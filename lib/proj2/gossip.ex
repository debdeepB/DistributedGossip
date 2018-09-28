defmodule Gossip do
  use GenServer

  # client apis
  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def send_message(pid, {message, number, topology, n}) do
    GenServer.cast(pid, {:send_message, message, number, topology, n})
  end

  def s(n, start_time, topo) do
    blacklist = MasterNode.get_blacklist(:global.whereis_name(:nodeMaster))
    bllen = Kernel.length(blacklist)
    threshold = 0.1

    if topo == "line" or topo == "2D" do
      threshold = 0.1
    else
      threshold = 0.5
    end

    if(bllen / n >= threshold) do
      IO.puts("Time = #{System.system_time(:millisecond) - start_time}")
      Process.exit(self(), :kill)
    end

    s(n, start_time, topo)
  end

  # server apis

  def init(messages) do
    {:ok, messages}
  end

  def handle_cast({:send_message, new_message, number, topo, numNodes}, messages) do
    if messages == 9 do
      MasterNode.add_blacklist(:global.whereis_name(:nodeMaster), number)
    end

    r = MasterNode.get_whitelist(:global.whereis_name(:nodeMaster), number, topo, numNodes)
    nodeName = String.to_atom("node#{r}")
    :timer.sleep(1)
    Gossip.send_message(:global.whereis_name(nodeName), {new_message, r, topo, numNodes})
    {:noreply, messages + 1}
  end

  # other methods

  def init_nodes(num) do
    Enum.each(1..num, fn i -> create_node(i) end)
  end

  def create_node(n) do
    name = String.to_atom("node#{n}")
    {:ok, pid} = GenServer.start_link(Gossip, 1, name: name)
    :global.register_name(name, pid)
  end
end
