defmodule Lavalex.LoadResponse do
  defstruct [:type, :playlist_info, :tracks, :exception]

  def parse(map) do
    %Lavalex.LoadResponse{
      type: map["loadType"],
      playlist_info: map["playlistInfo"] |> parse_playlist_info(),
      tracks: map["tracks"] |> Enum.map(&Lavalex.Track.parse/1),
      exception: map["exception"] |> parse_exception()
    }
  end

  defp parse_playlist_info(%{"name" => name, "selectedTrack" => selected_track}) do
    %{ name: name, selected_track: selected_track }
  end

  defp parse_playlist_info(other), do: other

  defp parse_exception(%{ "message" => message, "severity" => severity}) do
    %{ message: message, severity: severity }
  end

  defp parse_exception(other), do: other
end
