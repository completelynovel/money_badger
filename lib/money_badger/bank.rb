require 'hpricot'
require 'open-uri'

class Bank
  
  @@config                    = {}
  @@rates_url                 = 'http://www.ecb.int/stats/eurofxref/eurofxref-daily.xml'
  
  class << self
    def exchange_rates(options = {})
      self.update_rates if @@config['exchange_rates'].empty? && !options[:prevent_update]
      @@config['exchange_rates']
    end
    
    def exchange_rates=(rates_hash)
      return false unless rates_hash.is_a?(Hash)
      @@config['exchange_rates'] = rates_hash
    end
    
    def commission
      config['commission'] || 0
    end
    
    def commission=(rate)
      config['commission'] = rate
    end
    
    def non_tradeable_currencies
      config['non_tradeable_currencies'] || []
    end
    
    def non_tradeable_currencies=(currency_array)
      return unless currency_array.is_a?(Array)
      config['non_tradeable_currencies'] = currency_array
    end
    
    def currency_symbols
      config['currency_symbols']
    end
    
    def rates_url
      config['xml_url'] || @@rates_url
    end
    
    def config
      @@config
    end
    
    def config=(config_hash)
      @@config['exchange_rates'] = {}
      @@config.merge!(config_hash)
    end
  
    # updates the rates constant
    #
    # rates constant is a global var containing a hash 
    def update_rates
      clear_rates
      add_currency_rate("EUR", 1)
      add_currency_rates(config["exchange_rates"]) # rates from bank.yml
        
      fetch_rates.each do |currency_rate|
        add_currency_rate(currency_rate[:currency], currency_rate[:rate].to_f)
      end
      @@config['exchange_rates']
    end
    
    def add_currency_rate(currency, rate)
      @@config['exchange_rates'][currency] = rate
    end
    
    def add_currency_rates(rates_hash = {})
      return unless rates_hash.is_a?(Hash)
      rates_hash.each do |currency, rate|
        # if the rate is a reference to another currency set it to the same rate otherwise use value
        if rate.is_a?(String)
          rate = @@config['exchange_rates'][rate]
        end
        @@config['exchange_rates'][currency] = rate
      end
    end
    
    def clear_rates
      @@config['exchange_rates'].clear
    end
    
    def fetch_rates
      begin
        doc = Hpricot.XML(open(rates_url))
        doc.search("gesmes:Envelope/Cube/Cube/Cube")
      rescue
        raise Money::MoneyError.new("failing to fetch currency rates.")
        {}
      end
    end
    
    def rate_for(currency)
      if exchange_rates[currency]
        exchange_rates[currency]
      else
        raise Money::MoneyError.new("Bank does not have the rate for #{currency}, please add more currency exchange rates.")
      end
    end
  
    # Used to exchange a money object between one currency and another
    def exchange(money_object, new_currency, options = {})
      return nil unless tradeable?(money_object.currency) # if you can't trade a currency return nil
      
      options[:exclude_commission] ||= false
      if money_object.currency != new_currency
        # find the exchange appropriate exchange rates, convert to big decimal to avoid floating point errors
        old_rate = BigDecimal.new(self.rate_for(money_object.currency).to_s)
        new_rate = BigDecimal.new(self.rate_for(new_currency).to_s)
        # do the calculation -> new currency = new rate / old rate  * amount
        new_amount = money_object.to_big_decimal * (new_rate / old_rate )
        # add in some commission if appropriate to take into account non mid market rates most sellers achieve
        new_amount = new_amount * (1 + self.commission) unless options[:exclude_commission] || self.commission == 0
        # convert to new money currency 
        new_amount.to_f.to_money(:currency => new_currency)
        
      else
        money_object
      end
    end
    
    def symbol_for(currency)
      self.currency_symbols[currency] || "$"
    end
    
    def tradeable?(currency)
      return true unless non_tradeable_currencies.include?(currency)
    end
 
  end 
end
