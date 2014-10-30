# Creator: Casey Ackels
# Initial Date: March 12, 2011]
# File Initial Date: 01 12,2014
# Dependencies: 
#-------------------------------------------------------------------------------
#
# Subversion
#
# $Revision: 479 $
# $LastChangedBy: casey.ackels@gmail.com $
# $LastChangedDate$
#
########################################################################################

namespace eval export {}

proc export::DataToExport {} {
    #****f* DataToExport/export
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2011-2014 Casey Ackels
    #
    # FUNCTION
    #	Gather, and assemble the data to export. For Distribution.
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
    global log headerParent files mySettings job
    #${log}::debug --START-- [info level 1]
    
    
    if {[info exists mySettings(job,fileName)] != 1} {
        ${log}::debug Job number is not filled in!
        return
    }
    
    foreach val [list Number Name Title] {
        if {![info exists job($val)]} {
            ${log}::debug Aborting... job($val) doesn't exist. Please fill in the $val field.
            return
            }
    }
    
    ${log}::notice Default file name: $mySettings(job,fileName)

    set fileName $mySettings(job,fileName)
    foreach item {Title Name Number} {
        set item2 [string tolower $item]
        #puts [string map [list %$item2 $job($item)] $mySettings(job,fileName)]
        set fileName [string map [list %$item2 $job($item)] $fileName]
    }

	set fileName [join $fileName]
	
	${log}::debug Actual file name: $fileName

    # don't open the file yet, because we may have canceled the Save As dialog...
    set myFile(data) [file join [eAssist_Global::SaveFile $fileName]]
    
    if {$myFile(data) eq {}} {
        ${log}::notice Aborting... The Save As window was closed without a file name.
        #${log}::debug ERROR: $err
        return
    } else {
        # open the file
        set myFile(data) [open $myFile(data) w]
    }
    
        
    # HEADER: Write output
    # OrderType is a hardcoded value, this should be moved to a user option.
    #   OrderType is the Column name, Version is the value.
    #chan puts $myFile(data) [::csv::join "OrderNumber $headerParent(outPutHeader) OrderType"]
    #${log}::debug [::csv::join "OrderNumber $headerParent(outPutHeader) OrderType"]
    if {[info exists colNames]} {unset colNames}
    set colCount [$files(tab3f2).tbl columncount]
    for {set x 0} {$colCount > $x} {incr x} {
        #lappend colNames [$files(tab3f2).tbl columncget $x -name]
        lappend colNames [db eval "SELECT OutputHeaderName FROM Headers where InternalHeaderName='[$files(tab3f2).tbl columncget $x -name]'"]
    }
    chan puts $myFile(data) [::csv::join "$colNames OrderType"]
    ${log}::debug HEADER: [::csv::join "$colNames OrderType"]
    ${log}::debug ROWS:

    set rowCount [$files(tab3f2).tbl size]
    for {set x 0} {$rowCount > $x} {incr x} {
        # RECORDS: Write output one row at a time.
        # Version is a hardcoded value, this should be moved to a user option.
        ${log}::debug [::csv::join "[$files(tab3f2).tbl get $x] Version"]
        chan puts $myFile(data) [::csv::join "[$files(tab3f2).tbl get $x] Version"]
    }
    
	chan close $myFile(data)
    #${log}::debug --END-- [info level 1]
} ;# export::DataToExport
