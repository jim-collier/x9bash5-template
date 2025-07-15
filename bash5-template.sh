#!/bin/bash

#  shellcheck disable=2001  ## 'See if you can use ${variable//search/replace} instead.' Complains about good uses of sed.
#  shellcheck disable=2016  ## 'Expressions don't expand in single quotes, use double quotes for that.' I know, and I often want an explicit '$'.
#  shellcheck disable=2034  ## 'variable appears unused.' Complains about valid use of variable indirection (e.g. later use of local -n var=$1)
#  shellcheck disable=2046  ## 'Quote to prevent word-splitting.' (OK for integers.)
#  shellcheck disable=2086  ## 'Double quote to prevent globbing and word splitting.' (OK for integers.)
#  shellcheck disable=2119  ## 'Use foo "$@" if function's $1 should mean script's $1.' Confusing and inapplicable.
#  shellcheck disable=2120  ## 'Foo references arguments, but none are ever passed.' Valid function argument overloading.
#  shellcheck disable=2128  ## 'Expanding an array without an index only gives the element in the index 0.' False hits on associative arrays.
#  shellcheck disable=2155  ## 'Declare and assign separately to avoid masking return values.' Cumbersome and unnecessary.
#  shellcheck disable=2178  ## 'Variable was used as an array but is now assigned a string.' False hits on associative arrays with e.g. 'local -n assocArray=$1'.
#  shellcheck disable=2317  ## 'Can't reach.' I.e. an 'exit' is used for debugging and makes a visual mess.
## shellcheck disable=2002  ## 'Useless use of cat.'
## shellcheck disable=2004  ## '$/${} is unnecessary on arithmetic variables.' Inappropriate complaining?
## shellcheck disable=2053  ## 'Quote the right-hand sid of = in [[ ]] to prevent glob matching.' Disable for valid Yoda Notation warning?
## shellcheck disable=2143  ## 'Use grep -q instead of echo | grep'
## shellcheck disable=2162  ## 'read without -r will mangle backslashes.'
## shellcheck disable=2181  ## 'Check exit code directly, not indirectly with $?.'

##	Github home for template+library ......: https://github.com/jim-collier/x9bash5-template/
##		Changelog .........................: https://github.com/jim-collier/bash-5-ultimate-guide/blob/main/CHANGELOG.md
##		Remaining to-do ...................: https://github.com/jim-collier/x9bash5-template/blob/main/TODO.md
##	Using Bash5 style and performance guide: https://github.com/jim-collier/bash-5-ultimate-guide/blob/main/bash-5-ultimate-guide.md
##		Note: This template is not yet 100% in line with either the style nor performance parts of the guide.
##		      It mostly is, and where it counts. But over time will be brought fully in line, and intentional
##		      exceptions will be documented (what & why).

##	Purpose .............: See fAbout().
##	Args ................: See fSyntax().
##	Copyright and license: See fCopyright().
##	History:

## Constants
declare -r  thisVersion="v1.0.0-beta.1"        ## Put you script's semantic version here.
declare -r  thisCopyrightYear="2025"           ## Put your copyright date here.
declare -r  thisAuthor="Jim Collier"           ## Put your copyright name here.
declare -r  runAsOtherUser=""                  ## E.g. sudo aka root, or another username. Leave blank for no sudo or user change.
declare -r  templateVersion="v10.0.0-beta.1"   ## Template version, don't change.
declare -r  templateCopyrightYear="2011-2025"  ## Template copyright year, don't change.
declare -ri atLeastOneArgRequired=0
declare -ri doDebug=0
declare  -i doQuietly=0
declare  -i doPromptToContinue=1

## Copyright, about, & syntax (minified)
fCopyright(){ ((doQuietly)) && return;
	fEcho_Clean ""
	fEcho_Clean "${meName} ${thisVersion}, Copyright © ${thisCopyrightYear} ${thisAuthor}."
	fEcho_Clean "Built on 'bash5-template.sh' ${templateVersion}, Copyright © ${thisCopyrightYear} ${thisAuthor}."
	fEcho_Clean "Both are licensed GPLv3+: GNU GPL version 3 or later. Full text at"
	fEcho_Clean "  https://www.gnu.org/licenses/gpl-3.0.en.html"
#	fEcho_Clean "There is no warranty, to the extent permitted by law."
	fEcho_Force ;:;}
fAbout(){ ((doQuietly)) && return;
	fEcho_Clean ""
	#           X-------------------------------------------------------------------------------X
	fEcho_Force "Does some stuff:"
	fEcho_Force "  • Do some stuff."
	fEcho_Force "  • Do some more stuff."
	fEcho_Force ;:;}
fSyntax(){ ((doQuietly)) && return;
	fEcho_Clean ""
	#           X-------------------------------------------------------------------------------X
	fEcho_Force "Syntax: ${meName}  [optional args]  <file path>"
	fEcho_Force "  Optional arguments:"
	fEcho_Force "    --some-option <NUM> : Something."
	fEcho_Force ;:;}


#•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
fInit(){

	## Constants

	## Check for need to show help
	{ ((atLeastOneArgRequired)) && [[ -z "${1}${2}${3}${4}" ]]; } && { fCopyright; fAbout; fSyntax; exit 0; }
	case " ${*,,} " in
		*" -h "*|*" --help "*)                 fCopyright; fAbout; fSyntax; exit 0; ;;
		*" -v "*|*" --ver "*|*" --version "*)  fCopyright;                  exit 0; ;;
	esac

	## Validate dependencies
	fDependencies_Add  awk         "A GNU coreutil. Check for broken link to mawk or gawk."
	fDependencies_Add  basename    "A GNU coreutil, in nearly all repos if not default distros."
	fDependencies_Add  dirname     "A GNU coreutil, in nearly all repos if not default distros."
	fDependencies_Add  find        "Part of GNU findutils, in nearly all repos if not default distros."
	fDependencies_Add  gawk        "GNU awk [more features], in nearly all repos if not default distros."
	fDependencies_Add  grep        "GNU grep, in nearly all repos if not default distros."
	fDependencies_Add  mawk        "Mike's awk [fastest], in nearly all repos if not default distros."
	fDependencies_Add  realpath    "A GNU coreutil, in nearly all repos if not default distros."
	fDependencies_Add  sed         "GNU sed, in nearly all repos if not default distros."
	fDependencies_Add  tr          "A GNU coreutil, in nearly all repos if not default distros."
	[[ $(fDependencies_GetCount_Required_byEcho) -gt 0 ]] && { fCopyright; fAbout; }
	fDependencies_Validate

	## Custom arg variables
#	declare stringArg
#	declare arg_intArg
#	declare arg_boolArg

	## Parse the args [only change $parseArgs_maxPositionalArgCount]
	declare -ri parseArgs_maxPositionalArgCount=2  ## Variable expected by fParseArgs()
	declare allArgsStr; declare -a allArgsArr
	fParseArgs  "${1:-}" "${2:-}" "${3:-}" "${4:-}" "${5:-}" "${6:-}" "${7:-}" "${8:-}" "${9:-}" "${10:-}" "${11:-}" "${12:-}" "${13:-}" "${14:-}" "${15:-}" "${16:-}" "${17:-}" "${18:-}" "${19:-}" "${20:-}" "${21:-}" "${22:-}" "${23:-}" "${24:-}" "${25:-}" "${26:-}" "${27:-}" "${28:-}" "${29:-}" "${30:-}" "${31:-}" "${32:-}"
	declare -r allArgsStr; declare -ar allArgsArr

	## Arg validation and normalization
#	declare -i boolArg  ; fGetBool boolArg   "${arg_boolArg}"   0
#	declare -i intArg   ; fGetInt  intArg    "${arg_intArg}"    0
#	declare    floatArg ; fGetNum  floatArg  "${arg_floatArg}"  0

	## Get logging filespec (without yet creating it)
	declare logFilespec="" # ; fLog_GetFilespec logFilespec

#	#DEBUG
#	echo -e "\${allArgsArr[*]} ...: '${allArgsArr[*]}'"
#	echo -e "\${allArgsStr} ......: ${allArgsStr}"
#	fEchoVarAndVal stringArg
#	fEchoVarAndVal arg_intArg
#	exit

#	## Process convenience macros in variables that you might advertise to users
#	zipMountDir="${zipMountDir//'•FILENAME•'/"${zipFileName}"}" ## Supports macros "•FILENAME•" and "•SERIAL•"
#	local -r zipMountDir="${zipMountDir}"

	## Prompt to continue
	if ((doPromptToContinue)); then
		if ((! doQuietly)); then
			fEcho_Clean
			fCopyright; fAbout
			fEcho_Clean
			fEcho_Clean "Some other information."
			if [[ "${runAsOtherUser}" != "${USER}" ]]; then
				fEcho_Clean
				if fIsRegexMatch "${runAsOtherUser}" '^sudo|root$'; then fEcho_Clean "Needs to run as sudo, may prompt for authorization."
				else fEcho_Clean "Needs to run as user '${runAsOtherUser}', may prompt for sudo authorization."
				fi
			fi
			fEcho_Clean
		fi
		read -r -p "Continue? (y/n): " answer
		fEcho_ResetBlankCounter
		[[ "${answer,,}" != "y" ]] && { fEcho "User aborted."; exit 1; }
		((! doQuietly)) && fEcho_Clean
	fi

	## Ready to go; call main function with fully-validate variables.
	fRunFunctionAs  "${runAsOtherUser}"  fMain  "${logFilespec}"  "${1:-}" "${2:-}" "${3:-}" "${4:-}" "${5:-}" "${6:-}" "${7:-}" "${8:-}" "${9:-}" "${10:-}" "${11:-}" "${12:-}" "${13:-}" "${14:-}" "${15:-}" "${16:-}" "${17:-}" "${18:-}" "${19:-}" "${20:-}" "${21:-}" "${22:-}" "${23:-}" "${24:-}" "${25:-}" "${26:-}" "${27:-}" "${28:-}" "${29:-}" "${30:-}" "${31:-}" "${32:-}"

}


#•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
fMain(){
	## We only have access to variables passed here, that were carefully initialized and validated by fInit().
	## Take them in as read-only (and as integers if appropriate), unless you have good reason to modify them.
	## At this early stage, there will (necessarily) be no Bash arrays or associative arrays yet, which
	##   couldn't be passed anyway. (The args array will have already served it's purpose.)
	## There can be up to 32 args beyond OG user name, home, and log filespec (the latter which may be null).

	## Args; fRunFunctionAs() always passes OG username and userhome as first two params. fInit() usually passes logfilespec as third.
	declare -r origUserName="${1:-}" ; shift || true
	declare -r origUserHome="${1:-}" ; shift || true
	declare -r logFilespec="${1:-}"  ; shift || true
	[[ "${origUserName}" != "${USER}" ]] && { declare tmpStr; fTernaryStr  tmpStr  "root"  "${USER}"  "Now running as"  " root"  " user '${USER}'"  "."; fEcho "${tmpStr}"; }



	((! doQuietly)) && { fEcho; fEcho "Done."; }
}


#•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
fParseArgs(){

	## Look for stars "✶✶✶✶✶✶✶✶" for places to custom-modify unique instances of this function.

	## GENERIC (don't modify): Populate args array and string.
	## Note: Args are 1-based index, but the resulting array of args at the end is a normal 0-based index.
	local -r -i maxPracticalArgCount=50  ## In Bash we have 2MB of args, or somewhere around 10k by count. For readabality and performance, keep it MUCH lower, say ~20-99.
	local    -i totalArgCount=0
	local    -i switchCounter=0
	allArgsStr=""
	allArgsArr=()
	## Store the highest non-empty argument number.
	local -i i; i=0
	for ((i=1; i<=maxPracticalArgCount; i++)); do [[ -n "${!i:-}" ]] && totalArgCount=$i; done
	local -ri totalArgCount=$totalArgCount
	## Build args str and array, including empty args - up to the last non-empty arg.
	local thisStr=""
	for ((i=1; i<=totalArgCount; i++)); do
		thisStr="${!i}"
		## Append argument number i to allArgsStr, first replacing embedded quotes, then delimiting with single quotes and spaces.
		thisStr="${thisStr//\"/″}"; thisStr="${thisStr//\'/′}"
		[[ -n "${allArgsStr}" ]] && allArgsStr="${allArgsStr} "
		allArgsStr="${allArgsStr}'${thisStr}'"
		## Append argument number i to allArgsArr()
		allArgsArr+=("${thisStr}")
	done

	## GENERIC: Variables for loop
	local    tmpStr=""
	local    currentArg=""
	local    lastSwitch=""
	local -i expectingSwitchParamForNextArg=0
	local -i positionalArgCounter=0

	## Process arguments
	for currentArg in "${allArgsArr[@]}"; do
		#fEcho_Clean "Debug: currentArg ........: '${currentArg}'"

		## Test if an option switch or not
		if [[ -n "$(echo "${currentArg}" | grep -P "^\-(\-?)[^\ \-]" 2>/dev/null || true)" ]]; then
			## It's an option (either unary or long-option, we don't know yet)
			#fEcho_Clean "Debug: option ............: '${currentArg}'"

			## Check if this was supposed to NOT be a unary switch (eg expecting a parameter after previous long-option)
			((expectingSwitchParamForNextArg)) && fThrowError "Expecting a long-option argument for '${lastSwitch}', instead got another option '${currentArg}'."
			((switchCounter++))

			## Validate switches, and act on unary switches
			lastSwitchAsPassed="${currentArg}"
			tmpStr="${currentArg,,}"

			## Strip switch dashes off
			[[ "-"  == "${tmpStr:0:1}" ]] && tmpStr="${tmpStr:1}"
			[[ "-"  == "${tmpStr:0:1}" ]] && tmpStr="${tmpStr:1}"
			lastSwitch="${tmpStr}" ## Remember lastSwitch

			case "${tmpStr}" in

			#	## ✶✶✶✶✶✶✶✶ PUT CUSTOM UNARY SWITCH TESTS AND PARENT BOOLEAN VARIABLE ASSIGNMENTS HERE
			#	"unary-switch")  booleanVariable=1  ;;

			#	## ✶✶✶✶✶✶✶✶ PUT TESTS FOR CUSTOM LONG-OPTION LOGIC THAT EXPECTS AN ARGUMENT TO FOLLOW, HERE
			#	"long-option-with-arg-to-follow") expectingSwitchParamForNextArg=1 ;;

				## ¯\_(ツ)_/¯
				*) fThrowError  "Unexpected option in this context: '${currentArg}'."  ;;

			esac
		else
			## It's not an option switch; could be a long-option argument, or a positional arg

			if ((expectingSwitchParamForNextArg)); then :
				## Now we know to expecting an long-option argument
				#fEcho_Clean "Debug: arg for long-option: '${lastSwitch}': '${currentArg}'"

			#	## ✶✶✶✶✶✶✶✶ PUT CUSTOM LONG-OPTION ARGUMENT TESTS AND PARENT VARIABLE ASSIGNMENTS HERE
			#	case "${lastSwitch,,}" in
			#		"long-option-with-arg-to-follow") someParentVariable="${currentArg}" ;;
			#		*)                                fThrowError "Unkown option: '${lastSwitchAsPassed}', current parameter: '${currentArg}'." ;;  ## A redundant check.
			#	esac
			#	expectingSwitchParamForNextArg=0

			else
				## Well it must be a positional arg then.
				((positionalArgCounter++))
				((positionalArgCounter > parseArgs_maxPositionalArgCount))  && fThrowError "Too many positional arguments: ${positionalArgCounter}, for max of ${parseArgs_maxPositionalArgCount}."
				#fEcho_Clean "Debug: positional arg #${positionalArgCounter}: '${currentArg}'"

				## ✶✶✶✶✶✶✶✶ PUT CUSTOM POSITIONAL ARG LOGIC HERE (only use one of the following methods, delete the other)

				## Assign parent variables; Method 1: argument counter (less flexible but best for simple input)
				case $positionalArgCounter in
					1) stringArg="${currentArg}"      ;;
					2) arg_intArg="${currentArg}" ;;
					*) fThrowError "Unexpected positional argument # ${positionalArgCounter}: '${currentArg}'." ;;
				esac

			#	## Assign parent variables; Method 2: test argument contents (possibly more flexible depending on use-case)
			#	case "${currentArg,,}" in
			#		"enable")  doEnable=1   ;;
			#		"disable") doDisable=1  ;;
			#		"start")   doStart=1    ;;
			#		"stop")    doStop=1     ;;
			#		"list")    doList=1     ;;
			#		*)
			#			if (( positionalArgCounter <  (totalArgCount-switchCounter) )); then
			#				fThrowError "Unknown positional argument '${currentArg}'."
			#			else
			#				fThrowError "Unexpected positional argument #${positionalArgCounter}: '${currentArg}'."
			#			fi
			#		;;
			#	esac

			fi
		fi
	done
	((expectingSwitchParamForNextArg)) && fThrowError "Never received a parameter for switch '--${lastSwitch}'."

:;}  ## 'true' has to be the last thing or this function errors [the joys of the mysterious 'set -e'].




#•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
fCleanup(){
	((_vLog_DidInitFsObjs)) && _fLog_Cleanup
	if ((! doQuietly)); then
		fEcho_Clean
	fi
}




#•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
# Generic function usage examples
#•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••

: <<- EOF_s7asw

	fRecord_Add                        assocArray                         ## Add a new record.
	fRecord_FieldVal_Set               assocArray  "Property"  "Value"    ## Adds property=value to current record (idx = _.UBound).
	fRecord_FieldVal_Get  returnValue  assocArray  "Property"             ## Get value at current cursor, by named property.
	fRecord_FieldVal_Get_byEcho        assocArray  "Property"             ## Get value at current cursor, by named property, and by echo.
	fRecord_MoveFirst                  assocArray
	fRecord_MoveLast                   assocArray
	fRecord_MoveNext                   assocArray
	fRecord_MovePrev                   assocArray
	fRecord_isEOF                      assocArray  ||  echo  "no"
	fRecord_isBOF                      assocArray  ||  echo  "no"
	fRecord_isInBounds                 assocArray  &&  echo  "yes"
	fRecord_Get_LBound         retInt  assocArray
	fRecord_Get_UBound         retInt  assocArray
	fRecord_Get_Cursor         retInt  assocArray


EOF_s7asw




#•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
##	Generic code.
##
##	Some unit and battle-tested functions have been partially or fully minified.
##	Functions are ordered approximately by the number of dependents they have to
##	  other generic funcions, and loosely grouped by what they do or work with.
##	This whole section can be deleted (with possibly a few tweaks or deletions
##	  needed to template above), without affecting generic block below like fEcho
##	  related stuff, etc. Otherwise to delete only some or most, start from the
##	  bottom of this section, up.
#•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••


##	Group purpose ....: Generic echo-related functions (minified).
##	Can be deleted? ..: NO; not without also removing many generic functions and template code that relies on it.
##	Statefulness .....: Trivial single global state. (Only for count of blank lines output.)
##	Input ............:
##	Function return...:
##	Stdout ...........:
##	StdErr ...........:
##	Other side-effects:
##	Notes ............: The most useful feature about this collection, is by default not redundantly echoing
##	                    repeated blank lines - which is tedious logic to recreate for every script.
##	Dependents .......:
##	Dependencies .....:
##	Unit tests passed :
declare -i _wasLastEchoBlank=0
fEcho_Clean(){
	if   [[ -n "$*" ]]         ; then echo -e "$*"; _wasLastEchoBlank=0
	elif ((!_wasLastEchoBlank)); then echo ""     ; _wasLastEchoBlank=1; fi }
# shellcheck disable=2120  ## References arguments, but none are ever passed; Just because this library function isn't called here, doesn't mean it never will in other scripts.
fEcho()                   { if [[ -n "$*" ]]; then fEcho_Clean "[ $* ]"; else fEcho_Clean ""; fi; }
fEcho_Force()             { fEcho_ResetBlankCounter; fEcho "$*";                                  }
fEcho_Clean_Force()       { fEcho_ResetBlankCounter; fEcho_Clean "$*";                            }
fEchoVarAndVal()          { fEcho_Clean "${2}${1} = '${!1}'";                                     }
fEcho_ResetBlankCounter(){ _wasLastEchoBlank=0;                                                  }


##	Group purpose ....: Generic error-handling (minified).
##	Can be deleted? ..: Generally not - without also removing many generic functions that rely on it.
##	Statefulness .....: Single global state.
##	Input ............:
##	Function return...:
##	Stdout ...........:
##	StdErr ...........:
##	Other side-effects:
##	Notes ............:
##	Dependents .......:
##	Dependencies .....:
##	Unit tests passed :
declare -i _wasCleanupRun=0  ## Managed internally by this suite.
declare -i _doExitOnThrow=0    ## Managed internally by this suite.
declare -i _ErrVal=0         ## Set by this suite, but managed by calling functions. Think of it as an extended '$?' that doesn't immediately clear.
_fSingleExitPoint(){
	local -r signal="${1:-}"
	local -r lineNum="${2:-}"
	local -r exitCode="${3:-}"
	local -r errMsg="${4:-}"
	local -r errCommand="$BASH_COMMAND"
	_ErrVal=$exitCode
	if [[ "${signal}" == "INT" ]]; then
		fEcho_Force
		echo "User interrupted." >&2
		fEcho_ResetBlankCounter
		fCleanup  ## User cleanup
		exit 1
	elif [[ "${exitCode}" != "0" ]] && [[ "${exitCode}" != "1" ]]; then  ## Clunky string compare is less likely to fail than integer
		fEcho_Clean
		echo -e "Signal .....: '${signal}'"      >&2
		echo -e "Err# .......: '${exitCode}'"    >&2
		echo -e "Message ....: '${errMsg}'"      >&2
		echo -e "At line# ...: '${lineNum}'"     >&2
		echo -e "Command# ...: '${errCommand}'"  >&2
		fEcho_Clean_Force
		fCleanup  ## User cleanup
	else
		fCleanup  ## User cleanup
	fi ;}
_fTrap_Exit(){
	if [[ "${_wasCleanupRun}" == "0" ]]; then  ## String compare is less to fail than integer
		_wasCleanupRun=1
		_fSingleExitPoint "${1:-}" "${2:-}" "${3:-}" "${4:-}" "${5:-}" "${6:-}" "${7:-}" "${8:-}" "${9:-}" "${10:-}" "${11:-}" "${12:-}" "${13:-}" "${14:-}" "${15:-}" "${16:-}" "${17:-}" "${18:-}" "${19:-}" "${20:-}" "${21:-}" "${22:-}" "${23:-}" "${24:-}" "${25:-}" "${26:-}" "${27:-}" "${28:-}" "${29:-}" "${30:-}" "${31:-}" "${32:-}"
	fi ;}
_fTrap_Error(){
	if [[ "${_wasCleanupRun}" == "0" ]]; then  ## String compare is less to fail than integer
		_wasCleanupRun=1
		fEcho_ResetBlankCounter
		_fSingleExitPoint "${1:-}" "${2:-}" "${3:-}" "${4:-}" "${5:-}" "${6:-}" "${7:-}" "${8:-}" "${9:-}" "${10:-}" "${11:-}" "${12:-}" "${13:-}" "${14:-}" "${15:-}" "${16:-}" "${17:-}" "${18:-}" "${19:-}" "${20:-}" "${21:-}" "${22:-}" "${23:-}" "${24:-}" "${25:-}" "${26:-}" "${27:-}" "${28:-}" "${29:-}" "${30:-}" "${31:-}" "${32:-}"
	fi ;}
_fTrap_Error_Ignore(){ _ErrVal=1; true;  return 0; }
_fTrap_Error_Soft(){   _ErrVal=1; false; return 1; }
fThrowError(){
	local    errMsg="${1:-}"
	local -r funcName="${2:-}"
	local    meNameLocal="${meName}"
	[[ -z "${errMsg}"      ]]                           && errMsg="An error occurred."
#	[[ -z "${meNameLocal}" ]] && [[ -n "${funcName}" ]] && meNameLocal="${funcName}()"
#	[[ -n "${meNameLocal}" ]] && [[ -n "${funcName}" ]] && meNameLocal="${meNameLocal}.${funcName}()"
	[[ -n "${meNameLocal}" ]]                           && errMsg="${meNameLocal}: ${errMsg}"
	local callStack=""
	for (( i = 1; i < ${#FUNCNAME[@]}; i++ )); do
		[[ "${FUNCNAME[i]}" == "main" ]] && continue
		[[ -n "${callStack}" ]] && callStack="${callStack}, "
		callStack="${callStack}${FUNCNAME[i]}()"
	done
	[[ -n "${callStack}" ]] && callStack="Reverse call stack: ${callStack}"
	fEcho_Clean
	echo -e  "${errMsg}"     >&2
	echo -e  "${callStack}"  >&2
	fEcho_ResetBlankCounter
	_ErrVal=1
	{ ((_doExitOnThrow)) && exit 1; } || return 1; }
fDefineTrap_Error_Fatal(){        :; _ErrVal=0; _doExitOnThrow=1; trap '_fTrap_Error         ERR    ${LINENO}  $?  $_' ERR; set -e; } ## Standard; exits script on any caught error; but 'set -e' has known inconsistencies catching or ignoring errors.
fDefineTrap_Error_ExitOnThrow(){  :; _ErrVal=0; _doExitOnThrow=1; trap '_fTrap_Error         ERR    ${LINENO}  $?  $_' ERR; set +e; } ## Only exits script on fThrowError().
fDefineTrap_Error_Soft(){         :; _ErrVal=0; _doExitOnThrow=0; trap '_fTrap_Error_Soft    ERR    ${LINENO}  $?  $_' ERR; set -e; } ## Returns error code of 1 on error.
fDefineTrap_Error_Ignore(){       :; _ErrVal=0; _doExitOnThrow=0; trap '_fTrap_Error_Ignore  ERR    ${LINENO}  $?  $_' ERR; set +e; } ## Eats errors and returns true.
fDefineTrap_Error_Fatal
trap '_fTrap_Error SIGHUP  ${LINENO} $? $_' SIGHUP
trap '_fTrap_Error SIGINT  ${LINENO} $? $_' SIGINT    ## CTRL+C
trap '_fTrap_Error SIGTERM ${LINENO} $? $_' SIGTERM
trap '_fTrap_Exit  EXIT    ${LINENO} $? $_' EXIT
trap '_fTrap_Exit  INT     ${LINENO} $? $_' INT
trap '_fTrap_Exit  TERM    ${LINENO} $? $_' TERM


##	Group purpose ....: Generic logging (minified).
##	Can be deleted? ..: Yes. The only default template occurrence an fInit() is commented out.
##	Statefulness .....: Single global state.
##	Input ............:
##	Function return...:
##	Stdout ...........:
##	StdErr ...........:
##	Other side-effects:
##	Notes:
##		You can also write directly to log file yourself at any time after fLog_Init() or first fLog_Line() or fLog_Pipe(), and/or 'mv' the file after fLog_Cleanup().
##			The only 'required' function you need to call for logging:
##				fLog_Line()   E.g.: fLog_Line "Hello"
##			Or for continuous streamed logging (even from function output):
##				fLog_Pipe()   E.g.: fMyFunctionOrCommand | fLog_Pipe
##			Other functions you can *optionally* invoke:
##				fLog_GetFilespec() ................: If you want to know what the log filespec will be, before it's created.
##				fLog_Init() .......................: If you want to explicitly init the logfile, but is not necessary.
##				fLog_Cleanup() ....................: Not strictly necessary if you don't run as root, as it only updates file permissions to OG user.
##	Dependents .......:
##	Dependencies .....:
##	Unit tests passed :
declare -r -i maxLogfiles=10
declare -r -i removeNullFilesNMinutesOld=1
readonly      defaultLogMiddleSubdirs="var/log"
declare       _vLog_Dir=""  _vLog_Filename=""  _vLog_Filespec=""  _vLog_WiledcardSpec=""  _vLog_Owner=""
declare -i    _vLog_DidInitVars=0  _vLog_DidInitFsObjs=0
fLog_GetFilespec(){
	##	Purpose: Initializes everything and gives you the log filespec, without actually creating anything yet.
	##	Args:
	##		1 [REQUIRED]: varName      The variable to populate.
	##		2 [optional]: LogDir       If not specified, defaults to "$(fGetOgUserHome)/var/log/${meName}"
	##		3 [optional]: logFileName  If NOT specified, logfile rotation will work, and defaults to "${meName}_${serialDT}.log"
	##		4 [optional]: Username for ownership and/or homedir calculation
	##	Dependencies: fGetOgUserName(), fGetOgUserHome(), __pLog_InitVars()
	local -n refVar=$1 ; shift || true
	__pLog_InitVars  "${1:-}"  "${2:-}"  "${3:-}"
	refVar="${_vLog_Filespec}" ;:;}
fLog_Init(){
	##	Optional args:
	##		1: LogDir       If not specified, defaults to "$(fGetOgUserHome)/var/log/${meName}"
	##		2: logFileName  If NOT specified, logfile rotation will work, and defaults to "${meName}_${serialDT}.log"
	##		3: Username for ownership and/or homedir calculation
	##	Dependencies: fRemoveOldLogs(), __pLog_InitVars()
	((_vLog_DidInitFsObjs)) && return 0
	__pLog_InitVars  "${1:-}"  "${2:-}"  "${3:-}"
	if [[ ! -d "${_vLog_Dir}" ]]; then
		mkdir -p "${_vLog_Dir}"
		[[ "root" == "${USER,,}" ]] && chown ${_vLog_Owner}:${_vLog_Owner} "${_vLog_Dir}"
	fi
	[[ -n "${_vLog_WiledcardSpec}" ]] && fRemoveOldLogs  "${_vLog_Dir}"  "${_vLog_WiledcardSpec}"  $((maxLogfiles - 1))  $removeNullFilesNMinutesOld
	touch "${_vLog_Filespec}"
	_vLog_DidInitFsObjs=1 ;:;}
fLog_Line(){
	{ ((! _vLog_DidInitFsObjs)) || [[ -z "${_vLog_Filespec}" ]] || [[ ! -f "${_vLog_Filespec}" ]]; } && fLog_Init
	echo -e "$(date "+%Y%m%d-%H%M%S")  $1" >> "${_vLog_Filespec}" ;:;}
fLog_Pipe(){  ## Put this function after a pipe, to log all output of a command.
	{ ((! _vLog_DidInitFsObjs)) || [[ -z "${_vLog_Filespec}" ]] || [[ ! -f "${_vLog_Filespec}" ]]; } && fLog_Init
	while IFS= read -r nextLine; do echo -e "$(date "+%Y%m%d-%H%M%S")  ${nextLine}" >> "${_vLog_Filespec}"; done ;:;}
fLog_Cleanup(){  ## Call after done logging, to clean-up log file permissions.
	((! _vLog_DidInitFsObjs)) && fThrowError  "Log cleanup called but has not been initialized."  "${FUNCNAME[0]}"
	[[ "root" == "${USER,,}" ]] && chown ${_vLog_Owner}:${_vLog_Owner} "${_vLog_Filespec}" ;:;}
fLog_Reset(){ _vLog_Dir="" ; _vLog_Filename="" ; _vLog_Filespec="" ; _vLog_WiledcardSpec="" ; _vLog_Owner="" ; _vLog_DidInitVars=0 ; _vLog_DidInitFsObjs=0 ;:;}
fRemoveOldLogs(){
	##  Removes old [and optionally empty] log files.
	##	Used by: _fLog_Init()
	##	Example: fRemoveOldLogs  "${HOME}/var/log/$(basename "${0}")"  "$(basename "${0}")_*.log"  10  1
	local -r basePath="${1:-}"                   ## Arg <REQUIRED>: Folder where logfiles go.
	local -r wildcardFilespec="${2:-}"             ## Arg <REQUIRED>: A filename with at least one required embedded POSIX wildcard in the string (NOT at the shell expansion level). This is to old logs can be deleted.
	local    keepNewestNlogs=$3                ## Arg [optional]: Number of newest log files to keep. Defaults to $default_keepNewestNlogs
	local    removeNullsThisMinutesOrOlder=$4  ## Arg [optional]: Remove empty files this many minutes or older. 0 to disable.
	## Arg4: Remove 0-byte matches older than N > 0 minutes old. (Default = 0 which means DISABLE this action.
	local -ri default_keepNewestNlogs=10
	local -ri default_removeNullsThisMinutesOrOlder=$((60*24))
	local -r  safetyCheck_Arg1MustContain="[^a-z0-9](log|archive|old|bak|backup|delete|zip|7z|tar|gz|tgz|xz|bz2|zst)"
	[[   -z "${basePath}" ]] && fThrowError  "The first argument to this function must be a valid folder to rotate logs in."  "${FUNCNAME[0]}"
	[[ ! -d "${basePath}" ]] && fThrowError  "The first argument to this function (the folder to rotate logs in) doesn't seem to exist: '${basePath}'."  "${FUNCNAME[0]}"
	[[ "/" == "$(realpath "${basePath}")" ]] && fThrowError  "For safety purposes, the first argument to this function (the folder to rotate logs in '${basePath}') cannot be the root directory."  "${FUNCNAME[0]}"
	[[ -z "${wildcardFilespec}" ]] && fThrowError  "The second argument to this function must be a single file name, with at least one POSIX wildcard character embedded in the string (rather than shell expansion variables)."  "${FUNCNAME[0]}"
	grep -Pq '[*?\[\]]' <<< "${wildcardFilespec}" || fThrowError  "The second argument to this function (log filespec '${wildcardFilespec}') must have at least one POSIX wildcard expression embedded in the string, e.g.: *, ?, []."  "${FUNCNAME[0]}"
	local -r fullPathspec="$(realpath "${basePath}")/${wildcardFilespec}"
	grep -iPq "${safetyCheck_Arg1MustContain}" <<< "${fullPathspec}" || fThrowError "For safety purposes, as a crude check against potential massive accidental deletion, the full path/file spec sent to this function must satisfy the following regex: '${safetyCheck_Arg1MustContain}', but doesn't: '${fullPathspec}'."  "${FUNCNAME[0]}"
	[[ -n "${keepNewestNlogs}" ]] && [[ ! "${keepNewestNlogs}" =~ ^[0-9]$ ]] && fThrowError  "The third argument to this function ('keep newest N logs'), must be an integer, but got '${keepNewestNlogs}' instead."  "${FUNCNAME[0]}"
	[[ -z "${keepNewestNlogs}" ]] && keepNewestNlogs=${default_keepNewestNlogs}
	local -ir keepNewestNlogs=$keepNewestNlogs
	[[ -n "${removeNullsThisMinutesOrOlder}" ]] && [[ ! "${removeNullsThisMinutesOrOlder}" =~ ^[0-9]$ ]] && fThrowError  "The fourth argument to this function ('remove null files N minutes or older'), must be an integer >=0, but got '${removeNullsThisMinutesOrOlder}' instead."  "${FUNCNAME[0]}"
	[[ -z "${removeNullsThisMinutesOrOlder}" ]] && removeNullsThisMinutesOrOlder=$default_removeNullsThisMinutesOrOlder
	local -ir removeNullsThisMinutesOrOlder=$removeNullsThisMinutesOrOlder
	local useRemoveProgram="rm" ; [[ -z "$(which trash 2>/dev/null || true)" ]] && useRemoveProgram="trash"; local -r useRemoveProgram="${useRemoveProgram}"
	find "${basePath}" -maxdepth 1 -type f -name "${wildcardFilespec}" -printf '%T@ %p\0' | sort -z -n | head -z -n "-${keepNewestNlogs}" | cut -z -d' ' -f2- | xargs -0 -r "${useRemoveProgram}"
	if ((removeNullsThisMinutesOrOlder > 0)); then
		find "${basePath}" -maxdepth 1 -type f -name "${wildcardFilespec}" -empty -mmin +${removeNullsThisMinutesOrOlder} -delete
	fi
	:;}
__pLog_InitVars(){
	##	Used by: fLog_Init(), fLog_GetFilespec()
	((_vLog_DidInitVars)) && return 0
	local logDir="${1:-}"
	local logFileName="${2:-}"
	local userName="${3:-}"
	[[ -z "${userName}" ]] && fGetOgUserName userName
	_vLog_Owner="${userName}"
	if [[ -z "${logDir}"  ]]; then
		local userHome=""; fGetOgUserHome userHome "${userName}"; local -r userHome="${userHome}"
		logDir="${userHome}/${defaultLogMiddleSubdirs}/${meName}"
	fi
	_vLog_Dir="${logDir}"
	local _vLog_WiledcardSpec=""
	if [[ -z "${logFileName}" ]]; then
		logFileName="${meName}_${serialDT}.log"
		_vLog_WiledcardSpec="${meName}_*.log"
	fi
	_vLog_Filename="${logFileName}"
	_vLog_Filespec="${_vLog_Dir}/${_vLog_Filename}"
	_vLog_DidInitVars=1 ;:;}


##	Group purpose ....: Generic unit-testing (minified).
##	Can be deleted? ..: Yes. External unit-test scripts will break, but not this script.
##	Statefulness .....: Stateless.
##	Input ............:
##	Function return...:
##	Stdout ...........:
##	StdErr ...........:
##	Other side-effects:
##	Notes ............:
##	Dependents .......:
##	Dependencies .....:
##	Unit tests passed :
declare __vAllTestIDs=""
fUnitTest_PrintSectionHeader(){
	fEcho_Clean; fEcho_Clean "•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••"
	if [[ -n "${1:-}" ]]; then
		fEcho_Clean "Unit test section: ${1:-}"
		fEcho_Clean "•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••"
	fi ;:;}
fAssert_AreEqual(){
	local -r testID="${1:-}"            ## Arg [optional]: Unique test ID, e.g. muid1.
	local -r testVal="${2:-}"           ## Arg <REQUIRED>: Test val, e.g. from output of a command.
	local -r expectVal="${3:-}"         ## Arg <REQUIRED>: Expected val.
	local -r addComment="${4:-}"        ## Arg [optional]: Brief comment to include in output.
	local    outputStr=""
	if [[ -n "${testID}" ]]; then
		[[ "${__vAllTestIDs}" == *"y${testID}z"* ]] && fThrowError  "Unique test ID has been used already: '${testID}'."  "${FUNCNAME[0]}"
		__vAllTestIDs="${__vAllTestIDs}y${testID}z"
	fi
	if [[ "${testVal}" == "${expectVal}" ]]; then
		outputStr="Assertion ID '${testID}': Pass, test and expected values are the same: '${testVal}'"
	else
		outputStr="Assertion ID '${testID}': **FAIL**, test and expected values are NOT the same; '${testVal}' != '${expectVal}'."
	fi
	[[ -n "${addComment}" ]] && outputStr="${outputStr}  [${addComment}]"
	fEcho_Clean "${outputStr}"
	:;}
fAssert_AreNotEqual(){
	local -r testID="${1:-}"            ## Arg [optional]: Unique test ID, e.g. muid1.
	local -r testVal="${2:-}"           ## Arg <REQUIRED>: Test val, e.g. from output of a command.
	local -r expectWrongVal="${3:-}"    ## Arg <REQUIRED>: Expected wrong val.
	local -r addComment="${4:-}"        ## Arg [optional]: Brief comment to include in output.
	local    outputStr=""
	if [[ -n "${testID}" ]]; then
		[[ "${__vAllTestIDs}" == *"y${testID}z"* ]] && fThrowError  "Unique test ID has been used already: '${testID}'."  "${FUNCNAME[0]}"
		__vAllTestIDs="${__vAllTestIDs}y${testID}z"
	fi
	if [[ "${testVal}" != "${expectWrongVal}" ]]; then
		outputStr="Assertion ID '${testID}': Pass, test and expected incorrect value are the not the same; '${testVal}' != '${expectWrongVal}'."
	else
		outputStr="Assertion ID '${testID}': **FAIL**, test and expected values ARE the same: '${testVal}'"
	fi
	[[ -n "${addComment}" ]] && outputStr="${outputStr}  [${addComment}]"
	fEcho_Clean "${outputStr}"
	:;}
fAssert_Eval_AreEqual(){
	local -r testID="${1:-}"            ## Arg [optional]: Unique test ID, e.g. muid1.
	local -r expressionToEval="${2:-}"  ## Arg <REQUIRED>: Exression to evaluate.
	local -r expectVal="${3:-}"         ## Arg <REQUIRED>: Expected val.
	local -r addComment="${4:-}"        ## Arg [optional]: Brief comment to include in output.
	fAssert_AreEqual  "${testID}"  "$(eval "${expressionToEval}")"  "${expectVal}"  "${addComment}";:;}
fAssert_Eval_ShouldError(){
	local -r testID="${1:-}"            ## Arg [optional]: Unique test ID, e.g. muid1.
	local -r expressionToEval="${2:-}"  ## Arg <REQUIRED>: Exression to evaluate.
	local -r addComment="${3:-}"        ## Arg [optional]: Brief comment to include in output.
	local -i returnCode=0
	local    outputStr=""
	if [[ -n "${testID}" ]]; then
		[[ "${__vAllTestIDs}" == *"y${testID}z"* ]] && fThrowError  "Unique test ID has been used already: '${testID}'."  "${FUNCNAME[0]}"
		__vAllTestIDs="${__vAllTestIDs}y${testID}z"
	fi
	fDefineTrap_Error_Ignore
		_ErrVal=0
		eval "${expressionToEval}" &>/dev/null
		returnCode=${_ErrVal}
	fDefineTrap_Error_Fatal
	if ((returnCode > 0)); then
		outputStr="Assertion ID '${testID}': Pass, function errored as predicted."
	else
		outputStr="Assertion ID '${testID}': **FAIL**, function did not error as predicted."
	fi
	[[ -n "${addComment}" ]] && outputStr="${outputStr}  [${addComment}]"
	fEcho_Clean "${outputStr}"
	:;}
fAssert_Eval_ShouldNotError(){
	local -r testID="${1:-}"            ## Arg [optional]: Unique test ID, e.g. muid1.
	local -r expressionToEval="${2:-}"  ## Arg <REQUIRED>: Exression to evaluate.
	local -r addComment="${3:-}"        ## Arg [optional]: Brief comment to include in output.
	local -i returnCode=0
	local    outputStr=""
	if [[ -n "${testID}" ]]; then
		[[ "${__vAllTestIDs}" == *"y${testID}z"* ]] && fThrowError  "Unique test ID has been used already: '${testID}'."  "${FUNCNAME[0]}"
		__vAllTestIDs="${__vAllTestIDs}y${testID}z"
	fi
	fDefineTrap_Error_Ignore
		_ErrVal=0
		eval "${expressionToEval}" &>/dev/null
		returnCode=${_ErrVal}
	fDefineTrap_Error_Fatal
	if ((returnCode == 0)); then
		outputStr="Assertion ID '${testID}': Pass, function succeeded as predicted."
	else
		outputStr="Assertion ID '${testID}': **FAIL**, function errored."
	fi
	[[ -n "${addComment}" ]] && outputStr="${outputStr}  [${addComment}]"
	fEcho_Clean "${outputStr}"
	:;}


##	Group purpose ....: Adds expected script dependencies to an array one-at-a-time, then validates them all at once. (To avoid
##	                    bothering the user with the ol' one-at-a-time dependency-fix/more-errors annoyance.)
##	Input ............: [per-function]
##	Function return...: >0 if error
##	StdErr ...........: [if error]
##	Other side-effects: $__pDependencies_Array[], $__pDependencies_HighestIndex
##	Notes ............: It's totally unnecessary to use fRecord_*() or associative arrays at all for this. It would be WAY more concise,
##	                    faster, and maintainable to just add items to delimited string vars directly in _Add(). But this was also a testbed
##                      for fRecord_*(), and also serves as a usage example.
##	Dependents .......: fInit() [in stock standard template]
##	Dependencies .....: fThrowError()
##	Unit tests passed : 20250710
declare -gA __pDependencies_Array
declare -gi __pDependencies_HighestIndex=0
fDependencies_Add(){ #
	declare -r  commandThatShouldBeInPath="${1:-}"  ## Arg <REQUIRED>: A command/program that should be in the path.
	declare -r  howToGet="${2:-}"                   ## Arg [optional]: How to obtain it if it's not.
	declare -r  arg_isSuggestionOnly="${3:-}"       ## Arg [optional]: 0=required (default), 1=suggestion-only, that will only be seen if another required one isn't met.
	declare -i  isSuggestionOnly ; fGetBool  isSuggestionOnly  "${arg_isSuggestionOnly}"  0
	[[ -z "${commandThatShouldBeInPath}" ]] && fThrowError  "No path program specified to add to dependencies checker."  "${FUNCNAME[0]}"
	fRecord_Add          __pDependencies_Array  ## Note: Read function block header comment for why we're going rediculously overboard with fRecord_*() instead of ultra-simple text variable handling.
	fRecord_FieldVal_Set __pDependencies_Array  "Program"           "${commandThatShouldBeInPath}"
	fRecord_FieldVal_Set __pDependencies_Array  "HowToGet"          "${howToGet}"
	fRecord_FieldVal_Set __pDependencies_Array  "IsSuggestionOnly"   $isSuggestionOnly
	fRecord_FieldVal_Set __pDependencies_Array  "Pathspec"          "$(which "${commandThatShouldBeInPath}" 2>/dev/null || true)"; }
fDependencies_Validate(){ #
	declare progName warningList errList="" tmpStr
	fRecord_MoveFirst  __pDependencies_Array
	while fRecord_isInBounds __pDependencies_Array; do
		fRecord_FieldVal_Get  progName  __pDependencies_Array  "Program"
		[[ -z "${progName}" ]] && continue
		if [[ -z "$(fRecord_FieldVal_Get_byEcho __pDependencies_Array "Pathspec")" ]]; then
			tmpStr="${progName}	$(fRecord_FieldVal_Get_byEcho __pDependencies_Array "HowToGet")"
			if [[ "$(fRecord_FieldVal_Get_byEcho __pDependencies_Array "IsSuggestionOnly")" == "1" ]]; then  warningList="Suggestion	${tmpStr}"
			else  errList="Required	${tmpStr}"; fi; fi
		fRecord_MoveNext  __pDependencies_Array; done
	[[ -z "${errList}"     ]] && return 0
	tmpStr=""
	fAppendStr  tmpStr  $'\n'  "Importance	Program	How to get"
	fAppendStr  tmpStr  $'\n'  "••••••••••	•••••••	••••••••••"
	[[ -n "${errList}"     ]] && fAppendStr  tmpStr  $'\n'  "$(sort -u <<< "${errList}")"
	[[ -n "${warningList}" ]] && fAppendStr  tmpStr  $'\n'  "$(sort -u <<< "${warningList}")"
	#tmpStr="$(column -t -s $'\t' --table-wrap 3 <<< "${tmpStr}")"
	tmpStr="$(column -t -s $'\t' <<< "${tmpStr}")"
	tmpStr="The following dependencies are required to run this script:"$'\n\n'"${tmpStr}"
	fThrowError "${tmpStr}" ;}
fDependencies_GetCount_Required_byEcho(){
	fRecord_MoveFirst  __pDependencies_Array
	varName_s7ag5=0
	while fRecord_isInBounds __pDependencies_Array; do
		[[ "$(fRecord_FieldVal_Get_byEcho __pDependencies_Array "IsSuggestionOnly")" == "0" ]] && varName_s7ag5=$((varName_s7ag5+1))
		fRecord_MoveNext  __pDependencies_Array
	done
	echo "${varName_s7ag5}" ; }

##	Purpose ..........: Runs specified function as sudo or username.
##	Input ............: <'sudo' or username [or empty for current]>  <function name [in this script]>
##	Function return...: 0 [success], >0 [some failure]
##	Stdout ...........: Directly: If !doQuietly, possible status message.
##	StdErr ...........: Possible error conditions.
##	Other side-effects: [None directly.]
##	Notes ............: Always passes as first two parameters, [username] and [user home directory] of the earliest known user in the launch chain or user of sudo.
##	Dependents .......: fInit() [in stock standard template]
##	Dependencies .....: fGetOgUserName(), fGetOgUserHome(), fIsFunction()
##	Unit tests passed : 20250709-203343
fRunFunctionAs(){ #
	declare    runAs="${1:-}"
	declare -r functionName="${2:-}"
	{ fIsRegexMatch  "${runAs}"  '^(|sudo|root)$' || fIsUser "${runAs}"; } || fThrowError  "Not a know user: '${runAs}'"  "${FUNCNAME[0]}"
	fIsFunction "${functionName}" || fThrowError  "Not a valid defined function in this script: '${functionName}'"  "${FUNCNAME[0]}"
	declare ogUserName; fGetOgUserName ogUserName
	declare ogUserHome; fGetOgUserHome ogUserHome
	if [[ -z "${runAs}" ]] || [[ "${runAs}" == "${USER}" ]]; then
		## We are already running as defined user (possibly sudo or even self), so invoke function directly.
		$functionName "${ogUserName}"  "${ogUserHome}"  "${1:-}" "${2:-}" "${3:-}" "${4:-}" "${5:-}" "${6:-}" "${7:-}" "${8:-}" "${9:-}" "${10:-}" "${11:-}" "${12:-}" "${13:-}" "${14:-}" "${15:-}" "${16:-}" "${17:-}" "${18:-}" "${19:-}" "${20:-}" "${21:-}" "${22:-}" "${23:-}" "${24:-}" "${25:-}" "${26:-}" "${27:-}" "${28:-}" "${29:-}" "${30:-}" "${31:-}" "${32:-}"
	elif fIsRegexMatch "${runAs}" '^root|sudo$'; then
		## We need to run as sudo but currently aren't; so relaunch script via sudo; function will be called via routing control at the bottom of this script.
		((! doQuietly)) && sudo echo "[ Re-launching to run function '${functionName}()' as sudo ... ]"
		sudo "${mePath}" "REENTRANT_${reentrantKey}"  "${functionName}"  "${ogUserName}"  "${ogUserHome}"  "${1:-}" "${2:-}" "${3:-}" "${4:-}" "${5:-}" "${6:-}" "${7:-}" "${8:-}" "${9:-}" "${10:-}" "${11:-}" "${12:-}" "${13:-}" "${14:-}" "${15:-}" "${16:-}" "${17:-}" "${18:-}" "${19:-}" "${20:-}" "${21:-}" "${22:-}" "${23:-}" "${24:-}" "${25:-}" "${26:-}" "${27:-}" "${28:-}" "${29:-}" "${30:-}" "${31:-}" "${32:-}"
	else
		## We need to run as a different user but currently aren't; so relaunch script via sudo; function will be called via routing control at the bottom of this script.
		((! doQuietly)) && sudo echo "[ Re-launching to run function '${functionName}()' as user '${runAs}' ... ]"
	#	sudo -u $runAs -i "${mePath}" "REENTRANT_${reentrantKey}"  "${functionName}"  "${ogUserName}"  "${ogUserHome}"  "${1:-}" "${2:-}" "${3:-}" "${4:-}" "${5:-}" "${6:-}" "${7:-}" "${8:-}" "${9:-}" "${10:-}" "${11:-}" "${12:-}" "${13:-}" "${14:-}" "${15:-}" "${16:-}" "${17:-}" "${18:-}" "${19:-}" "${20:-}" "${21:-}" "${22:-}" "${23:-}" "${24:-}" "${25:-}" "${26:-}" "${27:-}" "${28:-}" "${29:-}" "${30:-}" "${31:-}" "${32:-}"
		sudo -u $runAs "${mePath}" "REENTRANT_${reentrantKey}"  "${functionName}"  "${ogUserName}"  "${ogUserHome}"  "${1:-}" "${2:-}" "${3:-}" "${4:-}" "${5:-}" "${6:-}" "${7:-}" "${8:-}" "${9:-}" "${10:-}" "${11:-}" "${12:-}" "${13:-}" "${14:-}" "${15:-}" "${16:-}" "${17:-}" "${18:-}" "${19:-}" "${20:-}" "${21:-}" "${22:-}" "${23:-}" "${24:-}" "${25:-}" "${26:-}" "${27:-}" "${28:-}" "${29:-}" "${30:-}" "${31:-}" "${32:-}"
	fi ;:;}


##	Group purpose ....: Error message constants
##	Can be deleted? ..: Not without also removing dependents.
##	Dependents .......: fAssArr_*()
declare -r errBadRef_Chg_AssArr="Calling function didn't pass a reference to an associative array variable (for in-place manipulation)."
declare -r errBadRef_Chg_Array="Calling function didn't pass a reference to an array variable (for in-place manipulation)."
declare -r errBadRef_Chg_Int="Calling function didn't pass a reference to an integer variable (for return value placement)."
declare -r errBadRef_Chg_Str="Calling function didn't pass a reference to a string variable (for in-place value change)."
declare -r errBadRef_Ret_Int="Calling function didn't pass a reference to an integer variable (for in-place value change)."
declare -r errBadRef_Ret_Str="Calling function didn't pass a reference to a string variable (for return value placement)."


##	Group purpose ....: Simulates database functions - under the hood, operating on calling functions' associative arrays.
##	Input ............: [per-function]
##	Function return...: Usually >0 if error
##	StdErr ...........: [if error]
##	Other side-effects: Calling functions' associative arrays, and in some cases variables to store results.
##	Notes ............: Although conceptually cool in the context of Bash's limited array handling and lack of OO,
##	                    this is all probably pretty slow. So maybe don't use this for performance-critical bottlenecks.
##	                    (Line-delimited strings with tools like sed, awk, grep, and tr are usually the fastest for massive
##	                    amounts of data. Or more natively, multiple arrays each representing a field, with matching integer
##	                    indexes, would almost certainly be faster than this conceit.)
##	Dependents .......: fInit() [in stock standard template]
##	Dependencies .....: fThrowError()
##	Unit tests passed : 20250710
fRecord_Add(){ ## Add a new record.
	declare -n  assArr_s7abk=$1  ## Arg: <REQUIRED>: Reference to associative array.
	declare -i  newIdx=${2:-0}
	[[ -z "${assArr_s7abk["_.LBound"]:-}" ]] && assArr_s7abk=( ["_.LBound"]=1  ["_.UBound"]=0  ["_.Cursor"]=0 )
	newIdx=$((${assArr_s7abk["_.UBound"]} + 1))  ## Increment idx.
	assArr_s7abk["_.UBound"]=$newIdx; }  ## set UBound to incremented idx.
fRecord_FieldVal_Set(){ ## Adds idx.property=value to current record (i.e. idx of _.UBound)
	declare -n  assArr_s7abj=$1
	declare -r  arrProperty="${2:-}"  setVal="${3:-}"
	declare -r  arrIdx="${assArr_s7abj["_.UBound"]}"
	if [[ -z "${arrIdx}" ]]; then  fThrowError  "Associative array metadata '_.UBound' doesn't appear to be set for index '${arrIdx}'. [¢⍤Č웃]"  "${FUNCNAME[0]}"
	else assArr_s7abj["${arrIdx}.${arrProperty}"]="${setVal}"; fi; }
fRecord_FieldVal_Get(){ # Get value at current cursor, by named property.
	declare -n varName_s7abv=$1
	declare -n assArr_s7abv=$2
	declare -r arrProperty="${3:-}"
	declare -i arrIdx ; fRecord_Get_Cursor  arrIdx  assArr_s7abv
	fAssArr_GetVal  varName_s7abv  assArr_s7abv  $arrIdx  "${arrProperty}" ;}
fRecord_FieldVal_Get_byEcho(){ # Get value at current cursor, by named property, and by echo.
	declare -n  assArr_s7abo=$1
	declare -r  arrProperty="${2:-}"
	declare     retVal
	fRecord_FieldVal_Get retVal assArr_s7abo "${arrProperty}" ; echo -e "${retVal}" ;}
fRecord_MoveFirst(){ declare -n assArr_s7abf=$1 ; assArr_s7abf["_.Cursor"]=${assArr_s7abf["_.LBound"]}; }
fRecord_MoveLast(){  declare -n assArr_s7abg=$1 ; assArr_s7abg["_.Cursor"]=${assArr_s7abg["_.UBound"]}; }
fRecord_MoveNext(){  declare -n assArr_s7ab0=$1 ; assArr_s7ab0["_.Cursor"]=$((${assArr_s7ab0["_.Cursor"]} + 1)); }
fRecord_MovePrev(){  declare -n assArr_s7ab1=$1 ; assArr_s7ab1["_.Cursor"]=$((${assArr_s7ab1["_.Cursor"]} - 1)); }
fRecord_isEOF(){
	declare -n assArr_s7ab2=$1
	declare -i uBound cCursor ; fRecord_Get_UBound  uBound  assArr_s7ab2 ; fRecord_Get_Cursor  cCursor assArr_s7ab2
	[[ cCursor -gt uBound ]]; }
fRecord_isBOF(){ #
	declare -n assArr_s7ab3=$1
	declare -i lBound cCursor ; fRecord_Get_LBound  lBound  assArr_s7ab3 ; fRecord_Get_Cursor  cCursor assArr_s7ab3
	[[ cCursor -lt lBound ]]; }
fRecord_isInBounds(){ declare -n varName_s7ac6=$1 ; ! fRecord_isBOF varName_s7ac6  &&  ! fRecord_isEOF varName_s7ac6 ; }
fRecord_Get_LBound(){ #
	declare -n  varName_s7a9r=$1
	declare -n  assArr_s7a9r=$2
	declare -r  retVal="${assArr_s7a9r["_.LBound"]}"
	if [[ -z "${retVal}" ]]; then fThrowError  "Either the associative array hasn't been initialized yet with at least one call to fRecord_Add(), or the associative array itself isn't valid. [¢⍤āz]"  "${FUNCNAME[0]}"
	else varName_s7a9r=$retVal; fi; }
fRecord_Get_UBound(){ #
	declare -n  varName_s7a9s=$1
	declare -n  assArr_s7a9s=$2
	declare -r  retVal="${assArr_s7a9s["_.UBound"]}"
	if [[ -z "${retVal}" ]]; then  fThrowError  "Either the associative array hasn't been initialized yet with at least one call to fRecord_Add(), or the associative array itself isn't valid. [¢⍤āz]"  "${FUNCNAME[0]}"
	else  varName_s7a9s=$retVal ; fi; }
fRecord_Get_Cursor(){ #
	declare -n  varName_s7a9t=$1
	declare -n  assArr_s7a9t=$2
	declare -r  retVal="${assArr_s7a9t["_.Cursor"]}"
	if [[ -z "${retVal}" ]]; then  fThrowError  "Either the associative array hasn't been initialized yet with at least one call to fRecord_Add(), or the associative array itself isn't valid. [¢⍤āz]"  "${FUNCNAME[0]}"
	else  varName_s7a9t=$retVal ; fi; }


##	Group purpose ....: For specified associative arrays, appends from, or copies to, as second associative array.
##	Input ............: [per-function]
##	Function return...: >0 if error
##	StdErr ...........: [if error]
##	Other side-effects: Calling functions' associative arrays.
##	Dependencies .....: fThrowError()
##	Unit tests passed :
fAA_AppendFromSubAA(){ :; }  #TODO
fAA_FilterToSubAA(){ :; }    #TODO


##	Group purpose ....: Lighter-weight wrappers for Bash associative arrays. Unlike fRecord_*, don't try to abstract
##	                    too much away. You are still free to loop over and access the array directly. The only idea
##	                    it keeps from fRecord_*, is the idea of per-array metadata like '_.LBound' and '_.UBound'.
##	Input ............: [per-function]
##	Function return...: Usually >0 if error
##	StdErr ...........: [if error]
##	Other side-effects: Calling functions' associative arrays, and in some cases variables to store results.
##	Notes ............: Although conceptually cool in the context of Bash's limited array handling and lack of OO,
##	                    this is all probably pretty slow. So maybe don't use this for performance-critical bottlenecks.
##	                    (Line-delimited strings with tools like sed, awk, grep, and tr are usually the fastest for massive
##	                    amounts of data. Or more natively, multiple arrays each representing a field, with matching integer
##	                    indexes, would almost certainly be faster than this conceit.)
##	Dependents .......: fInit() [in stock standard template]
##	Dependencies .....: fThrowError(), fAA_AppendFromSubAA(), fAA_FilterToSubAA()
##	Unit tests passed :
fAssArr_AddIdx(){ ## Add a new record.
	[[ -v $1 ]] || fThrowError "${errBadRef_Chg_AssArr} [¢⍩fP]"  "${FUNCNAME[0]}" ; declare -n  assArr_s7abk=$1  ## Arg: <REQUIRED>: Associative array.
	[[ -v $2 ]] || fThrowError "${errBadRef_Ret_Int} [¢⍩fS]"     "${FUNCNAME[0]}" ; declare -n  newIdx_s7agn=$2  ## Arg: <REQUIRED>: New integer index return value.
	[[ -z "${assArr_s7abk["_.LBound"]}" ]] && assArr_s7abk=( ["_.LBound"]=1  ["_.UBound"]=0  ["_.Cursor"]=0 )
	newIdx_s7agn=$((${assArr_s7abk["_.UBound"]} + 1))  ## Increment idx.
	assArr_s7abk["_.UBound"]=$newIdx_s7agn; }  ## set UBound to incremented idx.
fAssArr_SetVal(){ #
	declare -n  assArr_s7abl=$1
	declare -ri arrIdx=$2
	declare -r  arrProperty="${3:-}"
	declare -r  setVal="${4:-}"
	assArr_s7abl["${arrIdx}.${arrProperty}"]="${setVal}" ;}
fAssArr_GetVal(){ #
	declare -n  varName_s7a8g=$1
	declare -n  assArr_s7abm=$2
	declare -ri arrIdx=$3
	declare -r  arrProperty="${4:-}"
	declare -r  arrKey="${arrIdx}.${arrProperty}"
	if [[ "${assArr_s7abm["${arrKey}"]+isset}" != "isset" ]]; then  fThrowError  "Either the key '${arrKey}' - or the associative array itself - doesn't exist. [¢⍤āᚠ]"  "${FUNCNAME[0]}"
	else  varName_s7a8g="${assArr_s7abm["${arrKey}"]}"; fi ;}
fAssArr_GetSubAssArr_Idx(){ :; }  #TODO
fAssArr_SetSubAssArr_Idx(){ :;}  #TODO
fAssArr_Delete_Idx(){ :; }        #TODO


##	Purpose ..........: Test if a string is that of an existing function name.
##	Input ............: <test string>
##	Function return...: 0=is a function, 1=isn't, >1=error.
##	StdErr ...........: [Possible errors from 'type'.]
##	Dependents .......: fRunFunctionAs()
##	Dependencies .....:
##	Unit tests passed : 20250709-173511
fIsFunction(){ [[ $(type -t "${1:-}") == function ]]; }

##	Purpose ..........: Test if a string is that of an existing username.
##	Input ............: <test string>
##	Function return...: 0=is a function, 2=isn't, 3=username is empty.
##	Dependents .......: fRunFunctionAs()
##	Dependencies .....:
##	Unit tests passed : 20250709-173328
fIsUser(){ { [[ -z "${1:-}" ]] && return 3; } || getent passwd "${1:-}" &>/dev/null; }

##	Purpose ..........: Constants for several functions below. (These must appear higher in script.)
##	Dependencies .....: fIsInt(), fIsNum(), __pGetX_Common(), fRoundNum(), fMath()
declare -r currencySymbols='$¢¥£€₹₩₽₺฿₴₦₪₫₵₡₲₱₸₿Ξ₮🅑◎🪙✕⧫Ð₳ɱ' ; declare -r currencySymbols_escaped='\$¢¥£€₹₩₽₺฿₴₦₪₫₵₡₲₱₸₿Ξ₮🅑◎🪙✕⧫Ð₳ɱ'  ## Dependents: 1;3, Dependencies: 0;0 [respectively]
declare -r sep_decimal='.'   ; declare -r sep_decimal_escaped='\.'   ## Dependents: 1;18, Dependencies: 0;0 [respectively].
declare -r sep_thousands=',' ; declare -r sep_thousands_escaped=','  ## Dependents: 1;3, Dependencies: 0;0 [respectively].
declare -r extractNum_Step1_sedE="s#${sep_thousands_escaped}##g; s#[${currencySymbols_escaped}]+##; s#\+##; s#([+-])[[:space:]]+([0-9]*)#\1\2#; s#([0-9]*)[[:space:]]+%#\1%#; s#^[[:space:]]+##; s#[[:space:]]+\$##;"  ## Remove all thousand seps, first currency symbol, first '+' sign, space between - and numbers, space between numbers and %, leading space, trailing space. [Dependents: 1, Dependencies: 2.]
declare -r extractNum_Step2_grepP="[0-9+\-${sep_decimal_escaped}%]+"  ## extract all number like things grouped together without spaces, without regard to proper order or number of them. Use with 'head -n 1' to only use the first occurrence. [Dependents: 1, Dependencies: 1.]
declare -r sedE_NoInsignificantNonNakedZeros="s#^([+\-]?)0*([1-9][0-9]*)#\1\2#; s#(${sep_decimal_escaped}[0-9]*[1-9])0*\$#\1#; s#^([+\-]?)(${sep_decimal_escaped}[0-9]+)\$#\10\2#; s#^([+/-]?[0-9]+${sep_decimal_escaped})\$#\10#;"  ## Assumes an already otherwise well-formed number. [Dependents: 1, Dependencies: 1.]

##	Purpose ..........: Test if input is a fairly raw integer. Currency symbols, +/-, %, thousands separators, and ending decimal are ok.
##	Input ............: <test value>
##	Function return...: 0=is, 1=isn't, >1=error.
##	StdErr ...........: [!Possible errors from sed.]
##	Notes ............: If there are digits AFTER a decimal, then it's not considered an int. Numbers with multiple '+/-' delimiters, or in the wrong place, aren't ints.
##	Dependen[ts;cies] : 1, 0
##	Unit tests passed : 20250708
fIsInt(){ sed "s#[${sep_thousands_escaped}]##g; s#[${currencySymbols_escaped}]##"  <<<  "${1:-}" | grep  -qP  '^[+-]?[0-9]+\.?$'; }

##	Purpose ..........: Test if input is a fairly raw number, integer or decimal. Currency symbols, +/-, %, and thousands separators are ok.
##	Input ............: <test value>
##	Function return...: 0=is, 1=isn't, >1=error.
##	StdErr ...........: [!Possible errors from sed.]
##	Notes ............: Phone numbers and IP addresses, for example, are not 'numbers'. They have delimiters that happen to have meaning for numbers, but multiple of them.
##	Dependen[ts;cies] : 1, 0
##	Unit tests passed : 20250708
fIsNum(){ sed "s#[${sep_thousands_escaped}]##g; s#[${currencySymbols_escaped}]##; s#\.##;"  <<<  "${1:-}" | grep  -qP  '^-?[0-9]+%?$' ; }

##	Purpose ..........: Floating-point-capable "-gt" (which Bash can't natively do). Can also compare string data.
##	Input ............: <val1>  <val2>
##	Function return...: 0=is, 1=isn't, >1=error.
##	StdErr ...........: [Possible errors from awk.]
##	Notes ............: Does no input validation. Can and will compare more than numbers.
##	Dependen[ts;cies] : 0, 0
##	Unit tests passed : 20250706
fIsVal1_gt_Val2(){ awk -v Val1="${1:-}" -v Val2="${2:-}" 'BEGIN {exit !(Val1 > Val2)}'; }

##	Purpose ..........: Floating-point-capable "-lt" (which Bash can't natively do). Can also compare string data.
##	Input ............: <val1>  <val2>
##	Function return...: 0=is, 1=isn't, >1=error.
##	StdErr ...........: [Possible errors from awk.]
##	Notes ............: Does no input validation. Can and will compare more than numbers.
##	Dependen[ts;cies] : 0, 0
##	Unit tests passed : 20250706
fIsVal1_lt_Val2(){ awk -v Val1="${1:-}" -v Val2="${2:-}" 'BEGIN {exit !(Val1 < Val2)}'; }  ## Floating-point-capable -lt (which Bash can't natively do). Unit tests passed on: 20250706.

##	Purpose ..........: PCRE-compatibble regex test.
##	Input ............: <string>  <regex>  [0=case-INsensitive:default, 1=case-sensitive]
##	Function return...: 0=matches, 1=doesn't, >1=error.
##	StdErr ...........: [Possible errors from grep.]
##	Notes ............: Does no input validation.
##	Dependen[ts;cies] : 0, 0
##	Unit tests passed : 20250706
fIsRegexMatch(){
	if [[ "${3:-}" == "1" ]]; then grep -qP  "${2:-}" <<< "${1:-}"
	else                         grep -qPi "${2:-}" <<< "${1:-}"; fi; }

##	Purpose ..........: Floating-point-capable min (which Bash can't natively do).
##	Input ............: <byref for return value>  <val1>  <val2>
##	Function return...: (Possible >0 from awk.)
##	StdErr ...........: [Possible errors from awk.]
##	Notes ............: Does no input validation and will work with non-numbers.
##	Dependen[ts;cies] : 0, 0
##	Unit tests passed : 20250706
fGetMinVal(){
	declare -n  varName_s76fk=$1  ## <REQUIRED>: Variable for return. Also pass ints or floats (strings) for $2 and $3.
	{ awk -v Num1="${2:-}" -v Num2="${3:-}" 'BEGIN {exit !(Num1 < Num2)}' && varName_s76fk="${2:-}"; } || varName_s76fk="${3:-}" ;:;}

##	Purpose ..........: Floating-point-capable max (which Bash can't natively do).
##	Input ............: <byref for return value>  <val1>  <val2>
##	Function return...: 0
##	StdErr ...........: [Possible errors from awk.]
##	Notes ............: Does no input validation and will work with non-numbers.
##	Dependen[ts;cies] : 0, 0
##	Unit tests passed : 20250706
fGetMaxVal(){
	declare -n  varName_s76s9=$1  ## <REQUIRED>: Variable for return. Also pass ints or floats (strings) for $2 and $3.
	{ awk -v Num1="${2:-}" -v Num2="${3:-}" 'BEGIN {exit !(Num1 > Num2)}' && varName_s76s9="${2:-}"; } || varName_s76s9="${3:-}" ;:;}

##	Purpose ..........: Floating-point-capable number forced between min and max.
##	Purpose ..........: Floating-point-capable max (which Bash can't natively do).
##	Input ............: <byref for return value>  <test val>  <min val>  <max val>
##	Function return...: 0
##	StdErr ...........: [Possible errors from awk.]
##	Notes ............: Does no input validation and will work with non-numbers.
##	Dependen[ts;cies] : 0, 0
##	Unit tests passed : 20250706
fGetBetweenVal(){
	declare -n  varName_s77dr=$1 ; declare -r  testNum="${2:-}"  minNum="${3:-}"  maxNum="${4:-}"
	     awk -v Val1="$minNum"  -v Val2="$maxNum" 'BEGIN {exit !(Val1 > Val2)}' && fThrowError  "Arg3 (min) must be lower than Arg4 (max). [¢¿5⍩]"  "${FUNCNAME[0]}"
	if   awk -v Val1="$testNum" -v Val2="$minNum" 'BEGIN {exit !(Val1 < Val2)}' ; then varName_s77dr="$minNum"
	elif awk -v Val1="$testNum" -v Val2="$maxNum" 'BEGIN {exit !(Val1 > Val2)}' ; then varName_s77dr="$maxNum"
	else                                                                               varName_s77dr="$testNum"; fi ;:;}

##	Purpose ..........: Returns 0 or 1, given input like 'true', 'no', 'Y', -1, etc.
##	Input ............: <byref for return value>  <input>  <default value if null or garbage>
##	Function return...:
##	Stdout ...........: [none]
##	StdErr ...........: y
##	Dependents .......:
##	Dependencies .....: fIsInt(), fThrowError()
##	Unit tests passed : 20250708
fGetBool(){
	##	Unit tests passed, code minified on: 20250704.
	declare -n  varRef_s74hb=$1 ; declare -r  arg_inputVal="${2:-}"  arg_defaultVal="${3:-}"
	varRef_s74hb=0
	local -i defaultVal=0; local -i isSet_defaultVal=0; [[ -n "${arg_defaultVal}" ]] && { isSet_defaultVal=1 ; defaultVal=$arg_defaultVal ; }
	case "${arg_inputVal,,}" in
		"1"|"true"|"yes"|"y"|"t")  varRef_s74hb=1  ;;
		"0"|"false"|"no"|"n"|"f")  varRef_s74hb=0  ;;
		*)	if fIsInt "${arg_inputVal}"    ; then varRef_s74hb=$((arg_inputVal != 0))
			elif ((isSet_defaultVal))       ; then varRef_s74hb=$defaultVal
			elif [[ -z "${arg_inputVal}" ]] ; then fThrowError "No input. [s79bh]."  "${FUNCNAME[0]}"
			else                                   fThrowError "Invalid boolean input '${arg_inputVal}' [¢¢re]."  "${FUNCNAME[0]}"; fi ;;
	esac
:;}

##	Purpose ..........: Private function for some math-related functions.
##	Input ............: <input and output string variable reference>
##	Function return...: >0 if error probably.
##	StdErr ...........: [something on error probalby]
##	Dependents .......: fGetInt(), fGetNum(), and fRoundNum()
##	Dependencies .....: _BigMath(), _Math()
##	Unit tests passed : 20250708
__pGetX_Common(){  ## Common between fGetInt(), fGetNum(), and fRoundNum(). Returns a clean decimal number, no leading or trailing 0s, and no naked decimal point.; Unit tests passed, code minified on: 20250708-195728.
	local -n varRef_outValStr_s78s3=$1
	[[ -z "${varRef_outValStr_s78s3}" ]] && return 0
	varRef_outValStr_s78s3="$(sed -E "${extractNum_Step1_sedE}" <<< "${varRef_outValStr_s78s3}" | grep -Po "${extractNum_Step2_grepP}" | head -n 1 || true)" ## Results in the first occurrence of space-free number-like characters.
	[[ -z "${varRef_outValStr_s78s3}" ]] && return 0
	local -i isPercent=0; [[ "${varRef_outValStr_s78s3}" == *"%"* ]] && isPercent=1; local -ri isPercent=$isPercent
	{ [[ -n "${varRef_outValStr_s78s3}" ]] && [[ $( grep -o  "${sep_decimal_escaped}" <<< "${varRef_outValStr_s78s3}" | wc -l || echo 0 ) -gt 1 ]]; } && varRef_outValStr_s78s3="" #..: Too many decimals separators.
	{ [[ -n "${varRef_outValStr_s78s3}" ]] && [[ $( grep -oP '[+\-]'                  <<< "${varRef_outValStr_s78s3}" | wc -l || echo 0 ) -gt 1 ]]; } && varRef_outValStr_s78s3="" #..: Too many '+' and/or '-'.
	if [[ -n "${varRef_outValStr_s78s3}" ]] && ((isPercent)); then  ## May divide by 100 to convert % to integer.
		[[ $( grep -o '\%' <<< "${varRef_outValStr_s78s3}" | wc -l || 0 ) -gt 1 ]] && varRef_outValStr_s78s3="" ## Too many '%'.
		if [[ -z "${varRef_outValStr_s78s3}" ]] || [[ "${varRef_outValStr_s78s3: -1}" != "%" ]]; then ## The '%' is somewhere not at the end, so invalid number.
			varRef_outValStr_s78s3=""
		else
			varRef_outValStr_s78s3="${varRef_outValStr_s78s3::-1}" ## Remove the %.
			if [[ $(grep -Po '[0-9]' <<< "${varRef_outValStr_s78s3}" | wc -l || 0) -gt 15 ]]; then  fBigMath  varRef_outValStr_s78s3  "${varRef_outValStr_s78s3}/100"
			else                                                                                    fMath     varRef_outValStr_s78s3  "${varRef_outValStr_s78s3}/100"
			fi; fi; fi; [[ -n "${varRef_outValStr_s78s3}" ]] && varRef_outValStr_s78s3="$(sed -E "${sedE_NoInsignificantNonNakedZeros}" <<< "${varRef_outValStr_s78s3}")"; :;}

fGetInt(){
	## Extracts, validates, and/or defaults a +/- integer. (A surprisingly hard problem in bash.) !locale-aware
	## Removing commas and insignificant 0s. Does not round. (To get a rounded integers, use 'fGetNum NUM 0'.) For %, divides by 100 then truncates.
	## Unit tests passed, code minified on: 20250708.
	local -n varRef_s74bm=$1       ## Arg <REQUIRED>: Variable for return integer.
	local -r arg_inputVal="${2:-}"     ## Arg [optional]: Input string to extract/convert to integer.
	local -r arg_defaultVal="${3:-}"   ## Arg [optional]: This will be used if input is blank, or if input is garbage and $tryNotToError is true.
	varRef_s74bm=0
	local -i defaultVal=0    ; local -i isSet_defaultVal=0    ; [[ -n "${arg_defaultVal}"    ]] && { isSet_defaultVal=1    ; defaultVal=$arg_defaultVal ; } ; local -ri defaultVal=$defaultVal ; local -i isSet_defaultVal=$isSet_defaultVal
	local    outValStr="${arg_inputVal}"
	local -i outValInt=0       #; fEchoVarAndVal arg_defaultVal; fEchoVarAndVal defaultVal; fEchoVarAndVal isSet_defaultVal; fEchoVarAndVal outValStr
	[[ -n "${outValStr}" ]] && __pGetX_Common outValStr   ## Common between fGetInt(), fGetNum(), and fRoundNum(). Returns a clean decimal number, no leading or trailing 0s, and no naked decimal point.
	[[ -n "${outValStr}" ]] && outValStr="$(grep -Po "^[+\-]?[0-9]+" <<< "${outValStr}" | head -n 1 || echo "")"  ## Extract only the first full [-] and integer (including 0).
	if [[ -n "${outValStr}" ]]; then
		outValInt=$outValStr
	else
		if ((isSet_defaultVal))        ; then  outValInt=$defaultVal
		elif [[ -n "${arg_inputVal}" ]]; then  fThrowError  "The input value can't be converted to an integer: '${arg_inputVal}' [s78qb]."  "${FUNCNAME[0]}"
		else                                   fThrowError  "No input value given' [¢ɤϠÑ]."  "${FUNCNAME[0]}"
		fi
	fi; varRef_s74bm=$outValInt; :;}
fGetNum(){
	## Converts, and optionally constrains, rounds, defaults, and/or validates an integer or float.
	## Unit tests passed, code minified on: 20250708.
	local -n varRef_s76ej=$1      ; shift || true  ## Arg <REQUIRED>: Variable for return number. Can be int or string.
	local -r arg_inputVal="${1:-}"    ; shift || true  ## Arg [optional]: Input string to convert to integer. If empty, default or 0 will be returned regardless of $_FGETINT_NOERROR
	local    arg_roundDigits="${1:-}" ; shift || true  ## Arg [optional]: number of decimal places to round to.
	local -r arg_defaultVal="${1:-}"  ; shift || true  ## Arg [optional]: This will be used if input is blank, or if input is garbage and $_FGETINT_NOERROR is 1.
	varRef_s76ej=0
	local -i roundDigits=0         ; local -i isSet_roundDigits=0   ; [[ -n "${arg_roundDigits}"   ]] && { isSet_roundDigits=1   ; roundDigits=$arg_roundDigits ; }
	local    defaultVal=0          ; local -i isSet_defaultVal=0    ; [[ -n "${arg_defaultVal}"    ]] && { isSet_defaultVal=1    ; defaultVal=$arg_defaultVal ; }
	((roundDigits < 0)) && roundDigits=0
	local outValStr="${arg_inputVal}"  #; fEchoVarAndVal arg_inputVal; fEchoVarAndVal outValStr
	[[ -n "${outValStr}" ]] && __pGetX_Common outValStr   ## Common between fGetInt(), fGetNum(), and fRoundNum(). Returns a clean decimal number, no leading or trailing 0s, and no naked decimal point.
	if [[ -z "${outValStr}" ]]; then
		if ((isSet_defaultVal))        ; then  outValStr=$defaultVal   #; fEchoVarAndVal outValStr
		elif [[ -n "${arg_inputVal}" ]]; then  fThrowError  "The input value can't be converted to a number: '${arg_inputVal}' [s78ts]."  "${FUNCNAME[0]}"
		else                                   fThrowError  "No input value given' [s78tr]."  "${FUNCNAME[0]}"
		fi
	fi
	((isSet_roundDigits)) && _FROUNDNUM_SKIP_PRECLEAN=1 fRoundNum outValStr $roundDigits
	varRef_s76ej=$outValStr; :;}

## Rounding of >15 decimals is *exceedingly* difficult in bash, mawk, gawk, bc, etc. Even to some degree for <15 digits, in a way one typically expects for integer vs floating point.
## Holy crap this took forever to unit-test and debug with as minimal code as reasonable, so don't so much as change a single character!
## I've tried every permutation of - and subprogram for - awk, mawk, gawk, printf, bc, etc. This is the only combo that works for big and small numbers.
## Unit tests passed, and code minified, on: 20250708.
declare -i _FROUNDNUM_SKIP_PRECLEAN=0  ## If used, must be set each call.
fRoundNum(){
	local -n  varRef_s76sr=$1   ## Arg <REQUIRED>: Variable with number to round, modified in-place.
	local -i  roundDigits=$2    ## Arg <REQUIRED>: 0 or positive integer to round decimal number to.
	fIsNum "${varRef_s76sr}" || fThrowError  "Input isn't a number: '${varRef_s76sr}'. [¢¿VÉ]"  "${FUNCNAME[0]}"
	local wrkVal="${varRef_s76sr}"  #; fEchoVarAndVal wrkVal
	((! _FROUNDNUM_SKIP_PRECLEAN)) && __pGetX_Common  wrkVal
	local -i  decimalPos=0; fGetStrMatchPos  decimalPos  "${wrkVal}"  '.'
	local -i len_wrkVal=${#wrkVal}
	((roundDigits < 0)) && roundDigits=0
	if ((decimalPos > 0)); then
		local -ri decimalPlaces=$((len_wrkVal - decimalPos))
		if ((decimalPlaces > roundDigits)); then
			wrkVal="${wrkVal//'-'/''}" ; local -i isNegative=0; ((${#wrkVal} != len_wrkVal)) && isNegative=1  ## Rounding only seems to be reliable on positive numbers, so remove the negative sign and add it back on later.
			if ((${#wrkVal} > 16)); then  ## Exceeding limits of 64-bit float [15 total significant digits + decimal point]; have to use slow and stupid 'bc -l' route, but it works.
				local -ri bcTmpScale=$((roundDigits * 2 + 1))
				wrkVal="$(bc -l <<< "scale=${bcTmpScale}; sf=10^${roundDigits}; (${wrkVal} * sf + 0.5)/sf")"
				local -r wrkVal_dec="${wrkVal#*.}"
				wrkVal="${wrkVal%%.*}.${wrkVal_dec:0:roundDigits}"
			else  ## The fast route but limited to 64-bit double float (<= 15 total significant digits).
				wrkVal="$(mawk -v vArg="${wrkVal}" -v vRound="${roundDigits}" "BEGIN { vFact = 10^vRound; vResult = int((vArg * vFact) + 0.5) / vFact; printf \"%.${roundDigits}f\n\", vResult; }")"
			fi
			((isNegative)) && wrkVal="-${wrkVal}"  ## Add negative sign back on if necessary.
		fi
	fi
	if ((roundDigits > 0)); then wrkVal="$(sed -E "s#(${sep_decimal_escaped}[0-9]*[1-9])0+\$#\1#; s#${sep_decimal_escaped}0*\$#${sep_decimal_escaped}0#; s#${sep_decimal_escaped}\$#${sep_decimal_escaped}0#; s#^${sep_decimal_escaped}#0${sep_decimal_escaped}#; s#^([0-9]+)\$#\1${sep_decimal_escaped}0#" <<< "${wrkVal}")" ## Nix insignificant 0s; 'N.0*'→'N.0'; 'N.'→'N.0'; '.N'→'0.N'; 'N'→'N.0'
	else                         wrkVal="$(sed "s#${sep_decimal_escaped}0*##;" <<< "${wrkVal}")"  ## Trim off decimal point and zeros, if exist
	fi
	varRef_s76sr=$wrkVal
	_FROUNDNUM_SKIP_PRECLEAN=0
:;}

declare -i _FAUTOMATH_SHOWMETHOD_ON_STDERR=0
fMath(){ ## Wrapper for fastest math. With much better rounding and output. Supposed to be 64-bit double-precision float math via mawk.
	local -n  varRef_s77c5=$1       ## Arg <REQUIRED>: Variable for return result.
	local -r  mathExpression="${2:-}"   ## Arg <REQUIRED>: Math expression.
	local -r  arg_roundDigits="${3:-}"  ## Arg [optional]: Digits to round to. Clamps to 0 < x <= 15. If not specified, returns up to 15, or as few as needed.
	[[ -z "${mathExpression}" ]] && fThrowError  "A math expression or 'mawk' formula must be provided as the second argument."  "${FUNCNAME[0]}"
	varRef_s77c5=0; local -i roundDigits=15 ; [[ -n "${arg_roundDigits}" ]] && roundDigits=$arg_roundDigits  ## 15 is max useful precision with 64-bit double-precision float.
	{ ((roundDigits < 0)) && roundDigits=0; } || { ((roundDigits > 15)) && roundDigits=15; }  ## 15 digits max precision no matter $arg_roundDigits.
	((_FAUTOMATH_SHOWMETHOD_ON_STDERR)) && echo "mawk \"BEGIN { printf \"%.${roundDigits}f\n\", ${mathExpression} }\"" >&2
	varRef_s77c5="$(mawk "BEGIN { printf \"%.${roundDigits}f\n\", ${mathExpression} }")"
	if ((roundDigits > 0)); then
		varRef_s77c5="$(sed -E "s/(${sep_decimal_escaped}[0-9]*[1-9])0+\$/\1/; s/${sep_decimal_escaped}\$//; s/(${sep_decimal_escaped}0)0+\$/\1/" <<< "${varRef_s77c5}")"  ## Logical formatting for decimals
	else
		varRef_s77c5="$(sed -E "s/${sep_decimal_escaped}0*\$//" <<< "${varRef_s77c5}")"  ## Integer formatting
	fi  ;:;}
fBigMath(){ ## Wrapper for slower arbitray-precision math via 'bc -l', but with WAY better rounding and output. Note: Not eve gwak --bignum can do this.
	local -n  varRef_s77c9=$1       ## Arg <REQUIRED>: Variable for return result.
	local -r  mathExpression="${2:-}"   ## Arg <REQUIRED>: Math expression.
	local -r  arg_roundDigits="${3:-}"  ## Arg [optional]: Digits to round to. Basically unlimited. If not specified, returns up to 15 by default, or as few as needed.
	[[ -z "${mathExpression}" ]] && fThrowError  "A math expression or 'bc -l' formula must be provided as the second argument."  "${FUNCNAME[0]}"
	varRef_s77c9=0; local -i roundDigits=15 ; [[ -n "${arg_roundDigits}" ]] && roundDigits=$arg_roundDigits
	((roundDigits < 0)) && roundDigits=0
	local -ri bcTmpScale=$((roundDigits * 2 + 1))
	((_FAUTOMATH_SHOWMETHOD_ON_STDERR)) && echo "bc -l <<< \"scale=${bcTmpScale}; ${mathExpression}\"" >&2
	local wrkVal_s77q1="$(bc -l <<< "scale=${bcTmpScale}; ${mathExpression}")"
	fRoundNum  wrkVal_s77q1  $roundDigits
	varRef_s77c9=$wrkVal_s77q1 ;:;}
fAutoMath(){  ## Decide on _Math() or _BigMath() based on crude digit count. Slower, if you know which one you need.
	local -n  varRef_s78pe=$1       ## Arg <REQUIRED>: Variable for return result.
	local -r  mathExpression="${2:-}"   ## Arg <REQUIRED>: Math expression.
	local -r  arg_roundDigits="${3:-}"  ## Arg [optional]: Digits to round to. Basically unlimited. If not specified, returns up to 15 by default, or as few as needed.
	if [[ $(grep -Po '[0-9]' <<< "${varRef_s78pe}" | wc -l || 0) -gt 15 ]]; then  fBigMath  varRef_s78pe  "${mathExpression}"  "${arg_roundDigits}"
	else                                                                          fMath     varRef_s78pe  "${mathExpression}"  "${arg_roundDigits}"; fi ;:;}

fGetFormattedNum(){  ## !locale-aware
	local -n varRef_s74h1=$1             ; shift || true  ## Arg <REQUIRED>: Variable for return formatted number.
	local -r arg_inputVal="${1:-}"           ; shift || true  ## Arg <REQUIRED>: Input value to convert to number, then format as a string.
	local -r arg_numDecimalPlaces="${1:-}"   ; shift || true  ## Arg [optional]:
	local -r arg_showThousandsDelim="${1:-}" ; shift || true  ## Arg [optional]:
	local -r arg_numLeadingZeroPad="${1:-}"  ; shift || true  ## Arg [optional]:
	local -r arg_numTrailingZeroPad="${1:-}" ; shift || true  ## Arg [optional]:
	local retVal=""
	local tmpNum=0
	fGetNum  tmpNum  "${arg_inputVal}"  ""  ""  ""  "${arg_numDecimalPlaces}"  "${arg_doTruncateNotRound}"
	## TODO ...
:;}

fGetRandomInt(){
	##	Purpose: Return a cryptographically valid integer between low and high ints, inclusive.
	##	Note: $RANDOM can do similar, but is not uniformly random, or crypto-secure.
	##	Unit tests passed on: 20250704.
	local -n  varName=$1  ## <REQUIRED>: Variable for return int.
	local -ri intLow=$2   ## <REQUIRED>: Lowest int.
	local -ri intHigh=$3  ## <REQUIRED>: Highest int.
	varName=$(shuf -i ${intLow}-${intHigh} -n 1 --random-source=/dev/urandom)
:;}


##	Group purpose ....: Array to-and-from string variables or files.
##	Input ............: [per-function]
##	Function return...: >0 if error
##	StdErr ...........: [if error]
##	Other side-effects: Calling functions' arrays, string variables, or system files.
##	Notes ............: Although conceptually cool in the context of Bash's limited array handling and lack of OO,
##	Dependents .......:
##	Dependencies .....: fThrowError()
##	Unit tests passed :
fArrayFromStr(){ :; }
fArrayToStr(){ :; }
fArrayFromFile(){ :; }
fArrayToFile(){ :; }


fGetStrMatchPos(){
	##	Unit tests passed on: 20250704.
	local -n varRef_s74ht="${1:-}"  ## Arg <REQUIRED>: Variable for return value, 0=no match, >=1 position of start of firt match.
	local -r mainStr="${2:-}"
	local -r findStr="${3:-}"
	varRef_s74ht=0
	{ [[ -z "${mainStr}" ]] || [[ -z "${findStr}" ]]; } && return 0
	local -r testStr="${mainStr%%"$findStr"*}"
	[[ "${testStr}" != "${mainStr}" ]] && varRef_s74ht=$((${#testStr}+1))
	:;}
fTrimStr(){
	##	Unit tests passed on: 20250704.
	local -n varRef_s74n3=$1  ## Arg <REQUIRED>: Variable reference that contains the string that will be modified in-place.
	[[ -n "${varRef_s74n3}" ]] && varRef_s74n3="$(sed 's/^[[:blank:]]*//g; s/[[:blank:]]*$//g;' 2>/dev/null <<< "${varRef_s74n3}" || true)"
	:;}
fNormStr(){
	##	Purpose: Strips leading and trailing spaces from string, and changes all whitespace inside a string to single spaces. Reference: https://unix.stackexchange.com/a/205854
	##	Unit tests passed on: 20250704.
	local -n varName_s74e8=$1                           ## Arg <REQUIRED>: Variable reference that contains the string that will be modified in-place.
	varName_s74e8="${varName_s74e8//[$'\t\r\n ']/' '}"  ## Convert misc whitespace to space.
	varName_s74e8="${varName_s74e8//$'\t'/ }"           ## Convert tabs to spaces
	varName_s74e8="$(awk '{$1=$1};1' 2>/dev/null <<< "${varName_s74e8}" || true)"  ## Collapse multiple spaces to one and trim
	:;}
fAppendStr(){
	##	Unit tests passed on: 20250704.
	local -n varName_s74nj=$1                    ## Arg <REQUIRED>: Variable reference that contains the string that will be modified in-place.
	local -r appendFirstIfExistingNotEmpty="${2:-}"  ## Arg [optional]: String to append between contents in $varName_s74nj if not empty, and $appendStr.
	local -r appendStr="${3:-}"                      ## Arg [optional]: String to append at end.
	[[ -n "${varName_s74nj}" ]] && varName_s74nj="${varName_s74nj}${appendFirstIfExistingNotEmpty}"
	varName_s74nj="${varName_s74nj}${appendStr}"
	:;}
fPadTruncStr(){
	##	Unit tests passed on: 20250704.
	local -n    varName_s74np=$1             ## Arg <REQUIRED>: Variable reference that contains the string that will be modified in-place.
	local    -i toLen=$2                     ## Arg <REQUIRED>: Integer length to pad to. If 0, won't pad, and may return '' if $doTruncateIfInputTooLong is 1.
	local    -i padDirection=$3              ## Arg [optional]: Negative value to pad to left, positive [default] pad to right.
	local    -i doTruncateIfInputTooLong=$4  ## Arg [optional]: 1 to truncate input string if it's longer than $toLen. Default is 0.
	local       padChar="${5:-}"                 ## Arg [optional]: Will default to space (' '), if empty. Only first character used.
	((doTruncateIfInputTooLong != 0)) && doTruncateIfInputTooLong=1 #.........................: Normalize $doTruncateIfInputTooLong.
	[[ ${#varName_s74np} -eq $toLen ]] && return 0 #..........................................: String already same as it would be after transform, so do nothing and return
	{ ((toLen <= 0)) && ((doTruncateIfInputTooLong)); } && { varName_s74np=""; return 0; } #..: If $toLen <= 0, return and truncate, set empty string and return.
	{ [[ $toLen -lt ${#varName_s74np} ]] && ((! doTruncateIfInputTooLong)); } && return 0; #..: If not truncating and toLen is shorter thas input, do nothing and return.
	((padDirection == 0)) && padDirection=1 #....................................................: Default to >0 for right-padding.
	{ [[ -z "${padChar}" ]] && padChar=' '; } || { padChar="${padChar:0:1}"; } #..............: Default space, or first char of $padChar.
	local padStr=""
	[[ $toLen -gt ${#varName_s74np} ]] && padStr="$(seq $toLen | xargs -I {} printf "${padChar}")"
	if ((padDirection > 0)); then
		varName_s74np="${varName_s74np}${padStr}"
		varName_s74np="${varName_s74np:0:$toLen}"  ## Right-pad and/or truncate; either it's long enough to truncate padding, or we only made it this far because we're going to truncate input and $toLen is >0.
	else
		varName_s74np="${padStr}${varName_s74np}"
		varName_s74np="${varName_s74np: -$toLen}"  ## Left-pad and/or truncate; either it's long enough to truncate padding, or we only made it this far because we're going to truncate input and $toLen is >0.
	fi
	:; }
fTernaryStr(){
	##	Unit tests passed on: 20250704.
	local -n varName_s74qf=$1    ; shift || true  ## Arg <REQUIRED>: Variable reference for result.
	local -r trueCondition="${1:-}"  ; shift || true  ## Arg <REQUIRED>: String that is considered 'true'.
	local -r testCondition="${1:-}"  ; shift || true  ## Arg <REQUIRED>: String to compare to $trueCondition to test for true.
	local -r prefixStr="${1:-}"      ; shift || true  ## Arg [optional]: String to prepend to beginning no matter what.
	local -r ifTrueStr="${1:-}"      ; shift || true  ## Arg [optional]: String to append if true.
	local -r ifFalseStr="${1:-}"     ; shift || true  ## Arg [optional]: String to append if false.
	local -r suffixStr="${1:-}"      ; shift || true  ## Arg [optional]: String to append to end to no matter what.
	varName_s74qf=""
	varName_s74qf="${varName_s74qf}${prefixStr}"
	{ [[ "${testCondition}" == "${trueCondition}" ]] && varName_s74qf="${varName_s74qf}${ifTrueStr}"; } || varName_s74qf="${varName_s74qf}${ifFalseStr}";
	varName_s74qf="${varName_s74qf}${suffixStr}"
	:;}
ConditionalSandwichStr(){
	##	Unit tests passed on: 20250704.
	local -n varName_s74qp=$1  ; shift || true  ## Arg <REQUIRED>: Variable reference that contains the string that will be modified in-place.
	local -r withPrefix="${1:-}"   ; shift || true  ## Arg [optional]: String to prepend to beginning, only if first arg is non-empty.
	local -r withSuffix="${1:-}"   ; shift || true  ## Arg [optional]: String to append to end, only if first arg is non-empty.
	[[ -n "${varName_s74qp}" ]] && varName_s74qp="${withPrefix}${varName_s74qp}${withSuffix}"
	:;}

declare -ri outputNonEmptyArg_MaxCount=128
fJoinNonEmptyArgs(){  ## Given a list of arguments, joins all empty ones together
	##	Unit tests passed on: 20250704.
	local -n  varName_s74qv=$1  ; shift || true  ## Arg <REQUIRED>: Variable reference that contains the string that will be modified in-place.
	for ((i = 0; i < outputNonEmptyArg_MaxCount; i++)); do
		[[ -n "${1:-}" ]] && varName_s74qv="${varName_s74qv}${1:-}"
		shift || { true; break; }
	done ;:;}
fJoinNonEmptyArgs_byecho(){
	##	Unit tests passed on: 20250704.
	for ((i = 0; i < outputNonEmptyArg_MaxCount; i++)); do
		[[ -n "${1:-}" ]] && echo -n "${1:-}"
		shift || { true; break; }
	done ;:;}

fNormalizePath(){
	##	Unit tests passed on: 20250704.
	local -n  varName_s74r8=$1     ## Arg <REQUIRED>: Variable reference that contains the string that will be modified in-place.
	local     loop_PreviousStr=""
	while [[ -n "${varName_s74r8}" ]] && [[ "${varName_s74r8}" != "${loop_PreviousStr}" ]]; do
		loop_PreviousStr="${varName_s74r8}"
		varName_s74r8=${varName_s74r8//[$'\t\r\n ']/' '} #..........................................................: Replace whacky whitespace chars with a space.
		varName_s74r8="$(echo "${varName_s74r8}" | sed 's#\\#/#g' 2>/dev/null || true)" #...........................: Convert backslashes to forward slashes
		varName_s74r8="$(echo "${varName_s74r8}" | sed 's#/ #/#g' | sed 's# /#/#g' 2>/dev/null || true)" #..........: Remove space before and after slashes
		varName_s74r8="$(echo "${varName_s74r8}" | sed 's#//#/#g' 2>/dev/null || true)" #...........................: Replace two backslashes with one
		varName_s74r8="${varName_s74r8%/}" #........................................................................: Trim trailing slash
		varName_s74r8="$(sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//' 2>/dev/null <<< "${varName_s74r8}" || true)" #...: Trim leading and trailing whitespace
	done
:;}

fGetOgUserName(){
	##	Unit tests passed on: 20250704.
	##	Gets username, even if user is running as sudo - across just about any platform.
	##	Used by:
	##		_fLog_Init()
	local -n varName_s74rg=$1  ## Arg <REQUIRED>: Variable reference for result.
	local    retVal=""
	varName_s74rg=""
	{ [[ -z "${retVal}" ]] || [[ "root" == "${retVal,,}" ]]; } && retVal="${USER}"
	{ [[ -z "${retVal}" ]] || [[ "root" == "${retVal,,}" ]]; } && retVal="${SUDO_USER}"
	{ [[ -z "${retVal}" ]] || [[ "root" == "${retVal,,}" ]]; } && retVal="$(whoami  2>/dev/null || true)"
	{ [[ -z "${retVal}" ]] || [[ "root" == "${retVal,,}" ]]; } && retVal="$(logname 2>/dev/null || true)"
	[[ -z "${retVal}"   ]] && retVal="${USER}"  ## In case we need to get back to root.
	[[ -z "${retVal}"   ]] && fThrowError  "Could not figure out username. This could be a bug [¢Яēᛏ]."  "${FUNCNAME[0]}"
	varName_s74rg="${retVal}"
:;}

fGetOgUserHome(){
	##	Unit tests passed on: 20250704.
	##	Gets home dir, even if user is running as sudo - across just about any platform.
	##	Used by:
	##		_fLog_Init()
	local -n varName_s74rm=$1  ## Arg <REQUIRED>: Variable reference for result.
	local    userName="${2:-}"     ## Arg [optional]: Username. If blank will use fGetOgUserName().
	local    retVal=""
	[[ -z "${userName}" ]] && fGetOgUserName userName
	[[ -z "${retVal}" ]] && retVal="$(eval echo "~${userName}")"
	[[ -z "${retVal}" ]] && retVal="/home/${userName}"
	varName_s74rm="${retVal}"
:;}

fGetFileSize(){
	local -n varName_s73bq=$1                   ## Arg <REQUIRED>: Variable reference for result.
	local -r fileSpec="${2:-}"                      ## Arg <REQUIRED>: Filespec to get filesize of.
	local    unitDef="${3:-}"                       ## TODO: B [default], KB, MB, GB, TB, PB, EB, ZB, YB, KiB, MiB, GiB, TiB, PiB, EiB, ZiB, YiB.
	local -r thousandsSeparatorChar="${4:-}"        ## TODO
	varName_s73bq=-1
	[[ -z "${unitDef}" ]] && unitDef="B" ; local -r unitDef="${unitDef}"
	local wrking_fSize="$(stat --printf="%s" "${fileSpec}" 2> /dev/null || true)"
	grep -qP '^[0-9]+$' <<< "${wrking_fSize}" && varName_s73bq=$wrking_fSize
:;}

fGetFileTime_mtime(){
	##	Dependencies: fFormatTime_Linux_EpochAndMS()
	local -n   varName_s66kl=$1     ## Arg <REQUIRED>: Variable reference for result.
	local -r   fileSpec="${2:-}"        ## Arg <REQUIRED>: Filespec to get filesize of.
	local   -i msDigitPrecision=$3  ## Default to 6 [if input 0], which seems to be the most precise without n^64 floating-point error.
	varName_s66kl=""
	local wrking_mtime="$(date -r "${fileSpec}" '+%s.%N')"  ## Faster than Python
	local tmpResult=""
	fFormatTime_Linux_EpochAndMS  tmpResult  "${wrking_mtime}"  $msDigitPrecision
	varName_s66kl="${tmpResult}"
:;}

fConvertBase10to32c(){
	##	Unit tests passed on: 20250704.
	local -n varName_s74rp=$1     ## Arg <REQUIRED>: Variable reference for result.
	local -r input_InBase10="${2:-}"
	[[ -z "${1:-}" ]] && fThrowError "No parent variable name specified as first parameter to store return value in. [фǩǑǴ]"  "${FUNCNAME[0]}"
	[[ -v returnVariableName ]]      && fThrowError "No parent variable name specified as first parameter to store return value in. [фǩöÁ]"  "${FUNCNAME[0]}"
	[[ -z "${input_InBase10}" ]]     && fThrowError "No base-10 integer specified to convert. [фȟñŸ]"  "${FUNCNAME[0]}"
	[[ -z "$(echo "$input_InBase10" | grep -iPo '^[0-9]+$')" ]] && fThrowError "Expecting a base-10 integer as input, instead got '${input_InBase10}'. [фȟñĆ]"  "${FUNCNAME[0]}"
	local -r -a baseChars=(0 1 2 3 4 5 6 7 8 9 a b c d e f g h j k m n p q r s t v w x y z)
	local -i idx
	local    retVal=""
	## bc: 'obase' means 'output base', and for obase>16, bc returns a space-delimited string of base-10 numbers,
	##      a string which we'll interpret as an array, and the numbers which we'll treat as array indexes into base32c[].
	for item in $(bc <<< "obase=32; ${input_InBase10}"); do
		idx=$((10#$item)) #......................: Leading 0s get interpreted by bash as octal, so convert to base10 and strip off leading 0s.
		retVal="${retVal}${baseChars[${idx}]}" #...: Build base32c return string one character at a time.
	done
	varName_s74rp="${retVal}"
	:;}
fConvertBase10to256j1(){
	##	Unit tests passed on: 20250704.
	local -n varName_s74rt=$1    ## Arg <REQUIRED>: Variable reference for result.
	local -r input_InBase10="${2:-}"
	[[ -z "${1:-}" ]] && fThrowError "No parent variable name specified as first parameter to store return value in. [фǩŘЖ]"  "${FUNCNAME[0]}"
	[[ -v returnVariableName ]]      && fThrowError "No parent variable name specified as first parameter to store return value in. [фǩŇǵ]"  "${FUNCNAME[0]}"
	[[ -z "${input_InBase10}" ]]     && fThrowError "No base-10 integer specified to convert. [фǩöū]]"  "${FUNCNAME[0]}"
	[[ -z "$(echo "$input_InBase10" | grep -iPo '^[0-9]+$')" ]] && fThrowError "Expecting a base-10 integer as input, instead got '${input_InBase10}'. [фǩöȞ]"  "${FUNCNAME[0]}"
	local -ra baseChars=(0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p q r s t u v w x y z ʞ λ μ ᛎ ᛏ ᛘ ᛯ ᛝ ᛦ ᛨ ᚠ ᚧ ᚬ ᚼ 🜣 🜥 🜿 🝅 ▵ ▸ ▿ ◂ ҂ ‡ ± ⁑ ÷ ∞ ≈ ≠ Ω Ʊ Ξ ψ Ϡ δ ϟ Ћ Ж Я Ѣ ф ¢ £ ¥ § ¿ ɤ ʬ ⍤ ⍩ ⌲ ⍋ ⍒ ⍢ Â Ĉ Ê Ĝ Ĥ Î Ĵ Ô Ŝ Û Ŵ Ŷ Ẑ â ĉ ê ĝ ĥ î ĵ ô ŝ û ŵ ŷ ẑ Ã Ẽ Ĩ Ñ Õ Ũ Ỹ ã ẽ ĩ ñ õ ũ ỹ Ä Ë Ï Ö Ü Ẅ Ẍ Ÿ ä ë ï ö ü ẅ ẍ ÿ Á Ć É Ǵ Í Ń Ó Ŕ Ś Ú Ẃ Ý Ź á ć é ǵ í ń ó ŕ ś ú ẃ ý ź Ā Ē Ī Ō Ū Ȳ ā ē ī ō ū ȳ Ǎ Č Ď Ě Ǧ Ȟ Ǩ Ň Ǒ Ř Š Ǔ ǎ č ď ě ǧ ȟ ǩ ň ǒ ř š ǔ ǝ ɹ ʇ ʌ ₸ ᛬ 웃 유 ㅈ ㅊ ㅍ ㅎ ㅱ ㅸ ㅠ ソ ッ ゞ ぅ ぇ ォ)
	local -i idx
	local    retVal=""
	## bc: 'obase' means 'output base', and for obase>16, bc returns a space-delimited string of base-10 numbers,
	##      a string which we'll interpret as an array, and the numbers which we'll treat as array indexes into base32c[].
	for item in $(bc <<< "obase=256; ${input_InBase10}"); do
		idx=$((10#$item)) #......................: Leading 0s get interpreted by bash as octal, so convert to base10 and strip off leading 0s.
		retVal="${retVal}${baseChars[${idx}]}" #...: Build base32c return string one character at a time.
	done
	varName_s74rt="${retVal}"
	:;}

fMustBeInPath(){
	##	Unit tests passed on: 20250704.
	local -r programToCheckForInPath="${1:-}"
	if [[ -z "${programToCheckForInPath}" ]]; then
		fThrowError "Not program specified."  "${FUNCNAME[0]}"
	elif [[ -z "$(which ${programToCheckForInPath} 2>/dev/null || true)" ]]; then
		fThrowError "Not found in path: ${programToCheckForInPath}"
	fi
:;}

fIndent_abs_pipe(){
	## Pipe through this function to indent everything by $1 absolute spaces from the left.
	sed -e 's/^[ \t]*//' | sed "s/^/$(printf "%${1}s")/"
	}
fIndent_rltv_pipe(){
	## Pipe through this function to indent everything by $1 additional spaces left.
	sed "s/^/$(printf "%${1}s")/"
	}

fFormatTime_Linux_EpochAndMS(){
	##	Purpose:
	##		Return linux time as seconds since 1970 or whatever, plus decimal fractional seconds.
	##		If the input isn't formatted as just numbers [with optional decimal], return empty.
	##	Depended on by: fGetFileTime_mtime()
	##	Notes:
	##		- This was written before fGetFormattedNum().
	local -n varName_s66kk=$1     ## Arg <REQUIRED>: Variable reference for result.
	local    inputTime="${2:-}"       ## Arg <REQUIRED>: Input Linux epoch time (optionally with decimal milliseconds), to format.
	local -i msDigitPrecision=$3  ## Default to 6 [if input 0], which seems to be the most precise without n^64 floating-point error.
	varName_s66kk=""
	[[ $msDigitPrecision -le 0 ]] && msDigitPrecision=6 ; local -ri msDigitPrecision=$msDigitPrecision
	[[ -z "${inputTime}" ]] && return 0
	inputTime="$(grep -iPo '[0-9]+\.?[0-9]+' <<< "${inputTime}")"  ## Make sure we're only dealing with a positive integer or float.
	[[ -z "${inputTime}" ]] && return 0
	local -r inputTime="${inputTime}"
	local -r padZeros="$(printf "%0${msDigitPrecision}d" 0)"
	local inputTime_left=""
	local inputTime_right=""
	if grep -qP '^[0-9]+\.[0-9]+$' <<< "${inputTime}"; then  ## Proper decimal number
		## Get right and left of decimal.
		inputTime_left="${inputTime%%.*}"
		inputTime_right="${inputTime#*.}"
	else
		inputTime_left="$(grep -Po '[0-9]+' <<< "${inputTime}")"
	fi
	inputTime_right="${inputTime_right}${padZeros}"
	inputTime_right="${inputTime_right:0:${msDigitPrecision}}"
	[[ -n "${inputTime_left}" ]] && [[ -n "${inputTime_right}" ]] && varName_s66kk="${inputTime_left}.${inputTime_right}"
:;}


##	Purpose ..........: A little more safe rm. More checks, and optionally won't delete a non-empty dir.
##	Can be deleted? ..: Yes
##	Statefulness .....:
##	Input ............:
##	Function return...:
##	Stdout ...........:
##	StdErr ...........:
##	Other side-effects:
##	Notes ............:
##	Dependents .......: [none]
##	Dependencies .....: fThrowError()
##	Unit tests passed :
fSafer_rm(){
	local -r rmDir="${1:-}"            ## Arg <REQUIRED>: Dir to delete.
	local    raw_ignoreError="${2:-}"  ## Arg [optional]: Ignore error on rm. [Default 0]
	local    raw_mustBeEmpty="${3:-}"  ## Arg [optional]: Dir must be empty, or error. [Default 1]
	local -i ignoreError=0; [[ "${raw_ignoreError,,}" =~ "1"|"true" ]] && ignoreError=1; local -ri ignoreError=$ignoreError
	local -i mustBeEmpty=1; [[ "${raw_mustBeEmpty,,}" =~ "1"|"true" ]] && mustBeEmpty=1; local -ri mustBeEmpty=$mustBeEmpty
	[[   -z "${rmDir}"               ]] && fThrowError  "No folder to delete specified."
	[[ ! -d "${rmDir}"               ]] && fThrowError  "Folder to delete doesn't exist: '${rmDir}'."
	[[      "${rmDir}" == "/"        ]] && fThrowError  "I refuse to try to delete '/'!."
	[[      "${rmDir}" == "${HOME}"  ]] && fThrowError  "I refuse to try to delete '${HOME}/'!."
	[[      "${rmDir}" == "${HOME}/" ]] && fThrowError  "I refuse to try to delete '${HOME}/'!."
	if [[ $mustBeEmpty -eq 1 ]] && [[ -n "$(ls -A "${rmDir}" 2>/dev/null || true)" ]]; then
		fThrowError  "Can't delete non-empty folder '${rmDir}/'."
	fi
	fEcho "Removing folder '${rmDir}' ..."
	if [[ $ignoreError -eq 1 ]]; then
		rm -rf "${rmDir}" 2>/dev/null || true
	else
		rm -rf "${rmDir}"
	fi
:;}


##	Purpose ..........: Example function header
##	Can be deleted? ..:
##	Statefulness .....:
##	Input ............:
##	Function return...:
##	Stdout ...........:
##	StdErr ...........:
##	Other side-effects:
##	Notes ............:
##	Dependents .......:
##	Dependencies .....:
##	Unit tests passed :


#•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
##	Group purpose ....: Generic filesystem-reading/filtering functions (minified)
##	Can be deleted? ..: Yes.
##	Statefulness .....: Each caller holds their own state.
##	Input ............:
##	Function return...:
##	Stdout ...........:
##	StdErr ...........:
##	Other side-effects:
##	Notes ............:
##	Dependents .......:
##	Dependencies .....:
##	Unit tests passed :
fFilesys_AddFilterDef(){  ## Filters are processed in order, so the that inclusive and exclusive filters are added purposely matters very much.
	local -n  varFilterArr_s75n2=$1  ## Arg <REQUIRED>: Variable reference of regex filter array. Just an array created by caller, held in context by caller, but managed by fFilesys_AddFilterDef().
	local -r  regEx="${2:-}"             ## Arg <REQUIRED>: String regular expression, compatible with 'grep -P'
	local     excOrInc="${3:-}"          ## Arg [optional]: [+|-]. '+' [default] for inclusive filter that keeps only matches, '-' for exclusive filter that removes matches.
	local     caseSensitive="${4:-}"     ## Arg [optional]: [i|s]. 'i' for insensitive [default], 's' for case-sensitive.
	[[ -z "${excOrInc}" ]] && excOrInc='+' ; [[ -z "${caseSensitive}" ]] && caseSensitive='i'
	#fEchoVarAndVal regEx ; fEchoVarAndVal excOrInc ; fEchoVarAndVal caseSensitive
	[[ -n "${regEx}" ]]                         || fThrowError "Must include a regular expression as the second argument."     "${FUNCNAME[0]}"
	grep -qiP '^[\+\-]$' <<< "${excOrInc}"      || fThrowError "The third argument (in|exclusive filter) must be '+' or '-'."  "${FUNCNAME[0]}"
	grep -qiP '^[is]$'   <<< "${caseSensitive}" || fThrowError "The fourth argument (case-sensitivity) must be 'i' or 's'."    "${FUNCNAME[0]}"
	varFilterArr_s75n2+=("${excOrInc}${caseSensitive,,}${regEx}") ;:;}
fFilesys_DoScan(){
	local -n varFsList_s75hb=$1          ## Arg <REQUIRED>: Variable reference to append results to. May already have existing results.
	local -n varFilterArr_s75hb=$2       ## Arg <REQUIRED>: Variable reference of regex filter array. Just an array created by caller, held in context by caller, but managed by fFilesys_AddFilterDef().
	local -r arg_scanPath="${3:-}"           ## Arg <REQUIRED>: Path to scan at and below.
	local    scanBits="${4:-}"               ## Arg [optional]: Coded string for one or more object types: [f]ile, [d]ir, [l]ink, [i]nvalid link, [e]xecutable files, named [p]ipe, [s]ocket, [c]haracter dev, [b]lock dev
	local    scanPath="${arg_scanPath}"
	fNormalizePath scanPath
	local -r scanPath="${scanPath}"
	[[ -n "${scanPath}" ]]  || fThrowError "Required path arg can't be empty."                   "${FUNCNAME[0]}"
	[[ -d "${scanPath}" ]]  || fThrowError "Directory doesn't seem to exist: '${arg_scanPath}'"  "${FUNCNAME[0]}"
	grep -qiPo '[fdliepscb]' <<< "${scanBits}" && scanBits="f"; local -r scanBits="${scanBits}"  ## Default to [f]ile.
	if ((! doQuietly)); then
		echo -n "[ Scanning '${scanPath}' ..."
		local -i startSecs=0  stopSecs=0  listCount=0
		local    tmpResult=""  etSecs=""  statsOutput=""
		startSecs=$(date +%s.%N)
	fi
	__pFilesys_DoScan_Sub  tmpResult  "${scanPath}"  "${scanBits}"  'f'  '-type  f'
	__pFilesys_DoScan_Sub  tmpResult  "${scanPath}"  "${scanBits}"  'd'  '-type  d'
	__pFilesys_DoScan_Sub  tmpResult  "${scanPath}"  "${scanBits}"  'l'  '-type  l'
	__pFilesys_DoScan_Sub  tmpResult  "${scanPath}"  "${scanBits}"  'i'  '-xtype l'
	__pFilesys_DoScan_Sub  tmpResult  "${scanPath}"  "${scanBits}"  'e'  '-type  f -executable'
	__pFilesys_DoScan_Sub  tmpResult  "${scanPath}"  "${scanBits}"  's'  '-type  s'
	__pFilesys_DoScan_Sub  tmpResult  "${scanPath}"  "${scanBits}"  'p'  '-type  p'
	__pFilesys_DoScan_Sub  tmpResult  "${scanPath}"  "${scanBits}"  'c'  '-type  c'
	__pFilesys_DoScan_Sub  tmpResult  "${scanPath}"  "${scanBits}"  'b'  '-type  b'
	if ((! doQuietly)); then
		listCount=$(wc -l <<< "${tmpResult}")
		stopSecs=$(date +%s.%N)

		etSecs=$((stopSecs - startSecs)) ; statsOutput=""



		((etSecs > 1)) && statsOutput=" in $(printf "%'d\n" ${etSecs}) seconds)"
		statsOutput=" (considering $(printf "%'d\n" $listCount) items${statsOutput}). ]"
		echo "${statsOutput}"
		echo -n "[ sorting and filtering ..."
		startSecs=$(date +%s.%N)
	fi
	tmpResult="$(sort -u <<< "${tmpResult}" | awk 'NF')"  ## Sort while also removing duplicates, and empty lines
	fFilesys_ApplyFilters tmpResult varFilterArr_s75hb
	if [[ -n "${tmpResult}" ]]; then
		[[ -n "${varFsList_s75hb}" ]] && varFsList_s75hb="${varFsList_s75hb}"$'\n'
		varFsList_s75hb="${varFsList_s75hb}${tmpResult}"
	fi
	if ((! doQuietly)); then
		listCount=$(wc -l <<< "${tmpResult}")
		stopSecs=$(date +%s.%N)
		etSecs=$((stopSecs - startSecs)) ; statsOutput=""

		((etSecs > 1)) && statsOutput=" in $(printf "%'d\n" ${etSecs}) seconds)"
		echo " (filtered down to $(printf "%'d\n" $listCount) items${statsOutput}). ]"
		fEcho_ResetBlankCounter
	fi ;:;}
fFilesys_ApplyFilters(){ :  ## Only need to call explicitly, if user builds their own filesystem list outside of fFilesys_DoScan().
	local -n varFsList_s75mz=$1     ## Arg <REQUIRED>: Variable reference to filesystem list. May be modified in-place.
	local -n varFilterArr_s75mz=$2  ## Arg <REQUIRED>: Variable reference of regex filter array. Just an array created by caller, held in context by caller, but managed by fFilesys_AddFilterDef().

	[[ -z "${varFsList_s75mz}" ]] && return 0  ## No files to filter so just return
	{ [[ -z "${varFilterArr_s75mz}" ]] || [[ "${#varFilterArr_s75mz[@]}" -lt 1 ]]; } && return 0  ## No filters specified so just return.

	local bits_IncExc_CaseSens=""
	local regEx=""

	for filterItem in "${varFilterArr_s75mz[@]}"; do
		[[ -z "${filterItem}"        ]] && continue
		[[    "${#filterItem}" -lt 3 ]] && fThrowError "Encountered a filter item in array that has no regex portion [¢£Śɤ]."  "${FUNCNAME[0]}"

		bits_IncExc_CaseSens="${filterItem:0:2}"
		regEx="${filterItem:2}"

		case "${bits_IncExc_CaseSens}" in
			"+s") varFsList_s75mz="$(grep  -P    "${regEx}" <<< "${varFsList_s75mz}" || true)" ;;
			"+i") varFsList_s75mz="$(grep  -Pi   "${regEx}" <<< "${varFsList_s75mz}" || true)" ;;
			"-s") varFsList_s75mz="$(grep  -Pv   "${regEx}" <<< "${varFsList_s75mz}" || true)" ;;
			"-i") varFsList_s75mz="$(grep  -Piv  "${regEx}" <<< "${varFsList_s75mz}" || true)" ;;
			*)    fThrowError "Unknown inc/exc and/or case-sensitive encoding characters encounted in filter definition: '${bits_IncExc_CaseSens}' [¢£Śǝ]."  "${FUNCNAME[0]}" ;;
		esac

	done
:;}
__pFilesys_DoScan_Sub(){
	local -n tmpResult_s75hg=$1; local -r scanPath="${2:-}"; local -r scanBits="${3:-}"; local -r whatBit="${4:-}"; local -r findArg="${5:-}"
	if grep -qio "${whatBit}" <<< "${scanBits}"; then
		[[ -n "${tmpResult_s75hg}" ]] && tmpResult_s75hg="${tmpResult_s75hg}"$'\n'
		tmpResult_s75hg="${tmpResult_s75hg}$(eval "find  '${scanPath}'  ${findArg}  2>/dev/null || true")"
	fi ;:;}


#•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
##	Group purpose ....: Generic timer functions (minified).
##	Can be deleted? ..: Yes. External unit-test scripts will break, but not this script.
##	Statefulness .....: Each caller holds their own state.
##	Input ............:
##	Function return...:
##	Stdout ...........:
##	StdErr ...........:
##	Other side-effects:
##	Notes ............:
##	Dependents .......:
##	Dependencies .....:
##	Unit tests passed :
fTimer_Start(){
	local -n varName_s76aj=$1   ## Arg <REQUIRED>: Variable reference to start time. Must be a STRING, as a floating-point is stored.
	varName_s76aj="$(date +%s.%N)" ;:; }
fTimer_Stop(){
	local -n varName_s76ak=$1   ## Arg <REQUIRED>: Variable reference to elapsed time. Must be a STRING, as a floating-point is stored.
	varName_s76aj="$(date +%s.%N)" ;:; }
fTimer_GetET(){
	local -n  varName_s76am=$1   ## Arg <REQUIRED>: Variable reference to elapsed time. Must be a STRING, as a formatted string is returned.
	local -r  timerStart="${2:-}"    ## Arg <REQUIRED>: Value from fTimer_Start()
	local -r  timerStop="${3:-}"     ## Arg <REQUIRED>: Value from fTimer_Stop()
	local -r  arg_doFormat=$4    ## Arg [optional]: Default=1.  1 = yes format output; 0 = no just return raw 'seconds.milliseconds'.
	local -r  timeUnit="${5:-}"      ## Arg [optional]: Default=[A]uto. Or [MILLI]seconds, [S]econds, [MIN]utes, [H]ours, [D]ays, [W]eeks, [MO]nths, [Y]ears, [C]enturies, [MILLEN]enia.
	local -ri decimalDigits=$6   ## Arg [optional]: Number of digits to round to. If doFormat=1, then default=2. (If doFormat=0, no rounding.)
	local -i doFormat=0
	{ [[ -z "${arg_doFormat}" ]] || [[ "${arg_doFormat}" == "1" ]]; } && doFormat=0 ; local -ri doFormat=$doFormat
	local elapsedTime="$(awk -v s="$timerStart" -v e="$timerStop" 'BEGIN { print e - s }')"
	if ((doFormat)); then
		[[ -z "${timeUnit}" ]] && timeUnit="a"
		if [[ "${timeUnit}" == "a" ]]; then
			## Figure out best automatic time unit, depending on elapsed milliseconds.
			local elapsedMSint="$(awk '{ print $1 * 1000 }' <<< "${elapsedTime}")"
			local -i elapsedMSint=${elapsedMS%%'.'*}
		#	local -i lenMSint=${#elapsedMSint}
		#	if   ((elapsedMSint >             )); then timeUnit='millennia'     ## MS len=14 digits
		#	elif ((elapsedMSint >             )); then timeUnit='centuries'     ## MS len=13
			if   ((elapsedMSint > 63113904000 )); then timeUnit='years'         ## MS len=11 ; min=2      , max=[none]   , min MS 63113904000
			elif ((elapsedMSint > 31556952000 )); then timeUnit='months'        ## MS len=10 ; min=12     , max=24       , min MS 31556952000
		#	elif ((elapsedMSint >             )); then timeUnit='weeks'         ## MS len=9  ; n/a        , n/a          , min MS n/a
			elif ((elapsedMSint > 86400000    )); then timeUnit='days'          ## MS len=8  ; min=2      , max=1 year   , min MS 86400000
			elif ((elapsedMSint > 3600000     )); then timeUnit='hours'         ## MS len=7  ; min=1      , max=24       , min MS 3600000
			elif ((elapsedMSint > 60000       )); then timeUnit='minutes'       ## MS len=5  ; min=1      , max=60       , min MS 60000
			elif ((elapsedMSint > 100         )); then timeUnit='seconds'       ## MS len=4  ; min=0.1    , max=60       , min MS 100
			else                                       timeUnit='milliseconds'  ## MS len=1  ; min=[none] , max=100      , min MS [none]
			fi
		fi
		case "${timeUnit,,}" in
			## Convert elapsed time to specified time unit.
			"s"*)          : ;;  ## Already in seconds
			"ms"|"milli"*) elapsedTime="$(awk '{ print $1 * 1000        }' <<< "${elapsedTime}")" ;;
			"mille"*)      elapsedTime="$(awk '{ print $1 / 31556952000 }' <<< "${elapsedTime}")"  ;;
			"mo"*)         elapsedTime="$(awk '{ print $1 / 2629746     }' <<< "${elapsedTime}")"  ;;
			"m"*)          elapsedTime="$(awk '{ print $1 / 60          }' <<< "${elapsedTime}")"  ;;
			"h"*)          elapsedTime="$(awk '{ print $1 / 3600        }' <<< "${elapsedTime}")"  ;;
			"d"*)          elapsedTime="$(awk '{ print $1 / 86400       }' <<< "${elapsedTime}")"  ;;
			"w"*)          elapsedTime="$(awk '{ print $1 / 604800      }' <<< "${elapsedTime}")"  ;;
			"y"*)          elapsedTime="$(awk '{ print $1 / 31556952    }' <<< "${elapsedTime}")"  ;;
			"c"*)          elapsedTime="$(awk '{ print $1 / 3155695200  }' <<< "${elapsedTime}")"  ;;
			*)             fThrowError "Unrecognized time unit specified: '${timeUnit}'. [¢¥ĩǵ]"  "${FUNCNAME[0]}" ;;
		esac
	fi

#	printf "%'.6f seconds\n" "$elapsed" | sed -E 's/\.?0+$//'

:;}


##	Group purpose ....: Generig debugging, tracing, and future profiling (minified).
##	Can be deleted? ..: Yes. There is no default template use of any of it.
##	Statefulness .....: Single global state.
##	Input ............:
##	Function return...:
##	Stdout ...........:
##	StdErr ...........:
##	Other side-effects:
##	Notes ............: Doesn't yet profile call path count and timing, only tracing.
##	Dependents .......:
##	Dependencies .....:
##	Unit tests passed :
if ((doDebug)); then
declare -ri _dbgIndentEachLevelBy=4
declare  -i _dbgNestLevel=0
declare  -i _dbgTemporarilyDisableEcho=0
function fdbgEnter(){
	if [[ ${doDebug} -eq 1 ]]; then
		local    -r functionName="${1:-}"
		local    -r extraText="${2:-}"
		local -i    dontEchoToStdout=0; if [[ -n "${3:-}" ]] && [[ $3 =~ ^[0-9]+$ ]]; then dontEchoToStdout=$3; fi
		local       output=""
		if [[ -n "$functionName" ]]; then output=".$functionName()"; fi
		output="Entered ${meName}${output}"
		if [[ -n "$extraText" ]]; then output="$output [${extraText}]"; fi
		output="▸ $output:"
		if [[ $dontEchoToStdout -eq 0 ]]; then fdbgEcho "${output}"; fi
		if [[ _dbgNestLevel -lt 0 ]]; then _dbgNestLevel=0; fi
		_dbgNestLevel=$((_dbgNestLevel+1))
	fi ;:;}
function fdbgEgress(){
	if [[ ${doDebug} -eq 1 ]]; then
		local    -r functionName="${1:-}"
		local    -r extraText="${2:-}"
		local -i    dontEchoToStdout=0; if [[ -n "${3:-}" ]] && [[ $3 =~ ^[0-9]+$ ]]; then dontEchoToStdout=$3; fi
		local       output=""
		_dbgNestLevel=$((_dbgNestLevel-1))
		if [[ _dbgNestLevel -lt 0 ]]; then _dbgNestLevel=0; fi
		if [[ -n "$functionName" ]]; then output=".$functionName()"; fi
		output="Egressed ${meName}${output}"
		if [[ -n "$extraText" ]]; then output="$output [${extraText}]"; fi
		output="◂ $output."
		if [[ $dontEchoToStdout -eq 0 ]]; then fdbgEcho "$output"; fi

	fi ;:;}
function fdbgEcho(){
	if [[ ${doDebug} -eq 1 ]] && [[ $_dbgTemporarilyDisableEcho -ne 1 ]]; then
		fEcho_Clean "$*"
	fi ;:;}
function fdbgEchoVarAndVal(){
	if [[ "${doDebug}" -eq 1 ]]; then
		local -r varName="${1:-}"
		local -r optionalPrefix="${2:-}"
		local    outputStr=""
		if [[ -n "$optionalPrefix" ]]; then outputStr="$optionalPrefix"; fi
		outputStr="${outputStr}${varName} = '${!varName}'"
		fdbgEcho "$outputStr"
	fi ;:;}
fi







#•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
## Execution entry point (do not modify)
#•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••

## Error and exit settings
 set -u  ## Require variable declaration. Stronger than mere linting. But can struggle if functions are in sourced files.
 set -e  #..........................................: Exit on errors. This is inconsistent (made a little better with settings below), so eventually may move to 'set +e' (which is more constant work and mental overhead).
 set -E  #..........................................: Propagate ERR trap settings into functions, command substitutions, and subshells.
 shopt -s inherit_errexit  #........................: Propagate 'set -e' ........ into functions, command substitutions, and subshells. Will fail on Bash <4.4.
 set -o pipefail  #.................................: Make sure all stages of piped commands also fail the same.

## Check if sourced
declare -i isSourced
(return 0 2>/dev/null) && isSourced=1 || isSourced=0
declare -ri isSourced=$isSourced

## Generic global variables that shouldn't be changed.
declare -r mePath="${0}"
declare -r meName="$(basename "${mePath}")"
declare -r serialDT="$(date "+%Y%m%d-%H%M%S")"
declare -r reentrantKey="yn51wXTOLh8PmYH04FW7m3Fmxp3sif5e"  ## Not a security thing, just teensy extra effort to make sure we know we want to run reentrantly as sudo.

## Startup routing.
if [[ "${1:-}" =~ -(unittest|unitest|unit-test|test|test)-(t|g) ]] && fIsFunction fUnitTest_Toolbox; then  ## '--unittest-toolbox'
	fUnitTest_Toolbox "${2:-}" "${3:-}" "${4:-}" "${5:-}" "${6:-}" "${7:-}" "${8:-}" "${9:-}" "${10:-}" "${11:-}" "${12:-}" "${13:-}" "${14:-}" "${15:-}" "${16:-}" "${17:-}" "${18:-}" "${19:-}" "${20:-}" "${21:-}" "${22:-}" "${23:-}" "${24:-}" "${25:-}" "${26:-}" "${27:-}" "${28:-}" "${29:-}" "${30:-}" "${31:-}" "${32:-}" "${33:-}"
elif [[ "${1:-}" =~ -(unittest|unitest|unit-test) ]] && fIsFunction fUnitTest_User; then ## '--unittest'
	fUnitTest_User "${2:-}" "${3:-}" "${4:-}" "${5:-}" "${6:-}" "${7:-}" "${8:-}" "${9:-}" "${10:-}" "${11:-}" "${12:-}" "${13:-}" "${14:-}" "${15:-}" "${16:-}" "${17:-}" "${18:-}" "${19:-}" "${20:-}" "${21:-}" "${22:-}" "${23:-}" "${24:-}" "${25:-}" "${26:-}" "${27:-}" "${28:-}" "${29:-}" "${30:-}" "${31:-}" "${32:-}" "${33:-}"
elif [[ "${1:-}" == "REENTRANT_${reentrantKey}" ]]; then ## Reentrant as sudo or another user, run function defined it $2
	$2 "${3:-}" "${4:-}" "${5:-}" "${6:-}" "${7:-}" "${8:-}" "${9:-}" "${10:-}" "${11:-}" "${12:-}" "${13:-}" "${14:-}" "${15:-}" "${16:-}" "${17:-}" "${18:-}" "${19:-}" "${20:-}" "${21:-}" "${22:-}" "${23:-}" "${24:-}" "${25:-}" "${26:-}" "${27:-}" "${28:-}" "${29:-}" "${30:-}" "${31:-}" "${32:-}" "${33:-}" "${34:-}"
else ## Regular
	fInit "${1:-}" "${2:-}" "${3:-}" "${4:-}" "${5:-}" "${6:-}" "${7:-}" "${8:-}" "${9:-}" "${10:-}" "${11:-}" "${12:-}" "${13:-}" "${14:-}" "${15:-}" "${16:-}" "${17:-}" "${18:-}" "${19:-}" "${20:-}" "${21:-}" "${22:-}" "${23:-}" "${24:-}" "${25:-}" "${26:-}" "${27:-}" "${28:-}" "${29:-}" "${30:-}" "${31:-}" "${32:-}"
fi
