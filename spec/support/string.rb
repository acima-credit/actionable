class String
  # From https://raw2.github.com/mynyml/unindent/master/lib/unindent.rb
  def unindent
    indent = split("\n").reject { |line| line.strip.empty? }.map { |line| line.index(/[^\s]/) }.compact.min || 0
    gsub(/^[[:blank:]]{#{indent}}/, '')
  end
end
