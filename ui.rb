class GtkRadioButtonEx < Gtk::RadioButton
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

		def midinous 
			@builder.get_object("midinous")
		end
		midinous.add_events("key-press-mask")
		def canvas
			@builder.get_object("canvas")
		end
		def canvas_viewport
			@builder.get_object("canvas_viewport")
		end
		def canvas_scroll_window
			@builder.get_object("canvas_scroll_window")
		end
		def canvas_h_adj
			@builder.get_object("canvas_scroll_h")
		end
		def canvas_v_adj
			@builder.get_object("canvas_scroll_v")
		end

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
		canvas.add_events("button-press-mask")
		canvas.add_events("button-release-mask")
		canvas.add_events("pointer-motion-mask")
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
				
				# generate the grid with a center point
				x = grid_size
				while x < canvas_size
					y = grid_size
					while y < canvas_size
=begin
						if y == (canvas_size/2) && x == (canvas_size/2)
							cr.circle(x,y,5)
							cr.fill
						else
							cr.circle(x,y,1)
							cr.fill
						end
=end
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