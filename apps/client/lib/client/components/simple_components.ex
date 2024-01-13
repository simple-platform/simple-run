defmodule Client.SimpleComponents do
  @moduledoc """
  Provides common UI components.
  """

  use Phoenix.Component

  alias Client.Components.Icons

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

  def label(assigns) when not is_nil(assigns.state) do
    ~H"""
    <span class={"#{label_style(@state)} badge text-xs"}>
      <%= @state |> Atom.to_string() |> String.replace("_", " ") %>
    </span>
    """
  end

  def label(assigns) do
    ~H"""

    """
  end

  defp label_style(_), do: "badge-outline"

  def app_actions(assigns) do
    ~H"""
    <div class="actions flex space-x-1.5">
      <%= if @app.state == :running do %>
        <button class="btn btn-circle btn-outline btn-xs">
          <Heroicons.LiveView.icon name="stop" class="h-3 w-3" />
        </button>
      <% end %>
      <%= if @app.state == :stopped do %>
        <button class="btn btn-circle btn-outline btn-xs">
          <Heroicons.LiveView.icon name="play" class="h-3 w-3" />
        </button>
      <% end %>
      <button class="btn btn-circle btn-outline btn-xs">
        <Heroicons.LiveView.icon name="trash" class="h-3 w-3" />
      </button>
      <a href={@app.url} target="_blank" class="btn btn-circle btn-outline btn-xs">
        <Icons.github class="w-3 h-3" />
      </a>
    </div>
    """
  end

  def footer(assigns)
      when not assigns.docker_status.installed or not assigns.docker_status.running do
    ~H"""
    <footer class="alert alert-warning gap-1.5 rounded-none text-xs p-1.5">
      <Heroicons.LiveView.icon name="exclamation-triangle" class="h-4 w-4" />
      <%= if not @docker_status.installed do %>
        <div>
          We couldn't find Docker on your machine. Applications won't run until you <a
            class="link underline underline-offset-2 decoration-dotted"
            href="https://www.docker.com/products/docker-desktop"
            target="_blank"
          >
            install
          </a>it.
        </div>
      <% else %>
        <div>Docker is not running. Trying to start Docker so that we can run applications.</div>
      <% end %>
    </footer>
    """
  end

  def footer(assigns) do
    ~H"""

    """
  end
end
