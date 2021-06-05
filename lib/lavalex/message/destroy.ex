defmodule Lavalex.Message.Destroy do
  @enforce_keys [:guild_id]
  defstruct [
    :guild_id,
    op: "destroy"
  ]
end
