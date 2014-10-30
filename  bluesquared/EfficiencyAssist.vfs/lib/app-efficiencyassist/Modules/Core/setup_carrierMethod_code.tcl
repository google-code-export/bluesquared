# Creator: Casey Ackels
# Initial Date: February 2, 2014]
# File Initial Date: Feb 2,2014
# Dependencies: 
#-------------------------------------------------------------------------------
#
# Subversion
#
# $Revision: 169 $
# $LastChangedBy: casey.ackels $
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

proc eAssistSetup::controlCarrierSetup {{modify add} {entryPath ""} {lboxPath ""} args} {
    #****f* controlCarrierSetup/eAssistSetup
    # CREATION DATE
    #   10/28/2014 (Tuesday Oct 28)
    #
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2014 Casey Ackels
    #   
    #
    # SYNOPSIS
    #   eAssistSetup::controlCarrierSetup <add|delete> <widgetPath> -columnNames <value> -table <value> 
    #
    # FUNCTION
    #	This is a wrapper around a few other procs; that can control/edit the entries in the CarrierSetup window
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
    
    if {$entryPath eq "" || $lboxPath eq ""} {return -errorcode 1 "Must have path to widget"}

    foreach {key value} $args {
        switch -- $key {
            -columnNames    {set cols $value}
            -table          {set dbTable $value}
        }
    }
    
    
    switch -- $modify {
        add     { if {[$entryPath get] eq ""} {return}
                    set data [list [$entryPath get]]; $entryPath delete 0 end
                    #ADD/MODIFY to db
                    ${log}::debug dbInsert -columnNames $cols -table $dbTable -data $data
                    eAssist_db::dbInsert -columnNames $cols -table $dbTable -data $data
        }
        delete  { if {[$lboxPath curselection] eq ""} {return}
                    set data [$lboxPath get [$lboxPath curselection]]
                    #DELETE from DB
                    ${log}::debug delete $dbTable $cols $data
                    eAssist_db::delete $dbTable $cols $data
                }
        query  {}
        default {${log}::debug [info level 1] $modify is unknown}
    }
    



    #READ from DB
    $lboxPath delete 0 end
    ${log}::debug $lboxPath insert end [eAssist_db::dbSelectQuery -columnNames $cols -table $dbTable]
    #$lboxPath insert end [set list [eAssist_db::dbSelectQuery -columnNames $cols -table $dbTable]]
    foreach record [eAssist_db::dbSelectQuery -columnNames $cols -table $dbTable] {
        $lboxPath insert end $record
    }
     

    
} ;# eAssistSetup::controlCarrierSetup


proc eAssistSetup::addCarrierSetup {varType entryField listBox} {
    #****f* addCarrierSetup/eAssistSetup
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2011-2014 Casey Ackels
    #
    # FUNCTION
    #	Add values to listbox
    #	entryField = Path to widget
    #   listBox = Path to widget
    #   Type = what it is, for the switch to work correctly
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
    #   THis could be refactored into [eAssistSetup::addToIntlListbox] and [eAssistSetup::removeFromIntlListbox]
    #
    # SEE ALSO
    #
    #***
    global log carrierSetup
    ${log}::debug --START-- [info level 1]
    
    ${log}::debug Adding $varType, $entryField, $listBox
    
    if {[$entryField get] == ""} {return}

    switch -- $varType {
            PAYMENT     {
                        set entryValue $carrierSetup(enterPaymentType)
                        set newVarType PaymentType
                        ${log}::debug PAYMENT - $entryField
            }
            SHIPMENT    {
                        set entryValue $carrierSetup(enterShipmentType)
                        set newVarType ShipmentType
                        ${log}::debug SHIPMENT - $entryField
            }
            CARRIERS    {
                        set entryValue $carrierSetup(enterCarrier)
                        set newVarType CarrierList
                        ${log}::debug CARRIERS - $entryField
            }
            RATES       {
                        set entryValue $carrierSetup(enterRateType)
                        set newVarType RateType
                        ${log}::debug RATES - $entryField
            }
            SHIPPINGCLASS {
                        set entryValue $carrierSetup(enterShippingClass)
                        set newVarType ShippingClass
                        ${log}::debug SHIPPINGCLASS - $entryField
            }
            default     {
                        ${log}::debug Nothing set for this SWITCH command
            }
    }

    ${log}::debug Adding _ $entryField _ to $newVarType Listbox
    
    $listBox insert end $entryValue
    $entryField delete 0 end
    
    
    
    set carrierSetup($newVarType) [$listBox get 0 end]
    ${log}::debug $newVarType _ADD: [$listBox get 0 end]
    
	
    ${log}::debug --END-- [info level 1]
} ;# eAssistSetup::addCarrierSetup


proc eAssistSetup::delCarrierSetup {varType listBox} {
    #****f* delCarrierSetup/eAssistSetup
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2011-2014 Casey Ackels
    #
    # FUNCTION
    #	Delete selected items from listbox
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
    global log carrierSetup
    ${log}::debug --START-- [info level 1]
    
    if {[$listBox curselection] == ""} {return}   
    
    switch -- $varType {
            PAYMENT     {
                        set newVarType PaymentType
            }
            SHIPMENT    {
                        set newVarType ShipmentType
            }
            CARRIERS    {
                        #set newVarType CarrierList
                        set tbl Carriers
                        set col Name
            }
            RATES       {
                        set newVarType RateType
            }
            SHIPPINGCLASS {
                        set entryValue $carrierSetup(enterShippingClass)
                        set newVarType ShippingClass
                        ${log}::debug SHIPPINGCLASS - $entryField
            }
            default     {
                        ${log}::debug Nothing set for this SWITCH command
            }
    }
    
    # Remove the entry from the DB
    eAssist_db::delete $tbl $col [$listBox curselection]
    
    # ... then remove it from the list box
    $listBox delete [$listBox curselection]
    #set carrierSetup($newVarType) [$listBox get 0 end]
    
	
    ${log}::debug --END-- [info level 1]
} ;# eAssistSetup::delCarrierSetup
