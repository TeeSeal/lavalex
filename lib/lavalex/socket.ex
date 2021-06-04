defmodule Lavalex.Socket do
  use WebSockex

  def start_link(state) do
    headers = [
      "Authorization": Application.get_env(:lavalex, :password),
      "Num-Shards": Application.get_env(:lavalex, :num_shards),
      "User-Id": Application.get_env(:lavalex, :user_id)
    ]

    WebSockex.start_link(
      "ws://" <> Application.get_env(:lavalex, :host),
      __MODULE__,
      state,
      extra_headers: headers
    )
  end

  def handle_frame({type, msg}, state) do
    IO.puts "Received Message - Type: #{inspect type} -- Message: #{inspect msg}"
    {:ok, state}
  end

  def handle_cast({:send, {type, msg} = frame}, state) do
    IO.puts "Sending #{type} frame with payload: #{msg}"
    {:reply, frame, state}
  end
end
