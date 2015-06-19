# Tradesman

Tradesman lets you invoke human-readble classes that handle the pass, fail, and invalid cases of common create, update, and delete actions without having to write the code!

## Usage

```ruby
# Simple - Returns a successful Outcome
outcome = Tradesman::CreateUser.go(user_params)
outcome.success? #=> true
outcome.failure? #=> false
outcome.result #=> User Entity

# With invalid parameters - returns an invalid Outcome
outcome = Tradesman::CreateUser.go(invalid_user_params)
outcome.success? #=> false
outcome.failure? #=> true
outcome.result #=> Error Class
outcome.type #=> :validation

# With invalid parameters - fail loudly!
outcome = Tradesman::CreateUser.go!(invalid_user_params) #=> raises Tradesman::Invalid or Tradesman::Failure

# Passing a block - Well-suited for Controllers
Tradesman::UpdateUser.go(params[:id], user_update_params) do
  success do |result|
    render(text: 'true', status: 200)
  end

  invalid do |error|
    render(text: 'false', status: 404)
  end

  failure do |error|
    render(text: 'false', status: 400)
  end
end

# Delete
Tradesman::DeleteUser.go(params[:id])

# Create as a child of an existing record
Tradesman::CreateUserForEmployer.go(employer, user_params)

# Create multiple records
Tradesman::CreateUser.go([user_params, user_params, user_params])

# Create multiple for a single parent
Tradesman::CreateUserForEmployer.go(employer, [user_params, user_params, user_params])

# Update multiple records with 1 set of parameters
Tradesman::UpdateUser.go([user1, user2, user3], update_params)

# Update n records with n sets of parameters
# Whenever you pass an id, you can either pass the id itself,
# or an object that response to :id
update_params = {
  user1.id => user1_params,
  user2.id => user2_params,
  user3.id => user3_params
}
Tradesman::UpdateUser.go(update_params.keys, update_params.values)


# Delete multiple records
Tradesman::DeleteUser.go([id1, id2, id3])
```

## Parsing Rules

Classes have the following structure:

`Method` + `Record`

```ruby
# Examples:
CreateUser
UpdateEmployer
DeleteBlogPost
```

Where **Method** is one of `Create`, `Update`, or `Delete`, and **Record** is your model classname, CamelCased.
Note that model namespaces are ignored.

The only exception is when you create a record for a parent. These classes have the following structure:

`Method` + `Record` + `'For'` + `ParentRecord`

```ruby
# Examples
CreateUserForEmployer
CreateInvoiceForCustomer
```

Where 'For' is a string literal and **ParentRecord** is the parent model classname, CamelCased.


## Why is this necessary?

At Onfido, we observed that many Create, Update and Delete actions we programmed were are simple and repeated (albeit with different records and parameter lists) in several locations. They can generally be broken in to the following steps:

- Query existing record by some group of parameters, but generally just by :id (Update and Delete only)
- Return 404 if record does not exist
- Update or Create a new record with a given set of parameters. For Deletion, no parameters are required.
- Return a success, invalid, or failure message based on the result of this persistence action.

Example:
```ruby
# users_controller.rb
def update
  @user = User.find(params[:id])
  return render(text: 'false', status: 404) unless @user

  @user.assign_attributes(user_params)
  return render(text: 'false', status: 422) unless @user.save

  render 'user'
end

private

def user_params
  params.permit(:first_name, :last_name, :email)
end
```

Yes, the above example is trivial, but many such trivial actions are necessary in web applications.
Tradesman is designed to handle the above and a few other common use-cases to reduce such tedious, often-repeated boilerplate code.

Tradesman version of the above:
```ruby
Tradesman::UpdateUser.go(user_id, user_params) do
  success do |result|
    @user = result
    render 'user'
  end

  invalid do |error|
    render(text: error.message, status: 422)
  end

  failure { |result| render(text: 'false', status: 400) } # If you prefer one-liners
end

private

def user_params
  params.permit(:first_name, :last_name, :email)
end
```

The Tradesman version says exactly what it does, is cruft free, and is much quicker to test (more on that later).

## Config

**Define your adapter**

```ruby
# config/initializers/tradesman.rb
Tradesman.configure { |config| config.adapter = :active_record }
```

**Development Mode and Model Namespaces**

Rails' lazy-loading in the development environment makes a bit more configuration necessary, particularly if you have wrapped your models in namespaces.

Consider:
```ruby
module MyNamespace
  class Employer < ActiveRecord::Base
    has_many :users
  end
end

module MyOtherNamespace
  class User < ActiveRecord::Base
    belongs_to :employer
  end
end
```

In order to help Tradesman lazy load these models, you need to enable development mode and configure any namespaces:

```ruby
# config/initializers/tradesman.rb
Tradesman.configure do |config|
  config.adapter = :active_record
  config.development_mode = Rails.env.development?
  config.namespaces = [MyNamespace, MyOtherNamespace]
end
```

**Reset Tradesman** _(Can be done at runtime or in tests)_
```ruby
Tradesman.reset
```

## Adapters

Tradesman sits on top of [Horza](https://github.com/onfido/horza/), and can use any of its adapters.

## Edge Cases

**Models ending with double 's'**

Some models end with a double 's', ie `Address`, `Business`. Rails has a well documented inability to properly inflect this type of word.
There is a simple fix:

```ruby
# config/initializers/inflections.rb
ActiveSupport::Inflector.inflections do |inflect|
  inflect.singular(/ess$/i, 'ess')
end
```
