defmodule PPMarkdown.ClassIdentifiantsCssTest do

  use ExUnit.Case

  alias TestHelper, as: T

  @options %{compact_output: true}

  test "la tournure 'class.Paragraphe' ou 'id#Paragraphe permet de créer un paragraphe avec class et id" do
    assert T.file_match?(
      "classe_css_de_paragraphe.mmd",
      "73DE04981159F643858A5F28575684C5BF1FDE28ADB8890C88C48C6C3AE0253B",
      @options
    )
  end

end