require 'cc/api/explorer/version'
require 'cc/api/http/http_requestor'
require 'cc/api/parser/arguments_parser'
require 'cc/api/parser/json_parser'
require 'cc/api/presentor/presentor'
require 'cc/api/util/config_reader'
require 'cc/api/util/key_chains_getter'
require 'command_line_reporter'
require 'thor'
require 'yaml'

module Cc
  module Api
    module Explorer
      class CLI < Thor
        DEFAULT_COLS = 
          {
            "lattice-products" => ["store_variant.store_name", "store_variant.qty", "store_variant.buy_price.money.currency"],
            "lattice-stores" => ["store.name", "store.state", "store.url"],
            "lattice-offers" => ["store.name", "buy_price.cents", "sell_price.cents"],
            "catalog-products" => ["name", "barcode", "weight"],
            "catalog-product_types" => ["name", "id", "default_weight"],
            "catalog-stores" => ["name", "postal_code", "url"],
            "catalog-categories" => ["name", "seoname", "description"],
            "store-products" => ["product.seoname", "product.weight", "product.description"]
          }

        DESC =
          {
            "cols" => "JSON 'key chains' to display as columns to the output table. To determine 'key chains' for a selected command use --keychains",
            "keychains" => "Output the 'key chains' for a command",
            "offset" => "Offset of the starting row to be displayed. Nothing is displayed when out of bounds",
            "limit" => "Limit of rows to be displayed",
            "colw" => "Width of every column to be displayed",
            "colp" => "Padding of every cell to be displayed",
            "json" => "Prints the JSON response body instead",
            "id" => "Product ID",
            "skus" => "SKUs separated by ',' if more than one",
            "page" => "Page number of the response",
            "token" => "OAuth Token",
            "store" => "Store name (Crystal Commerce Client)",
            "csv" => "Print out the result into a csv file. Columns are separated by comma"
          }

        option :csv, :desc => DESC["csv"], :banner => "CSV_FILE_PATH"
        option :cols, :desc => DESC["cols"]
        option :keychains, :type => :boolean, :desc => DESC["keychains"]
        option :offset, :type => :numeric, :desc => DESC["offset"]
        option :limit, :type => :numeric, :desc => DESC["limit"]
        option :colw, :type => :numeric, :desc => DESC["colw"]
        option :colp, :type => :numeric, :desc => DESC["colp"]
        option :json, :type => :boolean, :desc => DESC["json"]
        option :id, :desc => DESC["id"]
        option :skus, :desc => DESC["skus"]
        desc "lattice [products --id <PRODUCT ID> --skus <PRODUCT SKUS separated by ','>] | [offers --id <PRODUCT ID> --skus <PRODUCT SKUS separated by comma>] | [stores]", 
              "The Market Data APIs track the Prices, Quantities, and similar data. It also indicates which stores in the CrystalCommerce in-network currently has those products for sale."
        def lattice subcommand
          case subcommand 
          when "products"
            # { product : { variants : { store_variants : [ { store_variant : { ... } } ] } } } 
            args = {:action => "lattice-products", :params => {:id => options[:id], :skus => options[:skus].to_s.split(',') } }
            self.perform args
          when "stores"
            # { [ { store : { ... } } ] }
            args = {:action => "lattice-stores"}
            self.perform args
          when "offers"
            # { <PRODUCT ID> : [ { ... } ] }
            args = {:action => "lattice-offers", :params => {:id => options[:id], :skus => options[:skus].to_s.split(',') } }
            self.perform args
          else
            Cc::Api::Parser::ArgumentsParser.raise_cli_arguments_exception
          end
        end

        option :csv, :desc => DESC["csv"], :banner => "CSV_FILE_PATH"
        option :cols, :desc => DESC["cols"]
        option :keychains, :type => :boolean, :desc => DESC["keychains"]
        option :offset, :type => :numeric, :desc => DESC["offset"]
        option :limit, :type => :numeric, :desc => DESC["limit"]
        option :colw, :type => :numeric, :desc => DESC["colw"]
        option :colp, :type => :numeric, :desc => DESC["colp"]
        option :json, :type => :boolean, :desc => DESC["json"]
        option :page, :type => :numeric, :desc => DESC["page"]

        desc "catalog [products] | [product_types] | [stores] | [categories]", 
          "This API will give access to read and write to the catalog of products. This includes what products could be sold but doesn't include prices or quantities, which are stored in the Market Data APIs."
        def catalog subcommand
          case subcommand 
          when "products"
            # { products : [ { ... }  }
            args = {:action => "catalog-products", :params => { :page => options[:page] || 1 } }
            self.perform args
          when "product_types"
            # { products : [ { ... } ] }
            args = {:action => "catalog-product_types", :params => { :page => options[:page] || 1 } }
            self.perform args
          when "stores"
            # { stores : [ { ... } ] }
            args = {:action => "catalog-stores"}
            self.perform args
          when "categories"
            # { categories : [ { ... } ] }
            args = {:action => "catalog-categories", :params => { :page => options[:page] || 1} }
            self.perform args
          else
            Cc::Api::Parser::ArgumentsParser.raise_cli_arguments_exception
          end
        end

        option :csv, :desc => DESC["csv"], :banner => "CSV_FILE_PATH"
        option :cols, :desc => DESC["cols"]
        option :keychains, :type => :boolean, :desc => DESC["keychains"]
        option :offset, :type => :numeric, :desc => DESC["offset"]
        option :limit, :type => :numeric, :desc => DESC["limit"]
        option :colw, :type => :numeric, :desc => DESC["colw"]
        option :colp, :type => :numeric, :desc => DESC["colp"]
        option :json, :type => :boolean, :desc => DESC["json"]
        option :page, :type => :numeric, :desc => DESC["page"]
        option :token, :desc => DESC["token"]
        option :store, :desc => DESC["store"]

        desc "store [products --token <access token> --store <store name>]", "The Store Data API provides access to the data related to a single store whereas the Market Data API applies to all stores."
        def store subcommand
          case subcommand
          when "products"
            # { paginated_collection : { entries : [ { product: { ... } } ] } }
            args = {:action => "store-products", :params => {:token => options[:token], :store => options[:store], :page => options[:page] || 1} }
            self.perform args
          else
            Cc::Api::Parser::ArgumentsParser.raise_cli_arguments_exception
          end
        end

        protected

        def perform args
          action = args[:action]
          begin
            param = Cc::Api::Parser::ArgumentsParser.parse args
            response = Cc::Api::Http::HttpRequestor.request_for_json param 
            puts "response time: #{response[:response_time]}"
            
            if options[:json]
              puts JSON.pretty_generate response[:body]
            else
              target = Cc::Api::Parser::ArgumentsMapper.get_target_key_chain args[:action]
              array = Cc::Api::Util::KeyChainsGetter.get_target_array response[:body], target, options[:id]
              if options[:keychains]
                Cc::Api::Util::KeyChainsGetter.get_key_chains array.first, ""
              else
                begin
                  result = Cc::Api::Parser::JsonParser.vanilla_reduce array, options[:cols].split(',')
                rescue
                  result = Cc::Api::Parser::JsonParser.vanilla_reduce array, DEFAULT_COLS[args[:action]]
                end
                tabler = Cc::Api::Presentor::Tabler.new
                tabler.present result, options[:colw], options[:colp], options[:offset], options[:limit]
                Cc::Api::Presentor::CSVer.to_csv result, options[:csv], options[:offset], options[:limit] if options[:csv]
              end
            end
          rescue Cc::Api::Util::LicenseKeysException
            puts 'License keys not set properly. Place your keys at ~/.bashrc (linux) or ~/.profile (mac). Just add this line "export CC_API_KEYS=<ssologin>:<key>"'
          rescue Cc::Api::Http::ServerProblemException
            puts "There's a problem with the server. Server response not expected."
          end
        end
      end
    end
  end
end
