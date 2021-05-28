defmodule WsTrade.Auth.Client do
  @moduledoc false
  use Tesla

  plug(
    Tesla.Middleware.BaseUrl,
    Application.get_env(:ws_trade, :base_url) || "https://trade-service.wealthsimple.com/auth"
  )

  plug(Tesla.Middleware.JSON)

  def login(email, password, otp) do
    post("/login", %{
      email: email,
      password: password,
      otp: otp
    })
  end

  def refresh(refresh_token) do
    post("/refresh", %{
      refresh_token: refresh_token
    })
  end
end
