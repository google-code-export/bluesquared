# Creator: Casey Ackels
# Initial Date: March 12, 2011]
# File Initial Date: 12 22,2014
# Dependencies: 
#-------------------------------------------------------------------------------
#
# Subversion
#
# $Revision: 169 $
# $LastChangedBy: casey.ackels $
# $LastChangedDate: 2011-10-17 16:11:20 -0700 (Mon, 17 Oct 2011) $
#
########################################################################################

##
## - Overview
# Overview

## Coding Conventions
# - Namespaces: Firstword_Secondword

# - Procedures: Proc names should have two words. The first word lowercase the first character of the first word,
#   will be uppercase. I.E sourceFiles, sourceFileExample

namespace eval customer {}

proc customer::manage {} {
    #****f* manage/customer
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2011-2013 Casey Ackels
    #
    # FUNCTION
    #	GUI for adding a new customer
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
    global log
    
    if {[winfo exists .manageCustomer]} {destroy .manageCustomer}
    
    set wid .manageCustomer

    toplevel $wid
    wm transient $wid .
    wm title $wid [mc "Manage Customers"]
    
    set locX [expr {[winfo screenwidth . ] / 4 + [winfo x .]}]
    set locY [expr {[winfo screenheight . ] / 5 + [winfo y .]}]
    wm geometry $wid +${locX}+${locY}

    set f1 [ttk::label $wid.f1 -padding 10]
    pack $f1 -fill both -expand yes -padx 5p -pady 5p
    
    ttk::button $f1.btn0 -text [mc "View"]
    ttk::button $f1.btn1 -text [mc "Modify"]
    ttk::button $f1.btn2 -text [mc "Add"]
    ttk::button $f1.btn3 -text [mc "Delete"]
    
    set f2 [ttk::label $wid.f2 -padding 10]
    pack $f2 -fill both -expand yes -padx 5p -pady 5p
    
    tablelist::tablelist $f2.tbl -columns {
                                0 "Code" center
                                0 "Name" center} \
                                -showlabels yes \
                                -height 10 \
                                -selectbackground yellow \
                                -selectforeground black \
                                -stripebackground lightblue \
                                -exportselection yes \
                                -showseparators yes \
                                -fullseparators yes \
                                -selectmode extended \
                                -editselectedonly 1 \
                                -selecttype row \
                                -yscrollcommand [list $f2.scrolly set] \
                                -xscrollcommand [list $f2.scrollx set]


    ttk::scrollbar $f2.scrolly -orient v -command [list $f2.tbl yview]
    ttk::scrollbar $f2.scrollx -orient h -command [list $f2.tbl xview]

    grid $f2.tbl -column 0 -row 0 -sticky news
    grid columnconfigure $f2 $f2.tbl -weight 1
    grid rowconfigure $f2 $f2.tbl -weight 1
    
    grid $f2.scrolly -column 1 -row 0 -sticky nse
    grid $f2.scrollx -column 0 -row 1 -sticky ews
    
    ::autoscroll::autoscroll $f2.scrolly ;# Enable the 'autoscrollbar'
    ::autoscroll::autoscroll $f2.scrollx
    
    set f3 [ttk::label $wid.f3 -padding 10]
    pack $f3 -fill both -expand yes -padx 5p -pady 5p
    
    ttk::button $f3.btn0 -text [mc "OK"]
    ttk::button $f3.btn1 -text [mc "Cancel"]
    
    grid $f3.btn0 -column 0 -row 0 -sticky ns
    grid $f3.btn1 -column 1 -row 0 -sticky ns

} ;# customer::manage