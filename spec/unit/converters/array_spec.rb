# frozen_string_literal: true

RSpec.describe Necromancer::ArrayConverters, "#call" do
  describe ":string -> :array" do
    subject(:converter) {
      described_class::StringToArrayConverter.new(:string, :array)
    }

    {
      ""                => [],
      "123"             => %w[123],
      "1,2,3"           => %w[1 2 3],
      "1-2-3"           => %w[1 2 3],
      " 1  - 2 - 3 "    => [" 1  ", " 2 ", " 3 "],
      "1  ,  2  , 3"    => ["1  ", "  2  ", " 3"],
      "1.2,2.3,3.4"     => %w[1.2 2.3 3.4],
      "a,b,c"           => %w[a b c],
      "a-b-c"           => %w[a b c],
      "aa a,b bb,c c c" => %w[aa\ a b\ bb c\ c\ c]
    }.each do |input, obj|
      it "converts #{input.inspect} to #{obj.inspect}" do
        expect(converter.(input)).to eq(obj)
      end
    end

    it "fails to convert empty string to array in strict mode" do
      expect {
        converter.("unknown", strict: true)
      }.to raise_error(
        Necromancer::ConversionTypeError,
        "'unknown' could not be converted from `string` into `array`"
      )
    end
  end

  describe ":string -> :booleans" do
    subject(:converter) { described_class::StringToBooleanArrayConverter.new }

    {
      "t,f,t"     => [true, false, true],
      "yes,no,Y"  => [true, false, true],
      "1-0-FALSE" => [true, false, false]
    }.each do |input, obj|
      it "converts #{input.inspect} to #{obj.inspect}" do
        expect(converter.(input)).to eq(obj)
      end
    end

    it "fails to convert in strict mode" do
      expect {
        converter.("yes,unknown", strict: true)
      }.to raise_error(
        Necromancer::ConversionTypeError,
        "'unknown' could not be converted from `string` into `boolean`"
      )
    end
  end

  describe ":string -> :integers/:ints" do
    subject(:converter) { described_class::StringToIntegerArrayConverter.new }

    {
      "1,2,3"         => [1, 2, 3],
      "1.2, 2.3, 3.4" => [1, 2, 3]
    }.each do |input, obj|
      it "converts #{input.inspect} to #{obj.inspect}" do
        expect(converter.(input)).to eq(obj)
      end
    end

    it "fails to convert in strict mode" do
      expect {
        converter.("1,unknown", strict: true)
      }.to raise_error(
        Necromancer::ConversionTypeError,
        "'unknown' could not be converted from `string` into `integer`"
      )
    end
  end

  describe ":string -> :floats" do
    subject(:converter) { described_class::StringToFloatArrayConverter.new }

    {
      "1,2,3"         => [1.0, 2.0, 3.0],
      "1.2, 2.3, 3.4" => [1.2, 2.3, 3.4]
    }.each do |input, obj|
      it "converts #{input.inspect} to #{obj.inspect}" do
        expect(converter.(input)).to eq(obj)
      end
    end

    it "fails to convert in strict mode" do
      expect {
        converter.("1,unknown", strict: true)
      }.to raise_error(
        Necromancer::ConversionTypeError,
        "'unknown' could not be converted from `string` into `float`"
      )
    end
  end

  describe ":string -> :numerics/:nums" do
    subject(:converter) { described_class::StringToNumericArrayConverter.new }

    {
      "1,2.0,3"       => [1, 2.0, 3],
      "1.2, 2.3, 3.4" => [1.2, 2.3, 3.4]
    }.each do |input, obj|
      it "converts #{input.inspect} to #{obj.inspect}" do
        expect(converter.(input)).to eq(obj)
      end
    end

    it "fails to convert in strict mode" do
      expect {
        converter.("1,unknown", strict: true)
      }.to raise_error(
        Necromancer::ConversionTypeError,
        "'unknown' could not be converted from `string` into `numeric`"
      )
    end
  end

  describe ":array -> :booleans/:bools" do
    subject(:converter) {
      described_class::ArrayToBooleanArrayConverter.new(:array, :boolean)
    }

    {
      %w[t f yes no] => [true, false, true, false],
      %w[t no 5]     => [true, false, "5"]
    }.each do |input, obj|
      it "converts #{input.inspect} to #{obj.inspect}" do
        expect(converter.(input)).to eq(obj)
      end
    end

    it "fails to convert `['t', 'no', 5]` to boolean array in strict mode" do
      expect {
        converter.(["t", "no", 5], strict: true)
      }.to raise_error(
        Necromancer::ConversionTypeError,
        "'5' could not be converted from `string` into `boolean`"
      )
    end
  end

  describe ":array -> :integers" do
    subject(:converter) { described_class::ArrayToIntegerArrayConverter.new }

    {
      %w[1 2 3]       => [1, 2, 3],
      %w[1.2 2.3 3.4] => [1, 2, 3]
    }.each do |input, obj|
      it "converts #{input.inspect} to #{obj.inspect}" do
        expect(converter.(input)).to eq(obj)
      end
    end

    it "fails to convert `['1','2.3']` to integer array in strict mode" do
      expect {
        converter.(["1", "2.3"], strict: true)
      }.to raise_error(
        Necromancer::ConversionTypeError,
        "'2.3' could not be converted from `string` into `integer`"
      )
    end
  end

  describe ":array -> :floats" do
    subject(:converter) { described_class::ArrayToFloatArrayConverter.new }

    {
      %w[1 2 3]       => [1.0, 2.0, 3.0],
      %w[1.2 2.3 3.4] => [1.2, 2.3, 3.4]
    }.each do |input, obj|
      it "converts #{input.inspect} to #{obj.inspect}" do
        expect(converter.(input)).to eq(obj)
      end
    end

    it "fails to convert `['1','2.3',false]` to float array in strict mode" do
      expect {
        converter.(["1", "2.3", false], strict: true)
      }.to raise_error(
        Necromancer::ConversionTypeError,
        "'false' could not be converted from `string` into `float`"
      )
    end
  end

  describe ":array -> :numerics/:nums" do
    subject(:converter) {
      described_class::ArrayToNumericArrayConverter.new(:array, :numerics)
    }

    {
      %w[1 2.3 3.0]   => [1, 2.3, 3.0],
      %w[1 2.3 false] => [1, 2.3, "false"]
    }.each do |input, obj|
      it "converts #{input.inspect} to #{obj.inspect}" do
        expect(converter.(input)).to eq(obj)
      end
    end

    it "fails to convert `['1','2.3',false]` to numeric array in strict mode" do
      expect {
        converter.(["1", "2.3", false], strict: true)
      }.to raise_error(
        Necromancer::ConversionTypeError,
        "'false' could not be converted from `string` into `numeric`"
      )
    end
  end

  describe ":array -> :set" do
    subject(:converter) {
      described_class::ArrayToSetConverter.new(:array, :set)
    }

    it "converts `[:x,:y,:x,1,2,1]` to set" do
      expect(converter.([:x, :y, :x, 1, 2, 1])).to eql(Set[:x, :y, 1, 2])
    end

    it "fails to convert `1` to set" do
      expect {
        converter.(1, strict: true)
      }.to raise_error(Necromancer::ConversionTypeError)
    end
  end

  describe ":object -> :array" do
    subject(:converter) {
      described_class::ObjectToArrayConverter.new(:object, :array)
    }

    it "converts nil to array" do
      expect(converter.(nil)).to eq([])
    end

    it "converts custom object to array" do
      stub_const("Custom", Class.new do
        def to_ary
          %i[x y]
        end
      end)
      custom = Custom.new
      expect(converter.(custom)).to eq(%i[x y])
    end
  end
end
