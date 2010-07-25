# -*- coding: utf-8 -*-
require 'redmine'
require 'dispatcher'

config.gem 'ruby-hmac', :lib => 'hmac-sha1'
config.gem 'uuid'

Dispatcher.to_prepare :redmine_http_store do
  require_dependency 'attachment'
  unless Attachment.included_modules.include? RedmineHttpStore::AttachmentPatch
    Attachment.send(:include, RedmineHttpStore::AttachmentPatch)
  end

  app_dependency = Redmine::VERSION.to_a.slice(0,3).join('.') > '0.8.4' ? 'application_controller' : 'application'
  require_dependency(app_dependency)
  require_dependency 'attachments_controller'
  unless AttachmentsController.included_modules.include? RedmineHttpStore::AttachmentsControllerPatch
    AttachmentsController.send(:include, RedmineHttpStore::AttachmentsControllerPatch)
  end

  RedmineHttpStore::Connection.initialize RedmineHttpStore::Client.new
end

Redmine::Plugin.register :redmine_http_store do
  name 'Redmine HTTP store plugin'
  author 'Martin Häger'
  description 'This plugin stores attached files to a HTTP file store instead of the local filesystem'
  version '0.0.1'
  url 'http://github.com/mtah/redmine_http_store'
  author_url 'http://freeasinbeard.org'
end
