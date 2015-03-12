Basic information on helping you get started with Distribution Help

# Introduction #
Installation of DH currently consists of downloading the .exe file and running it. The defaults assumes that DH is located in its own folder, in the same folder where the source files (imports) are kept.

# Importing a File #
Once DH is opened, there are two ways to bring in an source file.
# Go to File > Import File
# Type the Job Number in the entry field and hit the Enter Key, or press the "Import File" Button.

If the file has headers, DH will try to assign the value to the correct entry field.

If the file does **not** have headers, you will have to drag and drop the values listed in the listbox, to the correct entry field.

# User defined #
Once the data from the file is assigned, you **must** enter a piece weight (The weight on one book). DH requires that you enter two digits after the decimal, the hundredths. If the books' weight is in the thousandths, please use that. The more accurate you are, the better.

The 2nd required field is the maximum quantity per box. DH uses this value to figure out how many boxes are in each shipment, and how many books the last box has in it.

**<sup>currently not implemented, but will be in the future, DH will not even allow you to generate the file if a required field is not filled in. And the required field will be colored red to bring attention to it</sup>**

# Generating the Import File #
Once all the fields are filled out, you may generate the import file by pressing the "Generate File" button. This will save a copy in the default folder, and a copy in the default "Archive" folder.

