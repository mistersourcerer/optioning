describe Optioning do
  let(:to_hash_lambda) { ->(value) { value } }
  let(:optioning) { Optioning.new :path, :commit, to_hash: to_hash_lambda }

  describe "#deprecate" do
    it "returns the instance of `Optioning`" do
      optioning.deprecate.must_be_same_as optioning
    end

    it "accepts the date of deprecation"

    it "accepts a version of deprecation"
  end

  describe "#deprecation_warn" do

  end
end
