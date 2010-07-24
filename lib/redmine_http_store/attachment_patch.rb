module RedmineHttpStore
  module AttachmentPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
 
      base.class_eval do
        unloadable
        before_save    :put_to_http_store
        before_destroy :delete_from_http_store
      end
    end

    module ClassMethods
    end
    
    module InstanceMethods
      private
      def put_to_http_store
        if @temp_file && @temp_file.size > 0
          begin
            self.disk_filename = RedmineHttpStore::Connection.put(filename, @temp_file.read, self.content_type)
            md5 = Digest::MD5.new
            self.digest = md5.hexdigest
          rescue Exception => e
            errors.add(:base, e)
            return false
          end
        end

        @temp_file = nil
      end

      def delete_from_http_store
        begin
          RedmineHttpStore::Connection.delete(self.disk_filename)
        rescue Exception => e
          errors.add(:base, e)
          return false
        end
      end
    end
  end
end
