require_relative "proc_midi"
require_relative "constants"
require_relative "logic"
require_relative "./style/ui"
require_relative "canvas"
require_relative "key_bindings"

class Init_Prog

	def initialize #Build the user interface, initiate the objects in the program
		UI::canvas.set_size_request(CANVAS_SIZE,CANVAS_SIZE)
		UI::canvas_h_adj.set_upper(CANVAS_SIZE)
		UI::canvas_v_adj.set_upper(CANVAS_SIZE)
		grid_center
		initialize_provider
		apply_style(UI::midinous,@provider)
		apply_style(UI::prop_list_view,@provider)
		apply_style(UI::file_chooser,@provider)
		apply_style(UI::confirmer,@provider)
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
		css_file = "./bin/style/midinous_themes.style"
    @provider = Gtk::CssProvider.new
    @provider.load_from_path(css_file)
  end
	
end

init  = Init_Prog.new
Times = Time.new
#init.grid_center # Setting Grid Center here ensures the background always gets drawn first

module Event_Router
	extend Key_Bindings
	
	#For window keep-alives
	UI::midinous.signal_connect("delete-event")               {true}
	UI::file_chooser.signal_connect("delete-event")           {true}
	UI::confirmer.signal_connect("delete-event")              {true}
	
	#For key bindings
	UI::midinous.signal_connect("key-press-event")            { |obj, event| route_key(event) }
																													  
	#For general events                                       
	UI::tempo.signal_connect("value-changed")                 { |obj| CC.set_tempo(obj.value) }
	UI::root_select.signal_connect("value-changed")           { |obj| CC.set_scale(UI::scale_combo.active_iter[0],obj.value) }
	
	#For keys
	UI::main_tool_1.signal_connect("keybinding-event")        {Active_Tool.set_tool(1)}
	UI::main_tool_2.signal_connect("keybinding-event")        {Active_Tool.set_tool(2)}
	UI::main_tool_3.signal_connect("keybinding-event")        {Active_Tool.set_tool(3)}
	UI::main_tool_4.signal_connect("keybinding-event")        {Active_Tool.set_tool(4)}
	UI::path_builder.signal_connect("keybinding-event")       {CC.canvas_generic("path")}
	UI::prop_mod.signal_connect("changed")                    {Pl.check_input(UI::prop_mod.text)}
	UI::prop_mod.signal_connect("keybinding-event")           {CC.canvas_generic("prop")}
	UI::stop.signal_connect("keybinding-event")               {CC.canvas_stop}
	UI::play.signal_connect("keybinding-event")               {CC.canvas_play}

	
	#For clicks
	UI::main_tool_1.signal_connect("button-press-event")      {Active_Tool.set_tool(1)}
	UI::main_tool_2.signal_connect("button-press-event")      {Active_Tool.set_tool(2)}
	UI::main_tool_3.signal_connect("button-press-event")      {Active_Tool.set_tool(3)}
	UI::main_tool_4.signal_connect("button-press-event")      {Active_Tool.set_tool(4)}
	UI::path_builder.signal_connect("button-press-event")     {CC.canvas_generic("path")}
	UI::prop_list_selection.signal_connect("changed")    	    {Pl.prop_list_select(UI::prop_list_selection.selected)}
	UI::prop_mod_button.signal_connect("button-press-event")  {CC.canvas_generic("prop")}
	UI::stop.signal_connect("button-press-event")             {CC.canvas_stop}
	UI::play.signal_connect("button-press-event")             {CC.canvas_play}
	UI::scale_combo.signal_connect("changed")                 {CC.set_scale(UI::scale_combo.active_iter[0],CC.root_note)}

	
	#For file operations
	UI::file_new.signal_connect("button-press-event")         {UI.confirm("new")}       #Confirm first with a dialog if there are unsaved changes.
	UI::file_open.signal_connect("button-press-event")        {UI.file_oper("open")}    #Change the label to "Open"
	UI::file_save.signal_connect("button-press-event")        {UI.file_oper("save")}    #Change the label to "Save", or save automatically if the working file exists.
	UI::file_save_as.signal_connect("button-press-event")     {UI.file_oper("saveas")}  #Change the label to "Save As"
	UI::file_quit.signal_connect("button-press-event")        {UI.confirm("quit")}      #Confirm first with a dialog if there are unsaved changes.
	
	UI::confirmer_confirm.signal_connect("button-press-event"){UI.confirm_act("yes")}
	UI::confirmer_cancel.signal_connect("button-press-event") {UI.confirm_act("no")}
	
	UI::file_operation.signal_connect("button-press-event")   {UI.file_oper_act("yes")} #If open, confirm first with a dialog if there are unsaved changes. If save/save as, overwrite confirmation should automatically appear. Otherwise, use confirmer.
	UI::file_cancel.signal_connect("button-press-event")      {UI.file_oper_act("no")}
	UI::file_chooser.signal_connect("selection-changed")      {UI.file_input_check("chooser")}
	UI::file_name.signal_connect("changed")                   {UI.file_input_check("name")}
	
	#For accelerators
	UI::menu_commands.connect(Gdk::Keyval::KEY_n,4,0)         {UI.confirm("new")}
	UI::menu_commands.connect(Gdk::Keyval::KEY_o,4,0)         {UI.file_oper("open")}
	UI::menu_commands.connect(Gdk::Keyval::KEY_s,4,0)         {UI.file_oper("save")}
	UI::menu_commands.connect(Gdk::Keyval::KEY_s,5,0)         {UI.file_oper("saveas")}
	UI::menu_commands.connect(Gdk::Keyval::KEY_q,4,0)         {UI.confirm("quit")}
	UI::canvas_commands.connect(Gdk::Keyval::KEY_a,4,0)       {Pl.select_all           if Active_Tool.tool_id == 1}
	UI::canvas_commands.connect(Gdk::Keyval::KEY_x,4,0)       {Pl.copy_points("cut")   if Active_Tool.tool_id == 1}
	UI::canvas_commands.connect(Gdk::Keyval::KEY_c,4,0)       {Pl.copy_points("copy")  if Active_Tool.tool_id == 1}
	UI::canvas_commands.connect(Gdk::Keyval::KEY_v,4,0)       {Pl.paste_points         if Active_Tool.tool_id == 1}
	
	#Canvas Events
	UI::canvas.signal_connect("button-press-event")           { |obj, event| CC.canvas_press(event) }
	UI::canvas.signal_connect("motion-notify-event")          { |obj, event| CC.canvas_drag(obj,event) }
	UI::canvas.signal_connect("button-release-event")         { |obj, event| CC.canvas_release(obj,event) }                             
	UI::canvas.signal_connect("draw")                         { |obj, cr|    CC.canvas_draw(cr) }
	UI::canvas.signal_connect("delete-selected-event")        {CC.canvas_del}	
	UI::canvas.signal_connect("beat-up")                      {CC.canvas_grid_change("+")}
	UI::canvas.signal_connect("beat-dn")                      {CC.canvas_grid_change("-")}
	UI::canvas.signal_connect("beat-note-up")                 {CC.canvas_grid_change("++")}
	UI::canvas.signal_connect("beat-note-dn")                 {CC.canvas_grid_change("--")}
	UI::canvas.signal_connect("travel-event")                 {CC.canvas_travel}
	UI::canvas.signal_connect("cycle-play-mode-bck")          {Pl.play_mode_rotate(-1)}
	UI::canvas.signal_connect("cycle-play-mode-fwd")          {Pl.play_mode_rotate(1)}
	UI::canvas.signal_connect("set-start")                    {Pl.set_start}
	UI::canvas.signal_connect("del-path-to")                  {Pl.delete_paths_to(CC.nouspoints)}
	UI::canvas.signal_connect("del-path-from")                {Pl.delete_paths_from(CC.nouspoints)}
	UI::canvas.signal_connect("set-path-mode-h")              {Pl.set_path_mode("horz")}
	UI::canvas.signal_connect("set-path-mode-v")              {Pl.set_path_mode("vert")}
	UI::canvas.signal_connect("note-inc-up")                  {Pl.set_note(1)}
	UI::canvas.signal_connect("note-inc-dn")                  {Pl.set_note(-1)}
end

