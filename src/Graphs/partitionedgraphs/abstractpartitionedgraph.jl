abstract type AbstractPartitionedGraph{V,PV} <: AbstractNamedGraph{V} end

#Needed for interface
partitioned_graph(pg::AbstractPartitionedGraph) = not_implemented()
graph(pg::AbstractPartitionedGraph) = not_implemented()
function vertices(pg::AbstractPartitionedGraph, partition_vertex::AbstractPartitionVertex)
  return not_implemented()
end
partition_vertex(pg::AbstractPartitionedGraph, vertex) = not_implemented()
copy(pg::AbstractPartitionedGraph) = not_implemented()
function add_to_vertex_map!(pg::AbstractPartitionedGraph, vertex, partition_vertex)
  return not_implemented()
end
rem_from_vertex_map!(pg::AbstractPartitionedGraph, vertex) = not_implemented()
partition_edge(pg::AbstractPartitionedGraph, edge::AbstractEdge) = not_implemented()
function edges(pg::AbstractPartitionedGraph, partition_edge::AbstractPartitionEdge)
  return not_implemented()
end

vertices(pg::AbstractPartitionedGraph) = vertices(graph(pg))
parent_graph(pg::AbstractPartitionedGraph) = parent_graph(graph(pg))
function vertex_to_parent_vertex(pg::AbstractPartitionedGraph, vertex)
  return vertex_to_parent_vertex(graph(pg), vertex)
end
edgetype(pg::AbstractPartitionedGraph) = edgetype(graph(pg))
function parent_graph_type(G::Type{<:AbstractPartitionedGraph})
  return fieldtype(fieldtype(G, :graph), :parent_graph)
end
directed_graph(G::Type{<:AbstractPartitionedGraph}) = directed_graph(fieldtype(G, :graph))
function undirected_graph(G::Type{<:AbstractPartitionedGraph})
  return unddirected_graph(fieldtype(G, :graph))
end
function has_vertex(pg::AbstractPartitionedGraph, partition_vertex::AbstractPartitionVertex)
  return has_vertex(partitioned_graph(pg), parent(partition_vertex))
end
function has_edge(pg::AbstractPartitionedGraph, edge::AbstractPartitionEdge)
  return has_edge(partitioned_graph(pg), parent(partition_edge))
end

function is_boundary_edge(pg::AbstractPartitionedGraph, edge::AbstractEdge)
  p_edge = partition_edge(pg, edge)
  return src(p_edge) == dst(p_edge)
end

function add_edge!(pg::AbstractPartitionedGraph, edge::AbstractEdge)
  add_edge!(graph(pg), edge)
  pg_edge = parent(partition_edge(pg, edge))
  if src(pg_edge) != dst(pg_edge)
    add_edge!(partitioned_graph(pg), pg_edge)
  end
end

function rem_edge!(pg::AbstractPartitionedGraph, edge::AbstractEdge)
  pg_edge = partition_edge(pg, edge)
  if has_edge(partitioned_graph(pg), pg_edge)
    g_edges = edges(pg, pg_edge)
    if length(g_edges) == 1
      rem_edge!(partitioned_graph(pg), pg_edge)
    end
  end

  return rem_edge!(graph(pg), edge)
end

function rem_edge!(pg::AbstractPartitionedGraph, partition_edge::AbstractPartitionEdge)
  return rem_edges!(pg, edges(pg, parent(partition_edge)))
end

function rem_edge(pg::AbstractPartitionedGraph, partition_edge::AbstractPartitionEdge)
  pg_new = copy(pg)
  rem_partition_edge!(pg_new, partition_edge)
  return pg_new
end

function rem_partition_edges!(
  pg::AbstractPartitionedGraph, partition_edges::Vector{AbstractPartitionEdge}
)
  for pe in partition_edges
    rem_edge!(pg, pe)
  end
end

function rem_partition_edges(
  pg::AbstractPartitionedGraph, partition_edges::Vector{AbstractPartitionEdge}
)
  pg_new = copy(pg)
  rem_partition_edges!(pg_new, partition_edges)
  return pg_new
end

#Vertex addition and removal. I think it's important not to allow addition of a vertex without specification of PV
function add_vertex!(
  pg::AbstractPartitionedGraph, vertex, partition_vertex::AbstractPartitionVertex
)
  add_vertex!(graph(pg), vertex)
  add_vertex!(partitioned_graph(pg), parent(partition_vertex))

  return add_to_vertex_map!(pg, vertex, partition_vertex)
end

function add_vertices!(
  pg::AbstractPartitionedGraph,
  vertices::Vector,
  partition_vertices::Vector{V} where {V<:AbstractPartitionVertex},
)
  @assert length(vertices) == length(partition_vertices)
  for (v, pv) in zip(vertices, partition_vertices)
    add_vertex!(pg, v, pv)
  end
end

function add_vertices!(
  pg::AbstractPartitionedGraph, vertices::Vector, partition_vertex::AbstractPartitionVertex
)
  return add_vertices!(pg, vertices, fill(partition_vertex, length(vertices)))
end

function rem_vertex!(pg::AbstractPartitionedGraph, vertex)
  rem_vertex!(graph(pg), vertex)
  pv = partition_vertex(pg, vertex)
  if length(vertices(pg, pv)) == 1
    rem_vertex!(partitioned_graph(pg), parent(pv))
  end
  return rem_from_vertex_map!(pg, vertex)
end

function rem_vertex!(
  pg::AbstractPartitionedGraph, partition_vertex::AbstractPartitionVertex
)
  return rem_vertices!(pg, vertices(pg, partition_vertex))
end

function rem_vertex(pg::AbstractPartitionedGraph, partition_vertex::AbstractPartitionVertex)
  pg_new = copy(pg)
  rem_vertex!(pg_new, partition_vertex)
  return pg_new
end

function rem_vertices!(
  pg::AbstractPartitionedGraph, partition_vertices::Vector{AbstractPartitionVertex}
)
  for pv in partition_vertices
    rem_vertex!(pg, pv)
  end
end

function rem_vertices(
  pg::AbstractPartitionedGraph, partition_vertices::Vector{AbstractPartitionVertex}
)
  pg_new = copy(rem_partition_vertex)
  rem_vertices!(pg_new, partition_vertices)
  return pg_new
end

function add_vertex!(pg::AbstractPartitionedGraph, vertex)
  return error("Need to specify a partition where the new vertex will go.")
end

function (pg1::AbstractPartitionedGraph == pg2::AbstractPartitionedGraph)
  if fieldnames(typeof(pg1)) != fieldnames(typeof(pg1))
    return false
  end

  for field in fieldnames(typeof(pg1))
    if getfield(pg1, field) != getfield(pg2, field)
      return false
    end
  end
  return true
end