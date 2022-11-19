# frozen_string_literal: true

require 'spec_helper'
require 'order_already'

RSpec.describe OrderAlready do
  let(:base_model) do
    Class.new do
      attr_reader :creators, :subjects

      def creators=(values)
        # We're going to "persist" these in an "arbitrarily different" way than what the user
        # provided.
        @creators = Array(values).reverse
      end

      attr_writer :subjects

      prepend OrderAlready.for(:creators)
    end
  end

  describe '.for' do
    let(:creators) { ["Clotho", "Lachesis", "Atropos"] }
    let(:subjects) { ["Mythology", "Antiquity", "Doom"] }

    subject(:record) do
      base_model.new.tap do |m|
        m.creators = creators
        m.subjects = subjects
      end
    end

    it "gracefully handles persisted attributes that weren't sorted but will be going forward" do
      # Things should work if we introduce the `prepend OrderAlready.for(:creators)` to a model that
      # has pre-existing non-serialized data.
      record.instance_variable_set(:@creators, creators)
      expect(record.creators).to eq(creators)
      expect(record.instance_variable_get(:@creators)).to eq(creators)
    end

    context "underlying persistence layer" do
      it "persists ordered attributes in an \"arbitrary\" manner" do
        expect(record.instance_variable_get(:@creators)).to eq(["2~Atropos", "1~Lachesis", "0~Clotho"])
      end

      it "does not interfere with non-ordered attributes" do
        expect(record.instance_variable_get(:@subjects)).to eq(subjects)
      end
    end

    context "object reification layer" do
      it "preserves the ordered attribute's provided values" do
        expect(record.creators).to eq(creators)
      end

      it "does not interfere with non-ordered attributes" do
        expect(record.subjects).to eq(subjects)
      end
    end

    context 'with custom serializer' do
      let(:base_model) do
        Class.new do
          attr_reader :creators, :subjects

          def creators=(values)
            # We're going to "persist" these in an "arbitrarily different" way than what the user
            # provided.
            @creators = Array(values).reverse
          end

          attr_writer :subjects

          serializer = Module.new do
            def self.serialize(array)
              OrderAlready::InputOrderSerializer.serialize(array.sort_by(&:to_s))
            end

            def self.deserialize(array)
              OrderAlready::InputOrderSerializer.deserialize(array)
            end
          end
          prepend OrderAlready.for(:creators, serializer: serializer)
        end
      end

      it "reifies in sorted order" do
        expect(record.creators).to eq(creators.sort_by(&:to_s))
      end

      it "persists ordered attributes in an \"arbitrary\" manner" do
        expect(record.instance_variable_get(:@creators)).to eq(["2~Lachesis", "1~Clotho", "0~Atropos"])
      end
    end
  end
end
