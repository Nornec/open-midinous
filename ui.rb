class GtkRadioButtonEx < Gtk::RadioButton
	type_register
	def initialize
		super()
	end
	define_signal('keybinding-event',nil,nil,nil)
end
class GtkButtonEx < Gtk::Button
	type_register
	def initialize
		super()
	end
	define_signal('keybinding-event',nil,nil,nil)
end
class GtkCanvas < Gtk::DrawingArea
	type_register
	def initialize
		super()
	end
	define_signal('delete-selected-event',nil,nil,nil)
	define_signal('beat-up',nil,nil,nil)
	define_signal('beat-dn',nil,nil,nil)
	define_signal('beat-note-up',nil,nil,nil)
	define_signal('beat-note-dn',nil,nil,nil)
	define_signal('travel-event',nil,nil,nil)
	define_signal('cycle-point-type-bck',nil,nil,nil)
	define_signal('cycle-point-type-fwd',nil,nil,nil)
	define_signal('set-start',nil,nil,nil)
end
class GtkPropEntry < Gtk::Entry
	type_register
	def initialize
		super()
	end
	define_signal('keybinding-event',nil,nil,nil)
end

class UI_Elements
	# Construct a Gtk::Builder instance and load our UI description
	attr_reader :bg_buff
	def build_ui
		builder_file = "./midinous.glade"
		bg_tile = "./assets/bg.png"
		
		# Connect signal handlers to the constructed widgets
		@builder = Gtk::Builder.new(:file => builder_file)
		
		#Set up the background tile for use
		@bg_buff = GdkPixbuf::Pixbuf.new(:file => bg_tile)
		
		#Main window
		def midinous 
			@builder.get_object("midinous")
		end

		#Drawing Areas
		def canvas
			@builder.get_object("canvas")
		end
		def canvas_viewport
			@builder.get_object("canvas_viewport")
		end
		def canvas_scroll_window
			@builder.get_object("canvas_scroll_window")
		end
		
		#Adjustments
		def canvas_h_adj
			@builder.get_object("canvas_scroll_h")
		end
		def canvas_v_adj
			@builder.get_object("canvas_scroll_v")
		end
		def tempo_adj
			@builder.get_object("tempo_adj")
		end
		
		#Buttons
		def main_tool_1
			@builder.get_object("main_tool_1")
		end		
		def main_tool_2
			@builder.get_object("main_tool_2")
		end		
		def main_tool_3
			@builder.get_object("main_tool_3")
		end		
		def main_tool_4
			@builder.get_object("main_tool_4")
		end
		def path_builder
			@builder.get_object("path_builder")
		end
		def prop_mod_button
			@builder.get_object("prop_mod_button")
		end
		def play
			@builder.get_object("play")
		end
		def stop
			@builder.get_object("stop")
		end
		def tempo
			@builder.get_object("tempo")
		end
		
		#Button Areas
		def logic_controls
			@builder.get_object("logic_controls")
		end
		
		#Text Areas
		def tool_descrip
			@builder.get_object("tool_descrip")
		end
		def status_area
			@builder.get_object("status_area")
		end
		def prop_mod
			@builder.get_object("prop_mod")
		end
		def t_sig
			@builder.get_object("t_sig")
		end
		
		#Labels
		def perf_label
			@builder.get_object("perf_label")
		end		
		def tool_label
			@builder.get_object("tool_label")
		end
		def tempo_label
			@builder.get_object("tempo_label")
		end
		def property_label
			@builder.get_object("property_label")
		end		
		def modify_label
			@builder.get_object("modify_label")
		end
		def t_sig_label
			@builder.get_object("t_sig_label")
		end
		
		#Point Property Tree
		def prop_list_model
			@builder.get_object("prop_list_model")
		end	
		def prop_list_view
			@builder.get_object("prop_list_view")
		end
		def prop_list
			@builder.get_object("prop_list")
		end
		def prop_list_col1_h
			@builder.get_object("prop_list_col1_h")
		end
		def prop_list_col2_h
			@builder.get_object("prop_list_col2_h")
		end	
		def prop_list_col1
			@builder.get_object("prop_list_col1")
		end
		def prop_list_col2
			@builder.get_object("prop_list_col2")
		end
		def prop_list_selection
			@builder.get_object("prop_list_selection")
		end
		
		
		#Initialize the elements of the screen
		midinous.add_events("key-press-mask")
		canvas.add_events("button-press-mask")
		canvas.add_events("button-release-mask")
		canvas.add_events("pointer-motion-mask")
		prop_mod.add_events("key-press-mask")
		
		path_builder.sensitive = false
		prop_mod_button.sensitive = false
		
		tool_descrip.text  = "Select"
		t_sig.text = "4/4"
		
		perf_label.markup       = "<b>#{perf_label.text}</b>"
		tempo_label.markup      = "<b>#{tempo_label.text}</b>"
		tool_label.markup       = "<b>#{tool_label.text}</b>"
		property_label.markup   = "<b>#{property_label.text}</b>"
		modify_label.markup     = "<b>#{modify_label.text}</b>"
		t_sig_label.markup   = "<b>#{t_sig_label.text}</b>"
		
		#canvas.add_events(Gdk::EventMask::BUTTON_PRESS_MASK.nick)
	end

end

class Tool
	def initialize
		@tool_id = 1
	end
	def set_tool(id)
		@tool_id = id
		unless @tool_id == 4 
			UI::path_builder.sensitive = false
		end
		case
			when @tool_id == 1
				UI::main_tool_1.active = true
				UI::tool_descrip.text = "Select"
				UI::canvas.queue_draw
			when @tool_id == 2 
				UI::main_tool_2.active = true
				UI::tool_descrip.text = "Place"
				UI::canvas.queue_draw
			when @tool_id == 3 
				UI::main_tool_3.active = true 
				UI::tool_descrip.text = "Move"
				UI::canvas.queue_draw
			when @tool_id == 4 
				UI::main_tool_4.active = true
				UI::path_builder.sensitive = true
				UI::tool_descrip.text = "Path"
				UI::canvas.queue_draw
		end
	end
	
	def get_tool
		return @tool_id
	end

end

GtkRadioButtonEx #Declare the new radio button definition to add functionality
GtkButtonEx      #Declare the new button
GtkCanvas        #Declare the new drawing area
UI = UI_Elements.new()  #Create a new UI_Elements object
UI::build_ui
Active_Tool = Tool.new