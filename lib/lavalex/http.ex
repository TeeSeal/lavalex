defmodule Lavalex.HTTP do
  use HTTPoison.Base

  def process_response_body(body) do
    Poison.decode!(body)
  end

  def process_request_headers(_headers) do
    ["Authorization": Application.get_env(:lavalex, :password)]
  end

  def process_request_url(path) do
    base_url() <> path
  end

  def base_url do
    %URI{
      scheme: "http",
      host: Application.get_env(:lavalex, :host),
    }
    |> URI.to_string()
  end
end
