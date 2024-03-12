# mix run priv/repo/seeds.exs

# Demo user
{:ok, user} =
  Provider.Accounts.register_user(%{email: "user@example.com", password: "Password12345"})

# Demo application
attrs = %{
  name: "Example",
  uid: "d3657d4e6eae28872b18ed9fc7d055e3ebf370b1e756579b1e05134ba7e8fead",
  secret: "0b66263cb0dc22feabdf456edf522b91a5480ac7e743bfef5035f81020364305",
  redirect_uri: "https://localhost:4000/client/oauth2/callback"
}

{:ok, application} =
  ExOauth2Provider.Applications.create_application(user, attrs, otp_app: :provider)
