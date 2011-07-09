class MoneyTransaction < ActiveRecord::Base
  has_money :amount

  #has_money :total, :value => :total, :currency_field => :total_currency, :precision => 5

end