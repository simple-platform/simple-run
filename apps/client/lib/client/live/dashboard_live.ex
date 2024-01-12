defmodule Client.DashboardLive do
  use Client, :live_view

  import Client.SimpleComponents

  alias Client.Entities.App

  def mount(_params, _session, socket) do
    if connected?(socket) do
      App.subscribe()
    end

    apps = App.get_all() |> Enum.to_list()

    socket =
      socket
      |> stream(:apps, apps)
      |> assign(:no_apps, Enum.empty?(apps))
      |> assign(:active_app, Enum.at(apps, 0))

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
                    <div class="w-full"><%= app.name %></div>
                    <.app_actions app={app} />
                  </div>
                </li>
              </ul>
            </div>
          </aside>
          <div class="w-full">
            <h1 class="text-2xl"><%= @active_app.name %></h1>
          </div>
        </section>
      <% end %>
    </section>
    """
  end

  def handle_info({:app_registered, app}, socket) do
    socket =
      socket
      |> stream_insert(:apps, app, at: 0)
      |> update(:no_apps, fn _ -> false end)

    {:noreply, socket}
  end
end
