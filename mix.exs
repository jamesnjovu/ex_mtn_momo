defmodule ExMtnMomo.MixProject do
  use Mix.Project

  @version "0.1.2"
  @source_url "https://github.com/jamesnjovu/ex_mtn_momo"
  @description "Elixir library for MTN Mobile Money API integration"

  def project do
    [
      app: :ex_mtn_momo,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Hex package information
      package: package(),
      description: @description,
      source_url: @source_url,

      # Docs
      name: "ExMtnMomo",
      docs: docs(),
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ExMtnMomo.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:uuid, "~> 1.1"},
      {:httpoison, "~> 1.6"},
      {:jason, "~> 1.2"},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["James Njovu"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Docs" => "https://hexdocs.pm/ex_mtn_momo"
      },
      description: @description,
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE)
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: @source_url,
      extras: ["README.md", "LICENSE"],
      authors: ["James Njovu"],
      formatters: ["html"],
      source_ref: "v#{@version}",
      groups_for_modules: [
        "Main Modules": [
          ExMtnMomo
        ],
        "Sandbox Modules": [
          ExMtnMomo.Sandbox
        ],
        "Collection Modules": [
          ExMtnMomo.Collection
        ],
        "Disbursements Modules": [
          ExMtnMomo.Disbursements
        ]
      ]
    ]
  end
end
