# J'essaie de tester ici pp_markdown puisque je n'y arrive pas dans l'extension elle-même
defmodule PPMarkdown.ExternalTest do

  use ExUnit.Case

  alias TestHelper, as: T

  @options %{compact_output: true}

  @tag :skip
  test "peut charger un bloc de code externe (chemin relatif)" do
  end

  @tag :skip
  test "peut charger un bloc de code externe (priv de l'application)" do
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
