require 'spec_helper'

describe Money do
  
  let (:money)    { Money.new(10, "USD", 2) }
  let (:dollars)  { Money.new(500, "USD") }
  let (:pounds)   { Money.new(300, "GBP") }
  let (:euros)    { Money.new(100, "EUR") }
  
  it "should have a bank" do
    Money.bank.should == Bank
  end
  
  describe "def initialize" do
    
    context "with blank attrs" do
      
      it "should be a money object" do
        money.should be_a(Money)
      end
      
      it "should have the default currency" do
        money.currency.should == Money.default_currency
      end
      
      it "should have the default precision" do
        money.precision.should == Money.default_precision
      end
    end
    
    context "initialize with attributes of value and currency" do
      before :each do
        @value = 500
        @currency = "GBP"
        @money = Money.new(@value, @currency)
      end
      
      it "should have a value of #{@value}" do
        @money.value.should == @value
      end
      
      it "should have a currency of #{@currency}" do
        @money.currency.should == @currency
      end
    end
    
    context "initialize with attributes of value, currency and precision" do
      before :each do
        @value = 500
        @currency = "GBP"
        @precision = 3
        @money = Money.new(@value, @currency, @precision)
      end
      
      it "should have a value of #{@value}" do
        @money.value.should == @value
      end
      
      it "should have a currency of #{@currency}" do
        @money.currency.should == @currency
      end
      
      it "should have a precision of #{@precision}" do
        @money.precision.should == @precision
      end
    end
    
    context "initialize with a value and a hash of currency and precision" do
      before :each do
        @value = 500
        @currency = "GBP"
        @precision = 3
        @money = Money.new(@value, :currency => @currency, :precision => @precision)
      end
      
      it "should have a value of #{@value}" do
        @money.value.should == @value
      end
      
      it "should have a currency of #{@currency}" do
        @money.currency.should == @currency
      end
      
      it "should have a precision of #{@precision}" do
        @money.precision.should == @precision
      end
    end
  end
  
  describe "def -@" do
    it "should negate the money value" do
      money = Money.new(500)
      new_money = -money
      new_money.value.should == -500
      old_money = -new_money
      old_money.value.should == 500
    end
  end
  
  describe "def +(other_money)" do
    it "should add two money values together if currencies and precisions are the same" do
      sum = Money.new(5) + Money.new(10)
      sum.should == Money.new(15)
    end
  end
  
  describe "def -(other_money)" do
    it "should subtract the second from the first if currencies and precisions are the same" do
      sum = Money.new(15) - Money.new(10)
      sum.should == Money.new(5)
    end
  end
  
  describe "def *(FixNum)" do
    it "should multiply the money by the fixnum" do
      sum = Money.new(10) * 5
      sum.should == Money.new(50)
    end
  end
  
  describe "def /(FixNum)" do
    it "should divide the money by the fixnum" do
      sum = Money.new(10) / 5
      sum.should == Money.new(2)
    end
  end
  
  describe "def <=(FixNum)" do
    
    it "should return true if the money is less than another money or float" do
      (money <= Money.new(50)).should be_true
      (money <= 20).should be_true
    end
    
    it "should return true if the money is the same as another money or float" do
      (money <= money).should be_true
      (money <= 0.1).should be_true
    end
    
    it "should return false if the money is more than another money or float" do
      (money <= Money.new(5)).should be_false
      (money <= 0.05).should be_false
    end
  end
  
  describe "def >=(FixNum)" do
    
    it "should return false if the money is less than another money or float" do
      (money >= Money.new(50)).should be_false
      (money >= 20).should be_false
    end
    
    it "should return true if the money is the same as another money or float" do
      (money >= money).should be_true
      (money >= 0.1).should be_true
    end
    
    it "should return true if the money is more than another money or float" do
      (money >= Money.new(5)).should be_true
      (money >= 0.05).should be_true
    end
  end
  
  describe "def >(money_or_fixnum)" do

    it "should return false if the money is less than another money or float" do
      (money > Money.new(50)).should be_false
      (money > 20).should be_false
    end
    
    it "should return false if the money is the same as another money or float" do
      (money > money).should be_false
      (money > 0.1).should be_false
    end
    
    it "should return true if the money is more than another money or float" do
      (money > Money.new(5)).should be_true
      (money > 0.05).should be_true
    end
  end
  
  describe "def <(money_or_fixnum)" do

    it "should return true if the money is less than another money or float" do
      (money < Money.new(50)).should be_true
      (money < 20).should be_true
    end
    
    it "should return false if the money is the same as another money or float" do
      (money < money).should be_false
      (money < 0.1).should be_false
    end
    
    it "should return false if the money is more than another money or float" do
      (money < Money.new(5)).should be_false
      (money < 0.05).should be_false
    end
  end
  
  describe "def zero?" do
    it "should return true if the money value is 0" do
      Money.new(0).zero?.should be_true
    end
    
    it "should return false if the money value is not 0" do
      Money.new(5).zero?.should be_false
      Money.new(-5).zero?.should be_false
    end
  end
  
  describe "def ===(money_or_thing)" do
    
    it "should return true if the money value, currency and precision are the same" do
      (money === Money.new(10, "USD", 2)).should be_true
    end
    
    it "should return false if the money value is not equal" do
      (money === Money.new(23, "USD", 2)).should be_false
    end
    
    it "should return false if the money currency is not equal" do
      (money === Money.new(10, "GBP", 2)).should be_false
    end
    
    it "should return false if the money precision is not equal" do
      (money === Money.new(10, "USD", 7)).should be_false
    end
    
    it "should return true if compared to a number of the same value" do
      (money === 0.1).should be_true
    end
    
    it "should return false if compared ot a number without the same value" do
      (money === 55).should be_false
    end
  end
  
  describe "def ==(money_or_thing)" do
    
    it "should return true if the money value, currency and precision are the same" do
      (money == Money.new(10, "USD", 2)).should be_true
    end
    
    it "should return false if the money value is not equal" do
      (money == Money.new(23, "USD", 2)).should be_false
    end
    
    it "should return false if the money currency is not equal" do
      (money == Money.new(10, "GBP", 2)).should be_false
    end
    
    it "should return true if value and currency are the same but the precision is not" do
      (money == Money.new(100, "USD", 3)).should be_true
    end
    
    it "should return true if compared to a number of the same value" do
      (money == 0.1).should be_true
    end
    
    it "should return false if compared ot a number without the same value" do
      (money == 55).should be_false
    end
  end
  
  describe "def =~(money_or_thing)" do
    
    it "should return true if the money value, currency and precision are the same" do
      (money =~ Money.new(10, "USD", 2)).should be_true
    end
    
    it "should return false if the money value is not equal" do
      (money =~ Money.new(23, "USD", 2)).should be_false
    end
    
    it "should return false if the money currency is not equal" do
      (money =~ Money.new(10, "GBP")).should be_false
    end

    it "should return true if the value is the same once the currency is converted" do
      (money =~ Money.new(10, "USD").exchange_to("GBP")).should be_true
    end
    
    it "should return true if the money value and currency are the same but the money precision is not" do
      (money =~ Money.new(10, "USD", 7)).should be_false
    end
    
    it "should return true if compared to a number of the same value" do
      (money =~ 0.1).should be_true
    end
    
    it "should return false if compared ot a number without the same value" do
      (money =~ 55).should be_false
    end
  end
  
  describe "def eql?(other_money)" do
    
    it "should return true if the money values are the same" do
      money.eql?(Money.new(10)).should be_true
    end
    
    it "should return false if the money value is not equal" do
      money.eql?(Money.new(23)).should be_false
    end
  end
  
  describe "def format" do
    before :each do
      money.stub(:currency_symbol).and_return("$")
    end
    
    it "should return a string of the currency symbol plus a 2 decimal place number" do
      money.format.should == "$0.10"
    end
    
    it "should return a string of the currency symbol plus a 3 decimal place number when precision is set to 3" do
      money.format(:precision => 3).should == "$0.100"
    end
    
    it "should return a string of the number when hide_symbol is set to true" do
      money.format(:hide_symbol => true).should == "0.10"
    end
  end
  
  describe "def currency_symbol" do
    before :each do
      Bank.stub(:symbol_for).with("USD").and_return("$")
      Bank.stub(:symbol_for).with("GBP").and_return("GBP")
    end
    
    it "should return a $ when currency is USD" do
      Money.new(500, "USD").currency_symbol.should == "$"
    end
    
    it "should return a GBP when currency is GBP" do
      Money.new(500, "GBP").currency_symbol.should == "GBP"
    end
  end
  
  describe "def in_cents" do
    
    it "should return 500 when 500 cents are present" do
      Money.new(500, "USD").in_cents.should == 500
    end
    
    it "should return 500 when 5000 tenth of cents are present" do
      Money.new(5000, "USD", 3).in_cents.should == 500
    end
    
  end
  
  describe "def in_dollars" do
    
    it "should return 5 when 500 cents are present" do
      Money.new(500, "USD").in_dollars.should == 5
    end
    
    it "should return 5 when 5000 tenth of cents are present" do
      Money.new(5000, "USD", 3).in_dollars.should == 5
    end
    
  end
  
  describe "def in_precision(precision)" do
    
    it "should convert money precision 2 to precision 3" do
      Money.new(500, "USD").in_precision(3).precision.should == Money.new(500, "USD", 3).precision
    end
    
  end
  
  describe "def to_str" do
    
    it "should put the value in a string of the float" do
      Money.new(500, "USD").to_str.should == "5.0"
    end
    
  end
  
  describe "def to_f" do
    
    it "should put the value in a float" do
      Money.new(500, "USD").to_f.should == 5.0
    end
    
  end
  
  describe "def exchange_to(currency)" do
    
    it "should if there are $2 to GBP1 it should exchange $4 to GBP2" do
      money = Money.new(400, "USD")
      money.class.bank.stub(:exchange_rates).and_return({"USD" => 2, "GBP" => 1})
      money.exchange_to("GBP")
    end
    
  end
  
end
