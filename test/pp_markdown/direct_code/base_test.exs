defmodule PPMarkdown.CodeDirectBaseTest do

  use ExUnit.Case

  alias TestHelper, as: T


  test "un premier test simple" do
    T.compare(
      "Un paragraphe simple",
      "<p>Un paragraphe simple</p>"
      )
  end

end