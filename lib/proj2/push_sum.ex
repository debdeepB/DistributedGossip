defmodule PushSum do
  use GenServer
  # API

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def add_message(pid, message, number, topo, numNodes, halfS, halfW) do
    GenServer.cast(pid, {:add_message, message, number, topo, numNodes, halfS, halfW})
  end

  def s(n, b, topo) do
    blacklist = MasterNode.get_saturated(:global.whereis_name(:nodeMaster))
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

  def handle_cast({:add_message, new_message, number, topo, numNodes, halfS, halfW}, messages) do
    newS = Enum.at(messages, 0) + halfS
    newW = Enum.at(messages, 1) + halfW

    oldRatio = Enum.at(messages, 0) / Enum.at(messages, 1)
    newRatio = newS / newW

    oldCount = 0

    if oldRatio - newRatio < 0.0000000001 do
      if Enum.at(messages, 2) == 2 do
        MasterNode.add_saturated(:global.whereis_name(:nodeMaster), number)
      end

      oldCount = Enum.at(messages, 2) + 1
    end

    halfS = newS / 2
    halfW = newW / 2

    newS = newS - halfS
    newW = newW - halfW

    newState = [newS, newW, oldCount]

    r = MasterNode.get_neighbour(:global.whereis_name(:nodeMaster), number, topo, numNodes)
    nodeName = String.to_atom("node#{r}")

    PushSum.add_message(
      :global.whereis_name(nodeName),
      new_message,
      r,
      topo,
      numNodes,
      halfS,
      halfW
    )

    {:noreply, newState}
  end

  def createNodes(times) do
    if times > 0 do
      nodeName = String.to_atom("node#{times}")
      {:ok, pid} = GenServer.start_link(PushSum, [times, 1, 0], name: nodeName)
      :global.register_name(nodeName, pid)
      createNodes(times - 1)
    end
  end
end
