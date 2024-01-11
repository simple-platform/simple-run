defmodule Client.DashboardLive do
  use Client, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <section class="h-full w-full flex flex-col"></section>
    """
  end
end
