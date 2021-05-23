defmodule WsTrade.Client do
  @moduledoc false
  use Tesla

  plug(Tesla.Middleware.BaseUrl, Application.get_env(:ws_trade, :base_url))
  plug(Tesla.Middleware.JSON)

  def login(email, password, otp) do
    post("/auth/login", %{
      email: email,
      password: password,
      otp: otp
    })
  end
end
