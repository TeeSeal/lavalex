defmodule Lavalex.HTTP do
  use HTTPoison.Base

  def process_request_url(path), do: base_url() <> path

  def process_request_headers(headers) do
    headers ++
      [
        Authorization: Application.get_env(:lavalex, :password),
        "Content-Type": "application/json"
      ]
  end

  def process_request_body(body) when is_list(body) or is_map(body) do
    Poison.encode!(body)
  end

  def process_request_body(body), do: body

  def process_response_body(body) do
    Poison.decode!(body)
  end

  def base_url do
    %URI{
      scheme: "http",
      host: Application.get_env(:lavalex, :host)
    }
    |> URI.to_string()
  end
end
