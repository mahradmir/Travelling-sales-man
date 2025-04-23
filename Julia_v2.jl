###############################################################################
# CombinedROIAlgUnified_v2.jl
# © 2025 Mitra Jafaei & Mehrad Mir – All Rights Reserved
###############################################################################

using Statistics, LinearAlgebra, Random, Graphs, SimpleWeightedGraphs
using Clustering                       # DBSCAN
using FilePathsBase                    # lightweight path ops
import Base.Threads: @threads

# ---------- utility ------------------------------------------------------- #

tour_length(G, t) = sum(weight(G,t[i],t[i+1]) for i in 1:length(t)-1)

function write_tsplib(G, path)
    open(path, "w") do io
        println(io, "NAME: window")
        println(io, "TYPE: TSP")
        println(io, "DIMENSION: ", nv(G))
        println(io, "EDGE_WEIGHT_TYPE: EUC_2D")
        println(io, "NODE_COORD_SECTION")
        for v in vertices(G)
            x,y = G.vprops[v][:pos]
            @printf(io, "%d %.6f %.6f\n", v, x*10000, y*10000)
        end
        println(io,"EOF")
    end
end

function read_concorde_sol(path)
    t = Int[]
    open(path) do io
        for l in eachline(io)
            push!(t, parse(Int,l)+1)   # Concorde is 0-based
        end
    end
    push!(t, t[1])
    return t
end

function ConcordeSolve(G; tmpdir=mktempdir())
    tspfile = joinpath(tmpdir,"w.tsp")
    solfile = joinpath(tmpdir,"w.sol")
    write_tsplib(G,tspfile)
    run(`concorde -x -o $solfile $tspfile`; wait=true)
    tour = read_concorde_sol(solfile)
    return tour
end

# ---------- geometric helpers -------------------------------------------- #

function delaunay(G)
    V = [G.vprops[i][:pos] for i in 1:nv(G)]
    using DelaunayTriangulation
    tri = DelaunayTriangulation.DelaunayTriangulation(V)
    H = SimpleWeightedGraph(nv(G))
    for s in tri.simplices
        for (u,v) in ((s[1],s[2]),(s[2],s[3]),(s[3],s[1]))
            w = norm(V[u]-V[v])
            add_edge!(H,u,v,w)
        end
    end
    return H
end

function spanner(H,α)
    S = SimpleWeightedGraph(nv(H))
    for (u,v,w) in sortedges(H,by=e->e.weight)
        if !has_edge(S,u,v) && (!has_path(S,u,v) || distances(S,u,v)[1] > α*w)
            add_edge!(S,u,v,w)
        end
    end
    return S
end

# ---------- local search (2-opt CPU, GPU hook stub) ---------------------- #

function two_opt!(G, t, ε, maxIter)
    improved=true; it=0
    while improved && it<maxIter
        improved=false
        for i in 2:length(t)-2, j in i+1:length(t)-1
            Δ = weight(G,t[i-1],t[i]) + weight(G,t[j],t[j+1]) -
                weight(G,t[i-1],t[j]) - weight(G,t[i],t[j+1])
            if Δ < -ε
                t[i:j] = reverse(t[i:j]); improved=true
            end
        end
        it+=1
    end
end

# ---------- basic heuristics -------------------------------------------- #

function nearest_greedy(G)
    start=1; N=nv(G)
    unvisited=Set(2:N); tour=[start]
    cur=start
    while !isempty(unvisited)
        nxt = findmin(weight(G,cur,v) for v in unvisited)[2]
        push!(tour,nxt); delete!(unvisited,nxt); cur=nxt
    end
    push!(tour,start)
end

StreamingAlg(G, _) = nearest_greedy(G)

# ---------- clustering branch (unchanged) -------------------------------- #

# ... (reuse your previous CombinedAdaptiveAlg implementation) ...

# ---------- windowed with Concorde -------------------------------------- #

function WindowedDiscreteAlgWithConcorde(
        G,W,W0,
        ε_min,ε_max,maxIter,d_base,C,
        α,M,P,ε_scales,τ_min,τ_max,min_samples)

    n = nv(G); S = spanner(delaunay(G),α)
    idx = collect(vertices(S))
    windows = [idx[i:min(i+W-1,n)] for i in 1:W:n]

    tours = Vector{Vector{Int}}(undef,length(windows))

    @threads for w in eachindex(windows)
        sub = induced_subgraph(S, windows[w])
        if nv(sub) ≤ W0
            tours[w] = ConcordeSolve(sub)
        elseif nv(sub) ≤ 40
            tours[w] = nearest_greedy(sub); two_opt!(sub,tours[w],ε_min,maxIter)
        elseif nv(sub) ≤ 800
            tours[w] = nearest_greedy(sub); two_opt!(sub,tours[w],ε_min,maxIter)
        else
            tours[w] = StreamingAlg(sub,5)
        end
    end

    # stitch tours
    global_tour = tours[1]
    for k in 2:length(tours)
        global_tour = connect_tours(S, global_tour, tours[k])
    end
    two_opt!(S, global_tour, ε_min, maxIter)
    return global_tour
end

# ---------- dispatcher --------------------------------------------------- #

function CombinedROIAlgUnified(G;
        ε_min=0.001, ε_max=0.05,
        maxIter_base=1000,d_base=20,C=2.0,
        α=1.3,M=6,P=Threads.nthreads(),
        ParamRanges=(τ_min=20,τ_max=200,min_samples=5),
        n3=40,n1=800,n2=30_000,W0=9_000,
        β=1.25,δ=0.15,W=5_000)

    n = nv(G)

    if n ≤ n3
        t = nearest_greedy(G); two_opt!(G,t,0.0,10_000)
        return t
    elseif n ≤ n1
        t = nearest_greedy(G); two_opt!(G,t,ε_min,maxIter_base)
        return t
    elseif n ≤ n2
        return StreamingAlg(G,5)
    else
        return WindowedDiscreteAlgWithConcorde(G,W,W0,
               ε_min,ε_max,maxIter_base,d_base,C,
               α,M,P,[],ParamRanges.τ_min,ParamRanges.τ_max,ParamRanges.min_samples)
    end
end
