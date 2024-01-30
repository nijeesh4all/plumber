# frozen_string_literal: true

module Pipelines
  class Factory
    attr_reader :name, :source, :destination

    def initialize(configuration)
      @configuration = configuration
      @name = configuration["name"]
    end

    def pipeline
      source_class = self.source_class
      source_attributes = self.source_attributes
      destination_class = self.destination_class
      destination_attributes = self.destination_attributes
      transforms = self.transforms

      Kiba.parse do
        source source_class, **source_attributes

        transforms.each do |transform_class, transform_attributes|
          transform transform_class, **transform_attributes
        end

        destination destination_class, **destination_attributes
      end
    end

    private

    attr_reader :configuration

    def source_config
      @configuration[:source]
    end

    def destination_config
      @configuration[:destination]
    end

    def source_class
      class_name = source_config[:class]
      Object.const_get(class_name)
    end

    def destination_class
      class_name = destination_config[:class]
      Object.const_get(class_name)
    end

    def source_attributes
      source_config[:attributes]
    end

    def destination_attributes
      destination_config[:attributes]
    end

    def transforms_config
      @configuration[:transforms] || []
    end

    def transforms
      @transforms ||= transforms_config.map do |transform_config|
        transform_class = Object.const_get(transform_config[:class])
        [ transform_class, transform_config[:attributes] ]
      end
    end
  end
end
