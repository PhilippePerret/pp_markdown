ExUnit.start()

defmodule TestHelper do

  alias PPMarkdown.Engine

  @doc """
  Retourne le code une fois traité par l'engin, avec les options +options+
  """
  def get_output_of(filename, options) do
    if options do
      Application.put_env(:pp_markdown, :options, options)
    end
    {:__block__, _, liste} = Engine.compile("test/fixtures/textes/#{filename}", filename)
    Keyword.get(liste, :safe)
  end


  def get_output_of(filename) do
    get_output_of(filename, nil)
  end

  @doc """
  Retourne [<texte>], le texte retourné par la méthode PPMarkdown.Engine.compile/2
  qui est, par défaut, un texte sans retour chariot et une liste.
  Cela permet, dans les tests, de faire par exemple :

    assert actual = T.expected(" " "
    <p>Un premier paragraphe</p>
    <p>Un deuxième paragraphe</p>
    " " ")
  et de retourner : 
    ["<p>Un premier paragraphe</p><p>Un deuxième paragraphe</p>"]
  """
  def expected(string) do
    string = string
    |> String.replace("\n", "")
    [string]
  end

end

