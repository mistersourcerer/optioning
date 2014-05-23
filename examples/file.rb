begin
  require "optioning"
rescue LoadError
  $:.unshift File.expand_path "../../lib", __FILE__
  require "optioning"
end

class FileExample
  def initialize(path, commit, content)
    @content = content
    @path, @commit = path, commit
  end

  def export
    hasherize :path, :commit,
      to_hash: ->(){},
      store: "NO!",
      persist: "I will persist!"
  end

  private

  def hasherize(*values_and_options)
    optioning = Optioning.new values_and_options
    optioning.deprecate :to_hash, :to, "v2.0.0"
    optioning.recognize :persist
    optioning.process caller

    puts "\n#{'*'* 80}"
    puts "I should export the follow ivars: #{optioning.values}"
    puts optioning.on :to
    puts optioning.on :persist
    puts optioning.on :store
  end
end

file = FileExample.new('/some/file.rb', 'cfe9aacbc02528b', '#omg! such file!')
file.export
