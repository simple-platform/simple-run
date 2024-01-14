defmodule Client.DashboardLive do
  use Client, :live_view

  import Client.SimpleComponents

  alias ClientData.Apps
  alias ClientData.Entities.App

  alias Client.Managers.Docker

  alias Client.Components.Icons

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Apps.subscribe()
      Docker.subscribe()
    end

    apps = Apps.get_all() |> Enum.to_list()

    socket =
      socket
      |> stream(:apps, apps)
      |> assign(:no_apps, Enum.empty?(apps))
      |> assign(:active_app, Enum.at(apps, 0))
      |> assign(:docker_status, %{})

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <section class="h-full w-full flex flex-col overflow-hidden">
      <%= if @no_apps do %>
        <.no_apps />
      <% else %>
        <section class="p-3 h-full flex space-x-3">
          <aside class="h-full max-w-[26rem] min-w-[24rem] w-[24rem]">
            <h1 class="text-2xl">Applications</h1>
            <div class="relative h-full w-full">
              <ul
                id="applications"
                class="menu menu-lg bg-base-200 rounded-box overflow-scroll flex-nowrap absolute inset-0 top-3 bottom-8 space-y-1.5"
                phx-update="stream"
              >
                <li :for={{id, app} <- @streams.apps} id={id}>
                  <div class={"flex px-3 cursor-pointer #{if @active_app.id == app.id, do: "active", else: ""}"}>
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
              <ul class="overflow-scroll absolute inset-0 top-3 bottom-8 space-y-1.5">
                <li class="card bg-base-200 shadow-md">
                  <div class="card-body p-3">
                    <div class="flex items-center">
                      <div class="w-full flex items-center space-x-1.5">
                        <div class="card-title text-lg">Repository</div>
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
      |> stream_insert(:apps, app, at: 0)
      |> update(:no_apps, fn _ -> false end)
      |> update(:active_app, fn _ -> app end)

    {:noreply, socket}
  end

  def handle_info({:app_updated, %App{id: id} = app}, socket) do
    socket = socket |> stream_insert(:apps, app)

    socket =
      case id == socket.assigns.active_app.id do
        true -> socket |> update(:active_app, fn _ -> app end)
        false -> socket
      end

    {:noreply, socket}
  end

  def handle_info({:docker_status, status}, socket) do
    {:noreply, socket |> update(:docker_status, fn _ -> status end)}
  end
end
