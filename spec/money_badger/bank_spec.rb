require 'spec_helper'

  
describe Bank do

  before do
    mock(Bank).stub(:get_rates).and_return(Nokogiri.XML('
    <gesmes:Envelope xmlns:gesmes="http://www.gesmes.org/xml/2002-08-01" xmlns="http://www.ecb.int/vocabulary/2002-08-01/eurofxref">
    <gesmes:subject>Reference rates</gesmes:subject>
    <gesmes:Sender>
    <gesmes:name>European Central Bank</gesmes:name>
    </gesmes:Sender>
    <Cube>
    <Cube time="2011-07-08">
    <Cube currency="USD" rate="1.4242"/>
    <Cube currency="JPY" rate="115.98"/>
    <Cube currency="BGN" rate="1.9558"/>
    <Cube currency="CZK" rate="24.224"/>
    <Cube currency="DKK" rate="7.4587"/>
    <Cube currency="GBP" rate="0.89320"/>
    <Cube currency="HUF" rate="263.08"/>
    <Cube currency="LTL" rate="3.4528"/>
    <Cube currency="LVL" rate="0.7091"/>
    <Cube currency="PLN" rate="3.9401"/>
    <Cube currency="RON" rate="4.2010"/>
    <Cube currency="SEK" rate="9.0838"/>
    <Cube currency="CHF" rate="1.2102"/>
    <Cube currency="NOK" rate="7.7450"/>
    <Cube currency="HRK" rate="7.3910"/>
    <Cube currency="RUB" rate="39.8226"/>
    <Cube currency="TRY" rate="2.3124"/>
    <Cube currency="AUD" rate="1.3231"/>
    <Cube currency="BRL" rate="2.2214"/>
    <Cube currency="CAD" rate="1.3645"/>
    <Cube currency="CNY" rate="9.2072"/>
    <Cube currency="HKD" rate="11.0824"/>
    <Cube currency="IDR" rate="12133.26"/>
    <Cube currency="ILS" rate="4.8455"/>
    <Cube currency="INR" rate="63.2270"/>
    <Cube currency="KRW" rate="1505.56"/>
    <Cube currency="MXN" rate="16.4491"/>
    <Cube currency="MYR" rate="4.2565"/>
    <Cube currency="NZD" rate="1.7111"/>
    <Cube currency="PHP" rate="60.892"/>
    <Cube currency="SGD" rate="1.7364"/>
    <Cube currency="THB" rate="43.025"/>
    <Cube currency="ZAR" rate="9.5102"/>
    </Cube>
    </Cube>
    </gesmes:Envelope>
    '
    ))
  end
  
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
    
    it "should return EXCHANGE_RATES if present" do
      Bank.exchange_rates        =  {"USD" => 1}
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

  describe "def config=(hash)" do
    let (:config_hash) {
      {
        "commission"         => 0, 
        "exchange_rates"     => {:EUR => 1, :USD => 1.4434, :JPY => 122.26, :GBP => 0.8836}, 
        "currency_symbols"   => { :GBP => 'G', :EUR => "E", :JPY => "#" } 
      }
    }

    it "should set the exchange rates" do
      Bank.config = config_hash
      Bank.exchange_rates.should == {:EUR => 1, :USD => 1.4434, :JPY => 122.26, :GBP => 0.8836}
    end

    it "should set the commission" do
      Bank.config = config_hash
      Bank.commission.should == 0
    end

    it "should set the currency_symbols" do
      Bank.config = config_hash
      Bank.currency_symbols.should == { :GBP => 'G', :EUR => "E", :JPY => "#" } 
    end
  end

  describe "def update_rates" do
    before :each do
      Bank.stub(:config).and_return(
        {
          "commission"         => 0, 
          "exchange_rates"     => {:EUR => 1, :USD => 1.4434, :JPY => 122.26, :GBP => 0.8836}, 
          "currency_symbols"   => { :GBP => 'G', :EUR => "E", :JPY => "#" } 
        }
      )
    end
    
    it "should clear the rates" do
      rates = {"USD" => 1}
      Bank.exchange_rates = rates
      Bank.should_receive(:clear_rates).and_return(true)
      Bank.should_receive(:fetch_rates).and_return({})
      Bank.should_receive(:add_currency_rate).and_return(true)
      Bank.update_rates
    end
    
    it "should add a currency rate EUR => 1" do
      Bank.should_receive(:fetch_rates).and_return({})
      Bank.update_rates
      Bank.exchange_rates["EUR"].should == 1
    end
    
    it "should update the currency rates from the european exchange bank" do
      Bank.update_rates
      Bank.exchange_rates.length.should > 4
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
      Bank.exchange(@dollars, "GBP").should == @pounds * Bank.exchange_rates["GBP"]
    end
    
  end
  
  describe "def symbol_for(currency)" do
    
    it "should return $ for USD and E for GBP" do
      Bank.stub(:currency_symbols).and_return({"USD" => "$", "GBP" => "E"})
      Bank.symbol_for("USD").should == "$"
      Bank.symbol_for("GBP").should == "E"
    end
    
  end
  
  
end
