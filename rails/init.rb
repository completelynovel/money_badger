require 'money_badger'
require 'rails/has_money'

ActiveRecord::Base.send(:include, MoneyBadger::HasMoney)

