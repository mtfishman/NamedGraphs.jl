module NamedGraphs
# TODO: Delete this!
using AbstractTrees
using Dictionaries
using Graphs
using GraphsFlows
using LinearAlgebra
using SimpleTraits
using SparseArrays
using SplitApplyCombine
using SymRCM
using Suppressor

using Graphs.SimpleGraphs

# General utility functions
not_implemented() = error("Not implemented")

import Base:
  convert,
  copy,
  eltype,
  getindex,
  hcat,
  hvncat,
  show,
  to_index,
  to_indices,
  union,
  vcat,
  zero
# abstractnamedgraph.jl
import Graphs:
  a_star,
  add_edge!,
  add_vertex!,
  add_vertices!,
  adjacency_matrix,
  all_neighbors,
  bellman_ford_shortest_paths,
  bfs_parents,
  bfs_tree,
  blockdiag,
  boruvka_mst,
  center,
  common_neighbors,
  connected_components,
  connected_components!,
  degree,
  degree_histogram,
  desopo_pape_shortest_paths,
  diameter,
  dijkstra_shortest_paths,
  dst,
  dfs_parents,
  dfs_tree,
  eccentricity,
  edges,
  edgetype,
  enumerate_paths,
  floyd_warshall_shortest_paths,
  has_edge,
  has_path,
  has_vertex,
  indegree,
  induced_subgraph,
  inneighbors,
  is_connected,
  is_cyclic,
  is_directed,
  is_strongly_connected,
  is_weakly_connected,
  johnson_shortest_paths,
  kruskal_mst,
  merge_vertices,
  merge_vertices!,
  mincut,
  ne,
  neighbors,
  neighborhood,
  neighborhood_dists,
  nv,
  outdegree,
  outneighbors,
  prim_mst,
  periphery,
  radius,
  rem_vertex!,
  rem_edge!,
  spfa_shortest_paths,
  src,
  steiner_tree,
  topological_sort_by_dfs,
  tree,
  vertices,
  yen_k_shortest_paths
import SymRCM: symrcm

# abstractnamededge.jl
import Base: Pair, Tuple, show, ==, hash, eltype, convert
import Graphs: AbstractEdge, src, dst, reverse, reverse!


# TODO: Move to `lib/DictionariesExtensions/src/DictionariesExtensions.jl`.
include("Dictionaries/dictionary.jl")

include("lib/Keys/src/Keys.jl")
include("lib/GraphsExtensions/src/GraphsExtensions.jl")
include("abstractnamededge.jl")
include("namededge.jl")
include("abstractnamedgraph.jl")
include("decorate.jl")
include("shortestpaths.jl")
include("distance.jl")
include("distances_and_capacities.jl")
include("steiner_tree/steiner_tree.jl")
include("traversals/dfs.jl")
include("namedgraph.jl")
include("generators/named_staticgraphs.jl")
include("lib/PartitionedGraphs/src/PartitionedGraphs.jl")

# TODO: reexport Graphs.jl (except for `Graphs.contract`)
export NamedGraph,
  NamedDiGraph,
  NamedEdge,
  PartitionedGraph,
  PartitionEdge,
  PartitionVertex,
  Key,
  ⊔,
  named_binary_tree,
  named_grid,
  named_path_graph,
  named_path_digraph,
  # AbstractGraph
  boundary_edges,
  boundary_vertices,
  child_vertices,
  dijkstra_mst,
  dijkstra_parents,
  directed_graph,
  edge_path,
  inner_boundary_vertices,
  is_leaf,
  is_path_graph,
  is_self_loop,
  leaf_vertices,
  outer_boundary_vertices,
  permute_vertices,
  parent_vertex,
  subgraph,
  symrcm,
  symrcm_permute,
  undirected_graph,
  vertex_path,
  vertextype,
  # Graphs.jl
  a_star,
  adjacency_matrix,
  center,
  diameter,
  dijkstra_shortest_paths,
  dijkstra_tree,
  disjoint_union,
  eccentricity,
  eccentricities,
  incident_edges,
  comb_tree,
  named_comb_tree,
  neighborhood,
  neighborhood_dists,
  neighbors,
  nv,
  partitioned_graph,
  partitionedge,
  partitionedges,
  partitionvertex,
  partitionvertices,
  partitioned_vertices,
  path_digraph,
  path_graph,
  periphery,
  pre_order_dfs_vertices,
  post_order_dfs_vertices,
  post_order_dfs_edges,
  radius,
  rename_vertices,
  degree,
  degrees,
  indegree,
  indegrees,
  is_tree,
  outdegree,
  outdegrees,
  mincut_partitions,
  steiner_tree,
  unpartitioned_graph,
  weights

using PackageExtensionCompat: @require_extensions
function __init__()
  @require_extensions
end

end # module AbstractNamedGraphs
