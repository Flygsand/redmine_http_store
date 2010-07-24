module RedmineHttpStore
  module AttachmentsControllerPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
 
      base.class_eval do
        unloadable
        before_filter :redirect_to_http_store, :except => :destroy
        skip_before_filter :file_readable
      end
    end
    
    module ClassMethods
    end
    
    module InstanceMethods
      def redirect_to_http_store
        if @attachment.container.is_a?(Version) || @attachment.container.is_a?(Project)
          @attachment.increment_download
        end
        redirect_to("#{RedmineHttpStore::Connection.uri}/#{@attachment.disk_filename}")
      end
    end
  end
end
