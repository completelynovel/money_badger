class String
  
  def to_money(options = {})
    options[:currency]  ||= Money.default_currency
    options[:precision] ||= Money.default_precision
    
    # Get the currency
    matches  = scan(/([A-Z]{2,3})/)
    currency = matches[0] ? matches[0][0] : options[:currency]
    
    # Get the precision
    precision = options[:precision].to_i
    precision = Money.default_precision if precision < Money.default_precision

    # Get the cents amount
    str     = self =~ /^\./ ? "0#{self}" : self
    matches = str.scan /(\-?[\d,]+(\.(\d+))?)/
    value   = matches[0] ? (matches[0][0].gsub(',', '').to_f * 10**precision) : 0
    
    # Return money object
    Money.new(value, currency, precision)
  end
  
end

module MoneyExtensions
  
  def to_money(options = {})
    if self.is_a?(Money) && self.currency.present? && !options[:currency].present?
      options[:currency] = self.currency
    end

    if self.is_a?(Money) && self.precision.present? && !options[:precision].present?
      options[:precision] = self.precision
    end
        
    to_s.to_money(options)
  end
  
end

class Fixnum;     include MoneyExtensions; end
class Float;      include MoneyExtensions; end
class String;     include MoneyExtensions; end
class Money;      include MoneyExtensions; end
class BigDecimal; include MoneyExtensions; end