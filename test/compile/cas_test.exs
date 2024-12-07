# J'essaie de tester ici pp_markdown puisque je n'y arrive pas dans l'extension elle-même
defmodule PPMarkdown.EngineTest do

  use ExUnit.Case

  alias PPMarkdown.Engine

  test "un simple paragraphe" do

    Application.put_all_env(pp_markdown: [server_tags: false])

    actual = 
      "test/fixtures/textes/simple_paragraphe.mmd"
      |> Engine.compile("simple_paragraphe.mmd")

    assert "simple" == actual
    
  end

end
