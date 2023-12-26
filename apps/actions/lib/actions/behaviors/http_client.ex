defmodule Actions.Behaviors.HttpClient do
  @moduledoc """
  This module provides an HTTP client for making requests to external services.
  """

  @type url() :: URI.t() | String.t()

  @callback new(options :: keyword()) :: Req.Request.t()

  @callback post!(url() | keyword() | Req.Request.t(), options :: keyword()) :: Req.Response.t()
  @callback put!(url() | keyword() | Req.Request.t(), options :: keyword()) :: Req.Response.t()
  @callback get!(url() | keyword() | Req.Request.t(), options :: keyword()) :: Req.Response.t()
  @callback delete!(url() | keyword() | Req.Request.t(), options :: keyword()) :: Req.Response.t()
end
