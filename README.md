middleman-swiftype
==================

## Install
1. Add `gem "middleman-swiftype", :git => "https://github.com/dstaley/middleman-swiftype"` to your `Gemfile` and run `bundle install`.
2. Add `activate :swiftype` to your `config.rb`.

## Usage
At the moment, this only generates a JSON document at your build's root. It doesn't (yet) upload to Swiftype.

By default, all `.html` pages will be added to a `search.json` file at your build's root. You can modify which pages are included by adding a `pages_selector` lambda to your `config.rb`:

```ruby
activate :swiftype do |opts|
  opts.pages_selector = lambda { |p| p.path.match(/\.html/) && p.metadata[:options][:layout] == nil }
end
```

You can also manually generate a JSON file with the following:
```
bundle exec middleman swiftype
```
which defaults to a `search.json` file in the current working directory. You can manually specify the filename like so:
```
bundle exec middleman swiftype -o swiftype.json
```