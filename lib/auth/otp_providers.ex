defmodule WsTrade.Auth.OtpProviders do
  @moduledoc false
  def simple_user_prompt do
    otp =
      IO.gets("OTP: ")
      |> String.trim_trailing()

    {:ok, otp}
  end
end
