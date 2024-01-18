defmodule Concurrency do
  @moduledoc """
  API for parallelization of various jobs.
  """
  use GenServer

  def start() do
    GenServer.start(__MODULE__, [], name: __MODULE__)
  end

  @spec seed((... -> any()), [any()], non_neg_integer()) :: any()
  def seed(fun, args, count) do
    GenServer.cast(__MODULE__, {:seed, fun, args, count})
  end

  @spec harvest() :: [SmokeTest.response()]
  def harvest() do
    GenServer.call(__MODULE__, :harvest)
  end

  @impl true
  def init([]), do: {:ok, []}

  @impl true
  def handle_cast({:seed, fun, args, count}, _) do
    new_state =
      1..count
      |> Enum.map(fn _ -> Task.async(fn -> apply(fun, args) end) end)
      |> Enum.map(&Task.await(&1))

    {:noreply, new_state}
  end

  @impl true
  def handle_call(:harvest, _, state) do
    {:stop, :normal, state, state}
  end
end
