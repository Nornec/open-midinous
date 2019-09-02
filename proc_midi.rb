#Midi input and output methods go here

#Output.use(0) on windows will default to the Microsoft default synth
#Sends a series of notes to an instrument
class Proc_Midi
	attr_accessor :out
	def initialize(port)
		@out = UniMIDI::Output.use(port)
	end
	#Sends a note to an instrument
	def note_send(channel,note,velocity)
		@out.puts(0x90+channel-1,note,velocity)
	end

	#Release a note. Does not require a duration. Is called when a release signal is received.
	def note_rlse(channel,note)
		@out.puts(0x80+channel-1,note,0x00)
	end

end

class NoteSender
	attr_reader :note, :chan, :vel
	def initialize(note,chan,vel)
		@note = note
		@chan = chan
		@vel  = vel
	end
	
	def play
		Pm.note_send(@chan,@note,@vel)
	end
	def stop
		Pm.note_rlse(@chan,@note)
	end
	
end


Pm = Proc_Midi.new(1)