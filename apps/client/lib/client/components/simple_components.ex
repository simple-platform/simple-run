defmodule Client.SimpleComponents do
  @moduledoc """
  Provides common UI components.
  """

  use Phoenix.Component

  def no_apps(assigns) do
    ~H"""
    <div class="h-full w-full flex flex-col justify-center items-center prose space-y-3">
      <Heroicons.LiveView.icon name="square-3-stack-3d" class="h-24 w-24" />
      <h1 class="m-0">Your applications will show up here</h1>
      <div>
        Get started by clicking
        <span class="italic underline underline-offset-2 decoration-dotted">Run Locally</span>
        button on your favorite GitHub repository
      </div>
    </div>
    """
  end
end
