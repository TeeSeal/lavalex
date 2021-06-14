defmodule Lavalex.Message.Equalizer do
  use Lavalex.Message

  @enforce_keys [:guild_id, :bands]
  defstruct [
    :guild_id,
    :bands,
    op: "equalizer"
  ]

  def serialize(%Lavalex.Message.Equalizer{} = message) do
    bands =
      message.bands
      |> Enum.map(&super/1)

    %{message | bands: bands} |> super()
  end
end
