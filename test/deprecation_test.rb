describe Deprecation do
  let(:to_hash_lambda) { ->(value) { value } }
  let(:optioning) { Optioning.new :path, :commit, to_hash: to_hash_lambda }

  it "stores the option deprecated and the replacement" do
    deprecation = Deprecation.new :to_hash, :to
    deprecation.option.must_be :==, :to_hash
    deprecation.replacement.must_be :==, :to
  end

  it "accepts the date of deprecation" do
    deprecation = Deprecation.new :to_hash, :to, 2015, 3
    deprecation.date.must_be :==, Date.new(2015, 03, 01)
  end

  it "accepts a version of deprecation" do
    deprecation = Deprecation.new :to_hash, :to, "v2.0.0"
    deprecation.version.must_be :==, "v2.0.0"
  end

  describe "#warn" do
    it "without version or date" do
      deprecation = Deprecation.new :to_hash, :to
      deprecation.warn.must_be :==, "NOTE: option `:to_hash` is deprecated;"+
        " use `:to` instead. It will be removed in a future version.\n"
    end

    it "returns the message to warn about deprecation" do
      deprecation = Deprecation.new :to_hash, :to, "v2.0.0"
      deprecation.warn.must_be :==, "NOTE: option `:to_hash` is deprecated;"+
        " use `:to` instead. It will be removed on or after version v2.0.0.\n"
    end

    it "uses date to deprecate when it is available" do
      deprecation = Deprecation.new :to_hash, :to, 2015, 3
      deprecation.warn.must_be :==, "NOTE: option `:to_hash` is deprecated;"+
        " use `:to` instead. It will be removed on or after 2015-03-01.\n"
    end

    describe "when caller is available" do
      let(:deprecation) { Deprecation.new :to_hash, :to, "v2.0.0" }
      before do
        deprecation.caller = "/x/p/t/o/omg_lol_bbq.rb:42:in `hasherize'"
      end

      it "deprecation message includes caller info" do
        deprecation.warn.must_be :==, "NOTE: option `:to_hash` is deprecated;"+
          " use `:to` instead. It will be removed on or after version v2.0.0.\n"+
          "Called from /x/p/t/o/omg_lol_bbq.rb:42:in `hasherize'.\n"
      end
    end
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
      before do
        @original_stderr, $stderr = $stderr, StringIO.new
        optioning.deprecate :to_hash, :to, "v2.0.0"
      end

      after do
        $stderr = @original_stderr
      end

      it "constructs a deprecation message accordingly to the arguments" do
        optioning.deprecation_warn
        deprecation = Deprecation.new :to_hash, :to, "v2.0.0"
        $stderr.string.must_be :==, deprecation.warn
      end

      it "uses the callee information to compose the warning message" do
        optioning.deprecation_warn [
          "examples/client_maroto.rb:5:in `<class:Client>'",
          "examples/client_maroto.rb:2:in `<main>'"]
        deprecation = Deprecation.new :to_hash, :to, "v2.0.0"
        deprecation.caller = "examples/client_maroto.rb:5:in `<class:Client>'"
        $stderr.string.must_be :==, deprecation.warn
      end
    end
  end
end
