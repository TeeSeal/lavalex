defmodule Lavalex.Util do
  def camelize(map) when is_map(map) do
    for tuple <- map, into: %{}, do: camelize(tuple)
  end

  def camelize(list) when is_list(list) do
    Enum.map(list, &camelize/1)
  end

  def camelize({key, value}) do
    {camelize(key), value}
  end

  def camelize(atom) when is_atom(atom) do
    Atom.to_string(atom)
    |> camelize()
    |> String.to_atom()
  end

  def camelize(string) do
    [head | tail] = String.split(string, "_")
    capitalized_tail = Enum.map(tail, &String.capitalize/1)
    Enum.join([head | capitalized_tail])
  end

  def compact(map) when is_map(map) do
    map |> reject_nil_values() |> Map.new()
  end

  def compact(data), do: reject_nil_values(data)

  def underscore_keys(nil), do: nil

  def underscore_keys(map = %{}) do
    for {key, value} <- map, into: %{} do
      {
        Macro.underscore(key) |> String.replace("-", "_"),
        underscore_keys(value)
      }
    end
  end

  def underscore_keys([head | rest]) do
    [underscore_keys(head) | underscore_keys(rest)]
  end

  def underscore_keys(not_a_map) do
    not_a_map
  end

  def atomize_keys(nil), do: nil

  def atomize_keys(map) when is_map(map) do
    for {key, value} <- map, into: %{}, do: {String.to_atom(key), atomize_keys(value)}
  end

  def atomize_keys([head | rest]) do
    [atomize_keys(head) | atomize_keys(rest)]
  end

  def atomize_keys(not_a_map) do
    not_a_map
  end

  defp reject_nil_values(enum) do
    Enum.reject(enum, fn {_, v} -> is_nil(v) end)
  end
end
