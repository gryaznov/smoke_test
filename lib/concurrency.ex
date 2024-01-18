defmodule Concurrency do
  @moduledoc """
  API for parallelization of various jobs.
  """
  @spec seed((... -> any()), [any()], non_neg_integer()) :: any()
  def seed(fun, args, count) do
    Enum.map(1..count, fn _ -> Task.async(fn -> apply(fun, args) end) end)
  end

  @spec harvest(any()) :: [any()]
  def harvest(list) do
    Enum.map(list, &Task.await(&1))
  end
end
