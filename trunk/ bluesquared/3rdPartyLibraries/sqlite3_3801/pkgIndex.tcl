#
# Tcl package index file
#
# Note sqlite*3* init specifically
#
package ifneeded sqlite3 3.8.0.1 \
    [list load [file join $dir sqlite3801.dll] Sqlite3]
