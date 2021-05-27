defmodule WsTrade.Accounts do
  alias WsTrade.Client

  def get_accounts() do
    Client.get_accounts()
    |> case do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, %{status: 401}} -> {:error, :unauthorized}
      {:ok, %{status: _}} -> {:error, :unknown_status}
      e -> {:error, :remote_call_failed}
    end
  end
end
