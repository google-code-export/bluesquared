# Creator: Casey Ackels
# Initial Date: March 12, 2011]
# File Initial Date: 10 24,2013
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
# Split addresses code

## Coding Conventions
# - Namespaces: Firstword_Secondword

# - Procedures: Proc names should have two words. The first word lowercase the first character of the first word,
#   will be uppercase. I.E sourceFiles, sourceFileExample



proc eAssistHelper::displayVerQty {cVersion} {
    #****f* displayVerQty/eAssistHelper
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2011-2013 Casey Ackels
    #
    # FUNCTION
    #	Display the quantity of the current version
    #
    # SYNOPSIS
    #   eAssistHelper:displayVerQty <textVariable>
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
    global log process files splitVers
    ${log}::debug --START -- [info level 1]
    
    set qty [$files(tab3f2).tbl getcolumn Quantity]
    set vPos [lsearch $process(versionList) $cVersion]    
    set splitVers(totalVersionQty) [lindex $qty $vPos]

    ${log}::debug --END -- [info level 1]
} ;# eAssistHelper::displayVerQty


proc eAssistHelper::splitInsertData {splitTable mainTable} {
    #****f* splitInsertData/eAssistHelper
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2011-2013 Casey Ackels
    #
    # FUNCTION
    #	Insert data into the Split table
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
    global log w files
    ${log}::debug --START -- [info level 1]
    
    set ColumnCount [$files(tab3f2).tbl columncount]
    #set showColumns [list Company Contact Zip Quantity]
    
    $w(sVersf2).tbl insertcolumns end 0 ...
    $w(sVersf2).tbl columnconfigure 0 -name "count" -showlinenumbers 1 -labelalign center
    
    # Insert and configure columns
    set x 0
    for {set y 0} {$ColumnCount > $y} {incr y} {
        incr x
        set ColumnName [$files(tab3f2).tbl columncget $y -name]
        $w(sVersf2).tbl insertcolumns end 0 $ColumnName
        
        # Over ride the defaults, since this is not meant to cleanse the data; but to allocate quantities.
        switch -nocase $ColumnName {
            Company         {set vHide no; set vEditable no; set vWindow ttk::entry}
            Attention       {set vHide no; set vEditable no; set vWindow ttk::entry}
            Zip             {set vHide no; set vEditable no; set vWindow ttk::entry}
            Quantity        {set vHide no; set vEditable yes; set vWindow ttk::entry; set qtyPos1 [expr {$x - 2}]; set qtyPos2 $x}
            distributiontype    {set vHide no; set vEditable yes; set vWindow ttk::combobox}
            default         {set vHide yes; set vEditable no; set vWindow ttk::entry}
        }
        ${log}::debug ColumnName: $ColumnName, hide: $vHide, editable: $vEditable, window: $vWindow
        $w(sVersf2).tbl columnconfigure $x -name $ColumnName -labelalign center -editable $vEditable -hide $vHide -editwindow $vWindow      
    }

    # Insert the data
    set dest [$files(tab3f2).tbl getcolumns Company]
    set zip [$files(tab3f2).tbl getcolumns Zip]

    set process(controlDupes) ""
    set z 0
	# We need to cycle through each contact name (decision on this column was arbitrary)
    # Then we make sure it isn't a contact that we've already come across, if is, then we'll skip it.
    foreach contact [$files(tab3f2).tbl getcolumns Attention] {
        # Dupe control
        set currentEntry [list $contact [lindex $dest $z] [lindex $zip $z]]
        
        # Grab the row and add a space, since the first column is just a count field.
        # using the qtyPos variables, we skip the Quantity column.
        set currentRow1 "{} [$files(tab3f2).tbl getcells $z,0 $z,$qtyPos1] {}"
        set currentRow2 [$files(tab3f2).tbl getcells $z,$qtyPos2 $z,end]
        
        if {[lsearch -nocase $process(controlDupes) $currentEntry] == -1} {
            $w(sVersf2).tbl insert end "$currentRow1 $currentRow2"
        }
        
        lappend process(controlDupes) $currentEntry
        incr z
    }

    ${log}::debug --END -- [info level 1]
} ;# eAssistHelper::splitInsertData


proc eAssistHelper::editStartSplit {tbl row col text} {
    #****f* editStartSplit/eAssistHelper
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2011-2013 Casey Ackels
    #
    # FUNCTION
    #	Start Command for editing the Company Sample table
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
    global log splitVers dist
    ${log}::debug --START-- [info level 1]
        
		set w [$tbl editwinpath]
        set calc no
        switch -glob [string tolower [$tbl columncget $col -name]] {
            "quantity"		{ set splitVers(splitQtyStart) $text; set calc yes
                            ${log}::debug Column Data START: [$tbl getcolumns $col]
                            set colCount [$tbl getcolumns $col]
                            }
            "distributiontype"  {$w configure -values $dist(distributionTypes) -state readonly}
			default	{}
        }
        
    if {[info exists numTotal]} {unset numTotal}
    if {$calc eq "yes"} {
        foreach num $colCount {
            if {$num ne {}} {
                ${log}::debug String should be integer: $num
                lappend numTotal $num
            }
        }
    if {[info exists numTotal]} {
        ${log}::debug total count: $numTotal
        }
    #${log}::debug total count: [expr [join [split $numTotal ""] +]]
    }

    return $text

    ${log}::debug --END-- [info level 1]
} ;# eAssistHelper::editStartSplit


proc eAssistHelper::editEndSplit {tbl row col text} {
    #****f* editEndSplit/eAssistHelper
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2011-2013 Casey Ackels
    #
    # FUNCTION
    #	End Command for editing the Company Sample table
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
    global log splitQty splitVers
    ${log}::debug --START-- [info level 1]
        
	set w [$tbl editwinpath]
    set calc no

    #${log}::debug Column Name: [$tbl columncget $col -name]
    switch -glob [string tolower [$tbl columncget $col -name]] {
            "quantity"		{set calc yes; set splitVers(allocated) [eAssistHelper::calcSamples $splitVers(splitQtyStart) $text $splitVers(allocated)]}
			default	{}
    }
    
    if {$calc ne "no"} { 
        if {$splitVers(unallocated) == ""} {
            set splitVers(unallocated) $splitVers(totalVersionQty)
        }
        set splitVers(unallocated) [expr {$splitVers(totalVersionQty) - $splitVers(allocated)}]
    }
    
    return $text

    ${log}::debug --END-- [info level 1]
} ;# eAssistHelper::editEndSplit