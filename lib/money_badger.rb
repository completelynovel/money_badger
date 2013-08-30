require 'money_badger/version'

require 'bigdecimal'
require 'nokogiri'
require 'open-uri'

require 'money_badger/core_extensions'
require 'money_badger/bank'
require 'money_badger/money'

# rails addition
if defined?(ActiveRecord) || defined?(ActiveModel)
  require 'rails/has_money'
  ActiveRecord::Base.send(:include, MoneyBadger::HasMoney)
end 
