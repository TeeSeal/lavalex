defmodule Lavalex.Message.Pause do
  use Lavalex.Message

  @enforce_keys [:guild_id]
  defstruct [
    :guild_id,
    pause: true,
    op: "pause"
  ]
end
