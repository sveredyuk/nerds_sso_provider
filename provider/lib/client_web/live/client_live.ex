defmodule ClientWeb.ClientLive do
  use ProviderWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <a href={@oauth_url}>Login with Nerds Provider</a>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    client_id = "d3657d4e6eae28872b18ed9fc7d055e3ebf370b1e756579b1e05134ba7e8fead"
    redirect_url = "https://localhost:4000/client/oauth2/callback"

    oauth_url =
      "/oauth/authorize?response_type=code&client_id=#{client_id}&redirect_uri=#{redirect_url}"

    {:ok, assign(socket, oauth_url: oauth_url)}
  end
end
