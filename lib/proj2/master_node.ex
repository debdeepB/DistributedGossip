defmodule MasterNode do
  use GenServer

  def add_blacklist(pid, message) do
    GenServer.cast(pid, {:add_blacklist, message})
  end

  def get_blacklist(pid) do
    GenServer.call(pid, :get_blacklist, :infinity)
  end

  def get_whitelist(pid, nodeId, topo, numNodes) do
    GenServer.call(pid, {:get_whitelist, nodeId, topo, numNodes}, :infinity)
  end

  def whiteRandom(topo, numNodes, nodeId, messages) do
    nodeList = Topology.checkRnd(topo, numNodes, nodeId)
    nodeList = Enum.filter(nodeList, fn el -> !Enum.member?(messages, el) end)
    nodeLen = Kernel.length(nodeList)

    topoCheck =
      if topo == "line" or topo == "2D" do
        true
      else
        false
      end

    if nodeLen == 0 and topoCheck == true do
      :timer.sleep(1000)
      Process.exit(:global.whereis_name(:main_process), :kill)
    end

    if nodeLen == 0 do
      whiteRandom(topo, numNodes, nodeId, messages)
    else
      randomNeighbor = :rand.uniform(nodeLen)
      Enum.at(nodeList, randomNeighbor - 1)
    end
  end

  def init(messages) do
    {:ok, messages}
  end

  def handle_call(:get_blacklist, _from, messages) do
    {:reply, messages, messages}
  end

  def handle_call({:get_whitelist, nodeId, topo, numNodes}, _from, messages) do
    nodernd = whiteRandom(topo, numNodes, nodeId, messages)
    {:reply, nodernd, messages}
  end

  def handle_cast({:add_blacklist, new_message}, messages) do
    {:noreply, [new_message | messages]}
  end

  def s(n, b, topo) do
    blacklist = MasterNode.get_blacklist(:global.whereis_name(:nodeMaster))
    bllen = Kernel.length(blacklist)

    threshold =
      if topo == "line" or topo == "2D" do
        0.1
      else
        0.5
      end

    if(bllen / n >= threshold) do
      IO.puts("Time = #{System.system_time(:millisecond) - b}")
      Process.exit(self(), :kill)
    end

    s(n, b, topo)
  end
end
