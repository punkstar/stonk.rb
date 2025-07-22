# Stonk

A Ruby gem for fetching real-time stock prices from multiple data sources with a unified interface. Stonk provides adapters for popular financial APIs and includes caching capabilities for improved performance.

## Features

- **Caching**: Built-in file-based caching to reduce API calls
- **Fallback Strategy**: Automatically tries multiple adapters if one fails
- **Rate Limiting**: Built-in rate limit handling with retry logic
- **Error Handling**: Comprehensive error handling for various failure scenarios

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'stonk'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install stonk
```

## Usage

### Basic Usage

```ruby
require 'stonk'

# Create a service with lookup adapters and optional cache adapter
cache_adapter = Stonk::Adapter::FileCacheAdapter.new('/tmp/stock_cache.json')
service = Stonk::Service.new(
  lookup_adapters: [
    Stonk::Adapter::AlphaVantageAdapter.new(ENV['ALPHA_VANTAGE_API_KEY'])
  ],
  cache_adapter:
)

# Get stock price (automatically cached if cache_adapter is provided)
price = service.get_stock_price('AAPL')
puts "Apple stock price: $#{price}" if price
```

### Using Individual Adapters

#### Alpha Vantage Adapter

The Alpha Vantage adapter requires an API key from [Alpha Vantage](https://www.alphavantage.co/):

```ruby
require 'stonk'

# Create Alpha Vantage adapter with API key
alpha_adapter = Stonk::Adapter::AlphaVantageAdapter.new(
  ENV['ALPHA_VANTAGE_API_KEY'],
  retry_on_rate_limit: true,
  rate_limit_sleep_seconds: 5
)

# Get stock price
begin
  price = alpha_adapter.get_stock_price('AAPL')
  puts "Apple stock price: $#{price}"
rescue Stonk::Adapter::StockNotFound
  puts "Stock not found"
rescue Stonk::Adapter::RateLimitExceeded
  puts "Rate limit exceeded"
rescue Stonk::Adapter::ServerError => e
  puts "Server error: #{e.message}"
end
```

#### File Cache Adapter

The file cache adapter stores stock prices locally to reduce API calls:

```ruby
require 'stonk'

# Create file cache adapter
cache_adapter = Stonk::Adapter::FileCacheAdapter.new('/tmp/stock_cache.json')

# Set a stock price in cache
cache_adapter.set_stock_price('AAPL', Stonk::Money.new('150.25'))

# Get stock price from cache
begin
  price = cache_adapter.get_stock_price('AAPL')
  puts "Cached Apple stock price: $#{price}"
rescue Stonk::Adapter::StockNotFound
  puts "Stock not found in cache"
end

# Clear the cache
cache_adapter.clear_cache
```

### Advanced Usage with Fallback Strategy

```ruby
require 'stonk'

# Create adapters in order of preference
cache_adapter = Stonk::Adapter::FileCacheAdapter.new('/tmp/stock_cache.json')
alpha_adapter = Stonk::Adapter::AlphaVantageAdapter.new(ENV['ALPHA_VANTAGE_API_KEY'])
alpha_adapter_with_retry = Stonk::Adapter::AlphaVantageAdapter.new(
  ENV['ALPHA_VANTAGE_API_KEY'],
  retry_on_rate_limit: true
)

# Service will try lookup adapters in order until one succeeds, and cache results
service = Stonk::Service.new(
  lookup_adapters: [
    cache_adapter,           # Try looknig up in the cache first
    alpha_adapter            # Then Alpha Vantage
    alpha_adapter_with_retry # Then back to Alpha Vantage with a retry.
  ],
  cache_adapter:             # Cache successful results
)

# Get stock price (will try each lookup adapter until one returns a price, then cache the result)
price = service.get_stock_price('AAPL')
puts "Apple stock price: $#{price}" if price
```

### Working with Money Objects

Stock prices are returned as `Stonk::Money` objects, which are based on `BigDecimal` for precision:

```ruby
require 'stonk'

yahoo_adapter = Stonk::Adapter::YahooFinanceAdapter.new
price = yahoo_adapter.get_stock_price('AAPL')

# Money objects support arithmetic operations
puts "Price: $#{price}"
puts "Price as float: #{price.to_f}"
puts "Price as string: #{price.to_s}"

# You can perform calculations
total_value = price * 100
puts "Value of 100 shares: $#{total_value}"
```

### Error Handling

```ruby
require 'stonk'

service = Stonk::Service.new(
  lookup_adapters: [
    Stonk::Adapter::YahooFinanceAdapter.new
  ]
)

begin
  price = service.get_stock_price('INVALID_SYMBOL')
  puts "Price: $#{price}" if price
rescue Stonk::Adapter::StockNotFound
  puts "Stock symbol not found"
rescue Stonk::Adapter::RateLimitExceeded
  puts "Rate limit exceeded, try again later"
rescue Stonk::Adapter::ServerError => e
  puts "Server error: #{e.message}"
rescue => e
  puts "Unexpected error: #{e.message}"
end
```

### Logging

Stonk includes built-in logging that can be configured via environment variables:

```ruby
# Set log level via environment variable
ENV['STONK_LOG_LEVEL'] = 'DEBUG'

# Or access the logger directly
Stonk.logger.level = Logger::DEBUG
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/punkstar/stonk.rb](https://github.com/punkstar/stonk.rb). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/punkstar/stonk.rb/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Stonk project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/punkstar/stonk.rb/blob/main/CODE_OF_CONDUCT.md).
