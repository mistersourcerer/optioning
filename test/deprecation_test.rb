describe Deprecation do
  let(:to_hash_lambda) { ->(value) { value } }
  let(:optioning) { Optioning.new :path, :commit, to_hash: to_hash_lambda }

  it "stores the option deprecated and the replacement" do
    deprecation = Deprecation.new :to_hash, :to
    deprecation.option.must_be :==, :to_hash
    deprecation.replacement.must_be :==, :to
  end

  it "accepts the date of deprecation" do
    deprecation = Deprecation.new :to_hash, :to, Date.new(2015, 03, 13)
    deprecation.date.must_be :==, Date.new(2015, 03, 13)
  end

  it "accepts a version of deprecation" do
    deprecation = Deprecation.new :to_hash, :to, "v2.0.0"
    deprecation.version.must_be :==, "v2.0.0"
  end

  describe "#warn" do
    let(:deprecation) { Deprecation.new :to_hash, :to, "v2.0.0" }
    it "returns the message to warn about deprecation"
  end

  describe Optioning do
    describe "#deprecate" do
      it "returns the instance of `Optioning`" do
        optioning.deprecate(:to_hash, :to).must_be_same_as optioning
      end

      it "replaces the deprecate option" do
        optioning.deprecate :to_hash, :to
        optioning.on(:to).object_id.must_be :==, to_hash_lambda.object_id
      end
    end

    describe "#deprecation_warn" do

    end
  end
end
