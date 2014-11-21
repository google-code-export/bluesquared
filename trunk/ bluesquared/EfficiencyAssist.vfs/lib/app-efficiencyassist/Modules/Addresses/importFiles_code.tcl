# Creator: Casey Ackels
# Initial Date: March 12, 2011]
# File Initial Date: 10 07,2013 
#-------------------------------------------------------------------------------
#
# Subversion
#
# $Revision: 479 $
# $LastChangedBy: casey.ackels@gmail.com $
# $LastChangedDate$
#
########################################################################################

##
## - Overview
# Code for Batch Addresss

## Coding Conventions
# - Namespaces: Firstword_Secondword

# - Procedures: Proc names should have two words. The first word lowercase the first character of the first word,
#   will be uppercase. I.E sourceFiles, sourceFileExample

proc importFiles::initVars {args} {
    #****f* initVars/importFiles
    # CREATION DATE
    #   10/24/2014 (Friday Oct 24)
    #
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2014 Casey Ackels
    #   
    #
    # SYNOPSIS
    #   importFiles::initVars args 
    #
    # FUNCTION
    #	Initilize variables
    #   
    #   
    # CHILDREN
    #	N/A
    #   
    # PARENTS
    #   importFiles::eAssistGUI
    #   
    # NOTES
    #   
    #   
    # SEE ALSO
    #   
    #   
    #***
    global log headerParent headerAddress dist carrierSetup packagingSetup

    set headerParent(headerList) [eAssist_db::dbSelectQuery -columnNames InternalHeaderName -table Headers]
    set headerParent(headerList) [db eval "SELECT InternalHeaderName FROM Headers ORDER BY Header_ID"]
    set headerParent(whiteList) [eAssist_db::dbWhereQuery -columnNames InternalHeaderName -table Headers -where AlwaysDisplay=1]
    
    # Setup header array with subheaders
    foreach hdr $headerParent(headerList) {
        # Get the HeaderID
        #set id [eAssist_db::dbWhereQuery -columnNames Header_ID -table Headers -where "InternalHeaderName='$hdr'"]
        
        # Get the subheaders for the current header
        #set $headerAddress($hdr) [eAssist_db::leftOuterJoin -cols SubHeaderName -table Headers -jtable SubHeaders -where "HeaderID=Header_ID AND InternalHeaderName='$hdr'"]
        set headerAddress($hdr) [db eval "SELECT SubHeaderName FROM Headers LEFT OUTER JOIN SubHeaders WHERE HeaderID=Header_ID AND InternalHeaderName='$hdr'"]
    }
    
    set dist(distributionTypes) [db eval "SELECT DistTypeName FROM DistributionTypes"]
    set carrierSetup(ShippingClass) [db eval "SELECT ShippingClass FROM ShippingClasses"]
    set carrierSetup(ShipViaName) [db eval "SELECT ShipViaName FROM ShipVia"]
    
    set packagingSetup(ContainerType) [db eval "SELECT Container FROM Containers"]
    set packagingSetup(PackageType) [db eval "SELECT Package FROM Packages"]

} ;# importFiles::initVars



proc importFiles::readFile {fileName lbox} {
    #****f* readFile/importFiles
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2011-2013 Casey Ackels
    #
    # FUNCTION
    #	Description
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
    global log process files headerParent headerAddress options w
    ${log}::debug --START-- [info level 1]
    ${log}::debug file name: $fileName
    ${log}::debug file tail: [file tail $fileName]
    
    # Reset variables because we might be importing a 2nd file
    eAssistHelper::resetImportInterface 1
    
    if {$fileName eq ""} {return}
    
    set process(fileName) [file tail $fileName] ;# retrieve just the file name, so we can display it in a friendly matter
    
    # Open the file
    set process(fd) [open "$fileName" RDONLY]

    # Make the data useful, and put it into lists
    # We don't change the case here, in case the user wants it left alone.
    #while {-1 != [gets $fp line]}
    set gateway 0
    while { [gets $process(fd) line] >= 0 } {
        # Guard against lines of comma's, this will not be viewable in excel. Only in a text editor.
        if {[string is punc [join [split [string trim $line] " "] ""]] eq 1} {
            ${log}::notice Found some punc data, skipping ...
            continue
        }
        
        # Cycle through the rows until we find something that resembles a header row. Once we find it, start appending the data to a variable.
        # The imported files may have several rows of information before getting to the header row.
        if {$gateway == 0} {
            
            set Tmphdr [split $line ,]
            set hdr_lines 0
            foreach temp $Tmphdr {
                #${log}::debug Header $temp
                if {$gateway == 1} {
                    #${log}::debug Setting gateway to 1
                    break
                    }
                
                foreach hdr $headerParent(headerList) {
                    # Get the HeaderID
                    #set id [eAssist_db::dbWhereQuery -columnNames Header_ID -table Headers -where "InternalHeaderName='$hdr'"]
                    
                    # Get the subheaders for the current header
                    #set subheaders [eAssist_db::leftOuterJoin -cols SubHeaderName -table SubHeaders -jtable Headers -where "HeaderID=Header_ID AND HeaderID=$id"]
                    
                    if {[lsearch -nocase $headerAddress($hdr) $temp] != -1} {
                    #if {[lsearch -nocase $subheaders $temp] != -1} {}
                        #${log}::debug Found a Header Match: [lsearch -nocase $headerAddress($hdr) $temp]
                        #${log}::debug Number of matched headers: $hdr_lines
                        incr hdr_lines
                
                        # Once we reach 4 matches lets stop looping
                        if {$hdr_lines >= 4} {
                            ${log}::notice Found the Header row - $line
                            ${log}::notice Stopping the loop ...
                            lappend process(dataList) $line
                            set gateway 1
                            break
                        } else {
                            ${log}::notice Searching for the header row ...
                            ${log}::notice Headers found: $hdr_lines - $temp
                            continue
                        }
                    }
                }
            }
        } else {
            lappend process(dataList) $line
        }

    }
    
    #${log}::debug *Header RECORDS*: [expr [llength $process(dataList)]-1]
    set process(numOfRecords) [expr [llength $process(dataList)]-1]

    chan close $process(fd)

    # Only retrieve the first record. We use this as the 'header' row.
    set process(Header) [string toupper [csv::split [lindex $process(dataList) 0]]]
    ${log}::debug process(Header): $process(Header)
    
    set process(dataList) [lrange $process(dataList) 1 end] ;#we don't want the header, so lets trim it down.

    # headerList contains user set Master Header names
    # process(Header) contains headers listed in the file
    foreach header $process(Header) {
        # Insert all headers, regardless if they match or not.
        $lbox insert end $header
        
        if {$options(AutoAssignHeader) == 1} {
            foreach headerName $headerParent(headerList) {
                # Get the HeaderID
                set id [db eval "SELECT Header_ID FROM Headers WHERE InternalHeaderName='$headerName'"]
                # Get the subheaders for the current header
                set subheaders [db eval "SELECT SubHeaderName FROM SubHeaders LEFT OUTER JOIN Headers WHERE HeaderID=Header_ID AND HeaderID=$id"]
                
                if {$process(Header) != ""} {
                    if {[lsearch -nocase $subheaders $header] != -1} {
                        eAssistHelper::autoMap $headerName $header
                        #${log}::debug MAPPING - $headerName TO $header
                    }
                    # headerAddress($headername) = various spellings of the headername.
                    # Now we check to see if we can auto-map the headers with the information that we are already aware of.
                    #if {[lsearch -nocase $headerAddress($headerName) $header] != -1} {
                    #    if {$options(AutoAssignHeader) == 1} {
                    #        eAssistHelper::autoMap $headerName $header
                    #    }
                    #}

                    
                    #if {[lsearch -nocase $subheaders $header] != -1} {
                    #    if {$options(AutoAssignHeader) == 1} {
                    #        eAssistHelper::autoMap $headerName $header
                    #    }
                    #}
                }
            }
        }
    }
    
    importFiles::enableButtons $w(wi).top.btn2 $w(wi).btns.btn1 $w(wi).btns.btn2
    ${log}::debug --END-- [info level 1]
} ;# importFiles::readFile



proc importFiles::processFile {win} {
    #****f* processFile/importFiles
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2011-2013 Casey Ackels
    #
    # FUNCTION
    #	Description
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
    #   headerParent(headerList) - List of InternalHeaderName
    #   headerParent(outPutHeader) - List of Output Headers
    #   headerParent(whiteList) - List of headers that should always be displayed
    #   headerAddress() - Contains the subheaders associated with the listed master header
    #   headerParams() - Contains the setup params for the specified header
    #
    # SEE ALSO
    #   IFMenus::tblPopup
    #
    #***
    global log files headerAddress position process headerParams headerParent dist w job L_states options
    #${log}::debug --START-- [info level 1]
    
    # Close the file importer window
    destroy $win
    
    # This will allow us to append, or reset the interface depending on the user's selection in the File Importer window
    if {$options(ClearExistingData) == 1} {
        # Reset the entire interface
        eAssistHelper::resetImportInterface 2
    }

    
    # Ensure the 'count/OrderNumber' column is whitelisted
    if {[lsearch $headerParent(whiteList) OrderNumber] == -1} {lappend headerParent(whiteList) OrderNumber}
      
    set process(versionList) ""
    
    set ColumnCount [$files(tab3f2).tbl columncount]
    # Index (i.e. 01, from 01_HeaderName)
    set FileHeaders [lsort [array names position]]
    #${log}::debug FileHeaders: $FileHeaders
    
    
    # launch progress bar window
    eAssistHelper::importProgBar
    ${log}::debug Launching Progress Bar
    
    # configure value of progress bar (number of total records)
    set max [expr {$process(numOfRecords) + 1}]
    $::gwin(importpbar) configure -maximum $max
    ${log}::debug configuring Progress Bar with -maximum $max

    foreach record $process(dataList) {
        # .. Skip over any 'blank' lines in found in the file
        if {[string is punc $record] == 1} {continue}
            
        ## Ensure we have good data; if we don't, lets try to fix it
        if {[csv::iscomplete $record] == 0} {
                lappend badString $record
                ${log}::notice Bad Record - Found on line [lsearch $process(dataList) $record] - $record
                # Stop looping and go to the next record
                continue
        } else {
            if {[info exists badString]} {
                set l_line [csv::split [join $badString]]
                unset badString
            } else {
                set l_line [csv::split $record]
            }
        }
        
        #set l_line [join [split $l_line ,] ""] ;# remove all comma's

        for {set x 0} {$ColumnCount > $x} {incr x} {
            set ColumnName [$files(tab3f2).tbl columncget $x -name]
           
            
            # Figure out if the listData contains more chars than allowed; at the same time set the highlight configuration if it does exceed the limits
            set headerStringLength [join [eAssist_db::dbWhereQuery -columnNames HeaderMaxLength -table Headers -where InternalHeaderName='$ColumnName']]
            set bgColor [join [eAssist_db::dbWhereQuery -columnNames Highlight -table Headers -where InternalHeaderName='$ColumnName']]

            set tmpHeader [lindex $FileHeaders [lsearch -nocase $FileHeaders *$ColumnName]]

            set index [lrange [split $tmpHeader _] 0 0]
            #set indexHdr [lrange [split $tmpHeader _] 1 1]
         
            #${log}::debug Current Column: $ColumnName
            #${log}::debug tmpHeader: $tmpHeader

            if {[string compare $index 00] == 0} {
                # This is the first record so we only want to strip the leading 0, not both.
                set index 0
            } else {
                set index [string trimleft $index 0]
            }
            
            
            if {$index eq ""} {

                # Create a default version if, a version isn't found in the file. Planner defaults to 'Version 1'.
                if {[$files(tab3f2).tbl columncget $x -name] eq "Version"} {
                    #${log}::debug Found Version Column!
                    lappend newRow "Version 1"
                } else {
                    lappend newRow ""
                }
                
                if {[lsearch -nocase $headerParent(whiteList) $ColumnName] == -1} {
                    # the header is on the whitelist, but we don't have any data in the file
                    # If we dont have an index for it, then lets hide the column aswell.
                    # This will not hide columns that have no data in it, just columns that were not in the original file.
                    # WARNING - If importing more than one file it is possible for a column that has data in it from the first file, to be hidden by the second file.
                
                    #${log}::notice $ColumnName is not on the white list
                    #${log}::notice $ColumnName doesn't contain any data
                    #${log}::notice Hiding $ColumnName ...
                    $files(tab3f2).tbl columnconfigure $x -hide yes
                    
                }

            } else {
                set listData [string trim [lindex $l_line $index]]
                #${log}::debug l_line: $l_line
                #${log}::debug Index: $index
                #${log}::debug listData: $listData

                # Dynamically build the list of versions
                # the switch args, must equal the internal header name
                switch -nocase $ColumnName {
                    company     {set listData [join [split $listData ,] ""] ;# remove all comma's}
                    attention   {set listData [join [split $listData ,] ""] ;# remove all comma's}
                    address1    {set listData [join [split $listData ,] ""] ;# remove all comma's}
                    address2    {set listData [join [split $listData ,] ""] ;# remove all comma's}
                    address3    {set listData [join [split $listData ,] ""] ;# remove all comma's}
                    city        {set listData [join [split $listData ,] ""] ;# remove all comma's}
                    state       {set listData [join [split $listData ,]] ;# remove all comma's}
                    zip         {set listData [join [split $listData ,]] ;# remove all comma's}
                    version    {
                                # There is another instance of this above, to handle the case where the file may not have a version colum at all.
                                if {$listData eq ""} {set listData "Version 1"} else {set listData [join [split $listData ,] ""] ;# remove all comma's}
                                if {[lsearch $process(versionList) $listData] == -1} {
                                        lappend process(versionList) $listData
                                    }
                        }
                    default     {}
                }
                
                if {[string length $listData] > $headerStringLength} {
                    #${log}::debug List: $listData - Length: [string length $listData]
                    lappend maxCharColumn $x
                    
                    #OLD set bgColor [lindex $headerParams($ColumnName) 3]
                    
                    if {$bgColor != ""} {
                        set backGround $bgColor
                    } else {
                        set backGround yellow ;# default
                    }
                }
                
                
                # Create the list of values
                lappend newRow $listData
                #${log}::debug Position: [llength $newRow]
                    
                }
            #${log}::debug NewRow: $newRow

        }
        $files(tab3f2).tbl insert end $newRow
        #${log}::debug Raw Record: $record
        #${log}::debug Record: $newRow
        
        if {[info exists maxCharColumn] == 1} {
            foreach column $maxCharColumn {
                $files(tab3f2).tbl cellconfigure end,$column -bg $backGround
            }
        unset maxCharColumn
        }
        
        # Update Progress Bar ...
        $::gwin(importpbar) step 1
        ${log}::debug Updating Progress Bar - [$::gwin(importpbar) cget -value]
        
        unset newRow
        set x 0
    }
    # Ensure the progress bar is at the max, by the time we get to this point
    $::gwin(importpbar) configure -value $max
    
    # save the original version list as origVersionList, so we can keep the process(versionList) variable updated with user changed versions
    if {[info exists process(versionList)]} {
        set process(origVersionList) $process(versionList)
    }
    
    # Initialize popup menus
    IFMenus::tblPopup $files(tab3f2).tbl browse .tblMenu
    IFMenus::createToggleMenu $files(tab3f2).tbl
    
    # Get total copies
    set job(TotalCopies) [eAssistHelper::calcSamples $files(tab3f2).tbl [$files(tab3f2).tbl columncget Quantity -name]]
    
    ## Insert columns that we should always see, and make sure that we don't create it multiple times if it already exists
    if {[$files(tab3f2).tbl findcolumnname OrderNumber] == -1} {
        $files(tab3f2).tbl insertcolumns 0 0 "..."
        $files(tab3f2).tbl columnconfigure 0 -name "OrderNumber" -showlinenumbers 1 -labelalign center
    }
    
    # Enable menu items
    importFiles::enableMenuItems
    
    #${log}::debug --END-- [info level 1]
} ;# importFiles::processFile


proc importFiles::startCmd {tbl row col text} {
    #****f* startCmd/importFiles
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2013 - Casey Ackels
    #
    # FUNCTION
    #	Configuration options when the user enters the tablelist
    #
    # SYNOPSIS
    #	N/A
    #
    # CHILDREN
    #	N/A
    #
    # PARENTS
    #	
    #
    # NOTES
    #   dist() - Contains all distribution types
    #
    # SEE ALSO
    #
    #***
    global log dist carrierSetup job process packagingSetup
    ${log}::debug --START-- [info level 1]
    set w [$tbl editwinpath]
    
    set colName [$tbl columncget $col -name]
    
    switch -nocase $colName {
            "distributiontype"  {
                                $w configure -values $dist(distributionTypes) -state readonly
            }
            version              {
                                $w configure -values $process(versionList)
                                set process(startTblText) $text
                                ${log}::debug StartCmd: $process(startTblText)
            }
            ShipVia             {
                                $w configure -values $carrierSetup(ShipViaName) -state readonly
            }
            "quantity"          {
                                    if {![string is integer $text]} {
                                            bell
                                            tk_messageBox -title "Error" -icon error -message \
                                                [mc "Only numbers are allowed"]
                                        $tbl rejectinput
                                        return
                                    }
                                set job(TotalCopies) [eAssistHelper::calcSamples $tbl $col]
            }
            "containertype"     {
                                $w configure -values $packagingSetup(ContainerType) -state readonly
            }
            "packagetype"       {
                                $w configure -values $packagingSetup(PackageType) -state readonly
            }
            shippingclass       {
                                $w configure -values $carrierSetup(ShippingClass) -state readonly
            }
            default {
                #${log}::debug Column Name: [string tolower [$tbl columncget $col -name]]
            }
        }
        
        $tbl cellconfigure $row,$col -text $text

    #set idx [lsearch -nocase [array names headerParams] $colName]
    set stringLength [eAssist_db::dbWhereQuery -columnNames HeaderMaxLength -table Headers -where InternalHeaderName='$colName']
    set bgColor [join [eAssist_db::dbWhereQuery -columnNames Highlight -table Headers -where InternalHeaderName='$colName']]

    #if {$idx != -1} {}
    if {[string length $text] > $stringLength} {
        ${log}::debug length [string length $text]
            
        if {$bgColor != ""} {
            set backGround $bgColor
        } else {
            # Default color
            set backGround yellow
        }
    } else {
        set backGround SystemWindow
    }
    # Update the internal list with the current text so that we can run calculations on it.
    $tbl cellconfigure $row,$col -background $backGround

        
    return $text
    
    ${log}::debug --END-- [info level 1]
} ;#importFiles::startCmd


proc importFiles::endCmd {tbl row col text} {
    #****f* endCmd/importFiles
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2011-2013 Casey Ackels
    #
    # FUNCTION
    #	Description
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
    global log headerParams headerParent files process job
    ${log}::debug --START-- [info level 1]
    
    set colName [$tbl columncget $col -name]
    set updateCount 0
    
    switch -nocase $colName {
        version  {# Add $text to list of versions if that version doesn't exist (i.e. user created a new version)
                    if {$text == ""} {
                        set newItem [lsearch $process(versionList) $process(startTblText)]
                        set process(versionList) [lreplace $process(versionList) $newItem $newItem]
                        ${log}::debug Text is: $text
                        ${log}::debug $process(startTblText) should be removed from the list: $process(versionList)
                    }
                    
                    if {[lsearch $process(versionList) $text] == -1} {
                        #${log}::debug Old Version List: $process(versionList)
                        set newItem [lsearch $process(versionList) $process(startTblText)]
                        set process(versionList) [lreplace $process(versionList) $newItem $newItem $text]
                        #${log}::debug New Version List: $process(versionList)
                    }
        }
        quantity    {
                    # We update the count's at the end of this proc
                    if {![string is integer $text]} {
                        bell
                        tk_messageBox -title "Error" -icon error -message \
                                        [mc "Only numbers are allowed"]
                        $tbl rejectinput
                        return
                    }
                    set updateCount 1                    
        }
    }
    
    $tbl cellconfigure $row,$col -text $text
    
    set stringLength [eAssist_db::dbWhereQuery -columnNames HeaderMaxLength -table Headers -where InternalHeaderName='$colName']
    set bgColor [join [eAssist_db::dbWhereQuery -columnNames Highlight -table Headers -where InternalHeaderName='$colName']]

    if {[string length $text] > $stringLength} {
        ${log}::debug length [string length $text]
            
        if {$bgColor != ""} {
            set backGround $bgColor
        } else {
            # Default color
            set backGround yellow
        }
    } else {
        set backGround SystemWindow
    }
    
    # Update the internal list with the current text so that we can run calculations on it.
    $tbl cellconfigure $row,$col -background $backGround

    if {$updateCount == 1} {
        set job(TotalCopies) [eAssistHelper::calcSamples $tbl $col]
    }
    
	return $text
    ${log}::debug --END-- [info level 1]
} ;# importFiles::endCmd


proc importFiles::insertColumns {tbl} {
    #****f* insertColumns/importFiles
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2011-2014 Casey Ackels
    #
    # FUNCTION
    #	Insert columns before populating them with data
    #
    # SYNOPSIS
    #   importFiles::insertColumns <tbl>
    #
    # CHILDREN
    #	N/A
    #
    # PARENTS
    #	importFiles::eAssistGUI
    #
    # NOTES
    #
    # SEE ALSO
    #
    #***
    global log headerParent headerParams dist
    #${log}::debug --START-- [info level 1]

    set x -1; #was -1
    foreach hdr $headerParent(headerList) {
        incr x
        #set idx [lsearch -exact $headerParent(headerList) $hdr]
        $tbl insertcolumns end 0 $hdr
        
        # Get the header configs that we'll need
        set headerConfig [db eval "SELECT Widget,Required,DefaultWidth FROM Headers WHERE InternalHeaderName = '$hdr'"]
        
        # Set a default widget type
        set myWidget [lindex $headerConfig 0]
        if {$myWidget == ""} {
            set myWidget ttk::entry
        }
        
        
        ## Query Headers table for values, then issue the columnconfigure command.
        # Setting the color to red if it is a required column.
        set reqCol [lindex $headerConfig 1]
        
        if {$reqCol == 1} {
            set hdrFG red
            } else {
                set hdrFG black
        }
        
        set widthCol [lindex $headerConfig 2]
        if {$widthCol == ""} {set widthCol 0}

        $tbl columnconfigure $x \
                            -name $hdr \
                            -labelalign center \
                            -editable yes \
                            -editwindow $myWidget \
                            -labelforeground $hdrFG \
                            -width $widthCol
    }
	
} ;# importFiles::insertColumns


proc importFiles::enableMenuItems {} {
    #****f* enableMenuItems/importFiles
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2011-2014 Casey Ackels
    #
    # FUNCTION
    #	Enable menu items, now that we have imported a list.
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
    ${log}::debug --START-- [info level 1]
    
    set menuCount [$mb.modMenu index end]
    
     # Enable/Disable the menu items depending on which one is active.
    for {set x 0} {$menuCount >= $x} {incr x} {
        catch {$mb.modMenu entryconfigure $x -state normal}
    }
	
    ${log}::debug --END-- [info level 1]
} ;# importFiles::enableMenuItems


proc importFiles::detectCountry {l_line state idxZip} {
    #****f* detectCountry/importFiles
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2011-2014 Casey Ackels
    #
    # FUNCTION
    #	Detect if the state exists in the US, if it doesn't look at the zip code. Ultimately, either inserting the country ISO code or highlighting the Country field
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
    #   $l_line = the entire row of data being read in.
    #
    # SEE ALSO
    #
    #***
    global log L_states L_countryCodes
    ${log}::debug --START-- [info level 1]
    
    set domestic yes
    set zip [string trim [lindex $l_line $idxZip]]
    
    ${log}::debug State-Zip: $state - $zip
    ${log}::debug US State? [lsearch -nocase $L_states(US) $state]
    
    if {[lsearch -nocase $L_states(US) $state] == -1} {
        ${log}::debug State not found - $state
        set domestic no
    }
    
    if {$domestic eq "no"} {
        # Check for common abbreviations for canada, mexico and japan
        if {[lsearch -nocase $L_countryCodes $state] == -1} {
            ${log}::debug State/Country not found - $state - lets look at zip codes.
        } else {
            ${log}::debug State was found: $state
            set domestic yes
        }
        
        # Check the zip code
        # USA Zip Codes [zip+4], each state starts with a 0-9.
        for {set x 0} {$x < 10} {incr x} {
            if {[string first $x $zip 0] == 0} {
                ${log}::debug Zip code exists in the USA: $zip
                set domestic yes
                break
            }
        }
    }
    
    # If it still isn't domestic, lets try to find the country
    if {$domestic eq "no"} {
        # Canadian format A1A 1A1
        # Look at length - must be 6 chars
        ${log}::debug length [llength $zip]
        ${log}::debug alphanum? [string is alnum [string range $zip 0 2]]
        ${log}::debug Non-US Zip code: $zip
    }
    
	
    ${log}::debug --END-- [info level 1]
} ;# importFiles::detectCountry
