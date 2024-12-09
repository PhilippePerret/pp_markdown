# J'essaie de tester ici pp_markdown puisque je n'y arrive pas dans l'extension elle-même
defmodule PPMarkdown.ExternalTest do

  use ExUnit.Case

  alias TestHelper, as: T

  @options %{compact_output: true, template_folder:  nil}

  test "peut charger un bloc de code externe (chemin relatif)" do
    assert T.file_match?(
      "load_same_level.mmd", 
      "5B710B984FA7430F7938D791EF07AA0F57CD37579EB126EC593686409D9FBEF9", 
      @options)
  end

  test "peut charger un bloc de texte du dossier priv/static/textes" do
    assert T.file_match?(
      "load_from_static_textes.mmd",
      "4794863B61B8C5448544740D117245495E64CEA42C0C9E8E7E143CA99D92C1CA",
      @options
    )
  end
  
  test "peut charger un bloc de texte externe du dossier défini en :template_folder" do
    assert T.file_match?(
      "load_from_template_folder.mmd", 
      "A477DAA452595BA396121C3483DED4950CB1E898B9EF099B0B66E9B9D9A70E2E",
      %{@options | template_folder: "test/fixtures/textes/template_folder"})
  end

  @tag :skip
  test "cherche le texte dans tout le dossier priv quand il ne le trouve pas" do
  end

  test "produit une erreur dans la page si le fichier est introuvable" do
    assert T.file_match?(
      "load_unfound_file.mmd", 
      "73DC8EAB44629CD0B929C143738B94C280BCF57B884C96074E76F2BB836807AE",
      @options)
  end

  @tag :skip
  test "peut charger deux blocs de code externes" do
  end

  @tag :skip
  test "évalue le code dans les blocs de texte externes" do
  end

  @tag :skip
  test "charge un texte externe (chemin relatif)" do
  end
  
  @tag :skip
  test "charge un texte externe (priv de l'application)" do
  end

end
