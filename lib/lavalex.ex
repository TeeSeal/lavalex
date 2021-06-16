defmodule Lavalex do
  use Supervisor

  def start_link(node_opts) when is_list(node_opts) do
    Supervisor.start_link(__MODULE__, {Lavalex.Node, node_opts}, name: LavalexSupervisor)
  end

  def start_link(node_child_spec) do
    Supervisor.start_link(__MODULE__, node_child_spec, name: LavalexSupervisor)
  end

  @impl true
  def init(node_child_spec) do
    children = [
      node_child_spec,
      {DynamicSupervisor, strategy: :one_for_one, name: Lavalex.PlayerSupervisor}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
