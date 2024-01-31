# frozen_string_literal: true

module Pipelines
  # The Factory class is responsible for creating Kiba ETL pipelines based on configuration settings.
  # It takes a pipeline configuration hash and provides a 'pipeline' method to generate the Kiba pipeline.
  #
  # @example:
  #   factory = Pipelines::Factory.new({ name: 'SamplePipeline', source: { class: 'SampleSource', attributes: {} },
  #                                       destination: { class: 'SampleDestination', attributes: {} },
  #                                       transforms: [{ class: 'SampleTransform', attributes: {} }] })
  #   pipeline = factory.pipeline
  #   Kiba.run(pipeline)
  class Factory
    attr_reader :name, :source, :destination

    def initialize(configuration)
      @configuration = configuration
      @name = configuration[:name]
    end

    def pipeline
      # we have to pass it like this, as `Kiba.parse` gets executed in the context of the `Kiba::Context` class
      # Hence does not have access to the scope of the `Factory` class's instance variables
      kiba_config = {
        source_class:, source_attributes:, transforms:, destination_class:, destination_attributes:
      }

      Kiba.parse do
        source kiba_config[:source_class], **kiba_config[:source_attributes]

        kiba_config[:transforms].each do |transform_class, transform_attributes|
          transform transform_class, **transform_attributes
        end

        destination kiba_config[:destination_class], **kiba_config[:destination_attributes]
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
        [transform_class, transform_config[:attributes]]
      end
    end
  end
end
