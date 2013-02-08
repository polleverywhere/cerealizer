# Cerealizer

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'cerealizer'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cerealizer

## Usage

Want to write a HATOAS API without a bunch of stuff between your model and the serializer? Consider the following code:

```ruby
class FruitSerializer < Cerealizer::Base
  key :owner_href
  hey :href
  key :color
  key :private_tasting_note

  def href
    "/fruits/#{object.id}"
  end

  def href=(href)
    _, object.id = href.split('/')
  end

  def owner_href
    "/users/#{object.id}"
  end

  def owner_href=(href)
    _, object.id = href.split('/')
  end

  # Only the owner of the Fruit can change the owner key or the admin.
  def has_writeable_owner_href?
    object.id == scope.id or scope.is_admin?
  end

  # Only the owner of the fruit can read the private tasting note.
  def has_readable_private_tasting_note?
    object.id == scope.id
  end
end

user = User.new({:id => 3})
owner = User.new({:id => 12})
fruit = Fruit.new({ :owner_id => 12, id: => 8, color: => 'Orange'})

FruitSerializer.new(fruit, user).serializable_hash 
# => { :owner_href => '/users/12', href: => '/fruits/8', color: => 'Orange' }

FruitSerializer.new(fruit, owner).serializable_hash 
# => { :owner_href => '/users/12', href: => '/fruits/8', color: => 'Orange', :private_tasting_note => nil }
```

Nifty eh? More to come!

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
