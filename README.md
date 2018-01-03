# Actionable [![Build Status](https://travis-ci.org/acima-credit/actionable.svg?branch=master)](https://travis-ci.org/simple-finance/actionable)

## Simple and effective Ruby service objects. 
Actionable actions encapsulate business logic in a composable way that makes it easy to change when requirements change.  
It draws inspiration heavily in Trailblazer's [Operation](http://trailblazer.to/gems/operation/2.0/index.html)s alhtough 
it has a much smaller and simple scope. Still it provides the means to remove business logic from places like Rails 
controllers and models, Sidekiq processors, etc. into a shared set of actions with defined steps.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'actionable'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install actionable

## Usage
 
Let's look at a simple and contrived example:
 
 ```ruby
class CreateInvoice < Actionable::Action

  set_model :invoice
  
  step :build
  step :validate
  step :create
  
  def initialize(params)
    super()
    @params = params
  end
  
  def build
    @invoice = Invoice.new    
  end
  
  def validate
    validator = InvoiceValidator.new @invoice
    return unless validator.valid?
    
    fail :invalid, 'The invoice was invalid', validator.errors     
  end
  
  def create
    @invoice.save!  
  end
end
```

The basic principle is that once we run an action it will follow through with each step. If no steps declares an early 
success or failure then it will automatically declare success. In any case it will return a result object with some 
 basic properties:
 
 * `code`: either `:success` or some other error code (e.g. `:invalid`).
 * `message`: a human friendly error message (e.g. `The invoice was invalid`).
 * `errors`: a hash containing errors (optional).
 
In the case that any of the steps throws an unguarded exception then processing will stop and the exception will 
bubble up to be dealt with. If you are setting a model (e.g. `set_model :invoice`) then Actionable will wrap the steps
 execution in an `ActiveRecord::Transaction` so that it will all succeed or nothing will be committed to the database.

Following the previous example we could use that action in a controller like so:

```ruby
class CustomerMailerController < ApplicationController
  def create
    result = CreateInvoice.run params
    case result.code
    when :success
      redirect_to invoice_path(result.invoice.id)
    when :invalid
      flash[:error] = result.message
      render :edit  
    end
  end
end
```

Now we have removed all business logic into a simple service object and we can leave the controller to take care of
providing the parameters from the user and redirect traffic depending on the results. Notice that the result also 
contains all `instance variables` created in the process as ready to use methods (e.g. `result.invoice`).
 
Encapsulating all this business logic also makes it easier to add more features when requirements change. Let's say
 that later we find out that we need to send a notification to our customer. We can easily add another step like so:
 
 ```ruby
class CreateInvoice < Actionable::Action

  step :notify
  
  def notify
    CustomerMailer.send_invoice @invoice  
  end
end
```

We know that all these steps will execute successfully or the action will fail.

An action step can also point to another action to run through all of that action's steps. Maybe we already have an action setup to notify customer's via email and text messages. You can pass parameters, such as the @invoice we've already created in an array of symbols, like so `params: %i[invoice]`

```ruby
class CreateInvoice < Actionable::Action

  step NotifyCustomer, params: %i[invoice]
end
```

And here is an example of the `NotifyCustomer` class:

```ruby
class NotifyCustomer < Actionable::Action
  step :email
  step :sms

  def initialize(deliverable)
    super()
    @deliverable = deliverable
  end

  def email
    CustomerMailer.send_email @deliverable
  end

  def sms
    CustomerSmsDeliverer.send_sms @deliverable
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/acima-credit/actionable. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

