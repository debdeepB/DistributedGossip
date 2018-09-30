defmodule Topology do
  def imperfect_line_loop(neighbor, n, l) do
    rand = :rand.uniform(n)

    random_neighbor =
      if rand == l or Enum.member?(neighbor, rand) do
        imperfect_line_loop(neighbor, n, l)
      else
        rand
      end

    random_neighbor
  end

  def select_topology(topology, n, l) do
    cond do
      topology == "line" ->
        cond do
          l == 1 -> [l + 1]
          l == n -> [l - 1]
          true -> [l + 1, l - 1]
        end

      topology == "imperfect-line" ->
        neighbor =
          cond do
            l == 1 -> [l + 1]
            l == n -> [l - 1]
            true -> [l + 1, l - 1]
          end

        neighbor ++ [imperfect_line_loop(neighbor, n, l)]

      topology == "full" ->
        Enum.to_list(1..n)
      
      topology == "random-2D" ->
        lookup_2d_neighbour(l)

      true ->
        "Select a valid topology"
    end
  end

  def checkRnd(topology, n, l) do
    nodeList = select_topology(topology, n, l)
    nodeList = Enum.filter(nodeList, fn x -> x != l == true end)
    nodeList = Enum.filter(nodeList, fn x -> x != 0 == true end)
    nodeList = Enum.filter(nodeList, fn x -> x <= n == true end)
    nodeList = Enum.uniq(nodeList)
    nodeList
  end

  def initialize_ets_tables(n) do
    table = :ets.new(:random_2d, [:named_table])
    map = Enum.reduce 1..n, %{}, fn node_id, acc ->
      Map.put(acc, node_id, [x: :rand.uniform(), y: :rand.uniform()])
    end
    :ets.insert(table, {"data", map})
    initialize_2d_neighbour_table(n)
  end

  def initialize_2d_neighbour_table(n) do
    table = :ets.new(:random_2d_neighbour, [:named_table])
    map = Enum.reduce 1..n, %{}, fn node_id, acc ->
      Map.put(acc, node_id, find_2d_neighbour(node_id))
    end
    :ets.insert(table, {"data", map})
  end

  def find_2d_neighbour(node_id) do
    [{_, map}] = :ets.lookup(:random_2d, "data")
    current_node = map[node_id]
    Enum.filter 1..map_size(map), fn id ->
      dist = :math.pow(map[id][:x] - current_node[:x],2) + :math.pow(map[id][:y] - current_node[:y], 2) |> :math.sqrt()
      dist < 0.5 and id != node_id
    end
  end

  def lookup_2d_neighbour(node_id) do
    [{_, map}] = :ets.lookup(:random_2d_neighbour, "data")
    map[node_id]
  end
  
end
