defmodule Lavalex.Message.Volume do
  @enforce_keys [:guild_id, :volume]
  defstruct [
    :guild_id,
    :volume,
    op: "volume"
  ]
end
