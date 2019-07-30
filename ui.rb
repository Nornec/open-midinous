class UI_Elements
	# Construct a Gtk::Builder instance and load our UI description
	def build_ui
		builder_file = "./midinous.glade"
		# Connect signal handlers to the constructed widgets
		@builder = Gtk::Builder.new(:file => builder_file)

		def midinous 
			@builder.get_object("midinous")
		end
		
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

		def loper_1
			@builder.get_object("loper_1")
		end		
		def loper_2
			@builder.get_object("loper_2")
		end		
		def loper_3
			@builder.get_object("loper_3")
		end		
		def loper_4
			@builder.get_object("loper_4")
		end	
		
	end
	
	def grid_set(canvas_size)
		canvas.signal_connect("draw") do |_widget, cr| #i think _widget means current widget.
			gr_gray = [0.5,0.5,0.9,1.0]
			bg_blck = [0.0,0.0,0.0,1.0]
			# fill background with black
			cr.set_source_rgba(bg_blck)
			cr.paint
			cr.set_source_rgba(gr_gray)
			
			# generate the grid
			grid_size = 50
			x = grid_size
			while x < canvas_size do
				y = grid_size
				while y < canvas_size do
					cr.circle(x,y,1)
					cr.fill
					y += grid_size
				end
				x += grid_size
			end
		canvas_h_adj.set_value(canvas_size/3)			
		canvas_v_adj.set_value(canvas_size/2)
		end
	end

end