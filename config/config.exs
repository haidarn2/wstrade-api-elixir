import Config

config :ws_trade,
  base_url: System.get_env("WS_TRADE_BASE_URL") || "https://trade-service.wealthsimple.com"
