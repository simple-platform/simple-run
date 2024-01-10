defmodule Client.DashboardLive do
  use Client, :live_view

  import Client.SimpleComponents

  alias Client.Api.Container
  alias Client.Api.Application

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Container.subscribe()
      Application.subscribe()
    end

    {:ok, apps} = Application.get_all()
    apps = Enum.to_list(apps)

    socket =
      socket
      |> stream(:apps, apps)
      |> assign(:no_apps, Enum.empty?(apps))
      |> assign(:docker_version, nil)
      |> assign(:docker_running, nil)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <section class="h-full w-full flex flex-col">
      <div class="grow">
        <%= if @no_apps do %>
          <.no_apps />
        <% else %>
          <div class="px-5 py-3 space-y-6">
            <h1 class="text-3xl">Applications</h1>
            <ul id="applications" class="space-y-6" phx-update="stream">
              <li
                :for={{id, app} <- @streams.apps}
                id={id}
                class="card card-side bg-base-200 shadow-md rounded-md"
              >
                <div class="card-body p-6">
                  <div class="flex items-center space-x-1.5">
                    <div class="w-full flex items-center space-x-1.5">
                      <h3 class="card-title"><%= app.name %></h3>
                      <.label state={app.state} />
                      <.progress progress={app.progress} />
                      <div class="!ml-6 flex space-x-1.5"><.ports ports={app.ports} /></div>
                    </div>
                    <div class="space-x-3 flex items-center">
                      <.actions app={app} />
                    </div>
                  </div>
                  <.errors errors={app.errors} />
                </div>
              </li>
            </ul>
          </div>
        <% end %>
      </div>
      <.footer docker_running={@docker_running} docker_version={@docker_version} />
    </section>
    """
  end

  def handle_info({:app_registered, app}, socket) do
    socket = update(socket, :no_apps, fn _ -> false end)
    {:noreply, stream_insert(socket, :apps, app, at: 0)}
  end

  def handle_info({:app_updated, app}, socket) do
    {:noreply, stream_insert(socket, :apps, app)}
  end

  def handle_info({:docker_status, {version, running}}, socket) do
    socket =
      socket
      |> assign(:docker_version, version)
      |> assign(:docker_running, running)

    {:noreply, socket}
  end
end
