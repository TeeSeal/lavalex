defmodule Lavalex.Message.Seek do
  @enforce_keys [:guild_id, :position]
  defstruct [
    :guild_id,
    :position,
    op: "seek"
  ]
end
