defmodule WsTrade.Auth.TokenCache do
  use GenServer

  require Logger

  alias WsTrade.Auth.Client

  @oauth_header_keys ["x-access-token", "x-refresh-token", "x-access-token-expires"]
  @refresh_freq :timer.hours(1)

  def start_link(_args), do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)

  @impl true
  def init(_) do
    schedule_refresh()
    {:ok, nil}
  end

  @impl true
  def handle_info(:refresh, nil) do
    schedule_refresh()
    {:noreply, nil}
  end

  @impl true
  def handle_info(:refresh, %{"x-refresh-token" => token}) do
    Logger.debug("refreshing oauth token...")
    {:ok, new_token} = refresh_token(token)
    schedule_refresh()
    {:noreply, new_token}
  end

  @impl true
  def handle_call(:get_token, _from, token) do
    {:reply, token, token}
  end

  @impl true
  def handle_cast({:set_token, new_token}, _old_token) do
    {:noreply, new_token}
  end

  def get_token do
    GenServer.call(__MODULE__, :get_token)
    |> case do
      nil -> {:error, :not_logged_in}
      token -> {:ok, token}
    end
  end

  def set_token(token) do
    GenServer.cast(__MODULE__, {:set_token, token})
  end

  def flush do
    set_token(nil)
  end

  defp schedule_refresh do
    Process.send_after(self(), :refresh, @refresh_freq)
  end

  defp refresh_token(refresh_token) do
    with {:ok, %{status: 200, headers: headers}} <- Client.refresh(refresh_token) do
      oauth_token =
        headers
        |> Map.new()
        |> Map.take(@oauth_header_keys)

      Logger.debug("token refresh successful. exipres on #{parse_expiry(oauth_token)}")

      {:ok, oauth_token}
    else
      {:error, :not_logged_in} = e ->
        e

      {:ok, %{status: 401} = resp} ->
        Logger.error("Invalid refresh token! Logging out!\n#{inspect(resp)}")
        flush()
        {:error, :invalid_refresh_token}

      e ->
        Logger.error("Refresh failed!\n#{inspect(e)}")
        {:error, :unexpected_error}
    end
  end

  defp parse_expiry(%{"x-access-token-expires" => exp_str}) do
    exp_str
    |> Integer.parse()
    |> elem(0)
    |> DateTime.from_unix()
    |> elem(1)
    |> DateTime.to_iso8601()
  end
end
