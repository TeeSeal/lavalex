defmodule Lavalex.Message.Stop do
  @enforce_keys [:guild_id]
  defstruct [
    :guild_id,
    op: "stop"
  ]
end
