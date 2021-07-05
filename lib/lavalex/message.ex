defmodule Lavalex.Message do
  defmacro __using__(_opts) do
    quote do
      def serialize(data) do
        Lavalex.Message.serialize(data)
      end

      def build(params) do
        struct!(__MODULE__, params) |> serialize()
      end

      defoverridable(serialize: 1)
    end
  end

  @spec serialize(map | struct) :: map
  def serialize(struct) when is_struct(struct) do
    Map.from_struct(struct) |> serialize()
  end

  def serialize(%{guild_id: guild_id} = map) when is_integer(guild_id) do
    map
    |> Map.put(:guild_id, Integer.to_string(guild_id))
    |> serialize()
  end

  def serialize(data) do
    data |> Lavalex.Util.compact() |> Lavalex.Util.camelize()
  end
end
