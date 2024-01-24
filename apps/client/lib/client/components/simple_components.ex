defmodule Client.SimpleComponents do
  @moduledoc """
  Provides common UI components.
  """

  use Phoenix.Component

  @visible_states %{
    repo: [:cloning, :clone_failed, :start_failed],
    script: [:running, :failed, :success],
    container: [:scheduled, :building, :build_failed, :starting, :running, :run_failed, :stopped]
  }

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

  def state(assigns) do
    ~H"""
    <%= if state_visible?(@state, @type) do %>
      <div class="text-right w-full">
        <span class={"#{label_style(@state)} badge badge-xs p-2"}>
          <%= @state |> Atom.to_string() |> String.replace("_", " ") %>
        </span>
      </div>
    <% end %>
    """
  end

  defp label_style(:running), do: "badge-primary"

  defp label_style(state) do
    if state |> Atom.to_string() |> String.ends_with?("failed"),
      do: "badge-warning",
      else: "badge-outline"
  end

  defp state_visible?(state, type), do: @visible_states[type] |> Enum.any?(&(&1 == state))

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
    </div>
    """
  end

  def progress(assigns) when is_nil(assigns.progress) do
    ~H"""

    """
  end

  def progress(assigns) do
    ~H"""
    <span class="badge badge-secondary badge-xs p-2"><%= @progress %></span>
    """
  end

  def ports(assigns) when assigns.ports == [] do
    ~H"""

    """
  end

  def ports(assigns) do
    ~H"""
    <ul class="flex space-x-3">
      <li
        :for={
          %{
            "port" => container_port,
            "local" => %{"ip" => ip, "port" => local_port}
          } <-
            @ports
        }
        class="flex"
      >
        <%= if http_service?(ip,local_port) do %>
          <a href={"http://#{ip}:#{local_port}"} target="_blank" class="btn btn-outline btn-xs">
            <%= port(%{container_port: container_port, local_port: local_port, is_http: true}) %>
          </a>
        <% else %>
          <button class="btn btn-active btn-ghost btn-xs pointer-events-none">
            <%= port(%{container_port: container_port, local_port: local_port, is_http: false}) %>
          </button>
        <% end %>
      </li>
    </ul>
    """
  end

  defp port(assigns) do
    ~H"""
    <Heroicons.LiveView.icon name={if @is_http, do: "globe-alt", else: "server"} class="h-3 w-3" />
    <span><%= @local_port %></span>
    <Heroicons.LiveView.icon name="arrow-long-right" class="h-4 w-4" />
    <span><%= @container_port %></span>
    """
  end

  def errors(assigns) when assigns.errors == [] do
    ~H"""

    """
  end

  def errors(assigns) do
    ~H"""
    <tr>
      <td></td>
      <td></td>
      <td>
        <div
          role="alert"
          class="alert alert-warning rounded-md flex items-center p-1 w-full text-sm gap-0 space-x-1.5"
        >
          <div>
            <Heroicons.LiveView.icon
              name="exclamation-triangle"
              class="h-5 w-5 min-h-5 min-w-5 max-w-5 max-h-5"
            />
          </div>
          <div class="flex flex-col flex-grow">
            <div :for={error <- @errors}>
              <code class="line-clamp-4 break-all text-xs my-1 select-text">
                <%= error %>
              </code>
            </div>
          </div>
        </div>
      </td>
      <td></td>
    </tr>
    """
  end

  def type(assigns) do
    ~H"""
    <div class="w-full text-right">
      <span class="badge badge-xs badge-secondary badge-outline whitespace-nowrap p-2">
        <%= @type %>
      </span>
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

  defp http_service?(ip, port) do
    case :httpc.request(:get, {"http://#{ip}:#{port}", []}, [], []) do
      {:ok, _} -> true
      _ -> false
    end
  end
end
