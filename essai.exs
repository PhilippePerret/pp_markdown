defmodule PourEssai do
  # txt = "premier.deuxieme.Le paragraphe.\n\ntrois.identite.Un autre paragraphe."
  @txt """
  premier.deuxieme.Le paragraphe.

  monid#deux.trois.Un autre paragraphe.

  Un paragraphe sans rien du tout.

  idonly#  Mon troisième paragraphe.
  """
  @reg ~r/(\h*)((?:[a-z0-9_\-]+[.\#])+)(?:\h*)(.*)/mU
  @reg_mark_css ~r/([a-z0-9_\-]+)\./
  @reg_mark_id ~r/([a-z0-9_\-]+)\#/

  
  def replace_css_and_id(_tout, _amorce, idcss, paragraphe) do
    # [_tout, _amorce, idcss, paragraphe] = found
    IO.inspect(idcss, label: "IDCSS found")
    css =
      Regex.scan(@reg_mark_css, idcss)
      |> Enum.map(fn x -> [_tout, css] = x; css end)
    ids =
      Regex.scan(@reg_mark_id, idcss)
      |> Enum.map(fn x -> [_tout, id] = x; id end)
    mark_id = Enum.any?(ids) && " id=\"#{ids}\"" || ""
    mark_css = Enum.any?(css) && " class=\"#{Enum.join(css, " ")}\"" || ""

    "<p#{mark_id}#{mark_css}>#{paragraphe}</p>"
  end

  def corrige do
    @txt
    |> String.replace(@reg, &replace_css_and_id/4)
  end

end

PourEssai.corrige()
|> IO.inspect(label: "\n\nRÉSULTAT")


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