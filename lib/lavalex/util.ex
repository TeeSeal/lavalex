defmodule Lavalex.Util do
  def camelize(map) when is_map(map) do
    for tuple <- map, into: %{}, do: camelize(tuple)
  end

  def camelize(list) when is_list(list) do
    Enum.map(list, &camelize/1)
  end

  def camelize({key, value}) when is_list(value) or is_map(value) do
    {camelize(key), camelize(value)}
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
end
