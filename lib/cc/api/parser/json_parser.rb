module Cc
  module Api
    module Parser
      class JsonParser
        def self.reduce action, json, cols
          case action
          when "lattice-products"
            self.reduce_for_lattice_products json, cols  
          when "lattice-stores"
            self.reduce_for_lattice_stores json, cols  
          when "lattice-offers"
            self.reduce_for_lattice_offers json, cols  
          when "catalog-products"
            self.reduce_for_catalog_products json, cols  
          else
            nil
          end
        end

        protected

        def self.reduce_for_lattice_products json, cols
          result = []

          unless json.nil? || json["product"]["variants"].empty?
            json["product"]["variants"][0]["variant"]["store_variants"].each do |sv|
              store_variant = sv["store_variant"]
              result << {
                store_name: store_variant["store_name"],
                qty: store_variant["qty"],
                inventory_qty: store_variant["inventory_qty"],
                sell_price: store_variant["sell_price"]["money"]["cents"],
                buy_price: store_variant["buy_price"]["money"]["cents"]
              } 
            end
          end

          result
        end

        def self.reduce_for_lattice_stores json, cols
          result = []

          unless json.nil?
            json.each do |s|
              store = s["store"]
              result << {
                name: store["name"],
                postal_code: store["postal_code"] || "",
                url: store["url"] || ""
              } 
            end
          end

          result
        end

        def self.reduce_for_lattice_offers json, cols
          result = []

          unless json.nil?
            offers = json.first.last
            offers.each do |offer|
              result << {
                name: offer["store"]["database_name"],
                buy_price: offer["buy_price"]["cents"],
                store_credit_buy_price: offer["store_credit_buy_price"]["cents"],
                qty: offer["url"] || "",
                web_qty: offer["web_qty"] || "",
              } 
            end
          end

          result
        end

        def self.reduce_for_catalog_products json, cols
          result = []

          unless json.nil?
            json["products"].each do |p|
              result << {
                name: p["name"],
                seoname: p["seoname"],
                category_name: p["category_name"],
                weight: p["weight"],
                description: p["description"]
              } 
            end
          end

          result
        end

      end
    end
  end
end


