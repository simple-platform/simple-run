defmodule Actions.HttpClient do
  @moduledoc """
  This module provides an HTTP client for making requests to external services.
  """

  alias Actions.Behaviors.HttpClient

  @behaviour HttpClient

  @default_options [
    retry: false,
    pool_timeout: 500,
    receive_timeout: 1000
  ]

  def new(opts), do: Req.new(options(opts))

  def get!(req, opts), do: req |> Req.get!(options(opts))

  def post!(req, opts), do: req |> Req.post!(options(opts))

  def put!(req, opts), do: req |> Req.put!(options(opts))

  def delete!(req, opts), do: req |> Req.delete!(options(opts))

  defp options(opts), do: Keyword.merge(@default_options, opts)
end
