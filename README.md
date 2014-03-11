# Neighborly::Balanced

[![Build Status](https://travis-ci.org/neighborly/neighborly-balanced.png?branch=master)](https://travis-ci.org/neighborly/neighborly-balanced) [![Code Climate](https://codeclimate.com/github/neighborly/neighborly-balanced.png)](https://codeclimate.com/github/neighborly/neighborly-balanced)

## What

This is an integration between [Balanced](https://www.balancedpayments.com/) and [Neighborly](https://github.com/luminopolis/neighborly), a crowdfunding platform.

## How

Include this gem as dependency of your project, adding the following line in your `Gemfile`.

```ruby
# Gemfile
gem 'neighborly-balanced'
```

And install the migrations:

```console
$ bundle exec rake railties:install:migrations db:migrate
```

As you might know, Neighborly has a `Configuration` class, responsible to... project's configuration. You need to set API key secret and Marketplace ID, and you find yours acessing settings of [Balanced Dashboard](https://dashboard.balancedpayments.com/).

```console
$ rails runner "Configuration.create!(name: 'balanced_api_key_secret', value: 'YOUR_API_KEY_SECRET_HERE')"
$ rails runner "Configuration.create!(name: 'balanced_marketplace_id', value: 'YOUR_MARKETPLACE_ID_HERE')"
```

## Running tests

	`bundle exec rspec`

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


# License

Licensed under the [MIT license](LICENSE.txt).