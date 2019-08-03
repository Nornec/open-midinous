trace = TracePoint.new(:call) do |tp|
  puts "#{tp.defined_class}##{tp.method_id} got called (#{tp.path}:#{tp.lineno})"
end
trace.enable