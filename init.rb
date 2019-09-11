require_relative "proc_midi"
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
		grid_center
		initialize_provider
		apply_style(UI::midinous,@provider)
		apply_style(UI::prop_list_view,@provider)
	end
	
	def grid_center #center the grid
		UI::canvas_h_adj.set_value(CANVAS_SIZE/3.1)
		UI::canvas_v_adj.set_value(CANVAS_SIZE/2.4)
	end
	
	def apply_style(widget, provider)
    style_context = widget.style_context
    style_context.add_provider(provider, Gtk::StyleProvider::PRIORITY_USER)
    return unless widget.respond_to?(:children)
    widget.children.each do |child|
      apply_style(child, provider)
    end
  end
	
	def initialize_provider
		css_file = "./midinous_themes.css"
    @provider = Gtk::CssProvider.new
    @provider.load_from_path(css_file)
  end
	
end

init  = Init_Prog.new
Times = Time.new
#init.grid_center # Setting Grid Center here ensures the background always gets drawn first

module Event_Router
	extend Key_Bindings
	#For key bindings
	UI::midinous.signal_connect("key-press-event")           { |obj, event| route_key(event) }
	
	#For generic events
	UI::tempo.signal_connect("value-changed")                { |obj| CC.set_tempo(obj.value) }
	
	#For keys
	UI::main_tool_1.signal_connect("keybinding-event")       {Active_Tool.set_tool(1)}
	UI::main_tool_2.signal_connect("keybinding-event")       {Active_Tool.set_tool(2)}
	UI::main_tool_3.signal_connect("keybinding-event")       {Active_Tool.set_tool(3)}
	UI::main_tool_4.signal_connect("keybinding-event")       {Active_Tool.set_tool(4)}
	UI::path_builder.signal_connect("keybinding-event")      {CC.canvas_generic("path")}
	UI::prop_mod.signal_connect("changed")                   {Pl.check_input(UI::prop_mod.text)}
	UI::prop_mod.signal_connect("keybinding-event")          {CC.canvas_generic("prop")}
	UI::stop.signal_connect("keybinding-event")              {CC.canvas_stop}
	UI::play.signal_connect("keybinding-event")              {CC.canvas_play}
	
	#For clicks
	UI::main_tool_1.signal_connect("button-press-event")     {Active_Tool.set_tool(1)}
	UI::main_tool_2.signal_connect("button-press-event")     {Active_Tool.set_tool(2)}
	UI::main_tool_3.signal_connect("button-press-event")     {Active_Tool.set_tool(3)}
	UI::main_tool_4.signal_connect("button-press-event")     {Active_Tool.set_tool(4)}
	UI::path_builder.signal_connect("button-press-event")    {CC.canvas_generic("path")}
	UI::prop_list_selection.signal_connect("changed")    	   {Pl.prop_list_select(UI::prop_list_selection.selected)}
	UI::prop_mod_button.signal_connect("button-press-event") {CC.canvas_generic("prop")}
	UI::stop.signal_connect("button-press-event")            {CC.canvas_stop}
	UI::play.signal_connect("button-press-event")            {CC.canvas_play}
	
	#Canvas Events
	UI::canvas.signal_connect("delete-selected-event")       {              CC.canvas_del                 }
	UI::canvas.signal_connect("button-press-event")          { |obj, event| CC.canvas_press(event)        }
	UI::canvas.signal_connect("motion-notify-event")         { |obj, event| CC.canvas_drag(obj,event)     }
	UI::canvas.signal_connect("button-release-event")        { |obj, event| CC.canvas_release(obj,event)  }                             
	UI::canvas.signal_connect("draw")                        { |obj, cr|    CC.canvas_draw(cr)        }
	UI::canvas.signal_connect("beat-up")                     { CC.canvas_grid_change("+")                 }
	UI::canvas.signal_connect("beat-dn")                     { CC.canvas_grid_change("-")                 }
	UI::canvas.signal_connect("beat-note-up")                { CC.canvas_grid_change("++")                }
	UI::canvas.signal_connect("beat-note-dn")                { CC.canvas_grid_change("--")                }
	UI::canvas.signal_connect("travel-event")                { CC.canvas_travel                           }
end

