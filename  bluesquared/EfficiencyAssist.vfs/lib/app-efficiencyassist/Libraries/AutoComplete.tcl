# Creator: Casey Ackels
# Initial Date: March 12, 2011]
# File Initial Date: 09 23,2014
# Dependencies: 
#-------------------------------------------------------------------------------
#
# Subversion
#
# $Revision$
# $LastChangedBy: casey.ackels $
# $LastChangedDate$
#
########################################################################################

##
## - Overview
# Auto-Complete package found on wiki.tcl.tk

namespace eval AutoComplete {}

#proc AutoComplete::ToTitle {win action validation value valuelist} {
#    #****f* ToTitle/AutoComplete
#    # CREATION DATE
#    #   10/11/2014 (Saturday Oct 11)
#    #
#    # AUTHOR
#    #	Casey Ackels
#    #
#    # COPYRIGHT
#    #	(c) 2014 Casey Ackels
#    #   
#    #
#    # SYNOPSIS
#    #   AutoComplete::ToTitle win action validation value valuelist 
#    #
#    # FUNCTION
#    #	Returns the data in a ToTitle fashion; this is a wrapper around AutoComplete::AutoComplete
#    #   
#    #   
#    # CHILDREN
#    #	AutoComplete::AutoComplete
#    #   
#    # PARENTS
#    #   
#    #   
#    # NOTES
#    #   
#    #   
#    # SEE ALSO
#    #   
#    #   
#    #***
#    global log
#    #set value ""
#    #set newVal ""
#    #if {[info exists newVal]} {unset newVal}
#
#    if {[llength $value] == 1} {
#        set value [string totitle $value]
#    } else {
#        foreach val $value {
#            lappend newVal [string totitle $val]
#        }
#        #set value $newVal
#    }
#    
#    ${log}::debug ToTitle: $value
#    #return [lsort -dict [eAssist_db::dbSelectQuery -columnNames ProvName -table Provinces]]
#    AutoComplete::AutoComplete $win $action $validation $value $valuelist
#} ;# AutoComplete::ToTitle


proc AutoComplete::AutoComplete {win action validation value valuelist {capitalize 1}} {
    #****f* AutoComplete/AutoComplete
    # CREATION DATE
    #   09/23/2014 (Tuesday Sep 23)
    #
    # AUTHOR
    #	Andrew Black
    #   
    #
    # SYNOPSIS
    #   AutoComplete::AutoComplete %W %d %v %P <list to search on> ?upper|title?
    #
    # FUNCTION
    #	use autocomplete in the validate command of an entry box as follows
    #	-validatecommand {autocomplete %W %d %v %P $list}
    #	where list is a tcl list of values to complete the entry with
    #   
    #   
    # CHILDREN
    #	N/A
    #   
    # PARENTS
    #   
    #   
    # NOTES
    #   Found on http://wiki.tcl.tk/13267
    #   
    # SEE ALSO
    #   
    #   
    #***
    global log
    
    if {[info exists newVal]} {unset newVal}
    switch -- [string tolower $capitalize] {
        upper   {${log}::debug To Upper
                    set newVal [string toupper $value]
                    ${log}::debug To Upper: $value
                }
        title   {${log}::debug To Title
                    foreach val $value {
                        lappend newVal [string totitle $val]
                    }
                
                ${log}::debug To Title: $value
                }
        default {${log}::debug default}
    }

    
    if {$action == 1 & $value != {} & [set pop [lsearch -nocase -inline $valuelist $value*]] != {}} {
         $win delete 0 end;  $win insert end $pop
         $win selection range [string length $value] end
         $win icursor [string length $value]
    } elseif {$action == -1} {
        # insert the correct capitalized version if we don't have a match
        if {![info exists newVal]} {return 1}
        $win delete 0 end; $win insert end $newVal
   } else {
        $win selection clear
   }
   
   after idle [list $win configure -validate $validation]
   return 1
    
} ;# AutoComplete::AutoComplete

###
### -- This is useful if we want to search on ShipViaCode, and return the name of the carrier.
###
#proc AutoComplete::AutoCompleteShipVia {win action validation value} {
#if {[string is digit $value]} {
#    puts "digits..."
#    # Look at the ShipViaCode table, and return the carrier name
#    # Valuelist = db query for shipviacodes; value = what we're typing
#    set valuelist [db eval {SELECT ShipViaCode FROM ShipVia}]
#    #puts "valuelist: $valuelist"
#    set pop [lsearch -nocase -inline $valuelist $value*]
#    #puts "pop: $pop"
#        if {$pop ne ""} {
#            set dbQuery [db eval {SELECT Name FROM ShipVia 
#                        INNER JOIN Carriers
#                            ON Carriers.Carrier_ID = ShipVia.CarrierID
#                        WHERE ShipViaCode = $pop}]
#        }
#        #puts "dbQuery: $dbQuery"
#    } else {
#    # The user is typing letters ...
#    # valuelist = dbquery for carrier names
#    puts "letters..."
#    set valuelist [db eval {SELECT Name FROM Carriers}]
#        #puts "valuelist: valuelist"
#        set dbQuery [lsearch -nocase -inline $valuelist $value*]
#        #puts "dbQuery: $dbQuery"
#    }
#    
#    if {$action == 1 & $value != {} & $dbQuery != {}} {
#         $win delete 0 end;  $win insert end [join $dbQuery]
#         $win selection range [string length $value] end
#         $win icursor [string length $value]
#    } else {
#        $win selection clear
#   }
#   
#   after idle [list $win configure -validate $validation]
#   return 1
#}