# INCOMPLETE #

# Hooking into the API #
Each package name should contain the following prefix:
`eAssist_`

Each package must set these variables within the `desc` and `emailEvent` arrays. The Variable in the array should use the package name, minus the prefix.

  * `set desc(ModBoxLabels) [mc "Box Labels"]`
  * `set emailEvent(ModBoxLabels) [list Print "Print BreakDown"]`

This will populate the Email Setup page within Setup.

# Using the API within your package #