describe Optioning do
  let(:optioning) {
    Optioning.new [from: "xpto", to: "bbq", no_one_knows: "omg lol"]
  }

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
  end

  describe "#unrecognized_warn" do
    it "should not warning about a recognized option" do
      optioning.recognize :from
      optioning.unrecognized_warn
      ($stderr.string =~ /unrecognized option `:from`/).must_be :==, nil
    end

    it "should warning about a unrecognized option" do
      optioning.recognize :from, :to
      optioning.unrecognized_warn
      $stderr.string.must_be :==, "NOTE: unrecognized option `:no_one_knows` used."+
        "\nYou should use only the following: `:from`, `:to`"
    end

    it "not consider deprecated options unrecognized" do
      optioning = Optioning.new [
        from: "xpto",
        to: "bbq",
        omg: "x",
        no_one_knows: "omg lol"]
      optioning.deprecate :omg, :lol
      optioning.recognize :from, :to
      optioning.unrecognized_warn
      $stderr.string.must_be :==, "NOTE: unrecognized option `:no_one_knows` used."+
        "\nYou should use only the following: `:lol`, `:from`, `:to`"
    end

    it "not consider replacement options unrecognized" do
      optioning = Optioning.new [
        from: "xpto",
        to: "bbq",
        lol: "x",
        no_one_knows: "omg lol"]
      optioning.deprecate :omg, :lol
      optioning.recognize :from, :to
      optioning.unrecognized_warn
      $stderr.string.must_be :==, "NOTE: unrecognized option `:no_one_knows` used."+
        "\nYou should use only the following: `:lol`, `:from`, `:to`"
    end

    it "just send the 'You should use only...' message when there are unrecognized options" do
      optioning = Optioning.new [omg_lol_bbq: "recognized!"]
      optioning.recognize :omg_lol_bbq
      optioning.unrecognized_warn
      $stderr.string.must_be :==, ""
    end
  end
end
