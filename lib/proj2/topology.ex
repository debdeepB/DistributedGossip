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

      topology == "3D" ->
        lookup_3d_neighbour(l)

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

    map =
      Enum.reduce(1..n, %{}, fn node_id, acc ->
        Map.put(acc, node_id, x: :rand.uniform(), y: :rand.uniform())
      end)

    :ets.insert(table, {"data", map})
    initialize_2d_neighbour_table(n)
  end

  def initialize_2d_neighbour_table(n) do
    table = :ets.new(:random_2d_neighbour, [:named_table])

    map =
      Enum.reduce(1..n, %{}, fn node_id, acc ->
        Map.put(acc, node_id, find_2d_neighbour(node_id))
      end)

    :ets.insert(table, {"data", map})
  end

  def find_2d_neighbour(node_id) do
    [{_, map}] = :ets.lookup(:random_2d, "data")
    current_node = map[node_id]

    Enum.filter(1..map_size(map), fn id ->
      dist =
        (:math.pow(map[id][:x] - current_node[:x], 2) +
           :math.pow(map[id][:y] - current_node[:y], 2))
        |> :math.sqrt()

      dist < 0.5 and id != node_id
    end)
  end

  def lookup_2d_neighbour(node_id) do
    [{_, map}] = :ets.lookup(:random_2d_neighbour, "data")
    map[node_id]
  end

  def initialize_3d_tables({x, y, z}) do
    table = :ets.new(:three_d, [:named_table])
    :ets.insert(table, {"coord_to_node", Map.new()})
    :ets.insert(table, {"node_to_coord", Map.new()})
    :ets.insert(table, {"counter", 1})

    Enum.each(0..(z - 1), fn k ->
      Enum.each(0..(x - 1), fn i ->
        Enum.each(0..(y - 1), fn j ->
          [{_, coord_to_node_map}] = :ets.lookup(table, "coord_to_node")
          [{_, node_to_coord_map}] = :ets.lookup(table, "node_to_coord")
          [{_, counter}] = :ets.lookup(table, "counter")
          :ets.insert(table, {"coord_to_node", Map.put(coord_to_node_map, [i, j, k], counter)})
          :ets.insert(table, {"node_to_coord", Map.put(node_to_coord_map, counter, [i, j, k])})
          :ets.insert(table, {"counter", counter + 1})
        end)
      end)
    end)
  end

  def lookup_3d_neighbour(node_id) do
    [{_, coord_to_node_map}] = :ets.lookup(:three_d, "coord_to_node")
    [{_, node_to_coord_map}] = :ets.lookup(:three_d, "node_to_coord")
    [x, y, z] = node_to_coord_map[node_id]

    neighbours = [
      coord_to_node_map[[x + 1, y, z]],
      coord_to_node_map[[x - 1, y, z]],
      coord_to_node_map[[x, y + 1, z]],
      coord_to_node_map[[x, y - 1, z]],
      coord_to_node_map[[x, y, z + 1]],
      coord_to_node_map[[x, y, z - 1]]
    ]

    Enum.filter(neighbours, fn x -> x != nil end)
  end
end
