defmodule Lavalex.Util do
  @spec camelize(map) :: map
  def camelize(map) when is_map(map) do
    for tuple <- map, into: %{}, do: camelize(tuple)
  end

  @spec camelize(list) :: list
  def camelize(list) when is_list(list) do
    Enum.map(list, &camelize/1)
  end

  @spec camelize(tuple) :: tuple
  def camelize({key, value}) do
    {camelize(key), value}
  end

  @spec camelize(atom) :: atom
  def camelize(atom) when is_atom(atom) do
    Atom.to_string(atom)
    |> camelize()
    |> String.to_atom()
  end

  @spec camelize(String.t) :: String.t
  def camelize(string) do
    [head | tail] = String.split(string, "_")
    capitalized_tail = Enum.map(tail, &String.capitalize/1)
    Enum.join([head | capitalized_tail])
  end

  @spec compact(any) :: map | list
  def compact(map) when is_map(map) do
    map |> reject_nil_values() |> Map.new()
  end

  def compact(data), do: reject_nil_values(data)

  @spec underscore_keys(nil) :: nil
  def underscore_keys(nil), do: nil

  @spec underscore_keys(map) :: map
  def underscore_keys(map = %{}) do
    for {key, value} <- map, into: %{} do
      {
        Macro.underscore(key) |> String.replace("-", "_"),
        underscore_keys(value)
      }
    end
  end

  @spec underscore_keys(list) :: list
  def underscore_keys([head | rest]) do
    [underscore_keys(head) | underscore_keys(rest)]
  end

  def underscore_keys(not_a_map) do
    not_a_map
  end

  @spec atomize_keys(nil) :: nil
  def atomize_keys(nil), do: nil

  @spec atomize_keys(map) :: map
  def atomize_keys(map) when is_map(map) do
    for {key, value} <- map, into: %{}, do: {String.to_atom(key), atomize_keys(value)}
  end

  @spec atomize_keys(list) :: list
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
