Receipt Maker's global variables

# Introduction #

A list of useful global variables currently used


### Profile ###
This is the global array that will hold all the useful information per profile

**_General_**
  * profile(Store) - Name of the profile/store name

**_Printing_**
  * profile($profile(Store),bodySize) - Body Font Size
  * profile($profile(Store),date\_pos1) - Date Position (Top/Bottom)
  * profile($profile(Store),date\_pos2) - Date Position (Left/Center/Right)
  * profile($profile(Store),date\_size) - Date Size (Large/Medium/Small)
  * profile($profile(Store),taxFood) - Food on tax (optional)
  * profile($profile(Store),taxOther) - Food on other items (optional)
  * profile($profile(Store),$row,htext) - Header Text
  * profile($profile(Store),$row,hpos) - Header Position (Left/Center/Right)
  * profile($profile(Store),$row,hsize) - Header Size (Large/Medium/Small)
  * profile($profile(Store),$row,hspacing) - Header line spacing (Single/Double)

**_Purchased Lists_**
  * **_deprecated_** purchased(Name) - textvariable for combobox in (Purchased List Editor) - Holds the name of the list
  * purchased($purchased(Name),$row,item) - Item
  * purchased($purchased(Name),$row,price)- Price
  * purchased($purchased(Name),$row,tax) - Tax (Food/Other/None)


---


### Program ###
Global array that holds program specific information

**_Program Related_**
  * program(Name) - Name of the program
  * program(Version) - Version of the program
  * program(fileGateway) - Values will either be -create or -rename. This is used for the New Profile/Purchased List. It is dependent on if the combobox and checkbutton are Normal state.


**_Paths_**
  * program(Path) - Path where program is located
  * program(Profiles) - Path where profiles are located
  * program(PCL) - Path where purchased lists are located
  * program(Settings) - Path where settings.txt lives

**_General_**
  * program(profileList) - contains a list of available Profiles
  * program(purchasedList) - list of available Purchased Lists
  * program(newName) - Holds the name of a new Purchased List or Profile