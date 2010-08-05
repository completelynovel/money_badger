require 'money/bank'
require 'money/core_extensions'

class Money
  include Comparable

  attr_reader :value, :currency, :precision

  class MoneyError < StandardError# :nodoc:
  end

  # Bank lets you exchange the object which is responsible for currency
  # exchange. 
  # The default implementation just throws an exception. However money
  # ships with a variable exchange bank implementation which supports
  # custom excahnge rates:
  @@bank = Bank
  cattr_accessor :bank

  @@default_currency = "USD"
  cattr_accessor :default_currency
  
  @@default_precision = 2
  cattr_accessor :default_precision
  
  # Creates a new money object. 
  #  Money.new(100) 
  def initialize(value = 0, currency = default_currency, precision = 2)
    @value, @currency, @precision = value.to_f.round, currency, precision
  end

  # --------------- Arithmetic -----------------------
  #
  # Can add, subtract, multiply and divide money objects by other money objects
  # Can multiply or divide by money objects or fix_nums
  # Money arithmetic takes currency conversion into account.

  def -@
    Money.new(-value, currency, precision)
  end
  
  def +(other_money)
    return self if other_money.nil? || other_money.value == 0
    (BigDecimal.new(self.to_s) + BigDecimal.new(other_money.exchange_to(currency).to_s)).
    to_f.
    to_money(:currency => currency)
  end

  def -(other_money)
    return self if other_money.nil? || other_money.value == 0
    (BigDecimal.new(self.to_s) - BigDecimal.new(other_money.exchange_to(currency).to_s)).
    to_f.
    to_money(:currency => currency)
  end

  # multiply money by fixnum
  def *(number)
    (BigDecimal.new(self.to_s) * BigDecimal.new(number.to_s)).
    to_f.
    to_money(:currency => currency)
  end

  # divide money by fixnum
  def /(number)
    (BigDecimal.new(self.to_s) / BigDecimal.new(number.to_s)).
    to_f.
    to_money(:currency => currency)
  end
  
  # ------------- Interrogation -----------------------
  
  # Test if the money amount is zero
  def zero?
    value == 0 
  end

  # Do two money objects equal? Only works if both objects are of the same currency
  def eql?(other_money)
    value == other_money.value && currency == other_money.currency
  end

  def <=>(other_money)
    if currency == other_money.currency
      self.in_cents <=> other_money.in_cents
    else
      self.in_cents <=> other_money.exchange_to(currency).in_cents
    end
  end

  # -------------- Formatting ------------------

  # Format the price according to several rules
  def format(options = {})
    options[:precision] ||= 2
    options[:hide_symbol] ||= false
    
    out = ""
    out += self.currency_symbol unless options[:hide_symbol].present?
    out += sprintf("%.#{options[:precision]}f", self.to_f )
  end
  
  def currency_symbol
    Bank.symbol_for(self.currency)
  end

  def in_cents(options = {})
    self.value / 10 ** (self.precision - 2)
  end
  
  def in_dollars
    self.value / 10 ** (self.precision)
  end
  
  def in_precision(precision)
    self.class.new(self.in_cents, self.currency)
  end
  
  # -------------- Class translation -----------

  def to_s
    to_f.to_s
  end
  
  def to_f
    value.to_f / 10 ** precision
  end
  
  # ---------------- Foreign exchange ------------------------

  # Recieve the amount of this money object in another currency   
  def exchange_to(other_currency, options = {})
    self.class.bank.exchange(self, other_currency, options)
  end

end
