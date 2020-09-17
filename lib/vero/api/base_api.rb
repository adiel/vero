# frozen_string_literal: true

require 'json'
require 'rest-client'

module Vero
  module Api
    module Workers
      class BaseAPI
        attr_accessor :domain
        attr_reader :options

        def self.perform(domain, options)
          caller = new(domain, options)
          caller.perform
        end

        def initialize(domain, options)
          @domain = domain
          self.options = options
          setup_logging
        end

        def perform
          validate!
          request
        end

        def options=(val)
          @options = options_with_symbolized_keys(val)
        end

        protected

        def setup_logging
          return unless Vero::App.logger

          RestClient.log = Object.new.tap do |proxy|
            def proxy.<<(message)
              Vero::App.logger.info message
            end
          end
        end

        def url; end

        def validate!
          raise "#{self.class.name}#validate! should be overridden"
        end

        def request; end

        def request_content_type
          { content_type: :json, accept: :json }
        end

        def request_params_as_json
          JSON.dump(@options)
        end

        def options_with_symbolized_keys(val)
          val.each_with_object({}) do |(k, v), h|
            h[k.to_sym] = v
          end
        end
      end
    end
  end
end
