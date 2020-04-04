defmodule ClusterGCE.Strategy.Labels do
  @moduledoc """
  Clustering strategy for Google Compute Engine.

  This strategy checks for the list of app versions that are currently receiving HTTP.
  For each version that is listed, the list of instances running for that version are fetched.
  Once all of the instances have been received, they attempt to connect to each other.

  **Note**: This strategy only connects nodes that are able to receive GCP internal DNS traffic

  To cluster an application running in Google Compute Engine, define a topology for `libcluster`.

  ```elixir
  config :libcluster,
    topologies: [
      my_app: [
        strategy: ClusterGCE.Strategy.Labels,
        config: [
          polling_interval: 10_000,
          project_id: "my-project",
          label: "my-app:environment-name"
        ]
      ]
    ]
  ```

  ## Configurable Options

  Options can be set for the strategy under the `:config` key when defining the topology.

  * `:polling_interval` - Interval for checking for the list of running instances. Defaults to `10_000`
  * `:project_id`       - Google Cloud project name
  * `:label`            - A key value map of instance labels to match

  ### Release Configuration

  Update your release's `vm.args` file to include the following lines.

  ```
  ## Name of the node
  -name <%= release_name%>@${GOOGLE_COMPUTE_ENGINE_INSTANCE}.${GOOGLE_COMPUTE_ENGINE_ZONE}.c.${GOOGLE_CLOUD_PROJECT}.internal

  ## Limit distributed erlang ports to a single port
  -kernel inet_dist_listen_min 9999
  -kernel inet_dist_listen_max 9999
  ```

  Run your application with the environment variable `REPLACE_OS_VARS=true` and forward the following tcp ports:

  - `4369 # epmd`
  - `9999 # erlang distribution`
  ```
  """

  use GenServer
  use Cluster.Strategy

  alias Cluster.Strategy.State

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  @impl true
  def init([%State{} = state]) do
    {:ok, load(state)}
  end

  @impl true
  def handle_info(:timeout, state) do
    handle_info(:load, state)
  end

  def handle_info(:load, %State{} = state) do
    {:noreply, load(state)}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  defp load(%State{} = state) do
    connect = state.connect
    list_nodes = state.list_nodes
    topology = state.topology
    {:ok, nodes} = ClusterGCE.get_nodes(state)

    Cluster.Strategy.connect_nodes(topology, connect, list_nodes, nodes)

    Process.send_after(self(), :load, polling_interval(state))

    state
  end

  @default_polling_interval 10_000
  defp polling_interval(%State{config: config}) do
    Keyword.get(config, :polling_interval, @default_polling_interval)
  end
end
