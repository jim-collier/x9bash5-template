# To-do

## WIP

| Created     | Issue# |Pri| Started     | by  | Completed     | Description | Notes |
|-------------|--------|---|-------------|-----|---------------|-------------|-------|
| 20250711    |        | 5 |             |     |               | Finish fTimer_*() functions. | Blocked by some math functions which are now done.
| 20250711    |        | 5 | 20250706    | JC  |               | Finish fFilesys_*() functions. | Blocked by fTimer_*().
| 20250711    |        | 3 | 20250706    | JC  |               | For most generic functions, detect missing use of *nameref* variables by calling functions - for wich native Bash gives a cryptic, useless error message. | Eg: `[[ -v $1 ]] \|\| fThrowError "${errMissingRef_Alter_AssocArray}"`
| 20250711    |        | 2 | 20250706    | JC  |               | Make sure each function has a group or individual header.
| 20250711    |        | 2 | 20250706    | JC  |               | Make sure each function make sure arguments are commented.
| 20250711    |        | 2 | 20250706    | JC  |               | Make sure each function has arg comments | E.g. `Arg <REQUIRED>\|[optional]: Description`.
| 20250711    |        | 3 | 20250706    | JC  |               | Make sure each function has an entry under "Generic function usage examples".
| 20250711    |        | 4 |             |     |               | Write `fArrayFromStr()` etc. | Std safe syntax is convoluted just enough, and done frequently enough, to justify. Use *nameref* vars.
| 20250712    |        | 3 |             |     |               | Write `fAA_DeleteByRegex()` | Delete array elements by: Convert whole array to text, delete array, use `grep -E` to filter out text lines, recreate array from text.
| 20250711    |        | 2 |             |     |               | Write `fAA_FilterToSubAA()`, `fAA_AppendFromSubAA()` | Two-way between an associative array[s], and subset[s] minus a dimension from the key.
| 20250711    |        | 1 |             |     |               | Write `fAssArr_GetSubAssArr_byIdx()` | A `fAssArr_*()` abstraction of `fAA_FilterToSubAA()`.
| 20250711    |        | 1 |             |     |               | Write `fAssArr_SetSubAssArr_byIdx()` | A `fAssArr_*()` abstraction of `fAA_AppendFromSubAA()`.
| 20250711    |        | 1 |             |     |               | Write `fAssArr_Delete_Idx()` | A `fAssArr_*()` abstraction of `fAA_DeleteByRegex()`. Delete array elements based on idx.
| 20250711    |        | 1 |             |     |               | Integrate [Bats](https://github.com/sstephenson/bats) for unit testing, rather than own lightweight framework. | In the spirit of greater standardization.
| 20250712    |        | 1 |             |     |               | Add automatic timing of code paths to profiling.
| 20250711    |        | 4 |             |     |               | Stop using Bash for shell scripting and use something like Ksh, [PowerShell core](https://github.com/PowerShell/PowerShell), [Deno](https://deno.com/) (TS/JS), [Xonsh](https://xon.sh/contents.html) (Python), [Groovy](https://www.groovy-lang.org/) (Java), [Nushell](https://www.nushell.sh/book/scripts.html), [YSH](https://oils.pub/ysh.html), or Go with shell helper modules. | This template may always be relevant for smaller tasks and tools that will run on any distro with no depencies. The change would be for bigger projects where interactive debugging and strong typing would help, and/or where Bash performance is just too slow (e.g. long-running nested loops with floating-point math). Probably Go, definitely not Python. (See dedicated comparison document).

<!--
| 20250711    |        |   |             |     |               |
-->

## Done

| Created     | Issue# |Pri| Started     | by  | Completed     | Description | Notes |
|-------------|--------|---|-------------|-----|---------------|-------------|-------|
| 20250711    |        | 4 | 20250713    | JC  | 20250713      | Modify if necessary to be able to run "sourced" from one or more unit-testing files.
| 20250711    |        | 4 | 20250713    | JC  | 20250713      | Move unit testing out of main template.
| 20250713    |        | 2 | 20250713    | JC  | 20250713      | Rename most _f*() functions to just f*() for user-fliendliness.


## Canceled, moot

| Created     | Issue# |Pri| Started     | by  | Completed     | Description | Notes |
|-------------|--------|---|-------------|-----|---------------|-------------|-------|
