# NeighborlyBalanced

## UNDER ACTIVE DEVELOPMENT

This won't work for now. Feel free to follow the project and contribute, but it's not ready for production.

## What

This is an integration between [Balanced](https://www.balancedpayments.com/) and [Neighborly](https://github.com/luminopolis/neighborly), a crowdfunding platform.

## How

Include this gem as dependency of your project, adding the following line in your `Gemfile`.

```ruby
# Gemfile
gem 'neighborly_balanced'
```

NeighborlyBalanced is a Rails Engine, integrating with your (Neighborly) Rails application with very little of effort. To turn the engine on, mount it in an appropriate route:

```ruby
# config/routes.rb
mount NeighborlyBalanced::Engine => '/', as: 'neighborly_balanced'
```

As you might know, Neighborly has a `Configuration` class, responsible to... project's configuration. You find yours acessing settings of [Balanced Dashboard](https://dashboard.balancedpayments.com/).

```console
$ rails runner "Configuration.create!(name: 'balanced_api_key_secret', value: 'YOUR_API_KEY_SECRET_HERE')"
```

**to be continued**
