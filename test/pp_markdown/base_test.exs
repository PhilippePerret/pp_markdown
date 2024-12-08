# J'essaie de tester ici pp_markdown puisque je n'y arrive pas dans l'extension elle-même
defmodule PPMarkdown.EngineTest do

  use ExUnit.Case

  alias TestHelper, as: T

  @options %{compact_output: true}

  test "un simple paragraphe" do
    actual = T.get_output_of("simple_paragraphe.mmd", @options)
    assert ["<p>Un simple paragraphe.</p>"] == actual
  end

  test "paragraphe avec variable (var(...) et v(...))" do
    Application.put_env(:pp_markdown, :table_vars, %{nom: "Phil"})
    actual = T.get_output_of("paragraphe_avec_variable.mmd", @options)
    assert ["<p>Bonjour Phil !</p><p>Tu vas bien, Phil ?</p>"] == actual
  end

  test "paragraphe avec path (path(...) et p(...))" do
    actual = T.get_output_of("paragraphe_avec_path.mmd", @options)
    assert actual == T.expected("""
    <p>Le fichier <path>vers/mon/file</path></p>
    <p>Le dossier <path>vers/mon/dossier</path></p>
    """)
  end

  describe "avec les retours chariot" do
    test "retour le texte simple avec des retours" do
      actual = T.get_output_of("simple_paragraphe.mmd", %{@options | compact_output: false})
      assert ["<p>\nUn simple paragraphe.</p>\n"] == actual
    end
  end

end
