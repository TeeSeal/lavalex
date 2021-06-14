defmodule Lavalex.Message.Seek do
  use Lavalex.Message

  @enforce_keys [:guild_id, :position]
  defstruct [
    :guild_id,
    :position,
    op: "seek"
  ]
end
