defmodule Provider.DataFixtures do
  alias ExOauth2Provider.{AccessGrants, AccessTokens, Applications}

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Provider.Accounts.register_user()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end

  def application_fixture(%{user: user} = attrs \\ []) do
    attrs = Map.merge(%{name: "Example", redirect_uri: "https://example.com"}, attrs)
    {:ok, application} = Applications.create_application(user, attrs, otp_app: :provider)

    application
  end

  def access_token_fixture(%{application: application, user: user} = attrs) do
    attrs = Map.put_new(attrs, :redirect_uri, application.redirect_uri)

    {:ok, access_token} = AccessTokens.create_token(user, attrs, otp_app: :provider)

    access_token
  end

  def access_grant_fixture(%{application: application, user: user} = attrs) do
    attrs =
      attrs
      |> Map.put_new(:redirect_uri, application.redirect_uri)
      |> Map.put_new(:expires_in, 7200)

    {:ok, access_token} = AccessGrants.create_grant(user, application, attrs, otp_app: :provider)

    access_token
  end
end
