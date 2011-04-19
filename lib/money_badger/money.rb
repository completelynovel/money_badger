class Money
  attr_reader :value, :currency, :precision

  class MoneyError < StandardError# :nodoc:
  end
  
  @@bank = Bank # a bank object to handle currencies -> see money_badger/bank
  @@default_currency = "USD"
  @@default_precision = 2
  class << self
    def default_currency
      @@default_currency
    end
    
    def default_precision
      @@default_precision
    end
    
    def bank
      @@bank
    end
  end
  
  # == Creates a new money object. 
  #  Money.new(100, "USD", 3)
  #  Money.new(100, :currency => "USD", :precision => 3)
  def initialize(value = 0, *attrs)
    @value      = value.to_f.round
    @currency   = self.class.default_currency
    @precision  = self.class.default_precision
    
    if attrs.length == 1 && attrs.first.is_a?(Hash)
      @currency = attrs.first[:currency]
      @precision = attrs.first[:precision]
    elsif attrs.length == 1 && attrs.is_a?(Array)
      @currency = attrs.first
    elsif attrs.length == 2
      @currency = attrs.first
      @precision = attrs[1]
    end
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
    to_f.to_money(:currency => currency)
  end

  def -(other_money)
    return self if other_money.nil? || other_money.value == 0
    (BigDecimal.new(self.to_s) - BigDecimal.new(other_money.exchange_to(currency).to_s)).
    to_f.to_money(:currency => currency)
  end

  # multiply money by fixnum
  def *(number)
    (BigDecimal.new(self.to_s) * BigDecimal.new(number.to_s)).
    to_f.to_money(:currency => currency)
  end

  # divide money by fixnum
  def /(number)
    (BigDecimal.new(self.to_s) / BigDecimal.new(number.to_s)).
    to_f.to_money(:currency => currency)
  end
  
  def <=(money_or_float)
    BigDecimal.new(self.to_s) <= BigDecimal.new(money_or_float.to_s)
  end
  
  def >=(money_or_float)
    BigDecimal.new(self.to_s) >= BigDecimal.new(money_or_float.to_s)
  end
  
  def <(money_or_float)
    BigDecimal.new(self.to_s) < BigDecimal.new(money_or_float.to_s)
  end
  
  def >(money_or_float)
    BigDecimal.new(self.to_s) > BigDecimal.new(money_or_float.to_s)
  end
  
  # return Boolean true if the value, currency and precision are the same
  def ==(thing)
    if thing.is_a?(Money)
      self.to_f == thing.to_f && self.currency == thing.currency && self.precision == thing.precision
    elsif thing.respond_to?(:to_f)
      self.to_f == thing.to_f
    else
      false
    end
  end
  
  # return Boolean true if the value is the same
  def =~(thing)
    if thing.is_a?(Money)
      self.to_f == thing.to_f && self.currency == thing.currency
    elsif thing.respond_to?(:to_f)
      self.to_f == thing.to_f
    else
      false
    end
  end
  
  # return Boolean true if the value, currency and precision are not the same
  def !=(thing)
    !(self == thing)
  end
  
  # ------------- Interrogation -----------------------
  
  # Test if the money amount is zero
  def zero?
    value == 0 
  end

  # Do two money objects equal? Only works if both objects are of the same currency
  def eql?(other_money)
    self == other_money
  end
  
  # Sort monies by their value
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
    options[:precision] ||= self.class.default_precision
    options[:hide_symbol] ||= false
    
    out = ""
    out += self.currency_symbol unless options[:hide_symbol]
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
    self.class.new(self.in_cents, self.currency, precision)
  end
  
  # -------------- Class translation -----------
  
  def to_f
    self.value.to_f / 10 ** precision
  end

  def to_s
    self.to_f.to_s
  end
  
  def to_i
    self.to_f.to_i
  end
  
  # ---------------- Foreign exchange ------------------------

  # Recieve the amount of this money object in another currency   
  def exchange_to(other_currency, options = {})
    self.class.bank.exchange(self, other_currency, options)
  end

end
