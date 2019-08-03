require_relative "constants"
require_relative "logic"
require_relative "ui"
require_relative "canvas"
require_relative "key_bindings"

class Init_Prog

	def initialize #Build the user interface, initiate the objects in the program
		UI::midinous.signal_connect("destroy") {Gtk.main_quit}
		UI::canvas.set_size_request(CANVAS_SIZE,CANVAS_SIZE)
		UI::canvas_h_adj.set_upper(CANVAS_SIZE)
		UI::canvas_v_adj.set_upper(CANVAS_SIZE)
		UI::grid_set(CANVAS_SIZE,GRID_SPACING)
		UI::canvas_h_adj.set_value(CANVAS_SIZE/3.1)
		UI::canvas_v_adj.set_value(CANVAS_SIZE/2.4)
	end
	
	def grid_center #center the grid
		UI::canvas_h_adj.set_value(CANVAS_SIZE/3.1)
		UI::canvas_v_adj.set_value(CANVAS_SIZE/2.4)
	end
	
end

init = Init_Prog.new
init.grid_center # Setting Grid Center here ensures the background always gets drawn first

module Event_Router
	extend Key_Bindings
	#For key bindings
	UI::midinous.signal_connect("key-press-event") { |obj, event| route_key(event) }
	#For keys
	UI::main_tool_1.signal_connect("keybinding-event")   {Active_Tool.set_tool(1)}
	UI::main_tool_2.signal_connect("keybinding-event")   {Active_Tool.set_tool(2)}
	UI::main_tool_3.signal_connect("keybinding-event")   {Active_Tool.set_tool(3)}
	UI::main_tool_4.signal_connect("keybinding-event")   {Active_Tool.set_tool(4)}
	#For clicks                                                        
	UI::main_tool_1.signal_connect("button-press-event") {Active_Tool.set_tool(1)}
	UI::main_tool_2.signal_connect("button-press-event") {Active_Tool.set_tool(2)}
	UI::main_tool_3.signal_connect("button-press-event") {Active_Tool.set_tool(3)}
	UI::main_tool_4.signal_connect("button-press-event") {Active_Tool.set_tool(4)}
	#Canvas Events
	UI::canvas.signal_connect("delete-selected-event") {              CC.canvas_del                }
	UI::canvas.signal_connect("button-press-event")    { |obj, event| CC.canvas_press(event)       }
	UI::canvas.signal_connect("motion-notify-event")   { |obj, event| CC.canvas_drag(obj,event)    }
	UI::canvas.signal_connect("button-release-event")  { |obj, event| CC.canvas_release(obj,event) }
	UI::canvas.signal_connect("draw")                  { |obj, cr|    CC.canvas_draw(obj,cr)       }
end

