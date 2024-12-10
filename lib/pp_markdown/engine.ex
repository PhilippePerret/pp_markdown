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

  @reg_code ~r/(\`)(.*)\1/
  @reg_elixir_tag ~r/<%/
  @remp_elixir_tag "<%=\"<\"<>\"%\"%>"
  @reg_nowrap ~r/(nowrap|no_wrap|nw)\((.*)\)/U
  @reg_path ~r/\bp(?:ath)?\((.*)\)/U
  @reg_variable ~r/\bv(?:ar)?\((.*)\)/U
  @regex_load ~r/load\((.*)\)/U
  @regex_load_as_code ~r/load_as_code\((.*)\)/U



  # Ici, le traitement va être différent : on va, dans un premier temps, séparer
  # le texte "normal" des blocs de code (qui doivent subir beaucoup moins de
  # traitement). cela permettra aussi d'utiliser Makeup.hightlight qui ne fonctionne
  # en fait que sur des blocs de code, pas sur toute la page
  def compile(path, name \\ nil) do
    name = name || Path.basename(path)
    options = Application.get_env(:pp_markdown, :options, %{})
    options_earmark = %Earmark.Options{
      gfm: options[:gfm],
      smartypants: options[:smartypants] || false,
      breaks: true,
      compact_output: true
    }
    options = Map.merge(options, %{
      path: path, 
      name: name,
      server_tags: :all,
      earmark: options_earmark,
      smartypants: false,
      folder: Path.dirname(path)
    })

    path
    |> File.read!()
    |> load_external_codes(options)
    |> load_external_textes(options)
    |> dispatch_sections()
    |> traite_blocs_code(options)
    |> traite_blocs_texte(options)
    |> re_join_sections(options)
    |> final_transformations(options)
    |> EEx.compile_string(engine: Phoenix.HTML.Engine, file: path, line: 1)
  end

  @doc """
  Juste pour le débuggage, retourne la chaine simple qui sera affichée, avec tout son
  code HTML
  """
  def debug_smart_compile(path) do
    pseudo_ast = compile(path, Path.basename(path))
    {iodata, _bindings} = Code.eval_quoted(pseudo_ast)
    {:safe, iodata} = iodata
    IO.iodata_to_binary(iodata)
  end

  # La fonction reçoit tout le code, sépare les textes "normaux" des blocs de
  # code (qui doivent obligatoirement être marqués par "~~~" des deux côtés)
  #
  # @return :
  #   %{
  #     marked_text: "<le texte où les blocks de code ont été remplacé par
  #                   des balises __BLOCKCODE0__ etc.>"
  #     original_text: "<le texte original>"
  #     blocks: [<liste des blocs de textes, avec amorces]
  #   }
  #     {:text, "le texte"},
  #     {:blockcode, "le bloc de code avec ~~~<langage>...~~~"}
  #     {:text, "le texte}
  #     ...
  #   ]
  @reg_code_block ~r/(\n| *|\t*|^)\~\~\~([^\n]*)\n((?:.|\n)*)\1\~\~\~/Um
  defp dispatch_sections(code) do
    {blocks, letexte} =
    Regex.scan(@reg_code_block, code)
    |> Enum.with_index(0)
    |> Enum.reduce({[], code}, fn {matches, index}, {blocks, acc} ->
      full_block = Enum.fetch!(matches, 0)
      lang  = Enum.fetch!(matches, 2)
      lang  = lang == "" && nil || lang 
      block = Enum.fetch!(matches, -1)
      {blocks ++ [{block, lang, index}], String.replace(acc, full_block, "\n\n BLOCKCODE#{index} \n\n")}
    end)
    %{marked_text: letexte, original_text: code, blocks: blocks}
  end

  defp re_join_sections(file_map, _options) do
    case file_map.blocks do
    [] -> file_map[:marked_text]
    _ -> 
      Enum.reduce(file_map[:blocks], file_map[:marked_text], fn {remp, index}, acc ->
        String.replace(acc, ~r/ BLOCKCODE#{index} /, remp)
      end)
    end
  end

  # Traitement des blocs de code (et notamment colorisation syntaxique)
  #
  defp traite_blocs_code(map_file, options) do
    blocks_corrected =
      map_file.blocks
      # |> Enum.map(&traite_block_code(&1, options))
      |> Enum.map(fn {code, langage, index} -> 
        new_code = traite_block_code(code, langage, options)
        {new_code, index}
      end)
    
    Map.put(map_file, :blocks, blocks_corrected)
  end
  
  defp traite_block_code(blockcode, langage, _options) do
    lang_class = Enum.join(["makeup", langage], " ") |> String.trim()
    blockcode
    |> Makeup.highlight()
    |> String.replace("pre class=\"highlight\"", "pre class=\"#{lang_class}\"")
  end

  # Fonction de traitement principal du texte
  defp traite_blocs_texte(map_file, options) do
    texte_corrected = 
      map_file.marked_text
      |> first_transformations(options)
      |> class_et_id_css_transformations(options)
      # |> IO.inspect(label: "\nRETOUR DE class_et_id_css_transformations")
      |> Earmark.as_html!(options.earmark)
      # |> IO.inspect(label: "\nRETOUR DE Earmark.as_html!")
      |> handle_smart_tags(options)
      |> mmd_transformations(options)
    # On remet le texte dans la map du fichier
    Map.put(map_file, :marked_text, texte_corrected)
  end

  defp first_transformations(code, options) do
    code
    |> protege_exilir_tags_in_code(options)
  end

  # Concernant ce traitement, voir aussi la note [N001] en haut de page
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

  # Permet de charger du code externe. On peut le placer tel quel avec la
  # mark-fonction `load(path/to/file)' ou le mettre dans un bloc de code
  # avec la mark-fonction `load_as_code(path/to/file.ext)'.
  defp load_external_codes(code, _options) do 
    code
    |> reg_replace(@regex_load_as_code, &replace_as_code/2)
  end

  defp load_external_textes(code, options) do
    code
    |> reg_replace(@regex_load, fn _, pseudo_path -> 
      case resolve_pseudo_path(pseudo_path, options) do
        {:ok, path} -> File.read!(path)
        {:error, error} -> error
      end
    end)
  end

  # Function qui reçoit un pseudo path (qui peut se résumer au nom sans extension du fichier)
  # et retourne son path, c'est-à-dire le path d'un fichier existant
  #
  # @return {:ok, full_path} en cas de succès et {:error, <l'erreur>} dans le cas
  # contraire
  defp resolve_pseudo_path(ppath, options) do
    ppath = Path.extname(ppath) == "" && "#{ppath}.mmd" || ppath
    cond do
    File.exists?(ppath) -> {:ok, ppath}
    File.exists?(fpath = Path.join([options[:folder], ppath])) -> {:ok, fpath}
    File.exists?(fpath = Path.join(["priv","static","textes", ppath])) -> {:ok, fpath}
    options[:template_folder] && File.exists?(Path.join(options[:template_folder], ppath)) -> {:ok, Path.join(options[:template_folder], ppath)}
    true -> {:error, "[Impossible de résoudre le chemin de '#{ppath}']"}
    end
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
    
    # Code retourné
    """
    ~~~#{langage}
    #{source}#{File.read!(path)}
    ~~~
    """
  end

  defp reg_replace(code, regexp, remp) do
    Regex.replace(regexp, code, remp)
  end

  defp mmd_transformations(code, _options) do
    code
    |> transforme_nowrap()
    |> transforme_paths()
    |> transforme_vars()
  end

  defp transforme_nowrap(code) do
    code
    |> String.replace(@reg_nowrap, "<span style=\"white-space:nowrap;\">\\2</span>")
  end

  defp transforme_paths(code) do
    code
    |> String.replace(@reg_path, "<path>\\1</path>")
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
    code = Regex.replace(@reg_variable, code, &get_in_table_vars(&1, &2))
    code
  end
  defp get_in_table_vars(_tout, var_id) do
    var_id = String.to_atom(var_id)
    Map.get(table_vars(), var_id, "VARIABLE INTROUVABLE : #{var_id}")
  end
  defp table_vars() do
    Application.get_env(:pp_markdown, :table_vars)
  end

  # Méthode qui transforme :
  #
  #    style1.style2. <paragraphe>      => <p class="style1 style2">paragrpahe</p>
  #    ident#<Paragraphe>               => <p id="ident">Paragraphe</p>
  #    ident#style1.style2.<Paragraphe> => <p id="ident" class="style1 style2">
  #
  # L'expression régulière :
  #   On peut trouver n'importe quel caractère vide (\h)
  #   Ensuite, le texte doit commencer par des lettres minuscules, tirets, underscore ou point 
  #     jusqu'à finir par un point ou un dièse (qui marque vraiment la fin)
  #
  @reg_css_class_and_id ~r/\A(\h*)((?:[a-z0-9_\-]+[.#])+)(?:\h*)(.*)\z/
  @reg_mark_css ~r/([a-z0-9_\-]+)\./
  @reg_mark_id ~r/([a-z0-9_\-]+)\#/
  defp class_et_id_css_transformations(html, _options) do
    Regex.scan(~r/^(.*)$/m, html)
    |> Enum.map(fn l -> Enum.fetch!(l, 0) end)
    |> Enum.map(fn line ->
        case line do
          "" -> line
          _ -> 
          Regex.replace(@reg_css_class_and_id, line, fn _, _amorce, idcss, parag ->
            css = Regex.scan(@reg_mark_css, idcss) |> Enum.map(&Enum.at(&1, 1))
            ids = Regex.scan(@reg_mark_id, idcss) |> Enum.map(&Enum.at(&1, 1))
            mark_id  = Enum.any?(ids) && " id=\"#{ids}\"" || ""
            mark_css = Enum.any?(css) && " class=\"#{Enum.join(css, " ")}\"" || ""
            "<p#{mark_id}#{mark_css}>#{parag}</p>"
          end)
        end
      end)
    # |> IO.inspect(label: "\nTOUTES les lignes")
  end

  # Les toutes dernières transformations, juste avant de faire l'iodata qui va
  # être envoyée au moteur de rendu
  defp final_transformations(html, options) do
    html
    |> code_html_restants(options)
    |> makeup_pour_highlighting(options)
  end

  
  defp code_html_restants(html, _options) do
    html
    |> String.replace(~r/&lt;br( ?\/)?&gt;/, "<br />")
    |> String.replace("<p><pre", "<pre")
    |> String.replace("</pre></p>", "</pre>")
  end

  @regex_bad_highlight ~r/<code class="(?!makeup)/
  @remp_bad_highlight "<code class=\"makeup "

  defp makeup_pour_highlighting(html, _options) do
    html
    |> String.replace(@regex_bad_highlight, @remp_bad_highlight)
  end

  
  # 
  # ============ RÉCUPÉRÉ DE PhoenixMarkdown ================

  # --------------------------------------------------------
  defp handle_smart_tags(markdown, options) do
    path = options[:path]
    name = options[:name]
    restore =
      case options[:server_tags] do
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