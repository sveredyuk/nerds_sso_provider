defmodule Provider.OauthApplications.OauthApplication do
  use Ecto.Schema
  use ExOauth2Provider.Applications.Application, otp_app: :provider

  schema "oauth_applications" do
    application_fields()

    timestamps()
  end
end
