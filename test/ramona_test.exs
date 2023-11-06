defmodule RamonaTest do
  use ExUnit.Case
  alias Ramona.Utils
  doctest Ramona

  test "random hex colors" do
    pattern = ~r/^#?([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/

    assert Regex.match?(pattern, Utils.color_random())
    assert Regex.match?(pattern, Utils.color_random())
    assert Regex.match?(pattern, Utils.color_random())
    assert Regex.match?(pattern, "Ff00a3")
    assert Regex.match?(pattern, "FF20Fg") == false
    assert Regex.match?(pattern, "FF00AZ") == false
    assert Regex.match?(pattern, "#FF00AZ") == false
    assert Regex.match?(pattern, "#E80000")
  end
end
