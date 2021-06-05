defmodule Lavalex.Message do
  def serialize(%{guild_id: guild_id} = map) when is_integer(guild_id) do
    map
    |> Map.put(:guild_id, Integer.to_string(guild_id))
    |> serialize()
  end

  def serialize(struct) when is_struct(struct) do
    Map.from_struct(struct) |> serialize()
  end

  def serialize(map) do
    Lavalex.Util.camelize(map)
  end
end
