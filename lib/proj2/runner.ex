defmodule Runner do
  def run(args) do
    start_time = System.system_time(:millisecond)

    :global.register_name(:main_process, self())

    [n, topology, algorithm] = args
    n = String.to_integer(n)

    n =
      if topology == "2D" or topology == "imp2D" do
        sqrt = :math.sqrt(n) |> Float.floor() |> round
        :math.pow(sqrt, 2) |> round
      else
        n
      end

    starting_node = :rand.uniform(n)

    case args do
      [_, _, "gossip"] ->
        run_gossip({n, starting_node, topology}, start_time)

      [_, _, "push-sum"] ->
        run_pushsum({n, starting_node, topology}, start_time)

      _ ->
        "Invalid algorithm"
    end
  end

  def run_gossip({n, starting_node, topology}, start_time) do
    Gossip.init_nodes(n)
    {:ok, pid} = GenServer.start_link(MasterNode, [], name: :nodeMaster)
    :global.register_name(:nodeMaster, pid)
    :global.sync()
    name = String.to_atom("node#{starting_node}")
    Gossip.send_message(:global.whereis_name(name), {"Gossip", starting_node, topology, n})
    # check_convergence(n, start_time)
    MasterNode.s(n, start_time, topology)
  end

  def run_pushsum({n, starting_node, topology}, start_time) do
    PushSum.createNodes(n)
    {:ok, pid} = GenServer.start_link(MasterNode, [], name: :nodeMaster)
    :global.register_name(:nodeMaster, pid)
    :global.sync()
    name = String.to_atom("node#{starting_node}")

    PushSum.send_message(
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

  def check_convergence(n, start_time) do
    converged =
      Enum.all?(1..n, fn node_num ->
        name = String.to_atom("node#{node_num}")
        messages = :sys.get_state(:global.whereis_name(name), :infinity)
        messages > 1
      end)

    if converged do
      IO.puts("Time = #{System.system_time(:millisecond) - start_time}")
      Process.exit(self(), :kill)
    end

    check_convergence(n, start_time)
  end
end
