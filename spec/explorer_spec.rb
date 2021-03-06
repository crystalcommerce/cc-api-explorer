# -*- coding: utf-8 -*-
require 'spec_helper'

describe Cc::Api::Explorer::CLI do
  let(:license) { double("License", :username => 'abc', :password => "123")}

  before(:each) do
    Cc::Api::Util::ConfigReader.stub(:license).and_return(license)
  end

  let(:cc) { cc = Cc::Api::Explorer::CLI.new }

  context "market_data" do
    let(:skus) { ["123abc", "456def"] }

    context "products" do
      let(:expected_table_row) { %w[theendgames 0 USD] }
      let(:id) { "123" }
      let(:args) { "--id #{id} --sku #{skus}" }

      context "something is returned" do
        before(:each) do
          stub_request(:get, "https://abc:123@api.crystalcommerce.com/v1/market_data/products/#{id}?skus[]=#{skus[0]}").
            to_return(:status => 200, :body => MARKET_DATA_PRODUCTS_RESPONSE, :headers => {"Content-Type" => "application/json"})

          stub_request(:get, "https://abc:123@api.crystalcommerce.com/v1/market_data/products/#{id}?skus[]=#{skus[0]}&skus[]=#{skus[1]}").
            to_return(:status => 200, :body => MARKET_DATA_PRODUCTS_RESPONSE, :headers => {"Content-Type" => "application/json"})
        end

        it "returns something if arguments are correct" do

          printed = capture_stdout do
            args = ["market_data", "products", "--id", "123", "--skus", "123abc"]
            options = Cc::Api::Explorer::CLI.start(args)
          end

          expect(printed).to have_ascii_table_row(expected_table_row)
        end

        it "returns something if arguments are correct for multiple skus" do

          printed = capture_stdout do
            args = ["market_data", "products", "--id", "123", "--skus", skus.join(',')]
            options = Cc::Api::Explorer::CLI.start(args)
          end

          expect(printed).to have_ascii_table_row(expected_table_row)
        end
      end

      context "something is not returned" do
        it "returns an exception if arguments are not correct" do
          printed = capture_stdout do
            args = ["market_data", "products", "wrong", "arguments"]
            options = Cc::Api::Explorer::CLI.start(args)
          end

          printed.should eq "" #an error is printed here from Thor
        end

        it "returns blank if blank variants was returned" do
          stub_request(:get, "https://abc:123@api.crystalcommerce.com/v1/market_data/products/#{id}?skus[]=#{skus[0]}&skus[]=#{skus[1]}").
            to_return(:status => 200, :body => '{"product":{"product_id":201750,"variants":[]}}', :headers => {"Content-Type" => "application/json"})

          printed = capture_stdout do
            args = ["market_data", "products", "--id", "123", "--skus", skus.join(',')]
            options = Cc::Api::Explorer::CLI.start(args)
          end

          expect(printed).to_not have_ascii_table_row(expected_table_row)
        end

        it "returns blank if nil json was returned" do
          stub_request(:get, "https://abc:123@api.crystalcommerce.com/v1/market_data/products/#{id}?skus[]=#{skus[0]}&skus[]=#{skus[1]}").
            to_return(:status => 200, :body => nil, :headers => {"Content-Type" => "application/json"})


          printed = capture_stdout do
            args = ["market_dataproducts", "--id", "123", "--skus", skus.join(',')]
            options = Cc::Api::Explorer::CLI.start(args)
          end

          expect(printed).to_not have_ascii_table_row(expected_table_row)
        end
      end
    end

    context "stores" do
      let(:expected_table_row) { ["Lettie Traffanstedt'", "", ""]}
      context "something is returned" do
        it "returns something" do
          stub_request(:get, "https://abc:123@api.crystalcommerce.com/v1/market_data/stores").
            to_return(:status => 200, :body => MARKET_DATA_STORES_RESPONSE, :headers => {"Content-Type" => "application/json"})

          printed = capture_stdout do
            args = ["market_data", "stores"]
            options = Cc::Api::Explorer::CLI.start(args)
          end

          expect(printed).to have_ascii_table_row(expected_table_row)
        end
      end

      context "something is not returned" do
        it "returns nothing" do
          stub_request(:get, "https://abc:123@api.crystalcommerce.com/v1/market_data/stores").
            to_return(:status => 200, :body => nil, :headers => {"Content-Type" => "application/json"})

          printed = capture_stdout do
            args = ["market_data", "stores"]
            options = Cc::Api::Explorer::CLI.start(args)
          end

          expect(printed).to_not have_ascii_table_row(expected_table_row)
        end
      end
    end

    context "offers" do
      let(:expected_table_row) { ["Lettie Traffanstedt'", '109', '526']}
      context "something is returned" do
        it "returns something" do
          pending
          stub_request(:post, "https://abc:123@api.crystalcommerce.com/v1/market_data/offers").
            with(:body => "{\"search\":{\"skus\":{\"201750\":[\"123abc\",\"456def\"]}}}", :headers => {"Content-Type" => "application/json"}).
            to_return(:status => 200, :body => MARKET_DATA_OFFERS_RESPONSE, :headers => {"Content-Type" => "application/json"})

            #printed = capture_stdout do
              args = ["market_data", "offers", "--id", "201750", "--skus", skus.join(',')]
              options = Cc::Api::Explorer::CLI.start(args)
            #end

            #expect(printed).to have_ascii_table_row(expected_table_row)
        end
      end
    end
  end

  context "catalog" do
    context "products" do
      let(:expected_table_row) { ['Aven Cloudchaser', '', '0.0']}
      context "something is returned" do
        before(:each) do
          stub_request(:get, "https://abc:123@api.crystalcommerce.com/v1/catalog/products?page=1").
            to_return(:status => 200, :body => CATALOG_PRODUCTS_RESPONSE, :headers => {"Content-Type" => "application/json"})
        end

        it "returns something if arguments are correct" do

          printed = capture_stdout do
            args = ["catalog", "products"]
            options = Cc::Api::Explorer::CLI.start(args)
          end

          expect(printed).to have_ascii_table_row(expected_table_row)
        end
      end
    end

    context "product_types" do
      let(:expected_table_row) { ['Cthulhu Tech', '138', '1.0']}
      context "something is returned" do
        before(:each) do
          stub_request(:get, "https://abc:123@api.crystalcommerce.com/v1/catalog/product_types?page=1").
            to_return(:status => 200, :body => CATALOG_PRODUCT_TYPES_RESPONSE, :headers => {"Content-Type" => "application/json"})
        end

        it "returns something if arguments are correct" do
          printed = capture_stdout do
            args = ["catalog", "product_types"]
            options = Cc::Api::Explorer::CLI.start(args)
          end

          expect(printed).to have_ascii_table_row(expected_table_row)
        end
      end
    end

    context "stores" do
      let(:expected_table_row) { ['Asgard Keep', '62864', 'http://asgardkeep.co'] }
      context "something is returned" do
        before(:each) do
          stub_request(:get, "https://abc:123@api.crystalcommerce.com/v1/catalog/stores").
            to_return(:status => 200, :body => CATALOG_STORES_RESPONSE, :headers => {"Content-Type" => "application/json"})
        end

        it "returns something if arguments are correct" do
          printed = capture_stdout do
            args = ["catalog", "stores"]
            options = Cc::Api::Explorer::CLI.start(args)
          end

          expect(printed).to have_ascii_table_row(expected_table_row)
        end
      end
    end

    context "categories" do
      let(:expected_table_row) { ['Deathknell', 'deathknell', '']}
      context "something is returned" do
        before(:each) do
          stub_request(:get, "https://abc:123@api.crystalcommerce.com/v1/catalog/categories?page=1").
            to_return(:status => 200, :body => CATALOG_CATEGORIES_RESPONSE, :headers => {"Content-Type" => "application/json"})
        end

        it "returns something if arguments are correct" do
          printed = capture_stdout do
            args = ["catalog", "categories"]
            options = Cc::Api::Explorer::CLI.start(args)
          end

          expect(printed).to have_ascii_table_row(expected_table_row)
        end
      end
    end
  end

  context "store" do
    context "products" do
      let(:expected_table_row) { ['ashnods_cylix', '0.0037', '']}
      context "something is returned" do
        before(:each) do
          stub_request(:get, "https://abc:123@api.crystalcommerce.com/v1/stores/storename/products?page=2").
            to_return(:status => 200, :body => STORE_PRODUCTS_RESPONSE, :headers => {"Content-Type" => "application/json"})
        end

        it "returns something if arguments are correct" do
          printed = capture_stdout do
            args = ["store", "products", "--store", "storename", "--page", 2]
            options = Cc::Api::Explorer::CLI.start(args)
          end

          expect(printed).to have_ascii_table_row(expected_table_row)
        end
      end
    end
  end
end
