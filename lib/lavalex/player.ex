defmodule Lavalex.Player do
  use GenServer

  alias Lavalex.{Message, Node, Track}

  def start_link(node, guild_id, opts \\ []) do
    GenServer.start_link(__MODULE__, %{node: node, guild_id: guild_id}, opts)
  end

  @impl true
  def init(%{node: node, guild_id: guild_id}) do
    state = %{
      node: node,
      guild_id: guild_id,
      session_id: nil,
      voice_server: nil
    }

    {:ok, state}
  end

  def set_session_id(player, session_id) do
    GenServer.cast(player, {:set_session_id, session_id})
  end

  def set_voice_server(player, voice_server) do
    GenServer.cast(player, {:set_voice_server, voice_server})
  end

  def play(player, %Track{track: track}) do
    GenServer.cast(player, {:play, track})
  end

  def play(player, track) do
    GenServer.cast(player, {:play, track})
  end

  def stop(player) do
    GenServer.cast(player, :stop)
  end

  def destroy(player) do
    GenServer.cast(player, :destroy)
  end

  @impl true
  def handle_cast({:set_session_id, session_id}, state) do
    state = %{state | session_id: session_id}
    send_voice_update(state)
    {:noreply, state}
  end

  @impl true
  def handle_cast({:set_voice_server, voice_server}, state) do
    state = %{state | voice_server: voice_server}
    send_voice_update(state)
    {:noreply, state}
  end

  @impl true
  def handle_cast({:play, track}, %{node: node, guild_id: guild_id} = state) do
    message = Message.Play.build(guild_id: guild_id, track: track)
    Node.send(node, message)
    {:noreply, state}
  end

  @impl true
  def handle_cast(:stop, %{node: node, guild_id: guild_id} = state) do
    message = Message.Stop.build(guild_id: guild_id)
    Node.send(node, message)
    {:noreply, state}
  end

  @impl true
  def handle_cast(:destroy, %{node: node, guild_id: guild_id} = state) do
    message = Message.Destroy.build(guild_id: guild_id)
    Node.send(node, message)
    Node.remove_player(node, guild_id)
    {:stop, :normal, state}
  end

  defp send_voice_update(%{session_id: session_id, voice_server: voice_server})
       when is_nil(session_id) or is_nil(voice_server) do
    :noop
  end

  defp send_voice_update(%{
         node: node,
         guild_id: guild_id,
         session_id: session_id,
         voice_server: voice_server
       }) do
    message =
      Message.VoiceUpdate.build(
        guild_id: guild_id,
        session_id: session_id,
        event: voice_server
      )

    Node.send(node, message)
    :ok
  end
end
