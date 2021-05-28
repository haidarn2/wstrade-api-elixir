defmodule WsTrade.Data do
  require Logger

  alias WsTrade.Client

  @moduledoc """
  A module that provides functions for retrieving WS Trade securities information & exchange rates
  """

  @doc """
  ## Fetches the current USD/CAD Exchange rates

  iex> WsTrade.Data.get_exchange_rates()
  {:ok,
  %{
   "USD" => %{
     "buy_rate" => 1.229,
     "fx_rate" => 1.2106,
     "sell_rate" => 1.1924,
     "spread" => 0.015
   }
  }}
  """
  def get_exchange_rates do
    Client.get_exchange_rates()
    |> case do
      {:ok, %{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %{status: 401}} ->
        {:error, :unauthorized}

      {:ok, %{status: _}} = e ->
        Logger.error("unknown status!\n#{inspect(e)}")
        {:error, :unknown_status}

      _e ->
        {:error, :remote_call_failed}
    end
  end
end
