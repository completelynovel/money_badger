
require 'bigdecimal'
module MoneyBadger
  
  module StringExtensions
  
    def to_money(options = {})
    
      # Get the currency
      if options[:currency]
        currency = options[:currency]
      else
        matches  = scan(/([A-Z]{2,3})/)
        currency = matches[0] ? matches[0][0] : Money.default_currency 
      end
    
      # Get the precision
      if options[:precision]
        precision = options[:precision]
      else
        precision = scan(/\.(\d+)/).to_s.length # look for the decimal point
      end
      precision = Money.default_precision if precision < 2 # reset to default precision if not precise enough

      # Get the cents amount
      str     = self =~ /^\./ ? "0#{self}" : self
      matches = str.scan /(\-?[\d,]+(\.(\d+))?)/
      value   = matches[0] ? (matches[0][0].gsub(',', '').to_f * 10**precision) : 0
      
      # Return money object
      Money.new(value, currency, precision)
    end
  
  end

  module MoneyExtensions
  
    # use to create a money object from another class
    def to_money(options = {})
      # keep the same currency if present
      if self.is_a?(Money) && self.currency && !options[:currency]
        options[:currency] = self.currency
      end

      # keep the same precision if present
      if self.is_a?(Money) && self.precision && !options[:precision]
        options[:precision] = self.precision
      end
    
      to_s.to_money(options)
    end
  
  end

  module BigDecimalExtensions
  
    def to_big_decimal
      BigDecimal.new(self.to_f.to_s)
    end
  
  end
  
end
  
class Fixnum;                   include MoneyBadger::MoneyExtensions; end
class Float;                    include MoneyBadger::MoneyExtensions; end
class Money;                    include MoneyBadger::MoneyExtensions; end
class BigDecimal;               include MoneyBadger::MoneyExtensions; end

class String;                   include MoneyBadger::StringExtensions; end

class Fixnum;                   include MoneyBadger::BigDecimalExtensions; end
class Float;                    include MoneyBadger::BigDecimalExtensions; end
class String;                   include MoneyBadger::BigDecimalExtensions; end
class Money;                    include MoneyBadger::BigDecimalExtensions; end
