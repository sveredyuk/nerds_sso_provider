defmodule ClientWeb.ClientCallbackLive do
  use ProviderWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      access_token: <%= @access_token %>
    </div>
    """
  end

  def mount(%{"code" => code}, _session, socket) do
    if connected?(socket) do
      Req.post("http://localhost:4000/oauth/token",
        params: %{
          grant_type: "authorization_code",
          client_id: "d3657d4e6eae28872b18ed9fc7d055e3ebf370b1e756579b1e05134ba7e8fead",
          client_secret: "0b66263cb0dc22feabdf456edf522b91a5480ac7e743bfef5035f81020364305",
          redirect_uri: "https://localhost:4000/client/oauth2/callback",
          code: code
        }
      )
      |> case do
        {:ok, %{status: 200, body: %{"access_token" => access_token}}} ->
          {:ok, assign(socket, access_token: access_token)}

        {:ok, %{body: %{"error_description" => error}}} ->
          {:ok, assign(socket, access_token: error)}

        error ->
          dbg(error)
          {:ok, assign(socket, access_token: "Undefined error")}
      end
    else
      {:ok, assign(socket, access_token: nil)}
    end
  end

  def mount(%{"error" => error}, _session, socket) do
    {:ok, assign(socket, access_token: error)}
  end
end
