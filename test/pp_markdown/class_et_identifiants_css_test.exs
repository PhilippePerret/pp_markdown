defmodule PPMarkdown.ClassIdentifiantsCssTest do

  use ExUnit.Case

  alias TestHelper, as: T

  @options %{compact_output: true}

  test "la tournure '<class>.<paragraphe>' permet de créer un paragraphe avec class" do
    assert T.file_match?(
      "classe_css_de_paragraphe.mmd",
      nil,
      @options
    )
  end

end