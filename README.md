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

We can also use case statements in our action steps, called `case_steps`. This will allow us to conditionally execute some steps, just like a case statement does. The second, and optional third, arguments to `on` are just like normal `steps` where you can either pass a symbol or string to call a method, or another `Actionable::Action` class.

```ruby
class ReceiveAchStatus < ::Actionable::Action
  :attr_reader :ach_status

  case_step :ach_status do
    on 'sent', :sent
    on 'settled', :settled
    on %w[returned internally_returned], :returned
  end

  def initialize(ach_status)
    super()
    @ach_status = ach_status
  end

  def sent
  end

  def settled
  end

  def returned
  end
end
```

There are special steps that are only ran if the main steps were successful or if they failed. These are called `success_steps` and `failure_steps`. They work just like any other step, excpet that they are always ran at the end.

```ruby
class CreateInvoice < ::Actionable::Action
  step :build
  step :validate
  step :create

  on_failure :log_failure
  on_failure :build_failure_response
  on_success :build_success_response

  def initialize(params)
    super()
    @params = params
  end

  def build
  end

  def vaidate
  end

  def create
  end

  def log_failure
    logger.warn "failed to create invoice with params: #{@params}"
  end

  def build_failure_response
    @response = {
      status: 'error',
      message: 'failed to create invoice'
    }
  end

  def build_success_response
    @response = {
      status: 'success'
    }
  end
end
```

There are a couple of special methods that can be called to immediately short circuit the execution of the steps if we know that everything was successful or if things failed early. They are `succeed!` and `fail!`. In the following example, we won't get to the `create` step if the amount is missing because we'll fail before then. `succeed!` is going to work the exact same way, it'll just cause the result to have a status of `success` rather than `fail`.

There are also `fail` and `sucess` methods, without the bang. These will not short circuit the execution, but will create either a failure or success object, and continue execution. So, because of this, in the example, if we're missing only the name, but not the amount, we'll still go through and complete creating the invoice, but we'll end up with a failure object letting us know that the name was missing. However, if the amount is missing, we won't go on to actually create the invoice after validation.

```ruby
class CreateInvoice < ::Actionable::Action
  step :build
  step :validate
  step :create

  def initialize(params)
    super()
    @params = params
  end

  def build
  end

  def vaidate
    fail :name_invalid, "Name missing" unless @params[:name].present?
    fail! :amount_location, "Amount missing" unless @params[:amount].present?
  end

  def create
  end
end
```

Any instance variables that get created while running through the steps will be available in the result object in a fixtures attribute. For convenience, there are also methods setup on the result object to call those instance variables directly.

```ruby
class CreateInvoice < ::Actionalbe::Action
  step :build

  def initialize(params)
    super()
    @params = params
  end

  def build
    @invoice = Invoice.new
  end
end
```

```ruby
result = CreateInvoice.run({})
result.params
# => {}
result.invoice
# => #<Invoice invoice_number=1234>
result
# => #<Actionable::Success code=:success, message="Completed successfully.", errors={}, fixtures=["invoice", "params"]>
```

To make testing easier, a couple rspec stubs have been added if you require `actionable/rspec/stubs`. The stubs are `stub_actionable_success`/`allow_actionable_success` and `stub_actionable_failure`/`allow_actionable_failure`.

`stub_actionable_success`/`allow_actionable_success` take the klass and an optional hash of fixtures and will return a success object with the fixtures you specified. `stub_actionable_failure`/`allow_actionable_failure` takes the klass, error_code, optional error_message, and an optional hash of fixtures and will return a failure object with the code, message, and fixtures specified. The stub versions of these run with an expectation that the klass will be called with `run`, while the allow version simply allows it to run if we need it, but isn't required.

```ruby
Rspec.describe CreateInvoice do
  let(:invoice_params) { { amount: 1234.56 } }

  before { allow_actionable_success CreateInvoice, invoice_params: invoice_params }

  context "without errors" do
    let(:result) { CreateInvoice.run(invoice_params) }

    before { expect_actionable_success CreateInvoice, invoice_params: invoice_params }

    it "returns a success object" do
      expect(result.code).to eq(:success)
    end
  end

  context "with errors" do
    let(:invalid_invoice_params) { { amount: nil } }
    let(:result) { CreateInvoice.run(invalid_invoice_params) }

    before { expect_actionable_failure CreateInvoice, :invalid_params, "Amount was invalid", invoice_params: invalid_invoice_params }

    it "returns a failure object" do
      expect(result.code).to eq(:failure)
    end
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

