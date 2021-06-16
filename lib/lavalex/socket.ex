defmodule Lavalex.Socket do
  use WebSockex

  def start_link(node) do
    headers = [
      Authorization: Application.get_env(:lavalex, :password),
      "Num-Shards": Application.get_env(:lavalex, :num_shards),
      "User-Id": Application.get_env(:lavalex, :user_id)
    ]

    WebSockex.start_link(
      "ws://" <> Application.get_env(:lavalex, :host),
      __MODULE__,
      node,
      extra_headers: headers,
      name: __MODULE__
    )
  end

  def handle_frame(frame, node) do
    Lavalex.Node.message(node, frame)
    {:ok, node}
  end

  def handle_cast({:send, {type, msg} = frame}, node) do
    IO.puts("Sending #{type} frame with payload: #{msg}")
    {:reply, frame, node}
  end
end
