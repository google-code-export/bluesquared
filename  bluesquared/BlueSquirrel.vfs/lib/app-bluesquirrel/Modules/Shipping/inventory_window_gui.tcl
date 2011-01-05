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
# This file holds the window for the Inventory Mode.

# Definitions for prefixes of Variables
# G = Global
# S = String
# L = List
# I = Integer (Do not use this unless you are certain it is an Integer and not a plain string)

package provide shipping 1.0

namespace eval Inventory_Gui {
    
proc inventoryGUI {} {
global GS_windows

    # Destroy frames
    # NOTE: GS_windows is set in parent_gui.tcl
    if {[winfo exists .frame1]} {
        foreach window $GS_windows {
            destroy $window
        }
    }
    
    wm title . "List Display (Inventory)"

    ttk::frame .frame1
    pack .frame1 -fill x -anchor n
} ; # End of inventoryGUI proc

} ; # End of Inventory_Gui Namespace