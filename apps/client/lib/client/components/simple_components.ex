defmodule Client.SimpleComponents do
  @moduledoc """
  Provides common UI components.
  """

  use Phoenix.Component

  def no_apps(assigns) do
    ~H"""
    <div class="h-full w-full flex justify-center items-center">
      <div class="prose space-y-3 flex flex-col justify-center items-center">
        <Heroicons.LiveView.icon name="square-3-stack-3d" class="h-24 w-24" />
        <h1 class="m-0 text-2xl">Your applications will show up here</h1>
        <div>
          Get started by clicking
          <span class="italic underline underline-offset-2 decoration-dotted">Run Locally</span>
          button on your favorite GitHub repository
        </div>
      </div>
    </div>
    """
  end

  def ports(assigns) when assigns.ports == [] do
    ~H"""

    """
  end

  def ports(assigns) do
    ~H"""
    <div :for={{container_port, {host_ip, host_port}, is_http?} <- @ports} class="flex">
      <%= if is_http? do %>
        <a
          href={"http://#{host_ip}:#{host_port}"}
          target="_blank"
          class="text-xs badge badge-outline space-x-0.5"
        >
          <%= port(%{container_port: container_port, host_port: host_port, is_http?: is_http?}) %>
        </a>
      <% else %>
        <div class="text-xs badge badge-outline space-x-0.5 border-dotted">
          <%= port(%{container_port: container_port, host_port: host_port, is_http?: is_http?}) %>
        </div>
      <% end %>
    </div>
    """
  end

  defp port(assigns) do
    ~H"""
    <Heroicons.LiveView.icon name={if @is_http?, do: "globe-alt", else: "server"} class="h-3 w-3" />
    <span><%= @container_port %></span>
    <Heroicons.LiveView.icon name="arrow-long-right" class="h-4 w-4" />
    <span><%= @host_port %></span>
    """
  end

  def label(assigns) when is_atom(assigns.state) do
    ~H"""
    <span class={"#{label_style(@state)} badge text-xs"}>
      <%= @state |> Atom.to_string() |> String.replace("_", " ") %>
    </span>
    """
  end

  defp label_style(nil), do: ""
  defp label_style(state) when state in [:running], do: "badge-primary"
  defp label_style(state) when state in [:cloning, :scheduled], do: "badge-outline"

  defp label_style(state) when state in [:building, :starting, :started],
    do: "badge-outline badge-primary"

  defp label_style(state)
       when state in [:cloning_failed, :build_failed, :start_failed, :run_failed],
       do: "badge-outline badge-error"

  def footer(assigns) when is_nil(assigns.docker_version) and is_nil(assigns.docker_running) do
    ~H"""

    """
  end

  def footer(assigns) when is_nil(assigns.docker_version) do
    ~H"""
    <footer
      role="alert"
      class="alert-warning alert rounded-md flex items-center px-3 py-1.5 w-full text-xs gap-0 space-x-1.5 rounded-none"
    >
      <Heroicons.LiveView.icon name="exclamation-triangle" class="h-4 w-4" />
      <span>
        We couldn't find Docker on your machine. Applications won't run until you
        <a
          class="link underline underline-offset-2 decoration-dotted"
          href="https://www.docker.com/products/docker-desktop"
          target="_blank"
        >
          install
        </a>
        it.
      </span>
    </footer>
    """
  end

  def footer(assigns) when not assigns.docker_running do
    ~H"""
    <footer
      role="alert"
      class="alert-warning alert rounded-md flex items-center px-3 py-1.5 w-full text-xs gap-0 space-x-1.5 rounded-none"
    >
      <Heroicons.LiveView.icon name="exclamation-triangle" class="h-4 w-4" />
      <span>Docker is not running. Please start Docker to run applications.</span>
    </footer>
    """
  end

  def footer(assigns) do
    ~H"""

    """
  end
end
