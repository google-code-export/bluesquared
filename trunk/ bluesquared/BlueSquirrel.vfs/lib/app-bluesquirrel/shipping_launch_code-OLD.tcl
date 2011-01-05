# Creator: Casey Ackels
# Initial Date: October 28th, 2006]
# Massive Rewrite: February 2nd, 2007
# Last Updated: November 10th, 2007
# Dependencies: See Below
#-------------------------------------------------------------------------------
#
# Subversion
#
# $Revision: 6 $
# $LastChangedBy: casey $
# $LastChangedDate: 2007-02-17 13:02:08 -0800 (Sat, 17 Feb 2007) $
#
########################################################################################

##
## - Overview
# This file holds the launch code for List Display.

# Definitions for prefixes of Variables
# G = Global
# S = String
# L = List
# I = Integer (Do not use this unless you are certain it is an Integer and not a plain string)

## Coding Conventions
# - Namespaces: These should have two parts, a _gui and a _code. Both words should be capitalized. i.e. Example_Code

# - Procedures: Proc names should have two words. The first word lowercase the first character of the first word,
#   will be uppercase. I.E sourceFiles, sourceFileExample


##
## Source Files
##

# We use the prefix 'shipping_ because we are in the global namespace now, and we don't want to pollute it.


proc 'shipping_sourceFiles {} {


    catch {
	## All files that need to be sourced should go here. That way if any of them fail to load, we'll catch it.
	
	#Modify the Auto_path so our 'package requires' work.
	## Only use this if we are FreeWrapped
	lappend ::auto_path [file join [file dirname [info script]]]
	lappend ::auto_path [file join [file dirname [info script]] Libraries]
	lappend ::auto_path [file join [file dirname [info script]] Libraries tablelist4.8]
	
	#Modify the Auto_path so our 'package requires' work.
	## Only use this if we are NOT FreeWrapped.
	#lappend ::auto_path [file join [pwd] Backend_Code]
	#lappend ::auto_path [file join [pwd] Gui]
	#lappend ::auto_path [file join [pwd] Libraries]
	#lappend ::auto_path [file join [pwd] Libraries autoscroll]
	#lappend ::auto_path [file join [pwd] Libraries tile0.7.8]
	
	# Start the Package Require
	package require combobox
	# ** NOTE **
	# The file tablelistEdit.tcl has been edited for the binding of <Return> and <KP_Enter>
	# Lines 87-89; the original code is commented out.
	package require Tablelist_tile 4.8
	
	
	
	# Source the Gui files
	source [file join [file dirname [info script]] Modules Shipping parent_gui.tcl]
	source [file join [file dirname [info script]] Modules Shipping shipping_window_gui.tcl]
	source [file join [file dirname [info script]] Modules Shipping inventory_window_gui.tcl]
	source [file join [file dirname [info script]] Modules Shipping rollstock_window_gui.tcl]
	
	# Source the Error files
	source [file join [file dirname [info script]] Libraries errorMsg_gui.tcl]
	
	# Source the Backend_Code files
	source [file join [file dirname [info script]] Modules Shipping shipping_code.tcl]

	} S_errMsg
	
	if {([info exists S_errMsg]) && ($S_errMsg != "")} {
	    tk_messageBox \
                -parent . \
                -default ok \
                -icon warning \
                -title "Couldn't find File" \
                -message "I'm sorry, but I need a file to start. Can you please locate it, and put it here:\n[pwd]\n\n$S_errMsg"
	    
	    unset S_errMsg
	    exit ;# Don't even open the GUI. Exit right away.
    }
}


proc 'shipping_loadOptions {} {
    #option add *font {tahoma 10}
    option add *Listbox.font {tahoma 12}
    
    # Theme setting for Tile
    ttk::style theme use $ttk::currentTheme
    #style configure TCombobox -fieldbackground yellow
    #style theme use clam
}


proc 'shipping_LoadSettings {} {
    global programPath
    
    if {[catch {open LD_Defaults.txt r} fd]} {
	puts "unable to load defaults"
    } else {
	set settings [split [read $fd] \n]
	catch {close $fd}
	
	foreach line $settings {
	    if {$line == ""} {continue}
	    set l_line [split $line " "]
	    set [lindex $l_line 0] [join [lrange $l_line 1 end] " "]
	}
    }
}
# Load all files / packages
'shipping_sourceFiles

# Load the Option Database options
'shipping_loadOptions

# Load the config file
'shipping_LoadSettings

# Finally start the GUI
#Shipping_Gui::shippingGUI
listDisplay::parentGUI