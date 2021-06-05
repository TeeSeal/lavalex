defmodule Lavalex.Message.Equalizer do
  @enforce_keys [:guild_id, :bands]
  defstruct [
    :guild_id,
    :bands,
    op: "equalizer"
  ]
end
