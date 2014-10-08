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

proc eAssistSetup::modifyCountry {win control} {
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
    #   eAssistSetup::addCountry win -del|-add
    #
    # FUNCTION
    #	Deletes the currently selected row, and removes it.
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

    ${log}::debug win: $win $control
    
    switch -- $control {
        -add    {$win insert end ""; focus $win}
        -del    {$win delete [$win curselection]}
    }


    
} ;# eAssistSetup::modifyCountry


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


proc eAssistSetup::dbGetProvinces {win winCountry} {
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
    #   eAssistSetup::dbGetProvinces win 
    #
    # FUNCTION
    #	Retrieves the list of provinces already entered into the DB
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
    
    set program(db,currentCountryCode) [lrange [$winCountry get [$winCountry curselection]] 1 1]
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
                        }
        }
        ProvName { foreach val $text {
                        lappend newTxt [string totitle $val]
                    }
                }
        PostalCodeLowEnd    {set newTxt $text }
        PostalCodeHighEnd   {set newTxt $text}
        default     {}
    }
    
    $tbl cellconfigure $row,$col -text $newTxt

    ${log}::debug dbInsertProv [lrange [$tbl get $row] 1 end]
    eAssistSetup::dbInsertProv [lrange [$tbl get $row] 1 end]
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

    set args [join $args]
    
    ${log}::debug Prov Args: $args
    ${log}::debug ProvName: [lrange $args 1 1]

    set pAbbr [lrange $args 0 0]
    set pName [lrange $args 1 1]
    set pCodeHi [lrange $args 2 2]
    set pCodeLo [lrange $args 3 3]
    
    if {$pAbbr eq {}} {${log}::debug Not inserting into db, no abbreviation yet; return}
    if {$pName eq {}} {${log}::debug Not inserting into db, no province name yet; return}

    # This should return the db ID for the current country
    set countryID [db eval "SELECT Country_ID FROM Countries WHERE CountryCode='$program(db,currentCountryCode)'"]
    #${log}::debug countryID: $countryID

    # Match Country and Province Abbreviation
    set dbCheck [eAssist_db::dbWhereQuery -columnNames "ProvAbbr ProvName" -table Provinces -where "CountryID='$countryID' AND ProvAbbr='$pAbbr'"]
    set myWhere "CountryID='$countryID' AND ProvAbbr='$pAbbr'"
    set myProv "ProvName = '$pName'"
    
    if {$dbCheck == 0} {
        ${log}::debug Didn't match province abbreviation, trying province name
        # Didn't find the Province Abbreviation in the DB, lets see if we can find the Province Name. The user may have modified the abbreviation.
        set dbCheck [eAssist_db::dbWhereQuery -columnNames "ProvAbbr ProvName" -table Provinces -where "CountryID='$countryID' AND ProvName='$pName'"]
        set myWhere "CountryID='$countryID' AND ProvName='$pName'"
        set myProv "ProvAbbr = '$pAbbr'"
        #${log}::debug Found the CountryName: $dbCheck
    }
    
    ${log}::debug CountryID: $countryID
    ${log}::debug dbCheck: $dbCheck
    
    if {$dbCheck == ""} {
        # INSERT
        #db eval "INSERT or ABORT INTO Countries (CountryCode, CountryName) VALUES ('$cCode', '$cName')"
        ${log}::debug Inserting into db ... $args
        db eval "INSERT or ABORT INTO Provinces (ProvAbbr, ProvName, PostalCodeLowEnd, PostalCodeHighEnd, CountryID)
            VALUES ('$pAbbr', '$pName', '$pCodeLo', '$pCodeHi', '$countryID')"
    } else {
        # UPDATE
        ${log}::debug UPDATEing into db ... $args
        ${log}::debug Elements - myProv: $myProv
        ${log}::debug Elements - LowEnd: $pCodeLo
        ${log}::debug Elements - HighEnd: $pCodeHi
        ${log}::debug Elements - CountryID: $countryID
        #db eval "UPDATE Countries SET CountryCode = '$cCode', CountryName = '$cName' $myWhere"
        db eval "UPDATE Provinces SET $myProv,
                                        PostalCodeLowEnd = '$pCodeLo',
                                        PostalCodeHighEnd = '$pCodeHi'
                                WHERE $myWhere"
    }

    
} ;# eAssistSetup::dbInsertProv
