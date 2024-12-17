# J'essaie de tester ici pp_markdown puisque je n'y arrive pas dans l'extension elle-même
defmodule PPMarkdown.EngineBaseTest do

  use ExUnit.Case

  alias TestHelper, as: T

  @options %{compact_output: true, protect_spec_signs: true}

  test "un simple paragraphe" do
    assert T.file_match?("simple_paragraphe.mmd",
      "D8607393EE65B236F2D7BA28C24BAE1257B480FE25787E72AF4FBFFBBAB4375A",
      @options)
  end

  test "paragraphe avec variable (var(...) et v(...))" do
    Application.put_env(:pp_markdown, :table_vars, %{nom: "Phil"})
    assert T.file_match?("paragraphe_avec_variable.mmd",
      "EEFA38841BA8F56B974CE749D2F7436397A665FC2610146D3201FFE3BF3F0EE2",
      @options)

    # Doit produire :
    # <p>Bonjour Phil !</p><p>Tu vas bien, Phil ?</p>
  end

  test "paragraphe avec path (path(...) et p(...))" do
    assert T.file_match?("paragraphe_avec_path.mmd",
      "A78DA4FB0E041773AB0454691B27A352D7A2239B74C342ACA5A137E4B937815E",
      @options)

    # Doit produire (sans retours chariot) :
    # <p>Le fichier <path>vers/mon/file</path></p>
    # <p>Le dossier <path>vers/mon/dossier</path></p>
  end

  describe "avec les retours chariot" do
    test "retour le texte simple avec des retours" do
      actual = T.get_output_of("simple_paragraphe.mmd", %{@options | compact_output: false})
      assert ["<p>Un simple paragraphe.</p>"] == actual
    end
  end


  test "on peut protéger certains signes" do 
    actual = T.get_output_of("protected_signs.mmd", %{@options | protect_spec_signs: true})
    assert actual == [T.expected("""
    <p>Le signe &lt; et le signe &gt; avec un <i>mot en italique</i>.</p>
    <p>Le signe <code class=\"makeup inline\">&lt;</code> et le signe <code class=\"makeup inline\">&gt;</code>.</p>
    """)]
  end
  test "ou ne pas les protéger" do
    actual = T.get_output_of("protected_signs.mmd", %{@options | protect_spec_signs: false})
    assert ["<p>Un <paragraphe></p>"] == actual
  end

end
