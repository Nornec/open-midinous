#Midi input and output methods go here

#Output.use(0) on windows will default to the Microsoft default synth
#Sends a series of notes to an instrument
class GuiListener < MIDIEye::Listener

	GUI_LISTEN_INTERVAL = 1.0 / 10
	
	def gui_listen_loop
    loop do
      poll
      @event.trigger_enqueued
      sleep(GUI_LISTEN_INTERVAL)
    end
  end
	
	def gui_listen
		@listener = Thread.new do
			begin
				gui_listen_loop
			rescue Exception => exception
				Thread.main.raise(exception)
			end
		end
		@listener.abort_on_exception = true
		true
	end
end

class Proc_Midi
	attr_accessor :out_list, :in_list
	attr_reader   :out_id,   :in_id, :in, :midi_in
	def initialize(oid,iid)
	  @out_id = oid
		@out_list = UniMIDI::Output.all
		@out = UniMIDI::Output.use(@out_id)
		
		@in_id  = iid
		@in  = UniMIDI::Input.use(@in_id)
		@in_list  = UniMIDI::Input.all
		@midi_in = GuiListener.new(@in)
		@midi_in.listen_for(:class => [MIDIMessage::NoteOn,MIDIMessage::NoteOff]) {|e| Pl.set_note(e[:message].note.clamp(0,127))}
		@midi_in.gui_listen
	end
	
	#Select the output device
	def sel_out(id)
		@out = UniMIDI::Output.use(id)
		@out_id = id
	end
	
	#Select the input device
	def sel_in(id)
		@in = UniMIDI::Input.use(id)
		@in_id = id
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

Pm = Proc_Midi.new(0,0)