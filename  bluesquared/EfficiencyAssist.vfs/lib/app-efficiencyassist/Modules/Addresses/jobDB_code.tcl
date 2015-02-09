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

proc job::db::createDB {custID jobTitle jobName jobNumber} {
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
    global log job mySettings

    ${log}::notice Creating a new database for: $custID $jobTitle $jobName $jobNumber
    set job(db,Name) [join "$jobTitle $jobName $jobNumber" _]
    
    # Create the database
    sqlite3 $job(db,Name) [file join $mySettings(Home) $job(db,Name)] -create 1
    #ATTACH DATABASE 'DatabaseName' As 'Alias-Name';
    
    # Create the tables
    $job(db,Name) eval {        
        CREATE TABLE Notes (
            Notes_ID  INTEGER PRIMARY KEY AUTOINCREMENT,
            UserNotes TEXT
        );
        
        CREATE TABLE JobInformation (
            Job_ID      INTEGER PRIMARY KEY AUTOINCREMENT,
            CustID      TEXT,
            CSRID       TEXT,
            JobTitle    TEXT,
            JobName     TEXT,
            CreatedDate DATE,
            CreatedBy   TEXT
        );
        
        CREATE TABLE JobHeaders (
            header_ID   INTEGER PRIMARY KEY AUTOINCREMENT,
            HeaderNames TEXT
        );
    }
    
    # Populate the table from our main db.
    set hdr [db eval {SELECT InternalHeaderName FROM Headers}]
    foreach name $hdr {
        $job(db,Name) eval "INSERT INTO JobHeaders (HeaderNames) VALUES ('$name')"
    }
    
} ;# job::db::createDB
#job::db::createDB SAGMED TEST001 Febraury TEST555


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
