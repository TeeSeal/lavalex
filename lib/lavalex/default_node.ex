defmodule Lavalex.DefaultNode do
  require Logger

  @behaviour Lavalex.Node

  @impl Lavalex.Node
  @spec handle_player_update(map, Lavalex.Node.state) :: :ok
  def handle_player_update(data, _state) do
    Logger.info("[Lavalex] Player Update: " <> inspect(data))
  end

  @impl Lavalex.Node
  @spec handle_stats(map, Lavalex.Node.state) :: :ok
  def handle_stats(data, _state) do
    Logger.info("[Lavalex] Stats: " <> inspect(data))
  end

  @impl Lavalex.Node
  @spec handle_event(atom, map, Lavalex.Node.state) :: :ok
  def handle_event(_event, data, _state) do
    Logger.info("[Lavalex] Event: " <> inspect(data))
  end
end
