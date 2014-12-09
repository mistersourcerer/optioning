describe Optioning do
  let(:to_hash_lambda) { ->(value) { value } }
  let(:optioning) { Optioning.new [:path, :commit, to_hash: to_hash_lambda] }

  before do
    @original_stderr, $stderr = $stderr, StringIO.new
  end

  after do
    $stderr = @original_stderr
  end

  it 'accepts a parameter that is a plain hash' do
    optioning = Optioning.new old: "OH!",
                              from: ->(){},
                              omg: "O YEAH!",
                              wtf: "?"
    optioning.deprecate :old, :new
    optioning.deprecate :from_hash, :from
    optioning.recognize :omg

    # should not raise
    optioning.process

    $stderr.string.must_be :==,[
      "NOTE: option `:old` is deprecated;",
      " use `:new` instead. It will be removed in a future version.\n",

      "NOTE: unrecognized option `:wtf` used.",
      "\nYou should use only the following: `:new`, `:from`, `:omg`"
    ].join

    optioning.on(:omg).must_be :==, "O YEAH!"

    optioning.on(:nah).must_be :==, nil
  end

  describe "#process" do
    let(:optioning) {
      Optioning.new [:path, :commit,
        old: "OH!",
        from: ->(){},
        omg: "O YEAH!",
        wtf: "?"]
    }

    before do
      optioning.deprecate :old, :new
      optioning.deprecate :from_hash, :from
      optioning.recognize :omg
    end

    it "returns the instance of `Optioning`" do
      optioning.process.must_be_same_as optioning
    end

    it "doesn't mutate the original Array" do
      original = [:path, option: "value"]
      passed_options = original.dup
      optioning = Optioning.new passed_options
      optioning.deprecate :old_option, :option
      optioning.process
      passed_options.must_be :==, original
    end

    it "doesn't nillify option when deprecation exists but current is used" do
      optioning.deprecate :lol, :omg
      optioning.process
      optioning.on(:omg).must_be :==, "O YEAH!"
    end

    it "shows deprecations and unrecognized warnings" do
      optioning.process
      $stderr.string.must_be :==,[
        "NOTE: option `:old` is deprecated;",
        " use `:new` instead. It will be removed in a future version.\n",

        "NOTE: unrecognized option `:wtf` used.",
        "\nYou should use only the following: `:new`, `:from`, `:omg`"
      ].join
    end

    it "accepts the caller info as argument" do
      optioning.process [
        "examples/client_maroto.rb:5:in `<class:Client>'",
        "examples/client_maroto.rb:2:in `<main>'"]

      $stderr.string.must_be :==,[
        "NOTE: option `:old` is deprecated;",
        " use `:new` instead. It will be removed in a future version.\n",
        "Called from examples/client_maroto.rb:5:in `<class:Client>'.\n",

        "NOTE: unrecognized option `:wtf` used.",
        "\nYou should use only the following: `:new`, `:from`, `:omg`\n",
        "Called from examples/client_maroto.rb:5:in `<class:Client>'.",
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

    describe "when there is no options" do
      let(:optioning) { Optioning.new [:path, :commit] }
      it "not breaks when tries to recover the option" do
        optioning.on :x
      end
    end
  end
end
