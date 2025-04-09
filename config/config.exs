import Config

config :ex_mtn_momo,
  # Production URL for live environment
  base_url: "https://sandbox.momodeveloper.mtn.com",
  # mtnzambia for production
  x_target_environment: "sandbox",
  sandbox_key: "your_secondary_key or your_primary_key",

  # Disbursement credentials
  disbursement: %{
    secondary_key: "your_secondary_key",
    primary_key: "your_primary_key",
    user_id: "your_user_id",
    api_key: "your_api_key"
  },

  # Collection credentials
  collection: %{
    secondary_key: "your_secondary_key",
    primary_key: "your_primary_key",
    user_id: "your_user_id",
    api_key: "your_api_key"
  }
