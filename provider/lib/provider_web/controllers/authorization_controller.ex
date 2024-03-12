defmodule ProviderWeb.AuthorizationController do
  use ProviderWeb, :controller

  alias ExOauth2Provider.Authorization

  @config [otp_app: :provider]

  def new(conn, params) do
    conn.assigns.current_user
    |> Authorization.preauthorize(params, @config)
    |> case do
      {:ok, client, scopes} ->
        render(conn, "new.html", params: params, client: client, scopes: scopes)

      {:redirect, redirect_uri} ->
        redirect(conn, external: redirect_uri)

      {:error, error, status} ->
        conn
        |> put_status(status)
        |> render("error.html", error: error)
    end
  end

  def create(conn, params) do
    conn.assigns.current_user
    |> Authorization.authorize(params, @config)
    |> redirect_or_render(conn)
  end

  def delete(conn, params) do
    conn.assigns.current_user
    |> Authorization.deny(params, @config)
    |> redirect_or_render(conn)
  end

  defp redirect_or_render({:redirect, redirect_uri}, conn) do
    redirect(conn, external: redirect_uri)
  end

  defp redirect_or_render({:native_redirect, payload}, conn) do
    json(conn, payload)
  end

  defp redirect_or_render({:error, error, status}, conn) do
    conn
    |> put_status(status)
    |> json(error)
  end
end
