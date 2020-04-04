defmodule ClusterGCE.Zones do
  def get(project, headers) do
    api_url = 'https://compute.googleapis.com/compute/v1/projects/#{project}/zones'

    :get
    |> :httpc.request({api_url, headers}, [], [])
    |> case do
      {:ok, {{_, 200, _}, _headers, body}} ->
        zone_names =
          body
          |> Jason.decode!()
          |> Map.get("items", [])
          |> Enum.map(fn %{"name" => name} -> name end)

        {:ok, zone_names}

      error ->
        error
    end
  end
end
