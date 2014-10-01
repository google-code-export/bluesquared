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
    global log G_setupFrame w
    variable GUI
    # init vars
    set f1 ""
    set f2 ""


    eAssist_Global::resetSetupFrames ;# Reset all frames so we start clean
    
    #-------- Container Frame
    set frame1 [ttk::label $G_setupFrame.frame1]
    pack $frame1 -expand yes -fill both -pady 5p -padx 5p
    
    ##
    ## Notebook
    ##
    
    set w(countries) [ttk::notebook $frame1.countriesNBK]
    pack $w(countries) -expand yes -fill both
    
    ttk::notebook::enableTraversal $w(countries)
    
    #
    # Setup the notebook
    #
    $w(countries) add [ttk::frame $w(countries).country] -text [mc "Countries/Regions"]
    $w(countries) add [ttk::frame $w(countries).region] -text [mc "Postal Codes"]
    
    $w(countries) select $w(countries).country

    
    ##
    ## Tab 1
    ##
    

    ##
    ## Create the frames
    ##
    set f1 [ttk::frame $w(countries).country.f1]
    pack $f1 -padx 5p -pady 5p -fill both
    
    set f2 [ttk::labelframe $w(countries).country.f2 -text [mc "Countries"] -padding 10]
    pack $f2 -pady 5p -fill both
    
    set f3 [ttk::frame $w(countries).country.f3]
    pack $f3 -padx 5p -pady 5p -fill both
    
    set tbl2 [ttk::labelframe $w(countries).country.tbl2 -text [mc "Province/Regions"] -padding 10]
    pack $tbl2 -padx 5p -pady 5p -fill both

    #
    # --- Frame 1
    #   
    ttk::button $f1.btn1 -text [mc "Add"] -command "eAssistSetup::modifyCountry $f2.listbox -add"
    ttk::button $f1.btn2 -text [mc "Delete"] -command "eAssistSetup::modifyCountry $f2.listbox -del"
    
    grid $f1.btn1 -column 0 -row 0 -padx 2p -pady 5p -sticky nsw
    grid $f1.btn2 -column 1 -row 0 -padx 2p -pady 5p -sticky nsw
    
    #
    # --- Frame 2 Countries
    #
    tablelist::tablelist $f2.listbox -columns {
                                                0   "..." center
                                                0  "ISO Country Code"
                                                50  "Name"} \
                                        -showlabels yes \
                                        -height 10 \
                                        -selectbackground yellow \
                                        -selectforeground black \
                                        -stripebackground lightblue \
                                        -exportselection yes \
                                        -showseparators yes \
                                        -fullseparators yes \
                                        -selectmode single \
                                        -editselectedonly 1 \
                                        -selecttype cell \
                                        -yscrollcommand [list $f2.scrolly set] \
                                        -xscrollcommand [list $f2.scrollx set] \
                                        -editstartcommand {eAssistSetup::placeholder} \
                                        -editendcommand {eAssistSetup::countryEditEnd}
        
    
        # The internal names are the same spelling/capitalization as the db columns in table Countries
        $f2.listbox columnconfigure 0 -name "count" \
                                            -showlinenumbers 1 \
                                            -labelalign center
    
        $f2.listbox columnconfigure 1 -name "CountryCode" \
                                            -editable yes \
                                            -editwindow ttk::entry \
                                            -labelalign center
        
        $f2.listbox columnconfigure 2 -name "CountryName" \
                                            -editable yes \
                                            -editwindow ttk::entry \
                                            -labelalign center

    ttk::scrollbar $f2.scrolly -orient v -command [list $f2.listbox yview]
    ttk::scrollbar $f2.scrollx -orient h -command [list $f2.listbox xview]

    
    grid $f2.listbox -column 0 -row 1 -sticky news
    
    grid columnconfigure $f2 $f2.listbox -weight 1
    grid rowconfigure $f2 $f2.listbox -weight 1
    
    grid $f2.scrolly -column 1 -row 0 -sticky nse
    grid $f2.scrollx -column 0 -row 1 -sticky ews
    
    ::autoscroll::autoscroll $f2.scrolly ;# Enable the 'autoscrollbar'
    ::autoscroll::autoscroll $f2.scrollx
    
    set countries [eAssist_db::dbSelectQuery -columnNames "CountryCode CountryName" -table Countries]
    if {$countries != ""} {
        foreach country $countries {
            $f2.listbox insert end [list {} [lrange $country 0 0] [lrange $country 1 end]]
            ${log}::debug Country code: [lrange $country 0 0] Name: [lrange $country 1 end]
        }
    }
    

    
    #
    # --- Frame 3
    #   
    ttk::button $f3.btn1 -text [mc "Add"] -command "eAssistSetup::modifyCountry $tbl2.tbl2 -add"
    ttk::button $f3.btn2 -text [mc "Delete"] -command "eAssistSetup::modifyCountry $tbl2.tbl2 -del"
    
    grid $f3.btn1 -column 0 -row 0 -padx 2p -pady 5p -sticky nsw
    grid $f3.btn2 -column 1 -row 0 -padx 2p -pady 5p -sticky nsw
    
    
    ##
    ## Frame 4 - Province/Regions
    ##
    tablelist::tablelist $tbl2.tbl2 -columns {
                                                0   "..." center
                                                0 "Abbreviation"
                                                50 "Name"
                                                25 "PostCode Hi-End"
                                                25 "PostCode Lo-End"} \
                                        -showlabels yes \
                                        -height 10 \
                                        -selectbackground yellow \
                                        -selectforeground black \
                                        -stripebackground lightblue \
                                        -exportselection yes \
                                        -showseparators yes \
                                        -fullseparators yes \
                                        -selectmode single \
                                        -editselectedonly 1 \
                                        -selecttype cell \
                                        -yscrollcommand [list $tbl2.scrolly set] \
                                        -xscrollcommand [list $tbl2.scrollx set] \
                                        -editstartcommand {eAssistSetup::placeholder} \
                                        -editendcommand {eAssistSetup::provinceEditEnd}
    
        # The internal names are the same spelling/capitalization as the db columns in table Countries
        $tbl2.tbl2 columnconfigure 0 -name "count" \
                                            -showlinenumbers 1 \
                                            -labelalign center
        
        $tbl2.tbl2 columnconfigure 1 -name "ProvAbbr" \
                                            -editable yes \
                                            -editwindow ttk::entry \
                                            -labelalign center
        
        $tbl2.tbl2 columnconfigure 2 -name "ProvName" \
                                            -editable yes \
                                            -editwindow ttk::entry \
                                            -labelalign center
        
        $tbl2.tbl2 columnconfigure 3 -name "PostalCodeLowEnd" \
                                            -editable yes \
                                            -editwindow ttk::entry \
                                            -labelalign center
        
        $tbl2.tbl2 columnconfigure 4 -name "PostalCodeHighEnd" \
                                            -editable yes \
                                            -editwindow ttk::entry \
                                            -labelalign center

        
    ttk::scrollbar $tbl2.scrolly -orient v -command [list $tbl2.listbox yview]
    ttk::scrollbar $tbl2.scrollx -orient h -command [list $tbl2.listbox xview]
    
    grid $tbl2.tbl2 -column 0 -row 1 -sticky news
    
    grid columnconfigure $tbl2 $tbl2.tbl2 -weight 1
    grid rowconfigure $tbl2 $tbl2.tbl2 -weight 1
    
    grid $tbl2.scrolly -column 1 -row 0 -sticky nse
    grid $tbl2.scrollx -column 0 -row 1 -sticky ews
    
    ::autoscroll::autoscroll $tbl2.scrolly ;# Enable the 'autoscrollbar'
    ::autoscroll::autoscroll $tbl2.scrollx
    
    # Populate the table
    bind $f2.listbox <<TablelistSelect>> "eAssistSetup::dbGetProvinces $tbl2.tbl2 $f2.listbox"
    
    #bind $tbl2.listbox <<TablelistSelect>> {${log}::debug Table Selection: %W}
} ;# eAssistSetup::countries_GUI
