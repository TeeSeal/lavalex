defmodule Lavalex.Message.VoiceUpdate do
  use Lavalex.Message

  @enforce_keys [:guild_id, :session_id, :event]
  defstruct [
    :guild_id,
    :session_id,
    :event,
    op: "voiceUpdate"
  ]
end
