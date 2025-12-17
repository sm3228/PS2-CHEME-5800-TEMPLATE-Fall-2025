function _search(graph::MySimpleDirectedGraphModel, start::MyGraphNodeModel,
    algorithm::DijkstraAlgorithm)

    # initialize -
    distances = Dict{Int64, Float64}()
    previous  = Dict{Int64, Union{Nothing, Int64}}()
    queue     = PriorityQueue{Int64, Float64}() # DataStructures.jl

    # set distances and previous -
    for (k, _) ∈ graph.nodes
        distances[k] = (k == start.id) ? 0.0 : Inf
        previous[k]  = nothing
        enqueue!(queue, k, distances[k])
    end

    # main loop -
    while !isempty(queue)
        u = dequeue!(queue)

        # if the smallest thing left is Inf, remaining nodes are unreachable
        if distances[u] == Inf
            break
        end

        childset = mychildren(graph, graph.nodes[u])
        for w ∈ childset
            alt = distances[u] + myweight(graph, u, w)
            if alt < distances[w]
                distances[w] = alt
                previous[w]  = u
                queue[w]     = alt # decrease-key
            end
        end
    end

    return distances, previous
end


function _search(graph::MySimpleDirectedGraphModel, start::MyGraphNodeModel,
    algorithm::BellmanFordAlgorithm)

    # initialize -
    distances = Dict{Int64, Float64}()
    previous  = Dict{Int64, Union{Nothing, Int64}}()

    nodes = graph.nodes
    n = length(nodes)

    # initialize distance and previous dictionaries -
    for (_, node) ∈ nodes
        distances[node.id] = Inf
        previous[node.id]  = nothing
    end
    distances[start.id] = 0.0

    # relax edges |V|-1 times
    for _ in 1:(n - 1)
        updated = false

        for ((u, v), _) ∈ graph.edges
            # skip unreachable nodes
            if distances[u] == Inf
                continue
            end

            alt = distances[u] + myweight(graph, u, v)
            if alt < distances[v]
                distances[v] = alt
                previous[v]  = u
                updated = true
            end
        end

        # early exit if no updates
        if !updated
            break
        end
    end

    # negative cycle detection
    for ((u, v), _) ∈ graph.edges
        if distances[u] == Inf
            continue
        end
        if distances[u] + myweight(graph, u, v) < distances[v]
            throw(ArgumentError("The graph contains a negative cycle"))
        end
    end

    return distances, previous
end


# --- PUBLIC API BELOW HERE --------------------------------------------------------------------------- #

function mychildren(graph::MySimpleDirectedGraphModel,
        node::MyGraphNodeModel)::Set{Int64}
    return graph.children[node.id]
end

# graph.edges is assumed to store weights directly as Float64 at key (source,target)
function myweight(graph::MySimpleDirectedGraphModel, source::Int64, target::Int64)::Float64
    return graph.edges[(source, target)]
end

function myfindshortestpath(graph::MySimpleDirectedGraphModel, start::MyGraphNodeModel;
    algorithm::Union{BellmanFordAlgorithm, DijkstraAlgorithm} = BellmanFordAlgorithm())
    return _search(graph, start, algorithm)
end

# --- PUBLIC API ABOVE HERE --------------------------------------------------------------------------- #
