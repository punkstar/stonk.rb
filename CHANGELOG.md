## [1.1.0] - 2025-07-23

### Data Sources
- **CoinGecko adapter** - Cryptocurrency price data via CoinGecko API
  - Support for .CRYPTO suffix format (e.g., BTC.CRYPTO)

## [1.0.0] - 2025-07-22

### Core Features
- **Fallback strategy** - automatically tries multiple adapters if one fails
- **Built-in caching** with file-based cache adapter to reduce API calls
- **Rate limiting support** with configurable retry logic
- **Comprehensive error handling** for various failure scenarios

### Data Sources
- **Alpha Vantage adapter** - Premium stock data via RapidAPI
  - Configurable retry logic for rate limits
  - API key-based authentication
  - JSON response parsing

### Caching System
- **File cache adapter** for local storage of stock prices
  - JSON-based cache file format
  - Automatic cache file creation and management
  - Cache clearing functionality

### Core Classes
- **Stonk::Service** - Main service class for orchestrating adapters
- **Stonk::Money** - BigDecimal-based money class for precise price handling
- **Stonk::Adapter** - Base adapter module with common error classes
  - StockNotFound, RateLimitExceeded, ServerError exceptions

### Developer Experience
- **Comprehensive test suite** with Minitest
  - Unit tests for all adapters and core classes
  - VCR cassettes for API response testing
  - Fixtures for reliable test data
- **Logging support** with configurable log levels via STONK_LOG_LEVEL
- **Ruby 3.1+ compatibility** with modern Ruby features
- **MIT license** for open source use
- **Gem signing** with 1Password integration

### Error Handling
- Graceful handling of network failures
- Rate limit detection and retry mechanisms
- Stock symbol validation and not-found scenarios
- Server error classification and reporting
