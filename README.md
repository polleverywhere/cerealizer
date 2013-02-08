# Cerealizer

Serialize and deserialize data between models and JSON.

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
    "/users/#{object.owner_id}"
  end

  def owner_href=(href)
    _, object.owner_id = href.split('/')
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
```

Now lets use it in some app code! Lets generate some hashes that our app can convert into JSON:

```ruby
user = User.new(:id => 3)
owner = User.new(:id => 12)
fruit = Fruit.new(:owner_id => 12, id: => 8, color: => 'Orange')

FruitSerializer.new(fruit, user).to_hash
# => { :owner_href => '/users/12', href: => '/fruits/8', color: => 'Orange' }

FruitSerializer.new(fruit, owner).to_hash
# => { :owner_href => '/users/12', href: => '/fruits/8', color: => 'Orange', :private_tasting_note => nil }
```

Meh, its OK. Lots of libraries already do this with minimal hacking. That's not why we wrote this lib; what we need is something that can deal with *writing* attributes back into the model.

```ruby
FruitSerializer.new(fruit, user).write_keys(:owner_href => '/users/9000')
# => BOOM! Raise a Key::UnauthorizedWrite exception
```

Now we can implement authorization logic at a key level for our resources. Nifty!

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
