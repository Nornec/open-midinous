scale = [1,1,1,1,1,1,1,1,1,1,1,1]
notes = []
slen  = scale.length
root = 60

notes << root

c = 0
note = root
while note < 127
	note += scale[c]
	notes << note unless note > 127
  c = (c + 1) % slen
end

c = 0
note = root
while note > 0
	note -= scale.reverse[c]
	notes << note unless note < 0
	c = (c + 1) % slen
end

notes.each {|n| puts n}
puts notes.length