defmodule WsTrade.Auth.OtpStrategies do
  def simple_user_prompt do
    otp =
      IO.gets("OTP: ")
      |> String.trim_trailing()

    {:ok, otp}
  end
end
