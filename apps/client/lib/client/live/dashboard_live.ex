defmodule Client.DashboardLive do
  alias ClientData.Entities.Script
  use Client, :live_view

  import Client.SimpleComponents

  alias ClientData.Apps
  alias ClientData.Scripts
  alias ClientData.Containers
  alias ClientData.Entities.App
  alias ClientData.Entities.Container

  alias Client.Managers.Docker
  alias Client.Components.Icons

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Apps.subscribe()
      Docker.subscribe()
      Scripts.subscribe()
      Containers.subscribe()
    end

    apps = Apps.get_all()
    scripts = Scripts.get_all()
    containers = Containers.get_all()

    socket =
      socket
      |> assign(:apps, apps)
      |> assign(:scripts, scripts)
      |> assign(:containers, containers)
      |> assign(:active_app, Enum.at(apps, 0))
      |> assign(:docker_status, %{})

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <section class="h-full w-full flex flex-col overflow-hidden">
      <%= if Enum.empty?(@apps) do %>
        <.no_apps />
      <% else %>
        <section class="p-6 h-full flex space-x-6">
          <aside class="h-full max-w-[26rem] min-w-[24rem] w-[24rem]">
            <h1 class="text-2xl">Applications</h1>
            <div class="relative h-full w-full">
              <ul
                id="applications"
                class="menu menu-lg bg-base-200 rounded-box overflow-scroll flex-nowrap absolute inset-0 top-3 bottom-8 space-y-3 p-3"
              >
                <li :for={app <- @apps} phx-click="app_selected" phx-value-id={app.id}>
                  <div class={"flex px-3 cursor-pointer rounded-xl #{get_active_class(app, @active_app)}"}>
                    <div class="w-full flex items-center space-x-3">
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
              <div class="absolute inset-0 top-3 bottom-8 overflow-scroll">
                <table class="table table-xs">
                  <thead>
                    <tr>
                      <th></th>
                      <th></th>
                      <th class="w-full"></th>
                      <th></th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr class="hover">
                      <td><.state state={@active_app.state} type={:repo} /></td>
                      <td><.type type="repository" /></td>
                      <td class="flex items-center space-x-1.5">
                        <div class="font-medium text-sm"><%= get_repo_path(@active_app) %></div>
                        <.progress progress={@active_app.progress} />
                      </td>
                      <td>
                        <a
                          href={@active_app.url}
                          target="_blank"
                          class="btn btn-circle btn-outline btn-xs"
                        >
                          <Icons.github class="w-3 h-3" />
                        </a>
                      </td>
                    </tr>
                    <.errors errors={@active_app.errors} />

                    <%= for s <- app_scripts(@active_app, @scripts, :pre) do %>
                      <tr class="hover">
                        <td><.state state={s.state} type={:script} /></td>
                        <td><.type type="pre script" /></td>
                        <td>
                          <div class="font-medium text-sm"><%= s.name %></div>
                          <div class="text-xs italic"><%= s.file %></div>
                        </td>
                        <td></td>
                      </tr>
                      <.errors errors={s.errors} />
                    <% end %>

                    <%= for c <- app_containers(@active_app, @containers) do %>
                      <tr class="hover">
                        <td><.state state={c.state} type={:container} /></td>
                        <td><.type type="container" /></td>
                        <td class="space-y-1.5">
                          <div class="flex items-center space-x-1.5">
                            <div class="font-medium text-sm"><%= c.name %></div>
                            <.progress progress={c.progress} />
                          </div>
                          <.ports ports={c.ports} />
                        </td>
                        <td></td>
                      </tr>
                      <.errors errors={c.errors} />
                    <% end %>

                    <%= for s <- app_scripts(@active_app, @scripts, :post) do %>
                      <tr class="hover">
                        <td><.state state={s.state} type={:script} /></td>
                        <td><.type type="post script" /></td>
                        <td>
                          <div class="font-medium text-sm"><%= s.name %></div>
                          <div class="text-xs italic"><%= s.file %></div>
                        </td>
                        <td></td>
                      </tr>
                      <.errors errors={s.errors} />
                    <% end %>
                  </tbody>
                </table>
              </div>
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

  def handle_info({:script_registered, script}, socket) do
    {:noreply, socket |> update(:scripts, &[script | &1])}
  end

  def handle_info({:script_updated, script}, socket) do
    scripts =
      socket.assigns.scripts
      |> Enum.map(fn %Script{id: id} = existing_script ->
        if id == script.id, do: script, else: existing_script
      end)

    {:noreply, socket |> update(:scripts, fn _ -> scripts end)}
  end

  def handle_info({:docker_status, status}, socket) do
    {:noreply, socket |> update(:docker_status, fn _ -> status end)}
  end

  def handle_event("app_selected", %{"id" => id}, socket) do
    {:noreply, socket |> update(:active_app, fn _ -> Apps.get_by_id(id) end)}
  end

  ##########

  defp get_active_class(current_app, active_app) do
    if active_app.id == current_app.id, do: "active", else: ""
  end

  defp get_repo_path(app) do
    Apps.get_short_path!(app)
  end

  defp app_containers(app, containers) do
    containers |> Enum.filter(fn c -> c.app_id == app.id end)
  end

  defp app_scripts(app, scripts, type) do
    scripts |> Enum.filter(fn s -> s.app_id == app.id && s.type == type end)
  end
end
