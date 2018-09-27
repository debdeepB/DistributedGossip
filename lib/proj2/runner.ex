defmodule Runner do
  def run(args) do
    b = System.system_time(:millisecond)
    :global.register_name(:jahin, self())
    numNodes = String.to_integer(Enum.at(args, 0))
    topo = Enum.at(args, 1)
    algorithm = Enum.at(args, 2)

    if topo == "2D" or topo == "imp2D" do
      sqrt = :math.sqrt(numNodes) |> Float.floor() |> round
      numNodes = :math.pow(sqrt, 2) |> round
    end

    startingNode = :rand.uniform(numNodes)

    cond do
      algorithm == "gossip" ->
        Gossip.createNodes(numNodes)
        {:ok, pid1} = GenServer.start_link(MasterNode, [], name: :nodeMaster)
        :global.register_name(:nodeMaster, pid1)
        :global.sync()
        nodeName = String.to_atom("node#{startingNode}")
        Gossip.add_message(:global.whereis_name(nodeName), "Gossip", startingNode, topo, numNodes)
        Gossip.s(numNodes, b, topo)

      algorithm == "push-sum" ->
        PushSum.createNodes(numNodes)
        {:ok, pid1} = GenServer.start_link(MasterNode, [], name: :nodeMaster)
        :global.register_name(:nodeMaster, pid1)

        :global.sync()
        nodeName = String.to_atom("node#{startingNode}")

        PushSum.add_message(
          :global.whereis_name(nodeName),
          "Push-Sum",
          startingNode,
          topo,
          numNodes,
          0,
          0
        )

        PushSum.s(numNodes, b, topo)

      true ->
        "Invalid algorithm"
    end
  end
end
