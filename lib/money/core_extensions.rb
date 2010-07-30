module MoneyStringExtensions
  
  def to_money(options = {})
    options[:currency]  ||= Money.default_currency
    
    # Get the currency
    matches  = scan(/([A-Z]{2,3})/)
    currency = matches[0] ? matches[0][0] : options[:currency]
    
    # Get the precision
    unless precision.present?
      precision = scan(/\.(\d+)/).to_s.length # look for the decimal point
      precision = Money.default_precision if options[:precision] < 2 # reset to default precision if not precise enough
    end

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
    to_s.to_money(options)
  end
  
end
  
class Fixnum; include MoneyExtensions; end
class Float; include MoneyExtensions; end
class Money; include MoneyExtensions; end
class BigDecimal; include MoneyExtensions; end
class String; include MoneyStringExtensions; end
