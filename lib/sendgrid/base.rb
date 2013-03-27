require 'json'

module Sendgrid
  module Base
    def self.included(klass)
      klass.extend ClassMethods
    end

    module ClassMethods
      def sendgrid
        include InstanceMethods

        alias_method_chain :mail, :sendgrid
      end
    end

    module InstanceMethods
      def mail_with_sendgrid(headers = {}, &block)
        headers['X-SMTPAPI'] = sendgrid_json_headers(headers)

        mail_without_sendgrid(headers, &block)
      end

      private

      def sendgrid_json_headers(headers = {})
        sg_opts = {}

        if category = headers.delete(:sg_category)
          sg_opts[:category] = category
        end

        if filters_options = headers.delete(:sg_filters)
          filters_options = [filters_options] unless filters_options.is_a? Array
          sg_opts[:filters] = {}
          filters_options.each do |filter|
            sg_opts[:filters][filter] = { :settings => { :enable => 1 } }
          end
        end

        sg_opts.to_json.gsub(/(["\]}])([,:])(["\[{])/, '\\1\\2 \\3')
      end
    end
  end
end
