defmodule PushSum do
  use GenServer
  # API

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def send_message(pid, {message, number, topology, n, s_half, w_half}) do
    GenServer.cast(pid, {:send_message, message, number, topology, n, s_half, w_half})
  end

  def check_convergence(n, b, topo) do
    blacklist = Master.get_saturated(:global.whereis_name(:master))
    bllen = Kernel.length(blacklist)

    threshold = 1.0

    if(bllen / n >= threshold) do
      IO.puts("Time = #{(System.system_time(:millisecond) - b)/1000}")
      Process.exit(self(), :kill)
    end

    check_convergence(n, b, topo)
  end

  # SERVER

  def init(messages) do
    {:ok, messages}
  end

  def handle_cast({:send_message, new_message, number, topo, numNodes, halfS, halfW}, messages) do
    newS = Enum.at(messages, 0) + halfS
    newW = Enum.at(messages, 1) + halfW

    oldRatio = Enum.at(messages, 0) / Enum.at(messages, 1)
    newRatio = newS / newW

    oldCount =
      if oldRatio - newRatio < 0.0000000001 do
        if Enum.at(messages, 2) == 2 do
          Master.add_saturated(:global.whereis_name(:master), number)
        end

        Enum.at(messages, 2) + 1
      else
        0
      end

    halfS = newS / 2
    halfW = newW / 2

    newS = newS - halfS
    newW = newW - halfW

    newState = [newS, newW, oldCount]

    Task.async(fn -> keep_spreading(new_message, number, topo, numNodes, halfS, halfW) end)

    {:noreply, newState}
  end

  def keep_spreading(new_message, number, topo, numNodes, halfS, halfW) do
    :timer.sleep(1)
    r = Master.get_neighbour(:global.whereis_name(:master), number, topo, numNodes)
    nodeName = String.to_atom("node#{r}")

    PushSum.send_message(
      :global.whereis_name(nodeName),
      {
        new_message,
        r,
        topo,
        numNodes,
        halfS,
        halfW
      }
    )

    keep_spreading(new_message, number, topo, numNodes, halfS, halfW)
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
