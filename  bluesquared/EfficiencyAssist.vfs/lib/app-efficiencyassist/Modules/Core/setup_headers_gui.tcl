# Creator: Casey Ackels
# Initial Date: March 12, 2011]
# File Initial Date: 10 11,2013
# Dependencies: 
#-------------------------------------------------------------------------------
#
# Subversion
#
# $Revision: 444 $
# $LastChangedBy: casey.ackels@gmail.com $
# $LastChangedDate$
#
########################################################################################

##
## - Overview
# Overview

## Coding Conventions
# - Namespaces: Firstword_Secondword

# - Procedures: Proc names should have two words. The first word lowercase the first character of the first word,
#   will be uppercase. I.E sourceFiles, sourceFileExample


proc eAssistSetup::addressHeaders_GUI {} {
    #****f* addressHeadersI/eAssistSetup
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2011-2013 Casey Ackels
    #
    # FUNCTION
    #	Batch Addresses - Add/Edit header mappings, to headers that we have in the system already.
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
    global log G_setupFrame currentModule program headerParams headerParent
    global GUI w filters
    #variable GUI
    
    #set currentModule addressHeaders
    eAssist_Global::resetSetupFrames ;# Reset all frames so we start clean
    
    # Initialize the filters array
    eAssist_Global::launchFilters
    
    ##
    ## Parent Frame
    ##

    set w(hdr_frame1) [ttk::frame $G_setupFrame.frame1]
    pack $w(hdr_frame1) -expand yes -fill both -ipadx 5p -ipady 5p
    

    #
    #------- Frame 1a
    #
    set w(hdr_frame1a) [ttk::labelframe $w(hdr_frame1).a -text [mc "Master Header"]]
    pack $w(hdr_frame1a) -expand yes -fill both -ipadx 5p -ipady 5p
    
    tablelist::tablelist $w(hdr_frame1a).listbox -columns {
                                                    0   "..." center
                                                    0  "Header Name"
                                                    0  "Max String Length"
                                                    0  "Output Header"
                                                    0  "Widget"
                                                    0  "Highlight"
													0  "Always Display"
													0  "Required"
                                                    } \
                                        -showlabels yes \
                                        -height 10 \
                                        -selectbackground yellow \
                                        -selectforeground black \
                                        -stripebackground lightblue \
                                        -exportselection yes \
                                        -showseparators yes \
                                        -fullseparators yes \
                                        -movablecolumns yes \
                                        -movablerows yes \
                                        -editselectedonly 1 \
                                        -yscrollcommand [list $w(hdr_frame1a).scrolly set] \
                                        -xscrollcommand [list $w(hdr_frame1a).scrollx set] \
                                        -editstartcommand {eAssistSetup::startCmdHdr} \
                                        -editendcommand {eAssistSetup::endCmdHdr}
    
        $w(hdr_frame1a).listbox columnconfigure 0 -name "count" \
                                            -showlinenumbers 1 \
                                            -labelalign center
    
        $w(hdr_frame1a).listbox columnconfigure 1 -name "HeaderName" \
                                            -editable yes \
                                            -editwindow ttk::entry \
                                            -labelalign center
        
        $w(hdr_frame1a).listbox columnconfigure 2 -name "MaxStringLength" \
                                            -editable yes \
                                            -editwindow ttk::entry \
                                            -labelalign center
        
        $w(hdr_frame1a).listbox columnconfigure 3 -name "OutputHeader" \
                                            -editable yes \
                                            -editwindow ttk::entry \
                                            -labelalign center
        
        $w(hdr_frame1a).listbox columnconfigure 4 -name "Widget" \
                                            -editable yes \
                                            -editwindow ttk::combobox \
                                            -labelalign center
                                            
        $w(hdr_frame1a).listbox columnconfigure 5 -name "Highlight" \
                                            -editable yes \
                                            -editwindow ttk::entry \
                                            -labelalign center
       
	    $w(hdr_frame1a).listbox columnconfigure 6 -name "AlwaysDisplay" \
                                            -editable yes \
                                            -editwindow ttk::combobox \
                                            -labelalign center
		
		$w(hdr_frame1a).listbox columnconfigure 7 -name "Required" \
											-editable yes \
											-editwindow ttk::combobox \
											-labelalign center

        
        
        
    if {[array exists headerParams] == 1} {
        #'debug Populate listbox - data exists
            foreach hdrInfo $headerParent(headerList) {
                #
				if {$hdrInfo eq ""} {continue}
                $w(hdr_frame1a).listbox insert end "{} $hdrInfo $headerParams($hdrInfo)"
            }
    }
        
    #bind [$w(hdr_frame1a).listbox bodytag] <Double-1> {
    #    # Delete the entry
    #    #$w(hdr_frame1a).listbox delete [$w(hdr_frame1a).listbox curselection]
    #}
    
    # Create the row counter and the first line
    set internal(addrHdr,currentRow) 0
    $w(hdr_frame1a).listbox insert end ""
    
    
    ttk::scrollbar $w(hdr_frame1a).scrolly -orient v -command [list $w(hdr_frame1a).listbox yview]
    ttk::scrollbar $w(hdr_frame1a).scrollx -orient h -command [list $w(hdr_frame1a).listbox xview]
    
    grid $w(hdr_frame1a).listbox -column 0 -row 0 -sticky news
    grid columnconfigure $w(hdr_frame1a) $w(hdr_frame1a).listbox -weight 1
    grid rowconfigure $w(hdr_frame1a) $w(hdr_frame1a).listbox -weight 1
    
    grid $w(hdr_frame1a).scrolly -column 1 -row 0 -sticky nse
    grid $w(hdr_frame1a).scrollx -column 0 -row 1 -sticky ews
    
    ::autoscroll::autoscroll $w(hdr_frame1a).scrolly ;# Enable the 'autoscrollbar'
    ::autoscroll::autoscroll $w(hdr_frame1a).scrollx
	
	ttk::button $w(hdr_frame1a).btn1 -text [mc "Add Headers"] -command {eAssistSetup::editHeaders}
	
	grid $w(hdr_frame1a).btn1 -column 0 -row 2 -sticky w

    
    #
    #-------- Frame 1b
    #
    set w(hdr_frame1b) [ttk::labelframe $w(hdr_frame1).b -text [mc "Sub-Headers"]]
    pack $w(hdr_frame1b) -expand yes -fill both -ipadx 5p -ipady 5p
    
    ttk::label $w(hdr_frame1b).label1 -text [mc "Header Name"]

    ttk::combobox $w(hdr_frame1b).cbox1 -width 20 \
                            -state readonly \
                            -textvariable parentHeader \
                            -postcommand {eAssistSetup::populateComboBox}
    
    ttk::entry $w(hdr_frame1b).entry1 -width 20 -textvariable insertChildHeader
    
    ttk::button $w(hdr_frame1b).btn1 -text [mc "Add"] -command {eAssistSetup::addToChildHeader $w(hdr_frame1b).lbox1 $w(hdr_frame1b).entry1 $insertChildHeader $parentHeader}
    ttk::button $w(hdr_frame1b).btn2 -text [mc "Delete"] -command {eAssistSetup::removeHeader child $w(hdr_frame1b).lbox1 $parentHeader}
    
    listbox $w(hdr_frame1b).lbox1 -height 8 -width 20
    
    #-------- Grid Frame 1b
    grid $w(hdr_frame1b).label1 -column 0 -row 0
    grid $w(hdr_frame1b).cbox1 -column 1 -row 0
    
    grid $w(hdr_frame1b).entry1 -column 1 -row 1 -sticky news
    grid $w(hdr_frame1b).btn1 -column 2 -row 1
    
    grid $w(hdr_frame1b).lbox1 -column 1 -row 2 -sticky news
    grid $w(hdr_frame1b).btn2 -column 2 -row 2 -sticky new
    
    #---------- Binding
    bind $w(hdr_frame1b).cbox1 <<ComboboxSelected>> {
        # Display the child headers associated with the parent header
        eAssistSetup::displayHeader $w(hdr_frame1b).lbox1 [$w(hdr_frame1b).cbox1 current] $parentHeader
    }
	
} ;# eAssistSetup::addressHeaders_GUI


proc eAssistSetup::editHeaders {args} {
    #****f* editHeaders/eAssistSetup
    # CREATION DATE
    #   10/21/2014 (Tuesday Oct 21)
    #
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2014 Casey Ackels
    #   
    #
    # SYNOPSIS
    #   eAssistSetup::editHeaders args 
    #
    # FUNCTION
    #	Add/Edit headers
    #   
    #   
    # CHILDREN
    #	N/A
    #   
    # PARENTS
    #   
    #   
    # NOTES
    #   The prefixed number to the entry/combo/check widgets depicts which sequence they are in, within the DB.
    #   
    # SEE ALSO
    #   
    #   
    #***
    global log tmp_headerOpts
	
	set wid .modHeader
	
	if {[winfo exists $wid)] == 1} {destroy $wid}
    
    # .. Create the dialog window
    toplevel $wid
    wm transient $wid .
    wm title $wid [mc "Add/Edit Headers"]

    # Put the window in the center of the parent window
    set locX [expr {[winfo width . ] / 3 + [winfo x .]}]
    set locY [expr {[winfo height . ] / 3 + [winfo y .]}]
    #wm geometry .filterEditor 625x375+${locX}+${locY}
    wm geometry $wid +${locX}+${locY}

	
	## --------
	## General setup
	array set tmp_headerOpts {
		07_ckbtn1 0
		06_ckbtn2 1
		09_ckbtn3 0
	}
	
	
	## ---------
	## Frame 1 / General widgets
	
	set f1 [ttk::labelframe $wid.f1 -text [mc "Header Setup"] -padding 10]
	pack $f1 -padx 2p -pady 2p
	
    ttk::label $f1.txt1 -text [mc "Internal Header"]
	ttk::entry $f1.01_entry1
	
	ttk::label $f1.txt2 -text [mc "Output Header"]
	ttk::entry $f1.03_entry2
	
	ttk::label $f1.txt3 -text [mc "Max Length"]
	ttk::entry $f1.02_entry3 -validate all -validatecommand {eAssist_Global::validate %W %d %S -integer only}
	
	ttk::label $f1.txt4 -text [mc "Column Width"]
	ttk::entry $f1.08_entry4 -validate all -validatecommand {eAssist_Global::validate %W %d %S -integer only}
	
	ttk::label $f1.txt5 -text [mc "Highlight"]
	ttk::combobox $f1.05_cbox1 -values [list "" Red Yellow] -state readonly -width 15
	
	ttk::label $f1.txt6 -text [mc "Widgets"]
	ttk::combobox $f1.04_cbox2 -values [list "" ttk::entry ttk::combobox] -state readonly -width 15
	
	ttk::checkbutton $f1.07_ckbtn1 -text [mc "Required"] -variable tmp_headerOpts(07_ckbtn1)
	ttk::checkbutton $f1.06_ckbtn2 -text [mc "Always Display?"] -variable tmp_headerOpts(06_ckbtn2)
	ttk::checkbutton $f1.09_ckbtn3 -text [mc "Resize to String width"] -variable tmp_headerOpts(09_ckbtn3)
	
	
	
	grid $f1.txt1 -column 0 -row 0 -padx 2p -pady 2p -sticky e
	grid $f1.01_entry1 -column 1 -row 0 -padx 2p -pady 2p -sticky w
	
	grid $f1.txt2 -column 0 -row 1 -padx 2p -pady 2p -sticky e
	grid $f1.03_entry2 -column 1 -row 1 -padx 2p -pady 2p -sticky w
	
	grid $f1.txt3 -column 0 -row 2 -padx 2p -pady 2p -sticky e
	grid $f1.02_entry3 -column 1 -row 2 -padx 2p -pady 2p -sticky w
	
	grid $f1.txt4 -column 0 -row 3 -padx 2p -pady 2p -sticky e
	grid $f1.08_entry4 -column 1 -row 3 -padx 2p -pady 2p -sticky w	
	
	grid $f1.txt5 -column 0 -row 4 -padx 2p -pady 2p -sticky e
	grid $f1.05_cbox1 -column 1 -row 4 -padx 2p -pady 2p -sticky w
	
	grid $f1.txt6 -column 0 -row 5 -padx 2p -pady 2p -sticky e
	grid $f1.04_cbox2 -column 1 -row 5 -padx 2p -pady 2p -sticky w
	
	grid $f1.07_ckbtn1 -column 1 -row 6 -sticky w
	grid $f1.06_ckbtn2 -column 1 -row 7 -sticky w
	grid $f1.09_ckbtn3 -column 1 -row 8 -sticky w
	
	## ---------
	## Buttons
	
	set btns [ttk::frame $wid.btns -padding 10]
	pack $btns -padx 2p -pady 2p -anchor se
	
	ttk::button $btns.cncl -text [mc "Cancel"] -command "destroy $wid"
	ttk::button $btns.save -text [mc "OK"] -command "ea::db::writeHeaderToDB $f1 Headers"
	ttk::button $btns.svnew -text [mc "OK > New"]
	
	grid $btns.cncl -column 0 -row 0 -padx 2p -pady 2p -sticky e
	grid $btns.save -column 1 -row 0 -padx 2p -pady 2p -sticky e
	grid $btns.svnew -column 2 -row 0 -padx 2p -pady 2p -sticky e
	
	## --------
	## Options
	focus $f1.01_entry1

    
} ;# eAssistSetup::editHeaders
