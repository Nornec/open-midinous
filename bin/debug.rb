#trace = TracePoint.new(:call) do |tp|
#  puts "#{tp.defined_class}##{tp.method_id} got called (#{tp.path}:#{tp.lineno})"
#end
#trace.enable

IO.binwrite("out.txt","")
IO.binread("out.txt")
$file = File.open("out.txt", 'a')