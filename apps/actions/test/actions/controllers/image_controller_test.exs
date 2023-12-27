defmodule Actions.ImageControllerTest do
  use Actions.ConnCase, async: true

  @code "p:gh|o:simple-platform|r:simple-run|f:docker-compose.yaml"

  @pixel_image_url Application.compile_env(:actions, :pixel_image_url)
  @button_image_url Application.compile_env(:actions, :button_image_url)

  @mac "Macintosh"
  @win "Windows NT"
  @linux "Linux"

  describe "redirect_to_image/2" do
    test "should redirect to button image if client is on MacOS" do
      conn =
        build_conn()
        |> put_req_header("user-agent", @mac)
        |> get("/img/#{@code}")

      assert redirected_to(conn, 302) == @button_image_url
    end

    test "should redirect to pixel image if client is on Windows" do
      conn =
        build_conn()
        |> put_req_header("user-agent", @win)
        |> get("/img/#{@code}")

      assert redirected_to(conn, 302) == @pixel_image_url
    end

    test "should redirect to pixel image if client is on Linux" do
      conn =
        build_conn()
        |> put_req_header("user-agent", @linux)
        |> get("/img/#{@code}")

      assert redirected_to(conn, 302) == @pixel_image_url
    end
  end
end
