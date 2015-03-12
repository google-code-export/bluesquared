# Introduction #

Program wide variables are typically read-only, and should only be changed in one place. The Options window.


## Arrays ##

### Program ###
Program specific values<br>
<b><code>program(currentModule)</code></b>
<blockquote>Allows the program to open up at the last window. (eg Addresses)</blockquote>

<b><code>program(Version)</code></b>
<blockquote>Major version number (eg 4)</blockquote>

<b><code>program(PatchLevel)</code></b>
<blockquote>Minor numbers (eg 0.1)</blockquote>

<b><code>program(beta)</code></b>
<blockquote>Value should be Beta or Alpha (eg Alpha)</blockquote>

<h3>Settings</h3>

<b><code>settings(Home)</code></b>
<blockquote>The path to where the application resides</blockquote>

<b><code>settings(outFilePath)</code></b>
<blockquote>Path to where we save the formatted Import File</blockquote>

<b><code>settings(outFilePathCopy)</code></b>
<blockquote>Path to where we save the backup/archive Import File</blockquote>

<b><code>settings(sourceFiles)</code></b>
<blockquote>Path to where we read in the source import files. Which are the files we see before we format them.</blockquote>

<b><code>settings(BoxTareWeight)</code></b>
<blockquote>Default for the tare weight of the boxes. Theoretically we will not have to change this.