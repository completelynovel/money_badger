require 'spec_helper'

module MoneyBadger
  
  module HasMoney
    
    describe MoneyTransaction do

      let(:trans) { MoneyTransaction.new }
      let(:money) { Money.new(500, "GBP") }
      
      context "has_money(name, options = {})" do

        # has_money :amount
        # Test it sets everything to defaults
        describe "#amount" do
          
          it "it should respond to amount" do
            trans.should respond_to(:amount)
          end

          it "should respond with a Money object" do
            trans.amount.should be_a(Money)
          end

          it "should set the precision to the default (2)" do
            trans.amount.precision.should == 2
          end

          describe "#amount = ( thing )" do
            it "should set the money value when a money object is given" do
              trans.amount = money
              trans.amount_value.should == money.value
            end

            it "should set the money value when an integer object is given" do
              trans.amount = 5
              trans.currency = "GBP"
              trans.amount_value.should == money.value
            end

          end

          describe "#amount" do
            it "should return a money value built from value, currency and precision fields" do
              trans.stub(:amount_value).and_return(500)
              trans.stub(:currency).and_return("GBP")
              trans.amount.should == money
            end
          end
          
        end

        # has_money :total, :value => :total, :currency_field => :total_currency, :precision => 5
        # test defaults can be over ridden
        describe "#total" do
          it "should set the value to the specified total field (not the default total_value)"
          it "should use the specified currency "
          it "should set the money precision to 5"
        end
      end
      
    end
    
  end
  
end
