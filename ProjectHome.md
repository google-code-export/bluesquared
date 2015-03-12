# Efficiency Assist #
**Status**: Beta

_EA_ is a suite of modules meant to be used before using EFI Planner, or Seagull Scientific's BarTender. Essentially, it is used for pre-processing data.

The individual modules are:

  1. Setup
  1. Batch Maker (_EFI Planner_ and _EFI Process Shipper_)
  1. Box Labels (Seagull Scientific's _BarTender_)


---


### Setup ###
**Started**: _Fall 2013_

**Status**: _Stable_

Contains all setup configurations. This only holds what should be setup for ALL users. The individual settings are within the preferences, in their respective module.

The settings are currently held in a txt file, but is in the process of being put into a SQLite db.


---


### Batch Maker ###
**Started**: _Fall 2013_

**Status**: _Beta_

Formats a file to be imported into EFI's _Planner_ software or EFI's _Process Shipper_

With this module you can import a .csv file, apply some filters that fix your addresses to be closer to standard (i.e. abbreviates common spellings per USPS guidelines). Allows the user to insert _Planner_ required data, such as:
  * Distribution Type
  * Shipping Class
  * Order Number (This happens automatically upon export of the file)
  * And more!


---


### Box Labels ###
**Started**: _2005 (Approx.)_

**Status**: _Stable_

A front end to BarTender (a commercial label application), the BlueSquared Box Label application accepts up to 5 lines of text, max quantity per box and each quantity per destination.


---


# OUT DATED #
### Distribution Helper ###
**UPDATE** This was merged with Batch Creator, to make _Batch Maker_
**Started**: _Fall 2013_

**Status**: _Alpha_

Imports a .csv file, ability to apply some filters to standardize addresses. Allows the user to assign Distribution Type, Freight Carrier. Specify amount of samples, and per version.


---


### Batch Creator ###
**UPDATE** This was merged with Distribution Helper, to make _Batch Maker_
**Started**: _Spring 2011_

**Status**: _Stable_

This imports a .csv file into a layout window, where the user assigns each value to the position where it should be for an address. It then generates a file which is formatted to be imported into shipping software.

Currently the position of the elements are hard-coded in the 'out file'.