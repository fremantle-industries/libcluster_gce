defmodule ClusterGCE.MixProject do
  use Mix.Project

  def project do
    [
      app: :libcluster_gce,
      description: "",
      version: "0.0.1",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      source_url: source_url(),
      project_url: source_url(),
      package: package()
    ]
  end

  defp description do
    """
    Clustering strategy for connecting nodes running on Google App Engine.
    """
  end

  defp source_url do
    "https://github.com/alexgaribay/libcluster_gae"
  end

  defp package do
    [
      files: ["lib", "mix.exs", "LICENSE", "README.md"],
      maintainers: ["Alex Kwiatkowski"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/fremantle-industries/libcluster_gce"}
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:libcluster, "~> 3.0"},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
