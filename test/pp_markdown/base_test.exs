# J'essaie de tester ici pp_markdown puisque je n'y arrive pas dans l'extension elle-même
defmodule PPMarkdown.EngineBaseTest do

  use ExUnit.Case

  alias TestHelper, as: T

  @options %{compact_output: true}

  test "un simple paragraphe" do
    assert T.file_match?("simple_paragraphe.mmd",
      "D8607393EE65B236F2D7BA28C24BAE1257B480FE25787E72AF4FBFFBBAB4375A",
      @options)
  end

  test "paragraphe avec variable (var(...) et v(...))" do
    Application.put_env(:pp_markdown, :table_vars, %{nom: "Phil"})
    assert T.file_match?("paragraphe_avec_variable.mmd",
      "59807087F204EAB95BBF4754828E9D307F7775BC0AE56AD945B66650F41F58B3",
      @options)

    # Doit produire :
    # <p>Bonjour Phil !</p><p>Tu vas bien, Phil ?</p>
  end

  test "paragraphe avec path (path(...) et p(...))" do
    assert T.file_match?("paragraphe_avec_path.mmd",
      "16CF672140FB70AA804E4FE064C2B91D47B20FDF9DCA09220B1B47DADC0612AE",
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

end
