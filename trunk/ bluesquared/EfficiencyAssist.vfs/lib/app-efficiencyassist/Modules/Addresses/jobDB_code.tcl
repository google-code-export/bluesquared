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
    #   
    #   
    # SEE ALSO
    #   
    #   
    #***
    global log job mySettings program env

    ${log}::notice Creating a new database for: $custID $jobTitle $jobName $jobNumber

    set job(db,Name) [join [ea::tools::formatFileName] _]
    
    # Create the database
    sqlite3 $job(db,Name) [file join $saveFileLocation $job(db,Name).db] -create 1
    
    # Create the tables
    set job(db,currentSchemaVers) 1
    $job(db,Name) eval {        
        CREATE TABLE IF NOT EXISTS Notes (
            Notes_ID  INTEGER PRIMARY KEY AUTOINCREMENT,
            UserNotes TEXT
        );
        
        CREATE TABLE IF NOT EXISTS JobInformation (
            Job_ID      INTEGER PRIMARY KEY AUTOINCREMENT,
            CustID      TEXT,
            CSRName     TEXT,
            JobTitle    TEXT,
            JobName     TEXT,
            CreatedDate DATE,
            CreatedBy   TEXT
        );
        
        CREATE TABLE IF NOT EXISTS SysInfo (
            SysInfo_ID  INTEGER PRIMARY KEY AUTOINCREMENT,
            ProgramVers TEXT,
            SchemaVers  TEXT
        );
    }
    

    ## Grab the table fields from our main db.
    set hdr [db eval {SELECT InternalHeaderName FROM Headers ORDER BY DisplayOrder}]
    set cTable [list {addr_ID INTEGER PRIMARY KEY AUTOINCREMENT}]
    
    # Dynamically build the Addresses table
    foreach header $hdr {
        lappend cTable "'$header' TEXT"
    }
    set cTable [join $cTable ,]
    
    $job(db,Name) eval "CREATE TABLE IF NOT EXISTS Addresses ( $cTable )"

    # Insert data into JobInformation table
    $job(db,Name) eval "INSERT INTO JobInformation (CustID, CSRName, JobTitle, JobName, CreatedDate, CreatedBy) VALUES ('$custID', '$csrName', '$jobTitle', '$jobName', DATETIME('NOW'), '$env(USERNAME)')"
    
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
    global log job mySettings

    if {[info exists job(db,Name)] == 1} {${log}::debug Previous job is open, we should close the DB}
        
    set job(db,Name) [eAssist_Global::OpenFile [mc "Open Project"] $mySettings(sourceFiles) file .db]
    
    # Just in case the user cancels out of the open dialog.
    if {$job(db,Name) eq ""} {
        return
    }
    
    ${log}::debug job(db,Name): $job(db,Name)
    
    # Reset the inteface ...
    eAssistHelper::resetImportInterface

    # Open the db
    sqlite3 $job(db,Name) [file join $saveFileLocation $job(db,Name)]
    
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
    
    ${log}::debug Updating COLUMN: $dbCol
    ${log}::debug Updating Cells (should only ever have one): $widCells
    ${log}::debug Updating VALUES to: $dbTxt
    
    # Update the tabelist widget
    $wid cellconfigure $widCells -text $dbTxt
    
    # Update the DB
    set dbPK [$wid getcell [lindex [split $widCells ,] 0],0]
    $db eval "UPDATE $dbTbl SET $dbCol='$dbTxt' WHERE addr_ID='$dbPK'"
    
} ;# job::db::write
