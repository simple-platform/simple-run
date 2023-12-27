defmodule Actions.ImageController do
  use Actions, :controller

  @supported_os ["Macintosh"]

  @pixel_image_url Application.compile_env(:actions, :pixel_image_url)
  @button_image_url Application.compile_env(:actions, :button_image_url)

  def redirect_to_image(conn, _) do
    user_agent = conn |> get_req_header("user-agent") |> List.first()

    redirect_url =
      if Enum.any?(@supported_os, &String.contains?(user_agent, &1)),
        do: @button_image_url,
        else: @pixel_image_url

    conn |> redirect(external: redirect_url)
  end
end
