defmodule Concurrency do
  @moduledoc """
  API for parallelization of various jobs.
  """
  @spec seed((... -> any()), [any()], non_neg_integer()) :: any()
  def seed(fun, args, count) do
    Enum.map(
      1..count,
      fn _ ->
        self_pid = self()
        spawn(fn -> send(self_pid, apply(fun, args)) end)
      end
    )
  end

  @spec harvest(any()) :: [any()]
  def harvest(list) do
    Enum.map(
      list,
      fn _ ->
        receive do
          {status, time} -> {status, time}
        after
          # in case of throttling
          1000 -> {:error, 1000}
        end
      end
    )
  end
end
