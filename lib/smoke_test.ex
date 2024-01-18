defmodule SmokeTest do
  @moduledoc """
  Provides an ability to test a remote API responses with benchmarks (time, result) via HTTP calls.
  """
  alias Client.Request
  alias Concurrency

  @type response() :: {Request.time(), Request.success() | Request.error()}

  @url "https://httpbin.org/get"

  @doc """
  Performs the smoke test according to given parameters and prints formatted test's results.
    ##Examples:
      iex> result = SmokeTest.run()
      iex> true = String.starts_with?(result, "\\nResult:\\n- requests made: 1")

      iex> result = SmokeTest.run("https://httpbin.org/get", sequence: 1, parallel: 2)
      iex> true = String.starts_with?(result, "\\nResult:\\n- requests made: 3")
  """
  @spec run(String.t()) :: String.t()
  def run(url \\ @url), do: run(url, sequence: 1, parallel: 0)

  def run(_, sequence: s, parallel: p) when not is_integer(s) or not is_integer(p) do
    {:error, "The `sequence` and `parallel` args must be non-negative integers."}
  end

  def run(_, sequence: s, parallel: p) when s < 0 or p < 0 do
    {:error, "The `sequence` and `parallel` args must be equal or greater than 0."}
  end

  @spec run(String.t(), sequence: non_neg_integer(), parallel: non_neg_integer()) :: String.t()
  def run(url, sequence: sequence, parallel: parallel) do
    url
    |> send_requests(sequence, parallel)
    |> reduce_output()
    |> output_to_string()
  end

  @spec send_requests(String.t(), non_neg_integer(), non_neg_integer()) :: [response()]
  defp send_requests(_, 0, 0), do: []
  defp send_requests(url, sequence_count, 0), do: in_sequence(url, sequence_count)
  defp send_requests(url, 0, parallel_count), do: in_parallel(url, parallel_count)

  defp send_requests(url, sequence_count, parallel_count) do
    in_sequence(url, sequence_count) ++ in_parallel(url, parallel_count)
  end

  @spec in_sequence(String.t(), non_neg_integer()) :: [response()]
  defp in_sequence(url, count) do
    Enum.map(1..count, fn _ -> Request.perform(url) end)
  end

  @spec in_parallel(String.t(), non_neg_integer()) :: [response()]
  defp in_parallel(url, count) do
    Concurrency.seed(&Client.Request.perform/1, [url], count)
    |> Concurrency.harvest()
  end

  @spec reduce_output([Request.success() | Request.failure()]) :: map()
  defp reduce_output(result) do
    Enum.reduce(
      result,
      %{requests: 0, success: 0, failure: 0, time: []},
      fn {status, time}, acc -> update_stats(acc, time, status) end
    )
  end

  @spec update_stats(map(), Request.time(), :ok | :error) :: map()
  defp update_stats(%{requests: r, success: s, time: t} = map, time, :ok) do
    Map.merge(map, %{requests: r + 1, success: s + 1, time: [time | t]})
  end

  defp update_stats(%{requests: r, failure: f, time: t} = map, time, :error) do
    Map.merge(map, %{requests: r + 1, failure: f + 1, time: [time | t]})
  end

  @spec output_to_string(map()) :: String.t()
  defp output_to_string(output) do
    """

    Result:
    - requests made: #{output.requests};
    - succeed: #{output.success};
    - failed: #{output.failure};
    - avg. time per request: #{div(Enum.sum(output.time), output.requests)}ms;
    - time (in ms): #{output.time |> Enum.reverse() |> Enum.join(", ")};
    """
  end
end
