# Tradesman

Encapsulate common application behaviour with dynamically generated classes.

Tradesman dynamically generates classes with human-readble names that handle the pass, fail, and invalid results of common create, update, and delete actions.

## Usage

```ruby
# Simple - Returns an Outcome
outcome = Tradesman::CreateUser.run(user_params)
outcome.success? #=> true
outcome.failure? #=> false
outcome.result #=> User Entity

# With invalid parameters - Returns an Invalid Outcome
outcome = Tradesman::CreateUser.run(invalid_user_params)
outcome.success? #=> false
outcome.failure? #=> true
outcome.result #=> nil
outcome.type #=> :validation

# Passing a block - Well-suited for Controllers
Tradesman::UpdateUser.run({ id: params[:id] }.merge(user_update_params)) do
  success do |result|
    render(text: 'true', status: 200)
  end

  invalid do |error|
    render(text: 'false', status: 404)
  end

  failure do |result|
    render(text: 'false', status: 400)
  end
end

# Can also Delete
Tradesman::DeleteUser.run(id: params[:id])

# Or Create as a child of an existing record
Tradesman::CreateUserForEmployer.run({ parent_id: employer_id }.merge(user_params))
```

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
  return render(text: 'false', status: 400) unless @user.save

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
Tradesman::UpdateUser.run(user_params) do
  success do |result|
    @user = result
    render 'user'
  end

  invalid do |error|
    render(text: 'false', status: 404)
  end

  failure { |result| render(text: 'false', status: 400) } # If you prefer one-liners
end

private

def user_params
  params.permit(:id, :first_name, :last_name)
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
