###############################################################################
# CombinedROIAlgUnified.jl
# © 2025 Mitra Jafaei / Mehrad Mir – All Rights Reserved
###############################################################################

using Statistics, Random, LinearAlgebra
using Graphs, SimpleWeightedGraphs
using Clustering      # DBSCAN
using Metalhead       # برای GPU 2-opt (پلاگین دلخواه؛ می‌توانید CUDA.jl جایگزین کنید)

# ========================  ابزارهای عمومی  ================================= #

"""
    tour_length(G, tour)

وزن کل مسیر بسته.
"""
tour_length(G, tour) = sum(weight(G, tour[i], tour[i+1]) for i in 1:length(tour)-1)

two_opt_gain(G, tour, i, j) = weight(G,tour[i-1],tour[i]) +
                               weight(G,tour[j],tour[j%length(tour)+1]) -
                               weight(G,tour[i-1],tour[j]) -
                               weight(G,tour[i],tour[j%length(tour)+1])

# ---------- Delaunay + α-spanner (ساده؛ قابلِ تعویض با CGAL) --------------- #

function delaunay_triangulation(G)
    V = [G.vprops[i][:pos] for i in 1:nv(G)]
    tri = DelaunayTriangulation(V)
    H  = SimpleWeightedGraph(nv(G))
    for s in tri.simplices
        for (u,v) in [(s[1],s[2]),(s[2],s[3]),(s[3],s[1])]
            w = norm(V[u]-V[v])
            add_edge!(H,u,v,w)
        end
    end
    return H
end

function geometric_spanner(H, α)
    S = SimpleWeightedGraph(nv(H))
    V = 1:nv(H)
    for (u,v,w) in sortedges(H, by=e->e.weight)
        if !has_edge(S,u,v) &&
           ( !has_path(S,u,v) || distances(S,u,v)[1] > α*w )
            add_edge!(S,u,v,w)
        end
    end
    return S
end

# --------------------------  پایین-کران‌ها  -------------------------------- #

function statistical_lb(G,C)
    ws = Float64[e.weight for e in edges(G)]
    μ, σ = mean(ws), std(ws)
    return nv(G)*μ - C*σ*sqrt(nv(G))
end

function assignment_lb(G)
    D = adjacency_matrix(G)            # وزن صفر روی قطر باید بزرگ شود
    D = map((x,i,j)->i==j ? 1e12 : x, D, CartesianIndices(D))
    _, col = Hungarian(D)
    return sum(D[i,col[i]] for i in eachindex(col))
end

function one_tree_lb(G)
    best = Inf
    for r in 1:nv(G)
        H = spanningtree(delete_vertices(G, r))
        two = sort(weight.(Ref(G), r, neighbors(G,r)))[1:2]
        best = min(best, sum(weight.(H)) + sum(two))
    end
    return best
end

combined_lb(G,C) = maximum((statistical_lb(G,C),
                             assignment_lb(G),
                             one_tree_lb(G)))

# -------------------------- جست‌وجوی محلی ---------------------------------- #

function cpu_two_opt!(G, tour, ε, maxIter, k)
    it, improved = 0, true
    neigh = Dict(v => sort(neighbors(G,v); by=u->weight(G,v,u))[1:min(k,degree(G,v))]
                 for v in vertices(G))
    while improved && it < maxIter
        improved = false
        for i in 2:length(tour)-2
            for v in neigh[tour[i]]
                j = findfirst(==(v), tour)
                if isnothing(j) || j-i ≤ 1 || j≥length(tour) ; continue; end
                Δ = two_opt_gain(G,tour,i,j)
                if Δ < -ε
                    tour[i:j] = reverse(tour[i:j])
                    improved = true
                end
            end
        end
        it += 1
    end
    return tour
end

# (کرنل GPU آزمایشی؛ در صورت نبود CUDA مستقیماً cpu_two_opt! فراخوان)
gpu_two_opt!(G, tour, ε) = cpu_two_opt!(G,tour,ε,1,20)  # placeholder

# -------------------------  ExactSearch ------------------------------------ #

function exact_search(G, UB)
    best_len = UB
    best_tour = Int[]
    n = nv(G); start=1
    function dfs(prefix, used, ℓ)
        if length(prefix)==n
            total = ℓ + weight(G,prefix[end],start)
            if total < best_len
                best_len = total
                best_tour = vcat(prefix,start)
            end
            return
        end
        remaining = setdiff(1:n, used)
        # ساده: پایین‌کران MST روی باقی‌مانده
        LB = sum(weight.(spanningtree(induced_subgraph(G,remaining))))
        if ℓ+LB ≥ best_len; return; end
        u = prefix[end]
        for v in sort(remaining; by=x->weight(G,u,x))
            dfs(vcat(prefix,v), push!(copy(used),v), ℓ+weight(G,u,v))
        end
    end
    dfs([start], Set([start]), 0.0)
    return best_tour, best_len
end

# ------------------  CombinedAdaptiveAlg (Hierarchical)  ------------------- #

function combined_adaptive_alg(G,S,ε_min,ε_max,maxIter,k,d,C,τ_min,τ_max,min_samples,M)
    V = [S.vprops[i][:pos] for i in 1:nv(S)]
    ε_scales = exp.(range(log(ε_max), log(ε_min); length=4))
    clusters_raw = []
    for ε_DB in ε_scales
        lab = dbscan(V, ε_DB, min_samples).assignments
        for l in unique(lab)
            l==-1 && continue
            push!(clusters_raw, findall(==(l), lab))
        end
    end
    clusters = hierarchical_merge(clusters_raw)

    # تنظیم τ
    new_clusters=[]
    for cl in clusters
        if length(cl) > τ_max || length(cl) < τ_min
            ε = length(cl)>τ_max ? ε_min : ε_max*1.2
            lab=dbscan(V[cl],ε,min_samples).assignments
            for l in unique(lab); l==-1 && continue; push!(new_clusters, cl[lab.==l]); end
        else push!(new_clusters,cl) end
    end
    clusters = new_clusters

    # حل خوشه‌ها
    cluster_tours = Vector{Vector{Int}}(undef,length(clusters))
    for (idx,cl) in pairs(clusters)
        best_len=Inf
        for m=1:M
            ε_t = ε_min + (ε_max-ε_min)*exp(-3(m-1)/(M-1))
            tour = randperm(length(cl))
            cpu_two_opt!(induced_subgraph(G,cl), tour, ε_t, maxIter,k)
            len = tour_length(induced_subgraph(G,cl), tour)
            if len<best_len; best_len,cluster_tours[idx]=len,tour; end
        end
        cluster_tours[idx] = cl[cluster_tours[idx]]   # map به رئوس واقعی
        push!(cluster_tours[idx], cluster_tours[idx][1])
    end

    # گراف نماینده‌ها
    reps = [cl[1] for cl in clusters]
    G_cent = induced_subgraph(S,reps)
    best_cent = randperm(length(reps)); push!(best_cent,best_cent[1])
    for m=1:M
        ε_t = ε_min + (ε_max-ε_min)*exp(-3(m-1)/(M-1))
        cpu_two_opt!(G_cent, best_cent, ε_t, maxIter,k)
    end

    # ادغام
    full = Int[]
    for r in best_cent[1:end-1]
        idx = findfirst(==(r), reps)
        append!(full, cluster_tours[idx][1:end-1])
    end
    push!(full,full[1])
    cpu_two_opt!(G, full, ε_min, maxIter,k)
    return full, tour_length(G,full)
end

# --------------------- WindowedDiscreteAlg -------------------------------- #

function windowed_discrete_alg(G,W,n3,n1,ε_min,ε_max,maxIter,k,C,M,τ_min,τ_max,min_samples)
    windows = [collect(i:min(i+W-1,nv(G))) for i in 1:W:nv(G)]
    partials = Vector{Vector{Int}}()
    for win in windows
        sub = induced_subgraph(G,win)
        if length(win) ≤ n3
            t,_ = exact_search(sub, Inf)
        elseif length(win) ≤ n1
            t,_ = combined_adaptive_alg(sub, sub, ε_min, ε_max, maxIter,k,0,C,τ_min,τ_max,min_samples,M)
        else
            t,_ = linear_stream_tour(sub)
        end
        push!(partials, t)
    end
    tour = reduce((T1,T2)->connect_tours(G,T1,T2), partials)
    cpu_two_opt!(G,tour,ε_min,maxIter,k)
    return tour, tour_length(G,tour)
end

# ---------- Streaming ----------------------------------------------------- #

linear_stream_tour(G) = begin
    order = sort(vertices(G))
    push!(order, order[1])
    order, tour_length(G,order)
end

# -------------------- continuous_estimate -------------------------------- #

continuous_estimate(n,β,δ) = let L=β*sqrt(n)
    (L, L*(1-δ/sqrt(n)), L*(1+δ/sqrt(n)))
end

# ---------------------- ROI Dispatcher ----------------------------------- #

function CombinedROIAlgUnified(G;
        ε_min=0.001, ε_max=0.05,
        maxIter_base=1200, d_base=20, C=2.0,
        α=1.3, M=8, P=Threads.nthreads(),
        τ_min=20, τ_max=200, min_samples=5,
        n3=40, n1=800, n2=30_000,
        β=1.25, δ=0.15, W=5000)

    H = delaunay_triangulation(G)
    S = geometric_spanner(H,α)
    n = nv(G)

    if n ≤ n3
        trivialUB = combined_lb(G,C)*2
        tour,UB = exact_search(G,trivialUB)
        return tour,(UB,UB,UB)
    elseif n ≤ n1
        tour,len = combined_adaptive_alg(G,S,ε_min,ε_max,maxIter_base,d_base,d_base,C,
                                         τ_min,τ_max,min_samples,M)
        return tour,(len,combined_lb(G,C),len)
    elseif n ≤ n2
        tour,len = linear_stream_tour(S)
        return tour,(len,combined_lb(G,C),len)
    elseif n ≤ 10n2
        tour,len = windowed_discrete_alg(S,W,n3,n1,ε_min,ε_max,maxIter_base,
                                         d_base,C,M,τ_min,τ_max,min_samples)
        return tour,(len,combined_lb(G,C),len)
    else
        L,LB,UB = continuous_estimate(n,β,δ)
        return Int[],(L,LB,UB)
    end
end
