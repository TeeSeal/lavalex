defmodule Lavalex.Message do
  def serialize(struct) when is_struct(struct) do
    Map.from_struct(struct) |> serialize()
  end

  def serialize(map) do
    Lavalex.Util.camelize(map)
  end
end
