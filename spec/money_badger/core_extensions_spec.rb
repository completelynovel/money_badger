require 'spec_helper'

module MoneyBadger
  
  describe StringExtensions do
    
    describe "def to_money(options = {})" do
      
      it "should return a money object" do
        "500".to_money.should be_a(MoneyBadger::Money)
      end
      
      it "should default to the default currency" do
        "500".to_money.currency.should == Money.default_currency
      end
      
      it "should default to the default precision" do
        "500".to_money.precision.should == Money.default_precision
      end
      
      it "should recognize the precision from the position of the decimal place" do
        "500.0432".to_money.precision.should == 4
      end
      
      it "should recognize the currency from the 3 letter iso prefix" do
        "GBP 500".to_money.currency.should == "GBP"
      end
      
      it "should remove comma separations in numbers" do
        "500,000".to_money.in_dollars.should == 500000
      end
      
      it "should return a zero money object if the string is not recognised" do
        "ajfkla".to_money.value.should == 0
      end
      
    end
    
    
  end
  
  describe MoneyExtensions do
  
    describe "def to_money(options = {})" do
      
      it "should convert a float into a money object" do
        float = 4.50
        float.to_money.should be_a(MoneyBadger::Money)
      end
      
      it "should convert an Integer into a money" do
        int = 500
        int.to_money.should be_a(MoneyBadger::Money)
      end
      
      it "should convert a BigDecimal to a money" do
        big_decimal = BigDecimal.new("500")
        big_decimal.to_money.should be_a(MoneyBadger::Money)
      end
      
    end
  end
  
  describe BigDecimalExtensions do
    
    describe "def to_big_decimal" do
      before :each do
        @money = Money.new(500)
      end
      
      it "should convert a money into a big decimal" do
        @money.to_big_decimal.should be_a(BigDecimal)
      end
      
      it "should convert Money.new(500) into the same value in BigDecimal" do
        @money.to_big_decimal.to_f.should == @money.to_f
      end
      
    end
    
  end
  
end
