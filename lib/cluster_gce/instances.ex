defmodule ClusterGCE.Instances do
  def get(project, headers, zone_names) do
    zone_names
    |> Enum.map(fn z ->
      api_url =
        'https://compute.googleapis.com/compute/v1/projects/#{project}/zones/#{z}/instances'

      :get
      |> :httpc.request({api_url, headers}, [], [])
      |> case do
        {:ok, {{_, 200, _}, _headers, body}} ->
          instances =
            body
            |> Jason.decode!()
            |> Map.get("items", [])

          {:ok, instances}

        error ->
          error
      end
    end)
    |> Enum.filter(fn
      {:ok, _} -> true
      _ -> false
    end)
    |> Enum.reduce(
      {:ok, []},
      fn {:ok, i}, {:ok, instances} ->
        {:ok, instances ++ i}
      end
    )
  end
end
