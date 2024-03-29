# Initial Date: November 26, 2011]
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
# This file holds the launch code for Receipt Maker NG

# We prefix these procedures with ' because we are in the global namespace now, and we don't want to pollute it.

## Main Arrays
# program
# profile

package provide app-nextgenrm 1.0

proc 'nextGenRM_sourceReqdFiles {} {
    #****f* 'nextGenRM_sourceReqdFiles/global
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
    #	'nextGenRM_sourceOtherFiles
    #
    #***
	## All files that need to be sourced should go here. That way if any of them fail to load, we'll catch it.

	#Modify the Auto_path so our 'package requires' work.
        ##
        ## Binaries
        ##
	#lappend ::auto_path [file join [file dirname [info script]]]
        #lappend ::auto_path [file join [file dirname [info script]] Binaries]
        #lappend ::auto_path [file join [file dirname [info script]] Binaries sqlite3.3.8]
	#lappend ::auto_path [file join [file dirname [info script]] Binaries tkdnd2.2]

	##
        ## 3rd party tcl scripts
        ##
	lappend ::auto_path [file join [file dirname [info script]] Libraries]
	lappend ::auto_path [file join [file dirname [info script]] Libraries autoscroll]
	#lappend ::auto_path [file join [file dirname [info script]] Libraries csv]
	lappend ::auto_path [file join [file dirname [info script]] Libraries tablelist5.4]
	lappend ::auto_path [file join [file dirname [info script]] Libraries tooltip]
	lappend ::auto_path [file join [file dirname [info script]] Libraries about]
	lappend ::auto_path [file join [file dirname [info script]] Libraries debug]
	lappend ::auto_path [file join [file dirname [info script]] Libraries img]

	##
        ## Project built scripts
        ##
	lappend ::auto_path [file join [file dirname [info script]] Modules]
	lappend ::auto_path [file join [file dirname [info script]] Modules Core]

	
	## Start the Package Require
	## System Packages
	package require msgcat

	## 3rd Party modules
	#package require tkdnd
	package require Tablelist_tile 5.4
	package require tooltip
	package require autoscroll
	package require img::png
	#package require csv
	package require debug
	package require aboutwindow

	## ReceiptMaker NG
    package require rm_ng
	
	# Import namespace commands 
    namespace import 'debug::*
    namespace import msgcat::mc
	
	# Source files that are not in a package
        #source [file join [file dirname [info script]] Libraries popups.tcl]
        #source [file join [file dirname [info script]] Libraries errorMsg_gui.tcl]

        #'debug "Loaded"
}


proc 'nextGenRM_initVariables {} {
    #****f* initVariables/Disthelper_Helper
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2011 - Casey Ackels
    #
    # FUNCTION
    #
    #
    # SYNOPSIS
    #	Initialize program defaults. Create new file if one does not exist.
    #
    # CHILDREN
    #	N/A
    #
    # PARENTS
    #
    #
    # NOTES
    #
    # SEE ALSO
    #
    #***
    global settings debug program header profile



    set program(Name) "Receipt Maker NG"
    set program(Version) "Alpha"
    tk appname $program(Name)

	#'debug pwd [pwd]
	
	set program(Profiles) [file join $program(Path) Profiles]
	set program(PCL) [file join $program(Path) PurchasedList]
	set program(fileGateway) "" ;# Used to determine if need to create a new profile/purchased list, or clone an existing file
	
	# Create the directories
	file mkdir $program(Profiles)
	file mkdir $program(PCL)
	

	
	# Defaults
	#set profile(Store) "nolist"
	

}


proc 'nextGenRM_loadSettings {} {
    #****f* 'nextGenRM_loadSettings/global
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2008 - Casey Ackels
    #
    # FUNCTION
    #	Load the mandatory defaults. Everything else should be loaded in options
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
    #	'nextGenRM_loadOptions
    #
    #***
    global settings debug program header
		# Basic variable initialization
		
		# Enable / Disable Debugging
		set debug(onOff) on
		console show
		
		# Files
		set program(Path) [pwd]
		set program(Settings) [file join $program(Path) settings.txt]
	
		# Determine if settings file has been created
		# If file exists, read the variables (settings)
		if {![file exists $program(Settings)]} {
				'debug settings.txt doesn't exist. Creating...
				set Settings [open $program(Settings) w+]
		
				# Create default profile
				'debug $Settings "profile(Store) DefaultStore"
				chan close $Settings
	
		} else {
				'debug settings.txt exists. Opening...
				set Settings [open $program(Settings) r]
				'debug Settings: $Settings

				set readSettings [split [chan read $Settings] \n]
				chan close $Settings
			
				foreach line $readSettings {
						if {$line eq ""} {continue}
						set l_line [split $line " "]
						set [lindex $l_line 0] [join [lrange $l_line 1 end] " "]
						'debug $[lindex $l_line 0]
				}
		}
		# Check to see if we have new default settings
		'nextGenRM_initVariables
		puts "Loaded variables"
		nextgenrm_Icons::InitializeIcons
}


# Load required files / packages
'nextGenRM_sourceReqdFiles

# Load the config file
'nextGenRM_loadSettings

# Load the Option Database options
#'nextGenRM_loadOptions

# Start the GUI
#disthelper::parentGUI
nextgenrm::parentGUI
# Load the rest of the files
#'nextGenRM_sourceOtherFiles