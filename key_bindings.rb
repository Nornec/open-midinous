module Key_Bindings
	def route_key(event)
		#puts event.keyval
		unless !UI::logic_controls.focus?
			case event.keyval
				when 113        # Q
					UI::main_tool_1.signal_emit("keybinding-event")
				when 119        # W
					UI::main_tool_2.signal_emit("keybinding-event")
				when 101, 102   # E or F (colemak)
					UI::main_tool_3.signal_emit("keybinding-event")
				when 114, 112   # R or P (colemak)
					UI::main_tool_4.signal_emit("keybinding-event")
				when 65535      # del
					UI::canvas.signal_emit("delete-selected-event")
				when 116        # T
					UI::path_builder.signal_emit("keybinding-event")
			end
		end
	end

end