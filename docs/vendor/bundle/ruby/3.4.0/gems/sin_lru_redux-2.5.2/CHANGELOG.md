# Changelog

## [2.5.2] - 2025-3-12

- Other: Update summary

## [2.5.1] - 2025-3-5

- Other: Update summary
- Other: Update .rubocop.yml
- Other: Add .editorconfig
- Other Update README.md

## [2.5.0] - 2025-1-17

- New: Add SinLruRedux module compatible with LruRedux module
- Refactor: Improve implementation
- Test: Improve tests
- Other: Improve CI
- Other: Fix README.md

## [2.4.0] - 2025-1-2

- New: Be able to require `sin_lru_redux` instead of `lru_redux`
- Other: Update .rubocop.yml
- Other: Add how to sponsor

## [2.3.0] - 2025-1-1

- New: Add alias method `length` and `size` for `count`
- Refactor: Improve implementation
- Test: Update tests
- Other: Improve README.md

## [2.2.1] - 2024-12-31

- Refactor: Improve implementation
- Test: Improve tests

## [2.2.0] - 2024-12-31

- New: Raise an error when trying to assign nil to max_size, ttl, or ignore_nil
- Fix: Fix a bug where ignore_nil was not updated when ignore_nil was specified as false
- Fix: Fix a bug where items with nil value were deleted when ignore_nil was changed
- Refactor: Improve implementation
- Test: Improve tests
- Other: Improve CI
- Other: Improve documents

## [2.1.0] - 2024-12-30

- New: Set default max_size to 1000
- Fix: Fix a bug where ttl of item was not extended during LruRedux::TTL::Cache#getset, #fetch, and #[] execution
- Fix: Fix a bug where items with nil value were not deleted when ignore_nil was changed
- Refactor: Improve implementation
- Test: Improve tests
- Other: Update .gitignore
- Other: Add bin
- Other: Update Gemfile
- Other: Improve gemspec
- Other: Improve documents

## [2.0.1] - 2024-12-28

- Refactor: Make valid_xxxx? methods private
- Fix: Fix lint CI
- Other: Update gemspec

## [2.0.0] - 2024-12-28

- New: Add ignore_nil argument to cache initialize arguments.  If true, blocks called by getset yielding nil values will be returned but not stored in the cache.
- Fix: Fix LruRedux::TTL::ThreadSafeCache#delete to return deleted value
- Ruby Support: Drop runtime support for Ruby 2.2 and below and JRuby

## [1.1.0] - 2015-3-30

- New: TTL cache added.  This cache is LRU like with the addition of time-based eviction.  Check the Usage -> TTL Cache section in README.md for details.

## [1.0.0] - 2015-3-26

- Ruby Support: Ruby 1.9+ is now required by LruRedux.  If you need to use LruRedux in Ruby 1.8, please specify gem version 0.8.4 in your Gemfile.  v0.8.4 is the last 1.8 compatible release and included a number of fixes and performance improvements for the Ruby 1.8 implementation. @Seberius
- Perf: improve performance in Ruby 2.1+ on the MRI @Seberius

## [0.8.4] - 2015-2-20

- Fix: regression of ThreadSafeCache under JRuby 1.7 @Seberius

## [0.8.3] - 2015-2-20

- Perf: improve ThreadSafeCache performance @Seberius

## [0.8.2] - 2015-2-16

- Perf: use #size instead of #count when checking length @Seberius
- Fix: Cache could grow beyond its size in Ruby 1.8 @Seberius
- Fix: #each could deadlock in Ruby 1.8 @Seberius

## [0.8.1] - 2013-9-7

- Fix #each implementation
- Fix deadlocks with ThreadSafeCache
- Version jump is because its been used in production for quite a while now

## [0.0.6] - 2013-4-23

- Fix bug in getset, overflow was not returning the yeilded val

## [0.0.5] - 2013-4-23

- Added getset and fetch
- Optimised implementation so it 20-30% faster on Ruby 1.9+

## [0.0.4] - 2013-4-23

- Initial version
