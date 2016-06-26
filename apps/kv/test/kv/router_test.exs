defmodule KV.RouterTest  do
  use ExUnit.Case, async: true

  @tag :distributed # => @tag distributed: true
  test "route requests across nodes" do
    assert KV.Router.route("hello", Kernel, :node, []) == :"foo@KD"
    assert KV.Router.route("world", Kernel, :node, []) == :"bar@KD"
  end

  test "raise an error for unknown entries" do
    assert_raise RuntimeError, ~r/could not find entry/, fn ->
      KV.Router.route(<<0>>, Kernel, :node, [])
    end
  end
end
