describe Optioning do
  let(:optioning) { Optioning.new from: "xpto", no_one_knows: "omg lol" }

  before do
    @original_stderr, $stderr = $stderr, StringIO.new
  end

  after do
    $stderr = @original_stderr
  end

  describe "#recognize" do
    it "returns the instance of `Optioning`" do
      optioning.recognize(:x).must_be_same_as optioning
    end

    it "should not warning about a recognized option" do
      optioning.recognize :from
      optioning.unrecognized_warn
      ($stderr.string =~ /:from/).must_be :==, nil
    end

    it "should warning about a unrecognized option" do
      optioning.recognize :from
      optioning.unrecognized_warn
      $stderr.string.must_match(/:no_one_knows/)
    end
  end

  describe "#unrecognized_warn" do

  end
end
