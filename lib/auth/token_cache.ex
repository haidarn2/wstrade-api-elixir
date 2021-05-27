defmodule WsTrade.Auth.TokenCache do
  use GenServer

  require Logger

  # alias WsTrade.Auth

  @refresh_freq :timer.seconds(5)

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
  def handle_info(:refresh, old_token) do
    Logger.debug("refreshing oauth token...")
    # todo: use WsTrade.Auth
    new_token = old_token
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
end
