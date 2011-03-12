# Creator: Casey Ackels
# Initial Date: March 12, 2011]
# Dependencies: See Below
#-------------------------------------------------------------------------------
#
# Subversion
#
# $Revision: 43 $
# $LastChangedBy: casey.ackels $
# $LastChangedDate: 2011-03-12 13:44:31 -0800 (Sat, 12 Mar 2011) $
#
########################################################################################

##
## - Overview
# This file holds the parent GUI for Distribution Helper

# Definitions for prefixes of Variables
# G = Global
# S = String
# L = List
# I = Integer (Do not use this unless you are certain it is an Integer and not a plain string)

## Coding Conventions
# - Namespaces: 

# - Procedures: Proc names should have two words. The first word lowercase the first character of the first word,
#   will be uppercase. I.E sourceFiles, sourceFileExample

package provide disthelper_importFiles 1.0


namespace eval Disthelper_Gui {

proc disthelperGUI {} {
    #****f* disthelperGUI/Disthelper_Gui
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2011 - Casey Ackels
    #
    # FUNCTION
    #	Builds the GUI of the Import Files Module, with bindings
    #
    # SYNOPSIS
    #	N/A
    #
    # CHILDREN
    #	N/A
    #
    # PARENTS
    #	disthelper::parentGUI
    #
    # NOTES
    #	None
    #
    # SEE ALSO
    #	TODO: List the other *GUI procs.
    #
    #***


    wm title . "Distribution Helper"

# Frame 1
    set frame1 [ttk::labelframe .container.frame1 -text "File Headers"]
    pack $frame1 -expand yes -fill both -padx 5p -pady 3p -ipady 2p ;#-ipadx 5p
    
    tablelist::tablelist $frame1.listbox \
                -showlabels yes \
                -stretch all \
                -height 5 \
                -selectbackground yellow \
                -selectforeground black \
                -exportselection yes \
                -showseparators yes \
                -yscrollcommand [list $frame2b.scrolly set]
    
        $frame2b.listbox columnconfigure 0 -showlinenumbers 1 \
                                            -labelalign center \
                                            -align center
    
   
    ttk::scrollbar $frame1.scrolly -orient v -command [list $frame2b.listbox yview]
    
    grid $frame2.listbox -column 0 -row 0 -sticky news
    grid columnconfigure $frame $frame.listbox -weight 1
    
    grid $frame1.scrolly -column 1 -row 0 -sticky nse
    
    ::autoscroll::autoscroll $frame2b.scrolly ;# Enable the 'autoscrollbar'

    

    grid $frame1.text1 -column 0 -row 2 -sticky nes -padx 5p
    grid $frame1.entry1 -column 1 -row 2 -sticky news -pady 2p -padx 5p
       
    grid columnconfigure $frame1 1 -weight 1
    
# Frame 2 (This is a container for two frames)
    #set frame2 [ttk::labelframe .container.frame2 -text "Shipment Information"]
    #pack $frame2 -expand yes -fill both -padx 5p -pady 1p -ipady 2p
    

   

##
## - Bindings
##




bind [$frame2b.listbox bodytag] <Double-1> {
    #puts "selection2: [$frame2b.listbox curselection]"

    $frame2b.listbox delete [$frame2b.listbox curselection]
    
    # Make sure we keep all the textvars updated when we delete something
    Shipping_Code::addListboxNums ;# Add everything together for the running total
    # If we don't have the [catch] here, then we will get an error if we remove the last entry.
    # cell index "0,1" out of range
    catch {Shipping_Code::createList} err ;# Make sure our totals add up
    #puts "binding-Double1: $err"
}



bind all <<ComboboxSelected>> {
    Shipping_Code::readHistory [$frame1.entry1 current]
}


bind all <Escape> {exit}
bind all <F1> {console show}
bind all <F2> {console hide}

} ;# End of shippingGUI

} ;# End of Shipping_Gui namespace