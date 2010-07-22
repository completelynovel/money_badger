require 'money'
require 'money/has_money'

ActiveRecord::Base.send(:include, MoneyBadger::HasMoney)

