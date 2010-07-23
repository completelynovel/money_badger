class String
  
  def to_money(options = {})
    options[:currency] ||= Money.default_currency
    
    # Get the currency
    matches = scan /([A-Z]{2,3})/ 
    currency = matches[0] ? matches[0][0] : options[:currency]
    
    if !options[:precision]
      options[:precision] = scan(/\.(\d+)/).to_s.length
      options[:precision] = Money.default_precision if options[:precision] < 2
    end

    # Get the cents amount
    str = self =~ /^\./ ? "0#{self}" : self
    matches = str.scan /(\-?[\d,]+(\.(\d+))?)/
    value = matches[0] ? (matches[0][0].gsub(',', '').to_f * 10**options[:precision]) : 0
    Money.new(value, currency, options[:precision])
  end
  
end


module MoneyExtensions
  
  def convert_to_money(options = {})
    options[:precision] ||= Money.default_precision
    options[:currency]  ||= "GBP"
    
    Money.new(self.to_f * 10**options[:precision], options[:currency], options[:precision])
  end
  
  def to_money(options = {})
    if self.is_a?(Money) && self.currency.present? && !options[:currency].present?
      options[:currency] = self.currency
    end
    
    to_s.to_money(options)
  end
  
end

class Fixnum;     include MoneyExtensions; end
class Float;      include MoneyExtensions; end
class String;     include MoneyExtensions; end
class Money;      include MoneyExtensions; end
class BigDecimal; include MoneyExtensions; end
   

