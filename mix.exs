defmodule Rulex.Mixfile do
  use Mix.Project

  def project do
    [app: :rulex,
     version: "0.0.1",
     elixir: "~> 1.0.0",
     description: description,
     package: package,
     deps: []]
  end

  def application do
    [applications: []]
  end

  defp package do
    [ contributors: ["Arnaud Wetzel"],
      licenses: ["The MIT License (MIT)"],
      links: %{ "GitHub"=>"https://github.com/awetzel/rulex" } ]
  end

  defp description do
    """
    Rulex contains a very simple macro "defrule" allowing you to write a rule
    system using Elixir pattern matching.
    """
  end
end
