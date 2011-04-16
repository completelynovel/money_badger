require 'active_record'
ActiveRecord::Base.send(:include, MoneyBadger::HasMoney)

class Money < MoneyBadger::Money ; end
