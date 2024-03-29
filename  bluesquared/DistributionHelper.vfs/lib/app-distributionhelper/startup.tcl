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
	## All files that need to be sourced should go here. That way if any of them fail to load, we'll catch it.

	#Modify the Auto_path so our 'package requires' work.
    ##
    ## Binaries
    ##
	lappend ::auto_path [file join [file dirname [info script]]]
    lappend ::auto_path [file join [file dirname [info script]] Binaries]
    #lappend ::auto_path [file join [file dirname [info script]] Binaries sqlite3.3.8]
	lappend ::auto_path [file join [file dirname [info script]] Binaries tkdnd2.2]

	##
    ## 3rd party tcl scripts
    ##
	lappend ::auto_path [file join [file dirname [info script]] Libraries]
	lappend ::auto_path [file join [file dirname [info script]] Libraries autoscroll]
	lappend ::auto_path [file join [file dirname [info script]] Libraries csv]
	lappend ::auto_path [file join [file dirname [info script]] Libraries tablelist5.4]
    lappend ::auto_path [file join [file dirname [info script]] Libraries tcom3.9]
    #lappend ::auto_path [file join [file dirname [info script]] Libraries twapi]
	lappend ::auto_path [file join [file dirname [info script]] Libraries tooltip]
    lappend ::auto_path [file join [file dirname [info script]] Libraries about]
	lappend ::auto_path [file join [file dirname [info script]] Libraries debug]

	##
    ## Project built scripts
    ##
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
	package require Tablelist_tile 5.4
    package require tcom
    #package require twapi
	package require tooltip
	package require autoscroll
	package require csv
	package require debug

	## Distribution Helper modules
	package require disthelper_core
	package require disthelper_importFiles
    package require aboutwindow


	# Source files that are not in a package
    source [file join [file dirname [info script]] Libraries popups.tcl]
    source [file join [file dirname [info script]] Libraries errorMsg_gui.tcl]
    source [file join [file dirname [info script]] Libraries StreetSuffixState.tcl]
    
    loadSuffix ;# Initialize variables from StreetSuffixState.tcl
    
    load [file join [file dirname [info script]] Libraries twapi twapi-x86-3.1.17.dll]
    #source [file join [file dirname [info script]] Libraries debug.tcl]

        namespace import 'debug::'debug
        'debug "Loaded"
}

proc 'distHelper_initVariables {} {
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
    global settings header mySettings env intl ship

    # hackish, but this will allow us to add new defaults/settings without killing an existing config file.
    
    # Create personal settings file %appdata%
    if {[file isdirectory [file join $env(APPDATA) E_A]] == 0} {
        file mkdir [file join $env(APPDATA) E_A]
    }
    
    # Find out where we are in the system
    set settings(Home) [pwd]
    
    #if {![info exists settings(Home)]} {
    #    # Application location
    #    set settings(Home) [pwd]
    #    'debug Settings(Home) $settings(Home)
    #}

    if {![info exists settings(outFilePath)]} {
        # Location for saving the file
        # DEPRECATED 7-23
        set settings(outFilePath) [file dirname $settings(Home)]
    }
    
    if {![info exists mySettings(outFilePath)]} {
        # NEW 7-23 / Putting these settings into %APPDATA% instead of the server.
        # Location for saving the file
        set mySettings(outFilePath) [file dirname $settings(Home)]
    }

    if {![info exists settings(outFilePathCopy)]} {
        # Location for saving a copy of the file (this should just be up one directory)
        # DEPRECATED 7-23
        set settings(outFilePathCopy) [file dirname $settings(Home)]
    }
    
    if {![info exists mySettings(outFilePathCopy)]} {
        # NEW 7-23 / Putting these settings into %APPDATA% instead of the server.
        # Location for saving a copy of the file (this should just be up one directory)
        set mySettings(outFilePathCopy) [file dirname $settings(Home)]
    }

    if {![info exists settings(sourceFiles)]} {
        # Default for finding the source import files
        # DEPRECATED 7-23
        set settings(sourceFiles) [file dirname $settings(Home)]
    }
    
    if {![info exists mySettings(sourceFiles)]} {
        # NEW 7-23 / Putting these settings into %APPDATA% instead of the server.
        # Default for finding the source import files
        set mySettings(sourceFiles) [file dirname $settings(Home)]
    }

    if {![info exists settings(importOrder)]} {
        # Set default for headers; wording is used internally
        set settings(importOrder) [list shipVia Company Consignee delAddr delAddr2 delAddr3 City State Zip Phone Quantity Version Date Contact Email 3rdParty]
    }

    if {![info exists settings(shipvia3P)]} {
        # Set possible 3rd party shipvia codes
        set settings(shipvia3P) [list 067 154 166]
    }

    if {![info exists settings(shipviaPP)]} {
        # Set possible pre paid shipvia codes
        set settings(shipviaPP) [list 017 018]
    }

    if {![info exists settings(BoxTareWeight)]} {
        # Box Tare Weight
        set settings(BoxTareWeight) .566
    }

    #
    # Header
    #
    
    if {![info exists header(shipvia)]} {
        set header(shipvia) [list ShipViaCode "ship via" shipvia]
    }

    if {![info exists header(company)]} {
        set header(company) [list ShipToName company destination "company name"]
    }

    if {![info exists header(attention)]} {
        # Variations on spelling of consignee
        set header(attention) [list ShipToContact contact attention attn attn:]
    }

    if {![info exists header(address1)]} {
        set header(address1) [list ShipToAddressline1 address address1 "address 1" add add1 "add 1" addr addr1 "addr 1"]
    }

    if {![info exists header(address2)]} {
        set header(address2) [list ShipToAddressline2 address2 "address 2" add2 "add 2" addr2 "addr 2"]
    }

    if {![info exists header(address3)]} {
        set header(address3) [list ShipToAddressline3 address3 "address 3" add3 "add 3" addr3 "addr 3"]
    }

    if {![info exists header(CityStateZip)]} {
        set header(CityStateZip) [list city-state-zip city-st-zip "city state zip" "city st zip" csv state/region]
    }

    if {![info exists header(city)]} {
        set header(city) [list City ShipToCity]
    }
    
    if {![info exists header(state)]} {
        set header(state) [list ShipToState st st. state]
    }
    
    if {![info exists header(country)]} {
        set header(country) [list country ShipToCountry]
    }

     if {![info exists header(zip)]} {
        set header(zip) [list ShipToZipCode zip zipcode "zip code" postalcode "postal code" postal]
    }
    
    if {![info exists header(phone)]} {
        set header(phone) [list phone ShipToPhone]
    }
    
    if {![info exists header(email)]} {
        set header(email) [list email ShipToEmail]
    }
    
    if {![info exists header(shipdate)]} {
        set header(shipdate) [list "Ship Date" shipdate]
    }

     if {![info exists header(BatchNumberReference)]} {
        # This will hold the job number and a alpha at the end
        # E.G 60155_A (or 60155A)
        set header(BatchNumberReference) [list BatchNumberReference]
    }

    if {![info exists header(Reference1)]} {
        # After we output the file, Reference1 will hold the job number
        set header(Reference1) [list Reference1]
    }
    
    if {![info exists header(version)]} {
        # This is used in the original file, and reassigned to the Reference2 column
        set header(version) [list version vers]
    }
    
    if {![info exists header(Reference2)]} {
        # After we output the file, Reference2 will hold the Version/Qty
        set header(Reference2) [list Reference2]
    }

    if {![info exists header(quantity)]} {
        # This is used in the original file, and reassigned to the Reference2 column
        set header(quantity) [list quantity qty]
    }
    
    if {![info exists header(PackageQuantity)]} {
        set header(PackageQuantity) [list PackageQuantity]
    }

    if {![info exists header(3rdPartyNumber)]} {
        # 3P Account Number
        set header(3rdPartyNumber) [list ThirdPartyAccountNumber "3rd Party" 3rdParty 3p]
    }
    
    if {![info exists header(3rdPartyCode)]} {
        # Customer Code within Process Shipper
        set header(3rdPartyCode) [list ThirdPartyID]
    }
    #
    # - These are used internally
    # 
    if {![info exists header(pieceweight)]} {
        set header(pieceweight) [list pieceweight "pc weight" "piece weight" "pc wgt"]
    }

    if {![info exists header(fullbox)]} {
        set header(fullbox) [list fullbox "full box"]
    }
    
    if {![info exists header(residential)]} {
        # This column is used when we use address cleansing. We run it through Process Shipper once, then open it again in EA.
        set header(residential) [list ResidentialDelivery]
    }
    
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
    #	'distHelper_loadOptions
    #
    #***
    global settings debug program header customer3P env mySettings international company shipVia3P tcl_platform

    # Enable / Disable Debugging
    # See 'distHelper_sourceReqdFiles for the [namespace import] command
    set debug(onOff) on
    #console show
    puts "Platform: $tcl_platform(osVersion)"
    puts [parray tcl_platform]

    
    set program(Version) 3
    set program(PatchLevel) 0
    set program(beta) ""
    set program(Name) "Efficiency Assist"
    set program(FullName) "$program(Name) - $program(Version).$program(PatchLevel) $program(beta)"
    
    tk appname $program(Name)

    # Theme setting for Tile
    #ttk::style theme use xpnative
    #puts "theme names: [ttk::style theme names]"


    # Import msgcat namespace so we only have to use [mc]
    namespace import msgcat::mc

    #config file - these variables are "system wide"; and are not to be personalized.
    if {[catch {open config.txt r} fd]} {
        puts "unable to load defaults"
        puts "execute initVariables"

        # Initialize default values
        #'distHelper_initVariables
    } else {
	
    set configFile [split [read $fd] \n]
	catch {chan close $fd}

        foreach line $configFile {
            if {$line == ""} {continue}
            set l_line [split $line " "]
            set [lindex $l_line 0] [join [lrange $l_line 1 end] " "]
        }
        puts "Loaded variables"
        #parray company
    }
    
    set fd "" ;# Make sure we are cleared out before reusing.
    # Load Personalized settings
    if {[catch {open [file join $env(APPDATA) E_A settings.txt] r} fd]} {
        puts "Cannot find settings.txt; loading defaults"
        set settings(newSettingsTxt) no
        
        'distHelper_initVariables ;# load defaults
        
    } else {
        set settings(newSettingsTxt) yes
        set settingsFile [split [read $fd] \n]
        catch {chan close $fd}
        
        foreach line $settingsFile {
                if {$line == ""} {continue}
                set l_line [split $line " "]
                set [lindex $l_line 0] [join [lrange $l_line 1 end] " "]
                puts "line: $line"
        }
    }
    # Initialize default values
    'distHelper_initVariables
}


# Load the config file
'distHelper_loadSettings

# Load required files / packages
'distHelper_sourceReqdFiles

# Load the Option Database options
#'distHelper_loadOptions

# Start the GUI
disthelper::parentGUI