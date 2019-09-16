require "midi"
require "gtk3"
require_relative "init"
#require_relative "debug"

Gtk.main

#TODO
# Add an "advanced properties" area below the main one to have more control over points.
# Stop button should be disabled on program start
# Remove the "advance" and "backtrack" tools
# Add logic to allow relative pitches on nodes
#   Utilize the SCALES constant
# Reconfigure window logic to allow closing. Check notes on event handler
# Set up save/load logic, should only have to save the Nouspoints array
# Add key binding to change path mode
# Add "logic view" and utilize a secondary path build function and button label "Build Logic"
#   Add dialog for logic controls?
# Control S to Save?