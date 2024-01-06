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

  def label(assigns) when is_atom(assigns.state) do
    ~H"""
    <span class={"#{label_style(@state)} badge text-xs"}>
      <%= @state |> Atom.to_string() |> String.replace("_", " ") %>
    </span>
    """
  end

  defp label_style(nil), do: ""
  defp label_style(state) when state in [:cloning, :scheduled], do: "badge-outline"
  defp label_style(state) when state in [:building, :starting], do: "badge-outline badge-primary"

  defp label_style(state) when state in [:cloning_failed, :build_failed],
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
