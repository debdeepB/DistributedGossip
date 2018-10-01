defmodule Runner do
  def run(args) do
    start_time = System.system_time(:millisecond)

    :global.register_name(:main_process, self())

    n = preprocess_network(args)

    starting_node = :rand.uniform(n)

    case args do
      [_, topology, "gossip"] ->
        run_gossip({n, starting_node, topology}, start_time)

      [_, topology, "push-sum"] ->
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
    check_convergence(:gossip, n, start_time)
  end

  def run_pushsum({n, starting_node, topology}, start_time) do
    PushSum.createNodes(n)
    {:ok, pid} = GenServer.start_link(MasterNode, [], name: :nodeMaster)
    :global.register_name(:nodeMaster, pid)
    :global.sync()
    name = String.to_atom("node#{starting_node}")

    PushSum.send_message(
      :global.whereis_name(name),
      {
        "Push-Sum",
        starting_node,
        topology,
        n,
        0,
        0
      }
    )

    PushSum.s(n, start_time, topology)
  end

  def check_convergence(:gossip, n, start_time) do
    converged =
      Enum.all?(1..n, fn node_num ->
        name = String.to_atom("node#{node_num}")
        messages = :sys.get_state(:global.whereis_name(name))
        messages > 1
      end)

    if converged do
      IO.puts("Converged in #{(System.system_time(:millisecond) - start_time) / 1000} seconds")
      Process.exit(self(), :kill)
    end

    check_convergence(:gossip, n, start_time)
  end

  def check_convergence(:push_sum, n, start_time) do
    converged =
      Enum.all?(1..n, fn node_num ->
        name = String.to_atom("node#{node_num}")
        messages = :sys.get_state(:global.whereis_name(name))
        messages = Enum.at(messages, 2)
        messages > 0
      end)

    if converged do
      IO.puts("Converged in #{(System.system_time(:millisecond) - start_time) / 1000} seconds")
      Process.exit(self(), :kill)
    end

    check_convergence(:push_sum, n, start_time)
  end

  def preprocess_network([n, topology, _algorithm]) do
    n = String.to_integer(n)

    cond do
      topology == "random-2D" ->
        sqrt = :math.sqrt(n) |> Float.floor() |> round
        n = :math.pow(sqrt, 2) |> round
        Topology.initialize_ets_tables(n)
        n

      topology == "3D" ->
        cuberoot = :math.pow(n, 0.33) |> round
        n = :math.pow(cuberoot, 3) |> round
        Topology.initialize_3d_tables({cuberoot, cuberoot, cuberoot})
        n

      topology == "torus" ->
        sqrt = :math.sqrt(n) |> Float.floor() |> round
        n = :math.pow(sqrt, 2) |> round
        Topology.initialize_torus_table(n)
        n

      true ->
        n
    end
  end
end
