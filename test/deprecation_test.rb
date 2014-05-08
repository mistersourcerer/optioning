describe Optioning do
  let(:to_hash_lambda) { ->(value) { value } }
  let(:optioning) { Optioning.new :path, :commit, to_hash: to_hash_lambda }

  describe "#deprecate" do
    it "returns the instance of `Optioning`" do
      optioning.deprecate(:to_hash, :to).must_be_same_as optioning
    end

    it "replaces the deprecate option" do
      optioning.deprecate :to_hash, :to
      optioning.on(:to).object_id.must_be :==, to_hash_lambda.object_id
    end

    it "accepts the date of deprecation" do
      #optioning.deprecate :to_hash, :to
    end

    it "accepts a version of deprecation"
  end

  describe "#deprecation_warn" do

  end
end
