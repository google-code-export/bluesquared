# Creator: Casey Ackels
# Initial Date: March 12, 2011]
# File Initial Date: 09 29,2014
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
# DB Commands for Setup_Countries

## Coding Conventions
# - Namespaces: Firstword_Secondword

# - Procedures: Proc names should have two words. The first word lowercase the first character of the first word,
#   will be uppercase. I.E sourceFiles, sourceFileExample

proc eAssistSetup::placeholder {tbl row col text} {return $text}

proc eAssistSetup::modifyCountry {tbl wid} {
    #****f* modifyCountry/eAssistSetup
    # CREATION DATE
    #   09/29/2014 (Monday Sep 29)
    #
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2014 Casey Ackels
    #   
    #
    # SYNOPSIS
    #   eAssistSetup::addCountry tbl wid
    #
    # FUNCTION
    #	tbl = path to the tablelist widget
    #   wid = path to the entry widgets
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

    ${log}::debug win: $tbl $wid
    
    set children [winfo children $wid]
    if {[winfo exists valuesToInsert]} {unset valuesToInsert}
    
    foreach item $children {
        if {[string match -nocase *entry* $item] == 1} {
            lappend valuesToInsert [$item get]
            
            #... Clear the widgets out
            $item delete 0 end
            #puts $item
        }
    }
    
    ${log}::debug inserting values: $valuesToInsert
    
} ;# eAssistSetup::modifyCountry

proc eAssistSetup::delCountryProv {tbl} {
    #****f* delCountryProv/eAssistSetup
    # CREATION DATE
    #   10/10/2014 (Friday Oct 10)
    #
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2014 Casey Ackels
    #   
    #
    # SYNOPSIS
    #   eAssistSetup::addCountryProv tbl 
    #
    # FUNCTION
    #	Deletes the selected row from the widget, and database
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

    $tbl delete [$tbl curselection]

    ### ADD CODE TO REMOVE FROM DB
    
} ;# eAssistSetup::delCountryProv

proc eAssistSetup::editTblEntry {tbl wid} {
    #****f* editTblEntry/eAssistSetup
    # CREATION DATE
    #   10/11/2014 (Saturday Oct 11)
    #
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2014 Casey Ackels
    #   
    #
    # SYNOPSIS
    #   eAssistSetup::editTblEntry tbl wid 
    #
    # FUNCTION
    #	Gets the selected values, and populates the entry widgets that exist in the passed frame
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

    set data [$tbl get [$tbl curselection]]
    
    set children [winfo children $wid]
    if {[winfo exists widgets]} {unset widgets}
    
    foreach item $children {
        if {[string match -nocase *entry* $item] == 1} {
            lappend widgets $item
        }
    }
    
    set x 1 ;# Using 1 because we don't want to insert the numeric into the entry widgets.
    foreach wid $widgets {
        ${log}::debug $wid insert end [lrange $data $x $x]
        $wid delete 0 end
        $wid insert end [join [lrange $data $x $x]]
        incr x
    }

    
} ;# eAssistSetup::editTblEntry


proc eAssistSetup::getCountries {win} {
    #****f* getCountries/eAssistSetup
    # CREATION DATE
    #   10/10/2014 (Friday Oct 10)
    #
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2014 Casey Ackels
    #   
    #
    # SYNOPSIS
    #   eAssistSetup::getCountries win 
    #
    # FUNCTION
    #	Retrieves the list of country names in the database
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

    $win.cbx1 configure -values [eAssist_db::dbSelectQuery -columnNames CountryName -table Countries]

    
} ;# eAssistSetup::getCountries


proc eAssistSetup::countryEditEnd {tbl row col text} {
    #****f* countryEditEnd/eAssistSetup
    # CREATION DATE
    #   09/29/2014 (Monday Sep 29)
    #
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2014 Casey Ackels
    #   
    #
    # SYNOPSIS
    #   eAssistSetup::countryEditEnd args 
    #
    # FUNCTION
    #	What does it do?
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
    
    set win [$tbl editwinpath]
    ${log}::debug Tbl: $tbl Row: $row Col: $col Text: $text
    ${log}::debug win: $win
    

    #$w(hdr_frame1a).listbox
    
    switch -- [$tbl columncget $col -name] {
        CountryCode { if {[string length $text] ne 2} {
                            return -code 1 [mc "Two character code only!\nYou entered: $text"]
                            #break
                        } else {
                            set newTxt $text
                        }
        }
        CountryName { foreach val $text {
                        lappend newTxt [string totitle $val]
                    }
        }
        default     {}
    }
    
    $tbl cellconfigure $row,$col -text $newTxt

    ${log}::debug dbInsert [lrange [$tbl get $row] 1 end]
    eAssistSetup::dbInsertCountry [lrange [$tbl get $row] 1 end]
    return $newTxt
} ;# eAssistSetup::countryEditEnd


proc eAssistSetup::dbInsertCountry {args} {
    #****f* dbInsertCountry/eAssistSetup
    # CREATION DATE
    #   09/29/2014 (Monday Sep 29)
    #
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2014 Casey Ackels
    #   
    #
    # SYNOPSIS
    #   eAssistSetup::dbInsert args 
    #
    # FUNCTION
    #	Inserts data into specified table and column
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
    set args [join $args]
    set cCode [lrange $args 0 0]
    set cName [lrange $args 1 end]

    set dbCheck [eAssist_db::dbWhereQuery -columnNames "CountryCode CountryName" -table Countries -where CountryCode='$cCode']
    set myWhere "WHERE CountryCode = '$cCode'"
    
    if {$dbCheck == 0} {
        # Didn't find the CountryCode in the DB, lets see if we can find the CountryName. The user may have modified the country name.
        set dbCheck [eAssist_db::dbWhereQuery -columnNames "CountryCode CountryName" -table Countries -where CountryName='$cName']
        set myWhere "WHERE CountryName = '$cName'"
        #${log}::debug Found the CountryName: $dbCheck
    }
    
    if {$dbCheck eq ""} {
        # INSERT
        db eval "INSERT or ABORT INTO Countries (CountryCode, CountryName) VALUES ('$cCode', '$cName')"
    } else {
        # UPDATE
        db eval "UPDATE Countries SET CountryCode = '$cCode', CountryName = '$cName' $myWhere"
    }

} ;# eAssistSetup::dbInsertCountry


proc eAssistSetup::dbGetProvinces {win country} {
    #****f* dbGetProvinces/eAssistSetup
    # CREATION DATE
    #   09/29/2014 (Monday Sep 29)
    #
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2014 Casey Ackels
    #   
    #
    # SYNOPSIS
    #   eAssistSetup::dbGetProvinces win country
    #
    # FUNCTION
    #	Retrieves the list of provinces already entered into the DB
    #	win - province table
    #   country - widget path to retrieve the country name
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
    global log program
    
    $win delete 0 end
    
    set cName [$country get]
    set program(db,currentCountryCode)  [db eval "SELECT CountryCode FROM Countries WHERE CountryName='$cName'"]
    
    ${log}::debug country code: $program(db,currentCountryCode)
    ${log}::debug win: $win

    db eval "SELECT ProvAbbr,
                    ProvName,
                    PostalCodeLowEnd,
                    PostalCodeHighEnd
             FROM Provinces
                INNER JOIN Countries
                    ON Countries.Country_ID = Provinces.CountryID
                    WHERE Countries.CountryCode = '$program(db,currentCountryCode)'" {
                        $win insert end [list {} $ProvAbbr $ProvName $PostalCodeHighEnd $PostalCodeLowEnd]
                        ${log}::debug PROVINCES: [list {} $ProvAbbr $ProvName $PostalCodeHighEnd $PostalCodeLowEnd]
                    }

    
} ;# eAssistSetup::dbGetProvinces




proc eAssistSetup::provinceEditEnd {tbl row col text} {
    #****f* provinceEditEnd/eAssistSetup
    # CREATION DATE
    #   09/30/2014 (Tuesday Sep 30)
    #
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2014 Casey Ackels
    #   
    #
    # SYNOPSIS
    #   eAssistSetup::provinceEditEndCmd args 
    #
    # FUNCTION
    #	What does it do?
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

    set win [$tbl editwinpath]
    ${log}::debug Tbl: $tbl Row: $row Col: $col Text: $text
    ${log}::debug win: $win

    
    switch -- [$tbl columncget $col -name] {
        ProvAbbr { if {[string length $text] ne 2} {
                            return -code 1 [mc "Two character code only!\nYou entered: $text"]
                            #break
                        } else {
                            set newTxt [string toupper $text]
                            set table Provinces
                        }
        }
        ProvName { foreach val $text {
                        lappend newTxt [string totitle $val]
                    }
                    set table Provinces
                }
        PostalCodeLowEnd    {set newTxt $text; set table PostalCodes }
        PostalCodeHighEnd   {set newTxt $text; set table PostalCodes }
        default     {}
    }
    
    #$tbl cellconfigure $row,$col -text $newTxt

    ${log}::debug dbInsertProv $tbl get
    #eAssistSetup::dbInsertProv [lrange [$tbl get $row] 1 end]
    return $newTxt

} ;# eAssistSetup::provinceEditEnd


proc eAssistSetup::dbInsertProv {args} {
    #****f* dbInsertProv/eAssistSetup
    # CREATION DATE
    #   09/30/2014 (Tuesday Sep 30)
    #
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2014 Casey Ackels
    #   
    #
    # SYNOPSIS
    #   eAssistSetup::dbInsertProv args 
    #
    # FUNCTION
    #	Inserts/Updates Province entries
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
    global log program

    set data [$args get 0 end]
    # This should return the db ID for the current country
    set countryID [db eval "SELECT Country_ID FROM Countries WHERE CountryCode='$program(db,currentCountryCode)'"]
    
    foreach entry $data {
        set pAbbr [join [lrange $entry 1 1]]
        set pName [join [lrange $entry 2 2]]
        set pCodeHi [join [lrange $entry 3 3]]
        set pCodeLo [join [lrange $entry 4 4]]
        
        if {$pAbbr eq {}} {${log}::debug Not inserting into db, no abbreviation yet; break}
        if {$pName eq {}} {${log}::debug Not inserting into db, no province name yet; break}
        
        ${log}::debug $pAbbr $pName $pCodeHi $pCodeLo
    }
    



    
    #${log}::debug countryID: $countryID

    # Match Country and Province Abbreviation
    #set dbCheck [eAssist_db::dbWhereQuery -columnNames "ProvAbbr ProvName" -table Provinces -where "CountryID='$countryID' AND ProvAbbr='$pAbbr'"]
    #set myWhere "CountryID='$countryID' AND ProvAbbr='$pAbbr'"
    #set myProv "ProvName = '$pName'"
    #
    #if {$dbCheck == 0} {
    #    ${log}::debug Didn't match province abbreviation, trying province name
    #    # Didn't find the Province Abbreviation in the DB, lets see if we can find the Province Name. The user may have modified the abbreviation.
    #    set dbCheck [eAssist_db::dbWhereQuery -columnNames "ProvAbbr ProvName" -table Provinces -where "CountryID='$countryID' AND ProvName='$pName'"]
    #    set myWhere "CountryID='$countryID' AND ProvName='$pName'"
    #    set myProv "ProvAbbr = '$pAbbr'"
    #    #${log}::debug Found the CountryName: $dbCheck
    #}
    #
    #${log}::debug CountryID: $countryID
    #${log}::debug dbCheck: $dbCheck
    #
    #if {$dbCheck == ""} {
    #    # INSERT
    #    ${log}::debug Inserting into db ... $args
    #    db eval "INSERT or ABORT INTO Provinces (ProvAbbr, ProvName, PostalCodeLowEnd, PostalCodeHighEnd, CountryID)
    #        VALUES ('$pAbbr', '$pName', '$pCodeLo', '$pCodeHi', '$countryID')"
    #} else {
    #    # UPDATE
    #    ${log}::debug UPDATEing into db ... $args
    #    ${log}::debug Elements - myProv: $myProv
    #    ${log}::debug Elements - LowEnd: $pCodeLo
    #    ${log}::debug Elements - HighEnd: $pCodeHi
    #    ${log}::debug Elements - CountryID: $countryID
    #    #db eval "UPDATE Countries SET CountryCode = '$cCode', CountryName = '$cName' $myWhere"
    #    db eval "UPDATE Provinces SET $myProv,
    #                                    PostalCodeLowEnd = '$pCodeLo',
    #                                    PostalCodeHighEnd = '$pCodeHi'
    #                            WHERE $myWhere"
    #}

    
}
#
#proc eAssistSetup::dbInsertProv {args} {
#    #****f* dbInsertProv/eAssistSetup
#    # CREATION DATE
#    #   09/30/2014 (Tuesday Sep 30)
#    #
#    # AUTHOR
#    #	Casey Ackels
#    #
#    # COPYRIGHT
#    #	(c) 2014 Casey Ackels
#    #   
#    #
#    # SYNOPSIS
#    #   eAssistSetup::dbInsertProv args 
#    #
#    # FUNCTION
#    #	Inserts/Updates Province entries
#    #   
#    #   
#    # CHILDREN
#    #	N/A
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
#    global log program
#
#    set args [join $args]
#    
#    ${log}::debug Prov Args: $args
#    ${log}::debug ProvName: [lrange $args 1 1]
#
#    set pAbbr [join [lrange $args 0 0]]
#    set pName [join [lrange $args 1 1]]
#    set pCodeHi [join [lrange $args 2 2]]
#    set pCodeLo [join [lrange $args 3 3]]
#    
#    if {$pAbbr eq {}} {${log}::debug Not inserting into db, no abbreviation yet; return}
#    if {$pName eq {}} {${log}::debug Not inserting into db, no province name yet; return}
#
#    # This should return the db ID for the current country
#    set countryID [db eval "SELECT Country_ID FROM Countries WHERE CountryCode='$program(db,currentCountryCode)'"]
#    #${log}::debug countryID: $countryID
#
#    # Match Country and Province Abbreviation
#    set dbCheck [eAssist_db::dbWhereQuery -columnNames "ProvAbbr ProvName" -table Provinces -where "CountryID='$countryID' AND ProvAbbr='$pAbbr'"]
#    set myWhere "CountryID='$countryID' AND ProvAbbr='$pAbbr'"
#    set myProv "ProvName = '$pName'"
#    
#    if {$dbCheck == 0} {
#        ${log}::debug Didn't match province abbreviation, trying province name
#        # Didn't find the Province Abbreviation in the DB, lets see if we can find the Province Name. The user may have modified the abbreviation.
#        set dbCheck [eAssist_db::dbWhereQuery -columnNames "ProvAbbr ProvName" -table Provinces -where "CountryID='$countryID' AND ProvName='$pName'"]
#        set myWhere "CountryID='$countryID' AND ProvName='$pName'"
#        set myProv "ProvAbbr = '$pAbbr'"
#        #${log}::debug Found the CountryName: $dbCheck
#    }
#    
#    ${log}::debug CountryID: $countryID
#    ${log}::debug dbCheck: $dbCheck
#    
#    if {$dbCheck == ""} {
#        # INSERT
#        ${log}::debug Inserting into db ... $args
#        db eval "INSERT or ABORT INTO Provinces (ProvAbbr, ProvName, PostalCodeLowEnd, PostalCodeHighEnd, CountryID)
#            VALUES ('$pAbbr', '$pName', '$pCodeLo', '$pCodeHi', '$countryID')"
#    } else {
#        # UPDATE
#        ${log}::debug UPDATEing into db ... $args
#        ${log}::debug Elements - myProv: $myProv
#        ${log}::debug Elements - LowEnd: $pCodeLo
#        ${log}::debug Elements - HighEnd: $pCodeHi
#        ${log}::debug Elements - CountryID: $countryID
#        #db eval "UPDATE Countries SET CountryCode = '$cCode', CountryName = '$cName' $myWhere"
#        db eval "UPDATE Provinces SET $myProv,
#                                        PostalCodeLowEnd = '$pCodeLo',
#                                        PostalCodeHighEnd = '$pCodeHi'
#                                WHERE $myWhere"
#    }
#
#    
#}