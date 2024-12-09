ExUnit.start()

defmodule TestHelper do

  alias PPMarkdown.Engine

  @doc """
  Test principal pour voir si le contenu rendu par un fichier est le bon.

  @syntax

      test "mon test" do
        assert T.file_match?("<mon/fichier>", "<checksum>", @options)
      end

  La première fois, mettre "<checksum>" à nil pour obtenir le texte et le checksum
  produit. Si le texte correspond au résultat attendu, remplacer nil par le 
  checksum fourni.
  """
  def file_match?(filename, checksum, options) do
    case checksum do
    nil ->
      IO.puts """
      ************************************************************************
      Fichier : #{filename}
      Contenu évalué :
      --------------------------------------
      #{get_output_of(filename, options)}
      --------------------------------------
      Si ce texte est correct, mettre dans le test le checksum :
      #{get_checksum_of(filename, options)}
      ************************************************************************
      """
      false
    _ ->
      actual = get_checksum_of(filename, options)
      case checksum == actual do
      true -> true
      false ->
        IO.puts """
        ************************************************************************
        Fichier : #{filename}
        Le checksum ne correspond pas (le code produit par le fichier ne 
        correspond pas à ce qui est attendu)
        --------------------------------------
        #{get_output_of(filename, options)}
        --------------------------------------
        Si ce texte est le bon, il faut modifier le checksum :
        #{actual}
        ************************************************************************
        """
        false
      end
    end
  end

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

  def checksum(string) do
    :crypto.hash(:sha256, string) |> Base.encode16
  end

  def get_checksum_of(name, options) do
    get_output_of(name, options)
    |> checksum
  end

end

