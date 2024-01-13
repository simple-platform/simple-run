defmodule Client.AppControllerTest do
  use Client.ConnCase, async: true

  @err_unknown_provider "Request with an unknown provider"
  @err_missing_org "Request with a missing org"
  @err_missing_repo "Request with a missing repo"

  describe "register_app/2" do
    test "responds with error for unknown provider", %{conn: conn} do
      conn = post(conn, "/api/application", %{"request" => "simplerun:x?o=org&r=repo"})
      assert json_response(conn, 422) == %{"errors" => [@err_unknown_provider]}
    end

    test "responds with error for missing org", %{conn: conn} do
      conn = post(conn, "/api/application", %{"request" => "simplerun:gh?r=repo"})
      assert json_response(conn, 422) == %{"errors" => [@err_missing_org]}
    end

    test "responds with error for missing repo", %{conn: conn} do
      conn = post(conn, "/api/application", %{"request" => "simplerun:gh?o=org"})
      assert json_response(conn, 422) == %{"errors" => [@err_missing_repo]}
    end

    test "responds with success for valid request", %{conn: conn} do
      db() |> CubDB.clear()

      conn = post(conn, "/api/application", %{"request" => "simplerun:gh?o=org&r=repo}"})
      assert json_response(conn, 201) == true
    end
  end

  defp db, do: GenServer.whereis(:db)
end
