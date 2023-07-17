defmodule BencodeTest do
  use ExUnit.Case
  import Bencode
  doctest Bencode

  test "Decode: valid string" do
    assert decode("2:aa") == {:ok, "aa"}
  end

  test "Decode: empty string" do
    assert decode("0:") == {:ok, ""}
  end

  test "Decode: integer" do
    assert decode("i256e") == {:ok, 256}
  end

  test "Decode: 0 integer" do
    assert decode("i0e") == {:ok, 0}
  end

  test "Decode: valid list" do
    assert decode("li35e3:aaae") == {:ok, [35, "aaa"]}
  end

  test "Decode: valid dictionary" do
    assert decode("d3:fooli10e3:bazee") == {:ok, %{"foo" => [0, "baz"]}}
  end

  test "Decode: valid dictionary with more than one key" do
    assert decode("d2:aai25e3:aaa4:aaaae") == {:ok, %{"aa" => 25, "aaa" => "aaaa"}}
  end

end
