defmodule SmokeTestTest do
  use ExUnit.Case
  doctest SmokeTest

  describe "run/1, run/3" do
    test "invalid sequence and/or parallel args return error" do
      assert {:error, "The `sequence` and `parallel` args must be non-negative integers."} =
               SmokeTest.run("u", sequence: "x", parallel: "y")

      assert {:error, "The `sequence` and `parallel` args must be equal or greater than 0."} =
               SmokeTest.run("u", sequence: -1, parallel: 3)
    end
  end
end
