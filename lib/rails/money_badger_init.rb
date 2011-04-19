require 'active_record'
ActiveRecord::Base.send(:include, MoneyBadger::HasMoney)
