# Creator: Casey Ackels
# Initial Date: October 28th, 2006]
# Massive Rewrite: February 2nd, 2007
# Last Updated: February 6th, 2007
# Dependencies: See shipping_launch_code.tcl
#-------------------------------------------------------------------------------
#
# Subversion
#
# $Revision: 10 $
# $LastChangedBy: casey $
# $LastChangedDate: 2007-02-23 06:30:17 -0800 (Fri, 23 Feb 2007) $
#
########################################################################################

# Definitions for prefixes of Variables
# G = Global
# S = String
# L = List
# I = Integer (Do not use this unless you are certain it is an Integer and not a plain string)

## Coding Conventions
# - Namespaces: These should have two parts, a _gui and a _code. Both words should be capitalized. i.e. Example_Code

# - Procedures: Proc names should have two words. The first word lowercase the first character of the first word,
#   will be uppercase. I.E sourceFiles, sourceFileExample


# Start GUI
package provide bluesquirrel_core 1.0

namespace eval blueSquirrel {}


proc blueSquirrel::parentGUI {} {
    #****f* parentGUI/blueSquirrel
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2008 Casey Ackels
    #
    # FUNCTION
    #	Generate the parent GUI container and buttons (Close / Print)
    #
    # SYNOPSIS
    #	N/A
    #
    # CHILDREN
    #	blueSquirrel::shippingGUI
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
    global GI_textVar GS_textVar frame1 frame2b genResults GS_windows
    
    # List of frames within this proc
    set GS_windows ".frame1 .frame2 .frame3"
    
    wm geometry . 420x470
        
    # Create the Menu's
    set mb [menu .mb]
    . configure -menu $mb
    
    ## File
    menu $mb.file -tearoff 0 -relief raised -bd 2
    
    $mb add cascade -label "File" -menu $mb.file
    $mb.file add command -label "Exit" -command {exit}
    
    ## Edit
    menu $mb.edit -tearoff 0 -relief raised -bd 2
    $mb add cascade -label "Edit" -menu $mb.edit
    
    $mb.edit add command -label "Clear List" -command { Shipping_Code::clearList }
    $mb.edit add command -label "Breakdown" -command { Shipping_Gui::breakDown }
                
    ## Mode
    #menu $mb.mode -tearoff 0 -relief raised -bd 2
    #$mb add cascade -label "Mode" -menu $mb.mode
    
    #$mb.mode add command -label "Box Labels" -command {Shipping_Gui::shippingGUI}
    #$mb.mode add command -label "Inventory" -command {Inventory_Gui::inventoryGUI}
    #$mb.mode add command -label "Roll Stock" -command {Rollstock_Gui::rollstockGUI}
    
    ## Help
    menu $mb.help -tearoff 0 -relief raised -bd 2
    $mb add cascade -label "Help" -menu $mb.help
    
    $mb.help add command -label "About" -command {blueSquirrel::about}
    #$mb.help add command -label "v0.4" -command {}
    

    # Create Separator Frame
    set frame0 [ttk::frame .frame0]
    ttk::separator $frame0.separator -orient horizontal
    
    grid $frame0.separator - -sticky ew -ipadx 4i
    pack $frame0 -anchor n -fill x -expand yes
    
    # Create the container frame
    ttk::frame .container
    pack .container -expand yes -fill both

    # Start the Default GUI - ShippingGUI
        # All frames that make up the GUI are children to .container
    Shipping_Gui::shippingGUI


    ## 
    ## Control Buttons
    ##
    
    set btnBar [ttk::frame .btnBar]
    
    ttk::button $btnBar.print -text "Print Labels" -command "Shipping_Code::printLabels"
    ttk::button $btnBar.close -text "Close" -command {exit}
    #ttk::label $btnBar.copy -text "\u00a9 Casey Ackels - 2007"
    
    grid $btnBar.print -column 0 -row 3 -sticky nse -padx 8p  
    grid $btnBar.close -column 1 -row 3 -sticky nse ;#-padx 2p
    #grid $btnBar.copy -columnspan 2 -row 4 -sticky nse -pady 2p;#-padx 2p
    
    pack $btnBar -side bottom -anchor se -pady 4p -padx 5p
    
    # ToolTips
    tooltip::tooltip $btnBar.close "Close (Esc)"
    
    # Bindings
    bind $btnBar.close <Return> {exit}
    bind all <Control-p> "Shipping_Code::printLabels"

} ;# End of parentGUI


proc blueSquirrel::about {} {
    
    toplevel .about
    wm transient .about .
    wm geometry .about
    wm title .about About
    
    ttk::frame .about.parent
    
    ttk::label .about.parent.version -text "Version: 1.2 (Released September 2010)"
    ttk::label .about.parent.label -text "About"
    text .about.parent.txt -height 10 -width 50 -wrap word
    ttk::label .about.parent.copy -text "\u00a9 2007-2011 Casey Ackels"
    
    .about.parent.txt insert 0.0 {
I wrote this program so that we would not have to repeatedly do mundane math for each job that required box labels.
}
    bind .about.parent.txt <KeyPress> {break} ;# Prevent people from entering/removing anything
    bind .about.parent.txt <Button-1> {break} ;# Prevent people from entering/removing anything
    
    grid .about.parent.version -column 0 -row 0
    grid .about.parent.label -column 0 -row 1
    grid .about.parent.txt -column 0 -row 2 -sticky ew
    grid .about.parent.copy -column 0 -row 3
    
    grid .about.parent -column 0 -row 0 -sticky news 
}

