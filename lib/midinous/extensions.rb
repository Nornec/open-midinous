#   Copyright (C) 2019 James "Nornec" Ratliff
#
#   This file is part of Midinous
#
#   Midinous is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   Midinous is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with Midinous.  If not, see <https://www.gnu.org/licenses/>.

module UniMIDI
	class Loader
		class << self
			def clear_devices
				@devices = nil
			end
		end
	end
end

module MIDIWinMM
  module Map
		def reattach_funcs
			attach_function :midiInOpen, [:pointer, :uint, :input_callback, :DWORD_PTR, :DWORD], :MMRESULT
		end
	end
	
	#References MIDIWinMM\input.rb
	class Input
		def enable(options = {}, &block)
      init_input_buffer
      handle_ptr = FFI::MemoryPointer.new(FFI.type_size(:int))
      initialize_local_buffer
      @event_callback = get_event_callback
      Map.winmm_func(:midiInOpen, handle_ptr, @id, @event_callback, 0, Device::WinmmCallbackFlag)
      
      @handle = handle_ptr.read_int
      
      #Map.winmm_func(:midiInPrepareHeader, @handle, @header.pointer, @header.size)      
      #Map.winmm_func(:midiInAddBuffer, @handle, @header.pointer, @header.size)
      Map.winmm_func(:midiInStart, @handle)

      @enabled = true
      
      unless block.nil?
        begin
          yield(self)
        ensure
          close
        end
      else
        self
      end
    end
		alias_method :start, :enable
    alias_method :open, :enable	
	end

	
end

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