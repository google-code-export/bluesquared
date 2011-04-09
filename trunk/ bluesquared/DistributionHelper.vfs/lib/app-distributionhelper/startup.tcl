# Creator: Casey Ackels
# Initial Date: February 13, 2011]
# Dependencies: See Below
#-------------------------------------------------------------------------------
#
# Subversion
#
# $Revision$
# $LastChangedBy$
# $LastChangedDate$
#
########################################################################################

##
## - Overview
# This file holds the launch code for Distribution Helper.

# Definitions for prefixes of Variables
# G = Global
# S = String
# L = List
# I = Integer (Do not use this unless you are certain it is an Integer and not a plain string)

## Coding Conventions
# - Namespaces: These should have two parts, a _gui and a _code. Both words should be capitalized. i.e. Example_Code

# - Procedures: Proc names should have two words. The first word lowercase the first character of the first word,
#   will be uppercase. I.E sourceFiles, sourceFileExample

# We use the prefix 'blueSquirrel_ because we are in the global namespace now, and we don't want to pollute it.

package provide app-disthelper 1.0

proc 'distHelper_sourceReqdFiles {} {
    #****f* 'distHelper_sourceReqdFiles/global
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2011 - Casey Ackels
    #
    # FUNCTION
    #	Sources the required files. This means a faster load time for the gui.
    #
    # SYNOPSIS
    #	Add required files to the source lists
    #
    # CHILDREN
    #	None
    #
    # PARENTS
    #	None
    #
    # NOTES
    #	N/A
    #
    # SEE ALSO
    #	'distHelper_sourceOtherFiles
    #
    #***
#console show
	## All files that need to be sourced should go here. That way if any of them fail to load, we'll catch it.
	
	#Modify the Auto_path so our 'package requires' work.
	lappend ::auto_path [file join [file dirname [info script]]]
        lappend ::auto_path [file join [file dirname [info script]] Binaries]
        #lappend ::auto_path [file join [file dirname [info script]] Binaries sqlite3.3.8]
	lappend ::auto_path [file join [file dirname [info script]] Binaries tkdnd2.2]
        
	
	lappend ::auto_path [file join [file dirname [info script]] Libraries]
	lappend ::auto_path [file join [file dirname [info script]] Libraries autoscroll]
	lappend ::auto_path [file join [file dirname [info script]] Libraries csv]
	#lappend ::auto_path [file join [file dirname [info script]] Libraries tablelist5.2]
	lappend ::auto_path [file join [file dirname [info script]] Libraries tooltip]
	
	
	lappend ::auto_path [file join [file dirname [info script]] Modules]
	lappend ::auto_path [file join [file dirname [info script]] Modules Core]
	lappend ::auto_path [file join [file dirname [info script]] Modules Importfiles]
	
	#
	## Start the Package Require
	#
	
	## System Packages
	package require msgcat
	
	## 3rd Party modules
	package require tkdnd
	#package require Tablelist_tile 5.2
	package require tooltip
	package require autoscroll
	package require csv
	
	## Distribution Helper modules
	#package require shipping
	package require disthelper_core
	package require disthelper_importFiles

	
	# Source the required files
        source [file join [file dirname [info script]] Libraries popups.tcl]
}


proc 'distHelper_sourceOtherFiles {} {
    #****f* 'distHelper_sourceOtherFiles/global
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 20011 - Casey Ackels
    #
    # FUNCTION
    #	Sources the rest of the files.
    #
    # SYNOPSIS
    #	Add the files / packages to the source lists
    #
    # CHILDREN
    #	None
    #
    # PARENTS
    #	None
    #
    # NOTES
    #	N/A
    #
    # SEE ALSO
    #	'blueSquirrel_sourceReqdFiles
    #
    #***
    catch {	
	# Source the Error files
	source [file join [file dirname [info script]] Libraries errorMsg_gui.tcl]
    
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


proc 'distHelper_loadOptions {} {
    #****f* 'distHelper_loadOptions/global
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2008 - Casey Ackels
    #
    # FUNCTION
    #	Load the options / configurations
    #
    # SYNOPSIS
    #	None
    #
    # CHILDREN
    #	None
    #
    # PARENTS
    #	None
    #
    # NOTES
    #	N/A
    #
    # SEE ALSO
    #	'distHelper_loadSettings
    #
    #***
    #option add *font {tahoma 10}
    #option add *Listbox.font {tahoma 8}
    
    # Theme setting for Tile
    ttk::style theme use $ttk::currentTheme
    
    Disthelper_Helper::initVariables
    ;# The ttk way, to change the background
    #ttk::style map TEntry -fieldbackground [list focus yellow]
    #ttk::style configure TEntry -fieldbackground [list focus yellow]
    #style configure TCombobox -fieldbackground yellow
    #style theme use clam
}


proc 'distHelper_loadSettings {} {
    #****f* 'distHelper_loadSettings/global
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2008 - Casey Ackels
    #
    # FUNCTION
    #	Load the defaults, this includes the path to BarTender among other things,
    #	that must be done at the client site.
    #
    # SYNOPSIS
    #	None
    #
    # CHILDREN
    #	None
    #
    # PARENTS
    #	None
    #
    # NOTES
    #	N/A
    #
    # SEE ALSO
    #	'distHelper_loadOptions
    #
    #***
    global settings
    
    if {[catch {open config.txt r} fd]} {
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

namespace import msgcat::mc
# Load required files / packages
'distHelper_sourceReqdFiles

# Load the Option Database options
'distHelper_loadOptions

# Load the config file
#'distHelper_loadSettings

# Start the GUI
#blueSquirrel::shippingGUI
disthelper::parentGUI

# Load the rest of the files
'distHelper_sourceOtherFiles