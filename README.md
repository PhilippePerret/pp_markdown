# PPMarkdown

Moteur de rendu PHOENIX.Elixir pour traitement étendu des fichiers markdown.

## Fonctionnalités et spécificités

* chargement du code (quelconque) d'un autre fichier `load(path/to/file)`
* chargement du code d'un autre fichier en le mettant dans un bloc pre/code du type voulu `load_as_code(path/to/file.ext)`

  Le code du fichier sera mis dans un bloc de code avec le langage correspondant à son extension (css = css, js = javascript, ex = elixir, rb = ruby, etc.).
* transformation de variables définies dans une table, à l'aide du code `var(<id variable>)`
* mise en forme des chemins d'accès (et noms de fichiers/dossiers) à l'aide de `path(to/my/file)`
* préservation d'entités HTML classiques (qui s'affichent normalement en brut avec phoenix-markdonw)
    * `<br />`
* ajout de certains styles personnalisés pour les blocs de code (*document*, *markdown*)