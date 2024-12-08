# Notes
# -----
#
# [N001]
#   Plutôt que de traiter les blocs de code (<pre><code> ... </code></pre>) qui
#   pourraient être traités par d'autres fonctions, peut-être serait-il plus 
#   judicieux de les retirer au début, de les replacer par des balises __BLOCCODE-XX__,
#   de traiter le code restant, puis de les remettre en remplaçant les balises
#   et en mettant dans un <pre><code> ... </code></pre>
#
#
defmodule PPMarkdown.Engine do
  @behaviour Phoenix.Template.Engine

  # @table_vars Application.compile_env(:pp_markdown, :table_vars, %{})

  # alias PPMarkdown.Highlighter, as: Lighter

  # TODO Le définir en configuration ?
  @load_external_file_options %{source: true}



  def compile(path, name) do

    # Plus tard, on pourra définir des options
    options = Application.get_env(:pp_markdown, :options, %{})
    earmark_options = %{ earmark_options() | compact_output: options[:compact_output] || false}
    # |> IO.inspect(label: "\nEarmark options")

    path
    |> File.read!()
    |> first_transformations(options)
    |> Earmark.as_html!(earmark_options)
    |> handle_smart_tags(path, name)
    |> mmd_transformations(options)
    # |> Makeup.highlight()
    |> load_external_code()
    |> final_transformations(options)
    |> IO.inspect(label: "\nSortie de final_transformations")
    |> EEx.compile_string(engine: Phoenix.HTML.Engine, file: path, line: 1)
    |> IO.inspect(label: "\nRetour de Engine.compile")
  end

  defp first_transformations(code, options) do
    code 
    |> protege_elixir_tags_in_blockcode(options)
    |> protege_exilir_tags_in_code(options)
  end

  # Concernant ce traitement, voir aussi la note [N001] en haut de page
  @reg_code_block ~r/(\n| *|\t*)\~\~\~((?:.|\n)*)\1\~\~\~/Um
  @reg_code ~r/(\`)(.*)\1/
  @reg_elixir_tag ~r/<%/
  @remp_elixir_tag "<%=\"<\"<>\"%\"%>"

  defp protege_elixir_tags_in_blockcode(code, options) do
    protege_elixir_tags_in(code, @reg_code_block, options)
  end

  defp protege_exilir_tags_in_code(code, options) do
    protege_elixir_tags_in(code, @reg_code, options)
  end

  defp protege_elixir_tags_in(code, regex, _options) do
    code
    |> String.replace(regex, fn resultat ->
      resultat
      |> String.replace(@reg_elixir_tag, @remp_elixir_tag)
    end)
  end


  @regex_load ~r/load\((.*)\)/U
  @regex_load_as_code ~r/load_as_code\((.*)\)/U

  # Permet de charger du code externe. On peut le placer tel quel avec la
  # mark-fonction `load(path/to/file)' ou le mettre dans un bloc de code
  # avec la mark-fonction `load_as_code(path/to/file.ext)'.
  defp load_external_code(code) do 
    code
    |> reg_replace(@regex_load_as_code, &replace_as_code/2)
    |> reg_replace(@regex_load, fn _, path -> File.read!(path) end)
  end

  defp replace_as_code(_, path) do
    extension = path |> String.split(".") |> Enum.fetch!(-1)
    langage = 
      case extension do
      "rb" -> "ruby"
      "md" -> "markdown"
      "ex" -> "elixir"
      "heex" -> "elixir component"
      "py" -> "python"
      _ -> extension # par exemple pour css
      end

    source = if @load_external_file_options[:source], do: "<span class=\"text-sm italic\">(source : #{path})</span>\n\n", else: ""
    """
    <pre><code class="makeup #{langage}">
    #{source}#{File.read!(path)}
    </code></pre>
    """
  end

  defp reg_replace(code, regexp, remp) do
    Regex.replace(regexp, code, remp)
  end

  defp mmd_transformations(code, _options) do
    code 
    |> transforme_paths()
    |> transforme_vars()
  end

  defp transforme_paths(code) do
    code
    |> String.replace(~r/p(?:ath)?\((.*)\)/U, "<path>\\1</path>")
  end

  
  # Méthode qui traite tous les `var(<variable id>)' dans les codes markdown
  #
  # Ces variables doivent être définies dans une table implémentée dans config/config.ex
  # de l'application, définie par :
  #
  #   config :my_markdown, :table_vars, %{var: val, var: val, ...}
  #
  #   (pour le moment, comme 'my_markdonw' n'est pas encore définitif, on passe
  #    par config :phoenix_markdown, :table_vars, %{...})
  defp transforme_vars(code) do
    code = Regex.replace(~r/v(?:ar)?\((.*)\)/U, code, &get_in_table_vars(&1, &2))
    code
  end
  defp get_in_table_vars(_tout, var_id) do
    var_id = String.to_atom(var_id)
    Map.get(table_vars(), var_id, "VARIABLE INTROUVABLE : #{var_id}")
  end
  defp table_vars() do
    Application.get_env(:pp_markdown, :table_vars)
  end

  defp final_transformations(html, options) do
    html 
    |> code_html_restants(options)
    |> makeup_pour_highlighting(options)
  end

  defp code_html_restants(html, _options) do
    html
    |> String.replace(~r/&lt;br( ?\/)?&gt;/, "<br />")
  end

  @regex_bad_highlight ~r/<code class="(?!makeup)/
  @remp_bad_highlight "<code class=\"makeup "

  defp makeup_pour_highlighting(html, _options) do
    html
    |> String.replace(@regex_bad_highlight, @remp_bad_highlight)
  end

  
  # 
  # ============ RÉCUPÉRÉ DE PhoenixMarkdown ================
  #
  defp earmark_options() do
    case Application.get_env(:pp_markdown, :earmark) do
    %Earmark.Options{} = opts ->
      opts
    %{} = opts ->
      Kernel.struct!(Earmark.Options, opts)
    _ ->
      %Earmark.Options{}
    end
  end

  # --------------------------------------------------------
  defp handle_smart_tags(markdown, path, name) do
    restore =
      case Application.get_env(:pp_markdown, :server_tags) do
        :all -> true
        {:only, opt} -> only?(opt, path, name)
        [{:only, opt}] -> only?(opt, path, name)
        {:except, opt} -> except?(opt, path, name)
        [{:except, opt}] -> except?(opt, path, name)
        _ -> false
      end

    do_restore_smart_tags(markdown, restore)
  end

  # --------------------------------------------------------
  defp do_restore_smart_tags(markdown, true) do
    smart_tag = ~r/&lt;%.*?%&gt;/
    markdown = Regex.replace(smart_tag, markdown, &HtmlEntities.decode/1)

    uri_smart_tag = ~r/%3C(%25)+.*?%25%3E/
    Regex.replace(uri_smart_tag, markdown, &URI.decode/1)
  end

  defp do_restore_smart_tags(markdown, _), do: markdown

  # --------------------------------------------------------
  defp only?(opt, path, name) when is_bitstring(opt) do
    case opt == name do
    true -> true
    false ->
      paths = Path.wildcard(opt)
      Enum.member?(paths, path)
    end
  end

  defp only?(opts, path, name) when is_list(opts) do
    Enum.any?(opts, &only?(&1, path, name))
  end

  # sadly there is no is_regex guard...
  defp only?(regex, path, _) do
    if Kernel.is_struct(regex, Regex) do
      String.match?(path, regex)
    else
      raise ArgumentError,
            "Invalid parameter to PhoenixMarkdown only: configuration #{inspect(regex)}"
    end
  end

  # --------------------------------------------------------
  defp except?(opt, path, name) when is_bitstring(opt) do
    case opt == name do
      true -> false
      false ->
        paths = Path.wildcard(opt)
        !Enum.member?(paths, path)
    end
  end

  defp except?(opts, path, name) when is_list(opts) do
    Enum.all?(opts, &except?(&1, path, name))
  end

  # sadly there is no is_regex guard...
  defp except?(regex, path, _) do
    if Kernel.is_struct(regex, Regex) do
      !String.match?(path, regex)
    else
      raise ArgumentError,
            "Invalid parameter to PhoenixMarkdown except: configuration #{inspect(regex)}"
    end
  end
  
end