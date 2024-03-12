defmodule ProviderWeb.AuthorizationControllerTest do
  use ProviderWeb.ConnCase, async: true

  alias Provider.{OauthAccessGrants.OauthAccessGrant, Repo}
  alias ExOauth2Provider.Scopes

  import Provider.DataFixtures

  setup %{conn: conn} do
    user = user_fixture()
    conn = log_in_user(conn, user)
    {:ok, conn: conn, user: user}
  end

  test "new/2 renders authorization form", %{conn: conn, user: user} do
    application = application_fixture(%{user: user})

    conn = get conn, ~p"/oauth/authorize", valid_params(application)

    body = html_response(conn, 200)

    assert body =~ "Authorize <strong>#{application.name}</strong> to use your account?"
    assert body =~ application.name

    application.scopes
    |> Scopes.to_list()
    |> Enum.each(fn scope ->
      assert body =~ "<li>#{scope}</li>"
    end)
  end

  test "new/2 renders error with invalid client", %{conn: conn} do
    conn = get conn, ~p"/oauth/authorize", %{client_id: "", response_type: "code"}

    assert html_response(conn, 422) =~
             "Client authentication failed due to unknown client, no client authentication included, or unsupported authentication method."
  end

  test "new/2 redirects with error", %{conn: conn, user: user} do
    application = application_fixture(%{user: user})
    conn = get conn, ~p"/oauth/authorize", %{client_id: application.uid, response_type: "other"}

    assert redirected_to(conn) ==
             "https://example.com?error=unsupported_response_type&error_description=The+authorization+server+does+not+support+this+response+type."
  end

  test "new/2 with matching access token redirects when already shown", %{conn: conn, user: user} do
    application = application_fixture(%{user: user})
    access_token_fixture(%{user: user, application: application})

    conn = get conn, ~p"/oauth/authorize", valid_params(application)
    assert redirected_to(conn) == "https://example.com?code=#{last_grant_token()}"
  end

  test "create/2 redirects", %{conn: conn, user: user} do
    application = application_fixture(%{user: user})
    conn = post conn, ~p"/oauth/authorize", valid_params(application)
    assert redirected_to(conn) == "https://example.com?code=#{last_grant_token()}"

    assert last_grant().resource_owner_id == user.id
  end

  test "delete/2 redirects", %{conn: conn, user: user} do
    application = application_fixture(%{user: user})
    conn = delete conn, ~p"/oauth/authorize", valid_params(application)

    assert redirected_to(conn) ==
             "https://example.com?error=access_denied&error_description=The+resource+owner+or+authorization+server+denied+the+request."
  end

  defp last_grant do
    OauthAccessGrant
    |> Repo.all()
    |> List.last()
  end

  defp last_grant_token, do: last_grant().token

  def valid_params(application) do
    %{
      client_id: application.uid,
      response_type: "code",
      redirect_uri: application.redirect_uri
    }
  end
end
