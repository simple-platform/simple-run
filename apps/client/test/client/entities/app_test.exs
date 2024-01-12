defmodule Client.Entities.AppTest do
  use ExUnit.Case, async: true

  alias Client.Entities.App

  @err_unknown_provider "Request with an unknown provider"
  @err_missing_org "Request with a missing org"
  @err_missing_repo "Request with a missing repo"

  @org "simple-platform"
  @repo "simple-run"

  @url "https://github.com/#{@org}/#{@repo}"

  @app %App{
    id: UUID.uuid5(:url, @url),
    url: @url,
    org: @org,
    repo: @repo,
    name: "#{@org}/#{@repo}",
    state: nil,
    progress: nil,
    dockerfile: nil,
    provider: :github,
    errors: [],
    containers: []
  }

  @valid_request "simplerun:gh?o=#{@org}&r=#{@repo}"

  setup do
    db() |> CubDB.clear()
  end

  describe "new/1" do
    test "responds with error for unknown provider" do
      assert {:error, @err_unknown_provider} = App.new("simplerun:x?o=org&r=repo")
    end

    test "responds with error for missing org" do
      assert {:error, @err_missing_org} = App.new("simplerun:gh?r=repo")
    end

    test "responds with error for missing repo" do
      assert {:error, @err_missing_repo} = App.new("simplerun:gh?o=org")
    end

    test "responds with app for valid request" do
      assert {:ok, @app} = App.new(@valid_request)
    end

    test "responds with app for valid request with dockerfile" do
      app = %App{@app | dockerfile: "Dockerfile"}
      assert {:ok, app} = App.new("#{@valid_request}&f=Dockerfile")
    end
  end

  describe "register/1" do
    test "adds the app in db" do
      App.register(@app)
      assert db() |> CubDB.get({:app, {@app.id}}) == @app
    end
  end

  describe "get_all/0" do
    test "returns all apps in db" do
      App.register(@app)
      assert App.get_all() |> Enum.to_list() == [@app]
    end
  end

  defp db, do: GenServer.whereis(:db)
end
