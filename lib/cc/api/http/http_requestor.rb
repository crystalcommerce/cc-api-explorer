require 'httparty'

module Cc
  module Api
    module Http
      class ServerProblemException < Exception
      end

      class UnauthorizedAccessException < Exception
      end

      class HttpRequestor
        def request_for_json(params)
          start_time = Time.now
          if params[:request][:method] == "POST"
            response_body = HTTParty.post(
                params[:request][:url],
                :basic_auth => basic_auth,
                :body => params[:request][:body].to_json,
                :headers => { 'Content-Type' => 'application/json' }
            )
          elsif params[:request][:token]
            response_body = HTTParty.get(params[:request][:url], :headers => { "Authorization" => "OAuth #{params[:request][:token]}"})
          else
            response_body = HTTParty.get(params[:request][:url], :basic_auth => basic_auth)
          end
          puts "#{params[:request][:method] || "GET"} #{params[:request][:url]} #{params[:request][:body]}"
          end_time = Time.now

          raise UnauthorizedAccessException, "You don't have enough privilege to access." if response_body.code == 401
          raise ServerProblemException, "There's a problem with the server. Server response not expected." if response_body.code == 500
          return {body: response_body, response_time: end_time - start_time}
        end

      private

        def basic_auth
          @basic_auth ||= {
                           :username => license.username,
                           :password => license.password
                          }
        end

        def license
          @license ||= Cc::Api::Util::ConfigReader.license
        end
      end
    end
  end
end
