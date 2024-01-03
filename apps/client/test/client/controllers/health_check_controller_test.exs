defmodule Client.HealthCheckControllerTest do
  use Client.ConnCase, async: true

  describe "get_status/2" do
    test "responds with 200 OK", %{conn: conn} do
      conn = get(conn, "/healthz")
      assert json_response(conn, 200) == %{"ok" => true}
    end
  end
end
