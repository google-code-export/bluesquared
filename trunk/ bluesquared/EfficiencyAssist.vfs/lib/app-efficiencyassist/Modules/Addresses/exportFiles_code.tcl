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
    
    #set mySettings(job,fileName) "%number %title %name"
    
    if {[info exists mySettings(job,fileName)] != 1} {
        # Set the default format for the file name.
        set mySettings(job,fileName) "%number %title %name"
    }
    
    foreach val [list Title Name Number] {
        if {![info exists job($val)]} {
            ${log}::debug Aborting... job($val) doesn't exist. Please fill in the $val field.
                set answer [tk_messageBox -message "Please put in a Job $val" \
                        -icon question -type yesno \
                        -detail "Select \"Yes\" to open the Project Setup window."]
                switch -- $answer {
                        yes {eAssistHelper::projSetup}
                        no {exit}
                }
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
    
    ${log}::debug myFile(data): $myFile(data)
    
    if {$myFile(data) eq {}} {
        ${log}::notice Aborting... The Save As window was closed without a file name.
        #${log}::debug ERROR: $err
        return
    } else {
        #set fd [catch {[open $myFile(data) w]} err]
        if {[file exists $myFile(data)] && ![file writable $myFile(data)]} {
            tk_messageBox -message "The file is open in another program, please close before exporting." \
                            -icon warning -type ok \
                            -detail "$myFile(data)"
            return
        } else {
            set fd [open $myFile(data) w]
        }
        ${log}::debug fd: $fd
    }

    
        
    # HEADER: Write output
    # OrderType is a hardcoded value, this should be moved to a user option.
    #   OrderType is the Column name, Version is the value.
    if {[info exists colNames]} {unset colNames}
    set colCount [$files(tab3f2).tbl columncount]
    for {set x 0} {$colCount > $x} {incr x} {
        set tblName [$files(tab3f2).tbl columncget $x -name]
        if {$tblName eq "ShipVia"} {set shipViaIDX $x; ${log}::debug shipViaIDX: $shipViaIDX}
        # Just in case the header doesn't exist in the db; but we have it in the tablelist...
        set outputColNames [db eval "SELECT OutputHeaderName FROM Headers where InternalHeaderName='$tblName'"]
        
        if {$outputColNames eq ""} {
            lappend colNames [$files(tab3f2).tbl columncget $x -name]
        } else {
            lappend colNames [db eval "SELECT OutputHeaderName FROM Headers where InternalHeaderName='$tblName'"]
        }
    }
    chan puts $fd [::csv::join "$colNames OrderType"]
    ${log}::debug HEADER: [::csv::join "$colNames OrderType"]
    ${log}::debug ROWS:

    set rowCount [$files(tab3f2).tbl size]
    for {set x 0} {$rowCount > $x} {incr x} {
        # RECORDS: Write output one row at a time.
        set record [$files(tab3f2).tbl get $x]
        set shipViaName [lindex $record $shipViaIDX] ; ${log}::debug shipViaName: $shipViaName
        # The apostrophe is so we can open the file up in Excel without the leading zero disappearing. (It formats the cell for TEXT instead of INTEGER)
        set record [lreplace $record $shipViaIDX $shipViaIDX '[db eval "SELECT ShipViaCode FROM ShipVia where ShipViaName='$shipViaName'"]]
        # Version is a hardcoded value, this should be a header option, with a drop down in the spreadsheet
        ${log}::debug [::csv::join "$record Version"]
        chan puts $fd [::csv::join "$record Version"]
    }
    
	chan close $fd
    #${log}::debug --END-- [info level 1]
} ;# export::DataToExport
        