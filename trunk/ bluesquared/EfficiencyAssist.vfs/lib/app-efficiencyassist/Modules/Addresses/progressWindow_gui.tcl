# Creator: Casey Ackels
# Initial Date: July 10th, 2011
# Dependencies: progressWindow_code.tcl
#-------------------------------------------------------------------------------
#
# Subversion
#
# $Revision: 168 $
# $LastChangedBy: casey.ackels $
# $LastChangedDate: 2011-10-17 06:31:45 -0700 (Mon, 17 Oct 2011) $
#
########################################################################################

##
## - Overview
# This file holds the code for the About window package

# Definitions for prefixes of Variables
# G = Global
# S = String
# L = List
# I = Integer (Do not use this unless you are certain it is an Integer and not a plain string)

## Coding Conventions
# - Namespaces:

# - Procedures: Proc names should have two words. The first word lowercase the first character of the first word,
#   will be uppercase. I.E sourceFiles, sourceFileExample


proc eAssist_GUI::progressWindow {} {
    #****f* progressWindow/eAssist_GUI
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2011 - Casey Ackels
    #
    # FUNCTION
    #	eAssist_GUI::progressWindow
    #
    # SYNOPSIS
    #	Calling this command brings up the progress window, and starts processing the file
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
    global GL_file program intl
    destroy .progress

    toplevel .progress
    wm title .progress [mc "Processing File"]
    wm transient .progress .

    focus .progress

    # Put the window in the center of the parent window
    set locX [expr {[winfo width . ] / 3 + [winfo x .]}]
    set locY [expr {[winfo height . ] / 3 + [winfo y .]}]
    wm geometry .progress +${locX}+${locY}

    # Reset variables
    set program(ProgressBar) 0
    set program(totalAddress) 0
    set program(totalBoxes) 0
    set program(totalBooks) 0
    set program(totalAddress) 0
    set program(fileComplete) "In Progress.."
    set program(maxAddress) [llength $GL_file(dataList_modified)]

    ##
    ## Parent Frame
    ##
    set container [ttk::labelframe .progress.container -text [mc "File Progress"]]
    pack $container -expand yes -fill both -pady 5p -padx 5p

    set frame1 [ttk::frame $container.frame1]
    pack $frame1 -expand yes -fill both -pady 5p -padx 5p

    #ttk::progressbar $frame1.bar -length [llength $GL_file(dataList)]
    ttk::progressbar $frame1.bar -mode determinate -variable program(ProgressBar) -maximum $program(maxAddress)
    pack $frame1.bar -fill x -expand 1 -padx 4p -pady 10p
    
    ttk::label $frame1.notice -text [mc "PLEASE ENSURE THAT ALL PRIORITY MAIL HAS THE CORRECT PACKAGE TYPE"]
    pack $frame1.notice
    
    ttk::label $frame1.progress -textvariable program(fileComplete)
    pack $frame1.progress


    set frame2 [ttk::frame $container.frame2]
    pack $frame2 -expand yes -fill both -pady 5p -padx 5p
    
    ttk::label $frame2.txt1a -text [mc "Addresses"]
    ttk::label $frame2.txt1b -textvariable program(totalAddress)

    ttk::label $frame2.txt2a -text [mc "Boxes"]
    ttk::label $frame2.txt2b -textvariable program(totalBoxes)

    ttk::label $frame2.txt3a -text [mc "Books"]
    ttk::label $frame2.txt3b -textvariable program(totalBooks)
    
    ttk::label $frame2.txt4a -text [mc "File"]
    ttk::label $frame2.txt4b -textvariable program(fileComplete)
    
    grid $frame2.txt1a -column 0 -row 1 -sticky nse -padx 4p
    grid $frame2.txt1b -column 1 -row 1 -sticky nsw

    grid $frame2.txt2a -column 0 -row 2 -sticky nse -padx 4p
    grid $frame2.txt2b -column 1 -row 2 -sticky nsw

    grid $frame2.txt3a -column 0 -row 3 -sticky nse -padx 4p
    grid $frame2.txt3b -column 1 -row 3 -sticky nsw
    
    #grid $frame2.txt4a -column 0 -row 2 -sticky nse -padx 4p
    #grid $frame2.txt4b -column 1 -row 2 -sticky nsw


    set btnbar [ttk::frame .progress.btnbar]
    pack $btnbar -padx 4p -pady 10p -side right

    ttk::button $btnbar.close -text [mc "Close"] -command {eAssist_Helper::resetVars -resetGUI; destroy .progress}

    grid $btnbar.close -column 0 -row 0 -sticky nse

    eAssist_Code::writeOutPut
}
