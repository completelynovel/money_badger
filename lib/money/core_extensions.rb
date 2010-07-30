module MoneyStringExtensions
  
  def to_money(options = {})
    
    # Get the currency
    if options[:currency].present?
      currency = options[:currency]
    else
      matches  = scan(/([A-Z]{2,3})/)
      currency = matches[0] ? matches[0][0] : Money.default_currency 
    end
    
    # Get the precision
    if options[:precision].present?
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
    if self.is_a?(Money) && self.currency.present? && !options[:currency].present?
      options[:currency] = self.currency
    end

    # keep the same precision if present
    if self.is_a?(Money) && self.precision.present? && !options[:precision].present?
      options[:precision] = self.precision
    end
    
    to_s.to_money(options)
  end
  
end
  
class Fixnum; include MoneyExtensions; end
class Float; include MoneyExtensions; end
class Money; include MoneyExtensions; end
class BigDecimal; include MoneyExtensions; end
class String; include MoneyStringExtensions; end
