# Creator: Casey Ackels
# Initial Date: March 12, 2011]
# File Initial Date: 01 06,2015
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
# Code for the Customer namespace

## Coding Conventions
# - Namespaces: Firstword_Secondword

# - Procedures: Proc names should have two words. The first word lowercase the first character of the first word,
#   will be uppercase. I.E sourceFiles, sourceFileExample


proc customer::PopulateShipVia {lbox {custID 0}} {
    #****f* PopulateShipVia/customer
    # CREATION DATE
    #   01/06/2015 (Tuesday Jan 06)
    #
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2015 Casey Ackels
    #   
    #
    # SYNOPSIS
    #   customer::PopulateShipVia <lbox> ?custID? 
    #
    # FUNCTION
    #	Retrieves and displays the ship via codes in the available listbox. If custID is provided, it populates the assigned ship via listbox
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

    ${log}::debug Loading the shipvia's into $lbox
    if {$custID == 0} {
        set shipViaList [lsort [eAssist_db::dbSelectQuery -columnNames ShipViaName -table ShipVia]]
        foreach shipvia $shipViaList {
            $lbox insert end $shipvia
        }
    } elseif { $custID != ""} {
        set preferredShipVia [db eval "SELECT ShipVia.ShipViaName
                                                FROM CustomerShipVia
                                                     INNER JOIN
                                                     ShipVia ON ShipVia.ShipVia_ID = CustomerShipVia.ShipViaID
                                                     WHERE CustomerShipVia.custID = '$custID'"]
        foreach pShipVia $preferredShipVia {
            $lbox insert end $pShipVia
        }
        
    }
} ;# customer::PopulateShipVia

proc customer::transferToAssigned {lboxFrom lboxTo okBtn} {
    #****f* transferToAssigned/customer
    # CREATION DATE
    #   01/07/2015 (Wednesday Jan 07)
    #
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2015 Casey Ackels
    #   
    #
    # SYNOPSIS
    #   customer::transferToAssigned lboxFrom lboxTo
    #
    # FUNCTION
    #	Transfer's the selected entries from the Available Ship Via lbox, to the Assigned Ship Via lbox
    #	Guards against duplicates, by using [lsort -unique]. Removes all data from the widget, and reinserts upon adding new ship via's.
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
    
    set selectedShipVia [$lboxFrom curselection] ;# this is only the index of the selections
    
    set assignedShipVia [$lboxTo get 0 end]
    
    # Compile list for selected ship via's
    if {[info exists selectedShipViaList]} {unset selectedShipViaList}
    foreach index $selectedShipVia {
        lappend selectedShipViaList [$lboxFrom get $index]
    }

    # Bypass the combining of lists if the second list is empty
    if {$assignedShipVia ne {} } {
        #${log}::debug Concating ...
        set selectedShipViaList [concat $selectedShipViaList $assignedShipVia]
    }
    
    # Only keep the unique entries
    set selectedShipViaList [lsort -unique $selectedShipViaList]

    $lboxTo delete 0 end
    
    # Insert
    foreach item $selectedShipViaList {
        $lboxTo insert end $item
    }

    
    
} ;# customer::transferToAssigned

proc customer::removeFromAssigned {lbox okBtn} {
    #****f* removeFromAssigned/customer
    # CREATION DATE
    #   01/07/2015 (Wednesday Jan 07)
    #
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2015 Casey Ackels
    #   
    #
    # SYNOPSIS
    #   customer::removeFromAssigned lbox 
    #
    # FUNCTION
    #	Removes the selected Ship Via's from the Assigned lbox
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

    # Sort it from large to small, this way we can delete them in the loop properly.
    set selectedShipVia [lsort -decreasing [$lbox curselection]]
    
    foreach item $selectedShipVia {
        #Add item to list, so we can remove it from the DB. This is initiated in the first startup of the customer window.
        lappend ::customer::shipViaDeleteList [$lbox get $item]
    
        ${log}::debug Removed Selected ShipVia: [$lbox get $item]
        $lbox delete $item
        

    }
   
} ;# customer::removeFromAssigned


proc customer::populateCustomerLbox {lbox} {
    #****f* populateCustomerLbox/customer
    # CREATION DATE
    #   01/07/2015 (Wednesday Jan 07)
    #
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2015 Casey Ackels
    #   
    #
    # SYNOPSIS
    #   customer::populateCustomerLbox lbox 
    #
    # FUNCTION
    #	Lists the customers that are loaded in the DB
    #   
    #   
    # CHILDREN
    #	N/A
    #   
    # PARENTS
    #   
    #   
    # NOTES
    #   Currently we only show ACTIVE records.
    #   
    # SEE ALSO
    #   
    #   
    #***
    global log

    set getCustomerList [db eval "SELECT Cust_ID, CustName FROM Customer WHERE Status='1'"]
    
    foreach {id name} $getCustomerList {
        $lbox insert end "$id [list $name]"
        #${log}::debug id: $id cust: $name
    }

    
} ;# customer::populateCustomerLbox

proc customer::deleteFromlbox {lbox custID} {
    #****f* deleteFromlbox/customer
    # CREATION DATE
    #   01/08/2015 (Thursday Jan 08)
    #
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2015 Casey Ackels
    #   
    #
    # SYNOPSIS
    #   customer::deleteFromlbox lbox 
    #
    # FUNCTION
    #	Deletes the currently selected customer in the lbox, and refreshes the data from the DB
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
    
    set selData [$lbox get [$lbox curselection]]
    set csrFname [lrange [join [lrange $selData 1 1]] 0 0]
    set csrLname [lrange [join [lrange $selData 1 1]] 1 1]
    set title [lrange [$lbox get [$lbox curselection]] 2 2]
    set CSRid [db eval "SELECT CSR_ID from CSRs where FirstName='$csrFname' and LastName='$csrLname'"]

    
    set rowID [eAssist_db::getRowID PubTitle "CUSTID='$custID' AND CSRID='$CSRid' AND TitleName='$title'"]
    eAssist_db::delete PubTitle "" $rowID

} ;# customer::deleteFromlbox


proc customer::dbAddShipVia {lbox custIDwid custNamewid} {
    #****f* dbAddShipVia/customer
    # CREATION DATE
    #   01/13/2015 (Tuesday Jan 13)
    #
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2015 Casey Ackels
    #   
    #
    # SYNOPSIS
    #   customer::dbAddShipVia lbox 
    #
    # FUNCTION
    #	Adds the selected shipvias from the listbox, and inserts/updates them in the DB
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
    global log cust tmp

    set custID [$custIDwid get]
    set custName [list [$custNamewid get]]
    set shipViaList [$lbox get 0 end]
    
    ${log}::debug CustID: $custID
    ${log}::debug CustName: $custName
    ${log}::debug CustStatus: $cust(Status)
    #${log}::debug DATA: $shipViaList
    
    ## Check if the customer exists; if they don't lets add them.
    set tmp(db,rowID) [eAssist_db::getRowID Customer Cust_ID='$custID']
    eAssist_db::dbInsert -columnNames "Cust_ID CustName Status" -table Customer -data "$custID $custName $cust(Status)"
    
    # Remove ShipVia from DB
    if {[info exists ::customer::shipViaDeleteList]} {
        # Find out if these shipvia's exist in the DB associated with this custmer ID, if it does lets remove them from the DB if not, continue the loop.
        foreach shipName [lsort -unique $::customer::shipViaDeleteList] {
            #${log}::debug _DELETE_: [lsort -unique $::customer::shipViaDeleteList]
            # Grab the db ID since all we have is the Name
            set shipID [eAssist_db::dbWhereQuery -columnNames ShipVia_ID -table ShipVia -where "ShipViaName='$shipName'"]
            
            #if {$shipID != "" && $custID != ""} {}
            # Make sure the shipID and custID exist
            if {[eAssist_db::dbWhereQuery -columnNames ShipViaID -table CustomerShipVia -where "ShipViaID='$shipID' AND CustID='$custID'"] != ""} {
                #eAssist_db::delete CustomerShipVia ShipViaID
                db eval "DELETE from CustomerShipVia WHERE ShipViaID = '$shipID' AND CustID = '$custID'"
            }
        }
        # Unset var, so we don't unintentionally try to delete shipvia's that don't exist.
        #unset ::customer::shipViaDeleteList
    }
    
    # Skip if we don't have any shipvia changes
    if {$shipViaList != ""} {
        # Match the ShipVia's to their db ID's
        if {[info exists shipviaIDs]} {unset shipviaIDs}
        foreach item [lsort -unique $shipViaList] {
            ${log}::debug GET ID: [eAssist_db::dbWhereQuery -columnNames ShipVia_ID -table ShipVia -where "ShipViaName='$item'"]
            lappend shipviaIDs [eAssist_db::dbWhereQuery -columnNames ShipVia_ID -table ShipVia -where "ShipViaName='$item'"]
        }
        
        # Insert the ShipVia's
        foreach id $shipviaIDs {
           ${log}::debug INSERT: $custID _ $id
           #eAssist_db::dbInsert -columnNames "CustID ShipViaId" -table CustomerShipVia -data "$custID $id"
           db eval "INSERT OR ABORT INTO CustomerShipVia (CustID, ShipViaID) VALUES ('$custID', '$id')"
        }
    }
   

    
} ;# customer::dbAddShipVia

proc customer::validateEntry {okBtn addBtn remBtn wid entryValue} {
    #****f* validateEntry/customer
    # CREATION DATE
    #   01/13/2015 (Tuesday Jan 13)
    #
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2015 Casey Ackels
    #   
    #
    # SYNOPSIS
    #   customer::validateEntry okBtn wid entryValue 
    #
    # FUNCTION
    #	Ensures that we have some data in the widget; if we don't the OK button stays disabled. If we do, then we enable the OK button.
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

    ${log}::debug ENTRY: $wid
    #set entryValue [join [concat $entryValuePre $entryValuePost] ""]
    #${log}::debug Value: $entryValue
    ${log}::debug VALUE: $entryValue

    if {[string length $entryValue] >= 3} {
        #${log}::debug Button State Normal - Value: $entryValue
        $okBtn configure -state normal
        $addBtn configure -state normal
        $remBtn configure -state normal
    } else {
        #${log}::debug Button State Disable
        $okBtn configure -state disable
        $addBtn configure -state disable
        $remBtn configure -state disable
    }
    
    
    return 1
    
} ;# customer::validateEntry

proc customer::validateCustomer {type wid} {
    #****f* validateCustomer/customer
    # CREATION DATE
    #   01/27/2015 (Tuesday Jan 27)
    #
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2015 Casey Ackels
    #   
    #
    # SYNOPSIS
    #   customer::validateCustomer entryWid cboxWid 
    #
    # FUNCTION
    #	Looks for matches and populates both customer id widget, and customer name combobox
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

    set custIDList [db eval "SELECT Cust_ID FROM Customer WHERE Status='1'"]
    set custNameList [db eval "SELECT CustName FROM Customer WHERE Status='1'"]
    
    
    switch -- $type {
        id      {return $custIDList}
        name    {return $custNameList}
    }
} ;# customer::validateCustomer

proc customer::returnTitle {custID} {
    #****f* returnTitle/customer
    # CREATION DATE
    #   01/27/2015 (Tuesday Jan 27)
    #
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2015 Casey Ackels
    #   
    #
    # SYNOPSIS
    #   customer::returnTitle custID 
    #
    # FUNCTION
    #	Returns the list of titles associated with the customer id
    #   
    #   
    # CHILDREN
    #	N/A
    #   
    # PARENTS
    #   
    #   
    # NOTES
    #   Hardcoded to only show entries with a status of 1 (active)!
    #   
    # SEE ALSO
    #   
    #   
    #***
    global log

    set titleList [db eval "SElECT TitleName FROM PubTitle WHERE CustID='$custID' AND Status='1'"]
    #${log}::debug Title List: $titleList

    return $titleList
} ;# customer::returnTitle


proc customer::populateTitleWid {tbl custID} {
    #****f* populateTitleWid/customer
    # CREATION DATE
    #   01/28/2015 (Wednesday Jan 28)
    #
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2015 Casey Ackels
    #   
    #
    # SYNOPSIS
    #   customer::populateTitleWid tbl custID
    #
    # FUNCTION
    #	Populates the Title table with the CSR name and titles associated to the currently selected customer
    #   
    #   
    # CHILDREN
    #	N/A
    #   
    # PARENTS
    #   
    #   
    # NOTES
    #   Status is hardcoded to show only active records!
    #   
    # SEE ALSO
    #   
    #   
    #***
    global log

    # Make sure the table is cleared
    $tbl delete 0 end
    
    foreach title [db eval "SELECT TitleName FROM PubTitle WHERE CustID = '$custID'"] {
        set getCSRname [db eval "SELECT FirstName,
                            LastName
                       FROM CSRs
                            INNER JOIN
                            PubTitle ON PubTitle.CSRID = CSRs.CSR_ID
                      WHERE PubTitle.CustID = '$custID'
                      AND PubTitle.TitleName = '$title'
                      AND PubTitle.Status = '1'"]
        
        $tbl insert end [list "" $getCSRname $title]
    }
    
    
} ;# customer::populateTitleWid


proc customer::dbUpdateCustomer {} {
    #****f* dbUpdateCustomer/customer
    # CREATION DATE
    #   01/28/2015 (Wednesday Jan 28)
    #
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2015 Casey Ackels
    #   
    #
    # SYNOPSIS
    #   customer::dbUpdateCustomer 
    #
    # FUNCTION
    #	Inserts or Updates the Customer ID, Customer Name, Title and CSR (associated with the Title)
    #   
    #   
    # CHILDREN
    #	N/A
    #   
    # PARENTS
    #   
    #   
    # NOTES
    #   DB Tables: Customer, PubTitle
    #   
    # SEE ALSO
    #   
    #   
    #***
    global log job tmp
    
    set csrList [db eval "SELECT CSR_ID, FirstName, LastName FROM CSRs"]
    
    foreach {id fname lname} $csrList {
        #${log}::debug $id $fname $lname
        if {[join [list $fname $lname] " "] eq "$job(CSRName)"} {set csrID $id}
    }

    #${log}::debug id: $job(CustID)
    #${log}::debug custName: $job(CustName)
    #${log}::debug title: $job(Title)
    #${log}::debug csrID: $csrID
    # Insert the customer, default status of '1'; so its active.
    set tmp(db,rowID) [eAssist_db::getRowID Customer Cust_ID='$job(CustID)']
    eAssist_db::dbInsert -columnNames {Cust_ID CustName Status} -table Customer -data [list $job(CustID) $job(CustName) 1]
    
    # Insert the title, default status of '1'; so its active.
    set tmp(db,rowID) [eAssist_db::getRowID PubTitle TitleName='$job(Title)' AND CustID='$job(CustID)']
    eAssist_db::dbInsert -columnNames {TitleName CustID CSRID Status} -table PubTitle -data [list $job(Title) $job(CustID) $csrID 1]

    
} ;# customer::dbUpdateCustomer
