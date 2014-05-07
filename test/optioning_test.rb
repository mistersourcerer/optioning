describe Optioning do
  let(:to_hash_lambda) { ->(value) { value } }
  let(:optioning) { Optioning.new :path, :commit, to_hash: to_hash_lambda }

  describe "#raw" do
    it "transforms the var args passed to the constructor into an Array" do
      optioning.raw.must_be :==, [:path, :commit, to_hash: to_hash_lambda]
    end
  end

  describe "#values" do
    it "the arguments passed before the last one (if it is a `Hash`)" do
      optioning.values.must_be :==, [:path, :commit]
    end
  end

  describe "#on" do
    it "returns the value passed to specific option" do
      # impossible to use lambda.must_be_same_as, maybe a bug?
      optioning.on(:to_hash).object_id.must_be :==, to_hash_lambda.object_id
    end
  end
end
