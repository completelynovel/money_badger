require 'money'

module MoneyBadger
  
  module HasMoney
    
    def self.included(base)
      base.extend(HasMethods)
    end 
    
    module HasMethods
      
      def has_money(name, options = {})
        
        include InstanceMethods
        
        #####
        # Init the money option
        #####
        cattr_accessor :money_options
        self.money_options ||= {}
        
        #####
        # Init new money
        #####      
        self.money_options[name] = {}
        
        #####
        # Define the price value field name
        #####
        
        # Check if a field is present
        if options[:field_name].present?
          self.money_options[name][:value_field] = options[:field_name].to_s
          
        # Check if a method #{name}_value is present
        elsif self.column_names.include?("#{name.to_s}_value")
          self.money_options[name][:value_field] = "#{name.to_s}_value"
          
        # Call default currency method
        else
          self.money_options[name][:value_field] = "#{name.to_s}_value"
        end
        
        #####
        # Define the price currency field name
        #####
        
        # Check if a field is present
        if options[:currency].present?
          self.money_options[name][:currency_field] = options[:currency].to_s
          
        # Check if a method #{name}_currency is present
        elsif self.column_names.include?("#{name.to_s}_currency")
          self.money_options[name][:currency_field] = "#{name.to_s}_currency"
          
        # Call default currency method
        else
          self.money_options[name][:currency_field] = "currency"
        end
        
        #####
        # Define the precision of the money object
        #####
        self.money_options[name][:precision] = options[:precision] || 2

        #####
        # Create getter and setter for the money
        #####        
        method_declaration = %{
          def #{name}
            opt = self.class.money_options[:#{name}]
            Money.new(self.send(opt[:value_field]), self.send(opt[:currency_field]), opt[:precision])
          end
                    
          def #{name}=(amount)
            opt   = self.class.money_options[:#{name}]
            money = amount.to_money(:precision => opt[:precision], :currency => self.#{self.money_options[name][:currency_field]})
            
            raise_wrong_currency_type(self.send(opt[:currency_field]), money.currency) unless amount.is_a?(Money)
            self.#{self.money_options[name][:value_field]}    = money.value
            self.#{self.money_options[name][:currency_field]} = money.currency if self.class.column_names.include?(opt[:currency_field].to_s)
          end
          
          def self.#{name}_sum(collection)
            m = collection.collect(&:#{name}).sum
            m = Money.new(0) if m.zero?
            m
          end
        }
        class_eval method_declaration
        
      end
      
    end
    
    module InstanceMethods
      
      def raise_wrong_currency_type(currency1, currency2)
        if currency1.nil? || currency2.nil? || currency1 != currency2
          raise "Currency is set to #{currency1} - can't assign Money value with currency of #{currency2}"
        end        
      end
      
    end
    
  end
  
end

