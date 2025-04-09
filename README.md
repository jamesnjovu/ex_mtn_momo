# ExMtnMomo

[![Hex.pm](https://img.shields.io/hexpm/v/ex_mtn_momo.svg)](https://hex.pm/packages/ex_mtn_momo)
[![Hex Docs](https://img.shields.io/badge/hex-docs-blue.svg)](https://hexdocs.pm/ex_mtn_momo)
[![License](https://img.shields.io/hexpm/l/ex_mtn_momo.svg)](https://github.com/your-username/ex_mtn_momo/blob/master/LICENSE)

A robust Elixir client library for the MTN Mobile Money API, providing a simple and elegant interface for integrating with MTN's payment services.

## Features

- 📱 **Complete API Coverage** - Support for Collections, Disbursements, and Sandbox APIs
- 🔄 **Webhook Integration** - Easy processing of MTN MoMo callbacks
- 🔒 **Secure Authentication** - Seamless handling of OAuth tokens
- ⚙️ **Flexible Configuration** - Environment-specific settings
- 🧪 **Sandbox Testing** - Development environment support
- 🛠️ **Comprehensive Tooling** - Error handling, response parsing, and more

## Installation

Add `ex_mtn_momo` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_mtn_momo, "~> 0.1.2"}
  ]
end
```

## Configuration

Add your MTN MoMo API credentials to your `config.exs` file:

```elixir
config :ex_mtn_momo,
  base_url: "https://sandbox.momodeveloper.mtn.com",
  x_target_environment: "sandbox", # Options: "sandbox", "mtnzambia", etc.
  sandbox_key: "your_secondary_key or your_primary_key",
  
  # Disbursement credentials
  disbursement: %{
    secondary_key: "542809304c684ef1ad69d0abd0365a27",
    primary_key: "c5fd5b948d48486182bacfec52b81146",
    user_id: "ed59bb21-d650-43cc-87b5-81db171c22bf",
    api_key: "379d8f976c874bdd8fe2a66e72e14ca8"
  },
  
  # Collection credentials
  collection: %{
    secondary_key: "68f9275fb30547a9b9b592872317d88c",
    primary_key: "e39426048d6a4fff91f40bbb1e67283b",
    user_id: "75117b89-c4b5-4c44-b2ad-676cfae53be6",
    api_key: "79a148215e1e4fb48209d317d58a5c71"
  }
```

## API Overview

ExMtnMomo is organized into three main modules:

- `ExMtnMomo.Sandbox` - Functions for setting up and testing in the sandbox environment
- `ExMtnMomo.Collection` - Functions for receiving payments from customers
- `ExMtnMomo.Disbursements` - Functions for sending payments to customers

## Sandbox API

The Sandbox module allows you to create and manage API users for testing purposes.

### Creating a User

```elixir
# Generate a UUID for the new user
uuid = ExMtnMomo.Sandbox.get_uuid4()
# => "f8c7a6e5-d4b3-2c1a-0f9e-8d7c6b5a4e3d"

# Create an API user with a callback URL
{:ok, _} = ExMtnMomo.Sandbox.create_api_user(
  uuid,
  "https://webhook.site/your-webhook-id"
)
# => {:ok, "User Created"}

# Retrieve user details
{:ok, user_info} = ExMtnMomo.Sandbox.get_created_user(uuid)
# => {:ok, %{"providerCallbackHost" => "https://webhook.site/your-webhook-id"}}

# Generate an API key for the user
{:ok, %{"apiKey" => api_key}} = ExMtnMomo.Sandbox.get_api_key(uuid)
# => {:ok, %{"apiKey" => "a94d865a12e047319c6e673a15b48776"}}
```

## Collection API

The Collection API facilitates receiving payments from mobile money users.

### Authentication

```elixir
# Create an access token for collection operations
{:ok, token_info} = ExMtnMomo.Collection.create_access_token()
# => {:ok, %{"access_token" => "eyJ0eXAiOiJKV1QiLCJhbGciOiJSMjU2In0...", "expires_in" => 3600, "token_type" => "Bearer"}}

# Extract the access token
access_token = token_info["access_token"]
```

### Request to Pay

```elixir
# Create a payment request
payment_details = %{
  "amount" => "5000",
  "currency" => "EUR",
  "externalId" => "123456789",
  "payer" => %{
    "partyIdType" => "MSISDN",
    "partyId" => "256771234567"
  },
  "payerMessage" => "Payment for order #12345",
  "payeeNote" => "Customer payment received"
}

# Generate a reference ID
reference_id = UUID.uuid4()

# Submit the payment request
{:ok, _} = ExMtnMomo.Collection.request_to_pay(payment_details, access_token, reference_id)
# => {:ok, %{}}

# Check payment status
{:ok, status} = ExMtnMomo.Collection.request_to_pay_transaction_status(reference_id, access_token)
# => {:ok, 
#      %{
#        "amount" => "5000",
#        "currency" => "EUR",
#        "externalId" => "123456789",
#        "financialTransactionId" => "23503452",
#        "payer" => %{
#          "partyIdType" => "MSISDN",
#          "partyId" => "256771234567"
#        },
#        "status" => "SUCCESSFUL"
#      }
#    }
```

### Account Operations

```elixir
# Get account balance
{:ok, balance} = ExMtnMomo.Collection.get_account_balance(access_token)
# => {:ok, %{"availableBalance" => "15000", "currency" => "EUR"}}

# Get balance in a specific currency
{:ok, balance_eur} = ExMtnMomo.Collection.get_account_balance_in_specific_currency("EUR", access_token)
# => {:ok, %{"availableBalance" => "15000", "currency" => "EUR"}}

# Get user information
{:ok, user_info} = ExMtnMomo.Collection.basic_user_info("256771234567", access_token)
# => {:ok, %{"name" => "John Doe", ...}}
```

## Disbursement API

The Disbursement API allows you to send money to mobile money users.

### Authentication

```elixir
# Create an access token for disbursement operations
{:ok, token_info} = ExMtnMomo.Disbursements.create_access_token()
# => {:ok, %{"access_token" => "eyJ0eXAiOiJKV1QiLCJhbGciOiJSMjU2In0...", "expires_in" => 3600, "token_type" => "Bearer"}}

# Extract the access token
access_token = token_info["access_token"]
```

### Deposit

```elixir
# Create a deposit transaction
deposit_details = %{
  "amount" => "10000",
  "currency" => "EUR",
  "externalId" => "987654321",
  "payee" => %{
    "partyIdType" => "MSISDN",
    "partyId" => "256771234567"
  },
  "payerMessage" => "Salary payment",
  "payeeNote" => "Monthly salary"
}

# Generate a reference ID
reference_id = UUID.uuid4()

# Execute the deposit (using API v2)
{:ok, _} = ExMtnMomo.Disbursements.deposit_v2(deposit_details, reference_id)
# => {:ok, %{}}

# Check deposit status
{:ok, status} = ExMtnMomo.Disbursements.get_deposit_status(reference_id, access_token)
# => {:ok, 
#      %{
#        "amount" => "10000",
#        "currency" => "EUR",
#        "externalId" => "987654321",
#        "financialTransactionId" => "45678901",
#        "payee" => %{
#          "partyIdType" => "MSISDN",
#          "partyId" => "256771234567"
#        },
#        "status" => "SUCCESSFUL"
#      }
#    }
```

### Refund

```elixir
# Create a refund transaction
refund_details = %{
  "amount" => "5000",
  "currency" => "EUR",
  "externalId" => "ref987654321",
  "payerMessage" => "Order cancellation refund",
  "payeeNote" => "Refund for order #12345"
}

# Generate a reference ID
reference_id = UUID.uuid4()

# Execute the refund (using API v2)
{:ok, _} = ExMtnMomo.Disbursements.refund_v2(refund_details, reference_id)
# => {:ok, %{}}

# Check refund status
{:ok, status} = ExMtnMomo.Disbursements.get_refund_status(reference_id, access_token)
# => {:ok, %{"status" => "SUCCESSFUL", ...}}
```

### Transfer

```elixir
# Create a transfer transaction
transfer_details = %{
  "amount" => "2500",
  "currency" => "EUR",
  "externalId" => "transfer123456",
  "payee" => %{
    "partyIdType" => "MSISDN",
    "partyId" => "256771234567"
  },
  "payerMessage" => "Transfer to your account",
  "payeeNote" => "Funds transfer"
}

# Generate a reference ID
reference_id = UUID.uuid4()

# Execute the transfer
{:ok, _} = ExMtnMomo.Disbursements.transfer(transfer_details, reference_id)
# => {:ok, %{}}

# Check transfer status
{:ok, status} = ExMtnMomo.Disbursements.get_transfer_status(reference_id, access_token)
# => {:ok, %{"status" => "SUCCESSFUL", ...}}
```

## Complete Function List

### Sandbox Module

| Function | Description |
|----------|-------------|
| `get_uuid4/0` | Generates a UUID v4 string |
| `create_api_user/3` | Creates an API user in the sandbox environment |
| `get_created_user/2` | Retrieves information about a created user |
| `get_api_key/2` | Generates and retrieves an API key for a user |

### Collection Module

| Function | Description |
|----------|-------------|
| `create_access_token/1` | Creates an access token for collection operations |
| `create_oauth_2_token/1` | Creates an OAuth 2.0 token for collection operations |
| `request_to_pay/4` | Initiates a payment request to a customer |
| `request_to_pay_transaction_status/3` | Checks the status of a payment request |
| `get_account_balance_in_specific_currency/3` | Retrieves account balance for a specific currency |
| `get_account_balance/2` | Retrieves the overall account balance |
| `get_invoice_status/3` | Retrieves the status of an invoice |
| `request_to_withdraw_transaction_status/3` | Checks the status of a withdrawal request |
| `basic_user_info/3` | Retrieves basic information about a user |
| `get_payment_status/3` | Retrieves the status of a payment |
| `get_pre_approval_status/3` | Retrieves the status of a pre-approval |
| `get_user_info_with_consent/2` | Retrieves user information with consent |

### Disbursements Module

| Function | Description |
|----------|-------------|
| `bc_authorize/1` | Authorizes a BC request |
| `create_access_token/1` | Creates an access token for disbursement operations |
| `create_oauth_2_token/1` | Creates an OAuth 2.0 token for disbursement operations |
| `deposit_v1/3` | Initiates a deposit using API version 1.0 |
| `deposit_v2/3` | Initiates a deposit using API version 2.0 |
| `refund_v1/3` | Initiates a refund using API version 1.0 |
| `refund_v2/3` | Initiates a refund using API version 2.0 |
| `transfer/3` | Initiates a transfer |
| `get_account_balance/2` | Retrieves the account balance for disbursements |
| `get_account_balance_in_specific_currency/3` | Retrieves account balance for a specific currency |
| `get_deposit_status/3` | Retrieves the status of a deposit |
| `get_refund_status/3` | Retrieves the status of a refund |
| `get_transfer_status/3` | Retrieves the status of a transfer |
| `get_user_info_with_consent/2` | Retrieves user information with consent for disbursements |

## Error Handling

All API calls return either `{:ok, result}` or `{:error, reason}`. This allows for clean error handling with pattern matching:

```elixir
case ExMtnMomo.Collection.request_to_pay(payment_details, access_token, reference_id) do
  {:ok, response} ->
    # Handle successful payment request
    Logger.info("Payment request successful: #{reference_id}")
    {:ok, reference_id}
    
  {:error, %{"code" => code, "message" => message}} ->
    # Handle API error with code and message
    Logger.error("Payment request failed: #{code} - #{message}")
    {:error, :payment_request_failed}
    
  {:error, reason} ->
    # Handle other errors
    Logger.error("Payment request error: #{inspect(reason)}")
    {:error, :unknown_error}
end
```

## Testing

To run the tests:

```bash
mix test
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- MTN Mobile Money API documentation
- Elixir community for the excellent HTTP and JSON libraries