Setup of Email will be in its own designated section, called _EmailSetup_

This window will contain multiple tabs:
**Email Setup**
  * configure the server, port, TLS if using etc.


**Email Notification**
The events are populated based on what version has been selected.
  * Select Module, and disable/enable email notifications for the entire module
  * Select Email Event, and disable/enable email notifications for the event.
  * Email tips for available macros will change depending on what Module/Event has been selected.
  * Configure who we are sending the email to and from.
  * Create the subject and body of email.


## Mappings ##

Tied to each even is the ability to map generated data; for instance, how many box labels were created; could be inserted into the body of the email by using a macro.

Using `%b` to insert the break down. We could construct the body of the email like:
```
This is a system generated message, please see the details below:

%b
```

Upon receiving it we would see:

```
This is a system generated message, please see the details below:

Portland Monthly
August
Version 2

45 @ 50
3 @ 15
```

### Macro Creation ###

The macro should be created by using [String Map](http://www.tcl.tk/man/tcl8.6/TclCmd/string.htm#M34)

**Example**

**Note** We must use double-quotes since we need variable substitution to happen, otherwise we would use curly braces.
set myTxt {
Portland Monthly
August
Version 2

45 @ 50
3 @ 15}

set myString {This is a system generated message, please see the details below:

%b}

string map "%b [list $myTxt]" $myString
```