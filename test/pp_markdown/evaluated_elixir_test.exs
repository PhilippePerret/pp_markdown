# J'essaie de tester ici pp_markdown puisque je n'y arrive pas dans l'extension elle-même
defmodule PPMarkdown.EvaluatedTest do

  use ExUnit.Case

  alias TestHelper, as: T

  @options %{compact_output: true}

  @tag :skip # je n'arrive pas encore à tester ça
  test "le code elixir entre <%= ... %> doit être évalué" do
    assert T.file_match?("texte_avec_elixir.mmd",
      nil,
      @options)
  end
  
end
