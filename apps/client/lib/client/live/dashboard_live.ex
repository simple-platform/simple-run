defmodule Client.DashboardLive do
  use Client, :live_view
  alias ClientCore.Api.Applications

  import Client.SimpleComponents

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Applications.subscribe()
    end

    {:ok, apps} = Applications.get_all()
    apps = Enum.to_list(apps)

    socket =
      socket
      |> stream(:apps, apps)
      |> assign(:no_apps, Enum.empty?(apps))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <section class="h-full w-full flex justify-center items-center">
      <%= if @no_apps do %>
        <.no_apps />
      <% else %>
        <div :for={{id, app} <- @streams.apps} id={id}>
          <%= inspect(app) %>
        </div>
      <% end %>
    </section>
    """
  end

  def handle_info({:app_registered, app}, socket) do
    socket = update(socket, :no_apps, fn -> false end)
    {:noreply, stream_insert(socket, :apps, app, at: 0)}
  end
end
