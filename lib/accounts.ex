defmodule WsTrade.Accounts do
  @moduledoc """
  A module that implements functions for retrieving WS Trade account details
  """
  alias WsTrade.Client

  @doc """
    Retrieves all account ids open under the logged in WealthSimple Trade account.

  ## Examples

  iex> WsTrade.Accounts.get_accounts()
  {:ok,
  %{
   "results" => [
     %{
       "account_type" => "ca_non_registered",
       "available_to_withdraw" => %{"amount" => 8.86, "currency" => "CAD"},
       "base_currency" => "CAD",
       "buying_power" => %{"amount" => 8.86, "currency" => "CAD"},
       "created_at" => "2021-01-01T19:42:29.515Z",
       "current_balance" => %{"amount" => 8.86, "currency" => "CAD"},
       "custodian_account_number" => "HF544500CAD",
       "deleted_at" => nil,
       "external_esignature_id" => "document-2de66g1e-c2e0-4061-a11c-52b0edb4f519",
       "id" => "non-registered-afdggeh6",
       "last_synced_at" => "2021-05-27T22:22:16.288Z",
       "net_deposits" => %{"amount" => 7305, "currency" => "CAD"},
       "object" => "account",
       "opened_at" => "2021-01-01T19:42:55.099Z",
       "position_quantities" => %{
         "sec-s-19dda65d393d4260af25087824e2ee0b" => 140,
         "sec-s-271b88fdc6a8484692250f329c2733c6" => 100,
         "sec-s-6e73535b8e474d8689064c4c9fee326a" => 140,
         "sec-s-85286e8ff345468ab061146fc8bd2a82" => 13
       },
       "read_only" => nil,
       "status" => "open",
       "updated_at" => "2021-01-01T19:42:29.515Z",
       "withdrawn_earnings" => %{"amount" => 0, "currency" => "CAD"}
     }
   ]
  }}
  """
  def get_accounts() do
    Client.get_accounts()
    |> case do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, %{status: 401}} -> {:error, :unauthorized}
      {:ok, %{status: _}} -> {:error, :unknown_status}
      _e -> {:error, :remote_call_failed}
    end
  end

  @doc """
    Query the history of an open account within a certain time interval.
    Account id can be retrieved from: WsTrade.Accounts.get_accounts/0
    Interval must be one of: ["1d", "1w", "1m", "3m", "1y", "all"]

  ## Examples

  iex> WsTrade.Accounts.account_history("non-registered-afdggeh6", "1d")
  {:ok,
  %{
    "previous_close_data_point" => %{
      "date" => "2021-05-26T20:00:00.000Z",
      "equity_value" => %{"amount" => 7511.5884, "currency" => "CAD"},
      "net_deposits" => %{"amount" => 7305, "currency" => "CAD"},
      "value" => %{"amount" => 7520.4484, "currency" => "CAD"},
      "withdrawn_earnings" => %{"amount" => 0, "currency" => "CAD"}
    },
    "previous_close_net_liquidation_value" => %{
      "amount" => 7520.4484,
      "currency" => "CAD"
    },
    "results" => [
      %{
        "date" => "2021-05-27T13:30:00.000Z",
        "equity_value" => %{"amount" => 7595.0496, "currency" => "CAD"},
        "net_deposits" => %{"amount" => 7305, "currency" => "CAD"},
        "relative_equity_earnings" => %{
          "amount" => 83.4612,
          "currency" => "CAD",
          "percentage" => 0.010988894661069757
        },
        "value" => %{"amount" => 7603.9096, "currency" => "CAD"},
        "withdrawn_earnings" => %{"amount" => 0, "currency" => "CAD"}
      },
      ...
    ],
    "start_earnings" => %{"amount" => 215.4484, "currency" => "CAD"}
  }}
  """
  def account_history(account_id, interval)
      when interval in ["1d", "1w", "1m", "3m", "1y", "all"] do
    Client.account_history(account_id, interval)
    |> case do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, %{status: 401}} -> {:error, :unauthorized}
      {:ok, %{status: _}} -> {:error, :unknown_status}
      _e -> {:error, :remote_call_failed}
    end
  end
end
