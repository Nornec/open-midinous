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
end

class UI_Elements
	# Construct a Gtk::Builder instance and load our UI description
	def build_ui
		builder_file = "./midinous.glade"
		
		# Connect signal handlers to the constructed widgets
		@builder = Gtk::Builder.new(:file => builder_file)

		#Main window
		def midinous 
			@builder.get_object("midinous")
		end

		#Drawing Area
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
		
		#Text Areas
		def tool_descrip
			@builder.get_object("tool_descrip")
		end
		
		def status_area
			@builder.get_object("status_area")
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
		
		#Point Property Tree
		def point_list_model
			@builder.get_object("point_list_model")
		end
		def point_list
			@builder.get_object("point_list")
		end
		def point_list_col1
			@builder.get_object("point_list_col1")
		end
		def point_list_col2
			@builder.get_object("point_list_col2")
		end

  #test lifecycle of the point list
=begin
		data1 = ["Position","Color","Paths"]
		data2 = ["-100,200","#0547FF",nil]
		
		data1.length.times do |v|
			iter = point_list_model.append
			iter[0] = data1[v]
			iter[1] = data2[v]
		end
		#point_list_model.clear
=end
		
		#Initialize the elements of the screen
		midinous.add_events("key-press-mask")
		canvas.add_events("button-press-mask")
		canvas.add_events("button-release-mask")
		canvas.add_events("pointer-motion-mask")
		
		path_builder.sensitive = false
		
		tool_descrip.text = "Select"
		
		perf_label.markup       = "<b>#{perf_label.text}</b>"
		tempo_label.markup      = "<b>#{tempo_label.text}</b>"
		tool_label.markup       = "<b>#{tool_label.text}</b>"
		property_label.markup   = "<b>#{property_label.text}</b>"
		modify_label.markup     = "<b>#{modify_label.text}</b>"
		
		#canvas.add_events(Gdk::EventMask::BUTTON_PRESS_MASK.nick)
	end
	
	def grid_set(canvas_size,grid_size)
		UI::canvas.signal_connect("draw") do |_widget,cr| #i think _widget means current widget.
			#if @startup == true
			#	@startup = false
				gr_gray  = [0.3,0.5,0.9,1.0]
				gr_dgray = [0.5,0.5,0.5,0.1]

				bg_blck = [0.1,0.1,0.1,1.0]
				# fill background with black
				cr.set_source_rgba(bg_blck)
				cr.paint
				cr.set_source_rgba(gr_gray)
				#If needed, place a center point on the grid in the future at this point
				x = grid_size
				while x < canvas_size
					y = grid_size
					while y < canvas_size
						cr.circle(x,y,1)
						cr.fill
						y += grid_size
					end
					x += grid_size
				end
				# generate the connection points between grid points
				cr.set_source_rgba(gr_dgray)
				x = grid_size
				division = 4
				y = canvas_size - grid_size
				while x < canvas_size
					cr.move_to(x,grid_size)
					cr.line_to(x,canvas_size-grid_size)
					cr.set_line_width(1)
					cr.stroke
					x += grid_size*division
				end
				y = grid_size
				x = canvas_size - grid_size
				while y < canvas_size
					cr.move_to(grid_size,y)
					cr.line_to(canvas_size-grid_size,y)
					cr.set_line_width(1)
					cr.stroke
					y += grid_size*division
				end
			#end
		end #event handler end
	end

end

class Tool
	def initialize
		@tool_id = 1
	end
	def set_tool(id)
		@tool_id = id
		case
			when @tool_id == 1
				UI::main_tool_1.active = true
				UI::path_builder.sensitive = false
				UI::tool_descrip.text = "Select"
				UI::canvas.queue_draw
			when @tool_id == 2 
				UI::main_tool_2.active = true
				UI::path_builder.sensitive = false
				UI::tool_descrip.text = "Place"
				UI::canvas.queue_draw
			when @tool_id == 3 
				UI::main_tool_3.active = true 
				UI::path_builder.sensitive = false
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