defmodule Essai do
  @moduledoc """
  Pour utiliser ce module :

  iex -S mix run essai.exs
  iex> recompile();Essai.run  # ligne à rejouer autant de fois que voulu

  """
  # txt = "premier.deuxieme.Le paragraphe.\n\ntrois.identite.Un autre paragraphe."
  @txt """
  premier.deuxieme.Le paragraphe.

  monid#deux.trois.Un autre paragraphe.

  style1.style2.Un paragraphe avec deux styles, style1 et style2.

  Un paragraphe sans rien du tout.

  idonly#  Mon troisième paragraphe.
  """
  @reg_css_class_and_id ~r/\A(\h*)((?:[a-z0-9_\-]+[.#])+)(?:\h*)(.*)\z/
  @reg_mark_css ~r/([a-z0-9_\-]+)\./
  @reg_mark_id ~r/([a-z0-9_\-]+)\#/

  # @Entry
  def run do
    html = @txt

    Regex.scan(~r/^(.*)$/m, html)
    |> Enum.map(fn l -> Enum.fetch!(l, 0) end)
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(fn line ->
        Regex.replace(@reg_css_class_and_id, line, fn _, _amorce, idcss, parag ->
          css = Regex.scan(@reg_mark_css, idcss) |> Enum.map(&Enum.at(&1, 1))
          mark_css = Enum.any?(css) && " class=\"#{Enum.join(css, " ")}\"" || ""
          ids = Regex.scan(@reg_mark_id, idcss) |> Enum.map(&Enum.at(&1, 1))
          mark_id  = Enum.any?(ids) && " id=\"#{ids}\"" || ""
          "<p#{mark_id}#{mark_css}>#{parag}</p>"
        end)
      end)
    |> IO.inspect(label: "\nTOUTES les lignes")

  end

end

Essai.run


# def replace_css_and_id(_tout, _amorce, idcss, paragraphe) do
#   # [_tout, _amorce, idcss, paragraphe] = found
#   IO.inspect(idcss, label: "IDCSS found")
#   css =
#     Regex.scan(@reg_mark_css, idcss)
#     |> Enum.map(fn x -> [_tout, css] = x; css end)
#   ids =
#     Regex.scan(@reg_mark_id, idcss)
#     |> Enum.map(fn x -> [_tout, id] = x; id end)
#   mark_id = Enum.any?(ids) && " id=\"#{ids}\"" || ""
#   mark_css = Enum.any?(css) && " class=\"#{Enum.join(css, " ")}\"" || ""

#   "<p#{mark_id}#{mark_css}>#{paragraphe}</p>"
# end

# Regex.scan(reg, txt)
# |> Enum.map(fn x -> 
#   IO.inspect(x, label: "x")
#   [_tout, _amorce, idcss, paragraphe] = x
#   css =
#     Regex.scan(~r/([a-z_\-]+)\./, idcss)
#     |> Enum.map(fn x -> [_tout, css] = x; css end)
#   ids =
#   Regex.scan(~r/([a-z_\-]+)\#/, idcss)
#   |> Enum.map(fn x -> [_tout, id] = x; id end)
#   mark_id = Enum.any?(ids) && " id=\"#{ids}\"" || ""
#   mark_css = Enum.any?(css) && " class=\"#{Enum.join(css, " ")}\"" || ""

#   "<p#{mark_id}#{mark_css}>#{paragraphe}</p>"
# end)
# |> Enum.join()
# |> IO.inspect(label: "FINAL")