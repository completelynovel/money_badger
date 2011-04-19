require 'bigdecimal'
require 'money_badger/core_extensions'
require 'money_badger/bank'
require 'money_badger/money'
require 'money_badger/version'

# rails addition
['rails/has_money', 'rails/money_badger_init'].each do |file|
  require file
end if defined? ActiveRecord
