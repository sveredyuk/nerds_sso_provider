defmodule ProviderWeb.TokenControllerTest do
  use ProviderWeb.ConnCase, async: true

  alias Provider.{OauthAccessTokens.OauthAccessToken, Repo}
  alias ExOauth2Provider.AccessTokens

  import Provider.DataFixtures

  setup %{conn: conn} do
    application = application_fixture(%{user: user_fixture()})

    {:ok, conn: conn, application: application}
  end

  describe "with authorization_code strategy" do
    setup %{conn: conn, application: application} do
      user = user_fixture()
      access_grant = access_grant_fixture(%{user: user, application: application})

      request = %{
        client_id: application.uid,
        client_secret: application.secret,
        grant_type: "authorization_code",
        redirect_uri: application.redirect_uri,
        code: access_grant.token
      }

      {:ok, conn: conn, request: request}
    end

    test "create/2", %{conn: conn, request: request} do
      conn = post conn, ~p"/oauth/token", request
      body = json_response(conn, 200)
      assert last_access_token() == body["access_token"]
    end

    test "create/2 with error", %{conn: conn, request: request} do
      conn = post conn, ~p"/oauth/token", Map.merge(request, %{redirect_uri: "invalid"})
      body = json_response(conn, 422)

      assert "The provided authorization grant is invalid, expired, revoked, does not match the redirection URI used in the authorization request, or was issued to another client." ==
               body["error_description"]
    end
  end

  describe "with revocation strategy" do
    setup %{conn: conn, application: application} do
      user = user_fixture()
      access_token = access_token_fixture(%{application: application, user: user})

      request = %{
        client_id: application.uid,
        client_secret: application.secret,
        token: access_token.token
      }

      {:ok, conn: conn, request: request}
    end

    test "revoke/2", %{conn: conn, request: request} do
      conn = post conn, ~p"/oauth/revoke", request
      body = json_response(conn, 200)
      assert body == %{}
      assert AccessTokens.is_revoked?(last_access_token())
    end

    test "revoke/2 with invalid token", %{conn: conn, request: request} do
      conn = post conn, ~p"/oauth/revoke", Map.merge(request, %{token: "invalid"})
      body = json_response(conn, 200)
      assert body == %{}
    end
  end

  defp last_access_token do
    OauthAccessToken
    |> Repo.all()
    |> List.last()
    |> Map.get(:token)
  end
end
