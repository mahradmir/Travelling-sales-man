using Random, Graphs, SimpleWeightedGraphs
include("CombinedROIAlgUnified.jl")

# گراف اقلیدسی تصادفی
n = 300
pos = rand(n,2)
G  = SimpleWeightedGraph(n)
for i=1:n-1, j=i+1:n
    w = norm(pos[i,:]-pos[j,:])
    add_edge!(G,i,j,w)
end
for i in 1:n; G.vprops[i][:pos] = pos[i,:]; end

tour, (len, LB, UB) = CombinedROIAlgUnified(G)
println("Tour length = $len  (LB=$LB  UB=$UB)")
