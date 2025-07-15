# To-do

## WIP

| Created  | Issue# |Pri|Effort| Started  | by | Completed | Description | Notes |
|----------|--------|---|------|----------|----|-----------|-------------|-------|
| 20250711 |        | 5 |  1   |          |    |           | Finish `fTimer_*()` functions. | Blocked by some math functions which are now done.
| 20250711 |        | 5 |  1   |          |    |           | Finish `fFilesys_*()` functions. | Blocked by `fTimer_*()`.
| 20250715 |        | 5 |  3   |          |    |           | Finish unit tests, for 100% coverage.
| 20250711 |        | 4 |  2   | 20250706 | JC |           | For *nameref* variables, provide checking and error messages. | Eg: `[[ -v $1 ]] \|\| fThrowError "${errMissingRef_Alter_AssocArray}"`
| 20250715 |        | 5 |  4   |          |    |           | Provide Bash-style default arguments for function arguments.
| 20250715 |        | 4 |  2   | 20250706 | JC |           | For functions with other required arguments, make sure they have error messages for empty.
| 20250711 |        | 4 |  2   |          |    |           | Write `fArrayFromStr()` etc. | Std safe syntax is convoluted just enough, and done frequently enough, to justify. Use *nameref* vars.
| 20250715 |        | 3 |  3   |          |    |           | Add functions that 'safe-escape' and de-safe-escape' strings. (de-`sed`ed)
| 20250715 |        | 4 |  3   |          |    |           | Performance: Replace `sed` commands with Bash variable string manipulation wherever possible.
| 20250715 |        | 4 |  3   |          |    |           | Performance: For what's left, group adjacent `sed` commands into one.
| 20250715 |        | 4 |  3   |          |    |           | Performance: Avoid unnecessary use of e.g. 'true' and ':' (subprocces), and unit test all.
| 20250715 |        | 4 |  3   |          |    |           | Performance: Reduce use of `grep`
| 20250715 |        | 4 |  4   |          |    |           | Performance: Reduce use of `awk`
| 20250715 |        | 4 |  4   |          |    |           | Performance: Reduce use of piped commands
| 20250715 |        | 4 |  4   |          |    |           | Performance: Reduce use of command substitution, `$(...)`
| 20250715 |        | 4 |  4   |          |    |           | Performance: Reduce use of process substitution, `<(...)`
| 20250715 |        | 3 |  2   |          |    |           | Always use double brackets rather than single
| 20250715 |        | 3 |  2   |          |    |           | For ternary operators with braces
| 20250711 |        | 5 |  3   | 20250706 | JC |           | Make sure generic functions observe remaining performance guidelines from bash5 guide, and document intentional exceptions.
| 20250711 |        | 5 |  3   | 20250706 | JC |           | Make sure entire template observes style guidelines from bash5 guide, and document intentional exceptions.
| 20250711 |        | 2 |  4   | 20250706 | JC |           | Make sure each function has a group or individual header.
| 20250711 |        | 2 |  4   | 20250706 | JC |           | Make sure each function has arg comments | E.g. `Arg <REQUIRED>\|[optional]: Description`.
| 20250711 |        | 3 |  4   | 20250706 | JC |           | Make sure each function has an entry under "Generic function usage examples".
| 20250712 |        | 3 |  3   |          |    |           | Write `fAA_DeleteByRegex()` | Delete array elements by: Convert whole array to text, delete array, use `grep -E` to filter out text lines, recreate array from text.
| 20250711 |        | 2 |  4   |          |    |           | Write `fAA_FilterToSubAA()`, `fAA_AppendFromSubAA()` | Two-way between an associative array[s], and subset[s] minus a dimension from the key.
| 20250711 |        | 1 |  3   |          |    |           | Write `fAssArr_GetSubAssArr_byIdx()` | A `fAssArr_*()` abstraction of `fAA_FilterToSubAA()`.
| 20250711 |        | 1 |  3   |          |    |           | Write `fAssArr_SetSubAssArr_byIdx()` | A `fAssArr_*()` abstraction of `fAA_AppendFromSubAA()`.
| 20250711 |        | 1 |  2   |          |    |           | Write `fAssArr_Delete_Idx()` | A `fAssArr_*()` abstraction of `fAA_DeleteByRegex()`. Delete array elements based on idx.
| 20250711 |        | 1 |  5   |          |    |           | Integrate [Bats](https://github.com/sstephenson/bats) for unit testing, rather than own lightweight framework. | In the spirit of greater standardization.
| 20250712 |        | 1 |  5   |          |    |           | Add automatic count and timing of code paths to profiling.
| 20250711 |        | 4 |  5   |          |    |           | Stop using Bash for shell scripting and use something like Ksh, [PowerShell core](https://github.com/PowerShell/PowerShell), [Deno](https://deno.com/) (TS/JS), [Xonsh](https://xon.sh/contents.html) (Python), [Groovy](https://www.groovy-lang.org/) (Java), [Nushell](https://www.nushell.sh/book/scripts.html), [YSH](https://oils.pub/ysh.html), or Go with shell helper modules. | This template may always be relevant for smaller tasks and tools that will run on any distro with no depencies. The change would be for bigger projects where interactive debugging and strong typing would help, and/or where Bash performance is just too slow (e.g. long-running nested loops with floating-point math). Probably Go, definitely not Python. (See [comparison document](https://github.com/jim-collier/x9bash5-template/blob/main/Shell%20script%20comparison.md)).
<!--                                                       |
| 2025MMDD |        |   |      |          |    |           |
-->


## Canceled, moot

| Created  | Issue# |Pri|Effort| Started  | by | Completed | Description | Notes |
|----------|--------|---|------|----------|----|-----------|-------------|-------|
| 20250711 |        | 3 |  4   |          |    |           | Refactor from `set -e` to `set +e`, and re-run unit tests. | `set -e` is OK with `set -E; set -o pipefail; shopt -s inherit_errexit`


## Done

| Created  | Issue# |Pri|Effort| Started  | by | Completed | Description | Notes |
|----------|--------|---|------|----------|----|-----------|-------------|-------|
| 20250711 |        | 4 |      | 20250713 | JC | 20250713  | Modify if necessary to be able to run "sourced" from one or more unit-testing files.
| 20250711 |        | 4 |      | 20250713 | JC | 20250713  | Move unit testing out of main template.
| 20250713 |        | 2 |      | 20250713 | JC | 20250713  | Rename most _f*() functions to just f*() for user-fliendliness.
| 20250715 |        |   |  2   |          |    |           | `set -u; set -o pipefail; shopt -s inherit_errexit \|\| true`, and re-run unit tests.
