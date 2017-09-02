class NullLogger
  %w[debug info warn error].each { |key| define_method(key) { |*args| } }
end
