defmodule Client.DashboardLive do
  use Client, :live_view
  alias ClientCore.Api.Application

  import Client.SimpleComponents

  def mount(_params, _session, socket) do
    {:ok, apps} = Application.get_all()
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
        <div>
          <div :for={{id, app} <- @streams.apps} id={id}>
            <%= inspect(app) %>
          </div>
        </div>
      <% end %>
    </section>
    """
  end
end
