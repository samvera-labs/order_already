# OrderAlready

In the spirit of Browse Everything and Questioning Authority, the Order Already module provides a simple interface for ordering properties that have an indeterminate persistence order (looking at you Fedora Commons and RDF N-Triples).

To do this, OrderAlready takes liberties with the persistence layer's storage of the ordered values; (e.g. we prepend an index and delimiter to each value then at object reification we sort on that index).  You may not feel comfortable with this solution, because Order Already munges your canonical data.  And that's understandable.

However, the other options for sorting is described in the theoretical in the [Portland Common Data Model's Wiki](https://github.com/duraspace/pcdm/wiki#ordering-extension).  This is rather impractical, and non-performant, for attributes of a pcdm::Object, such as their creators, subjects, etc.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add order_already

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install order_already

## Usage

With a plain old Ruby object (PORO):

```ruby
class MyModel
  attr_accessor :author, :subject

  prepend OrderAlready.for(:author, :subject)
end
```

With Samvera Portland Common Data Model (PCDM) object:

```ruby
class GenericWork < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  self.indexer = GenericWorkIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata

  prepend OrderAlready.for(:creator, :contributor)
end
```

As of v0.2.0, the `OrderAlready.for` method takes a `:serializer` keyword.  By default this is the preserve the order of the input serializers.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/scientist-softserv/order_already.
