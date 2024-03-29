# Copyright: 2007-2011 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.
#
# This script can be used to create all needed constants for the TcomWord
# package.
# You may need to have to change the path to the type library of Word used
# in the import command.
#
# Usage: tclsh createConstFile.tcl > wordConst.tcl

package require tcom

tcom::import "C:/Program Files (x86)/Microsoft Office/Office12/msword.olb" paul

set len [expr 4 + 2*2] ; # 4 characters for paul; 2*2 characters for ::

puts "# Auto generated by createConstFile.tcl based on the type library"
puts "# of Word in Office 2007"
puts "#"
puts "# Copyright: 2007-2011 Paul Obermeier (obermeier@poSoft.de)"
puts "# Distributed under BSD license."
puts ""
puts "package provide tcomword 0.4.1"
puts ""
puts "namespace eval ::Word {"

foreach arr [lsort [info vars paul::*]] {
    puts ""
    puts "    # Enumeration [string range $arr $len end]"
    foreach key [lsort [array names $arr *]] {
        set cmd [format "set val \$%s(%s)" $arr $key]
        eval $cmd
        puts "    variable $key $val"
    }
}

puts "}"
exit 0
