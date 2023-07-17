defmodule BencodeDecoderTest do
  use ExUnit.Case
  doctest Bencode.Decoder
  import Bencode.Decoder

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

defmodule BencodeEncoderTest do
  use ExUnit.Case
  import Bencode.Encoder
  doctest Bencode.Decoder

  test "Encode: String type" do
    encoded = encode("test") |> IO.iodata_to_binary()
    assert encoded == "4:test"
  end

  test "Encode: Integer type" do
    encoded = encode(1000) |> IO.iodata_to_binary()
    assert encoded == "i1000e"
  end

  test "Encode: Map type" do
    encoded = encode(%{foo: "baz", fooo: 100}) |> IO.iodata_to_binary()
    assert encoded == "d3:foo3:baz4:foooi100ee"
  end

  test "Encode: all types" do
    encoded = encode(%{foo: [10, 20, "aaa"], baz: 30, d: "ddd"}) |> IO.iodata_to_binary()
    IO.inspect(encoded)
    assert encoded == "d3:bazi30e1:d3:ddd3:fooli10ei20e3:aaaee"
  end
end
