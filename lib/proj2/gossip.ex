defmodule Gossip do
  use GenServer

  # API

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def add_message(pid, message, number, topo, numNodes) do
    GenServer.cast(pid, {:add_message, message, number, topo, numNodes})
  end

  def s(n, b, topo) do
    blacklist = MasterNode.get_blacklist(:global.whereis_name(:nodeMaster))
    bllen = Kernel.length(blacklist)
    threshold = 0.1

    if topo == "line" or topo == "2D" do
      threshold = 0.1
    else
      threshold = 0.5
    end

    if(bllen / n >= threshold) do
      IO.puts("Time = #{System.system_time(:millisecond) - b}")
      Process.exit(self(), :kill)
    end

    s(n, b, topo)
  end

  # SERVER

  def init(messages) do
    {:ok, messages}
  end

  def handle_cast({:add_message, new_message, number, topo, numNodes}, messages) do
    if messages == 9 do
      MasterNode.add_blacklist(:global.whereis_name(:nodeMaster), number)
    end

    r = MasterNode.get_whitelist(:global.whereis_name(:nodeMaster), number, topo, numNodes)
    nodeName = String.to_atom("node#{r}")
    :timer.sleep(1)
    Gossip.add_message(:global.whereis_name(nodeName), new_message, r, topo, numNodes)
    {:noreply, messages + 1}
  end

  def createNodes(times) do
    if times > 0 do
      nodeName = String.to_atom("node#{times}")
      {:ok, pid} = GenServer.start_link(Gossip, 1, name: nodeName)
      :global.register_name(nodeName, pid)
      createNodes(times - 1)
    end
  end
end
