# Tradesman

Encapsulate common application behaviour with dynamically generated classes.

Tradesman dynamically generates classes with human-readble names that handle the pass, fail, and invalid results of common create, update, and delete actions.

## Usage

```ruby
# Simple - Returns an Outcome
outcome = Tradesman::CreateUser.run(user_params)
outcome.success? #=> true
outcome.result #=> User Entity

# Passing a block - Well-suited for Controllers
Tradesman::UpdateUser.run(params[:id], user_update_params) do
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
Tradesman::DeleteUser.run(params[:id])

# Or Create as a child of an existing record
Tradesman::CreateUserForEmployer.run(employer_id, user_params)
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
Tradesman::UpdateUser.run(params[:id], user_params) do
  success do |result|
    @user = result
    render 'user'
  end

  invalid do |error|
    render(text: 'false', status: 404)
  end

  failure { |result| render(text: 'false', status: 400) } # If you prefer one-liners
end
```

The Tradesman version says exactly what it does, is cruft free, and is much quicker to test (more on that later).
