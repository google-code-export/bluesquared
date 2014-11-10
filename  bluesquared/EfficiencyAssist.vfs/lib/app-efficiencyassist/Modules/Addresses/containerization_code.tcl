# Creator: Casey Ackels
# Initial Date: March 12, 2011]
# Dependencies: See Below
#-------------------------------------------------------------------------------
#
# Subversion
#
# $Revision: 498 $
# $LastChangedBy: casey.ackels $
# $LastChangedDate: 2014-11-03 14:57:54 -0800 (Mon, 03 Nov 2014) $
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

namespace eval cont {
    set pkg(ctn,width) 8.5
    set pkg(ctn,height) 9
    set pkg(ctn,length) 11
    
    # Set the standard for Stitched books
    # 24 (pages), 32 (soft weight), 9 (soft height), 35 (hard weight), 9 (hard height), .10 (fluff, percentage)
    set std(stitched,24pg) [list 24 32 9 35 9 .10]
    set cont(divisible) [list 3 4 5]
}

# cont::maxByWeight .203 .128 $std(stitched,24pg)

proc cont::maxByWeight {pcwt pcht std} {
    #****f* maxByWeight/cont
    # CREATION DATE
    #   11/09/2014 (Sunday Nov 09)
    #
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2014 Casey Ackels
    #   
    #
    # SYNOPSIS
    #   cont::maxByWeight  
    #
    # FUNCTION
    #	Returns max by weight
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
    global log cont
    # Setup basic info
    #set std(stitched,24pg) [list 24 32 9 35 9 .10]
    #set cont(divisible) [list 3 4 5]
    
    ${log}::debug standard: $std
    ${log}::debug pieceWt: $pcwt
    
    
    set softWt [lindex $std 1]
    ${log}::debug Soft Wt: $softWt
    
    # (soft weight) / (piece weight)
    set maxpcs [expr {$softWt / $pcwt}]
    ${log}::debug Max Pcs: $maxpcs
    
    # round, and append a decimal so we receive floating numbers in later calculations ...
    set maxpcs [tcl::mathfunc::round $maxpcs].
    ${log}::debug maxpcs (whole): $maxpcs
    
    #${log}::debug Divisible? [cont::divisible $maxpcs]
    #while {[cont::divisible $maxpcs] == 0} {
    #    # Reduce the count by one, and rerun the divisible proc
    #    set maxpcs [expr $maxpcs - 1]
    #    ${log}::debug maxpcs (incr): $maxpcs
    #}
    
    set totalpcht [cont::maxByHeight $pcht $std]
    
    ${log}::debug FINAL PCHT: [lindex $totalpcht 0]
    ${log}::debug Final Total Height: [lindex $totalpcht 1]
    
    ${log}::debug FINAL PCWT: $maxpcs
    ${log}::debug Final total Weight: [expr {$maxpcs * $pcwt}]
    
    
} ;# cont::maxByWeight


proc cont::maxByHeight {pcht std} {
    #****f* maxByHeight/cont
    # CREATION DATE
    #   11/09/2014 (Sunday Nov 09)
    #
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2014 Casey Ackels
    #   
    #
    # SYNOPSIS
    #   cont::maxByHeight pcht std 
    #
    # FUNCTION
    #	Returns max by height
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
    global log
   
    ${log}::debug standard: $std
    ${log}::debug pieceHt: $pcht
    set fluff [lindex $std 5]
    ${log}::debug Fluff (%): $fluff
    
    set pcht_fluff [expr {$pcht + ($pcht * $fluff)}]
    ${log}::debug pieceHt with Fluff: $pcht_fluff
    
    
    set softHt [lindex $std 2]
    ${log}::debug Soft Ht: $softHt
    
    # (soft weight) / (piece weight)
    set maxpcs [expr {$softHt / $pcht_fluff}]
    ${log}::debug Max Pcs: $maxpcs
    
    # round, and append a decimal so we receive floating numbers in later calculations ...
    set maxpcs [tcl::mathfunc::round $maxpcs].
    ${log}::debug maxpcs (whole): $maxpcs
    
    #${log}::debug Divisible? [cont::divisible $maxpcs]
    while {[cont::divisible $maxpcs] == 0} {
        # Reduce the count by one, and rerun the divisible proc
        set maxpcs [expr $maxpcs - 1]
        ${log}::debug maxpcs (incr): $maxpcs
    }
    
    #${log}::debug FINAL PCHT: $maxpcs
    #${log}::debug Final Total Height: [expr {$maxpcs * $pcht_fluff}]
    return "$maxpcs [expr {$maxpcs * $pcht_fluff}]"
} ;# cont::maxByHeight


proc cont::divisible {maxpcs} {
    global cont log
    
    set divisibleNum 0
    # Divisible?
    foreach item $cont(divisible) {
        #${log}::debug Divisible by $item: [expr {$maxpcs / $item}]
        if {[isWholeNumber [expr {$maxpcs / $item}]]} {
            ${log}::debug YES - Divisible by $item: [expr {$maxpcs / $item}]
            set divisibleNum [expr {$maxpcs / $item}]
            return $divisibleNum
        }
    }
    return $divisibleNum
}


proc isWholeNumber { float } {
   return [expr abs($float - int($float)) > 0 ? 0 : 1]
}