function _search(graph::MySimpleDirectedGraphModel, start::MyGraphNodeModel, 
    algorithm::DijkstraAlgorithm)
    
    # initialize -
    distances = Dict{Int64, Float64}();
    previous = Dict{Int64, Union{Nothing,Int64}}();
    queue = PriorityQueue{Int64, Float64}(); # exported from DataStructures.jl

    # set distances and previous -
    distances[start.id] = 0.0; # distance from start to start is zero
    for (k, _) ∈ graph.nodes # what is this?
        if k != start.id
            distances[k] = Inf;
            previous[k] = nothing;
        end
        enqueue!(queue, k, distances[k]); # add nodes to the queue
    end

    # main loop -
    while !isempty(queue) # process nodes in the queue until it is empty (!isempty(queue) is the same as isempty(queue) == false)
        u = dequeue!(queue);
        mychildren = children(graph, graph.nodes[u]);

        for w ∈ mychildren # iterate over the children set of the current node
            alt = distances[u] + myweight(graph, u, w); # distance to u so far + weight of edge from u to w
            if alt < distances[w] # Wow! the distance to w is less than the current best distance to w
                distances[w] = alt;
                previous[w] = u;
                queue[w] = alt;
            end
        end
    end

    # return -
    return distances, previous;
end

function _search(graph::MySimpleDirectedGraphModel, start::MyGraphNodeModel, 
    algorithm::BellmanFordAlgorithm)

    # initialize -
    distances = Dict{Int64, Float64}();
    previous = Dict{Int64, Union{Nothing,Int64}}();
    nodes = graph.nodes;
    number_of_nodes = length(nodes);
    counter = 1; # loop counter

    # initialize distance and previous dictionaries -
    for (_, node) ∈ nodes
        distances[node.id] = Inf;
        previous[node.id] = nothing;
    end
    distances[start.id] = 0.0;

    # TODO: Implement the Bellman-Ford algorithm here. See pseudocode in lecture notes.
    # TODO: Don't forget to uncomment the throw statement below when you are done implementing the algorithm.
    throw(ArgumentError("Bellman-Ford algorithm not yet implemented"));
     counter = 1;
    while counter < (number_of_nodes - 1)
        
        for (k, _) ∈ graph.edges

            u = k[1];
            v = k[2];

            alt = distances[u] + weight(graph, u, v);
            if alt < distances[v]
                distances[v] = alt;
                previous[v] = u;
            end
        end

        # increment counter -
        counter += 1;
    end

    # check: If we have negatice cycles, then we should throw an error. 
    for (k, _) ∈ graph.edges

        u = k[1];
        v = k[2];

        if distances[u] + myweight(graph, u, v) < distances[v]
            throw(ArgumentError("The graph contains a negative cycle"));
        end
    end

    # return -
    return distances, previous;
end


# --- PUBLIC API BELOW HERE --------------------------------------------------------------------------- #

"""
    function children(graph::MySimpleDirectedGraphModel, node::MyGraphNodeModel) -> Set{Int64} where T <: AbstractGraphModel

Returns the set of child node IDs for a given node in the graph.

### Arguments
- `graph::MySimpleDirectedGraphModel`: The graph to search where `T <: AbstractGraphModel`.
- `node::MyGraphNodeModel`: The node to find children for.

### Returns
- `Set{Int64}`: The set of child node IDs.
"""
function mychildren(graph::MySimpleDirectedGraphModel, 
        node::MyGraphNodeModel)::Set{Int64}
    return graph.children[node.id];
end

"""
    function weight(graph::MySimpleDirectedGraphModel, source::Int64, target::Int64, edgemodels::Dict{Int64, MyGraphEdgeModel}) -> Any where T <: AbstractGraphModel

Returns the weight of the edge between two nodes in the graph.

### Arguments
- `graph::MySimpleDirectedGraphModel`: The graph to search where `T <: AbstractGraphModel`.
- `source::Int64`: The ID of the source node.
- `target::Int64`: The ID of the target node.

### Returns
- `Any`: The weight of the edge between the source and target nodes. We have this as `Any` to allow for flexibility in edge weights, which can be of any type.
"""
function myweight(graph::MySimpleDirectedGraphModel, source::Int64, target::Int64, 
    edgemodels::Dict{Int64, MyGraphEdgeModel})::Any
    
    # do a has key?
    if !haskey(graph.edges, (source, target))
        return nothing # or throw an error?
    end

    edge_id = graph.edges[(source, target)]
    if edge_id === nothing
        return nothing # or throw an error?
    end
    return edgemodels[edge_id].weight
end

"""
    function weight(graph::MySimpleDirectedGraphModel, source::Int64, target::Int64) -> Float64 where T <: AbstractGraphModel

This function returns the weight of the edge between two nodes in a graph model.

### Arguments
- `graph::MySimpleDirectedGraphModel`: the graph model to search. This is a subtype of `AbstractGraphModel`.
- `source::Int64`: the source node id.
- `target::Int64`: the target node id.

### Returns
- the weight of the edge between the source and target nodes.
"""
function myweight(graph::MySimpleDirectedGraphModel, source::Int64, target::Int64)::Float64  
    return graph.edges[(source, target)][1];
end

"""
    findshortestpath(graph::MySimpleDirectedGraphModel, start::MyGraphNodeModel; 
        algorithm::AbstractGraphSearchAlgorithm = BellmanFordAlgorithm()) where T <: AbstractGraphModel

The function computes the shortest paths from a starting node to all other nodes in a graph model. 

### Arguments
- `graph::MySimpleDirectedGraphModel`: the graph model to search. This is a subtype of `AbstractGraphModel`.
- `start::MyGraphNodeModel`: the node to start the search from.
- `algorithm::MyAbstractGraphSearchAlgorithm`: the algorithm to use for the search. The default is `BellmanFordAlgorithm`, but it can also be `DijkstraAlgorithm`.

### Returns
- a tuple of two dictionaries: the first dictionary contains the distances from the starting node to all other nodes, and the second dictionary contains the previous node in the shortest path from the starting node to all other nodes.
"""
function myfindshortestpath(graph::MySimpleDirectedGraphModel, start::MyGraphNodeModel;
    algorithm::Union{BellmanFordAlgorithm, DijkstraAlgorithm} = BellmanFordAlgorithm())
    return _search(graph, start, algorithm);
end
# --- PUBLIC API ABOVE HERE --------------------------------------------------------------------------- #