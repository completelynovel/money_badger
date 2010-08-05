require 'hpricot'

class Bank
  
  begin
    @@config = YAML.load_file("#{Rails.root}/config/bank.yml") || {}
  rescue
    @@config = {}
  end
  
  ECB_RATES_URL = @@config['xml_url'] || 'http://www.ecb.int/stats/eurofxref/eurofxref-daily.xml'
  EXCHANGE_RATES = {} # can initialise a rates hash with default values here
  @@commission  = @@config['commission'] || 0 # how much to charge above mid-market quoted rates (takes account of banks actual exchange rates)
  @@exchange_rates = @@config['exchange_rates'] || {}
  @@non_tradeable_currencies = @@config['non_tradeable_currencies'] || []
  
  cattr_accessor :exchange_rates
  cattr_accessor :commission
  cattr_accessor :non_tradeable_currencies
  
  def self.rates
    self.update_rates if EXCHANGE_RATES.empty?

    EXCHANGE_RATES 
  end
  
  # Used to exchange a money object between one currency and another
  def self.exchange(money_object, new_currency, options = {})
    #return nil if self.can_convert?(money_object, new_currency)
    
    options[:exclude_commission] ||= false
    if money_object.currency != new_currency
      # find the exchange appropriate exchange rates, convert to big decimal to avoid floating point errors
      old_rate = BigDecimal.new(self.rate_for(money_object.currency).to_s)
      new_rate = BigDecimal.new(self.rate_for(new_currency).to_s)
      # do the calculation -> new currency = new rate / old rate  * amount
      new_amount = money_object * (new_rate / old_rate )
      # add in some commission if appropriate to take into account non mid market rates most sellers achieve
      new_amount = new_amount * (1 + @@commission) unless options[:exclude_commission].present?
      # convert to new money currency 
      new_amount.to_money(:currency => new_currency)
    else
      money_object
    end
  end
  
  # updates the rates constant
  #
  # rates constant is a global var containing a hash 
  def self.update_rates
    clear_rates
    add_currency_rate("EUR", 1)
    
    fetch_rates.each do |currency_rate|
      add_currency_rate(currency_rate[:currency], currency_rate[:rate].to_f)
    end
    add_currency_rates(@@exchange_rates) # add_currency_rates("CREDIT" => 1, "YEN" => 208)
    
    rates
  end
  
  def self.add_currency_rate(currency, rate)
    EXCHANGE_RATES[currency] = rate
  end
  
  def self.add_currency_rates(rates_hash)
    rates_hash.each do |currency, rate|
      EXCHANGE_RATES[currency] = rate
    end
  end
  
  def self.clear_rates
    EXCHANGE_RATES.clear
  end
  
  def self.fetch_rates
    doc = Hpricot.XML(open(ECB_RATES_URL))
    doc.search("gesmes:Envelope/Cube/Cube/Cube")
  end
  
  def self.rate_for(currency)
    if rates[currency].present?
      rates[currency]
    else
      raise Money::MoneyError.new("Bank does not support this money exchange, please add more currency exchange rates.")
    end
  end
  
  def self.symbol_for(currency)
    @@config['currency_symbols'][currency] || "$"
  end
  
  def self.tradeable?(currency)
    return true unless @@non_tradeable_currencies.include?(currency)
  end
  
  def self.can_convert?(money_object, new_currency)
    tradeable?(money_object.currency) || !tradeable?(money_object.currency) && tradeable?(new_currency)
  end
  
end
