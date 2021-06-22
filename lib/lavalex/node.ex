defmodule Lavalex.Node do
  use GenServer

  require Logger

  @type node_state :: %{
          callback_module: module,
          websocket: pid,
          user_id: integer,
          players: map
        }

  @callback handle_player_update(map, node_state) :: any
  @callback handle_stats(map, node_state) :: any
  @callback handle_event(atom, map, node_state) :: any

  defmacro __using__(_opts) do
    quote do
      @behaviour Lavalex.Node

      @impl Lavalex.Node
      def handle_player_update(_data, _state) do
        :noop
      end

      @impl Lavalex.Node
      def handle_stats(_data, _state) do
        :noop
      end

      @impl Lavalex.Node
      def handle_event(_event, _data, _state) do
        :noop
      end

      defoverridable(handle_player_update: 2, handle_stats: 2, handle_event: 3)
    end
  end

  def start_link({callback_module, opts}) do
    GenServer.start_link(__MODULE__, callback_module, opts)
  end

  def init(callback_module) do
    {:ok, websocket} = Lavalex.Socket.start_link(self())

    state = %{
      callback_module: callback_module,
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

  def handle_cast(
        {:message, {_type, message}},
        %{players: players, callback_module: callback_module} = state
      ) do
    message = transform_message(message)

    case message do
      %{op: "stats"} = message ->
        apply(callback_module, :handle_stats, [message, state])

      %{op: "playerUpdate", guild_id: guild_id, state: data} = message ->
        case Map.fetch(players, guild_id) do
          {:ok, player} -> Lavalex.Player.update(player, data)
          :error -> :noop
        end

        message = Map.put(message, :guild_id, guild_id)
        apply(callback_module, :handle_player_update, [message, state])

      %{op: "event"} = message ->
        event = message.type |> Macro.underscore() |> String.to_atom()
        apply(callback_module, :handle_event, [event, message, state])

      message ->
        Logger.info("[Lavalex] Unknown Message: " <> inspect(message))
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
    case Map.fetch(players, guild_id) do
      {:ok, player} -> Lavalex.Player.destroy(player)
      :error -> :noop
    end

    {:noreply, state}
  end

  def handle_cast({:voice_state_update, %{guild_id: guild_id, session_id: session_id}}, state) do
    {player, state} = get_or_start_player(guild_id, state)
    Lavalex.Player.set_session_id(player, session_id)
    {:noreply, state}
  end

  defp get_or_start_player(guild_id, %{players: players} = state) do
    case Map.fetch(players, guild_id) do
      {:ok, player} ->
        {player, state}

      :error ->
        player = start_player(guild_id)
        players = Map.put(players, guild_id, player)
        {player, %{state | players: players}}
    end
  end

  defp start_player(guild_id) do
    {:ok, player} =
      DynamicSupervisor.start_child(
        Lavalex.PlayerSupervisor,
        {Lavalex.Player, node: self(), guild_id: guild_id}
      )

    player
  end

  defp transform_message(message) do
    message =
      Poison.decode!(message) |> Lavalex.Util.underscore_keys() |> Lavalex.Util.atomize_keys()

    case message do
      %{guild_id: guild_id} = message ->
        {guild_id, _} = Integer.parse(guild_id)
        %{message | guild_id: guild_id}

      message ->
        message
    end
  end
end
