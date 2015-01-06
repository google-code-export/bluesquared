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

    set f1 [ttk::label $wid.f1]
    pack $f1 -fill both -expand yes -padx 5p -pady 5p
    
    ttk::button $f1.btn0 -text [mc "View"]
    ttk::button $f1.btn1 -text [mc "Modify"]
    ttk::button $f1.btn2 -text [mc "Add"] -command {customer::Modify add "" ""}
    ttk::button $f1.btn3 -text [mc "Delete"]
    
    grid $f1.btn0 -column 0 -row 0 -sticky s
    grid $f1.btn1 -column 1 -row 0 -sticky s
    grid $f1.btn2 -column 2 -row 0 -sticky s
    grid $f1.btn3 -column 3 -row 0 -sticky s
    
    set f2 [ttk::label $wid.f2 -padding 10]
    pack $f2 -fill both -expand yes -padx 5p -pady 5p
    
    tablelist::tablelist $f2.tbl -columns {
                                6 "Code" center
                                40 "Name" center} \
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

# customer::Modify modify "" ""
proc customer::Modify {modify {id 0} {custName ""}} {
    #****f* Modify/customer
    # CREATION DATE
    #   12/24/2014 (Wednesday Dec 24)
    #
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2014 Casey Ackels
    #   
    #
    # SYNOPSIS
    #   customer::Add <add|edit|view> ?id? ?Customer Name?
    #
    # FUNCTION
    #	A Dialog which allows the user to, add, edit or view records for specific customers 
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

    if {[winfo exists .viewCustomer]} {destroy .viewCustomer}
    
    set wid .viewCustomer

    toplevel $wid
    wm transient $wid .
    wm title $wid [mc "View/Edit Customers"]
    
    set locX [expr {[winfo screenwidth . ] / 4 + [winfo x .]}]
    set locY [expr {[winfo screenheight . ] / 5 + [winfo y .]}]
    wm geometry $wid +${locX}+${locY}
    
    switch -- $modify {
        add     {}
        edit    {}
        view    {set state disabled}
        default {}
    }
    
    
    # Enter Customer ID and Name
    set f0a [ttk::frame $wid.f0a -padding 10]
    pack $f0a -fill x
    
    ttk::label $f0a.txt1 -text [mc "Customer ID"]
    ttk::entry $f0a.entry1
    
    ttk::label $f0a.txt2 -text [mc "Customer Name"]
    ttk::entry $f0a.entry2
    
    grid $f0a.txt1 -column 0 -row 0 -sticky nse
    grid $f0a.entry1 -column 1 -row 0 -sticky nsw
    
    grid $f0a.txt2 -column 0 -row 1 -sticky nse
    grid $f0a.entry2 -column 1 -row 1 -sticky nsw

    
    #-------- Notebook container Frame
    set f0 [ttk::frame $wid.f0]
    pack $f0 -expand yes -fill both -pady 5p -padx 5p
    
    # Control Buttons
    set btns [ttk::frame $wid.btns -padding 10]
    pack $btns -anchor se
    
    ttk::button $btns.btn0 -text [mc "OK"]
    ttk::button $btns.btn1 -text [mc "Cancel"]
    
    grid $btns.btn0 -column 0 -row 0
    grid $btns.btn1 -column 1 -row 0
    
    
    ##
    ## Notebook
    ##
    set nbk [ttk::notebook $f0.notebook]
    pack $nbk -expand yes -fill both -padx 5p -pady 5p
    
    ttk::notebook::enableTraversal $nbk
    
    #
    # Setup the notebook
    #
    $nbk add [ttk::frame $nbk.shipvia] -text [mc "Preferred Ship Via's"]
    $nbk add [ttk::frame $nbk.titles] -text [mc "Titles"]
    
    $nbk select $nbk.shipvia
    

    
    # -----
    # Tab 1, Notebook - Preferred Ship Via's
    
    # Frame 1 - Available Ship Via
    set f1a [ttk::labelframe $nbk.shipvia.f1a -text [mc "Available"] -padding 10]
    pack $f1a -expand yes -fill both -side left -pady 5p -padx 5p
    
    listbox $f1a.lbox -width 30 -selectmode extended \
            -yscrollcommand [list $f1a.scrolly set] \
            -xscrollcommand [list $f1a.scrollx set]
    
    ttk::scrollbar $f1a.scrolly -orient v -command [list $f1a.lbox yview]
    ttk::scrollbar $f1a.scrollx -orient h -command [list $f1a.lbox xview]
    
    ::autoscroll::autoscroll $f1a.scrolly ;# Enable the 'autoscrollbar'
    ::autoscroll::autoscroll $f1a.scrollx
    
    grid $f1a.lbox -column 0 -row 0 -sticky news
    grid $f1a.scrolly -column 1 -row 0 -sticky nse
    grid $f1a.scrollx -column 0 -row 1 -sticky ews
    
    # Frame 2 - Buttons
    set f2a [ttk::frame $nbk.shipvia.f2a -padding 10]
    pack $f2a -expand yes -fill both -side left -pady 5p -padx 5p
    
    ttk::button $f2a.btn1 -text [mc "Add >"] -command {${log}::debug [.viewCustomer.f0.notebook.shipvia.f1a.lbox curselection]}
    ttk::button $f2a.btn2 -text [mc "< Remove"]
    
    grid $f2a.btn1 -column 0 -row 0 -sticky news
    grid $f2a.btn2 -column 0 -row 1 -sticky news
    
    # Frame 3 - Assigned Ship Via
    set f3a [ttk::labelframe $nbk.shipvia.f3a -text [mc "Assigned"] -padding 10]
    pack $f3a -expand yes -fill both -side left -pady 5p -padx 5p
    
    listbox $f3a.lbox -width 30 -selectmode extended \
            -yscrollcommand [list $f3a.scrolly set] \
            -xscrollcommand [list $f3a.scrollx set]
    
    ttk::scrollbar $f3a.scrolly -orient v -command [list $f3a.lbox yview]
    ttk::scrollbar $f3a.scrollx -orient h -command [list $f3a.lbox xview]
    
    ::autoscroll::autoscroll $f3a.scrolly ;# Enable the 'autoscrollbar'
    ::autoscroll::autoscroll $f3a.scrollx
    
    grid $f3a.lbox -column 0 -row 0 -sticky news
    grid $f3a.scrolly -column 1 -row 0 -sticky nse
    grid $f3a.scrollx -column 0 -row 1 -sticky ews
    
    # Populate the ship via listboxes
    customer::PopulateShipVia $f1a.lbox
    #customer::PopulateShipVia $f3a.lbox custID
    


} ;# customer::Modify

