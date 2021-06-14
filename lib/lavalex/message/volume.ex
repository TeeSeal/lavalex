defmodule Lavalex.Message.Volume do
  use Lavalex.Message

  @enforce_keys [:guild_id, :volume]
  defstruct [
    :guild_id,
    :volume,
    op: "volume"
  ]
end
