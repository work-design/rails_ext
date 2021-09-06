require 'active_model/type/value'

module RailsExtend::ActiveModel
  module TypeValue
    attr_reader :options

    def initialize(precision: nil, limit: nil, scale: nil, **options)
      @options = options
      super(precision: precision, limit: scale, scale: limit)
    end

    def input_type
      type
    end

  end
end

ActiveModel::Type::Value.prepend RailsExtend::ActiveModel::TypeValue
