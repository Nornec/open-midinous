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
	define_signal('cycle-play-mode-bck',nil,nil,nil)
	define_signal('cycle-play-mode-fwd',nil,nil,nil)
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
		
		#Windows
		def midinous 
			@builder.get_object("midinous")
		end
		def file_chooser
			@builder.get_object("file_chooser")
		end
		def confirmer
			@builder.get_object("confirmer")
		end
		
		#Menu Items
		def file_new
			@builder.get_object("file_new")
		end
		def file_open
			@builder.get_object("file_open")
		end
		def file_save
			@builder.get_object("file_save")
		end
		def file_save_as
			@builder.get_object("file_save_as")
		end
		def file_quit
			@builder.get_object("file_quit")
		end
		def help_about
			@builder.get_object("help_about")
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
		def file_operation
			@builder.get_object("file_operation")
		end
		def file_cancel
			@builder.get_object("file_cancel")
		end
		def confirmer_confirm
			@builder.get_object("confirmer_confirm")
		end
		def confirmer_cancel
			@builder.get_object("confirmer_cancel")
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
		def file_name
			@builder.get_object("file_name")
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
		def confirmer_label
			@builder.get_object("confirmer_label")
		end
		def scale_label
			@builder.get_object("scale_label")
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
		
		#Scale Selection Combo Box
		def scale_combo
			@builder.get_object("scale_combo")
		end
		def scale_tree_model
			@builder.get_object("scale_tree_model")
		end
		def scale_display
			@builder.get_object("scale_display")
		end
		
		scale_cat_1 = scale_tree_model.append(nil)
			scale_cat_1_sub_01 = scale_tree_model.append(scale_cat_1)
			scale_cat_1_sub_02 = scale_tree_model.append(scale_cat_1)
			scale_cat_1_sub_03 = scale_tree_model.append(scale_cat_1)
			scale_cat_1_sub_04 = scale_tree_model.append(scale_cat_1)
			scale_cat_1_sub_05 = scale_tree_model.append(scale_cat_1)
			scale_cat_1_sub_06 = scale_tree_model.append(scale_cat_1)
		scale_cat_2  = scale_tree_model.append(nil)
			scale_cat_2_sub_01 = scale_tree_model.append(scale_cat_2)		
			scale_cat_2_sub_02 = scale_tree_model.append(scale_cat_2)		
			scale_cat_2_sub_03 = scale_tree_model.append(scale_cat_2)		
			scale_cat_2_sub_04 = scale_tree_model.append(scale_cat_2)		
			scale_cat_2_sub_05 = scale_tree_model.append(scale_cat_2)		
			scale_cat_2_sub_06 = scale_tree_model.append(scale_cat_2)		
			scale_cat_2_sub_07 = scale_tree_model.append(scale_cat_2)		
			scale_cat_2_sub_08 = scale_tree_model.append(scale_cat_2)		
			scale_cat_2_sub_09 = scale_tree_model.append(scale_cat_2)		
		scale_cat_3 = scale_tree_model.append(nil)
			scale_cat_3_sub_01 = scale_tree_model.append(scale_cat_3)
			scale_cat_3_sub_02 = scale_tree_model.append(scale_cat_3)
			scale_cat_3_sub_03 = scale_tree_model.append(scale_cat_3)
			scale_cat_3_sub_04 = scale_tree_model.append(scale_cat_3)
			scale_cat_3_sub_05 = scale_tree_model.append(scale_cat_3)
			scale_cat_3_sub_06 = scale_tree_model.append(scale_cat_3)		
		scale_cat_4 = scale_tree_model.append(nil)
			scale_cat_4_sub_01 = scale_tree_model.append(scale_cat_4)
			scale_cat_4_sub_02 = scale_tree_model.append(scale_cat_4)
			scale_cat_4_sub_03 = scale_tree_model.append(scale_cat_4)
			scale_cat_4_sub_04 = scale_tree_model.append(scale_cat_4)
			scale_cat_4_sub_05 = scale_tree_model.append(scale_cat_4)
			scale_cat_4_sub_06 = scale_tree_model.append(scale_cat_4)
		scale_cat_5 = scale_tree_model.append(nil)
			scale_cat_5_sub_01 = scale_tree_model.append(scale_cat_5)
			scale_cat_5_sub_02 = scale_tree_model.append(scale_cat_5)
			scale_cat_5_sub_03 = scale_tree_model.append(scale_cat_5)
			scale_cat_5_sub_04 = scale_tree_model.append(scale_cat_5)
			scale_cat_5_sub_05 = scale_tree_model.append(scale_cat_5)
		
		scale_cat_1 [0] = "Pentatonic"
				scale_cat_1_sub_01[0] = "Hirajoshi"           
				scale_cat_1_sub_02[0] = "Insen"               
				scale_cat_1_sub_03[0] = "Iwato"               
				scale_cat_1_sub_04[0] = "Pentatonic Major"    
				scale_cat_1_sub_05[0] = "Pentatonic Minor"    
				scale_cat_1_sub_06[0] = "Two Semitone Tritone"
		scale_cat_2 [0] = "Traditional"
				scale_cat_2_sub_01[0] = "Aeolian"         
				scale_cat_2_sub_02[0] = "Dorian"          
				scale_cat_2_sub_03[0] = "Harmonic Major"  
				scale_cat_2_sub_04[0] = "Harmonic Minor"  
				scale_cat_2_sub_05[0] = "Ionian"          
				scale_cat_2_sub_06[0] = "Locrian"         
				scale_cat_2_sub_07[0] = "Lydian"          
				scale_cat_2_sub_08[0] = "Mixolydian"      
				scale_cat_2_sub_09[0] = "Phrygian"
		scale_cat_3 [0] = "Modified Traditional"
				scale_cat_3_sub_01[0] =	"Altered"         			
				scale_cat_3_sub_02[0] =	"Half Diminished" 			
				scale_cat_3_sub_03[0] =	"Locrian Major"   			
				scale_cat_3_sub_04[0] =	"Lydian Augmented"			
				scale_cat_3_sub_05[0] =	"Melodic Minor"   			
				scale_cat_3_sub_06[0] =	"Ukrainian Dorian"			
		scale_cat_4 [0] = "Exotic"
				scale_cat_4_sub_01[0] = "Augmented" 
				scale_cat_4_sub_02[0] = "Blues"  
				scale_cat_4_sub_03[0] = "Flamenco"  
				scale_cat_4_sub_04[0] = "Hungarian" 
				scale_cat_4_sub_05[0] = "Persian"   
				scale_cat_4_sub_06[0] = "Prometheus"
		scale_cat_5 [0] = "Mathematical"
				scale_cat_5_sub_01[0] = "Chromatic"
				scale_cat_5_sub_02[0] = "Octatonic Whole"
				scale_cat_5_sub_03[0] = "Octatonic Half" 
				scale_cat_5_sub_04[0] = "Tritone" 
				scale_cat_5_sub_05[0] = "Whole Tone"

		
		#Initialize the elements of the screen
		midinous.add_events("key-press-mask")
		canvas.add_events("button-press-mask")
		canvas.add_events("button-release-mask")
		canvas.add_events("pointer-motion-mask")
		prop_mod.add_events("key-press-mask")
		
		path_builder.sensitive = false
		prop_mod_button.sensitive = false
		stop.sensitive = false
		
		tool_descrip.text  = "Select"
		t_sig.text = "4/4"
		
		perf_label.markup       = "<b>#{perf_label.text}</b>"
		tempo_label.markup      = "<b>#{tempo_label.text}</b>"
		tool_label.markup       = "<b>#{tool_label.text}</b>"
		property_label.markup   = "<b>#{property_label.text}</b>"
		modify_label.markup     = "<b>#{modify_label.text}</b>"
		t_sig_label.markup      = "<b>#{t_sig_label.text}</b>"
		scale_label.markup      = "<b>#{scale_label.text}</b>"
		
		#canvas.add_events(Gdk::EventMask::BUTTON_PRESS_MASK.nick) #This points to a nickname, basically a string like "button-press-mask" in this case
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

UI = UI_Elements.new()  #Create a new UI_Elements object
UI::build_ui
Active_Tool = Tool.new