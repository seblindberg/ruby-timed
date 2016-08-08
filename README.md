# Timed

[![Build Status](https://travis-ci.org/seblindberg/ruby-timed.svg?branch=master)](https://travis-ci.org/seblindberg/ruby-timed)
[![Coverage Status](https://coveralls.io/repos/github/seblindberg/ruby-timed/badge.svg?branch=master)](https://coveralls.io/github/seblindberg/ruby-timed?branch=master)
[![Inline docs](http://inch-ci.org/github/seblindberg/ruby-timed.svg?branch=master)](http://inch-ci.org/github/seblindberg/ruby-timed)

Gem for working with timed, ordered items. Still early days.

The basic building block is the `Timed::Item`. These begin and end somewhere in time and can thus be related to each other. Several items can then be combined into a `Timed::Sequence`. This object guarantees that the items in it are non overlapping and ordered chronologically.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'timed'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install timed

## Usage

```ruby
require 'timed'

# Create an empty
sequence = Timed::Sequence.new

# Add a couple of items. Any object that implements #begin
# and #end can be added. Internally it is converted to a
# Timed::Item.
sequence << 10..20
sequence << 30..40

# Calculate the time occupied by the items in the sequence
sequence.time # => 20
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/timed.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

