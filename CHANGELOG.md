# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

- *With the exception of much older entries, which A) didn't use this convention, and B) have been edited down for brevity since much of the code discussed has been long-gone since before putting the project on github. This more standardized changelog format wasn't followed until 2025-07-10. Anything older than that is a tossup.*


## v10.0.0-beta.1

### Notes

As of 2025-07-11, this is the biggest update in 14 years, possibly 17 (and its first time on github).

Many of the changes involve embracing native Bash v5 idioms, and a higher reliance on native idioms in general - which allowed for simplifying and removing functions.

(But there are still plenty of functions that could/should easily get the axe with little pain or possibly even notice. Possibly even some that were written just for this version.)

Since this script is moving towards more idiomatic standards-compliance anyway, it might as well also move to github, standardized project file structure, and semantic versioning.

### Added

- Added unit testing functions back in [re-created actually], simpler and lighter-weight. [≅2025-07-06 to 11]
- Brought debugging/profiling functions back in from older bigger template branch. (Profiling = tracing code paths, but not counting and timing....yet.) [≅2025-06]
- Added simple suite of generic logging functions. (Rather than refactoring much older more complicated logging code from a many-years-old branch of this template.) Logging is a great candidate for a set of generic functions, as it is frequently needed and can consume a lot of lines of code doing the same thing in every script, often in slightly different ways. [≅2025-06]
- A pretty useful collection of functions to scan a filesystem by one or more specific object types [including broken links], and narrow-down the results with successive passes of include or exclude regex filters. [≅2025-07-01 to 12]
	- This could be - and is - done with simply with `find` and multiple passes of `grep -E`. But these functions wrap that in a reasonably simple, clean, and lightweight way that still makes it worth the effort. In the future it may integrate with a filesystem "records & fields"-based toolset in the works that can deal with things like xattrs, EXIF/XMP, and advanced filenaming (including basing filenames on metadata - *or vice-versa*.)
- Created or added back in from older templates and refactored, several once-discarded functions that were missed. [≅2025-07-06 to 11]
- Added reentrant startup routing back in, this time much simpler and more sane, having learned lessons from previous efforts at "auto-routing" reentrant templates. [≅2025-07-06 to 11]
	- Can now relaunch as any user, not just sudo.
	- The [re]entry and exit points make a lot more sense now.
- Checking for dependencies is now much easier, with dedicated functions. [≅2025-07-10]
	- That themselves, internally, are horribly convoluted in order to create and test fRecord_*() along the way. They could have just been very simple string manipulations.
- Added a HEREDOC section illustrating generic function usage examples. [≅2025-06]
- Added some associative array handling functions, fRecord_* and fAssArr_*. Although conceptually cool in the context of limited Bash, they're probably pretty slow in large loop contexts, so maybe don't use for performance-critical bottlenecks. (Line-delimited strings at best, or multiple arrays with matching integer indexes at worst, is probably the better performance-preserving alternative.)  [≅2025-07-06 to 11]

### Changed

- Improved error-handling [≅2025-07-06 to 11]:
	- `fThrowError()`
		- Now outputs the full relevant call stack.
			- *Now there's no need to add `"${FUNCNAME[0]}"` to every call to `fThrowError()`, yay!*
		- Doesn't necessarily exit, in some cases returns non-0.
		- Error message is simpler and goes to `stderr` rather than `stdout`.
		- Sets global `$_ErrVal` so that the value persists longer (or even at all), for detection/inspection by callers. Although it gets reset when error-handling changes, calling code should set it `=0` before calling something it wants to check afterward.
- Instead of returning boolean values by echo (either integers `0|1` or the even more ancient strings `"true"|"false"`), they do it the bash way: `return 0` for success, `1` for non success, or `>2` for error if possible. [≅2025-07-06 to 11]
	- Functions that modify values (eg trim a string), take a variable *nameref* (e.g. `local -n callerVar=$1`), and update its value in-place. (But within the function, vis-a-vi a temp variable so that the setting of result is atomic only on success, or possibly after an initial setting of default in case of error.)
	- Functions that "return" a value of a fundamentally different type than input (e.g. integer to string date), also take a *nameref* for return value, but also an additional parameter (usually read-only) as input for the value to transform into output.
	- If the function accepts multiple inputs that may be so memory-large that making a copy might be crazy inefficient especially inside a loop, it may accept more than one variable *nameref*.
	- Bash isn't very helpful with error messaging when you forget to provide a *nameref*. So efforts are made to validate *nameref* arguments and throw better errors.
- For fCopyright(), fAbout(), and fSyntax(): Changed back from HEREDOC format to fEcho_Clean. [≅2025-06]
	- HEREDOC, while easier to work with on the surface, is actually too hard for most editors to work with - vis-a-vis mix of tabs and spaces for script-formatting vs output indenting. It's just not worth the constant fuss, unless it's just a big blob of unindented paragraphs.
- Refactored or rewrote at least a dozen existing functions, to be simpler and more bash-idiomatic. [≅2025-06 to 07]
- Renamed most _f*() functions to just f*() for user-fliendliness.
- Moved unit testing out of main template, now 'source' template from testing scripts.
- Modify if necessary to be able to run "sourced" from one or more unit-testing files. (No changes needed.)


### Removed

- Removed or refactored most or all *_byecho() functions. [≅2025-07]
- Moved several low-use functions to an out-of-repo 'extras' script that will probably be forgotten. [≅2025-07-06 to 11]

### Other work

- Unit tested almost all functions. Still a several more to go, but which have all been in literal production for many years. [≅2025-07-06 to 11]


## 20250608
- Added handy and robust _fRemoveOldLogs().

## 20250606-07
- Added _fGetFileSize(), _fTime_EpochAndMS_TruncateMS(), _fGetFileTime_mtime()
- Added _fNormStr() back in.

## 20250319
- Increased argument passing from 20 to 50.
- Added _fAppendStr(), _fPad_Right(), _fBase10to32c(), _fBase10to256j1(), _ConditionalSandwichStr(), _fEchoVals()
- Removed: _fstrAppend_byglobal_val(). ##			- Improved fParseArgs().
- Replaced _fConditionalStr_byecho() with _fTernaryStr(), with different interface.

## 20241024
- Updated fEcho*() related stuff.
-
## 20240928
- Fixed args-string building loop bug in fParseArgs().

## 20240914
- Added some utility functions.

## 20240912
- Improved error output.
- Fixed bug in fThrowError().

## 20240623
- Fixed a bug that added an extra line at end and exited with 1, when showing syntax.

## 20190926
- Added debugging functions and variables: _dbgNestLevel, _dbgIndentEachLevelBy, _fdbgEnter1(), _fdbgEgress1(), _fdbgEcho1(), _fPipeAllRawStdout1()
- Changed everything beginning with "__" to "_"
- Added to the end of every "function(){" statement:
- Begin to change use of "${variable}" to just "$variable" to quicken dev and improve readability.
- Begin use of bash built-in $FUNCNAME.
- Appended "1" to every library function so that:
	- Maintain backward compatibility when copy/pasting everything below a certain line to provide "library" updates to legacy scripts.
- Renamed functions that return something by echo, *_byecho
- Renamed functions that returns something by global variable, *_byglobal

## 20190925
- Added functions:
	fTemplate(), _fUnitTest1(), _fAssert_AreEqual1(), _fAssert_Eval_AreEqual1(), _fStrJustify1_byecho()
	_fdbgEchoVarAndVal1(), _fIndent_relative1(), _fStrKeepLeftN1_byecho(), _fStrKeepRightN1_byecho(), _fToInt1_byecho(), _fIndent_rltv1_pipe()
- Renamed _fIndent1() to _fIndent_abs1_pipe()
- Added routing logic to detect '--unit-test'
- Converted the following functions from modifying named variables, to returning value via echo (due to 'eval' expression causing runtime errors due to unescaped problem characters in output strings):
	_fEscapeStr1_byecho()
	_fNormalizePath1_byecho()
	_fNormalizeDir1_byecho()
- _fstrAppend1_DEPRECATED_byref()
	- Added a message to not use it (so it won't break existing scripts if template code updated).
	- Added _fstrAppend1_byglobal() to use instead.
- Enhanced _fpStrOps_TempReplacements1_byecho(), and _fEscapeStr1_byecho()
- Added an input argument to _fEchoVarAndVal1(): function name.
- Added global constant: doDebug=0.

## 20190925
- Added _fPipe_Blake12_Base64URL(), _fPipe_Uuid_Base164URL()
- Renamed _Indent() to _fIndent_abs1_pipe()

## 20190923
- Converted single brackets to double, for more robusteness, ease of updating to advanced features, and consistency.

## 20190920
- Copied entire contents from ${meName}, which has many improvements to generic & template stuff:
	- Function logic
	- Comments (e.g. function documentation)
	- Expanded argument handling
	- Structure

## 20190917 Slight updates and potential bug fixes.

## 20190911
- Refactor into one simpler template, removing most rarely-used functions, and dozens of other functions that can and should be handled in a more bash-idiomatic way.

## 20171217
	- Ill-fated, short-lived start of 0_library_v3 fork, that was going to refactor most functions to work more
	  consistently, but too non-idiomatically. (E.g. everything would return literal "true", "false", or "error",
	  with useful values returned in named variables.)

## 20171217
	- Forked 0_library_v1 to _v2 (leaving _v1 intact as another 'legacy' library), and:
	- Moved execution logic to library.
	- Fuller use of fPackArgs() and fUnpackArgs().
	- Created unit-testing functions.
	- Created generic logging functionality.

## 20170314
	- Forked to 0_library_v1, leaving now 'legacy' 0_library intact as its referenced by many scripts.
	- Added several regex, math, and hex related functions. As well as fForceUmount(), fIsMounted() fDo_IgnoreError(), fEchoAndDo_IgnoreError().

## 20161003
	- Created 'fPackedArgs*()' functions to solve the problem of quoted arguments getting unquoted with multiple passes among programs and scripts (especially sh, with its limited number of directly [non-shift] addressable args).

#
---


## 20190921
- Added virtualization detection, and video driver detection.

## 20160925
- Moved some bare-bones necessary code out of 0_library back to here.

## 20160922
- First version of separate '0_library' script, that this template sources. Most functions moved there.

## 20160913
- Minor additions and fixes.

## 20160907

## 20160905

## 20160831

## 20160830

## 20160827

## 20160725

## 20150925

## 20150504
- Added fRunForked(), fRunForked_AndLog(), fDoAsync_AndLog().

## 20141103
- Added fEchoOrEchoAndDo(), fEchoOrEchoAndDo_IgnoreError(), fStrIndentAllLines().

## 20141103
- Minor fixes.

## 20141011
- Minor fixes.

## 20141002
- Minor fixes.

## 20140624
- Added some filesystem functions.

## 20140615
- Added a few string-handling functions.

## 20140519
- Better error-handling.

## 20140304
- Bug fixes and cleanup.

## 20140224
- Bug fixes and a few new functions.

## 20140206-19
- Added about a dozen functions.

## 20140129
- Minor bug fixes

## 20130422

## 20121213
- Major update with initial execution moved into 0_library.

## 20121213
- Added custom error traps.

## 20120908
- Moved generic constants, variables, and functions to 0_jclibrary001-v001.

## 20120822
- Minor fixes.

## 20110506 First official version.
- Added logic to execute arbitrary subroutine as sudo, without necessarily setting cgtbProfile flag.
- Added profiling of functions here, since removed from execution engine and exit handler.
