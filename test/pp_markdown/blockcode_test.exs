# J'essaie de tester ici pp_markdown puisque je n'y arrive pas dans l'extension elle-même
defmodule PPMarkdown.BlockcodesTest do

  use ExUnit.Case

  alias TestHelper, as: T

  @options %{compact_output: true}

  test "blocs de code" do
    assert T.file_match?("simple_bloc_de_code.mmd", 
    "87540D2E07F8EC4DDB355B0D51173337CB865F8EDC0340603D2484489DF628D9", 
    @options)    
  end

  # test "avec du texte à évaluer (entre <%% ... %%>)" do
  #   filename = "blockcode_avec_heex.mmd"

  # end



end
