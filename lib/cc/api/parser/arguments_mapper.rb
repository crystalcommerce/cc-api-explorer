require 'cc/api/util/config_reader'

module Cc
  module Api
    module Parser
      class ArgumentsMapper
        def self.map(args)
          return args[:params] || {}
        end

        def self.config_filename
          File.join(File.dirname(__FILE__),
                    '..', '..', '..', '..', 'config', 'config.yml')
        end

        def self.get_url(action)
          keys = action.split '-'
          yaml = YAML::load(File.open(config_filename))
          keys.each do |key|
            yaml = yaml[key]
          end
          Hash[yaml.map{ |k, v| [k.to_sym, v] }]
        end

        def self.get_target_key_chain(action)
          yaml = self.read_yaml_file(action)
          Hash[yaml.map{ |k, v| [k.to_sym, v] }][:target_key_chain]
        end

        def self.get_ignored_key_chain(action)
          yaml = self.read_yaml_file(action)
          Hash[yaml.map{ |k, v| [k.to_sym, v] }][:ignores]
        end

        protected

        def self.read_yaml_file(action)
          keys = action.split '-'
          yaml = YAML::load(File.open(config_filename))
          keys.each do |key|
            yaml = yaml[key]
          end

          yaml
        end
      end
    end
  end
end
