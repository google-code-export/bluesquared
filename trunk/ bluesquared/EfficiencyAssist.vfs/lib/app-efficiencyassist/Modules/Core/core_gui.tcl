# Creator: Casey Ackels
# Initial Date: March 12, 2011]
# Dependencies: See Below
#-------------------------------------------------------------------------------
#
# Subversion
#
# $Revision: 508 $
# $LastChangedBy: casey.ackels $
# $LastChangedDate$
#
########################################################################################

##
## - Overview
# This file holds the parent GUI frame, buttons and menu for Distribution Helper

# Definitions for prefixes of Variables
# G = Global
# S = String
# L = List
# I = Integer (Do not use this unless you are certain it is an Integer and not a plain string)

## Coding Conventions
# - Namespaces:

# - Procedures: Proc names should have two words. The first word lowercase the first character of the first word,
#   will be uppercase. I.E sourceFiles, sourceFileExample

# Start GUI
package provide eAssist_core 1.0

namespace eval eAssist {}
namespace eval lib {}

proc eAssist::parentGUI {} {
    #****f* parentGUI/eAssist
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2011-2013 Casey Ackels
    #
    # FUNCTION
    #	Generate the parent GUI container and buttons (Cancel / Generate File)
    #
    # SYNOPSIS
    #	N/A
    #
    # CHILDREN
    #	eAssist::upsImportGUI
    #
    # PARENTS
    #	None
    #
    # NOTES
    #	None
    #
    # SEE ALSO
    #	N/A
    #
    #***
    global program settings btn log mb options user
    ${log}::debug Entering parentGUI

    set locX [expr {[winfo screenwidth . ] / 4 + [winfo x .]}]
    set locY [expr {[winfo screenheight . ] / 5 + [winfo y .]}]
    #wm geometry .wi 625x375+${locX}+${locY}
    wm geometry . 640x610+${locX}+${locY}
    
    wm protocol . WM_DELETE_WINDOW {eAssistSetup::SaveGlobalSettings; destroy .}
    wm protocol . WM_SAVE_YOURSELF {eAssistSetup::SaveGlobalSettings}

    
    wm title . $program(FullName)
    focus -force .

    # Create the Menu's
    set mb [menu .mb]
    . configure -menu $mb

    ### *** Main menu's are listed here. The sub-menu's are listed elsewhere.
    ## File
    menu $mb.file -tearoff 0 -relief raised -bd 2

    $mb add cascade -label [mc "File"] -menu $mb.file

    ## Module Menu - This is a dynamic menu for the active module.
    menu $mb.modMenu -tearoff 0 -relief raised -bd 2
    $mb add cascade -label [mc "Edit"] -menu $mb.modMenu


    ## Modules
    if {[llength $user($user(id),modules)] > 1} {
        # Create the main menu item
        menu $mb.module -tearoff 0 -relief raised -bd 2
        $mb add cascade -label [mc "Module"] -menu $mb.module
        
        # Add in the sub-menus        
        foreach mod $user($user(id),modules) {
            switch -- $mod {
                "Box Labels"    {$mb.module add command -label [mc "Box Labels"] -command {set options(geom,[lindex $settings(currentModule) 0]) [wm geometry .]; eAssist::buttonBarGUI BoxLabels 0}}
                "Batch Maker"   {$mb.module add command -label [mc "Batch Maker"] -command {set options(geom,[lindex $settings(currentModule) 0]) [wm geometry .]; eAssist::buttonBarGUI BatchMaker 1}}
                Setup           {$mb.module add command -label [mc "Setup"] -command {set options(geom,[lindex $settings(currentModule) 0]) [wm geometry .]; eAssist::buttonBarGUI Setup 2}}
                default         {${log}::critical "$mod: doesn't have a menu configuration setup."}
            }
        }
    }


    ## Help
    menu $mb.help -tearoff 0 -relief raised -bd 2
    $mb add cascade -label [mc "Help"] -menu $mb.help

    $mb.help add command -label [mc "About..."] -command { BlueSquared_About::aboutWindow 1}
    $mb.help add command -label [mc "Release Notes..."] -command { BlueSquared_About::aboutWindow 2}


    # Create the container frame
    ttk::frame .container
    pack .container -expand yes -fill both

 
    ##
    ## Control Buttons
    ##
    set btn(Bar) [ttk::frame .btnBar]
    pack $btn(Bar) -side bottom -anchor e -pady 13p -padx 5p
    
    ttk::button $btn(Bar).btn1
    ttk::button $btn(Bar).btn2

    # Start the gui
    # All frames that make up the GUI are children to .container  
    if {![info exists settings(currentModule)]} {
        set settings(currentModule) [list BatchMaker 1]
    }
    
    #${log}::debug CurrentModule: $settings(currentModule)
    eAssist::buttonBarGUI $settings(currentModule)

    
    eAssist_GUI::editPopup

} ;# End of parentGUI


proc eAssist::buttonBarGUI {args} {
    #****f* buttonBarGUI/eAssist
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2011-2014 Casey Ackels
    #
    # FUNCTION
    #	Controls what module we start in, and re-configure the button bar as needed, depending on what 'mode' we are in, or going to.
    #
    # SYNOPSIS
    #	N/A
    #
    # CHILDREN
    #	
    #
    # PARENTS
    #	None
    #
    # NOTES
    #	None
    #
    # SEE ALSO
    #	N/A
    #
    #***
    global log btn program settings mb options
    #${log}::debug Entering buttonBarGUI
    

    set module [lrange [join $args] 0 0]
    set idx [lrange [join $args] 1 1]
    
    set menuCount [$mb.module index end]
    
    # Enable/Disable the menu items depending on which one is active.
    for {set x 0} {$menuCount >= $x} {incr x} {
        if {$idx == $x} {
            $mb.module entryconfigure $x -state disable
        } else {
            $mb.module entryconfigure $x -state normal
        }
    }
    
    #${log}::debug INDEX: [lrange $args 1 1]
    $mb.modMenu delete 0 end
    $mb.file delete 0 end
        
    #${log}::debug Entering - $module
    switch -- $module {
        BoxLabels   {
            ${log}::debug Entering $module mode
            # .. remember what module we are in ..
            set settings(currentModule) [list BoxLabels 0]
            
            # .. setup the buttons on the button bar
            eAssist::remButtons $btn(Bar)
            eAssist::addButtons [mc "Print Labels"] Shipping_Code::printLabels btn1 0 8p
            eAssist::addButtons [mc "Print Breakdown"] Shipping_Gui::printbreakDown btn2 1 0p

            # .. launch the mode
            Shipping_Gui::shippingGUI
            
            eAssist_Global::getGeom $module 450x475
            # .. save the settings
            #eAssistSetup::SaveGlobalSettings
            lib::savePreferences
        }
        BatchMaker   {
            ${log}::debug Entering $module mode
            # .. remember what module we are in ..
            set settings(currentModule) [list BatchMaker 1]

            # .. setup the buttons and status bar
            eAssist::remButtons $btn(Bar)
            eAssist::statusBar
            
            # .. Initialize menu options
            importFiles::initMenu
            
            # .. launch the mode
            importFiles::eAssistGUI
            
            eAssist_Global::getGeom $module 900x610+240+124
            # .. save the settings
            #eAssistSetup::SaveGlobalSettings
            lib::savePreferences
            }
        Setup       {
            ${log}::debug Entering $module mode
            # .. remember what module we are in ..
            set settings(currentModule) [list Setup 2]

            # .. setup the buttons on the button bar
            eAssist::remButtons $btn(Bar)
            eAssist::addButtons [mc "Save"] eAssistSetup::SaveGlobalSettings btn1 0 8p
            eAssist::addButtons [mc "Exit"] exit btn2 1 0p

            # .. launch the mode
            eAssistSetup::eAssistSetup

            eAssist_Global::getGeom $module 845x573+247+156
            # .. save the settings
            #eAssistSetup::SaveGlobalSettings
            lib::savePreferences
        }
        default     {}
    }
    
    $mb.file add command -label [mc "Exit"] -command {eAssistSetup::SaveGlobalSettings ; exit}
    
    # Check the versions
    vUpdate::whatVersion
    
} ;# buttonBarGUI


proc eAssist::addButtons {text command btn1 column padX args} {
    #****f* addButtons/eAssist
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2011-2014 Casey Ackels
    #
    # FUNCTION
    #	Add one button for each invocation to the Button Bar
    #
    # SYNOPSIS
    #
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
    #   eAssist::remButtons
    #
    #***
    global log btn settings
    ${log}::debug --START-- [info level 1]
    
    if {[lrange $settings(currentModule) 0 0] eq "Setup"} {
        
        if {$text eq [mc "Save"]} {
            set state [eAssist::stateButtons]
        } else {
            set state normal
        }
    } else {
        set state normal
    }
    
    # reconfigure btn(bar)
    pack configure $btn(Bar) -side right -fill x -pady 5p
    
    {*}$btn(Bar).$btn1 configure -text $text -command $command -state $state
    grid $btn(Bar).$btn1 -column $column -row 3 -sticky nse -padx $padX
	
    ${log}::debug --END-- [info level 1]
} ;# eAssist::addButtons


proc eAssist::remButtons {path} {
    #****f* remButtons/eAssist
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2011-2014 Casey Ackels
    #
    # FUNCTION
    #	Remove all widgets that exist in the slave, used in conjunction with eAssist::addButtons
    #
    # SYNOPSIS
    #
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
    #   eAssist::addButtons
    #***
    global log
    ${log}::debug --START-- [info level 1]

    if {[grid slaves $path] != ""} { 
        foreach value [grid slaves $path] {
            grid forget $value
        }
    }
	
    ${log}::debug --END-- [info level 1]
} ;# eAssist::remButtons

proc eAssist::stateButtons {} {
    #****f* stateButtons/eAssist
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2011-2014 Casey Ackels
    #
    # FUNCTION
    #	Configures the state of the Save button, depending on if we can read/write to the config file in Setup mode
    #
    # SYNOPSIS
    #
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
    global log mySettings program
    ${log}::debug --START-- [info level 1]
 
    if {[eAssist_Global::fileAccessibility $program(Home) $mySettings(ConfigFile)] != 3} {
        return disable
    } else {
        return normal
    }
	
    ${log}::debug --END-- [info level 1]
} ;# eAssist::stateButtons


proc eAssist::statusBar {args} {
    #****f* statusBar/eAssist
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2011-2014 Casey Ackels
    #
    # FUNCTION
    #	General Status bar
    #
    # SYNOPSIS
    #
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
    global log btn job
    ${log}::debug --START-- [info level 1]

    # reconfigure btn(bar)
    pack configure $btn(Bar) -side left -fill x -pady 5p
    
    if {[winfo exists $btn(Bar).f1]} {destroy $btn(Bar).f1}
    set f1 [ttk::frame $btn(Bar).f1 -padding 2 -borderwidth 2]
    grid $f1 -column 0 -row 0 -sticky nse
    
    ttk::label $f1.txt1 -text [mc "Total Copies:"]
    ttk::entry $f1.txt2 -textvariable job(TotalCopies) -width 15 -state disabled -justify center
    
    grid $f1.txt1 -column 0 -row 0 -sticky nse
    grid $f1.txt2 -column 1 -row 0 -sticky nsw -padx 5p
    

    
    ${log}::debug --END-- [info level 1]
} ;# eAssist::statusBar


proc eAssist::detectHeightWidth {} {
    #****f* detectHeightWidth/eAssist
    # CREATION DATE
    #   10/30/2014 (Thursday Oct 30)
    #
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2014 Casey Ackels
    #   
    #
    # SYNOPSIS
    #   eAssist::detectHeightWidth args 
    #
    # FUNCTION
    #	Figure out if we were maximized the last time we were closed
    #   
    #   
    # CHILDREN
    #	N/A
    #   
    # PARENTS
    #   
    #   
    # NOTES
    #   
    #   
    # SEE ALSO
    #   
    #   
    #***
    global log

    if {[winfo screenheight . ] == [winfo height .]} {
        #wm attributes . -zoomed 1
        wm state . zoomed
        } elseif {[winfo screenwidth .] == [winfo width .]} {
           #wm attributes . -zoomed 1
           wm state . zoomed
        }

    
} ;# eAssist::detectHeightWidth
