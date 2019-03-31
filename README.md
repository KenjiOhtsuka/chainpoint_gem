# Chainpoint

[![Build Status](https://travis-ci.org/KenjiOhtsuka/chainpoint_gem.svg?branch=master)](https://travis-ci.org/KenjiOhtsuka/chainpoint_gem)

[![Gem Version](https://badge.fury.io/rb/chainpoint.svg)](https://badge.fury.io/rb/chainpoint)

[Rubygem Page](https://rubygems.org/gems/chainpoint)

[API Documentation](https://kenjiohtsuka.github.io/chainpoint_gem/)

A client for creating and verifying [Chainpoint](https://chainpoint.org/) proofs.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'chainpoint'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install chainpoint

## Usage

### Initialize new hash object

```ruby
sha256 = '09ca7e4eaa6e8ae9c7d261167129184883644d07dfba7cbfbc4c8a2e08360d5b'
chainpoint_hash = ChainPoint::Hash.new(sha256)
```

`Chainpoint::Hash.from_data` is a convenience method to create a new `Chainpoint::Hash` from raw
data:

```ruby
chainpoint_hash = Chainpoint::Hash.from_data('hello, world')
# => #<Chainpoint::Hash @hash="09ca7e4eaa6e8ae9c7d26116712918...>
```

### Submit Hash

Use this function to submit a hash, and receive back the proof handles needed to later retrieve a
proof.

By default hashes are submitted to three Nodes to help ensure a proof will become available at the appropriate time. Only one such proof need be permanently stored, the others provide redundancy.

```ruby
chainpoint_hash = Chainpoint::Hash.from_data('hello, world')
proof_handles = chainpoint_hash.submit
# =>
[
  {
    'hash_id_node' => '1d1aa8a0-8f42-11e8-967f-01a68adfc010',
    'uri' => 'http://45.77.197.76'
  }
  ...
]

```

### Get Proof

Once a hash has been submitted, it contains proof handles that can be used to retrieve the proof.
It's likely that you will be retrieving proofs at a later time, so it is possible to initialize
a `Chainpoint::Hash` object with proof handle data returned from a previous submit.

A `Chainpoint::Proof` representing the first valid proof will be returned, or `nil` if there is no valid proof.

```ruby
chainpoint_hash = Chainpoint::Hash.new(sha256, proof_handles: proof_handles)
chainpoint_hash.proof

#=> #<Chainpoint::Proof @proof="eJyNk71uFDEx0=...", @hash_id_node="1672f730-...1", @anchors_complete=["cal"]>
```

You may also pass an anchor type to return only proofs matching that type. By default chainpoint
anchors to a Calendar blockchain (`cal`) which usually completes in about 10s and to the Bitcoin blockchain `btc` which usually completes in about 2h.

```ruby
proof = Chainpoint::Hash.new(sha256, proof_handles: proof_handles).proof('btc')
#=> #<Chainpoint::Proof @proof="eJyNk71uFDEx0=...", @hash_id_node="1672f730-...1", @anchors_complete=["cal", "btc"]>
```

### Decode a Proof

A `Chainpoint::Proof` object contains a binary representation of the proof can be converted to JSON to view the Chainpoint JSON Schema:

```ruby
proof.decode
# =>
```

### Verify a Proof

You can verify a proof against each of the blockchains the proof has been anchored to:

```ruby
proof.verify
```

#### Response

```ruby
{
  "proof_index" => 0,
  "hash" => "09ca7e4eaa6e8ae9c7d261167129184883644d07dfba7cbfbc4c8a2e08360d5b",
  "hash_id_node" => "1672f730-536b-11e9-9241-015d8fee1e71",
  "hash_submitted_node_at" => "2019-03-31T04:11:41Z",
  "hash_id_core" => "18456d40-536b-11e9-8c0f-016fe824db22",
  "hash_submitted_core_at" => "2019-03-31T04:11:44Z",
  "anchors" => [
    {
      "branch" => "cal_anchor_branch",
      "type" => "cal",
      "valid" => true,
      "block_id" => "2967333", "block_value" => "74e2b62f68463f53105b65d57c729e5488b7833d6ebb259561b84e43d826c7ea"
    }
  ],
  "status"=>"verified"
}

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on [GitHub chainpoint](https://github.com/KenjiOhtsuka/chainpoint_gem).

## Other

* PHP [Composer Package](https://packagist.org/packages/kenji-otsuka/chainpoint) and its [GitHub Repository](https://github.com/KenjiOhtsuka/chainpoint_php).
