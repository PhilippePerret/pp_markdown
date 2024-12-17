defmodule PPMarkdown.BlockCodeTest do

  use ExUnit.Case

  alias TestHelper, as: T

  @options %{compact_output: true, protect_spec_signs: true, earmark: %Earmark.Options{
      gfm: false,
      smartypants: false,
      breaks: true,
      compact_output: true
    }}

  test "un premier test simple" do
    T.compare(
      "Paragraphe avec `code 1` <%= \"et\" %> `code 2`",
      "<p>Paragraphe avec <code>code 1</code> et <code>code 2</code></p>",
      @options
    )
  end

  test "deux blocs de code" do
    T.compare(
      """
      ~~~elixir
      Pour voir
      ~~~

      Un paragraphe

      ~~~
      un
      autre
      bloc
      ~~~
      """,
      """
      <pre class="makeup elixir"><code><span class="nc">Pour</span><span class="w"> </span><span class="n">voir</span><span class="w">
      </span></code></pre><p>Un paragraphe</p><pre class="makeup"><code><span class="n">un</span><span class="w">
      </span><span class="n">autre</span><span class="w">
      </span><span class="n">bloc</span></code></pre>
      """
    )
  end

end