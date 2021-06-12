defmodule Lavalex.Node do
  use GenServer

  require Logger

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    {:ok, websocket} = Lavalex.Socket.start_link(self())

    state = %{
      websocket: websocket,
      session_ids: :ets.new(:session_ids, []),
      voice_servers: :ets.new(:voice_servers, [])
    }

    {:ok, state}
  end

  def send(node, data) do
    GenServer.cast(node, {:send, data})
  end

  def message(node, message) do
    GenServer.cast(node, {:message, message})
  end

  def voice_state_update(node, data) do
    GenServer.cast(node, {:voice_state_update, data})
  end

  def voice_server_update(node, data) do
    GenServer.cast(node, {:voice_server_update, data})
  end

  def handle_cast({:send, data}, %{websocket: websocket} = state) do
    WebSockex.send_frame(websocket, {:text, Poison.encode!(data)})
    {:noreply, state}
  end

  def handle_cast({:message, {_type, message}}, state) do
    log = message |> Poison.decode!() |> Poison.encode!(pretty: true)
    Logger.info("[Lavalink]: " <> log)
    {:noreply, state}
  end

  def handle_cast({:voice_server_update, data}, %{voice_servers: voice_servers} = state) do
    :ets.insert(voice_servers, {data.guild_id, data})
    send_voice_update(data.guild_id, state)
    {:noreply, state}
  end

  def handle_cast(
        {:voice_state_update, data},
        %{session_ids: session_ids, voice_servers: voice_servers} = state
      ) do
    user_id = Application.get_env(:lavalex, :user_id)

    case data do
      %{user_id: ^user_id, channel_id: nil} ->
        :ets.delete(session_ids, data.guild_id)
        :ets.delete(voice_servers, data.guild_id)

      %{user_id: ^user_id} ->
        :ets.insert(session_ids, {data.guild_id, data.session_id})
        send_voice_update(data.guild_id, state)

      _ ->
        nil
    end

    {:noreply, state}
  end

  defp send_voice_update(guild_id, %{voice_servers: voice_servers, session_ids: session_ids}) do
    case {:ets.lookup(session_ids, guild_id), :ets.lookup(voice_servers, guild_id)} do
      {[{_, session_id}], [{_, voice_server}]} ->
        message =
          %Lavalex.Message.VoiceUpdate{
            guild_id: guild_id,
            session_id: session_id,
            event: voice_server
          }
          |> Lavalex.Message.serialize()

        __MODULE__.send(self(), message)

      _ ->
        nil
    end
  end
end
