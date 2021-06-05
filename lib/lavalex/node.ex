defmodule Lavalex.Node do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    {:ok, websocket} = Lavalex.Socket.start_link(self())
    {:ok, %{websocket: websocket}}
  end

  def send(node, payload) do
    GenServer.cast(node, {:send, payload})
  end

  def message(node, message) do
    GenServer.cast(node, {:message, message})
  end

  def handle_cast({:send, payload}, %{websocket: websocket} = state) do
    WebSockex.send_frame(websocket, {:text, Poison.encode!(payload)})
    {:noreply, state}
  end

  def handle_cast({:message, {type, message}}, state) do
    IO.puts "Received Message - Type: #{inspect type} -- Message: #{inspect message}"
    {:noreply, state}
  end
end
