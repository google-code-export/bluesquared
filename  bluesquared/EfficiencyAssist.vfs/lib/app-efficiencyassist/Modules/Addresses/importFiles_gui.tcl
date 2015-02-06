# Creator: Casey Ackels
# Initial Date: March 12, 2011]
# Dependencies: See Below
#-------------------------------------------------------------------------------
#
# Subversion
#
# $Revision: 498 $
# $LastChangedBy: casey.ackels $
# $LastChangedDate$
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

#package provide eAssist_importFiles 1.0
package provide eAssist_ModImportFiles 1.0

namespace eval eAssist_GUI {}
namespace eval importFiles {}
namespace eval IFMenus {} ;# IF = importFiles

proc importFiles::eAssistGUI {} {
    #****f* eAssistGUI/importFiles
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
    #	eAssist::parentGUI
    #
    # NOTES
    #
    #	
    # SEE ALSO
    #	
    #
    #***
    global log program w headerParent files mySettings process dist filter w options csmpls CSR job
    
    # Clear the frames before continuing
    eAssist_Global::resetFrames parent
    
    #wm geometry . 900x610 ;# Width x Height
    
    # Setup the Filter array
    eAssist_Global::launchFilters
    
    # Init vars - these overwrite the old flat file values, with values from the db
    importFiles::initVars
    
    
    ##
    ## Parent Frame
    ##
    set frame0 [ttk::frame .container.frame0]
    pack $frame0 -expand yes -fill both -pady 5p -padx 5p

    ##
    ## Notebook
    ##
    set w(nbk) [ttk::notebook $frame0.nbk]
    pack $w(nbk) -expand yes -fill both

    # Tab setup is in the corresponding proc
    ttk::notebook::enableTraversal $w(nbk)

    #
    # Create the notebook
    #
    #$w(nbk) add [ttk::frame $w(nbk).f1] -text [mc "Import Files"] -state hidden
    #$w(nbk) add [ttk::frame $w(nbk).f2] -text [mc "Process Batch Files"] -state hidden
    $w(nbk) add [ttk::frame $w(nbk).f3] -text [mc "Process Planner Files"]

    $w(nbk) select $w(nbk).f3
    
    ##
    ## - TAB 1
    ##

    
    ##
    ## Notebook 2
    ##
    set nb [ttk::notebook $w(nbk).f3.nb]
    pack $nb -expand yes -fill both

    ttk::notebook::enableTraversal $nb

    #
    # Create the notebook
    #
    $nb add [ttk::frame $nb.f1] -text [mc "Destinations"]
    $nb add [ttk::frame $nb.f2] -text [mc "Samples / Customer Copies"] -state hidden

    
    $nb select $nb.f1
    
    ##
    ##------------- Frame 1 Top Frame - Container
    ##
    set files(tab3f1a) [ttk::frame $nb.f1.f1]
    pack $files(tab3f1a) -side top -fill both ;# -padx 5p -pady 5p
    

    ##
    ##------------- Frame 3a
    ## Container frame
    set files(f3a) [ttk::frame $nb.f1.f1.b]
    pack $files(f3a) -side left -fill both -expand yes ;#-padx 5p -pady 5p
    
    
    ##
    #------------- Frame 2, Tablelist Notebook
    ##
    set files(tab3f2) [ttk::labelframe $nb.f1.f2 -text [mc "Distribution"]]
    pack $files(tab3f2) -side bottom -fill both -expand yes -padx 5p -pady 5p
    
    
    set scrolly $files(tab3f2).scrolly
    set scrollx $files(tab3f2).scrollx
    tablelist::tablelist $files(tab3f2).tbl \
                                    -showlabels yes \
                                    -selectbackground lightblue \
                                    -selectforeground black \
                                    -stripebackground lightyellow \
                                    -exportselection yes \
                                    -showseparators yes \
                                    -fullseparators yes \
                                    -movablecolumns no \
                                    -movablerows no \
                                    -editselectedonly 1 \
                                    -selectmode extended \
                                    -selecttype cell \
                                    -labelcommand tablelist::sortByColumn \
                                    -labelcommand2 tablelist::addToSortColumns \
                                    -editstartcommand {importFiles::startCmd} \
                                    -editendcommand {importFiles::endCmd} \
                                    -yscrollcommand [list $scrolly set] \
                                    -xscrollcommand [list $scrollx set]

    # Create the columns
    importFiles::insertColumns $files(tab3f2).tbl
    
    ttk::scrollbar $scrolly -orient v -command [list $files(tab3f2).tbl yview]
    ttk::scrollbar $scrollx -orient h -command [list $files(tab3f2).tbl xview]
        
    grid $scrolly -column 1 -row 0 -sticky ns
    grid $scrollx -column 0 -row 1 -sticky ew
        
    ::autoscroll::autoscroll $scrolly ;# Enable the 'autoscrollbar'
    ::autoscroll::autoscroll $scrollx ;# Enable the 'autoscrollbar'

    # Setup the bindings
    set bodyTag [$files(tab3f2).tbl bodytag]
    set labelTag [$files(tab3f2).tbl labeltag]
    set editWinTag [$files(tab3f2).tbl editwintag]
    
    # Begin bodyTag
    #bind $bodyTag <<Button3>> +[list tk_popup .tblMenu %X %Y]
    
    # Toggle between selecting a row, or a single cell
    bind $bodyTag <Button-1> {
        #${log}::debug Clicked on column %W %x %y
        #${log}::debug Column Name: [$files(tab3f2).tbl containingcolumn %x]
        set colName [$files(tab3f2).tbl columncget [$files(tab3f2).tbl containingcolumn %x] -name]
        #${log}::debug Column Name: $colName
        
        if {$colName eq "OrderNumber"} {
            $files(tab3f2).tbl configure -selecttype row
        } else {
            $files(tab3f2).tbl configure -selecttype cell
        }
    }
   
    
    bind $bodyTag <Control-v> {
        eAssistHelper::insValuesToTableCells -hotkey $files(tab3f2).tbl [clipboard get] [$files(tab3f2).tbl curcellselection]
        ${log}::debug Pressed <Control-V>
    }
    
    bind $bodyTag <Control-c> {
        IFMenus::copyCell $files(tab3f2).tbl
        ${log}::debug Pressed <Control-C>
    }
    
    # Begin labelTag
    bind $labelTag <Button-3> +[list tk_popup .tblToggleColumns %X %Y]
    #bind $labelTag <Enter> {tooltip::tooltip $labelTag testing}

    #----- GRID
    grid $files(tab3f2).tbl -column 0 -row 0 -sticky news -padx 5p -pady 5p
    grid columnconfigure $files(tab3f2) $files(tab3f2).tbl -weight 2
    grid rowconfigure $files(tab3f2) $files(tab3f2).tbl -weight 2
    
#ttk::style map TEntry -fieldbackground [list focus yellow]
   


} ;# importFiles::eAssistGUI


proc importFiles::initMenu {} {
    #****f* initMenu/importFiles
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2011-2013 Casey Ackels
    #
    # FUNCTION
    #	Initialize menus for the Addresses module
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
    global log mb
    ${log}::debug --START -- [info level 1]
    
    if {[winfo exists $mb.modMenu.quick]} {
        destroy $mb.modMenu.quick
    }

    $mb.modMenu delete 0 end
    $mb.file delete 0 end
    
    # Add Module specific Menus
    menu $mb.file.project
    $mb.file add cascade -label [mc "Project"] -menu $mb.file.project
        $mb.file.project add command -label [mc "New"] -command {customer::projSetup}
        $mb.file.project add command -label [mc "Edit"] -command {customer::projSetup edit}
        $mb.file.project add command -label [mc "View"] -command {customer::projSetup view}
    $mb.file add command -label [mc "Import File"] -command {importFiles::fileImportGUI}
    $mb.file add command -label [mc "Export File"] -command {export::DataToExport} ;#-state disabled
    
    menu $mb.file.reports
    $mb.file add cascade -label [mc "Reports"] -menu $mb.file.reports -state disabled
    $mb.file.reports add command -label [mc "Import Breakdown"]
    
    #$mb.file add command -label [mc "Export File"] -command {export::newDataToExport}
    
    # Change menu name
    #$mb entryconfigure Edit -label Distribution
    # Add cascade
    menu $mb.modMenu.quick
    $mb.modMenu add cascade -label [mc "Quick Add"] -menu $mb.modMenu.quick 
    #$mb.modMenu.quick add command -label [mc "JG Mail"]
    #$mb.modMenu.quick add command -label [mc "JG Inventory"]
    
    $mb.modMenu add separator
    
    $mb.modMenu add command -label [mc "Add Destination"] -command {eAssistHelper::addDestination $files(tab3f2).tbl}
    $mb.modMenu add command -label [mc "Filters..."] -command {eAssist_tools::FilterEditor} -state disable
    #$mb.modMenu add command -label [mc "Internal Samples"] -command {eAssistHelper::addCompanySamples} -state disable
    #$mb.modMenu add command -label [mc "Split"] -command {eAssistHelper::splitVersions}
    $mb.modMenu add command -label [mc "Manage Customers..."] -command {customer::manage}
    
    $mb.modMenu add separator
    
    $mb.modMenu add command -label [mc "Preferences"] -command {eAssistPref::launchPreferences}
	
    ${log}::debug --END -- [info level 1]
} ;# importFiles::initMenu
