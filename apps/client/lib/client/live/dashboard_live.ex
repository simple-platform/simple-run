defmodule Client.DashboardLive do
  use Client, :live_view

  import Client.SimpleComponents

  alias ClientData.Apps
  alias ClientData.Entities.App
  alias ClientData.Containers
  alias ClientData.Entities.Container

  alias Client.Managers.Docker
  alias Client.Components.Icons

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Apps.subscribe()
      Docker.subscribe()
      Containers.subscribe()
    end

    apps = Apps.get_all()
    containers = Containers.get_all()

    socket =
      socket
      |> assign(:apps, apps)
      |> assign(:active_app, Enum.at(apps, 0))
      |> assign(:containers, containers)
      |> assign(:docker_status, %{})

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <section class="h-full w-full flex flex-col overflow-hidden">
      <%= if Enum.empty?(@apps) do %>
        <.no_apps />
      <% else %>
        <section class="p-3 h-full flex space-x-3">
          <aside class="h-full max-w-[26rem] min-w-[24rem] w-[24rem]">
            <h1 class="text-2xl">Applications</h1>
            <div class="relative h-full w-full">
              <ul
                id="applications"
                class="menu menu-lg bg-base-200 rounded-box overflow-scroll flex-nowrap absolute inset-0 top-3 bottom-8 space-y-1.5"
              >
                <li :for={app <- @apps} phx-click="app_selected" phx-value-id={app.id}>
                  <div class={"flex px-3 cursor-pointer #{get_active_class(app, @active_app)}"}>
                    <div class="w-full flex items-center space-x-1.5">
                      <span><%= app.name %></span>
                    </div>
                    <.app_actions app={app} />
                  </div>
                </li>
              </ul>
            </div>
          </aside>
          <div class="w-full">
            <h1 class="text-2xl"><%= @active_app.name %></h1>
            <div class="relative h-full w-full">
              <ul class="overflow-scroll absolute inset-0 top-3 bottom-8 space-y-3">
                <li class="card bg-base-200 shadow-md">
                  <div class="card-body p-3">
                    <div class="flex items-center">
                      <div class="w-full flex items-center space-x-1.5">
                        <div class="text-md font-medium">Repository</div>
                        <.state state={@active_app.state} type={:repo} />
                        <.progress progress={@active_app.progress} />
                      </div>
                      <a
                        href={@active_app.url}
                        target="_blank"
                        class="btn btn-circle btn-outline btn-xs"
                      >
                        <Icons.github class="w-3 h-3" />
                      </a>
                    </div>
                    <.errors errors={@active_app.errors} />
                  </div>
                </li>
                <li
                  :for={c <- app_containers(@active_app, @containers)}
                  class="card bg-base-200 shadow-md"
                >
                  <div class="card-body p-3">
                    <div class="flex items-center">
                      <div class="w-full flex items-center space-x-1.5">
                        <div class="text-md font-medium">Container: <%= c.name %></div>
                        <.state state={c.state} type={:container} />
                        <.progress progress={c.progress} />
                      </div>
                    </div>
                    <.errors errors={c.errors} />
                  </div>
                </li>
              </ul>
            </div>
          </div>
        </section>
      <% end %>
      <.footer docker_status={@docker_status} />
    </section>
    """
  end

  def handle_info({:app_registered, app}, socket) do
    socket =
      socket
      |> update(:apps, fn apps -> [app | apps] end)
      |> update(:active_app, fn _ -> app end)

    {:noreply, socket}
  end

  def handle_info({:app_updated, %App{id: id} = app}, socket) do
    apps =
      socket.assigns.apps
      |> Enum.map(fn %App{id: id} = existing_app ->
        if id == app.id, do: app, else: existing_app
      end)

    socket = socket |> update(:apps, fn _ -> apps end)

    socket =
      case id == socket.assigns.active_app.id do
        true -> socket |> update(:active_app, fn _ -> app end)
        false -> socket
      end

    {:noreply, socket}
  end

  def handle_info({:container_created, container}, socket) do
    {:noreply, socket |> update(:containers, &[container | &1])}
  end

  def handle_info({:container_updated, container}, socket) do
    containers =
      socket.assigns.containers
      |> Enum.map(fn %Container{id: id} = existing_container ->
        if id == container.id, do: container, else: existing_container
      end)

    {:noreply, socket |> update(:containers, fn _ -> containers end)}
  end

  def handle_info({:docker_status, status}, socket) do
    {:noreply, socket |> update(:docker_status, fn _ -> status end)}
  end

  def handle_event("app_selected", %{"id" => id}, socket) do
    {:noreply, socket |> update(:active_app, fn _ -> Apps.get_by_id(id) end)}
  end

  defp get_active_class(current_app, active_app) do
    if active_app.id == current_app.id, do: "active", else: ""
  end

  def app_containers(app, containers) do
    containers |> Enum.filter(fn c -> c.app_id == app.id end)
  end
end
