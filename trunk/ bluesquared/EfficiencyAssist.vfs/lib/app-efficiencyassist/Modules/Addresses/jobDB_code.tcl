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

proc job::db::createDB {custID csrName jobTitle jobName jobNumber} {
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
    #   job::createDB custID jobTitle jobName JobNumber
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
    set job(db,Name) [join "$jobNumber $jobTitle $jobName" _]
    
    # Create the database
    sqlite3 $job(db,Name) [file join $mySettings(Home) $job(db,Name)] -create 1
    
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


proc job::db::load {dbName} {
    #****f* load/job::db
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
    #   job::db::load dbName 
    #
    # FUNCTION
    #	Loads the selected database
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

    
    #set myDB [file join $program(Home) <jobName>.edb]
    #sqlite3 db $myDB

    
} ;# job::db::load
