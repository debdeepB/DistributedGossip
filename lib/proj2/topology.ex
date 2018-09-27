defmodule Topology do
  def imp2Dloop(n, neighbor, l) do
    ran = :rand.uniform(n)

    if ran == l or Enum.member?(neighbor, ran) == true do
      imp2Dloop(n, neighbor, l)
    else
      ran
    end
  end

  def select_topology(topology, n, l) do
    max = n
    number2d = l

    cond do
      topology == "line" ->
        cond do
          l == 1 -> neighbor = [l + 1]
          l == max -> neighbor = [l - 1]
          true -> neighbor = [l + 1, l - 1]
        end

      topology == "full" ->
        neighbor = Enum.to_list(1..max)

      topology == "2D" or topology == "imp2D" ->
        j = :math.sqrt(n) |> round
        neighbor = []

        if rem(l, j) == 0 do
          neighbor = neighbor ++ [l + 1]
        end

        if rem(l + 1, j) do
          neighbor = neighbor ++ [l - 1]
        end

        if l - j < 0 do
          neighbor = neighbor ++ [l + j]
        end

        if l - (n - j) >= 0 do
          neighbor = neighbor ++ [l - j]
        end

        if n > 4 do
          if rem(l, j) != 0 and rem(l + 1, j) != 0 do
            neighbor = neighbor ++ [l - 1]
            neighbor = neighbor ++ [l + 1]
          end

          if l - j > 0 and l - (n - j) < 0 do
            neighbor = neighbor ++ [l + j]
            neighbor = neighbor ++ [l - j]
          end

          if l == j do
            neighbor = neighbor ++ [l - j]
            neighbor = neighbor ++ [l + j]
          end
        end

        if topology == "imp2D" do
          rnd = imp2Dloop(n, neighbor, l)
          neighbor = neighbor ++ [rnd]
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
