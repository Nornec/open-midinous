require "midi"
require "gtk3"
require_relative "init"
require_relative "debug"

Gtk.main

#TODO
# Add "transform" as a play mode? One point changes parms after playing? Could be any number of parameters, may require a dialog.
# Remove the "advance" and "backtrack" tools?
# Add logic to allow relative pitches on nodes
#   Utilize the SCALES constant
# Reconfigure window logic to allow closing. Check notes on event handler
# Set up save/load logic, should only have to save the Nouspoints array somehow
# Add key binding to change path mode (between horz and vert)
# Add "logic view" and utilize a secondary path build function and button label "Build Logic"
#   Add dialog for logic controls?
# Control S to Save?
# Add more control to path deletion, so that you don't have to delete a point to delete a path.