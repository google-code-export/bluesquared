# Initial Date: November 26, 2011]
# Dependencies: See Below
#-------------------------------------------------------------------------------
#
# Subversion
#
# $Revision: 157 $
# $LastChangedBy: casey.ackels $
# $LastChangedDate: 2011-10-03 14:41:48 -0700 (Mon, 03 Oct 2011) $
#
########################################################################################

# Definitions for prefixes of Variables
# G = Global
# S = String
# L = List
# I = Integer (Do not use this unless you are certain it is an Integer and not a plain string)

## Coding Conventions
# - Namespaces:

# - Procedures: Proc names should have two words. The first word lowercase the first character of the first word,
#   will be uppercase. I.E sourceFiles, sourceFileExample


proc nextgenrm_GUI::addEditWindow {} {
    #****f* addEditWindow/nextgenrm_GUI
    # AUTHOR
    #	Picklejuice
    #
    # COPYRIGHT
    #	(c) 2011 - Picklejuice
    #
    # FUNCTION
    #	Gateway to the main profile window, here we see the profiles that we already have, and are able to add/edit or delete them.
    #
    # SYNOPSIS
    #	N/A
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
    
    # Make sure the window has been destroyed before creating.
    if {[winfo exists .add]} {destroy .add}
        
     
##
## Window Manager
##
    
    toplevel .add
    wm title .add [mc "Add/Edit Profile"]
    wm transient .add .
    focus -force .add

    # x = horizontal
    # y = vertical
    # Put the window in the center of the parent window
    set locX [expr {[winfo width . ] / 4 + [winfo x .]}]
    set locY [expr {[winfo height . ] / 4 + [winfo y .]}]

    wm geometry .add +$locX+$locY
    
##
## Frames
##
    
    set frame1 [ttk::frame .add.frame1]
    pack $frame1 -fill both -expand yes -pady 5p
    
    listbox $frame1.lbox
    ttk::button $frame1.add -text [mc "Add"] -command {nextgenrm_GUI::profile; destroy .add}
    ttk::button $frame1.edit -text [mc "Edit"]
    ttk::button $frame1.del -text [mc "Delete"]
    
    grid $frame1.lbox -column 0 -row 0 -rowspan 15 -sticky news -padx 5p -pady 5p
    
    grid $frame1.add -column 1 -row 0 -sticky new -padx 5p -pady 3p
    grid $frame1.edit -column 1 -row 1 -sticky new -padx 5p -pady 3p
    grid $frame1.del -column 1 -row 2 -sticky new -padx 5p -pady 3p
    
    
# Separator Frame
    set sep_frame1 [ttk::frame .add.sep_frame1]
    ttk::separator $sep_frame1.separator -orient horizontal

    grid $sep_frame1.separator - -ipadx 1i
    pack $sep_frame1
    
# Button frame
    set button_frame [ttk::frame .add.button]
    pack $button_frame -side right
    
    ttk::button $button_frame.close -text [mc "Close"] -command {destroy .add}
    grid $button_frame.close -column 0 -row 0 -padx 5p -pady 5p
    
} ;# End nextgenrm_GUI::addEditWindow


proc nextgenrm_GUI::profile {} {
    #****f* profile/nextgenrm_GUI
    # AUTHOR
    #	Picklejuice
    #
    # COPYRIGHT
    #	(c) 2011 - Picklejuice
    #
    # FUNCTION
    #	Create the Profile window
    #
    # SYNOPSIS
    #	N/A
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
    global profile
    
    # Make sure the window has been destroyed before creating.
    if {[winfo exists .profile]} {destroy .profile}
    
##
## Window Manager
##
    
    toplevel .profile
    wm title .profile [mc "Store Profile"]
    wm transient .profile .
    focus -force .profile

    # x = horizontal
    # y = vertical
    # Put the window in the center of the parent window
    set locX [expr {[winfo width . ] / 4 + [winfo x .]}]
    set locY [expr {[winfo height . ] / 4 + [winfo y .]}]

    wm geometry .profile +$locX+$locY
    
    
##
## Container
##

    set container [ttk::frame .profile.container]
    pack $container -expand yes -fill both
    
##
## Frame 1
##
    
    set frame1 [ttk::frame $container.frame1]
    pack $frame1 -expand yes -fill both -pady 5p
    
    set profile(store) newStore
    ttk::label $frame1.profileTxt -text [mc "Profile Name"]
    ttk::entry $frame1.profileEnt -textvariable profile(store)

    
    grid $frame1.profileTxt -column 0 -row 0 -padx 3p -pady 2p
    grid $frame1.profileEnt -column 1 -row 0 -padx 2p -pady 2p
    
#
# Separator Frame
#
    set sep_frame1 [ttk::frame $container.sep_frame1]
    ttk::separator $sep_frame1.separator -orient horizontal
    
    grid $sep_frame1.separator - -ipadx 1.5i
    pack $sep_frame1 -pady 5p
    
##
## Notebook
##
    set nb [ttk::notebook $container.nb]
    pack $nb -expand yes -fill both -padx 5p -pady 5p
    
    $nb add [ttk::frame $nb.f1] -text [mc "Header"]
    $nb add [ttk::frame $nb.f2] -text [mc "Miscellaneous"]
    $nb select $nb.f1
    
    ttk::notebook::enableTraversal $nb
    
    
#
# Tab 1 - Header
#
    # Container for tab3
    set tab1 [ttk::frame $nb.f1.frame1]
    pack $tab1 -expand yes -fill both -padx 5p -pady 5p

    
    # container for listbox
    set pcl [ttk::frame $tab1.listbox]
    pack $pcl -expand yes -fill both
    
    set scrolly $pcl.scrolly
    tablelist::tablelist $pcl.listbox \
                -columns {0  "Header Text"     
                        10    "Position"  center
                        10    "Size"    center
                        10   "Spacing"   center } \
                -showlabels yes \
                -stretch 0 \
                -height 10 \
                -selectbackground yellow \
                -selectforeground black \
                -stripebackground lightblue \
                -exportselection yes \
                -showseparators yes \
                -fullseparators yes \
                -editstartcommand nextgenrm_GUI::startCmdHeader \
                -editendcommand nextgenrm_GUI::endCmdHeader \
                -yscrollcommand [list $scrolly set]
        
        $pcl.listbox columnconfigure 0 -name htext \
                                            -editable yes \
                                            -labelalign center \
                                            -editwindow ttk::entry
        
        $pcl.listbox columnconfigure 1 -name position \
                                            -editable yes \
                                            -editwindow ttk::combobox
        
        $pcl.listbox columnconfigure 2 -name size \
                                            -editable yes \
                                            -editwindow ttk::combobox
        
        $pcl.listbox columnconfigure 3 -name spacing \
                                            -editable yes \
                                            -editwindow ttk::combobox
        
        # Create the first line
        $pcl.listbox insert end ""
        
        ttk::scrollbar $scrolly -orient v -command [list $pcl.listbox yview]
        
        grid $pcl.listbox -column 0 -row 0 -sticky news
        grid $scrolly -column 1 -row 0 -sticky ns
    
        # This is needed so the scrollbar displays properly
        grid columnconfigure    $pcl 0 -weight 1
        grid rowconfigure       $pcl 0 -weight 1
        
        ::autoscroll::autoscroll $scrolly ;# Enable the 'autoscrollbar'


 # Separator Frame

    set sep_frame2 [ttk::frame $container.sep_frame2]
    ttk::separator $sep_frame2.separator -orient horizontal
    
    grid $sep_frame2.separator - -ipadx 1.5i
    pack $sep_frame2 -pady 2p

#    
# Button frame
#
    set button_frame [ttk::frame $container.button]
    pack $button_frame -side right
    
    ttk::button $button_frame.close -text [mc "Close"] -command {destroy .profile}
    grid $button_frame.close -column 0 -row 0 -padx 5p -pady 5p


#
# Tab 2 - Misc
#

    set tab2 [ttk::frame $nb.f2.frame1]
    pack $tab2 -expand yes -fill both -padx 5p -pady 5p
    
    ttk::label $tab2.printText -text [mc "Body Text Size"]
    ttk::combobox $tab2.printCombo -width 10 \
                                    -values "Large Medium Small" \
                                    -state readonly \
                                    -textvariable profile($profile(store),bodySize)
    
    grid $tab2.printText -column 0 -row 0 -sticky e -padx 3p -pady 2p
    grid $tab2.printCombo -column 1 -row 0 -sticky news -padx 2p -pady 2p
    
    ttk::label $tab2.dataText -text [mc "Date"]
    ttk::combobox $tab2.dataCombo1 -width 10 \
                                    -values "Top Bottom" \
                                    -state readonly \
                                    -textvariable profile($profile(store),date_pos1)
    ttk::combobox $tab2.dataCombo2 -width 10 \
                                    -values "Left Center Right" \
                                    -state readonly \
                                    -textvariable profile($profile(store),date_pos2)
    ttk::combobox $tab2.dataCombo3 -width 10 \
                                    -values "Large Medium Small" \
                                    -state readonly \
                                    -textvariable profile($profile(store),date_size)
    
    grid $tab2.dataText -column 0 -row 1 -padx 3p -pady 2p -sticky e
    grid $tab2.dataCombo1 -column 1 -row 1 -padx 2p -pady 2p -sticky news
    grid $tab2.dataCombo2 -column 2 -row 1 -padx 2p -pady 2p -sticky news
    grid $tab2.dataCombo3 -column 3 -row 1 -padx 2p -pady 2p -sticky news
    
    ttk::label $tab2.taxFoodTxt -text [mc "Tax (Food)"] 
    ttk::entry $tab2.taxFoodEnt -width 3 -textvariable profile($profile(store),taxFood)
    ttk::label $tab2.taxFoodPct -text %
    
    grid $tab2.taxFoodTxt -column 0 -row 2 -padx 3p -pady 2p -sticky e
    grid $tab2.taxFoodEnt -column 1 -row 2 -padx 2p -pady 2p -sticky news
    grid $tab2.taxFoodPct -column 2 -row 2 -pady 2p -sticky w
    
    ttk::label $tab2.taxOtherTxt -text [mc "Tax (Other)"]
    ttk::entry $tab2.taxOtherEnt -width 3 -textvariable profile($profile(store),taxOther)
    ttk::label $tab2.taxOtherPct -text %
    
    grid $tab2.taxOtherTxt -column 0 -row 3 -padx 3p -pady 2p -sticky e
    grid $tab2.taxOtherEnt -column 1 -row 3 -padx 2p -pady 2p -sticky news
    grid $tab2.taxOtherPct -column 2 -row 3 -pady 2p -sticky w

} ;# End nextgenrm_GUI::profile


proc nextgenrm_GUI::startCmdHeader {tbl row col text} { 
    #****f* startCmd/nextgenrm_GUI
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2011 - Casey Ackels
    #
    # FUNCTION
    #	Configuration options when the user enters the listbox
    #
    # SYNOPSIS
    #	N/A
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
    global profile
    
        set w [$tbl editwinpath]
        
        #'debug index: [$w index bottom]
        
        switch -- [$tbl columncget $col -name] {
            htext {
                $w configure -textvariable profile($profile(store),$row,htext)
            }
            position {
                    # Populate and make it readonly, and insert another line.
                    $w configure -values {"Left" "Center" "Right"} \
                                -state readonly \
                                -textvariable profile($profile(store),$row,hpos)

            }
            size {
                # Populate and make it readonly, and insert another line.
                $w configure -values {"Large" "Medium" "Small"} \
                            -state readonly \
                            -textvariable profile($profile(store),$row,hsize)
            }
            spacing {
                # Populate and make it readonly, and insert another line.
                $w configure -values {"Single" "Double"} \
                            -state readonly \
                            -textvariable profile($profile(store),$row,hspacing)
                
                set myRow [expr {[$tbl index end] - 1}]
                if {$row == 0} {$tbl insert end ""; 'debug Inserting 2nd Row}
                # See tablelist help for using 'end' as an index point.
                if {($row != 0) && ($row == $myRow)} {$tbl insert end ""; 'debug Inserting Row}
            }
            default {}
        }
        
        #'debug Text: $text
        return $text
}


proc nextgenrm_GUI::endCmdHeader {tbl row col text} { 
    #****f* endCmd/nextgenrm_GUI
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2011 - Casey Ackels
    #
    # FUNCTION
    #	Configuration options when the user leaves the listbox
    #
    # SYNOPSIS
    #	N/A
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
    global profile
   
    set w [$tbl editwinpath]
    
    switch -- [$tbl columncget $col -name] {
        htext {
            'debug htext: $profile($profile(store),$row,htext)
        }
        position {
            'debug pos: $profile($profile(store),$row,hpos)
        }
        size {
            'debug size: $profile($profile(store),$row,hsize)
        }
        spacing {
            'debug spacing: $profile($profile(store),$row,hspacing)
        }
        default {}
    }
    return $text
    
}