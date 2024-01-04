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
    <section class="h-full w-full">
      <%= if @no_apps do %>
        <.no_apps />
      <% else %>
        <table class="table text-sm">
          <thead>
            <tr>
              <th class="w-full">Name</th>
              <th>State</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            <tr :for={{id, app} <- @streams.apps} id={id} class="hover">
              <td class="flex items-center">
                <img src={app.image_url} class="h-10 w-10 mr-1.5" />
                <div>
                  <div><%= app.name %></div>
                  <div class="text-xs italic">
                    <a href={app.url} target="_blank" class="link link-hover font-light">
                      <%= app.url %>
                    </a>
                  </div>
                </div>
              </td>
              <td><%= app.state %></td>
              <td></td>
            </tr>
          </tbody>
        </table>
      <% end %>
    </section>
    """
  end

  def handle_info({:app_registered, app}, socket) do
    socket = update(socket, :no_apps, fn -> false end)
    {:noreply, stream_insert(socket, :apps, app, at: 0)}
  end
end
