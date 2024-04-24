using Graphs.SimpleGraphs: AbstractSimpleGraph

# https://github.com/JuliaGraphs/Graphs.jl/issues/365
function graph_from_vertices(graph_type::Type{<:AbstractSimpleGraph}, vertices)
  @assert vertices == Base.OneTo(length(vertices))
  return graph_type(length(vertices))
end

using Graphs.SimpleGraphs: SimpleDiGraph, SimpleGraph

directed_graph_type(G::Type{<:SimpleGraph}) = SimpleDiGraph{vertextype(G)}
# TODO: Use traits to make this more general.
undirected_graph_type(G::Type{<:SimpleGraph}) = G

# TODO: Use traits to make this more general.
directed_graph_type(G::Type{<:SimpleDiGraph}) = G
undirected_graph_type(G::Type{<:SimpleDiGraph}) = SimpleGraph{vertextype(G)}
