# Creator: Casey Ackels
# Initial Date: March 12, 2011]
# File Initial Date: 02 08,2015
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
# Create the per job databases

namespace eval job::db {}

proc job::db::createDB {custID csrName jobTitle jobName jobNumber saveFileLocation} {
    #****f* createDB/job::db
    # CREATION DATE
    #   02/08/2015 (Sunday Feb 08)
    #
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2015 Casey Ackels
    #   
    #
    # SYNOPSIS
    #   job::createDB custID csrName jobTitle jobName jobNumber saveFileLocation
    #
    # FUNCTION
    #	Initialize a new Job database
    #   
    #   
    # CHILDREN
    #	N/A
    #   
    # PARENTS
    #   
    #   
    # NOTES
    #   Schema Version Notes
    #   v1. Tables: Address, Notes and JobInformation
    #   v2. Altered Address table with proc [job::db::update_2]
    #   v3. Added table: internalShipments, Modifications, UserNotes, JobNotes, VersNotes
    #   v3. ShipDate and ArriveDate columns now use the DATE data type
    #   
    # SEE ALSO
    #   
    #   
    #***
    global log job mySettings program env

    ${log}::notice Creating a new database for: $custID $jobTitle $jobName $jobNumber

    set job(db,Name) [ea::tools::formatFileName]
    
    # Create the database
    sqlite3 $job(db,Name) [file join $saveFileLocation $job(db,Name).db] -create 1
    
    # Create the tables
        # UserNotes; Used internally for the distribution person(s)
        # JobNotes; per job (any notes that pertain to the whole job)
        # VersNotes; per version (any notes that are version specific)
    
    $job(db,Name) eval {
        
        CREATE TABLE IF NOT EXISTS Modifications (
            Mod_ID      INTEGER PRIMARY KEY AUTOINCREMENT,
            Mod_User    TEXT,
            Mod_Date    DATE,
            Mod_Time    TIME,
            Mod_SysLog  TEXT
        );

        CREATE TABLE IF NOT EXISTS UserNotes (
            UserNotes_ID         INTEGER PRIMARY KEY AUTOINCREMENT,
            ModID                INTEGER REFERENCES Modifications (Mod_ID),
            UserNotes_Notes      TEXT
        );
        
        CREATE TABLE IF NOT EXISTS JobNotes (
            JobNotes_ID         INTEGER PRIMARY KEY AUTOINCREMENT,
            ModID               INTEGER REFERENCES Modifications (Mod_ID),
            JobNotes_Notes      TEXT
        );
        
        CREATE TABLE IF NOT EXISTS VersNotes (
            VersNotes_ID         INTEGER PRIMARY KEY AUTOINCREMENT,
            ModID                INTEGER REFERENCES Modifications (Mod_ID),
            VersNotes_Notes      TEXT,
            VersNotes_Version    TEXT REFERENCES Addresses (Version)
                                    ON DELETE CASCADE
                                    ON UPDATE CASCADE
        );
        
        CREATE TABLE IF NOT EXISTS JobSamples (
            JobSamples_ID        INTEGER PRIMARY KEY AUTOINCREMENT,
            ModID                INTEGER REFERENCES Modifications (Mod_ID),
            JobSamples_Dest      TEXT,
            JobSamples_Version   TEXT REFERENCES Addresses (Version)
                                    ON DELETE CASCADE
                                    ON UPDATE CASCADE
        );
        
        CREATE TABLE IF NOT EXISTS JobInformation (
            Job_ID      INTEGER PRIMARY KEY AUTOINCREMENT,
            CustID      TEXT,
            CSRName     TEXT,
            JobTitle    TEXT,
            JobNumber   TEXT,
            JobName     TEXT,
            CreatedDate DATE,
            CreatedBy   TEXT
        );
        
        CREATE TABLE IF NOT EXISTS SysInfo (
            SysInfo_ID  INTEGER PRIMARY KEY AUTOINCREMENT,
            ProgramVers TEXT,
            SchemaVers  TEXT
        );
        
        --# Added in DB Vers 3 (No update proc needed for this, since we aren't altering tables)
        --# If intShp_shipment contains 1/YES, those destinations will NOT be included in the total
        CREATE TABLE IF NOT EXISTS InternalShipments (
            IntShp_ID   INTEGER PRIMARY KEY AUTOINCREMENT,
            AddrID      INTEGER REFERENCES Addresses (OrderNumber)
                            ON DELETE CASCADE
                            ON UPDATE CASCADE,
            IntShp_shipment BOOLEAN
        );
    }
    

    ## Grab the table fields from our main db.
    set hdr [db eval {SELECT InternalHeaderName FROM Headers ORDER BY DisplayOrder}]
    set cTable [list {OrderNumber INTEGER PRIMARY KEY AUTOINCREMENT}]
    
    # Dynamically build the Addresses table
    foreach header $hdr {
        switch -- $header {
            Quantity    {set dataType INTEGER}
            ShipDate    {set dataType DATE}
            ArriveDate  {set dataType DATE}
            default     {set dataType TEXT}
        }
        lappend cTable "'$header' $dataType"
    }
    set cTable [join $cTable ,]
    
    $job(db,Name) eval "CREATE TABLE IF NOT EXISTS Addresses ( $cTable )"

    # Insert data into JobInformation table
    $job(db,Name) eval "INSERT INTO JobInformation (CustID, CSRName, JobNumber, JobTitle, JobName, CreatedDate, CreatedBy) VALUES ('$custID', '$csrName', '$jobNumber', '$jobTitle', '$jobName', DATETIME('NOW'), '$env(USERNAME)')"
    
    # Insert data into Sysinfo table
    $job(db,Name) eval "INSERT INTO SysInfo (ProgramVers, SchemaVers) VALUES ('$program(Version).$program(PatchLevel)', '$job(db,currentSchemaVers)')"
       
} ;# job::db::createDB
#job::db::createDB SAGMED {Meredith Hunter} TEST001 Febraury 303603


proc job::db::open {} {
    #****f* open/job::db
    # CREATION DATE
    #   02/08/2015 (Sunday Feb 08)
    #
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2015 Casey Ackels
    #   
    #
    # SYNOPSIS
    #   job::db::load 
    #
    # FUNCTION
    #	Launches the browse dialog; loads the selected database based on the file that we've opened.
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
    global log job mySettings files headerParent process

    if {[info exists job(db,Name)] == 1} {
        ${log}::debug Previous job is open. Closing current job: $job(Title) $job(Name)
        $job(db,Name) close
        
        #unset job
        }
        
    set job(db,Name) [eAssist_Global::OpenFile [mc "Open Project"] $mySettings(sourceFiles) file -ext .db -filetype {{Efficiency Assist Project} {.db}}]
    
    # Just in case the user cancels out of the open dialog.
    if {$job(db,Name) eq ""} {
        return
    }
    
    # Reset the inteface ...
    eAssistHelper::resetImportInterface

    # Open the db
    sqlite3 $job(db,Name) $job(db,Name)
    
    set job(SaveFileLocation) [file dirname $job(db,Name)]
    set job(CustID) [join [$job(db,Name) eval {SELECT CustID FROM JobInformation}]]
    set job(CSRName) [join [$job(db,Name) eval {SELECT CSRName FROM JobInformation}]]
    set job(Number) [join [$job(db,Name) eval {SELECT JobNumber FROM JobInformation}]]
    set job(Title) [join [$job(db,Name) eval {SELECT JobTitle FROM JobInformation}]]
    set job(Name) [join [$job(db,Name) eval {SELECT JobName FROM JobInformation}]]
    
    set job(CustName) [join [db eval "SELECT CustName From Customer where Cust_ID='$job(CustID)'"]]

    #set newHdr {$OrderNumber}
    foreach header [job::db::retrieveHeaderNames $job(db,Name) Addresses] {
        lappend newHdr $$header
    }
    
    set headerParent(dbHeaderList) $newHdr
    
    ## Check db schema to see if it needs to be updated ...
    job::db::updateDB
    
    ## Insert columns that we should always see, and make sure that we don't create it multiple times if it already exists
    if {[$files(tab3f2).tbl findcolumnname OrderNumber] == -1} {
        $files(tab3f2).tbl insertcolumns 0 0 "..."
        $files(tab3f2).tbl columnconfigure 0 -name "OrderNumber" -labelalign center
    }
    
    # Insert the data into the tablelist
    $job(db,Name) eval {SELECT * from Addresses} {
        #${log}::debug [$files(tab3f2).tbl insert end $newHdr]
        catch {$files(tab3f2).tbl insert end [subst $newHdr]} err
    }
    
    if {[info exists err]} {${log}::debug ERROR: $err}
    
    set headerWhiteList "$headerParent(whiteList) OrderNumber"
    
    for {set x 0} {$headerParent(ColumnCount) > $x} {incr x} {
        set ColumnName [$files(tab3f2).tbl columncget $x -name]
        if {[lsearch -nocase $headerWhiteList $ColumnName] == -1} {
            $files(tab3f2).tbl columnconfigure $x -hide yes
        }
    }

    # Apply the highlights
    importFiles::highlightAllRecords $files(tab3f2).tbl
    
    # Get total copies
    set job(TotalCopies) [ea::db::countQuantity $job(db,Name) Addresses]
    
    # Init variables
    
    set process(versionList) [ea::db::getUniqueValues $job(db,Name) Version Addresses]
    ## Initialize popup menus
    #IFMenus::tblPopup $files(tab3f2).tbl browse .tblMenu
    IFMenus::createToggleMenu $files(tab3f2).tbl
} ;# job::db::open


proc job::db::write {db dbTbl dbTxt wid widCells {dbCol ""}} {
    #****f* write/job::db
    # CREATION DATE
    #   02/13/2015 (Friday Feb 13)
    #
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2015 Casey Ackels
    #   
    #
    # SYNOPSIS
    #   job::db::write db dbTbl dbCol dbTxt wid widCells
    #   job::db::write <dbName> <dbTable> ?colName? <text> <widTbl> <row,col>
    #
    # FUNCTION
    #	Writes data to the widget cell and database.
    #	If the column name isn't already known, use two quotes; and this proc will figure it out, since we are receiving the row,cell value.
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
    global log job

    if {$dbCol eq ""} {
        # retrieves the column name if we didn't pass it to the proc.
        set dbCol [$wid columncget [lindex [split $widCells ,] end] -name]
    }
    
    #${log}::debug Updating COLUMN: $dbCol
    #${log}::debug Updating Cells (should only ever have one): $widCells
    #${log}::debug Updating VALUES to: $dbTxt
    
    # Update the tabelist widget
    $wid cellconfigure $widCells -text $dbTxt
    
    # Update the DB
    set dbPK [$wid getcell [lindex [split $widCells ,] 0],0]
    $db eval "UPDATE $dbTbl SET $dbCol='$dbTxt' WHERE OrderNumber='$dbPK'"
    
    # Get total copies
    set job(TotalCopies) [ea::db::countQuantity $job(db,Name) Addresses]
    
} ;# job::db::write


proc job::db::updateDB {} {
    #****f* updateDB/job::db
    # CREATION DATE
    #   02/24/2015 (Tuesday Feb 24)
    #
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2015 Casey Ackels
    #   
    #
    # SYNOPSIS
    #   job::db::updateDB
    #
    # FUNCTION
    #	Verify's the db schema is the latest; if it isn't update the schema
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
    global log job program

    
    set job(db,oldSchema) [$job(db,Name) eval "SELECT max(SchemaVers) FROM SysInfo WHERE ProgramVers = '$program(Version).$program(PatchLevel)'"]
    
    if {$job(db,currentSchemaVers) > $job(db,oldSchema)} {
        ${log}::debug Current Schema: $job(db,currentSchemaVers)
        ${log}::debug DB Schema: $job(db,oldSchema)
        ${log}::debug Job Schema needs to be updated!
        ${log}::debug Updates to apply: [expr {$job(db,currentSchemaVers) - $job(db,oldSchema)}]
        
        set updates [expr {$job(db,oldSchema) + 1}] ;# Add a number, because we will start applying updates before the number can be increased.
        for {set x $updates} {$x <= $job(db,currentSchemaVers)} {incr x} {
            ${log}::info "Updating to schema $x"
            
            set updateProcs [info procs update_*]
            ${log}::info Available update procs: $updateProcs
            if {[lsearch $updateProcs _$x] != -1} {
                ${log}::info "Applying updates to schema $x"
                job::db::update_$x
            } else {
                ${log}::info "No updates to apply, must be adding a table ..."
                # Insert data into Sysinfo table
                $job(db,Name) eval "INSERT INTO SysInfo (ProgramVers, SchemaVers) VALUES ('$program(Version).$program(PatchLevel)', '$job(db,currentSchemaVers)')"
                ${log}::info Job DB Schema is now: [$job(db,Name) eval "SELECT max(SchemaVers) FROM SysInfo WHERE ProgramVers = '$program(Version).$program(PatchLevel)'"]
            }
        }
    }
} ;# job::db::updateDB


proc job::db::update_2 {} {
# Updates the schema
    global log job program

    $job(db,Name) eval "ALTER TABLE Addresses RENAME TO ea_temp_table"
    
    ## Grab the table fields from our main db.
    set hdr [db eval {SELECT InternalHeaderName FROM Headers ORDER BY DisplayOrder}]
    set cTable [list {OrderNumber INTEGER PRIMARY KEY AUTOINCREMENT}]
    
    # Dynamically build the Addresses table
    foreach header $hdr {
        switch -- $header {
            Quantity    {set dataType INTEGER}
            default     {set dataType TEXT}
        }
        lappend cTable "'$header' $dataType"
    }
    set cTable [join $cTable ,]
    
    $job(db,Name) eval "CREATE TABLE IF NOT EXISTS Addresses ( $cTable )"

    set tmpHdr [job::db::retrieveHeaderNames $job(db,Name) Addresses]
    
    set tmpHdr [join $tmpHdr ,]
    $job(db,Name) eval "INSERT INTO Addresses ($tmpHdr) SELECT $tmpHdr FROM ea_temp_table"
    
    $job(db,Name) eval "DROP TABLE ea_temp_table"
    
    # Insert data into Sysinfo table
    $job(db,Name) eval "INSERT INTO SysInfo (ProgramVers, SchemaVers) VALUES ('$program(Version).$program(PatchLevel)', '$job(db,currentSchemaVers)')"
    
    ${log}::info Job DB Schema is now: [$job(db,Name) eval "SELECT max(SchemaVers) FROM SysInfo WHERE ProgramVers = '$program(Version).$program(PatchLevel)'"]
} ;# job::db::update_2


proc job::db::retrieveHeaderNames {db dbTbl} {
    #****f* retrieveHeaderNames/job::db
    # CREATION DATE
    #   02/24/2015 (Tuesday Feb 24)
    #
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2015 Casey Ackels
    #   
    #
    # SYNOPSIS
    #   job::db::retrieveHeaderNames db dbTbl
    #
    # FUNCTION
    #	Retrieves the header names from the db that we're opening
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
    
    if {[info exists tmpHdr]} {unset tmpHdr}
    set pragma [$db eval "PRAGMA table_info($dbTbl)"]
    foreach item $pragma {
        if {$item != "" && ![string is digit $item] && ![string is upper $item]} {
            lappend tmpHdr $item
        }
        
    }
    
return $tmpHdr
    
} ;# job::db::retrieveHeaderNames


proc job::db::tableExists {dbTbl} {
    #****f* tableExists/job::db
    # CREATION DATE
    #   03/04/2015 (Wednesday Mar 04)
    #
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2015 Casey Ackels
    #   
    #
    # SYNOPSIS
    #   job::db::tableExists dbTbl
    #
    # FUNCTION
    #	Returns table name if found, otherwise returns nothing
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
    global log job

    $job(db,Name) eval "SELECT name FROM sqlite_master WHERE type='table' AND name='$dbTbl'"
    
} ;# job::db::tableExists
