defmodule WsTrade.Auth do
  @moduledoc false
  require Logger
  alias WsTrade.Auth.Client
  alias WsTrade.Auth.TokenCache

  @oauth_header_keys ["x-access-token", "x-refresh-token", "x-access-token-expires"]

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
      {:ok, %{status: 200, headers: headers}} ->
        Logger.debug("Login Successful.")

        oauth_token =
          headers
          |> Map.new()
          |> Map.take(@oauth_header_keys)

        TokenCache.set_token(oauth_token)
        {:ok, oauth_token}

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

  def login(email, password, otp_provider_func) when is_function(otp_provider_func, 0) do
    with {:ok, :opt_challenge_triggered} <- login(email, password),
         {:ok, otp_str} <- otp_provider_func.(),
         {:ok, oauth_token} <- login(email, password, otp_str) do
      Logger.debug("Login successful.")
      {:ok, oauth_token}
    else
      {:error, err} ->
        Logger.error("Login failed!\n#{inspect(err)}")
        {:error, err}

      e ->
        Logger.error("Login failed!\n#{inspect(e)}")
        {:error, :unexpected_error}
    end
  end

  def refresh() do
    with {:ok, %{"x-refresh-token" => refresh_token}} <- TokenCache.get_token(),
         {:ok, %{status: 200, headers: headers}} <- Client.refresh(refresh_token) do
      Logger.debug("token refresh successful.")

      oauth_token =
        headers
        |> Map.new()
        |> Map.take(@oauth_header_keys)

      TokenCache.set_token(oauth_token)
      {:ok, oauth_token}
    else
      {:error, :not_logged_in} = e ->
        e

      {:ok, %{status: 401} = resp} ->
        Logger.error("Invalid refresh token! Logging out!\n#{inspect(resp)}")
        TokenCache.flush()
        {:error, :invalid_refresh_token}

      e ->
        Logger.error("Refresh failed!\n#{inspect(e)}")
        {:error, :unexpected_error}
    end
  end
end
