# Creator: Casey Ackels
# Initial Date: March 12, 2011]
# File Initial Date: 01 19,2014
# Dependencies: 
#-------------------------------------------------------------------------------
#
# Subversion
#
# $Revision: 169 $
# $LastChangedBy: casey.ackels $
# $LastChangedDate$
#
########################################################################################

##
## - Overview
# Setup Carrier Methods

## Coding Conventions
# - Namespaces: Firstword_Secondword

# - Procedures: Proc names should have two words. The first word lowercase the first character of the first word,
#   will be uppercase. I.E sourceFiles, sourceFileExample


proc eAssistSetup::carrierMethod_GUI {} {
    #****f* carrierMethod_GUI/eAssistSetup
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2011-2013 Casey Ackels
    #
    # FUNCTION
    #	Add/Remove and Configure Carrier Methods
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
    global G_setupFrame log carrierSetup
    global f1 f2 f3 f4 f5 ;# Used for bindings only
    
    eAssist_Global::resetSetupFrames ;# Reset all frames so we start clean
    
    #-------- Container Frame
    set frame0 [ttk::label $G_setupFrame.frame0]
    pack $frame0 -expand yes -fill both -pady 5p -padx 5p
    
    ##
    ## Notebook
    ##
    
    set w(carrier) [ttk::notebook $frame0.carrierNotebook]
    pack $w(carrier) -expand yes -fill both
    
    ttk::notebook::enableTraversal $w(carrier)
    
    #
    # Setup the notebook
    #
    $w(carrier) add [ttk::frame $w(carrier).ctbl] -text [mc "General"]
    $w(carrier) add [ttk::frame $w(carrier).shipvia] -text [mc "Ship Via"]
    $w(carrier) add [ttk::frame $w(carrier).advanced] -text [mc "Advanced"] -state disabled
    $w(carrier) add [ttk::frame $w(carrier).frtrates] -text [mc "Freight Rates"] -state disabled
    $w(carrier) add [ttk::frame $w(carrier).upsrates] -text [mc "UPS Rates"] -state disabled
    $w(carrier) add [ttk::frame $w(carrier).fedexrates] -text [mc "FedEx Rates"] -state disabled
    
    $w(carrier) select $w(carrier).ctbl

    
    ##
    ## Tab 1 (General)
    ##
    
    #
    # --- Frame 1 Payment Types
    #
    set f1 [ttk::labelframe $w(carrier).ctbl.f1 -text [mc "Payment Types"] -padding 10]
    grid $f1 -column 0 -row 0 -pady 5p -padx 5p -sticky new

    
    ttk::entry $f1.entry -textvariable carrierSetup(enterPaymentType)
        tooltip::tooltip $f1.entry [mc "Use the Enter Key to add items"]
    
    listbox $f1.lbox -width 30 \
                    -yscrollcommand [list $f1.yPayment set] \
                    -xscrollcommand [list $f1.xPayment set]
        tooltip::tooltip $f1.lbox [mc "Use the Backspace Key to remove items"]
    
    
    # setup the Autoscrollbars
    ttk::scrollbar $f1.xPayment -orient horizontal -command [list $f1.lbox xview]
    ttk::scrollbar $f1.yPayment -orient vertical -command [list $f1.lbox yview]
     
    ::autoscroll::autoscroll $f1.xPayment ;# Enable the 'autoscrollbar'
    ::autoscroll::autoscroll $f1.yPayment
    
    
    grid $f1.entry      -column 0 -row 0 -sticky news
    grid $f1.lbox       -column 0 -row 1 -sticky news
    grid $f1.yPayment   -column 1 -row 1 -sticky ens
    grid $f1.xPayment   -column 0 -row 2 -sticky esw
    
    
    grid columnconfigure $f1 $f1.lbox -weight 1
    grid rowconfigure $f1 $f1.lbox -weight 1

    ea::tools::bindings $f1.entry {Return KP_Enter} {eAssistSetup::controlCarrierSetup add $f1.entry $f1.lbox -columnNames Payer -table FreightPayer; $f1.lbox see end}
    ea::tools::bindings $f1.lbox {Delete BackSpace} {eAssistSetup::controlCarrierSetup delete $f1.entry $f1.lbox -columnNames Payer -table FreightPayer}
    
    # Populate the listbox if we have existing data
    eAssistSetup::controlCarrierSetup query $f1.entry $f1.lbox -columnNames Payer -table FreightPayer
    
    #
    # --- Frame 2, Shipment Type
    #
    set f2 [ttk::labelframe $w(carrier).ctbl.f2 -text [mc "Shipment Type"] -padding 10]
    grid $f2 -column 1 -row 0 -pady 5p -padx 5p -sticky new
        
    ttk::entry $f2.entry -textvariable carrierSetup(enterShipmentType)    
    listbox $f2.lbox -width 30 \
                    -xscrollcommand [list $f2.xShipment set] \
                    -yscrollcommand [list $f2.xShipment set]
    
    # setup the Autoscrollbars
    ttk::scrollbar $f2.xShipment -orient h -command [list $f2.lbox xview]
    ttk::scrollbar $f2.yShipment -orient v -command [list $f2.lbox yview]
    
    grid $f2.entry      -column 0 -row 0 -sticky swe
    grid $f2.lbox       -column 0 -row 1 -sticky news
    grid $f2.xShipment  -column 0 -row 2 -sticky ews
    grid $f2.yShipment  -column 1 -row 1 -sticky ens
    
    ::autoscroll::autoscroll $f2.xShipment ;# Enable the 'autoscrollbar'
    ::autoscroll::autoscroll $f2.yShipment
    
    grid columnconfigure $f2 $f2.lbox -weight 1
    grid rowconfigure $f2 $f2.lbox -weight 1
    
    ea::tools::bindings $f2.entry {Return KP_Enter} {eAssistSetup::controlCarrierSetup add $f2.entry $f2.lbox -columnNames ShipmentType -table ShipmentTypes; $f2.lbox see end}
    ea::tools::bindings $f2.lbox {Delete BackSpace} {eAssistSetup::controlCarrierSetup delete $f2.entry $f2.lbox -columnNames ShipmentType -table ShipmentTypes}
    
    # Populate the listbox if we have existing data
    eAssistSetup::controlCarrierSetup query $f2.entry $f2.lbox -columnNames ShipmentType -table ShipmentTypes

    
    #
    # --- Frame 3, Carriers
    #
    set f3 [ttk::labelframe $w(carrier).ctbl.f3 -text [mc "Carriers"] -padding 10]
    grid $f3 -column 2 -row 0 -pady 5p -padx 5p -sticky news

    
    ttk::entry $f3.entry -textvariable carrierSetup(enterCarrier)   
    listbox $f3.lbox -width 30 \
                    -xscrollcommand [list $f3.xCarriers set] \
                    -yscrollcommand [list $f3.yCarriers set]

    
    # setup the Autoscrollbars
    ttk::scrollbar $f3.xCarriers -orient h -command [list $f3.lbox xview]
    ttk::scrollbar $f3.yCarriers -orient v -command [list $f3.lbox yview]
    
    grid $f3.entry      -column 0 -row 0 -sticky swe
    grid $f3.lbox       -column 0 -row 1 -sticky news
    grid $f3.xCarriers  -column 0 -row 2 -sticky ews
    grid $f3.yCarriers  -column 1 -row 1 -sticky ens
    
    ::autoscroll::autoscroll $f3.xCarriers ;# Enable the 'autoscrollbar'
    ::autoscroll::autoscroll $f3.yCarriers

    ea::tools::bindings $f3.entry {Return KP_Enter} {eAssistSetup::controlCarrierSetup add $f3.entry $f3.lbox -columnNames Name -table Carriers; $f3.lbox see end}
    ea::tools::bindings $f3.lbox {Delete BackSpace} {eAssistSetup::controlCarrierSetup delete $f3.entry $f3.lbox -columnNames Name -table Carriers}
    
    # Populate the listbox if we have existing data
    eAssistSetup::controlCarrierSetup query $f3.entry $f3.lbox -columnNames Name -table Carriers

    
    #
    # --- Frame 4, Rate Types
    #
    set f4 [ttk::labelframe $w(carrier).ctbl.f4 -text [mc "Rate Types"] -padding 10]
    grid $f4 -column 0 -row 1 -pady 5p -padx 5p -sticky news
    
    #grid columnconfigure $w(carrier).ctbl $f3 -weight 1
    #grid rowconfigure $w(carrier).ctbl $f3 -weight 1
    
    ttk::entry $f4.entry -textvariable carrierSetup(enterRateType)    
    listbox $f4.lbox -width 30 \
                    -xscrollcommand [list $f4.xRateType set] \
                    -yscrollcommand [list $f4.yRateType set]

    # setup the Autoscrollbars
    ttk::scrollbar $f4.xRateType  -orient h -command [list $f4.lbox xview]
    ttk::scrollbar $f4.yRateType  -orient v -command [list $f4.lbox yview]
    
    ::autoscroll::autoscroll $f4.xRateType  ;# Enable the 'autoscrollbar'
    ::autoscroll::autoscroll $f4.yRateType 
    
    grid $f4.entry      -column 0 -row 0 -sticky swe
    grid $f4.lbox       -column 0 -row 1 -sticky news
    grid $f4.xRateType  -column 0 -row 2 -sticky ews
    grid $f4.yRateType  -column 1 -row 1 -sticky ens

    ea::tools::bindings $f4.entry {Return KP_Enter} {eAssistSetup::controlCarrierSetup add $f4.entry $f4.lbox -columnNames RateType -table RateTypes; $f4.lbox see end}
    ea::tools::bindings $f4.lbox {Delete BackSpace} {eAssistSetup::controlCarrierSetup delete $f4.entry $f4.lbox -columnNames RateType -table RateTypes}
    
    # Populate the listbox if we have existing data
    eAssistSetup::controlCarrierSetup query $f4.entry $f4.lbox -columnNames RateType -table RateTypes

    
    #
    # --- Frame 5, Shipping Class
    #
    set f5 [ttk::labelframe $w(carrier).ctbl.f5 -text [mc "Shipping Class"] -padding 10]
    
    grid $f5 -column 1 -row 1 -pady 5p -padx 5p -sticky news
    
    ttk::entry $f5.entry -textvariable carrierSetup(enterShippingClass)    
    listbox $f5.lbox -width 30 \
                    -xscrollcommand [list $f5.xShippingClass set] \
                    -yscrollcommand [list $f5.yShippingClass set]

    # setup the Autoscrollbars
    ttk::scrollbar $f5.xShippingClass  -orient h -command [list $f5.lbox xview]
    ttk::scrollbar $f5.yShippingClass  -orient v -command [list $f5.lbox yview]
    
    ::autoscroll::autoscroll $f5.xShippingClass  ;# Enable the 'autoscrollbar'
    ::autoscroll::autoscroll $f5.yShippingClass
    
    grid $f5.entry           -column 0 -row 0 -sticky swe
    grid $f5.lbox            -column 0 -row 1 -sticky news
    grid $f5.xShippingClass  -column 0 -row 2 -sticky ews
    grid $f5.yShippingClass  -column 1 -row 1 -sticky ens

    
    ea::tools::bindings $f5.entry {Return KP_Enter} {eAssistSetup::controlCarrierSetup add $f5.entry $f5.lbox -columnNames ShippingClass -table ShippingClasses; $f5.lbox see end}
    ea::tools::bindings $f5.lbox {Delete BackSpace} {eAssistSetup::controlCarrierSetup delete $f5.entry $f5.lbox -columnNames ShippingClass -table ShippingClasses}
    
    # Populate the listbox if we have existing data
    eAssistSetup::controlCarrierSetup query $f5.entry $f5.lbox -columnNames ShippingClass -table ShippingClasses
    
    
    ##
    ## Tab 2 (Ship Via)
    ##
    
    #
    # --- Frame 1 Container Frame
    set f1C [ttk::frame $w(carrier).shipvia.f1]
    pack $f1C -anchor n -fill x
    
    set f1S [ttk::labelframe $w(carrier).shipvia.f1.a -text [mc "Ship Via Setup"] -padding 10]
    grid $f1S -column 0 -row 0 -pady 5p -padx 5p -sticky n
    
    ttk::label $f1S.txt1 -text [mc "Ship Via Code"]
    ttk::entry $f1S.01entry1
    
    ttk::label $f1S.txt3 -text [mc "Carrier"]
    ttk::combobox $f1S.03cbox1 -postcommand "$f1S.03cbox1 configure -values [list [eAssist_db::dbSelectQuery -columnNames Name -table Carriers]]"
    bind $f1S.03cbox1 <FocusIn> "$f1S.03cbox1 configure -values [list [eAssist_db::dbSelectQuery -columnNames Name -table Carriers]]"
    bind $f1S.03cbox1 <KeyRelease> [list AutoComplete::AutoCompleteComboBox $f1S.03cbox1 %K]
    
    ttk::label $f1S.txt4 -text [mc "Payment Type"]
    ttk::combobox $f1S.04cbox2 -postcommand "$$f1S.04cbox2 configure -values [list [eAssist_db::dbSelectQuery -columnNames Payer -table FreightPayer]]"
    bind $f1S.04cbox2 <FocusIn> "$f1S.04cbox2 configure -values [list [eAssist_db::dbSelectQuery -columnNames Payer -table FreightPayer]]"
    bind $f1S.04cbox2 <KeyRelease> [list AutoComplete::AutoCompleteComboBox $f1S.04cbox2 %K]
    
    ttk::label $f1S.txt5 -text [mc "Shipment Type"]
    ttk::combobox $f1S.05cbox3 -postcommand "$f1S.05cbox3 configure -values [list [eAssist_db::dbSelectQuery -columnNames ShipmentType -table ShipmentTypes]]"
    bind $f1S.05cbox3 <FocusIn> "$f1S.05cbox3 configure -values [list [eAssist_db::dbSelectQuery -columnNames ShipmentType -table ShipmentTypes]]"
    bind $f1S.05cbox3 <KeyRelease> [list AutoComplete::AutoCompleteComboBox $f1S.05cbox3 %K]

    #bind $f1S.cbox1 <<ComboboxSelected>> "$f1S.cbox1 configure -values [list [eAssist_db::dbSelectQuery -columnNames Name -table Carriers]]"
    
    ttk::label $f1S.txt2 -text [mc "Ship Via Name"]
    ttk::entry $f1S.02entry2

    
    grid $f1S.txt1 -column 0 -row 0 -pady 2p -padx 2p -sticky nse
    grid $f1S.01entry1 -column 1 -row 0 -pady 2p -padx 2p -sticky news
    grid $f1S.txt3 -column 0 -row 1 -pady 2p -padx 2p -sticky nse
    grid $f1S.03cbox1 -column 1 -row 1 -pady 2p -padx 2p -sticky news
    grid $f1S.txt4 -column 0 -row 2 -pady 2p -padx 2p -sticky nse
    grid $f1S.04cbox2 -column 1 -row 2 -pady 2p -padx 2p -sticky news
    grid $f1S.txt5 -column 0 -row 3 -pady 2p -padx 2p -sticky nse
    grid $f1S.05cbox3 -column 1 -row 3 -pady 2p -padx 2p -sticky news
    
    grid $f1S.txt2 -column 3 -row 0 -pady 2p -padx 2p -sticky nse
    grid $f1S.02entry2 -column 4 -row 0 -pady 2p -padx 2p -sticky news
    #grid $f1S.txt6 -column 3 -row 1 -pady 2p -padx 2p -sticky nse
    #grid $f1S.cbox4 -column 4 -row 1 -pady 2p -padx 2p -sticky news

    ## BUTTONS
    set f1aS [ttk::frame $w(carrier).shipvia.f1.b -padding 10 ]
    grid $f1aS -column 1 -row 0 -pady 5p -sticky n
    
    set f2S [ttk::frame $w(carrier).shipvia.f2 -padding 10]
    
    ttk::button $f1aS.btn1 -text [mc "Add"] -command "eAssistSetup::controlShipVia add -wid $f1S -tbl $f2S.tbl -dbtbl Carriers -btn $f1aS"
    ttk::button $f1aS.btn2 -text [mc "Delete"] -state disabled -command "eAssistSetup::controlShipVia delete -wid $f1S -tbl $f2S.tbl -dbtbl Carriers -btn $f1aS"
    ttk::button $f1aS.btn3 -text [mc "Clear"] -state disabled -command "eAssistSetup::controlShipVia clear -wid $f1S -tbl $f2S.tbl -dbtbl Carriers -btn $f1aS"
    grid $f1aS.btn1 -column 0 -row 0 ;#-pady 2p -padx 2p -sticky new
    grid $f1aS.btn2 -column 0 -row 1 ;#-pady 2p -padx 2p -sticky new
    grid $f1aS.btn3 -column 0 -row 2
    
    ## Table list
    #set f2S [ttk::frame $w(carrier).shipvia.f2 -padding 10]
    pack $f2S -anchor sw -fill both -expand yes 
    
    tablelist::tablelist $f2S.tbl -columns {
                                                0   "..." center
                                                0   "Ship Via Code" center
                                                30  "Ship Via Name"
                                                25  "Carrier"
                                                0   "Payment Type" center
                                                0   "Shipment Type" center} \
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
                                        -yscrollcommand [list $f2S.scrolly set] \
                                        -xscrollcommand [list $f2S.scrollx set]
                                                
        # The internal names are the same spelling/capitalization as the db columns in table Countries
        $f2S.tbl columnconfigure 0 -name "count" \
                                            -showlinenumbers 1 \
                                            -labelalign center
        
        $f2S.tbl columnconfigure 1 -name "ShipViaCode" \
                                            -labelalign center \
        
        $f2S.tbl columnconfigure 2 -name "ShipViaName" \
                                            -labelalign center
        
        $f2S.tbl columnconfigure 3 -name "Carrier" \
                                            -labelalign center
        
        $f2S.tbl columnconfigure 4 -name "PaymentType" \
                                            -labelalign center
        
        $f2S.tbl columnconfigure 5 -name "ShipmentType" \
                                            -labelalign center
        
        
    ttk::scrollbar $f2S.scrolly -orient v -command [list $f2S.tbl yview]
    ttk::scrollbar $f2S.scrollx -orient h -command [list $f2S.tbl xview]
	
    grid $f2S.tbl -column 0 -row 0 -sticky news
    grid columnconfigure $f2S $f2S.tbl -weight 1
    grid rowconfigure $f2S $f2S.tbl -weight 1
    
    grid $f2S.scrolly -column 1 -row 1 -sticky nse
    grid $f2S.scrollx -column 0 -row 2 -sticky ews
    
    ::autoscroll::autoscroll $f2S.scrolly ;# Enable the 'autoscrollbar'
    ::autoscroll::autoscroll $f2S.scrollx
    
    # Populate the entries with the selected row so we can edit/modify the data.
    bind [$f2S.tbl bodytag] <Double-ButtonRelease-1> "
        eAssistSetup::editShipVia $f1S $f2S.tbl {}
        ea::tools::modifyButton $f1aS.btn1 -text [mc Modify]
        ea::tools::modifyButton $f1aS.btn2 -state enabled
        ea::tools::modifyButton $f1aS.btn3 -state enabled
    "
    
    #bind [$f2S.tbl bodytag] <ButtonRelease-1> "eAssistSetup::controlShipVia clear -wid $f1S -tbl $f2S.tbl -dbtbl Carriers -btn $f1aS"
    
    # Refresh tbl and reread from db
    $f2S.tbl delete 0 end
    set recordList [eAssist_db::dbSelectQuery -columnNames "ShipViaCode ShipViaName CarrierName FreightPayerType ShipmentType" -table ShipVia]
    #$tbl insert end "{} $valueList"
    foreach record $recordList {
        $f2S.tbl insert end "{} $record"
    }

    
} ;# eAssistSetup::carrierMethod_GUI


#Remove buttons, and create bindings to the <Enter> key; <Delete> key, and a <Double-1> to delete
