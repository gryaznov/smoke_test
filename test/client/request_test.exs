defmodule Client.RequestTest do
  use ExUnit.Case, async: true

  alias Client.Request

  doctest Request

  describe "perform/1" do
    test "returns ok-result if the request succeed" do
      assert {:ok, _} = Request.perform("https://httpbin.org/anything")
    end

    test "returns error-result if the request failed" do
      assert {:error, _} = Request.perform("https://httpbin.org/wrong-wrong-wrong")
    end
  end
end
