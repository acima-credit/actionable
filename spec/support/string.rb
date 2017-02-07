class String

  # From https://raw2.github.com/mynyml/unindent/master/lib/unindent.rb
  def unindent
    indent = self.split("\n").select { |line| !line.strip.empty? }.map { |line| line.index(/[^\s]/) }.compact.min || 0
    self.gsub(/^[[:blank:]]{#{indent}}/, '')
  end

end
