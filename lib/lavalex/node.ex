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
      user_id: Application.get_env(:lavalex, :user_id),
      players: %{}
    }

    {:ok, state}
  end

  def send(node, data) do
    GenServer.cast(node, {:send, data})
  end

  def message(node, message) do
    GenServer.cast(node, {:message, message})
  end

  def get_player(node, guild_id) do
    GenServer.call(node, {:get_player, guild_id})
  end

  def get_all_players(node) do
    GenServer.call(node, :get_all_players)
  end

  def remove_player(node, guild_id) do
    GenServer.cast(node, {:remove_player, guild_id})
  end

  def voice_state_update(node, data) do
    GenServer.cast(node, {:voice_state_update, data})
  end

  def voice_server_update(node, data) do
    GenServer.cast(node, {:voice_server_update, data})
  end

  def handle_call({:get_player, guild_id}, _from, state) do
    {player, state} = get_or_start_player(guild_id, state)
    {:reply, player, state}
  end

  def handle_call(:get_all_players, _from, %{players: players} = state) do
    {:reply, players, state}
  end

  def handle_cast({:remove_player, guild_id}, %{players: players} = state) do
    {:noreply, %{state | players: Map.delete(players, guild_id)}}
  end

  def handle_cast({:send, data}, %{websocket: websocket} = state) do
    WebSockex.send_frame(websocket, {:text, Poison.encode!(data)})
    {:noreply, state}
  end

  def handle_cast({:message, {_type, message}}, state) do
    message =
      Poison.decode!(message) |> Lavalex.Util.underscore_keys() |> Lavalex.Util.atomize_keys()

    case message do
      %{op: "stats"} = message ->
        handle_stats(message, state)

      %{op: "playerUpdate", guild_id: guild_id, state: data} = message ->
        {guild_id, _} = Integer.parse(guild_id)

        {player, state} = get_or_start_player(guild_id, state)
        Lavalex.Player.update(player, data)

        message = Map.put(message, :guild_id, guild_id)
        handle_player_update(message, state)

      %{op: "event"} = message ->
        handle_event(message, state)

      message ->
        Logger.info("[Lavalink] Unknown Message:" <> inspect(message))
    end

    {:noreply, state}
  end

  def handle_cast({:voice_server_update, %{guild_id: guild_id} = voice_server}, state) do
    {player, state} = get_or_start_player(guild_id, state)
    Lavalex.Player.set_voice_server(player, voice_server)
    {:noreply, state}
  end

  def handle_cast(
        {:voice_state_update, %{user: %{id: user_id}}},
        %{user_id: lavalex_user_id} = state
      )
      when user_id != lavalex_user_id do
    {:noreply, state}
  end

  def handle_cast(
        {:voice_state_update, %{guild_id: guild_id, channel_id: nil}},
        %{players: players} = state
      ) do
    if {:ok, player} = Map.fetch(players, guild_id), do: Lavalex.Player.destroy(player)
    {:noreply, state}
  end

  def handle_cast({:voice_state_update, %{guild_id: guild_id, session_id: session_id}}, state) do
    {player, state} = get_or_start_player(guild_id, state)
    Lavalex.Player.set_session_id(player, session_id)
    {:noreply, state}
  end

  def handle_player_update(_data, _state) do
    :noop
  end

  def handle_stats(_data, _state) do
    :noop
  end

  def handle_event(_data, _state) do
    :noop
  end

  defp get_or_start_player(guild_id, %{players: players} = state) do
    case Map.fetch(players, guild_id) do
      {:ok, player} ->
        {player, state}

      :error ->
        {:ok, player} = Lavalex.Player.start_link(self(), guild_id)
        players = Map.put(players, guild_id, player)
        {player, %{state | players: players}}
    end
  end
end
