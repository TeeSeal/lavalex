defmodule Lavalex.Track do
  alias Lavalex.Track

  defstruct [
    :track,
    :identifier,
    :is_seekable,
    :author,
    :length,
    :is_stream,
    :position,
    :title,
    :uri
  ]

  def parse(%{"track" => track, "info" => info}), do: parse(track, info)

  def parse(track, info) do
    %Track{
      track: track,
      identifier: info["identifier"],
      is_seekable: info["isSeekable"],
      author: info["author"],
      length: info["length"],
      is_stream: info["isStream"],
      position: info["position"],
      title: info["title"],
      uri: info["uri"]
    }
  end

  def load(identifier) do
    Lavalex.HTTP.get!("/loadtracks", [], params: [identifier: identifier])
    |> Map.get(:body)
    |> Lavalex.LoadResponse.parse()
  end

  def decode(track) when is_list(track) do
    Lavalex.HTTP.post!("/decodetracks", track)
    |> Map.get(:body)
    |> Enum.map(&Track.parse/1)
  end

  def decode(track) do
    info =
      Lavalex.HTTP.get!("/decodetrack", [], params: [track: track])
      |> Map.get(:body)

    Track.parse(track, info)
  end
end
