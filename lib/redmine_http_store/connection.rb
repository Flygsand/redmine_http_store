require 'net/http'

module RedmineHttpStore
  class Connection
    @@host  = nil
    @@port  = nil
    @@conn  = nil

    def self.initialize
      options = YAML::load(File.open(File.join(Rails.root, 'config', 'http_store.yml')))

      @@host = options[Rails.env]['host']
      @@port = options[Rails.env]['port']

      @@conn = Net::HTTP.new(@@host, @@port)
    end

    def self.uri
      port = @@port ? ":#{@@port}" : ""
      "http://#{@@host}#{port}"
    end
    
    def self.put(filename, data)
      raise ArgumentError('Filename must not contain a "/"') if filename.include?('/')

      response = @@conn.start do |http|
        http.send_request('PUT', "/#{filename}", data)
      end

      act_on_response(response)
    end

    def self.delete(file_uuid)
      response = @@conn.start do |http|
        http.send_request('DELETE', "/#{file_uuid}")
      end

      act_on_response(response)
    end

    private
    def self.act_on_response(response)
      case response
      when Net::HTTPSuccess, Net::HTTPRedirection then
        response.body
      else
        response.error!
      end
    end
  end
end
