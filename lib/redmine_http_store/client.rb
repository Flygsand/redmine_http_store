require 'rubygems'
require 'uuid'

module RedmineHttpStore
  class Client
    def initialize
      @client_id = uuid
      @nonce = 0
    end
    
    def client_id
      @client_id
    end
    
    def nonce!
      old_nonce = @nonce
      @nonce = @nonce + 1
      old_nonce
    end

    private
    def uuid
      UUID.new.generate(:compact)
    end
  end
end
