require 'active_model/serialization'

module ActiveModel
  module Serializers
    module CSV
      include ActiveModel::Serialization

      # Returns an array representing the model. Some configuration can be
      # passed through +options+.
      #
      # Without any +options+, the returned Array will include all the model's
      # attributes.
      #
      #     user = User.find(1)
      #     user.as_csv
      #     # => [1, "Konata Izumi", 16, "2006-08-01", true]
      #
      # The :only and :except options can be used to limit
      # the attributes included, and work similar to the +attributes+ method.
      #
      #     user.as_csv(only: [:id, :name])
      #     # => [1, "Konata Izumi"]
      #
      #     user.as_csv(except: [:id, :created_at, :age])
      #     # => ["Konata Izumi", true]
      #
      # To include the result of some method calls on the model use :methods:
      #
      #     user.as_csv(methods: :permalink)
      #     # => [1, "Konata Izumi", 16, "2006-08-01", true, "1-konata-izumi"]
      #
      def as_csv(options = nil)
        options ||= {}

        attribute_names = attributes.keys
        if only = options[:only]
          attribute_names = Array(only).map(&:to_s).select do |key|
            attribute_names.include?(key)
          end
        elsif except = options[:except]
          attribute_names -= Array(except).map(&:to_s)
        end

        arr = []
        attribute_names.each do |n|
          arr.push(read_attribute_for_serialization(n).as_csv)
        end

        Array(options[:methods]).each do |m|
          if respond_to?(m)
            val = send(m)
            if idx = attribute_names.index(m.to_s)
              arr[idx] = val
            else
              arr.push(val)
            end
          end
        end

        arr
      end

    private

      # Hook method defining how an attribute value should be retrieved for
      # serialization. By default this is assumed to be an instance named after
      # the attribute. Override this method in subclasses should you need to
      # retrieve the value for a given attribute differently:
      #
      #   class MyClass
      #     include ActiveModel::Validations
      #
      #     def initialize(data = {})
      #       @data = data
      #     end
      #
      #     def read_attribute_for_serialization(key)
      #       @data[key]
      #     end
      #   end
      alias :read_attribute_for_serialization :send

    end
  end
end

ActiveRecord::Base.send(:include, ActiveModel::Serializers::CSV)

