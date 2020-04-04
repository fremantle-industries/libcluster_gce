# LibclusterGCE
[![Build Status](https://github.com/fremantle-industries/libcluster_gce/workflows/Test/badge.svg?branch=master)](https://github.com/fremantle-industries/libcluster_gce/actions?query=workflow%3ATest)
[![hex.pm version](https://img.shields.io/hexpm/v/libcluster_gce.svg?style=flat)](https://hex.pm/packages/libcluster_gce)

This is a Google Compute Engine (GCE) clustering strategy for [libcluster](https://hexdocs.pm/libcluster/readme.html). 
It currently supports identifying nodes based on compute engine labels.

## Installation

Add `:libcluster_gce` to your project's mix dependencies.

```elixir
def deps do
  [
    {:libcluster_gce, "~> 0.0.1"}
  ]
end
```

## Deployment Assumptions

Clustering will only apply to nodes that are accessible via the [GCP internal DNS](https://cloud.google.com/compute/docs/internal-dns).
If this doesn't fit your deployment strategy, please open a Github issue describing your deployment configuration.

## Configuration

To cluster an application running in Google Compute Engine, define a topology for `libcluster`.

```elixir
# config.exs
config :libcluster,
  topologies: [
    my_app: [
      strategy: ClusterGCE.Strategy.Labels,
      config: [
        project: "my-project",
        labels: %{
          "env" => "prod"
        }
      ]
    ]
  ]
```

Make sure a cluster supervisor is part of your application.

```elixir
defmodule MyApp.App do
  use Application

  def start(_type, _args) do
    topologies = Application.get_env(:libcluster, :topologies)

    children = [
      {Cluster.Supervisor, [topologies, [name: MyApp.ClusterSupervisor]]},
      # ...
    ]
    Supervisor.start_link(children, strategy: :one_for_one, name: MyApp.Supervisor)
  end
end
```

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

## Thanks

Shout out to [@alexgaribay](https://github.com/alexgaribay) for the hard work in [libcluster_gae](https://github.com/alexgaribay/libcluster_gae).

## Authors

* Alex Kwiatkowski - alex+git@fremantle.io

## License

`libcluster_gce` is released under the [MIT license](./LICENSE.md)
