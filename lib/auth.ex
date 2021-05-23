defmodule WsTrade.Auth do
  require Logger
  alias WsTrade.Client

  def login(email, password) do
    Client.login(email, password, "")
    |> case do
      {:ok, %{status: 401}} ->
        Logger.debug("Got 401 from otp challenge")
        {:ok, :opt_challenge_triggered}

      {:ok, %{status: status} = resp} ->
        Logger.error("Got unsupported status #{status}!\n#{inspect(resp)}")
        {:error, :unsupported_status}

      e ->
        Logger.error("Remote call failed!\n#{inspect(e)}")
        {:error, :remote_call_failed}
    end
  end

  def login(email, password, otp_str) when is_binary(otp_str) do
    Client.login(email, password, otp_str)
    |> case do
      {:ok, %{status: 200}} ->
        Logger.debug("Got 200 from login")
        {:ok, :successfully_logged_in}

      {:ok, %{status: 401} = resp} ->
        Logger.error("Incorrect credentials!\n#{inspect(resp)}")
        {:error, :incorrect_credentials}

      {:ok, %{status: status} = resp} ->
        Logger.error("Got unsupported status #{status}!\n#{inspect(resp)}")
        {:error, :unsupported_status}

      e ->
        Logger.error("Remote call failed!\n#{inspect(e)}")
        {:error, :remote_call_failed}
    end
  end

  def login(email, password, get_otp_func) when is_function(get_otp_func, 0) do
    with {:ok, _} <- login(email, password),
         {:ok, otp_str} <- get_otp_func.(),
         {:ok, _} <- login(email, password, otp_str) do
      Logger.debug("Login successful.")
    else
      e -> Logger.error("Login failed!\n#{inspect(e)}")
    end
  end
end
