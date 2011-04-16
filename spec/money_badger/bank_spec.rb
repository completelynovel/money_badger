require 'spec_helper'

module MoneyBadger
  
  describe Bank do
    
    it "should respond to exchange rates" do
      Bank.should respond_to(:exchange_rates)
    end
    
    it "should respond to commission" do
      Bank.should respond_to(:commission)
    end
    
    it "should respond to non_tradeable_currencies" do
      Bank.should respond_to(:non_tradeable_currencies)
    end
    
    
    describe "def self.exchange_rates" do
      
      it "should return @@exchange rates if present" do
        Bank.exchange_rates        = {"USD" => 1}
        Bank.exchange_rates.should == {"USD" => 1}
      end
      
      it "should look up exchange rates if nothing is present" do
        Bank.exchange_rates        = {}
        Bank.should_receive(:update_rates).and_return(true)
        Bank.exchange_rates
      end
      
    end
    
    describe "def self.exchange_rates=(rates_hash)" do
      
      it "should update exchange rates if given a hash" do
        rates = {"USD" => 1}
        Bank.exchange_rates = rates
        Bank.exchange_rates.should == rates
      end
      
      it "should return false if given something other than a hash" do
        (Bank.exchange_rates = nil).should be_false
      end
      
    end
    
    describe "def commission" do
      
      it "should be set to the commission" do
        rate = 0.5
        Bank.commission = rate
        Bank.commission.should == rate
      end
      
    end
    
    describe "def update_rates" do
      
      it "should clear the rates" do
        rates = {"USD" => 1}
        Bank.exchange_rates = rates
        Bank.should_receive(:fetch_rates).and_return(true)
        Bank.should_receive(:clear_rates).and_return(true)
        Bank.update_rates
      end
      
      it "should add a currency rate EUR => 1" do
        Bank.should_receive(:fetch_rates).and_return(true)
        Bank.update_rates
        Bank.exchange_rates["EUR"].should == 1
      end
      
      it "should call add rates twice" do
        Bank.should_receive(:add_currency_rates).twice.and_return(true)
        Bank.should_receive(:fetch_rates).and_return(true)
        Bank.update_rates
      end
      
    end
    
    describe "def add_currency_rate(rate)" do
      
      it "should add a currency rate to self.currency_rates" do
        Bank.add_currency_rate("GBP", 5)
        Bank.exchange_rates.include?("GBP").should be_true
        Bank.exchange_rates["GBP"].should == 5
      end
      
    end
    
    describe "def add_currency_rates(rates_hash)" do
      
      it "should return nil unless passed a hash" do
        Bank.add_currency_rates(nil).should be_nil
      end
      
      it "should set the currency rates to the contents of the hash" do
        rates = {"USD" => 1, "GBP" => 2}
        Bank.add_currency_rates(rates)
        Bank.exchange_rates["USD"] == rates["USD"]
        Bank.exchange_rates["GBP"] == rates["GBP"]
      end
      
      it "should understand named rates such as CREDIT => USD" do
        rates = {"USD" => 1, "CREDIT" => "USD"}
        Bank.add_currency_rates(rates)
        Bank.exchange_rates["CREDIT"].should == Bank.exchange_rates["USD"]
        
      end
      
    end
    
    describe "def clear rates" do
      
      it "should clear the rates hash" do
        Bank.clear_rates
        Bank.exchange_rates(:prevent_update => true).should == {}
      end
      
    end
    
    describe "def rates_for(currency)" do
      
      it "should return the exchange rate of the currency" do
        Bank.stub(:exchange_rates).and_return({"USD" => 1, "GBP" => 2})
        Bank.rate_for("USD").should == 1
        Bank.rate_for("GBP").should == 2
      end
      
    end
    
    describe "def exchange" do
      
      before :each do
        Bank.stub(:exchange_rates).and_return({"USD" => 1, "GBP" => 2})
        Bank.stub(:commission).and_return(0)
        @credits = Money.new(500, "CREDIT")
        @dollars = Money.new(400, "USD")
        @pounds  = Money.new(400, "GBP")
      end
      
      it "should return nil if the currency is not tradeable" do
        Bank.stub(:non_tradeable_currencies).and_return(["CREDIT"])
        Bank.exchange(@credits, "USD").should be_nil
      end
      
      it "should return the same amount if the currency is the same as the source" do
        Bank.exchange(@dollars, "USD").should == @dollars
      end
      
      it "should convert one currency into another if the currencies are different" do
        Bank.stub(:rate_for).with("USD").and_return(2)
        Bank.stub(:rate_for).with("GBP").and_return(2)
        Bank.stub(:commission).and_return(0)
        Bank.exchange(@dollars, "GBP").value.should == @pounds.value
      end
      
    end
    
    describe "def symbol_for(currency)" do
      
      it "should return $ for USD and £ for GBP" do
        Bank.stub(:currency_symbols).and_return({"USD" => "$", "GBP" => "£"})
        Bank.symbol_for("USD").should == "$"
        Bank.symbol_for("GBP").should == "£"
      end
      
    end
    
    
  end
  
end
