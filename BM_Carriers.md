#Carriers and the setup to detect the cheapest method. Should also aid in expected delivery date.

# Introduction #

Currently it is time consuming to figure out the best way to ship product. The destination could be in remote locations, or in other countries which could also be in a remote location.


# Details #

UPS should be the first carrier to add, as the information needed is readily available.

The following items will need to be imported (or typed) into EA.
**UPS Zones** UPS Rates based on ship method (this will tie into the Ship Via methods)
**UPS Fuel Surcharge**

The next carriers to be added should be:
**Soniq (so we can compare them to UPS)** Oak Harbor
**Peninsula**

**UPS Fuel Surchage** The implementation of this, should have two fields. The current fuel surchage percent, another field and a date selector to specify when that should take effect.

|Description|Percent|Effective|
|:----------|:------|:--------|
|Current Fuel Surcharge|7.5|  |
|Future Fuel Surcharge|8.0|July 1st|

Once July 1st arrives, the 8.0 should be moved up to Current Fuel Surcharge, two weeks later we should alert the user that the next fuel surcharge amount should be loaded into EA.