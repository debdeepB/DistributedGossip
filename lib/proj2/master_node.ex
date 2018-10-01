defmodule MasterNode do
  use GenServer

  def add_saturated(pid, node_num) do
    GenServer.cast(pid, {:add_saturated, node_num})
  end

  def get_saturated(pid) do
    GenServer.call(pid, :get_saturated, :infinity)
  end

  def get_neighbour(pid, node_id, topology, n) do
    GenServer.call(pid, {:get_neighbour, node_id, topology, n}, :infinity)
  end

  def whiteRandom(topo, numNodes, nodeId, messages) do
    nodeList = Topology.checkRnd(topo, numNodes, nodeId)
    nodeList = Enum.filter(nodeList, fn el -> !Enum.member?(messages, el) end)
    nodeLen = Kernel.length(nodeList)

    if nodeLen == 0 do
      :noneighbour
    else
      randomNeighbor = :rand.uniform(nodeLen)
      Enum.at(nodeList, randomNeighbor - 1)
    end
  end

  def init(messages) do
    {:ok, messages}
  end

  def handle_call(:get_saturated, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:get_neighbour, node_id, topology, n}, _from, state) do
    neighbour_id = whiteRandom(topology, n, node_id, state)
    {:reply, neighbour_id, state}
  end

  def handle_cast({:add_saturated, node_num}, state) do
    {:noreply, [node_num | state]}
  end

  def s(n, b, topo) do
    blacklist = MasterNode.get_saturated(:global.whereis_name(:nodeMaster))
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
