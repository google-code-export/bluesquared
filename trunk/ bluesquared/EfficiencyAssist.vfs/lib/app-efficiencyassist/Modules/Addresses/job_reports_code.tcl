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
    global log job

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
    #ttk::entry $f1.entry1 -textvariable disttypes
    #ttk::combobox $f1.cbox1 -values {Version}
    
    text $f1.txt \
                -xscrollcommand [list $f1.scrollx set] \
                -yscrollcommand [list $f1.scrolly set]
        
        # setup the autoscroll bars
    ttk::scrollbar $f1.scrollx -orient h -command [list $f1.txt xview]
    ttk::scrollbar $f1.scrolly -orient v -command [list $f1.txt yview]
    
    
    #ttk::button $f1.btn1 -text "OK" -command {job::reports::DistributionType .rv.f1.txt [.rv.f1.cbox1 get]}
    
    #grid $f1.cbox1 -column 0 -row 0 -sticky nsw
    #grid $f1.entry1 -column 0 -row 0 -sticky nsw
    #grid $f1.btn1 -column 1 -row 0 -sticky ew
    
    grid $f1.txt -column 0 -row 1 -sticky news
    grid columnconfigure $f1 0 -weight 2
    grid rowconfigure $f1 1 -weight 2
    
    grid $f1.scrolly -column 1 -row 1 -sticky nse
    grid $f1.scrollx -column 0 -row 2 -sticky ews
    
    ::autoscroll::autoscroll $f1.scrollx ;# Enable the 'autoscrollbar'
    ::autoscroll::autoscroll $f1.scrolly ;# Enable the 'autoscrollbar'
    
    $f1.txt delete 0.0 end
    
    
    job::reports::byVersion $f1.txt
} ;# job::reports::Viewer

proc job::reports::byVersion {txt args} {
    #****f* byVersion/job::reports
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
    #   job::reports::byVersion <textWidget Path> ?args?
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
    global log job
    ##
    ## Job Overview
    ##
    $txt insert end "Job Number: $job(Number)\n"
    $txt insert end "Job Title/Name: $job(Title) / $job(Name)\n\n"
    
    set numOfVersions [$job(db,Name) eval "SELECT count(distinct(Version)) FROM Addresses"]
    $txt insert end "Number of Versions: $numOfVersions\n"

    set numOfShipments [$job(db,Name) eval "SELECT count(*) FROM Addresses"]
    $txt insert end "Number of Shipments: $numOfShipments\n"
    
    set totalQtyOfShipments [$job(db,Name) eval "SELECT sum(Quantity) FROM Addresses"]
    $txt insert end "Total Quantity: $totalQtyOfShipments\n"

    $txt insert end "----\n\n"
    
    ##
    ## Detailed Information
    ##
    # Get unique versions
    set versionNames [$job(db,Name) eval "SELECT distinct(Version) FROM Addresses"]
    foreach vers $versionNames {
    # Output Version Name
        set versNumOfShipments [$job(db,Name) eval "SELECT count(*) FROM Addresses WHERE Version='$vers'"]
        set versQuantity [$job(db,Name) eval "SELECT sum(Quantity) FROM Addresses WHERE Version='$vers'"]
        $txt insert end "VERSION: $vers - Shipments: $versNumOfShipments - Quantity: $versQuantity\n"
        
        # Get unique distribution types, for current version
        set DistTypes [$job(db,Name) eval "SELECT distinct(DistributionType) FROM addresses WHERE Version='$vers' ORDER BY DistributionType"]
        foreach dist $DistTypes {
            # DistType associated with current version
            # Output Summary for Distribution Type
            # Output Carrier, Company and Quantity
            # Get total count for current distribution type

            
            set distTypeNumOfShipments [$job(db,Name) eval "SELECT count(*) from Addresses WHERE Version='$vers' AND DistributionType='$dist'"]
            set distTypeQty [$job(db,Name) eval "SELECT sum(Quantity) FROM Addresses WHERE Version='$vers' AND DistributionType='$dist'"]
            
            $txt insert end "\t<$dist> $distTypeNumOfShipments Shipments - $distTypeQty\n\n"
            
            # If the distribution type matches, UPS IMPORT, lets provide a grouped breakdown instead of the individual shipment
            if {$dist eq "07. UPS Import"} {
                if {[info exists qty]} {unset qty}
                $job(db,Name) eval "SELECT Quantity FROM Addresses WHERE Version='$vers' AND DistributionType='$dist'" {
                    #${log}::debug $Quantity $Version
                    lappend qty $Quantity
                }
            
                foreach single [lindex [Shipping_Code::extractFromList $qty] 0] {
                    #${log}::debug Singles: 1 Shipment of $single
                    $txt insert end "\t  1 Shipment of $single\n"
                }
            
                foreach groups [lrange [Shipping_Code::extractFromList $qty] 1 end] {
                    #${log}::debug Groups: [llength $groups] shipments of [lindex $groups 0]
                    $txt insert end "\t  [llength $groups] Shipments of [lindex $groups 0]\n"
                }
            } else {
            
                # Output detailed shipment information
                $job(db,Name) eval "SELECT ShipVia, Company, Quantity FROM Addresses WHERE Version='$vers' AND DistributionType='$dist' ORDER BY Quantity" {
                    # Error capturing: Set a default value if nothing was put into the db
                    if {$ShipVia eq ""} {set ShipVia [mc "CARRIER NOT ASSIGNED"]}
                    if {$Company eq ""} {set Company [mc "COMPANY NOT ASSIGNED"]}
                    if {$Quantity eq ""} {set Quantity [mc "QUANTITY NOT ASSIGNED"]}
                    
                    $txt insert end "\t  $ShipVia, $Company - $Quantity\n"
                }

            }
            # End of the Distribution Type
            $txt insert end "---- EOD\n"
        }
        # End of the Version
        $txt insert end "\n******** EOV\n"
    }

} ;# job::reports::byVersion
