defmodule Rulex.Mixfile do
  use Mix.Project

  def project do
    [app: :rulex,
     version: "0.2.0",
     elixir: ">= 1.0.0",
     docs: [
       main: "Rulex",
       source_url: "https://github.com/awetzel/rulex",
       source_ref: "master"
     ],
     description: description,
     package: package,
     deps: [{:ex_doc, only: :dev}] ]
  end

  def application do
    [applications: []]
  end

  defp package do
    [ contributors: ["Arnaud Wetzel"],
      licenses: ["The MIT License (MIT)"],
      links: %{ "Source"=>"https://github.com/awetzel/rulex", "Doc"=>"http://hexdocs.pm/rulex"} ]
  end

  defp description do
    """
    Rulex contains a very simple macro "defrule" allowing you to write a rule
    system using Elixir pattern matching.
    """
  end
end
