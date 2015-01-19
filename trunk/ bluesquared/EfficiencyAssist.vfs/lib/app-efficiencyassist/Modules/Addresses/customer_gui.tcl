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
    
    set f2 [ttk::label $wid.f2 -padding 10]
    pack $f2 -fill both -expand yes -padx 5p -pady 5p
    
    ## Frame 1
    ttk::button $f1.btn0 -text [mc "View"] -command "customer::Modify view $f2.tbl"
    ttk::button $f1.btn1 -text [mc "Modify"] -command "customer::Modify edit $f2.tbl"
    ttk::button $f1.btn2 -text [mc "Add"] -command {customer::Modify add}
    ttk::button $f1.btn3 -text [mc "Delete"] -state disabled
    
    grid $f1.btn0 -column 0 -row 0 -sticky s
    grid $f1.btn1 -column 1 -row 0 -sticky s
    grid $f1.btn2 -column 2 -row 0 -sticky s
    grid $f1.btn3 -column 3 -row 0 -sticky s
    

    ## Frame 2
    tablelist::tablelist $f2.tbl -columns {
                                10 "Code" center
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
    pack $f3 -padx 5p -pady 5p -anchor se
    
    ttk::button $f3.btn0 -text [mc "Close"] -command [list destroy $wid]
    #ttk::button $f3.btn1 -text [mc "Cancel"] -command [list destroy $wid]
    
    grid $f3.btn0 -column 0 -row 0 -sticky ns
    #grid $f3.btn1 -column 1 -row 0 -sticky ns
    
    customer::populateCustomerLbox $f2.tbl

} ;# customer::manage


proc customer::Modify {modify {tbl ""}} {
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
    #   customer::Add <add|edit|view> ?Path to table widget?
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
    global log cust

    if {[winfo exists .viewCustomer]} {destroy .viewCustomer}
    if {[info exists ::customer::shipViaDeleteList]} {unset ::customer::shipViaDeleteList}
    
    set wid .viewCustomer

    toplevel $wid
    wm transient $wid .
    wm title $wid [mc "View/Edit Customers"]
    
    set locX [expr {[winfo screenwidth . ] / 4 + [winfo x .]}]
    set locY [expr {[winfo screenheight . ] / 5 + [winfo y .]}]
    wm geometry $wid +${locX}+${locY}
    
    

    switch -- $modify {
        add     {set entryState [list normal normal]; set btnState normal
                        set custList [list "" ""]
                        set cust(Status) 1
                }
        edit    {set entryState [list readonly normal]; set btnState normal
                    set custList [$tbl get [$tbl curselection]]
                    set cust(Status) [eAssist_db::dbWhereQuery -columnNames Status -table Customer -where Cust_ID='[lindex $custList 0]']
                }
        view    {set entryState [list readonly readonly disabled]; set btnState disabled
                    set custList [$tbl get [$tbl curselection]]
                    set cust(Status) [eAssist_db::dbWhereQuery -columnNames Status -table Customer -where Cust_ID='[lindex $custList 0]']
                }
        default {}
    }
    
    
    # Enter Customer ID and Name 
    set f0a [ttk::frame $wid.f0a -padding 10]
    pack $f0a -fill x
    
    # Notebook container Frame
    set f0 [ttk::frame $wid.f0]
    pack $f0 -expand yes -fill both -pady 5p -padx 5p
    
    # Buttons Frame
    set btns [ttk::frame $wid.btns -padding 10]
    pack $btns -anchor se
    
    ttk::label $f0a.txt1 -text [mc "Customer ID"]
    ttk::entry $f0a.entry1 -width 10 ;#-validate key -validatecommand "customer::validateEntry $btns.btn0 $f2a.btn1 $f2a.btn2 %W %P"
    focus $f0a.entry1
        $f0a.entry1 insert end [lindex $custList 0]
        $f0a.entry1 configure -state [lindex $entryState 0]
    
    ttk::label $f0a.txt2 -text [mc "Customer Name"]
    ttk::entry $f0a.entry2 -width 50
        $f0a.entry2 insert end [lindex $custList 1]
        $f0a.entry2 configure -state [lindex $entryState 1]
        
    ttk::label $f0a.txt3 -text [mc "Record Active"]
    ttk::checkbutton $f0a.ckbtn1 -variable cust(Status)
        $f0a.ckbtn1 configure -state [lindex $entryState 2]
    
    grid $f0a.txt1 -column 0 -row 0 -sticky nse
    grid $f0a.entry1 -column 1 -row 0 -sticky nsw -pady 2p
    
    grid $f0a.txt2 -column 0 -row 1 -sticky nse
    grid $f0a.entry2 -column 1 -row 1 -sticky nsw -pady 2p
    
    grid $f0a.txt3 -column 0 -row 2 -sticky nse
    grid $f0a.ckbtn1 -column 1 -row 2 -sticky nsw -pady 2p

    
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
    
    listbox $f1a.lbox -width 30 -height 15 -selectmode extended \
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
    
    # Frame 3 - Assigned Ship Via
    set f3a [ttk::labelframe $nbk.shipvia.f3a -text [mc "Assigned"] -padding 10]
    pack $f3a -expand yes -fill both -side left -pady 5p -padx 5p
    
    ## Frame 2 - Buttons
    ttk::button $f2a.btn1 -text [mc "Add >"] -state $btnState -command "customer::transferToAssigned $f1a.lbox $f3a.lbox $btns.btn0" -state disable
    ttk::button $f2a.btn2 -text [mc "< Remove"] -state $btnState -command "customer::removeFromAssigned $f3a.lbox $btns.btn0" -state disable
     
    grid $f2a.btn1 -column 0 -row 0 -sticky news
    grid $f2a.btn2 -column 0 -row 1 -sticky news
    

    ## Frame 3
    listbox $f3a.lbox -width 30 -height 15 -selectmode extended \
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

    
    # -----
    # Tab 2, Titles
    
    # Frame 1 - Message to User
    set ft1 [ttk::frame $nbk.titles.ft1 -padding 10]
    pack $ft1 -expand yes -fill both ;#-pady 5p -padx 5p
    
    # Frame 2 - List of Titles, and Delete button
    set ft2 [ttk::frame $nbk.titles.ft2 -padding 10]
    pack $ft2 -expand yes -fill both ;#-pady 5p -padx 5p
    
    
    # Frame 1
    ttk::label $ft1.txt -text [mc "Titles are added automatically when creating a new Project"]
    
    grid $ft1.txt -column 0 -row 0 -sticky nw
    
    # Frame 2
    listbox $ft2.lbox -height 15 -width 30 \
            -yscrollcommand [list $ft2.scrolly set] \
            -xscrollcommand [list $ft2.scrollx set]
    
    ttk::scrollbar $ft2.scrolly -orient v -command [list $ft2.lbox yview]
    ttk::scrollbar $ft2.scrollx -orient h -command [list $ft2.lbox xview]
    
    ::autoscroll::autoscroll $ft2.scrolly ;# Enable the 'autoscrollbar'
    ::autoscroll::autoscroll $ft2.scrollx

    ttk::button $ft2.btn -text [mc "Delete"] -command "customer::deleteFromlbox $ft2.lbox [lindex $custList 0]"
    
    grid $ft2.lbox -column 0 -row 0 -sticky news
    grid $ft2.scrolly -column 1 -row 0 -sticky nse
    grid $ft2.scrollx -column 0 -row 1 -sticky ews
    
    grid $ft2.btn -column 1 -row 0 -sticky ne -padx 2p
    
    # Populate the title listbox   
    foreach title [eAssist_db::dbWhereQuery -columnNames TitleName -table PubTitle -where CustID='[lindex $custList 0]'] {
        $ft2.lbox insert end [join $title]
    }
    
    ##
    ## Control Buttons    
    ttk::button $btns.btn0 -text [mc "OK"] -command "customer::dbAddShipVia $f3a.lbox $f0a.entry1" -state disable
    ttk::button $btns.btn1 -text [mc "Cancel"] -command [list destroy $wid]
    
    grid $btns.btn0 -column 0 -row 0
    grid $btns.btn1 -column 1 -row 0
    
    
    # Reconfigurations
    $f0a.entry1 configure -validate key -validatecommand "customer::validateEntry $btns.btn0 $f2a.btn1 $f2a.btn2 %W %P"


} ;# customer::Modify

