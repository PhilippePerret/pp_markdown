# J'essaie de tester ici pp_markdown puisque je n'y arrive pas dans l'extension elle-même
defmodule PPMarkdown.EvaluatedTest do

  use ExUnit.Case

  alias TestHelper, as: T

  @options %{compact_output: true}

  test "le code elixir entre <%= ... %> doit être évalué" do
    actual = T.get_output_of("texte_avec_elixir.mmd")
    assert actual == T.expected("""
    <p>2 + 2 est égal à 4</p>
    <p>Le nom de ce fichier est 'texte_avec_elixir.mmd'.</p>
    """)
  end
  
end
