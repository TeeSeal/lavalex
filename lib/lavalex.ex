defmodule Lavalex do
  use Supervisor

  @spec start_link(list | {module, list}) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(node_opts) when is_list(node_opts) do
    Supervisor.start_link(__MODULE__, {Lavalex.DefaultNode, node_opts}, name: LavalexSupervisor)
  end

  def start_link(node_child_spec) do
    Supervisor.start_link(__MODULE__, node_child_spec, name: LavalexSupervisor)
  end

  @impl true
  def init(node_child_spec) do
    children = [
      {Lavalex.Node, node_child_spec},
      {DynamicSupervisor, strategy: :one_for_one, name: Lavalex.PlayerSupervisor}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
