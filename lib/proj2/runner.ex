defmodule Runner do
  def run(args) do
    start_time = System.system_time(:millisecond)
    
    :global.register_name(:main_process, self())

    [n, topology, algorithm] = args
    n = String.to_integer(n)

    if topology == "2D" or topology == "imp2D" do
      sqrt = :math.sqrt(n) |> Float.floor() |> round
      n = :math.pow(sqrt, 2) |> round
    end

    starting_node = :rand.uniform(n)

    case args do
      [_, _, "gossip"] ->
        run_gossip(n, starting_node, topology, start_time)
      [_, _, "push-sum"] ->
        run_pushsum(n, starting_node, topology, start_time)  
      _ ->
        "Invalid algorithm"
    end
  end

  def run_gossip(n, starting_node, topology, start_time) do
    Gossip.createNodes(n)
    {:ok, pid} = GenServer.start_link(MasterNode, [], name: :nodeMaster)
    :global.register_name(:nodeMaster, pid)
    :global.sync()
    name = String.to_atom("node#{starting_node}")
    Gossip.add_message(:global.whereis_name(name), "Gossip", starting_node, topology, n)
    Gossip.s(n, start_time, topology)
  end

  def run_pushsum(n, starting_node, topology, start_time) do
    PushSum.createNodes(n)
    {:ok, pid} = GenServer.start_link(MasterNode, [], name: :nodeMaster)
    :global.register_name(:nodeMaster, pid)
    :global.sync()
    name = String.to_atom("node#{starting_node}")
    PushSum.add_message(
      :global.whereis_name(name),
      "Push-Sum",
      starting_node,
      topology,
      n,
      0,
      0
    )
    PushSum.s(n, start_time, topology)
  end

end
