# MoneyBadger

A plugin to handle currency and foreign exchange.

Keeps things accurate and avoids floating point errors.

A money object consists of three attributes :

* @value - an integer which represent the amount without a decimal place
* @precision - an integer which sets where the decimal place is
* @currency - a string which stores the ISO currency code ie "USD", "GBP", "CAD" or "EUR"

## Requirements

Hpricot Gem : http://github.com/hpricot/hpricot

## Installation

The money gem provide an ActiveRecord Extension :

    has_money(name, options = {})

Place in your model to enable money. Store money in an integer field which defaults to "name_value".
has_money provides reader writer methods.

Options are :

* :currency  - specify a proc to determine the currency ie Proc.new{|object| object.currency}. The default is to look for a 'currency' instance method in the model has_money is inserted into.
* :precision - specify a precision to save the currency to.  If you are doing divisions, multiplications or cumulative totals you might like to specify a higher precision. Defaults to 2.
* :field_name - specify the name of the integer field to store the value in.

Examples :

    class Item < ActiveRecord::Base
      belongs_to :country
      
      has_money :total, 
                :precision => 3, 
                :field_name => :total_money, 
                :currency => Proc.new{|item| item.country.currency}
    end

or

    class Country < ActiveRecord::Base
      has_many :items
      def currency
        "USD"
      end
    end

## Use it !

    i = Item.new
    i.total.to_f #=> 0.000
    i.total = Money.new(500)
    i.total.to_f #=> 5.000
    i.total.format #=> "$5.00"


### Basics

    m = Money.new(500, "USD")
    m.value #=> 500
    m.to_f #=> 5.00
    m.to_s #=> "5.00"
    m.in_cents #=> 500
    m.format #=> "$5.00"
    
    n = "GBP 10.50".to_money
    n.value #=> 1050
    n.to_f #=> 10.50
    n.to_s #=> "10.50"
    n.format #=> "£10.50"
    
    o = 15.to_money
    o.to_f #=> 15.00
    o.to_s #=> "15.00"
    o.format #=> "$15.00"

### Arithmetic

    (m + o).format #=> "$20.00"
    
    (o - m).format #=> "$10.00"
    
    (m * 4 ).format #=> "$20.00"

### Currency conversion

Money has a bank object.
Currency rates are relative to the Euro
Currency rates are looked up form the European exchange bank
You can set a commission over the mid market rates given by the bank

    n.bank #=> Bank
    n.bank.rates #=> {"USD" => 1.34, "GBP" => 0.85, "EUR" => 1.00}
    n.bank.commission = 0.05 # set the commission to 5%
    
    n.exchange_to("USD").format => # "$17.24"
    
    (m + n ).format => # "$22.24"

### Advanced use

Can add a precision option. This is the third option in the new() method or the :precision => () option in the .to_money method.
The precision option allows you to keep the calculations accurate when dividing and multiplying.
The precision of a sum automatically changes to keep the most precise result.

    a = Money.new(50000, "USD", 4)
    a.value #=> 50000
    a.to_f #=> 5.0000
    a.in_cents #=> 500
    a.in_dollars #=> 5
    a.format #=> "$5.00"
    
    b = Money.new(56789, "USD", 5)
    b.value #=> 56789
    b.to_f #=> 0.56789
    b.format #=> "$0.57"
    (a + b).format #=> "$5.57"
    
    c = 5.02341.to_money(:currency => "GBP")
    c.value #=> 502341
    c.precision #=> 5
    c.format #=> "£5.02"
    (c * 3).to_f #=> 15.07023
    
    (a + c).format #=> "$12.56"


Copyright (c) 2010 completelynovel.com, released under the MIT license