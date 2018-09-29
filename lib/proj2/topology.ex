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

      topology == "2D" ->
        j = :math.sqrt(n) |> round
        neighbor = []

        neighbor = if rem(l, j) == 0, do: neighbor ++ [l + 1], else: neighbor

        neighbor = if rem(l + 1, j), do: neighbor ++ [l - 1], else: neighbor

        neighbor = if l - j < 0, do: neighbor ++ [l + j], else: neighbor

        neighbor = if l - (n - j) >= 0, do: neighbor ++ [l - j], else: neighbor

        neighbor =
          if n > 4 do
            neighbor =
              if rem(l, j) != 0 and rem(l + 1, j) != 0 do
                neighbor ++ [l - 1, l + 1]
              else
                neighbor
              end

            neighbor =
              if l - j > 0 and l - (n - j) < 0 do
                neighbor ++ [l + j, l - j]
              else
                neighbor
              end

            neighbor = if l == j, do: neighbor ++ [l - j, l + j], else: neighbor

            neighbor
          else
            neighbor
          end

        neighbor

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
end
