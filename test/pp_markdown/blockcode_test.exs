# J'essaie de tester ici pp_markdown puisque je n'y arrive pas dans l'extension elle-même
defmodule PPMarkdown.BlocCodesTest do

  use ExUnit.Case

  alias TestHelper, as: T

  @options %{compact_output: true}

  test "blocs de code" do
    actual = T.get_output_of("simple_bloc_de_code.mmd", @options)
    assert ["<pre><code>Un simple code</code></pre>"] == actual
    
  end

  # test "avec du texte à évaluer (entre <%% ... %%>)" do
  #   filename = "blockcode_avec_heex.mmd"

  # end



end
