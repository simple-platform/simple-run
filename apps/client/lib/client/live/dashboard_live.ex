defmodule Client.DashboardLive do
  use Client, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <section class="h-full">
      <h1>Simple Run!</h1>
    </section>
    """
  end
end
