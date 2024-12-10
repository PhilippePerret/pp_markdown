# PPMarkdown

Moteur de rendu PHOENIX.Elixir pour traitement étendu des fichiers markdown.

## Fonctionnalités et spécificités

* chargement du code (quelconque) d'un autre fichier `load(path/to/file)`
* chargement du code d'un autre fichier en le mettant dans un bloc pre/code du type voulu `load_as_code(path/to/file.ext)`

  Le code du fichier sera mis dans un bloc de code avec le langage correspondant à son extension (css = css, js = javascript, ex = elixir, rb = ruby, etc.).
* transformation de variables définies dans une table, à l'aide du code `var(<id variable>)` ou simplement `v(<id variable>)`
    Ces variables doivent avoir été définies dans : 

    ~~~elixir
    # in config/config.exs
    config :pp_markdown, :table_vars, %{<var>: <val>, <var>: <val> ...}
    ~~~

* mise en forme des chemins d'accès (et noms de fichiers/dossiers) à l'aide de `path(to/my/file)` ou `p(path/to/file)`
* préservation d'entités HTML classiques (qui s'affichent normalement en brut avec phoenix-markdonw)
    * `<br />`
* ajout de certains styles personnalisés pour les blocs de code (*document*, *markdown*)
* la fonction `nowrap(...)` permet de ne rien laisser passer à la ligne sur la page HTML, même les chevrons ou certains points qui, malgré l'espace insécable, passent quand même à la ligne. La méthode peut aussi s'écrire `no_wrap` ou `nw`
* Mise en forme
    * Paragraphes avec classe css grâce à la tournure `classe_css.<Paragraphe>` (limitations : seulement des minuscules, des chiffres, des tirets et des traits plats). Application de plusieurs styles avec `style1.style2.<paragraphe>` (même limitations)
    * Paragraphes avec identifiant CSS grâce à la tournure `identifiant#<Paragraphe>.` (même limitations que pour les classes CSS). Application d'identifiant (forcément unique) et style avec `<id>#style.<paragraphe>.`.


### Options

Les options de traitement doivent être définies dans : 

~~~elixir
# in config/config.exs

config :pp_markdown, :options, %{opt1: valeur, opt2: valeur ...}

~~~

Les options :

~~~
compact_output    Si true, pas de retours chariot ajoutés
                  Default : true

gfm               traitement markdown "github flavour"
                  Défaut : true

smartypants       Si true, traite intelligemment les guillemets
breaks            Si true, ajoute des retours chariot pour la 
                  lisibilité du code
                  Défaut : false

server_tags       :all : traite les <% ... %> dans le texte (hors
                  bloc de code — dans les blocs de code, il faut
                  écrire <%%= %%>)
                  Défaut : :all

template_folder   Dossier dans lequel peuvent se trouver des fichiers
                  template ou à insérer avec load(...) ou load_as_code
                  
~~~
