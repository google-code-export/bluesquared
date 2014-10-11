# Creator: Casey Ackels
# Initial Date: March 12, 2011]
# File Initial Date: 09 29,2014
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
# Add/Remove Countries and Regions that the user ships to.

## Coding Conventions
# - Namespaces: Firstword_Secondword

# - Procedures: Proc names should have two words. The first word lowercase the first character of the first word,
#   will be uppercase. I.E sourceFiles, sourceFileExample


proc eAssistSetup::countries_GUI {} {
    #****f* countries_GUI/eAssistSetup
    # CREATION DATE
    #   09/29/2014 (Monday Sep 29)
    #
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2014 Casey Ackels
    #   
    #
    # SYNOPSIS
    #   eAssistSetup::countries_GUI  
    #
    # FUNCTION
    #	Displays the widgets associated with the Countries tabs
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
    global log G_setupFrame

    eAssist_Global::resetSetupFrames ;# Reset all frames so we start clean
    set countryValues ""
    
    #-------- Container Frame
    set frame1 [ttk::label $G_setupFrame.frame1]
    pack $frame1 -expand yes -fill both -pady 5p -padx 5p
    
    #
    # --- Frame 1 - Countries
    #   
    set f1 [ttk::labelframe $frame1.f1 -text [mc "Countries"] -padding 10]
    pack $f1 -expand yes -fill both

        ## Child frame for the buttons
        set f1_b [ttk::frame $f1.btns]
        grid $f1_b -sticky nsw ;#-column 0 -row 0 -sticky nse
        
        ttk::label $f1_b.txt1 -text [mc "2-Digit Code"]
        ttk::entry $f1_b.entry1
        ttk::label $f1_b.txt2 -text [mc "Name"]
        ttk::entry $f1_b.entry2
        
        ttk::button $f1_b.btn1 -text [mc "Add"] -command "eAssistSetup::modifyCountry $f1.listbox $f1_b"
        ttk::button $f1_b.btn2 -text [mc "Delete"] -command "eAssistSetup::delCountryProv $f1.listbox"
        
        grid $f1_b.txt1 -column 0 -row 0 -padx 2p -pady 2p -sticky nse
        grid $f1_b.entry1 -column 1 -row 0 -padx 2p -pady 2p
        grid $f1_b.txt2 -column 0 -row 1 -padx 2p -pady 2p -sticky nse
        grid $f1_b.entry2 -column 1 -row 1 -padx 2p -pady 2p
        
        grid $f1_b.btn1 -column 2 -row 0 -padx 0p -pady 0p -sticky nsw
        grid $f1_b.btn2 -column 2 -row 1 -padx 0p -pady 0p -sticky nsw
    
    tablelist::tablelist $f1.listbox -columns {
                                                0   "..." center
                                                0  "2-Digit Code"
                                                50  "Name"} \
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
                                        -yscrollcommand [list $f1.scrolly set] \
                                        -xscrollcommand [list $f1.scrollx set] \
                                        -editstartcommand {eAssistSetup::placeholder} \
                                        -editendcommand {eAssistSetup::countryEditEnd}
        
    
        # The internal names are the same spelling/capitalization as the db columns in table Countries
        $f1.listbox columnconfigure 0 -name "count" \
                                            -showlinenumbers 1 \
                                            -labelalign center
    
        $f1.listbox columnconfigure 1 -name "CountryCode" \
                                            -editable yes \
                                            -editwindow ttk::entry \
                                            -labelalign center
        
        $f1.listbox columnconfigure 2 -name "CountryName" \
                                            -editable yes \
                                            -editwindow ttk::entry \
                                            -labelalign center

    ttk::scrollbar $f1.scrolly -orient v -command [list $f1.listbox yview]
    ttk::scrollbar $f1.scrollx -orient h -command [list $f1.listbox xview]

    
    grid $f1.listbox -column 0 -row 1 -sticky news
    
    grid columnconfigure $f1 $f1.listbox -weight 1
    #grid rowconfigure $f1 $f1.listbox -weight 1
    
    grid $f1.scrolly -column 1 -row 0 -sticky nse
    grid $f1.scrollx -column 0 -row 1 -sticky ews
    
    ::autoscroll::autoscroll $f1.scrolly ;# Enable the 'autoscrollbar'
    ::autoscroll::autoscroll $f1.scrollx
    
    set countries [eAssist_db::dbSelectQuery -columnNames "CountryCode CountryName" -table Countries]
    if {$countries != ""} {
        foreach country $countries {
            $f1.listbox insert end [list {} [lrange $country 0 0] [lrange $country 1 end]]
            ${log}::debug Country code: [lrange $country 0 0] Name: [lrange $country 1 end]
        }
    }
    

    
    #
    # --- Frame 2
    #
    set f2 [ttk::labelframe $frame1.f2 -text [mc "Province/Regions"] -padding 10]
    pack $f2 -expand yes -fill both
    
        ## Child frame for the buttons
        set f2_b [ttk::frame $f2.btns]
        grid $f2_b -sticky nsw -pady 2p ;#-column 0 -row 0 -sticky nse
        
        ttk::label $f2_b.txt0 -text [mc "Country"]
        ttk::combobox $f2_b.cbx1 -state readonly \
                                    -postcommand [list eAssistSetup::getCountries $f2_b]
        
        ttk::label $f2_b.txt1 -text [mc "Abbreviation"]
        ttk::entry $f2_b.entry1
        
        ttk::label $f2_b.txt2 -text [mc "Name"]
        ttk::entry $f2_b.entry2
        
        ttk::label $f2_b.txt3 -text [mc "PostCode Low End"]
        ttk::entry $f2_b.entry3
        
        ttk::label $f2_b.txt4 -text [mc "PostCode High End"]
        ttk::entry $f2_b.entry4
       
        ttk::button $f2_b.btn1 -text [mc "Add"] -command "eAssistSetup::modifyCountry $f2.tbl2 $f2_b"
        ttk::button $f2_b.btn2 -text [mc "Delete"] -command "eAssistSetup::delCountryProv $f2.tbl2"
        #ttk::button $f2_b.btn3 -text [mc "Save"] -command "eAssistSetup::dbInsertProv $f2.tbl2"
        
        grid $f2_b.txt0 -column 0 -row 0 -sticky nse -pady 1p -padx 2p
        grid $f2_b.cbx1 -column 1 -row 0 -sticky ew
        grid $f2_b.txt1 -column 0 -row 1 -sticky nse -pady 1p -padx 2p
        grid $f2_b.entry1 -column 1 -row 1 -sticky ew
        grid $f2_b.txt2 -column 0 -row 2 -sticky nse -pady 1p -padx 2p
        grid $f2_b.entry2 -column 1 -row 2 -sticky ew
        
        grid $f2_b.txt3 -column 2 -row 0 -sticky nse -pady 1p -padx 2p
        grid $f2_b.entry3 -column 3 -row 0 -sticky ew
        grid $f2_b.txt4 -column 2 -row 1 -sticky nse -pady 1p -padx 2p
        grid $f2_b.entry4 -column 3 -row 1 -sticky ew
        
        grid $f2_b.btn1 -column 4 -row 0 -padx 2p -pady 1p -sticky nsw
        grid $f2_b.btn2 -column 4 -row 1 -padx 2p -pady 1p -sticky nsw
    


    tablelist::tablelist $f2.tbl2 -columns {
                                                0   "..." center
                                                0 "Abbreviation"
                                                50 "Name"
                                                25 "PostCode Low End"
                                                25 "PostCode High End"} \
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
                                        -xscrollcommand [list $f2.scrollx set] \
                                        -editstartcommand {eAssistSetup::placeholder} \
                                        -editendcommand {eAssistSetup::provinceEditEnd}
    
        # The internal names are the same spelling/capitalization as the db columns in table Countries
        $f2.tbl2 columnconfigure 0 -name "count" \
                                            -showlinenumbers 1 \
                                            -labelalign center
        
        $f2.tbl2 columnconfigure 1 -name "ProvAbbr" \
                                            -editable yes \
                                            -editwindow ttk::entry \
                                            -labelalign center
        
        $f2.tbl2 columnconfigure 2 -name "ProvName" \
                                            -editable yes \
                                            -editwindow ttk::entry \
                                            -labelalign center
        
        $f2.tbl2 columnconfigure 3 -name "PostalCodeLowEnd" \
                                            -editable yes \
                                            -editwindow ttk::entry \
                                            -labelalign center
        
        $f2.tbl2 columnconfigure 4 -name "PostalCodeHighEnd" \
                                            -editable yes \
                                            -editwindow ttk::entry \
                                            -labelalign center

        
    ttk::scrollbar $f2.scrolly -orient v -command [list $f2.listbox yview]
    ttk::scrollbar $f2.scrollx -orient h -command [list $f2.listbox xview]
    
    grid $f2.tbl2 -column 0 -row 1 -sticky news
    
    grid columnconfigure $f2 $f2.tbl2 -weight 1
    #grid rowconfigure $f2 $f2.tbl2 -weight 1
    
    grid $f2.scrolly -column 1 -row 0 -sticky nse
    grid $f2.scrollx -column 0 -row 1 -sticky ews
    
    ::autoscroll::autoscroll $f2.scrolly ;# Enable the 'autoscrollbar'
    ::autoscroll::autoscroll $f2.scrollx
    
    bind $f2_b.cbx1 <<ComboboxSelected>> "eAssistSetup::dbGetProvinces $f2.tbl2 %W"
    #eAssistSetup::dbGetProvinces $f2.tbl2 %W
    
    
    # Populate the table the province table
    #bind $f1.listbox <<TablelistSelect>> "eAssistSetup::dbGetProvinces $f2.tbl2 $f1.listbox"
    
    #bind $tbl2.listbox <<TablelistSelect>> {${log}::debug Table Selection: %W}
} ;# eAssistSetup::countries_GUI
