describe Optioning do
  let(:optioning) { Optioning.new :path, :commit, xpto: 'NO' }

  describe "#recognize" do
    it "returns the instance of `Optioning`" do
      optioning.recognize.must_be_same_as optioning
    end
  end

  describe "#unrecognized_warn" do

  end
end
