defmodule Lavalex.Message.Destroy do
  use Lavalex.Message

  @enforce_keys [:guild_id]
  defstruct [
    :guild_id,
    op: "destroy"
  ]
end
