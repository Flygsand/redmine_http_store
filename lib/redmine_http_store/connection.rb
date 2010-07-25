require 'net/http'
require 'rubygems'
require 'hmac-sha1'

module RedmineHttpStore
  class Connection
    @@host          = nil
    @@port          = nil
    @@shared_secret = nil
    
    @@conn          = nil
    @@client        = nil
    
    def self.initialize(client)
      options = YAML::load(File.open(File.join(Rails.root, 'config', 'http_store.yml')))

      @@host = options[Rails.env]['host']
      @@port = options[Rails.env]['port']
      @@shared_secret = options[Rails.env]['shared_secret']

      @@conn = Net::HTTP.new(@@host, @@port)
      @@client = client
    end

    def self.uri
      port = @@port ? ":#{@@port}" : ""
      "http://#{@@host}#{port}"
    end
    
    def self.put(filename, data, content_type = nil)
      raise ArgumentError('Filename must not contain a "/"') if filename.include?('/')

      header = {'X-AEFS-ClientId' => @@client.client_id, 'X-AEFS-Signature' => signature(data)}
      header['Content-Type'] = content_type if content_type
      
      response = @@conn.start do |http|
        http.send_request('PUT', "/#{filename}", data, header)
      end

      act_on_response(response)
    end

    def self.delete(file_uuid)
      header = {'X-AEFS-ClientId' => @@client.client_id, 'X-AEFS-Signature' => signature}
      response = @@conn.start do |http|
        http.send_request('DELETE', "/#{file_uuid}", nil, header)
      end

      act_on_response(response)
    end

    private
    def self.signature(data = nil)
      h = HMAC::SHA1.new(@@shared_secret)
      h.update("#{@@client.client_id}#{@@client.nonce!}#{data}")
      h.hexdigest
    end
    
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
