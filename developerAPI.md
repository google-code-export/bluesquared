# API #

API for modules communicating with Core.
<br>
<ol><li><a href='developerAPI#Setup_API.md'>developerAPI#Setup_API</a>
</li><li><a href='developerAPI#Update_API.md'>developerAPI#Update_API</a>
</li><li><a href='developerAPI#Loadscripts_API.md'>developerAPI#Loadscripts_API</a>
</li><li><a href='developerAPI#MailManager_API.md'>developerAPI#MailManager_API</a></li></ol>


<h2>Setup_API</h2>
Commands that allow Core to know if the active module needs to be Setup before it can be used.<br>
<br>
Each package adds variables to the <code>setup()</code> array, within the <code>namespace eval</code> proc, such as:<br>
<pre><code>namespace eval eAssistSetup {<br>
    global setup<br>
   set setup($packageName,&lt;identifier&gt;) &lt;value&gt;<br>
}<br>
</code></pre>

To determine if we require a setup before using, each package should use this syntax<br>
<pre><code>setup($packageName,setupReqd) &lt;yes/no&gt;<br>
</code></pre>

That way we can create a <code>proc</code> to look at those variables, to determine if we need to process it further. Such as looking to see if the setup on it has been complete or not.<br>
<br>
Once setup has been <b>completed</b> lets issue another variable<br>
<br>
NOTE: When saving, cycle through all listed 'required' variables, and if they are all set, then set the 'setupComplete' variable to yes. See <a href='https://code.google.com/p/bluesquared/issues/detail?id=90'>issue 90</a>
<pre><code>set setup($packageName,setupComplete) &lt;yes/no&gt;<br>
</code></pre>

Using the <b><code>package</code></b> command, we can figure out what packages are loaded. Then, filter on the <b><code>eAssist_</code></b> keyword that we use to prefix all of the project-centric packages.<br>
<br>
<pre><code>foreach value [package names] {<br>
    if {[string match eAssist_* $value] == 1} {<br>
        puts $value<br>
        }<br>
}<br>
</code></pre>

<h3>Variables for Setup_API</h3>
<pre><code>setup($packageName,setupReqd) &lt;yes/no&gt;<br>
setup($packageName,setupComplete)&lt;yes/no&gt;<br>
</code></pre>


<h2>Update_API</h2>

Check for updates; update program when new versions are available.<br>
Possible features:<br>
<ol><li>Setup: Disable/Enable Auto-Update<br>
</li><li>Setup: Always check automatically for newer versions, notification always appears here.<br>
</li><li>Setup: Download (Button)</li></ol>

<h2>Filter_API</h2>

Filtering the data, could mean removing any periods or commas in a cell. We should allow the user to create their own. Requirements would be:<br>
<ol><li>Select columns for the filter to act on<br>
</li><li>Allow the user to select what to filter out<br>
</li></ol><ul><li>Commas<br>
</li><li>Hyphens<br>
</li><li>Forward/Back Slashes<br>
</li><li>High ASCII<br>
</li><li>User editable</li></ul>

<h2>Loadscripts_API</h2>

See <a href='https://code.google.com/p/bluesquared/issues/detail?id=99'>Issue 99</a>
<br>Allow the possibility to load scripts/packages from within EA, instead of hard-coding it.<br>
<br>
This should be in Setup, because we won't want the user to mess with this; for the most part.<br>
<br>
If we require the scripts to be in the common Package format, zipped up. We should be able to just Plug N Play. With the ability to see EVERY package in Setup, and load only those that we want.<br>
<br>
<h2>MailManager_API</h2>

See <a href='https://code.google.com/p/bluesquared/issues/detail?id=100'>Issue 100</a>
<br>Export our massaged file to MailManager, have it run TaskMaster to CASS and send out for NCOA, once it returns, export it to a file.<br>
<br>
EA should be watching, to alert the user when it has returned and that they can continue processing.