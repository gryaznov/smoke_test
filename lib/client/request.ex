defmodule Client.Request do
  @moduledoc """
  This module provides an API for making HTTP requests.
  """
  alias Client.Config

  @time_scale 1_000

  @type time :: non_neg_integer()
  @type success :: {:ok, non_neg_integer()}
  @type failure :: {:error, non_neg_integer()}
  @type httpc_response() ::
          {:ok | :error, {{charlist(), non_neg_integer(), charlist()}, [charlist()], charlist()}}

  @doc """
  Sends an http request and checks if the response's status is in the range of 200..299.
    ##Examples:
      iex> {:ok, _} = Request.perform("https://httpbin.org/get")
  """
  @spec perform(String.t()) :: success() | failure()
  def perform(url) do
    url
    |> get_with_benchmark()
    |> format_response()
  end

  @spec get(String.t()) :: httpc_response()
  def get(url) do
    :httpc.request(:get, {url, Config.headers()}, Config.ssl(), [])
  end

  @spec get_with_benchmark(String.t()) :: {time(), httpc_response()}
  defp get_with_benchmark(url) do
    :timer.tc(__MODULE__, :get, [url])
  end

  @spec format_response({time(), httpc_response()}) :: success() | failure()
  defp format_response({time, {:ok, {{_, status, _}, _, _}}})
       when status >= 200 and status < 300 do
    {:ok, ms_to_sec(time)}
  end

  defp format_response({time, _}), do: {:error, ms_to_sec(time)}

  @spec ms_to_sec(time()) :: time()
  defp ms_to_sec(microseconds), do: div(microseconds, @time_scale)
end
