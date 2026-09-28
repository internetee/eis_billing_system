[![Maintainability](https://qlty.sh/gh/internetee/projects/eis_billing_system/maintainability.svg)](https://qlty.sh/gh/internetee/projects/eis_billing_system)
[![Code Coverage](https://qlty.sh/gh/internetee/projects/eis_billing_system/coverage.svg)](https://qlty.sh/gh/internetee/projects/eis_billing_system)

# EIS Billing System

📚 **[API Documentation](https://internetee.github.io/eis_billing_system/)** | [GitHub Repository](https://github.com/internetee/eis_billing_system)

Centralized invoice management and payment processing system for Estonian Internet Services infrastructure. Provides invoice generation, payment processing, and integration with external payment systems for Registry, Auction, and EEID services.

## Table of Contents

- [System Overview](#system-overview)
- [Technology Stack](#technology-stack)
- [Architecture](#architecture)
- [Requirements](#requirements)
- [Installation and Setup](#installation-and-setup)
- [Configuration](#configuration)
- [Integrations](#integrations)
- [API Documentation](#api-documentation)
- [Invoice Types](#invoice-types)
- [Deployment](#deployment)
- [Testing](#testing)
- [Development](#development)

## System Overview

EIS Billing System is the central component for billing management in the Estonian Internet Services infrastructure. The system processes requests from three main services:

- **Registry** - domain management system
- **Auction** - domain auction system
- **EEID** - unified identity system

### Core Features

- Invoice and payment link generation
- Payment processing via EveryPay, and via Montonio for expiring auction payment links
- Refunds for auction deposits
- Bulk payments for auction
- Integration with Directo accounting system
- E-invoice delivery via Omniva
- Automatic transaction detection via LHV Connect
- Web interface for administrators

## Technology Stack

### Backend
- **Ruby** 3.4.10
- **Rails** 7.2.2.0
- **PostgreSQL** (primary database)
- **Redis** (caching and background jobs)

### Frontend
- **Hotwire** (Turbo + Stimulus)
- **Importmap** (JS dependency management)
- **Sprockets** (asset pipeline)

### External Dependencies
- **Puma** - application server
- **Sidekiq/ActiveJob** - background jobs
- **PDFKit** + wkhtmltopdf - PDF generation
- **PgSearch** - full-text search
- **Pagy** - pagination

## Architecture

### Service Communication

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   Registry  │────▶│              │◀────│   Auction   │
└─────────────┘     │              │     └─────────────┘
                    │  EIS Billing │
┌─────────────┐     │   System     │     ┌─────────────┐
│    EEID     │────▶│              │────▶│  EveryPay   │
└─────────────┘     └──────┬───────┘     └─────────────┘
                           │
                    ┌──────┴──────┐
                    │             │
                ┌───▼───┐    ┌────▼────┐    ┌───────────┐
                │Directo│    │ Omniva  │    │LHV Connect│
                └───────┘    └─────────┘    └───────────┘
```

### Communication
- **REST API** - all service-to-service interactions
- **Webhooks** - callbacks from EveryPay for payment status updates
- **Background Jobs** - asynchronous processing for integrations

## Requirements

### System Requirements
- Ruby 3.4.10
- PostgreSQL 12+
- Redis 5+
- Docker & Docker Compose (for development)

### For PDF Generation
- wkhtmltopdf

## Installation and Setup

### Docker (recommended for development)

1. Clone the repository:
```bash
git clone <repository-url>
cd eis_billing_system
```

2. Copy configuration examples:
```bash
cp config/application.yml.sample config/application.yml
```

3. Start the application via Docker:
```bash
docker-compose up
```

4. Create the database:
```bash
docker-compose exec app rails db:create db:migrate
```

### Local Installation (alternative)

1. Install dependencies:
```bash
bundle install
```

2. Setup the database:
```bash
rails db:create
rails db:migrate
rails db:seed
```

3. Start the server:
```bash
rails server
```

## Configuration

### Main Settings (config/application.yml)

#### Base Service URLs
```yaml
base_registry: "http://registry:3000"
base_auction: "http://auction_center:3000"
base_eeid: "http://eeid:3000"

# Callback URLs for payment status updates
registry_update_payment_url: "http://registry:3000/eis_billing/payment_status"
auction_update_payment_url: "http://auction_center:3000/eis_billing/payment_status"
eeid_update_payment_url: "http://eeid:3000/eis_billing/payment_status"
```

#### EveryPay Configuration
```yaml
everypay_key: "your_api_key"
everypay_base: "https://igw-demo.every-pay.com/api/v4"
linkpay_prefix: "https://igw-demo.every-pay.com/lp"
linkpay_token: "your_linkpay_token"
api_username: "your_username"
account_name: "your_account"
```

#### Directo Configuration
```yaml
directo_invoice_url: "https://your-directo-instance.com/api/invoice.asp"
```

#### LHV Connect Configuration
```yaml
lhv_keystore: "./eestiInternetiSa/eestiInternetiSa.p12"
lhv_keystore_password: "your_password"
lhv_keystore_alias: "your_alias"
lhv_ca_file: "path/to/ca/file" # development only
lhv_dev_mode: "true" # for development
```

#### E-Invoice (Omniva) Configuration
```yaml
e_invoice_provider_test_mode: "true" # for testing
```

#### EEID (Authentication)
```yaml
development:
  allowed_base_urls: "https://registry.test, https://auction_center.test, https://eeid.test"
  tara_redirect_uri: "https://eis_billing_system.test/auth/tara/callback"
  tara_identifier: "your_client_id"
  tara_secret: "your_client_secret"
```

#### Deposit Number Range
```yaml
deposit_min_num: "10001"
deposit_max_num: "14001"
```

### Email Configuration
```yaml
smtp_address: "smtp.example.com"
smtp_port: "587"
smtp_user_name: "your_username"
smtp_password: "your_password"
smtp_domain: "example.com"
smtp_authentication: "plain"
action_mailer_default_from: "no-reply@example.com"
```

## Integrations

### 1. EveryPay

**Purpose**: Online payment processing

**Functionality**:
- **Linkpay** - payment link generation for embedding in PDF/Email
- **One-off payments** - single payments for account top-ups and invoice payments
- **Refunds** - refund processing for auction deposits
- **Webhooks** - payment status update notifications

**Endpoints**:
- `POST /api/v1/invoice_generator/invoice_generator` - create linkpay link
- `POST /api/v1/invoice_generator/oneoff` - create one-off payment
- `GET /api/v1/callback_handler/callback` - webhook for EveryPay updates

**Webhook Events** (event_name):
- `status_updated` - payment status updated
- `refunded` - refund completed
- `voided` - payment cancelled
- `chargebacked` - chargeback initiated
- `abandoned` - payment failed

### 2. Directo

**Purpose**: Accounting system integration

**Functionality**:
- Invoice forwarding to accounting
- Payment data synchronization
- Background processing via `DirectoInvoiceForwardJob`

**Endpoints**:
- `POST /api/v1/directo/directo` - forward invoice to Directo

**Data Schema**:
Invoices contain `in_directo` (boolean) and `directo_data` (jsonb) fields for synchronization status tracking.

### 3. E-Invoice (Omniva)

**Purpose**: Electronic invoice delivery

**Functionality**:
- E-invoice delivery via Omniva operator
- Background processing via `SendEInvoiceJob` and `EInvoiceResponseSenderJob`
- Delivery time tracking in `sent_at_omniva` field

**Endpoints**:
- `POST /api/v1/e_invoice/e_invoice` - send e-invoice

### 4. LHV Connect

**Purpose**: Automatic bank transaction detection

**Functionality**:
- Automatic matching of incoming payments with invoices
- Processing via `PaymentLhvConnectJob`
- Certificate-based secure connection

**Technical Details**:
- Keystore: PKCS12 format (.p12)
- CA certificate support for validation
- Dev mode for testing without real transactions

### 5. EEID Integration

**Purpose**: Administrator authentication

**Functionality**:
- OAuth2 authentication via EEID (wrapper over TARA)
- User session management
- White-list access codes

**Endpoints**:
- `GET /auth/tara/callback` - OAuth callback
- `DELETE /logout` - session termination

**Models**:
- `User` - system administrators
- `AppSession` - active sessions
- `WhiteCode` - access codes

### 6. Montonio (payment links with an expiry date)

**Purpose**: Payment links for **auction** invoices that stop accepting payments at the invoice due date

**Why**: EveryPay LinkPay links never expire (the expiry can only be set by hand in the EveryPay
dashboard), so an auction invoice could still be paid long after it was due. Montonio payment links
accept an `expiresAt` timestamp, so the link dies at the end of the due date in Estonian time
(`Europe/Tallinn`): a due date of `2026-07-09` means `2026-07-09T23:59:59+03:00` (`2026-07-09T20:59:59Z`).

**Scope**: Montonio is used **only** for the payment link of invoices whose initiator is `auction`
and that carry a `due_date`. Every other initiator (registry, eeid, business_registry,
billing_system), all one-off payments, bulk payments, auction deposits and refunds keep using
EveryPay exactly as before. **EveryPay LinkPay is also the fallback**: if Montonio is not configured
or the API call fails, the invoice gets the EveryPay link (without an expiry), the failure is logged
at `error` level and `payment_link_provider` stays `everypay`, so the fallback rate can be queried
from the database.

**Prerequisites**:
- Payment links must be **activated for the Montonio store** - this is a separate feature with its
  own monthly fee, ask Montonio support to enable it.
- The webhook url (`montonio_notification_url`) must be **publicly reachable**, and Montonio's
  webhook source IPs **35.156.245.42** and **35.156.159.169** must be allowlisted in the firewall.
- Sandbox and production are separate stores with **separate key pairs**; using a production access
  key against the sandbox base url (or the other way around) answers `401 STORE_NOT_FOUND`.

**Configuration** (`config/application.yml`):
```yaml
# Sandbox: https://sandbox-stargate.montonio.com/api
# Production: https://stargate.montonio.com/api
montonio_base: 'https://sandbox-stargate.montonio.com/api'
montonio_access_key: ''   # store Access Key from the Montonio partner system
montonio_secret_key: ''   # store Secret Key, used to sign and verify the JWTs
montonio_notification_url: 'https://billing.example.com/api/v1/callback_handler/montonio'
```
Montonio is considered configured only when **both** the access key and the secret key are present.

**Endpoints**:
- `POST /api/v1/invoice_generator/invoice_generator` - creates the Montonio link for auction
  invoices with a `due_date` (see the API documentation section below)
- `POST /api/v1/callback_handler/montonio` - webhook for Montonio payment notifications

**Webhook** (`POST /api/v1/callback_handler/montonio`):

Montonio sends `{"orderToken": "<JWT>"}` (or `{"refundToken": "<JWT>"}` for refunds). There is no
Bearer token - the request is trusted because the JWT is signed (HS256) with our Montonio secret key
and carries our `accessKey`. The invoice is found by the stored payment link uuid
(`paymentLinkUuid` -> `invoices.payment_link_uuid`).

```json
{
  "uuid": "montonio-order-uuid",
  "accessKey": "...",
  "paymentStatus": "PAID",
  "grandTotal": 100.0,
  "currency": "EUR",
  "paymentLinkUuid": "montonio-payment-link-uuid"
}
```

| Situation | Invoice | Response |
| --- | --- | --- |
| `PAID`, amount and currency match | marked paid, `payment_reference` = Montonio order uuid, auction notified | 200 |
| same order uuid delivered again | untouched (idempotent) | 200 |
| `PAID` but amount/currency differ | untouched, discrepancy stored in `linkpay_info`, administrators notified | 200 |
| another order uuid for an already paid invoice | untouched, possible double payment reported to administrators | 200 |
| `PENDING`, `ABANDONED`, `AUTHORIZED` | untouched | 200 |
| `VOIDED`, `REFUNDED`, `PARTIALLY_REFUNDED` | untouched, administrators notified for manual handling | 200 |
| `refundToken` body | untouched, logged | 200 |
| unverifiable order token | untouched | 401 |
| unknown `paymentLinkUuid` | - | 404 |

Everything that is not a broken token or an unknown link answers 200 on purpose: Montonio retries a
failed delivery for 48 hours.

**Notification to the auction**: when the invoice is marked as paid, the usual
`PUT /eis_billing/payment_status` request is sent with `"payment_provider": "montonio"` and
`"payment_reference"` set to the Montonio order uuid.

## API Documentation

### Online Documentation

📚 **[View API Documentation on GitHub Pages](https://internetee.github.io/eis_billing_system/)**

The complete API documentation is automatically generated and published to GitHub Pages on every push to the main branch.

### Interactive Documentation (Local)

The system uses [Apipie](https://github.com/Apipie/apipie-rails) for interactive API documentation generation.

**Local Access**: `http://localhost:3000/apipie` (when running the application)

**Authentication** (for local documentation viewing):
```yaml
apipie_login: test
apipie_password: test
```

### Generating Static Documentation

To generate static HTML documentation locally:

```bash
bundle exec rake apipie:static
```

Generated files will be available in `public/apipie/`

### Main API Endpoints

#### Invoice Generation

**POST /api/v1/invoice_generator/invoice_generator**

Create the payment link for an invoice

```json
{
  "transaction_amount": "100.00",
  "reference_number": "RF123456",
  "order_reference": "Account #12345",
  "customer_name": "John Doe",
  "customer_email": "john@example.com",
  "custom_field_1": "Domain renewal",
  "custom_field2": "registry",
  "linkpay_token": "generated_token",
  "invoice_number": "INV-2025-001",
  "due_date": "2026-07-09",
  "return_url": "https://auction.example.com/invoices/1",
  "locale": "et"
}
```

Optional parameters:
- `due_date` (`YYYY-MM-DD`) - invoice due date. For **auction** invoices the payment link is created
  in Montonio and expires at the end of that day in Estonian time. An unparsable value answers `422`.
- `return_url` - where Montonio redirects the payer after the payment.
- `locale` - language of the Montonio payment page (`de`, `en`, `et`, `fi`, `lt`, `lv`, `pl`, `ru`),
  defaults to `en`.

**Response**:
```json
{
  "message": "Link created",
  "everypay_link": "https://pay.every-pay.eu/...",
  "payment_link": "https://pay.montonio.com/<uuid>",
  "payment_link_provider": "montonio",
  "payment_link_expires_at": "2026-07-09T20:59:59Z"
}
```

`everypay_link` is always the EveryPay LinkPay link, exactly as before. `payment_link` is what the
payer should use: the Montonio link for auction invoices with a due date, otherwise (and whenever
Montonio is unavailable) the same value as `everypay_link`, with `payment_link_provider` set to
`everypay` and `payment_link_expires_at` `null`.

#### One-off Payment

**POST /api/v1/invoice_generator/oneoff**

Create a one-off payment

```json
{
  "transaction_amount": "50.00",
  "customer_url": "https://registry.test/payment/callback",
  "description": "Account top-up",
  "custom_field2": "registry"
}
```

#### Bulk Payment (Auction only)

**POST /api/v1/invoice_generator/bulk_payment**

```json
{
  "transaction_amount": "500.00",
  "customer_url": "https://auction.test/payment/callback",
  "description": "Multiple domain deposits",
  "custom_field2": "auction"
}
```

#### Refund

**POST /api/v1/refund/auction**

```json
{
  "params": {
    "invoice_number": "INV-2025-001"
  }
}
```

#### Invoice Status

**POST /api/v1/invoice_generator/invoice_status**

Get invoice status by number

#### Data Import

**POST /api/v1/import_data/invoice_data**

Import invoice data from external systems

**POST /api/v1/import_data/reference_data**

Import reference data (reference numbers)

#### Synchronization

**PATCH /api/v1/invoice/invoice_synchronize**

Synchronize invoice status with external system

## Invoice Types

### 1. Regular

**Purpose**: Standard payments

**Usage**:
- Account top-ups
- Invoice payments
- Typically used with one-off payment

**Characteristics**:
- `affiliation: :regular`
- Does not support refunds
- Used by all services (Registry, Auction, EEID)

### 2. Auction Deposit

**Purpose**: Auction participation deposits

**Usage**:
- Fund blocking for auction participation
- Refunds for unsuccessful bidders

**Characteristics**:
- `affiliation: :auction_deposit`
- **Supports refunds** via EveryPay
- Used only by Auction service
- Special invoice number range (10001-14001)

**Refund process**:
```ruby
# Check if refund is possible
invoice.auction_deposit_prepayment? # => true

# API for refund
POST /api/v1/refund/auction
{
  "params": {
    "invoice_number": "10523"
  }
}
```

### 3. Linkpay

**Purpose**: Embeddable payment links

**Usage**:
- Links for PDF invoices
- Links in email notifications
- Payment via link with payment method selection

**Characteristics**:
- `affiliation: :linkpay`
- Stores additional information in `linkpay_info` (jsonb)
- Used by all services

**Additional data**:
```json
{
  "linkpay_info": {
    "link": "https://pay.every-pay.eu/...",
    "token": "...",
    "created_at": "2025-01-01T12:00:00Z"
  }
}
```

## Deployment

### Docker Environments

#### Development
```bash
docker-compose up
```

#### Staging
```bash
docker-compose -f docker-compose.staging.yml up
```

### AWS Production Deployment

System is deployed on AWS using Docker.

**Deployment process**:

1. **Capistrano** - deployment automation
2. **GitHub Actions** - CI/CD pipeline
3. **rbenv** - Ruby version management
4. **Passenger** - application server in production

**Running deployment**:
```bash
# Staging
cap staging deploy

# Production
cap production deploy
```

### Environments

The system supports three environments:
- **development** - local development (Docker)
- **staging** - testing environment (AWS + Docker)
- **production** - production environment (AWS + Docker)

### Environment Variables

Ensure these are configured in each environment:
- Database (DATABASE_URL)
- Redis (REDIS_URL)
- Secret keys (SECRET_KEY_BASE)
- External service API keys
- SMTP settings

## Testing

### Running Tests

```bash
# All tests
bundle exec rspec

# Specific file
bundle exec rspec spec/models/invoice_spec.rb

# Specific test
bundle exec rspec spec/models/invoice_spec.rb:15
```

### Test Coverage

Project uses SimpleCov for test coverage measurement.

```bash
# Run tests with coverage report
COVERAGE=true bundle exec rspec

# Report available in coverage/index.html
open coverage/index.html
```

### Testing Tools

- **RSpec** - testing framework
- **FactoryBot** - test data factories
- **Faker** - test data generation
- **WebMock** - HTTP request mocking
- **Selenium/Webdriver** - integration tests
- **DatabaseCleaner** - database cleanup between tests

### Linters and Security Checks

```bash
# RuboCop - code style
bundle exec rubocop

# Brakeman - security scanning
bundle exec brakeman

# Bundle Audit - dependency vulnerabilities
bundle exec bundle-audit check --update
```

## Development

### Project Structure

```
app/
├── controllers/
│   ├── api/v1/              # API endpoints
│   │   ├── invoice_generator/
│   │   ├── callback_handler/
│   │   ├── e_invoice/
│   │   ├── directo/
│   │   └── refund/
│   ├── dashboards/          # Admin UI
│   └── invoice_details/     # Invoice details
├── models/
│   ├── invoice.rb           # Main invoice model
│   ├── reference.rb         # Reference numbers
│   ├── user.rb              # Administrators
│   └── white_code.rb        # Access codes
├── jobs/
│   ├── directo_invoice_forward_job.rb
│   ├── send_e_invoice_job.rb
│   ├── payment_lhv_connect_job.rb
│   └── save_invoice_data_job.rb
├── contracts/               # Parameter validation (dry-validation)
├── mailers/                 # Email notifications
└── services/                # Business logic
```

### Database Schema

**Invoices** (main table):
- `invoice_number` - unique invoice number
- `initiator` - source (registry/auction/eeid/billing_system)
- `payment_reference` - payment reference (EveryPay reference or Montonio order uuid)
- `transaction_amount` - payment amount
- `status` - status (unpaid/paid/cancelled/failed/refunded/overdue)
- `affiliation` - type (regular/auction_deposit/linkpay)
- `everypay_response` - EveryPay response (jsonb)
- `directo_data` - Directo data (jsonb)
- `linkpay_info` - linkpay data (jsonb), also holds the Montonio link, the processed Montonio orders
  (`montonio_orders`, used for webhook idempotency) and any payment discrepancies
  (`montonio_discrepancies`)
- `due_date` - invoice due date, the payment link expires at the end of that day in Estonian time
- `payment_link` - the payment link handed to the payer
- `payment_link_uuid` - Montonio payment link uuid (unique), used to find the invoice from a webhook
- `payment_link_provider` - `montonio` or `everypay`
- `in_directo` - sent to Directo flag
- `transaction_time` - transaction timestamp
- `sent_at_omniva` - Omniva delivery timestamp

**References**:
- `reference_number` - payment reference
- `initiator` - source
- `owner` - owner
- `email` - owner email

### Background Jobs

All integrations with external services are processed asynchronously:

```ruby
# Directo
DirectoInvoiceForwardJob.perform_later(invoice_id)

# E-Invoice
SendEInvoiceJob.perform_later(invoice_id)

# LHV Connect
PaymentLhvConnectJob.perform_later

# Data saving
SaveInvoiceDataJob.perform_later(invoice_data)
SaveReferenceDataJob.perform_later(reference_data)
```

### Useful Commands

```bash
# Rails console
rails console

# Database console
rails dbconsole

# Routes
rails routes | grep invoice

# Clear logs
rails log:clear

# Migration status
rails db:migrate:status
```

### Logging

Logs are available in:
- `log/development.log`
- `log/staging.log`
- `log/production.log`

### Debugging

```ruby
# Use byebug in code
def some_method
  byebug  # debugger will stop here
  # your code
end
```

## Support

### Code Quality Monitoring

- **Maintainability**: [![Maintainability](https://qlty.sh/gh/internetee/projects/eis_billing_system/maintainability.svg)](https://qlty.sh/gh/internetee/projects/eis_billing_system)
- **Code Coverage**: [![Code Coverage](https://qlty.sh/gh/internetee/projects/eis_billing_system/coverage.svg)](https://qlty.sh/gh/internetee/projects/eis_billing_system)

### CI/CD

GitHub Actions are configured for:
- Automated test runs
- Code style checks (RuboCop)
- Security scanning (Brakeman)
- Dependency checks (Bundle Audit)

### Renovate

Automated dependency updates are configured via Renovate (see `renovate.json`)
