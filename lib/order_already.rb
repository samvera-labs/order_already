# frozen_string_literal: true

require_relative "order_already/version"
require "rails-html-sanitizer"

# In the spirit of Browse Everything and Questioning Authority, the Order Already module provides a
# simple interface for ordering properties that have an indeterminate persistence order (looking at
# you Fedora Commons and RDF N-Triples).
#
# To do this, we take liberties with the persistence layer's values (e.g. we prepend an index and
# delimiter to the given value).  You may not feel comfortable with this solution, because you are
# munging your data's
module OrderAlready
  class Error < StandardError; end

  # @api public
  #
  # @param attributes [Array<Symbol>] the name of the attributes/properties you want to order.
  # @param serializer [#serialize, #deserialize] the service class responsible for serializing the
  #        data.  Want to auto-alphabetize?  Use a different serializer than the default.
  #
  # @return [Module] a module that wraps the attr_accessor methods for the given :attributes.  In
  #         using a module, we have access to `super`; which is super convenient!  The module will
  #         also add a `#attribute_is_ordered_already?` method.
  #
  # @note In testing, you need to use `prepend` instead of `include`; but that may be a function of
  #       my specs.
  #
  # @example
  #   class MyRecord
  #     attr_reader :creators
  #     def creators=(values)
  #       # We're going to "persist" these in an "arbitrarily different" way than what the user
  #       # provided.
  #       @creators = Array(values).reverse
  #     end
  #     prepend OrderAlready.for(:creators)
  #   end
  #
  #   class OtherRecord
  #     attr_accessor :subjects
  #     # Assumes there's an Alphabetizer constant that responds to .serialize and .deserialize
  #     prepend OrderAlready.for(:subjects, serializer: Alphabetizer)
  #   end
  def self.for(*attributes, serializer: InputOrderSerializer)
    # Capturing the named attributes to create a local binding; this helps ensure we have that
    # available in the later :attribute_is_ordered_already? method definition.
    ordered_attributes = attributes.map(&:to_sym)

    # By creating a module, we have access to `super`.
    Module.new do
      ordered_attributes.each do |attribute|
        define_method(attribute) do
          serializer.deserialize(super())
        end

        define_method("#{attribute}=") do |values|
          super(serializer.serialize(values))
        end
      end

      define_method(:attribute_is_ordered_already?) do |attribute|
        ordered_attributes.include?(attribute.to_sym)
      end

      define_method(:already_ordered_attributes) do
        ordered_attributes
      end
    end
  end

  # This serializer preserves the input order regardless of underlying persistence order.
  #
  # The two public methods are {.deserialize} and {.serialize}.
  module InputOrderSerializer
    TOKEN_DELIMITER = '~'

    # @api public
    #
    # Convert a serialized array to a normal array of values.
    # @param arr [Array]
    # @return [Array]
    def self.deserialize(arr)
      return [] if arr&.empty?

      sort(arr).map do |val|
        get_value(val)
      end
    end

    # @api public
    #
    # Serialize a normal array of values to an array of ordered values
    #
    # @param arr [Array]
    # @return [Array]
    def self.serialize(arr)
      return [] if arr&.empty?

      arr = sanitize(arr)

      res = []
      arr.each_with_index do |val, ix|
        res << encode(ix, val)
      end

      res
    end

    def self.sanitize(values)
      full_sanitizer = Rails::Html::FullSanitizer.new
      sanitized_values = Array.new(values.size, '')
      empty = TOKEN_DELIMITER * 3
      values.each_with_index do |v, i|
        sanitized_values[i] = full_sanitizer.sanitize(v) unless v == empty
      end
    end
    private_class_method :sanitize

    # Sort an array of serialized values using the index token to determine the order
    def self.sort(arr)
      # Hack to force a stable sort; see
      # https://stackoverflow.com/questions/15442298/is-sort-in-ruby-stable
      n = 0
      arr.sort_by { |val| [get_index(val), n += 1] }
    end
    private_class_method :sort

    #
    # encode an index and a value into a composite field
    #
    def self.encode(index, val)
      "#{index}#{TOKEN_DELIMITER}#{val}"
    end
    private_class_method :encode

    # extract the index attribute from the serialized value; return index '0' if the
    # field cannot be parsed correctly
    def self.get_index(val)
      tokens = val.split(TOKEN_DELIMITER, 2)
      return tokens[0] if tokens.length == 2

      '0'
    end
    private_class_method :get_index

    # extract the value attribute from the serialized value; return the entire value if the
    # field cannot be parsed correctly
    #
    def self.get_value(val)
      tokens = val.split(TOKEN_DELIMITER, 2)
      return tokens[1] if tokens.length == 2

      val
    end
    private_class_method :get_value

    # @api private
    #
    # convert an ActiveTriples::Relation to a standard array (for debugging)
    def self.relation_to_array(arr)
      arr.map(&:to_s)
    end
  end
end
