using Graphs
using NamedGraphs

parent_graph = grid((2, 2))
vs = [("X", 1), ("X", 2), ("Y", 1), ("Y", 2)]

g = NamedGraph(parent_graph, vs)

@show has_vertex(g, ("X", 1))
@show has_edge(g, ("X", 1) => ("X", 2))
@show !has_edge(g, ("X", 2) => ("Y", 1))
@show has_edge(g, ("X", 2) => ("Y", 2))

g_sub = g[[("X", 1)]]

@show has_vertex(g_sub, ("X", 1))
@show !has_vertex(g_sub, ("X", 2))
@show !has_vertex(g_sub, ("Y", 1))
@show !has_vertex(g_sub, ("Y", 2))

g_sub = g[[("X", 1), ("X", 2)]]

@show has_vertex(g_sub, ("X", 1))
@show has_vertex(g_sub, ("X", 2))
@show !has_vertex(g_sub, ("Y", 1))
@show !has_vertex(g_sub, ("Y", 2))

# g_sub = g["X", :]
g_sub = subgraph(v -> v[1] == "X", g)

@show has_vertex(g_sub, ("X", 1))
@show has_vertex(g_sub, ("X", 2))
@show !has_vertex(g_sub, ("Y", 1))
@show !has_vertex(g_sub, ("Y", 2))

# g_sub = g[:, 2]
g_sub = subgraph(v -> v[2] == 2, g)

@show !has_vertex(g_sub, ("X", 1))
@show has_vertex(g_sub, ("X", 2))
@show !has_vertex(g_sub, ("Y", 1))
@show has_vertex(g_sub, ("Y", 2))

parent_graph = grid((2, 2))
g1 = NamedGraph(parent_graph; vertices=(2, 2))
g2 = NamedGraph(parent_graph; vertices=(2, 2))

g_disjoint_union = g1 ⊔ g2

@show nv(g_disjoint_union) == 8

## g_vcat = [g1; g2]
## 
## @show nv(g_vcat) == 8
## 
## g_hcat = [g1;; g2]
## 
## @show nv(g_hcat) == 8
