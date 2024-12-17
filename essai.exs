defmodule Essai do
  @moduledoc """
  Pour utiliser ce module :

  iex -S mix run essai.exs
  iex> recompile();Essai.run  # ligne à rejouer autant de fois que voulu

  """

  def run do
    quelle_methode?(%{donnee: true, autre: "c'est une autre", table: %{map: true}})
  end

  def quelle_methode?(%{donnee: false} = _map) do
    IO.puts "Je passe dans celle avec donnee: false"
  end

  def quelle_methode?(%{donnee: true} = _map) do
    IO.puts "Je passe dans celle avec donnee: true"
  end
end

# Essai.run