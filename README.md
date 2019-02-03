SolidusInventoryUnitFix
=======================

In vanilla Solidus, ordering x amount of an item will generate x amount of inventory_units. This leads to performance issues when you run a store that regularly sells more than 1000 items in any given order - such as B2B items or small electronic parts. Adding stock is also affected when a product is heavily backordered.

This gem aims to fix that issue by adding a quantity field to inventory_units - instead of an order with 10,000 parts generating 10,000 inventory_units, we'd instead like to generate one inventory unit with a quantity of 10,000.

Please note that this gem is *not* plug-and-play, review the "Potential Issues" section of this readme for more information.

Benchmark
---------

These are sample orders benchmarked without this gem installed, in varying product quantities.

|Quantity|Time To Process(seconds)|
|--------|------------------------|
|10      |1.603510                |
|100     |1.666836                |
|1,000   |5.551059                |
|10,000  |108.885997              |
|100,000 |(longer than 20 minutes)|


These are the same sample orders, but with this gem installed.

|Quantity|Time To Process(seconds)|
|--------|------------------------|
|10      |1.608142                |
|100     |1.171635                |
|1,000   |1.043417                |
|10,000  |1.045235                |
|100,000 |1.149779                |


Installation
------------

Add solidus_inventory_unit_fix to your Gemfile:

```ruby
gem 'solidus_inventory_unit_fix'
```

Bundle your dependencies and run the installation generator:

```shell
bundle
bundle exec rails g solidus_inventory_unit_fix:install
```

Potential Issues
----------------

Because of the large change this gem makes, installing this gem comes at a price: Not everything is going to work well with it.

Old orders will continue to work with this gem - because any check on quantity for the inventory unit is done with sum(&:quantity), and inventory_units are given a default quantity of 1.

What doesn't work:
The returns and refunds system does not work. It's tied very heavily into the idea that the inventory_unit count is 1:1 with quantity, and major changes would be needed for it to work well with the inventory_unit change this gem makes.

Item cancellation does not work - at the moment. I will attempt to address this soon, as it does not seem to need as drastic a change as the returns system needs.

The "solidus_product_assembly" gem overrides many of the models that this gem overrides - if you use both gems, you'll need to create your own override to merge the things both of the gems change.

There may be more gems that this gem does not play nice with - please let me know in an issue if you find any more, so I can update this list.

Testing
-------

First bundle your dependencies, then run `rake`. `rake` will default to building the dummy app if it does not exist, then it will run specs, and [Rubocop](https://github.com/bbatsov/rubocop) static code analysis. The dummy app can be regenerated by using `rake test_app`.

```shell
bundle
bundle exec rake
```

When testing your applications integration with this extension you may use it's factories.
Simply add this require statement to your spec_helper:

```ruby
require 'solidus_inventory_unit_fix/factories'
```

Copyright (c) 2019 Sean Denny, released under the New BSD License
