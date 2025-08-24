# To-do

## WIP

| Created  | Issue# |Pri|Effort| Started  | by | Completed | Description | Notes |
|----------|--------|---|------|----------|----|-----------|-------------|-------|
| 20250823 |        | 1 |      |          |    |           | fIsNum(): Don't call __pGetX_common(). | It's causing recursive calls into __pGetX_common(), which errors with re-use of fIsNum ref variable.
| 20250823 |        | 1 |      |          |    |           | fIsInt(): Don't call __pGetX_common(). | It's causing recursive calls into __pGetX_common(), which errors with re-use of fIsNum ref variable.
| 20250823 |        | 1 |      |          |    |           | fGetFormattedNum(): Don't rely on fIsNum() calling __pGetX_common().
| 20250711 |        | 1 |  1   |          |    |           | Finish `fTimer_*()` functions. | Blocked by some math functions which are now done.
| 20250711 |        | 1 |  1   |          |    |           | Finish `fFilesys_*()` functions. | Blocked by `fTimer_*()`.
| 20250716 |        | 1 |  3   |          |    |           | Finish `fFormatNum()`
| 20250716 |        | 1 |  2   |          |    |           | Update `fTimer_GetET()` to use fFormatNum().
| 20250716 |        | 1 |  3   |          |    |           | Add `fUnitTest_TimeFunction()` (all in-line). | Args <avgETVar> [stdDevVar] [loopIterations] [runCount]
| 20250711 |        | 2 |  2   |          |    |           | Write basic `fArrayFromStr()` | Std safe syntax is convoluted just enough, and done frequently enough, to justify. Use *nameref* vars.
| 20250711 |        | 2 |  2   |          |    |           | Write basic `fArrayFromFile()`
| 20250711 |        | 2 |  2   |          |    |           | Write basic `fArrayToStr()`
| 20250715 |        | 1 |  3   |          |    |           | Finish unit tests, for 100% coverage.
| 20250815 |        |   |      |          |    |           | fPerseArgs(): Make fully generic, by calling out user-specific subroutines for unary flags, options, and positional args.
| 20250815 |        |   |      |          |    |           | fPerseArgs(): Option args: Allow `=` as a delimiter, not just space[s], except options that can be flags or options (only `=` in that case).
| 20250815 |        |   |      |          |    |           | Add automatic processing of some common args. | E.g. `--verbose[=true]`, `--quiet[=true]`, and `--[inc*\|exc*][-[regx\|regex][=]"arg"`
| 20250815 |        |   |      |          |    |           | Add automatic handling of `--[inc*\|exc*][-[regx\|regex][=]"arg"` to be passed to file-filtering function.
| 20250815 |        |   |      |          |    |           | Add functions to allow adding to a 'search and replace' associative array, and to run it on all elements of an array.
| 20250815 |        |   |      |          |    |           | Rename the `x9` part. 'X' has been ruined as a toxic brand symbol. | Should be easy to type on qwerty and popular layouts, and 'say' something with unambiguous characters. Ideas: i1 **u1** d2 **o2** **r2** **s2** u2 **b4** c3 d8 **f8** g8 j8 m8 pl8 sm8 st8 u8 y8 u9. r2 wouldn't be sued over, o2 h2 probably could be.
| 20250815 |        |   |      |          |    |           | Split template out into two temporary parts: template and semantic-versioned library. | E.g. `bash5-template.sh` and `x9lib_v1`.
| 20250711 |        | 2 |  2   | 20250706 | JC |           | For *nameref* variables, provide checking and error messages. | Eg: `[[ -v $1 ]] \|\| fThrowError "${errMissingRef_Alter_AssocArray}"`
| 20250715 |        | 1 |  4   |          |    |           | Provide Bash-style default arguments for function arguments, and refactor custom defaults if appropriate.
| 20250715 |        | 2 |  2   | 20250706 | JC |           | For functions with other required arguments, make sure they have error messages for empty.
| 20250715 |        | 2 |  3   |          |    |           | Performance: Replace `sed` commands with Bash variable string manipulation wherever possible.
| 20250715 |        | 2 |  3   |          |    |           | Performance: For what's left, group adjacent `sed` commands into one.
| 20250715 |        | 2 |  3   |          |    |           | Performance: Avoid unnecessary use of e.g. 'true' and ':' (subprocces), and unit test all.
| 20250715 |        | 2 |  3   |          |    |           | Performance: Reduce use of `grep`
| 20250715 |        | 2 |  4   |          |    |           | Performance: Reduce use of `awk`
| 20250715 |        | 2 |  4   |          |    |           | Performance: Reduce use of piped commands
| 20250715 |        | 2 |  4   |          |    |           | Performance: Reduce use of command substitution, `$(...)`
| 20250715 |        | 2 |  4   |          |    |           | Performance: Reduce use of process substitution, `<(...)`
| 20250715 |        | 3 |  2   |          |    |           | Always use double brackets rather than single
| 20250711 |        | 1 |  3   | 20250706 | JC |           | Make sure generic functions observe remaining performance guidelines from bash5 guide, and document intentional exceptions.
| 20250711 |        | 1 |  3   | 20250706 | JC |           | Make sure entire template observes style guidelines from bash5 guide, and document intentional exceptions.
| 20250711 |        | 4 |  4   | 20250706 | JC |           | Make sure each function has a group or individual header.
| 20250711 |        | 4 |  4   | 20250706 | JC |           | Make sure each function has arg comments | E.g. `Arg <REQUIRED>\|[optional]: Description`.
| 20250711 |        | 3 |  4   | 20250706 | JC |           | Make sure each function has an entry under "Generic function usage examples".
| 20250715 |        | 4 |  2   |          |    |           | Add functions that 'safe-escape' and de-safe-escape' strings. (de-`sed`ed)
| 20250712 |        | 3 |  3   |          |    |           | Write `fAA_DeleteByRegex()` | Delete array elements by: Convert whole array to text, delete array, use `grep -E` to filter out text lines, recreate array from text.
| 20250711 |        | 4 |  4   |          |    |           | Write `fAA_FilterToSubAA()`, `fAA_AppendFromSubAA()` | Two-way between an associative array[s], and subset[s] minus a dimension from the key.
| 20250711 |        | 5 |  3   |          |    |           | Write `fAssArr_GetSubAssArr_byIdx()` | A `fAssArr_*()` abstraction of `fAA_FilterToSubAA()`.
| 20250711 |        | 5 |  3   |          |    |           | Write `fAssArr_SetSubAssArr_byIdx()` | A `fAssArr_*()` abstraction of `fAA_AppendFromSubAA()`.
| 20250711 |        | 5 |  2   |          |    |           | Write `fAssArr_Delete_Idx()` | A `fAssArr_*()` abstraction of `fAA_DeleteByRegex()`. Delete array elements based on idx.
| 20250711 |        | 5 |  5   |          |    |           | Integrate [Bats](https://github.com/sstephenson/bats) for unit testing, rather than own lightweight framework. | In the spirit of greater standardization.
| 20250712 |        | 5 |  5   |          |    |           | Add automatic count and timing of code paths to profiling.
| 20250711 |        | 2 |  5   |          |    |           | Stop using Bash for shell scripting and use something like Ksh, [PowerShell core](https://github.com/PowerShell/PowerShell), [Deno](https://deno.com/) (TS/JS), [Xonsh](https://xon.sh/contents.html) (Python), [Groovy](https://www.groovy-lang.org/) (Java), [Nushell](https://www.nushell.sh/book/scripts.html), [YSH](https://oils.pub/ysh.html), or Go with shell helper modules. | This template may always be relevant for smaller tasks and tools that will run on any distro with no depencies. The change would be for bigger projects where interactive debugging and strong typing would help, and/or where Bash performance is just too slow (e.g. long-running nested loops with floating-point math). Probably Go, definitely not Python. (See [comparison document](https://github.com/jim-collier/x9bash5-template/blob/main/Shell%20script%20comparison.md)).
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
