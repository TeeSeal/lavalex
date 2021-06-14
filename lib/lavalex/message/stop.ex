defmodule Lavalex.Message.Stop do
  use Lavalex.Message

  @enforce_keys [:guild_id]
  defstruct [
    :guild_id,
    op: "stop"
  ]
end
