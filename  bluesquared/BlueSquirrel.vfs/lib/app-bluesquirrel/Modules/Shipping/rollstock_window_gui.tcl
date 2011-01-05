# Creator: Casey Ackels (C) 2006 - 2007
# Initial Date: November 10th, 2007
# Massive Rewrite:
# Version: See shipping_launch_code.tcl
# Dependencies: See shipping_launch_code.tcl
#-------------------------------------------------------------------------------
#
# Subversion
#
# $Revision: 12 $
# $LastChangedBy: casey $
# $LastChangedDate: 2007-02-24 14:12:13 -0800 (Sat, 24 Feb 2007) $
#
########################################################################################

##
## - Overview
# This file holds the window for the Roll Stock Mode.

# Definitions for prefixes of Variables
# G = Global
# S = String
# L = List
# I = Integer (Do not use this unless you are certain it is an Integer and not a plain string)

package provide shipping 1.0

namespace eval Rollstock_Gui {

proc rollstockGUI {} {
global GS_windows frame2

    # Destroy frames
    # NOTE: GS_windows is set in parent_gui.tcl
    if {[winfo exists .frame1]} {
        foreach window $GS_windows {
            destroy $window
        }
    }

    
    wm title . "List Display (Roll Stock)"
    
    # Create Frame1
    set frame1 [ttk::frame .frame1]
    pack $frame1 -fill x -expand yes -padx 10p -pady 5p
    
    ttk::label $frame1.txt1 -text "P.O. #"
    ttk::entry $frame1.entry1 -width 10

    ttk::label $frame1.txt3 -text "Basis Weight"
    ttk::entry $frame1.entry3 -width 10
    
    ttk::label $frame1.txt5 -text "Tare"
    ttk::entry $frame1.entry5 -width 10
    
    ttk::label $frame1.txt2 -text "Material #"
    ttk::entry $frame1.entry2 -width 10
    
    ttk::label $frame1.txt4 -text "Width"
    ttk::entry $frame1.entry4 -width 10

    ##
    ## Frame 2
    
    set frame2 [ttk::labelframe .frame2 -text "Roll Weight"]
    pack $frame2 -fill x -expand yes -padx 10p -pady 2p
    
    tablelist::tablelist $frame2.table -columns {1 "Count" 0 "Weight"} \
                    -stretch all \
                    -width 50 \
                    -height 15 \
                    -stripebackground lightblue \
                    -yscrollcommand [list $frame2.scrolly set]
        
        $frame2.table columnconfigure 0 -showlinenumbers 1
        
        $frame2.table insert end ""
        $frame2.table cellconfigure 0,1 -editable 1 -editwindow entry
        
    ttk::scrollbar $frame2.scrolly -orient v -command [list $frame2.table yview]
    
    ttk::label $frame2.txt1 -text "Total Weight"
    ttk::label $frame2.txtv1 -text "x" -textvariable txtv(Weight)

    ##
    ## Packing List
    ##
    
    # Frame 1
    grid $frame1.txt1 -column 0 -row 0 -sticky nse -pady 2p -padx 5p
    grid $frame1.entry1 -column 1 -row 0 -sticky news -pady 2p -padx 5p ;#-ipadx 9p
    
    grid $frame1.txt2 -column 2 -row 0 -sticky nse -pady 2p -padx 5p
    grid $frame1.entry2 -column 3 -row 0 -sticky news -pady 2p -padx 5p ;#-ipadx 9p
    
    grid $frame1.txt3 -column 0 -row 2 -sticky nse -pady 2p -padx 5p
    grid $frame1.entry3 -column 1 -row 2 -sticky news -pady 2p -padx 5p ;#-ipadx 9p
    
    grid $frame1.txt4 -column 2 -row 2 -sticky nse -pady 2p -padx 5p
    grid $frame1.entry4 -column 3 -row 2 -sticky news -pady 2p -padx 5p ;#-ipadx 9p
    
    grid $frame1.txt5 -column 0 -row 4 -sticky nse -pady 2p -padx 5p
    grid $frame1.entry5 -column 1 -row 4 -sticky news -pady 2p -padx 5p
    
    # Frame 2
    grid $frame2.table -column 0 -row 0 -sticky news -padx 5p -pady 5p
    grid columnconfigure $frame2 $frame2.table -weight 1
    grid $frame2.scrolly -column 1 -row 0 -sticky nse
    
    grid $frame2.txt1 -column 0 -row 1 -sticky w -padx 5p -pady 2p
    grid $frame2.txtv1 -column 1 -row 1 ;#-sticky nsw
    
    ::autoscroll::autoscroll $frame2.scrolly ;# Enable the 'autoscrollbar'

  
    ##
    ## Bindings
    ##
    #bind ::TablelistBody <Return> {
    #    puts test
    #	#tablelist::nextPrevCell [tablelist::getTablelistPath %W] 1; break
    #}
    #bind TablelistEdit <Return> { puts test;#tablelist::goToNextPrevCell %W 1 }
    #foreach key {Return KP_Enter} {
    #    bind TablelistEdit <$key> { tablelist::goToNextPrevCell %W 1 }
    #    addRows
    #}
    bind TablelistEdit <Control_L> {
        $frame2.table insert end ""
	$frame2.table cellconfigure end -editable 1 -editwindow entry
    }

} ; # End of rollstockGUI proc



} ; # End of Rollstock_Gui Namespace