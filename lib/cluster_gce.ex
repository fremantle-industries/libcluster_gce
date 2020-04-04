defmodule ClusterGCE do
  alias ClusterGCE.{AccessToken, Instances, Zones}
  alias Cluster.Strategy.State

  def get_nodes(%State{config: config}) do
    project = Keyword.fetch!(config, :project)
    labels = Keyword.fetch!(config, :labels)
    {:ok, token} = AccessToken.get()
    headers = [{'Authorization', 'Bearer #{token}'}]

    with {:ok, zone_names} <- Zones.get(project, headers),
         {:ok, instances} <- Instances.get(project, headers, zone_names) do
      nodes =
        instances
        |> filter_running(labels)
        |> format_nodes(project)
        |> filter_current_node()

      {:ok, nodes}
    end
  end

  @running "RUNNING"
  defp filter_running(instances, labels) do
    instances
    |> Enum.filter(fn i ->
      status = Map.get(i, "status")
      label_keys = Map.keys(labels)

      instance_labels =
        i
        |> Map.get("labels", %{})
        |> Map.take(label_keys)

      status == @running && instance_labels == labels
    end)
  end

  defp format_nodes(instances, project) do
    instances
    |> Enum.map(fn %{"name" => instance_name, "zone" => zone} ->
      zone_uri = URI.parse(zone)
      zone_name = Path.basename(zone_uri.path)
      release_name = instance_name |> String.downcase() |> String.replace("-", "_")

      :"#{release_name}@#{instance_name}.#{zone_name}.c.#{project}.internal"
    end)
  end

  defp filter_current_node(nodes) do
    nodes
    |> Enum.filter(&(&1 != node()))
  end
end
