defmodule Lavalex.DefaultNode do
  require Logger

  @behaviour Lavalex.Node

  @impl Lavalex.Node
  def handle_player_update(data, _state) do
    Logger.info("[Lavalex] Player Update: " <> inspect(data))
  end

  @impl Lavalex.Node
  def handle_stats(data, _state) do
    Logger.info("[Lavalex] Stats: " <> inspect(data))
  end

  @impl Lavalex.Node
  def handle_event(_event, data, _state) do
    Logger.info("[Lavalex] Event: " <> inspect(data))
  end
end
