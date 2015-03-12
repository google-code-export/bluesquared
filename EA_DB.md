# Retrieving Data from joined tables #

**Retrieve Subheaders**

Query statement for retrieving secondary header names

```
SELECT SubHeaderName 
from SubHeaders 
left outer join Headers 
on SubHeaders.HeaderID = Headers.Header_ID 
where HeaderName='Company'
```


**Modules and Events Associated with them**

Retrieve the EventNotifications associated with the _Box Labels_ module.

```
SELECT EventName
  FROM EventNotifications
       LEFT OUTER JOIN Modules
                    ON EventNotifications.ModID = Modules.Mod_ID
 WHERE ModuleName = 'Box Labels';
```