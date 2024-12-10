# J'essaie de tester ici pp_markdown puisque je n'y arrive pas dans l'extension elle-même
defmodule PPMarkdown.EngineTest do

  use ExUnit.Case

  # alias PPMarkdown.Engine
  alias TestHelper, as: T


  @options %{compact_output: true}

  test "un simple paragraphe" do
    assert T.file_match?("simple_paragraphe.mmd", "D8607393EE65B236F2D7BA28C24BAE1257B480FE25787E72AF4FBFFBBAB4375A", @options)    
  end

end
