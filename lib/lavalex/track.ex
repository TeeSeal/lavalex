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

  @type track :: String.t()
  @type t :: %__MODULE__{
          track: track,
          identifier: String.t(),
          is_seekable: boolean,
          author: String.t(),
          length: integer,
          is_stream: boolean,
          position: integer,
          title: String.t(),
          uri: String.t()
        }

  @spec parse(map) :: Lavalex.Track.t()
  def parse(%{"track" => track, "info" => info}), do: parse(track, info)

  @spec parse(track, map) :: Lavalex.Track.t()
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

  @spec load(String.t()) :: Lavalex.LoadResponse.t()
  def load(identifier) do
    Lavalex.HTTP.get!("/loadtracks", [], params: [identifier: identifier])
    |> Map.get(:body)
    |> Lavalex.LoadResponse.parse()
  end

  @spec decode([track]) :: [Lavalex.Track.t()]
  def decode(track) when is_list(track) do
    Lavalex.HTTP.post!("/decodetracks", track)
    |> Map.get(:body)
    |> Enum.map(&Track.parse/1)
  end

  @spec decode(track) :: Lavalex.Track.t()
  def decode(track) do
    info =
      Lavalex.HTTP.get!("/decodetrack", [], params: [track: track])
      |> Map.get(:body)

    Track.parse(track, info)
  end
end
