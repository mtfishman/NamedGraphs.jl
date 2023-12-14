struct PartitionedGraph{V,PV,G<:AbstractNamedGraph{V},PG<:AbstractNamedGraph{PV}} <:
       AbstractPartitionedGraph{V,PV}
  graph::G
  partitioned_graph::PG
  partitioned_vertices::Dictionary{PV,Vector{V}}
  which_partition::Dictionary{V,PV}
end

##Constructors.
function PartitionedGraph{V,PV,G,PG}(
  g::AbstractNamedGraph{V}, partitioned_vertices::Dictionary{PV,Vector{V}}
) where {V,PV,G<:AbstractNamedGraph{V},PG<:AbstractNamedGraph{PV}}
  pvs = keys(partitioned_vertices)
  pg = NamedGraph(pvs)
  which_partition = Dictionary{V,PV}()
  for v in vertices(g)
    v_pvs = Set(findall(pv -> v ∈ partitioned_vertices[pv], pvs))
    @assert length(v_pvs) == 1
    insert!(which_partition, v, first(v_pvs))
  end

  for e in edges(g)
    pv_src, pv_dst = which_partition[src(e)], which_partition[dst(e)]
    pe = NamedEdge(pv_src => pv_dst)
    if pv_src != pv_dst && !has_edge(pg, pe)
      add_edge!(pg, pe)
    end
  end

  return PartitionedGraph(g, pg, partitioned_vertices, which_partition)
end

function PartitionedGraph(
  g::AbstractNamedGraph{V}, partitioned_vertices::Dictionary{PV,Vector{V}}
) where {V,PV}
  return PartitionedGraph{V,PV,NamedGraph{V},NamedGraph{PV}}(g, partitioned_vertices)
end

function PartitionedGraph{V,Int64,G,NamedGraph{Int64}}(
  g::AbstractNamedGraph{V}, partitioned_vertices::Vector{Vector{V}}
) where {V,G<:NamedGraph{V}}
  partitioned_vertices_dict = Dictionary{Int64,Vector{V}}(
    [i for i in 1:length(partitioned_vertices)], partitioned_vertices
  )
  return PartitionedGraph{V,Int64,NamedGraph{V},NamedGraph{Int64}}(
    g, partitioned_vertices_dict
  )
end

function PartitionedGraph(
  g::AbstractNamedGraph{V}, partition_vertices::Vector{Vector{V}}
) where {V}
  return PartitionedGraph{V,Int64,NamedGraph{V},NamedGraph{Int64}}(g, partition_vertices)
end

function PartitionedGraph{V,V,G,G}(vertices::Vector{V}) where {V,G<:NamedGraph{V}}
  return PartitionedGraph(NamedGraph{V}(vertices), [[v] for v in vertices])
end

function PartitionedGraph(vertices::Vector{V}) where {V}
  return PartitionedGraph{V,V,NamedGraph{V},NamedGraph{V}}(vertices)
end

function PartitionedGraph(
  g::AbstractNamedGraph{V};
  npartitions=nothing,
  nvertices_per_partition=nothing,
  backend=current_partitioning_backend(),
  kwargs...,
) where {V}
  partitioned_vertices = partition_vertices(
    g; npartitions, nvertices_per_partition, backend, kwargs...
  )
  return PartitionedGraph(g, partitioned_vertices)
end

#Needed for interface
partitioned_graph(pg::PartitionedGraph) = getfield(pg, :partitioned_graph)
graph(pg::PartitionedGraph) = getfield(pg, :graph)
partitioned_vertices(pg::PartitionedGraph) = getfield(pg, :partitioned_vertices)
which_partition(pg::PartitionedGraph) = getfield(pg, :which_partition)
function vertices(pg::PartitionedGraph, partition_vert::PartitionVertex)
  return partitioned_vertices(pg)[parent(partition_vert)]
end
function vertices(
  pg::PartitionedGraph, partition_verts::Vector{V}
) where {V<:PartitionVertex}
  return unique(reduce(vcat, [vertices(pg, pv) for pv in partition_verts]))
end
function which_partition(pg::PartitionedGraph, vertex)
  return PartitionVertex(which_partition(pg)[vertex])
end

function partition_edge(pg::PartitionedGraph, edge::AbstractEdge)
  return PartitionEdge(
    parent(which_partition(pg, src(edge))) => parent(which_partition(pg, dst(edge)))
  )
end

function partition_edges(pg::PartitionedGraph, partition_edge::PartitionEdge)
  psrc_vs, pdst_vs = vertices(pg, PartitionVertex(src(partition_edge))),
  vertices(pg, PartitionVertex(dst(partition_edge)))
  psrc_subgraph, pdst_subgraph, full_subgraph = subgraph(graph(pg), psrc_vs),
  subgraph(pg, pdst_vs),
  subgraph(pg, vcat(psrc_vs, pdst_vs))

  return setdiff(
    NamedGraphs.edges(full_subgraph),
    vcat(NamedGraphs.edges(psrc_subgraph), NamedGraphs.edges(pdst_subgraph)),
  )
end

#Copy on dictionaries is dodgy?!
function copy(pg::PartitionedGraph)
  return PartitionedGraph(
    copy(graph(pg)),
    copy(partitioned_graph(pg)),
    copy_keys_values(partitioned_vertices(pg)),
    copy_keys_values(which_partition(pg)),
  )
end

function insert_to_vertex_map!(
  pg::PartitionedGraph, vertex, partition_vertex::PartitionVertex
)
  pv = parent(partition_vertex)
  if pv ∉ keys(partitioned_vertices(pg))
    insert!(partitioned_vertices(pg), pv, [vertex])
  else
    pg.partitioned_vertices[pv] = unique(vcat(vertices(pg, partition_vertex), [vertex]))
  end

  return insert!(NamedGraphs.which_partition(pg), vertex, pv)
end

function delete_from_vertex_map!(pg::PartitionedGraph, vertex)
  pv = which_partition(pg, vertex)
  vs = vertices(pg, pv)
  delete!(partitioned_vertices(pg), parent(pv))
  if length(vs) != 1
    insert!(partitioned_vertices(pg), parent(pv), setdiff(vs, [vertex]))
  end
  return delete!(pg.which_partition, vertex)
end

### PartitionedGraph Specific Functions
function induced_subgraph(pg::PartitionedGraph, vertices::Vector)
  sub_pg_graph, _ = induced_subgraph(graph(pg), vertices)
  sub_partitioned_vertices = copy_keys_values(partitioned_vertices(pg))
  for pv in NamedGraphs.vertices(partitioned_graph(pg))
    vs = intersect(vertices, sub_partitioned_vertices[pv])
    if !isempty(vs)
      sub_partitioned_vertices[pv] = vs
    else
      delete!(sub_partitioned_vertices, pv)
    end
  end

  return PartitionedGraph(sub_pg_graph, sub_partitioned_vertices), nothing
end

### PartitionedGraph Specific Functions
function induced_subgraph(
  pg::PartitionedGraph, partition_verts::Vector{V}
) where {V<:PartitionVertex}
  return induced_subgraph(pg, vertices(pg, partition_verts))
end
