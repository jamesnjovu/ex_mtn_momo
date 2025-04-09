# ExMtnMomo

[![Hex.pm](https://img.shields.io/hexpm/v/ex_mtn_momo.svg)](https://hex.pm/packages/ex_mtn_momo)
[![Hex Docs](https://img.shields.io/badge/hex-docs-blue.svg)](https://hexdocs.pm/ex_mtn_momo)
[![License](https://img.shields.io/hexpm/l/ex_mtn_momo.svg)](https://github.com/your-username/ex_mtn_momo/blob/master/LICENSE)

ExMtnMomo is an Elixir library that provides a simple and elegant way to interact with the MTN Mobile Money API. It supports Sandbox testing, Collection, and Disbursement operations.

## Features

- Sandbox API for testing and development
- Collection API for receiving payments
- Disbursement API for sending payments
- Comprehensive error handling
- Configurable environment settings

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_mtn_momo` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_mtn_momo, "~> 0.1.0"}
  ]
end
```

## Configuration

Configure your MTN MoMo API credentials in your `config.exs` file:

```elixir
config :ex_mtn_momo,
  base_url: "https://sandbox.momodeveloper.mtn.com", # Production URL for live environment
  x_target_environment: "sandbox", # mtnzambia for production
  
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
```

## Quick Start

### Sandbox Setup

```elixir
# Generate a UUID for user creation
uuid = ExMtnMomo.Sandbox.get_uuid4()

# Create a user in the sandbox environment
{:ok, _} = ExMtnMomo.Sandbox.create_api_user(uuid)

# Get information about the created user
{:ok, user_info} = ExMtnMomo.Sandbox.get_created_user(uuid)

# Generate an API key for the user
{:ok, %{"apiKey" => api_key}} = ExMtnMomo.Sandbox.get_api_key(uuid)
```

### Collection Example

```elixir
# Get an access token for collections
{:ok, %{"access_token" => token}} = ExMtnMomo.Collection.create_access_token()

# Initiate a payment request
payment_details = %{
  "amount" => "1000",
  "currency" => "EUR",
  "externalId" => "123456789",
  "payer" => %{
    "partyIdType" => "MSISDN",
    "partyId" => "256771234567"
  },
  "payerMessage" => "Payment for products",
  "payeeNote" => "Payment received"
}

reference_id = UUID.uuid4()
{:ok, _} = ExMtnMomo.Collection.request_to_pay(payment_details, token, reference_id)

# Check payment status
{:ok, status} = ExMtnMomo.Collection.request_to_pay_transaction_status(reference_id, token)
```

### Disbursement Example

```elixir
# Get an access token for disbursements
{:ok, %{"access_token" => token}} = ExMtnMomo.Disbursements.create_access_token()

# Initiate a deposit
deposit_details = %{
  "amount" => "1000",
  "currency" => "EUR",
  "externalId" => "123456789",
  "payee" => %{
    "partyIdType" => "MSISDN",
    "partyId" => "256771234567"
  },
  "payerMessage" => "Salary payment",
  "payeeNote" => "Salary received"
}

reference_id = UUID.uuid4()
{:ok, _} = ExMtnMomo.Disbursements.deposit_v2(deposit_details, reference_id)
```

## Documentation

Full documentation can be found at [https://hexdocs.pm/ex_mtn_momo](https://hexdocs.pm/ex_mtn_momo).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.