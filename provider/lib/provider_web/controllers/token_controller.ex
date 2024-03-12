defmodule ProviderWeb.TokenController do
  use ProviderWeb, :controller

  alias ExOauth2Provider.Token

  @config [otp_app: :provider]

  def create(conn, params) do
    params
    |> Token.grant(@config)
    |> case do
      {:ok, access_token} ->
        json(conn, access_token)

      {:error, error, status} ->
        conn
        |> put_status(status)
        |> json(error)
    end
  end

  def revoke(conn, params) do
    params
    |> Token.revoke(@config)
    |> case do
      {:ok, response} ->
        json(conn, response)

      {:error, error, status} ->
        conn
        |> put_status(status)
        |> json(error)
    end
  end
end
