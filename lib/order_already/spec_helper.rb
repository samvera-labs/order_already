RSpec::Matchers.define :have_already_ordered_attributes do |*expected_attributes|
  match do |actual|
    actual.already_ordered_attributes.map(&:to_sym).sort == expected_attributes.map(&:to_sym).sort
  end

  failure_message do |actual|
    actual_attrs = actual.already_ordered_attributes.map(&:to_sym).sort
    expected_attrs = expected_attributes.map(&:to_sym).sort

    "Expected that #{actual} would have the following ordered attributes:\n" \
    "#{expected_attrs.inspect}.\n"
    "Actual: #{actual_attrs.inspect}\n"
  end
end