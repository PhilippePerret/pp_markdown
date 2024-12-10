defmodule PPMarkdown.Mixfile do
  use Mix.Project

  @version "0.1.3"
  @github "https://github.com/PhilippePerret/pp_markdown"

  def project do
    [
      app: :pp_markdown,
      version: @version,
      elixir: "~> 1.14",
      deps: deps(),
      package: [
        contributors: ["Philippe Perret"],
        maintainers: ["Philippe Perret"],
        licenses: ["MIT"],
        links: %{
          "GitHub" => @github,
        }
      ],

      name: "pp_markdown",
      source_url: @github,
      docs: docs(),
      description: """
      Markdown Template Engine for Phoenix. Uses Earmark to render.
      Inspired by phoenix_markdown
      """
    ]
  end

  def application do
    [
      # applications: [:phoenix],
      extra_applications: [:earmark]
    ]
  end

  defp deps do
    [
      {:phoenix, ">= 1.1.0"},
      {:phoenix_html, ">= 2.3.0"},
      {:earmark, "~> 1.4"},
      {:html_entities, "~> 0.4"},
      {:makeup, "1.2.1"},
      {:makeup_elixir, "0.14.0"},

      # Docs dependencies
      {:ex_doc, ">= 0.0.0", only: [:dev, :docs]},
      {:inch_ex, ">= 0.0.0", only: :docs},
      {:credo, "~> 0.8.10", only: [:dev, :test], runtime: false}
    ]
  end

  defp docs do
    [
      extras: ["README.md"],
      source_ref: "v#{@version}",
      main: "PPMarkdown"
    ]
  end

end
