The source file has to come from somewhere, and we will need minimal formatting so that DH will know what to do with it.

# Introduction #
The distribution personnel will create the source file, which ultimately will be used by DH to generate the final import file, used by the shipping software

# Details #
To make things easier, DH will automatically know what each column is if we assign a header row. This will make it much easier and faster for the shipping personnel and it really isn't that much more work for the distribution personnel.

## Headers ##
  * Ship Via (The code which the shipping software uses for knowing how it ships
  * Company (Company Name)
  * Consignee ( Attention To:)
  * Address1 (Main street address)
  * Address2 (Optional: Suite Number / Floor)
  * Address3 (Optional: Building Number, etc)
  * City
  * State
  * Zip
  * Phone
  * Quantity (Shipment Quantity)
  * Version (Optional: Name of the version, i.e. V1, V2)
  * Ship Date (Optional: Not used yet, but will be used for creating one or more final import files from one source file)