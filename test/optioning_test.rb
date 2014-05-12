describe Optioning do
  let(:to_hash_lambda) { ->(value) { value } }
  let(:optioning) { Optioning.new :path, :commit, to_hash: to_hash_lambda }

  before do
    @original_stderr, $stderr = $stderr, StringIO.new
  end

  after do
    $stderr = @original_stderr
  end

  describe "#process" do
    it "returns the instance of `Optioning`" do
      optioning.process.must_be_same_as optioning
    end

    it "shows deprecations and unrecognized warnings" do
      optioning = Optioning.new :path, :commit,
        old: "OH!",
        from: ->(){},
        omg: "O YEAH!",
        wtf: "?"

      optioning.deprecate :old, :new
      optioning.deprecate :from_hash, :from
      optioning.recognize :omg

      optioning.process
      $stderr.string.must_be :==,[
        "NOTE: option `:old` is deprecated;",
        " use `:new` instead. It will be removed in a future version.\n",
        "NOTE: unrecognized option `:wtf` used.",
        "\nYou should use only the following: `:new`, `:from`, `:omg`"
      ].join
    end
  end

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
