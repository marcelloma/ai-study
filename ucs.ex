Code.require_file("graph.ex")

defmodule PriorityQueue do
  def enqueue([], {val,pri}), do: [{val,pri}]
  def enqueue(queue, {val,pri}) do   
    Enum.find_index(queue, fn {_,xpri} -> xpri > pri end)
    |> case do
      nil -> List.insert_at(queue, -1, {val,pri})
      pos -> List.insert_at(queue, pos, {val,pri})
    end
  end

  def dequeue([]), do: {nil,[]}
  def dequeue([head|tail]), do: {head,tail}
end

defmodule BFS.State do
  defstruct [
    graph: Graph.new,
    goal: :empty,
    reached: Map.new,
    frontier: Keyword.new,
    node: nil,
  ]
end

defmodule BFS.Node do
  defstruct [
    label: :empty,
    parent: nil,
    total_cost: 0,
  ]

  def new({label,cost}, parent) do
    %__MODULE__{
      label: label,
      total_cost: parent.total_cost + cost,
      parent: parent,
    }
  end

  def print(node, str \\ "")
  def print(node, str) when is_nil(node.parent), do: to_string(node.label) <> str
  def print(node, str), do: print(node.parent, " => " <> to_string(node.label) <> str)
end

defmodule BFS do
  alias BFS.State
  alias BFS.Node

  def search(graph, current, goal) do
    node = %Node{label: current}
    frontier = expand(graph, node)
    
    %State{graph: graph, node: node, goal: goal, frontier: frontier}
    |> search
  end

  def search(state) when state.node.label == state.goal, do: {:success,state.node}
  def search(state) when length(state.frontier) == 0, do: {:failure}
  def search(state) do
    {{node,_},new_frontier} = PriorityQueue.dequeue(state.frontier)
    
    reached = Map.get(state.reached, node.label)
    cond do
      is_nil(reached) or node.total_cost < reached.total_cost ->
        reached = Map.put(state.reached, node.label, node)
        search %State{state|node: node, reached: reached, frontier: expand(state.graph, node, new_frontier)}   
      true ->
        search %State{state|node: node, frontier: new_frontier}   
    end
  end

  defp expand(graph, node, frontier \\ []) do
    Graph.get_adjacency(graph, node.label)
    |> Enum.map(& Node.new(&1, node) |> node_priority)
    |> Enum.reduce(frontier, & PriorityQueue.enqueue(&2, &1))
  end

  defp node_priority(node), do: {node,node.total_cost}
end

defmodule Main do
  def run do
    edges = [
      Graph.Edge.new(:Arad, :Zerind, 75),
      Graph.Edge.new(:Arad, :Timisoara, 118),
      Graph.Edge.new(:Arad, :Sibiu, 140),
      Graph.Edge.new(:Zerind, :Oradea, 71),
      Graph.Edge.new(:Oradea, :Sibiu, 151),
      Graph.Edge.new(:Timisoara, :Lugoj, 111),
      Graph.Edge.new(:Lugoj, :Mehadia, 70),
      Graph.Edge.new(:Mehadia, :Drobeta, 75),
      Graph.Edge.new(:Drobeta, :Craiova, 120),
      Graph.Edge.new(:Craiova, :Rimnicu_Vilcea, 146),
      Graph.Edge.new(:Craiova, :Pitesti, 138),
      Graph.Edge.new(:Sibiu, :Fagaras, 99),
      Graph.Edge.new(:Sibiu, :Rimnicu_Vilcea, 80),
      Graph.Edge.new(:Rimnicu_Vilcea, :Pitesti, 97),
      Graph.Edge.new(:Fagaras, :Bucharest, 211),
      Graph.Edge.new(:Pitesti, :Bucharest, 101),
      Graph.Edge.new(:Bucharest, :Urziceni, 85),
      Graph.Edge.new(:Bucharest, :Giurgiu, 90),
      Graph.Edge.new(:Urziceni, :Vaslui, 142),
      Graph.Edge.new(:Vaslui, :Iasi, 92),
      Graph.Edge.new(:Iasi, :Neamt, 87),
      Graph.Edge.new(:Urziceni, :Hirsova, 98),
      Graph.Edge.new(:Hirsova, :Eforie, 86),
    ]

    graph =
      Enum.reduce(edges, Graph.new, & Graph.add_edge(&2, &1))
      |> IO.inspect

    case BFS.search(graph, :Arad, :Bucharest) do
      {:success, node} ->
        IO.puts node.total_cost
        BFS.Node.print(node) |> IO.puts
      {:failure} ->
        IO.puts "Failed"
    end
  end
end

Main.run
