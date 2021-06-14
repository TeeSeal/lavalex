defmodule Lavalex.Message.Play do
  use Lavalex.Message

  @enforce_keys [:guild_id, :track]
  defstruct [
    :guild_id,
    :track,
    :start_time,
    :end_time,
    :volume,
    :no_replace,
    :pause,
    op: "play"
  ]
end
