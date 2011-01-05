# Creator: Casey Ackels (C) 2006 - 2007
# Initial Date: October 28th, 2006
# Massive Rewrite: February 2nd, 2007
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
# This file holds the window for the Shipping Mode.

# Definitions for prefixes of Variables
# G = Global
# S = String
# L = List
# I = Integer (Do not use this unless you are certain it is an Integer and not a plain string)

namespace eval Shipping_Gui {

proc displayList {} {
    global d_frame1 o_frame1 genResults GS_textVar L_frame1 gridNumber
    
        
    
    
    
    
} ;# End of displayList

proc shippingGUI {} {
    global GI_textVar GS_textVar d_frame1 o_frame1 frame3_right frame1 genResults GS_windows
    
    # Destroy frames
    # NOTE: GS_windows is set in parent_gui.tcl
    if {[winfo exists .mainTop]} {
        foreach window $GS_windows {
            destroy $window
        }
    }
    wm title . "List Display (Box Labels)"

    ttk::frame .mainTop
    pack .mainTop -fill x -anchor n
    
    # Create Frame1
    set frame1 [ttk::frame .mainTop.frame1]
    
    
    ttk::label $frame1.text -text "Max. Qty per Box"
    entry $frame1.entry -textvariable GS_textVar(maxBoxQty) -width 17 -background #F5F5F5 -validate key -validatecommand {Shipping_Code::filterKeys %S}

    ttk::label $frame1.text1 -text "Destination Quantity" 
    entry $frame1.entry1 -textvariable GS_textVar(destQty) -width 17 -background #F5F5F5 -validate key -validatecommand {Shipping_Code::filterKeys %S}
    ttk::button $frame1.add -text "Add to List" -command {
                                                    Shipping_Code::insertInListbox $GS_textVar(destQty)
                                                    set GS_textVar(destQty) ""
                                                    # Display the updated amount of entries that we have
                                                    Shipping_Code::createList $o_frame1.listbox $d_frame1.text 
                                                    }
    
    
    # Create Frame3
    set frame3 [ttk::frame .mainTop.frame3]
    set frame3_left [ttk::labelframe .mainTop.frame3.left -text "Current Totals" -width 4.5i -labelanchor nw]
    set frame3_right [ttk::frame .mainTop.frame3.right]
    
    # All for Frame3_left
    ttk::label $frame3_left.entries -text "Entries:"
    ttk::label $frame3_left.entryVar -text "0" -textvariable GI_textVar(entry)
    ttk::label $frame3_left.qty -text "Quantity:"
    ttk::label $frame3_left.qtyVar -text "0" -textvariable GI_textVar(qty)
    
    # All for Frame3_right
    #listbox $frame3_right.listbox \
    #            -width 15 \
    #            -height 6 \
    #            -background #F5F5F5 \
    #            -selectbackground yellow \
    #            -selectforeground black \
    #            -exportselection yes \
    #            -selectmode extended \
    #            -activestyle dotbox \
    #            -highlightthickness 0 \
    #            -yscrollcommand [list $frame3_right.scrolly set]
    
    tablelist::tablelist $frame3_right.listbox \
                -columns {  0 "Quantity"
                            0 "Version" center } \
                -stretch all \
                -width 23 \
                -height 6 \
                -selectbackground yellow \
                -selectforeground black \
                -exportselection yes \
                -stripebackground lightgrey \
                -yscrollcommand [list $frame3_right.scrolly set]
    
    ttk::scrollbar $frame3_right.scrolly -orient v -command [list $frame3_right.listbox yview]


    
##
## Start Packing Lists
##
    
    # Packing list for Frame1
    grid $frame1.text -column 0 -row 0 -sticky nes -ipadx 5p
    grid $frame1.entry -column 1 -row 0 -sticky news -ipadx 5p -pady 2p
    
    grid $frame1.text1 -column 0 -row 1 -sticky nws -ipadx 5p
    grid $frame1.entry1 -column 1 -row 1 -sticky news -ipadx 5p -pady 2p
    grid $frame1.add -column 2 -row 1 -sticky news -padx 10p -ipadx 5p
    tooltip::tooltip $frame1.add "Add to List (Enter)"

    pack $frame1 -anchor nw -expand yes -fill both -pady 5p -padx 10p
    pack propagate $frame1 no

    
    # Packing list for Frame3 (right and left)
    ## Frame3_left
    grid $frame3_left.entries -column 0 -row 0 -sticky nes -padx 2p
    grid $frame3_left.entryVar -column 1 -row 0 -sticky nws ;#-padx 15p
    grid $frame3_left.qty -column 0 -row 1 -sticky nes -padx 2p
    grid $frame3_left.qtyVar -column 1 -row 1 -sticky nws ;#-padx 15p
    

    grid columnconfigure $frame3_left 0 -weight 0
    grid columnconfigure $frame3_left 1 -weight 1
    
    ## Frame3_right
    grid $frame3_right.listbox -column 0 -row 0 -sticky nwes -ipadx 10p
    grid $frame3_right.scrolly -column 1 -row 0 -sticky nse
    
    ::autoscroll::autoscroll $frame3_right.scrolly ;# Enable the 'autoscrollbar'

    
    ## Main Frames
    grid $frame3_left -column 0 -row 0 -sticky nw -padx 20p -ipady 5p -ipadx 10p 
    grid $frame3_right -column 1 -row 0 -sticky nes -padx 10p
    pack $frame3 -expand yes -fill x -pady 5p ;#-padx 5p -pady 5p 
    

    focus -force $frame1.entry ;# Make the cursor start out in the correct spot.
    
##########################################
# Frames
    ttk::frame .mainBottom
    pack .mainBottom -fill x -expand yes -anchor n
    
    # set notebook, and tabs
    set nb [ttk::notebook .mainBottom.nb -height 200]
    $nb add [ttk::frame $nb.label] -text "Create Label"
    $nb add [ttk::frame $nb.overview] -text "Overview"
    $nb add [ttk::frame $nb.detailed] -text "Detailed"
    
    ### Populate the Notebook
    # Tab: Labels / Frame1
    
    set L_frame1 [ttk::frame $nb.label.l_frame1]
    
    ttk::label $L_frame1.txtMessage -text "Please do not enter a Quantity."
    
    ttk::label $L_frame1.text1 -text "Line 1"
    entry $L_frame1.entry1 -textvariable GS_textVar(line1) -width 20 -background #F5F5F5
    
    ttk::label $L_frame1.text2 -text "Line 2"
    entry $L_frame1.entry2 -textvariable GS_textVar(line2) -width 20 -background #F5F5F5
    
    ttk::label $L_frame1.text3 -text "Line 3"
    entry $L_frame1.entry3 -textvariable GS_textVar(line3) -width 20 -background #F5F5F5
    
    ttk::label $L_frame1.text4 -text "Line 4"
    entry $L_frame1.entry4 -textvariable GS_textVar(line4) -width 20 -background #F5F5F5
    
    ttk::label $L_frame1.text5 -text "Line 5"
    entry $L_frame1.entry5 -textvariable GS_textVar(line5) -width 20 -background #F5F5F5
    
    ttk::label $L_frame1.text6 -text "Line 6"
    entry $L_frame1.entry6 -textvariable GS_textVar(line6) -width 20 -background #F5F5F5

    
    # Tab: Overview / Frame1    
    set o_frame1 [ttk::frame $nb.overview.o_frame1]
    listbox $o_frame1.listbox \
                -width 36 \
                -height 7 \
                -background #F5F5F5 \
                -takefocus 0 \
                -selectbackground yellow \
                -selectforeground black \
                -exportselection yes \
                -selectmode extended \
                -activestyle dotbox \
                -highlightthickness 0 \
                -yscrollcommand [list $o_frame1.scrolly set]
    
    ttk::scrollbar $o_frame1.scrolly -orient v -command [list $o_frame1.listbox yview]
    ttk::button $o_frame1.print -text "Print Report" -command "Shipping_Code::printText listbox $o_frame1.listbox"
    
    # Tab: Detailed / Frame1
    set d_frame1 [ttk::frame $nb.detailed.d_frame1]
    text $d_frame1.text \
                -width 51 \
                -height 11 \
                -background #F5F5F5 \
                -takefocus 0 \
                -yscrollcommand [list $d_frame1.scrolly set]

    
    ttk::scrollbar $d_frame1.scrolly -orient v -command [list $d_frame1.text yview]
    ttk::button $d_frame1.print -text "Print Report" -command "Shipping_Code::printText text $d_frame1.text"
    
    ##
    ## Start Packing Lists
    ##
    # Frame1 / Create Label
    grid $L_frame1.txtMessage -columnspan 2 -row 0 -sticky news -pady 5p -padx 6p
    
    grid $L_frame1.text1 -column 0 -row 1 -sticky nes ;#-sticky ne ;#-ipadx 5p
    grid $L_frame1.entry1 -column 1 -row 1 -sticky new -pady 3p -padx 6p ;#-ipadx 5p -pady 2p
    #grid $L_frame1.addBtn -column 2 -row 1 -sticky new ;#-pady 2p -padx 5p
    
    grid $L_frame1.text2 -column 0 -row 2 -sticky nes ;#-ipadx 5p
    grid $L_frame1.entry2 -column 1 -row 2 -sticky new -pady 3p -padx 6p ;#-ipadx 5p -pady 2p
    #grid $L_frame1.removeBtn -column 2 -row 2 -sticky new ;#-pady 2p -padx 6p
    
    grid $L_frame1.text3 -column 0 -row 3 -sticky nes ;#-ipadx 5p
    grid $L_frame1.entry3 -column 1 -row 3 -sticky new -pady 3p -padx 6p ;#-ipadx 5p -pady 2p
    
    grid $L_frame1.text4 -column 0 -row 4 -sticky nes ;#-ipadx 5p
    grid $L_frame1.entry4 -column 1 -row 4 -sticky new -pady 3p -padx 6p ;#-ipadx 5p -pady 2p
    
    grid $L_frame1.text5 -column 0 -row 5 -sticky nes ;#-ipadx 5p
    grid $L_frame1.entry5 -column 1 -row 5 -sticky new -pady 3p -padx 6p ;#-ipadx 5p -pady 2p
    
    grid $L_frame1 -sticky news
    grid columnconfigure $L_frame1 1 -weight 1

    
    # Frame1 / Overview
    grid $o_frame1.listbox -column 0 -row 0 -sticky news ;#-ipadx 10p
    grid $o_frame1.scrolly -column 1 -row 0 -sticky nse
    #grid $o_frame1.print -column 0 -row 1 -sticky nse -padx 5p -pady 5p
    grid $o_frame1 -padx 5p -pady 5p -sticky news
    ::autoscroll::autoscroll $o_frame1.scrolly ;# Enable the 'autoscrollbar'
    
    
    # Frame1 / Detailed
    grid $d_frame1.text -column 0 -row 0 -sticky news
    grid $d_frame1.scrolly -column 1 -row 0 -sticky nse
    #grid $d_frame1.print -column 0 -row 1 -sticky nse -padx 5p -pady 5p
    grid $d_frame1 -padx 5p -pady 5p -sticky news
    
    ::autoscroll::autoscroll $d_frame1.scrolly ;# Enable the 'autoscrollbar'

    # pack notebook and set misc. options
    grid $nb

    
    $nb select $nb.label
    ttk::notebook::enableTraversal $nb


##
## - Bindings
##

foreach window "$frame1.entry $frame1.entry1" {
    bind $window <FocusIn> "$window configure -background yellow"
}

foreach window "$frame1.entry $frame1.entry1" {
    bind $window <FocusOut> "$window configure -background white"
}

foreach window "$frame1.add $frame1.entry1" {
    bind $window <Return> {
        Shipping_Code::insertInListbox $GS_textVar(destQty); set GS_textVar(destQty) ""
        Shipping_Code::createList $o_frame1.listbox $d_frame1.text ;# Display the updated amount of entries that we have
    }
}

bind $frame3_right.listbox <Delete> {

    catch {$frame3_right.listbox delete [$frame3_right.listbox curselection]} err
    
    # Make sure we keep all the textvars updated when we delete something
    Shipping_Code::addListboxNums ;# Add everything together for the running total
    Shipping_Code::addListboxEntries ;# Add up the amount of entries we have
    
    # Make sure if we delete something, the user has to re-generate the list. If we don't do this, it could cause
    # some confusion.
    if {[$frame3_right.listbox get 0 end] == ""} {
        $o_frame1.listbox delete 0 end
        $d_frame1.text delete 1.0 end
    } else {
        Shipping_Code::createList $o_frame1.listbox $d_frame1.text ;# Display the updated amount of entries that we have
    }

}

bind $frame3_right.listbox <ButtonPress> {
    focus $frame3_right.listbox
}

foreach window "$L_frame1.entry1 $L_frame1.entry2 $L_frame1.entry3 $L_frame1.entry4 $L_frame1.entry5" {
    bind $window <FocusIn> "$window configure -background yellow"
    }
    
foreach window "$L_frame1.entry1 $L_frame1.entry2 $L_frame1.entry3 $L_frame1.entry4 $L_frame1.entry5" {
    bind $window <FocusOut> "$window configure -background white"
    }

foreach value "KeyPress" {
        bind $d_frame1.text <$value> {break}
    }
    
bind $o_frame1.listbox <ButtonPress> "focus $o_frame1.listbox"

# Global bindings
bind all <Control-t> "Shipping_Code::printText text $d_frame1.text"
bind all <Control-l> "Shipping_Code::printText listbox $o_frame1.listbox"
bind all <Escape> {exit}
bind all <F1> {console show}
bind all <F2> {console hide}

} ;# End of shippingGUI

} ;# End of Shipping_Gui namespace