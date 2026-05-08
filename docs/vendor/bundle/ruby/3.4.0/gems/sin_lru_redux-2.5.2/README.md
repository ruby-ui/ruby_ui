# SinLruRedux

[![License](https://img.shields.io/github/license/cadenza-tech/sin_lru_redux?label=License&labelColor=343B42&color=blue)](https://github.com/cadenza-tech/sin_lru_redux/blob/main/LICENSE.txt) [![Tag](https://img.shields.io/github/tag/cadenza-tech/sin_lru_redux?label=Tag&logo=github&labelColor=343B42&color=2EBC4F)](https://github.com/cadenza-tech/sin_lru_redux/blob/main/CHANGELOG.md) [![Release](https://github.com/cadenza-tech/sin_lru_redux/actions/workflows/release.yml/badge.svg)](https://github.com/cadenza-tech/sin_lru_redux/actions?query=workflow%3Arelease) [![Test](https://github.com/cadenza-tech/sin_lru_redux/actions/workflows/test.yml/badge.svg)](https://github.com/cadenza-tech/sin_lru_redux/actions?query=workflow%3Atest) [![Lint](https://github.com/cadenza-tech/sin_lru_redux/actions/workflows/lint.yml/badge.svg)](https://github.com/cadenza-tech/sin_lru_redux/actions?query=workflow%3Alint)

Efficient and thread-safe LRU cache

Forked from [LruRedux](https://github.com/SamSaffron/lru_redux).

- [Installation](#installation)
- [Usage](#usage)
- [Cache Methods](#cache-methods)
- [Changelog](#changelog)
- [Contributing](#contributing)
- [License](#license)
- [Code of Conduct](#code-of-conduct)
- [Sponsor](#sponsor)

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add sin_lru_redux
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install sin_lru_redux
```

## Usage

```ruby
require 'lru_redux'

# non thread safe
cache = LruRedux::Cache.new(100)
cache[:a] = '1'
cache[:b] = '2'

cache.to_a
# [[:b, '2'], [:a, '1']]
# note the order matters here, last accessed is first

cache[:a] # a pushed to front
# '1'

cache.to_a
# [[:a, '1'], [:b, '2']]
cache.delete(:a)
cache.each { |key, value| puts "#{key} #{value}"}
# b 2

cache.max_size = 200 # cache now stores 200 items
cache.clear # cache has no items

cache.getset(:a) { 1 }
cache.to_a
#[[:a, 1]]

# already set so don't call block
cache.getset(:a) { 99 }
cache.to_a
#[[:a, 1]]

# for thread safe access, all methods on cache
# are protected with a mutex
cache = LruRedux::ThreadSafeCache.new(100)
```

**TTL Cache**

The TTL cache extends the functionality of the LRU cache with a Time To Live eviction strategy. TTL eviction occurs on every access and takes precedence over LRU eviction, meaning a 'live' value will never be evicted over an expired one.

```ruby
# Timecop is gem that allows us to change Time.now
# and is used for demonstration purposes.
require 'lru_redux'
require 'timecop'

# Create a TTL cache with a size of 100 and TTL of 5 minutes.
# The first argument is the size and
# the second optional argument is the TTL in seconds.
cache = LruRedux::TTL::Cache.new(100, 5 * 60)

Timecop.freeze(Time.now)

cache[:a] = '1'
cache[:b] = '2'

cache.to_a
# => [[:b, '2'], [:a, '1']]

# Now we advance time 5 min 30 sec into the future.
Timecop.freeze(Time.now + ((5 * 60) + 30))

# And we see that the expired values have been evicted.
cache.to_a
# => []

# The TTL can be updated on a live cache using #ttl=.
# Currently cached items will be evicted under the new TTL.
cache[:a] = '1'
cache[:b] = '2'

Timecop.freeze(Time.now + ((5 * 60) + 30))

cache.ttl = 10 * 60

# Since ttl eviction is triggered by access,
# the items are still cached when the ttl is changed and
# are now under the 10 minute TTL.
cache.to_a
# => [[:b, '2'], [:a, '1']]

# TTL eviction can be triggered manually with the #expire method.
Timecop.freeze(Time.now + ((5 * 60) + 30))

cache.expire
cache.to_a
# => []

Timecop.return

# The behavior of a TTL cache with the TTL set to `:none`
# is identical to the LRU cache.

cache = LruRedux::TTL::Cache.new(100, :none)

# The TTL argument is optional and defaults to `:none`.
cache = LruRedux::TTL::Cache.new(100)

# A thread safe version is available.
cache = LruRedux::TTL::ThreadSafeCache.new(100, 5 * 60)
```

## Cache Methods

- `#getset` Takes a key and block.  Will return a value if cached, otherwise will execute the block and cache the resulting value.
- `#fetch` Takes a key and optional block.  Will return a value if cached, otherwise will execute the block and return the resulting value or return nil if no block is provided.
- `#[]` Takes a key.  Will return a value if cached, otherwise nil.
- `#[]=` Takes a key and value. Will cache the value under the key.
- `#delete` Takes a key.  Will return the deleted value, otherwise nil.
- `#evict` Alias for `#delete`.
- `#clear` Clears the cache. Returns nil.
- `#each` Takes a block.  Executes the block on each key-value pair in LRU order (most recent first).
- `#each_unsafe` Alias for `#each`.
- `#to_a` Return an array of key-value pairs (arrays) in LRU order (most recent first).
- `#key?` Takes a key.  Returns true if the key is cached, otherwise false.
- `#has_key?` Alias for `#key?`.
- `#count` Return the current number of items stored in the cache.
- `#length` Alias for `#count`.
- `#size` Alias for `#count`.
- `#max_size` Returns the current maximum size of the cache.
- `#max_size=` Takes a positive number.  Changes the current max_size and triggers a resize.  Also triggers TTL eviction on the TTL cache.
- `#ignore_nil` Returns the current ignore nil setting.
- `#ignore_nil=` Takes true or false.  Changes the current ignore nil setting.

**TTL Cache Specific**

- `#ttl` Returns the current TTL of the cache.
- `#ttl=` Takes `:none` or a positive number.  Changes the current ttl and triggers a TTL eviction.
- `#expire` Triggers a TTL eviction.

## Changelog

See [CHANGELOG.md](https://github.com/cadenza-tech/sin_lru_redux/blob/main/CHANGELOG.md).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cadenza-tech/sin_lru_redux. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/cadenza-tech/sin_lru_redux/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://github.com/cadenza-tech/sin_lru_redux/blob/main/LICENSE.txt).

## Code of Conduct

Everyone interacting in the SinLruRedux project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/cadenza-tech/sin_lru_redux/blob/main/CODE_OF_CONDUCT.md).

## Sponsor

You can sponsor this project on [Patreon](https://patreon.com/CadenzaTech).
