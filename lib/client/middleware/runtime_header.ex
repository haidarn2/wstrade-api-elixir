defmodule WsTrade.Client.Middleware.RuntimeHeader do
  @moduledoc false
  @behaviour Tesla.Middleware

  @impl Tesla.Middleware
  def call(env, next, {header, provider}) do
    env
    |> Tesla.put_header(header, provider.())
    |> Tesla.run(next)
  end
end
