# Efficiency Assist - 4.0 #

See [issue 86](https://code.google.com/p/bluesquared/issues/detail?id=86) for the associated issues with this release.

# OVERVIEW #

This release encompasses two existing programs into modules, and creating more as needed.

# [Setup](Setup.md) #
The setup module allows us to configure each module within one area. Everything configured here is used globally.

# Labels #
This module is essentially a front-end to BarTender by passing basic commands to it via the command line options.

# Distribution #
Allows you to import a file (headers required), by mapping the source headers to the program headers. Once imported, you can do several things with it, such as: Quickly identify which fields exceed preset character length limitations, assign "Distribution Types", shipment method, assign samples per version.

It also offers to modes, the first is the most common. Which lists shipments by destination. The second, lists all destinations once per version, and only shows one version at a time.

# BatchMaker #
Was named UPS Imports; this will import files as needed. Allow you to specify piece weight, full box, ship date. This will export a formatted file to import into the shipping system.



---

This release will contain all addresses in a database. You will open the file, assign values to the correct fields (all except pieceweight, fullbox),  and “import” it into the program.

Once imported, will then be able to assign pieceweights, fullbox qty’s and other shipment specific information.

The person generating the batch, will type in the job number, which will bring up statistics of the addresses (i.e. total count, total destinations, by version), and if there are multiple ship dates, it will give you the opportunity to select a specific ship date, or select all.

Once you have a the Batch Creator open, you can modify the day it ships (which will affect the scheduler), insert pieceweights and fullbox qty’s per version.

  * Must have the ability to search on old jobs (customer, description, number) to retrieve historical information. Mainly pieceweight, qty per box

  * Create Box Labels
This will roll the current Box Label program into EA to make one uniform package. The benefits to this are:
  1. No more hand entering shipment qty's on large jobs
  1. Only required to enter FullBox qty's on jobs in EA.
  1. All other jobs that require labels, and are NOT in EA, will function normally. Meaning, how the labels are created now will not change.
  1. The ability to print out reports (ups vs freight, and shipment level). This will require slightly more data input.



---

**[IMPORT](Import_EA.md)**
Import correctly formatted files into EA. So that the user can perform sanitizing rules on it; to make it ready to produce a batch file for the shipping system or label creating software.

**[DATABASE](Database_EA.md)**
Will hold all job specific information, along with customer and shipment data.

**[EDIT DB](EditDB_EA.md)**
Edit the DB

**[SCHEDULER](Scheduler_EA.md)**
This will list all known imports for a given date range; you should be able to edit the ship date, if it changes directly from here.

**[BATCH CREATOR](BatchCreator_EA.md)**
Main window that the batch import maker will use.
You will enter the job number and it will bring up statistics on that particular job, along with the ability to enter FullBox/Pieceweight etc, by version. And finally able to hit “generate” to create a batch import file.

**[BOX LABELS](Boxlabels_EA.md)**
Allow the user to enter the correct information for the label, and individual shipment quantities.

**[OPTIONS](Options_EA.md)**
Set the file paths to various folders or programs.

**[PREFERENCES](Preferences_EA.md)**
Set global wide options. This will affect everyone who opens the software.