defmodule WsTrade.Client do
  @moduledoc false
  use Tesla

  plug(Tesla.Middleware.BaseUrl, Application.get_env(:ws_trade, :base_url))
  plug(Tesla.Middleware.JSON)
  plug(WsTrade.Client.Middleware.RuntimeHeader, {"Authorization", &get_auth_token/0})

  def login(email, password, otp) do
    post("/auth/login", %{
      email: email,
      password: password,
      otp: otp
    })
  end

  def get_accounts() do
    get("/account/list")
  end

  def get_auth_token do
    "1234567890"
  end
end
