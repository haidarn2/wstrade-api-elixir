defmodule WsTrade.MixProject do
  use Mix.Project

  def project do
    [
      app: :ws_trade,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {WsTrade.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, "~> 1.4.0"},
      {:hackney, "~> 1.17.0"},
      {:jason, ">= 1.0.0"},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp description do
    "An work-in-progress elixir wrapper of the WealthSimple Trade REST API."
  end

  defp package do
    [
      files: ~w(lib .formatter.exs mix.exs README* LICENSE),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/haidarn2/wstrade-api-elixir"}
    ]
  end
end
