# Creator: Casey Ackels
# Initial Date: March 12, 2011]
# File Initial Date: 02 16,2015
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
# Contains reports for Jobs (Batchmaker module)

namespace eval job::reports {}

proc job::reports::Viewer {} {
    #****f* Viewer/job::reports
    # CREATION DATE
    #   02/16/2015 (Monday Feb 16)
    #
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2015 Casey Ackels
    #   
    #
    # SYNOPSIS
    #   job::reports::Viewer  
    #
    # FUNCTION
    #	Displays a text widget, for the results of the report proc to dump data into.
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

    if {[winfo exists .rv]} {destroy .rv}

    toplevel .rv
    wm transient .rv .
    wm title .rv [mc "Report Viewer - By Distribution Type"]
    
    set locX [expr {[winfo screenwidth . ] / 4 + [winfo x .]}]
    set locY [expr {[winfo screenheight . ] / 5 + [winfo y .]}]
    wm geometry .rv +${locX}+${locY}

    set f1 [ttk::frame .rv.f1 -padding 10]
    pack $f1 -fill both -expand yes -padx 5p -pady 5p
    
    set disttypes ""
    
    text $f1.txt \
                -xscrollcommand [list $f1.scrollx set] \
                -yscrollcommand [list $f1.scrolly set]
        
        # setup the autoscroll bars
    ttk::scrollbar $f1.scrollx -orient h -command [list $f1.txt xview]
    ttk::scrollbar $f1.scrolly -orient v -command [list $f1.txt yview]
    
    ttk::entry $f1.entry1 -textvariable disttypes
    ttk::button $f1.btn1 -text "OK" -command {job::reports::DistributionType .rv.f1.txt [.rv.f1.entry1 get]}
    
    grid $f1.entry1 -column 0 -row 0 -sticky nsw
    grid $f1.btn1 -column 1 -row 0 -sticky ew
    
    grid $f1.txt -column 0 -row 1 -sticky news
    
    grid $f1.scrolly -column 1 -row 1 -sticky nse
    grid $f1.scrollx -column 0 -row 2 -sticky ews
    
    ::autoscroll::autoscroll $f1.scrollx ;# Enable the 'autoscrollbar'
    ::autoscroll::autoscroll $f1.scrolly ;# Enable the 'autoscrollbar'
    
    $f1.txt delete 0.0 end
    
    
    
} ;# job::reports::Viewer

#proc job::reports::DistributionType {txt args} {}
    #****f* DistributionType/job::reports
    # CREATION DATE
    #   02/16/2015 (Monday Feb 16)
    #
    # AUTHOR
    #	Casey Ackels
    #
    # COPYRIGHT
    #	(c) 2015 Casey Ackels
    #   
    #
    # SYNOPSIS
    #   job::reports::UPSIMPORT -basic|-detailed -disttype ?value1 ... valueN?
    #
    # FUNCTION
    #	Produces a report on the UPS Imports. Switches determine how verbose the report is.
    #   Options can be: -basic, or -detailed
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
proc job::reports::DistributionType {txt args} {
    global log job
    #set args [join $args]

    foreach dist $args {
        #${log}::debug *** $dist BASIC REPORT ***
        $txt insert end "*** $dist BASIC REPORT ***\n\n"
        
        set numOfVersions [$job(db,Name) eval "SELECT count(distinct(Version)) FROM Addresses WHERE DistributionType='$dist'"]
        #${log}::debug Number of Versions: $numOfVersions
        $txt insert end "Number of Versions: $numOfVersions\n"
        
        set versionNames [$job(db,Name) eval "SELECT distinct(Version) FROM Addresses WHERE DistributionType='$dist'"]
        #${log}::debug Version Names: [join $versionNames]
        $txt insert end "Version Names: [join $versionNames ,]\n"
        
        set numOfShipments [$job(db,Name) eval "SELECT count(*) FROM Addresses WHERE DistributionType='$dist'"]
        #${log}::debug Number of Shipments: $numOfShipments
        $txt insert end "Number of Shipments: $numOfShipments\n"
    
        set totalQtyOfShipments [$job(db,Name) eval "SELECT sum(Quantity) FROM Addresses WHERE DistributionType='$dist'"]
        #${log}::debug Total Quantity: $totalQtyOfShipments
        $txt insert end "Total Quantity: $totalQtyOfShipments\n"
    
        #${log}::debug -----
        $txt insert end "----\n\n"
        #${log}::debug *** $dist DETAILED REPORT ***
        $txt insert end "*** $dist DETAILED REPORT ***\n"
        
        foreach vers $versionNames {
            if {[info exists qty]} {unset qty}
            $job(db,Name) eval "SELECT Quantity FROM Addresses WHERE DistributionType='$dist' AND Version='$vers'" {
                #${log}::debug $Quantity $Version
                lappend qty $Quantity
            }
            set versQty [$job(db,Name) eval "SELECT sum(Quantity) FROM Addresses WHERE DistributionType='$dist' AND Version='$vers'"]
            
            #${log}::debug __ VERSION: [join $vers] __ QUANTITY: $versQty __ SHIPMENTS: [llength $qty]
            $txt insert end "\n\nVERSION: [join $vers] - QUANTITY: $versQty - SHIPMENTS: [llength $qty]\n\n"
            #${log}::debug [extractFromList $qty]
            #${log}::debug SINGLE: [lindex [extractFromList $qty] 0]
            #${log}::debug GROUPS: [lrange [extractFromList $qty] 1 end]
            
            foreach single [lindex [Shipping_Code::extractFromList $qty] 0] {
                #${log}::debug Singles: 1 Shipment of $single
                $txt insert end "1 Shipment of $single\n"
            }
            
            foreach groups [lrange [Shipping_Code::extractFromList $qty] 1 end] {
                #${log}::debug Groups: [llength $groups] shipments of [lindex $groups 0]
                $txt insert end "[llength $groups] Shipments of [lindex $groups 0]\n"
            }
        }
        #${log}::debug **-----------------
        $txt insert end "**-----------------\n\n\n"
    }  
} ;# job::reports::DistributionType "07. UPS Import"
