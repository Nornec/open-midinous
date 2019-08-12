module Key_Bindings
	def route_key(event)
		#puts event.keyval
		unless !UI::logic_controls.focus?
			case
				when event.keyval == 113                           # Q
					UI::main_tool_1.signal_emit("keybinding-event")
				when event.keyval == 119                           # W
					UI::main_tool_2.signal_emit("keybinding-event")
				when event.keyval == 101 || event.keyval == 102    # E or F (colemak)
					UI::main_tool_3.signal_emit("keybinding-event")
				when event.keyval == 114 || event.keyval == 112    # R or P (colemak)
					UI::main_tool_4.signal_emit("keybinding-event")
				when event.keyval == 65535                         # del
					UI::canvas.signal_emit("delete-selected-event")
				when event.keyval == 116                           # T
					UI::path_builder.signal_emit("keybinding-event")
			end
		end
	end

end