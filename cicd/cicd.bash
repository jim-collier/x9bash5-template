#!/bin/bash
#  shellcheck disable=2001  ## 'See if you can use ${variable//search/replace} instead.' Complains about good uses of sed.
#  shellcheck disable=2016  ## 'Expressions don't expand in single quotes, use double quotes for that.' I know, and I often want an explicit '$'.
#  shellcheck disable=2034  ## 'variable appears unused.' Complains about valid use of variable indirection (e.g. later use of local -n var=$1)
#  shellcheck disable=2046  ## 'Quote to prevent word-splitting.' (OK for integers.)
#  shellcheck disable=2086  ## 'Double quote to prevent globbing and word splitting.' (OK for integers.)
#  shellcheck disable=2119  ## 'Use foo "$@" if function's $1 should mean script's $1.' Confusing and inapplicable.
#  shellcheck disable=2120  ## 'Foo references arguments, but none are ever passed.' Valid function argument overloading.
#  shellcheck disable=2128  ## 'Expanding an array without an index only gives the element in the index 0.' False hits on associative arrays.
#  shellcheck disable=2155  ## 'Declare and assign separately to avoid masking return values.' Cumbersome and unnecessary. For integers it's sometimes required to even come into existence for counters.
#  shellcheck disable=2162  ## 'read without -r will mangle backslashes.'
#  shellcheck disable=2178  ## 'Variable was used as an array but is now assigned a string.' False hits on associative arrays with e.g. 'local -n assocArray=$1'.
#  shellcheck disable=2181  ## 'Check exit code directly, not indirectly with $?.'
#  shellcheck disable=2317  ## 'Can't reach.' (I.e. an 'exit' is used for debugging - and makes an unusable visual mess.)
## shellcheck disable=2002  ## 'Useless use of cat.'
## shellcheck disable=2004  ## '$/${} is unnecessary on arithmetic variables.' Inappropriate complaining?
## shellcheck disable=2053  ## 'Quote the right-hand sid of = in [[ ]] to prevent glob matching.' Disable for Yoda Notation.
## shellcheck disable=2143  ## 'Use grep -q instead of echo | grep'

##	Purpose: Wrapper for build, test, copy to local for dogfood, push to github. Calls test.sh, no need to call that separately.
##	History: At bottom of this file. (Note: History for this is maintained outside of [or in addition to] git project.)

##	Copyright © 2022-2026 Jim Collier (ID: 1cv◂‡Vᛦ)
##	Licensed under the GNU General Public License v2.0 or later. Full text at:
##		https://spdx.org/licenses/GPL-2.0-or-later.html
##	SPDX-License-Identifier: GPL-2.0-or-later


#•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
## Constants
if [[ -z "${doQuietly+x}" ]]; then

	## Settings (relative paths defined here will be verified and resolved later)
	declare    dirPath_Base=".."
	declare    dirPath_Source="${dirPath_Base}/bin"
	declare    filePath_ResultingExecToTestAndInstall="${dirPath_Base}/bin/template.bash"
	declare    dirAlsoCopyInstall_Subdir_Source="${dirPath_Base}/bin/include"
	declare    dirAlsoCopyInstall_Subdir_Target="include"
	declare    filePath_TesterExec="${dirPath_Base}/cicd/test.bash"
	declare    gitAutomationScript="${dirPath_Base}/cicd/utility/n8git_backup-and-publish"
	declare -a preferredInstallTargetPaths=("${HOME}/synced/0-0/common/exec/util/linux/bash"  "/usr/local/sbin/")  ## First one that exists, wins
	declare -i isCompileProject=0  ## 1: E.g. C++, Rust, Go, etc.  0: E.g. Python, Bash, etc.

	## Generic constants
	declare  -i doQuietly=0
	declare  -i doPromptToContinue=1
	declare -r  thisVersion="1.0.0-beta3"         ## Put you script's semantic version here.
	declare -r  thisBuild="1n0qcy6"
	declare -r  thisCopyrightYear="2026"           ## Put your copyright date here.
	declare -r  thisAuthor="Jim Collier"           ## Put your copyright name here.
	declare -ri atLeastOneArgRequired=0
	declare -ri doAsSudo=0

fi


## Version, copyright, about, syntax (minified but not obfuscated)
## Note: Echoing rather than HEREDOC is preferrable because - while slower - that's not
##       an issue in this context, and more importantly, HEREDOC is too hard to manage
##       indentation, esp. for the fSyntax() section.
declare -i wasShown_Version=0 wasShown_Copyright=0 wasShown_About=0 wasShown_Syntax=0

fVersion(){ { ((doQuietly)) || ((wasShown_Version)); } && return; wasShown_Version=1;
	fEcho_Clean "${meName} v${thisVersion} build ${thisBuild}" ;:;}

fCopyright(){ { ((doQuietly)) || ((wasShown_Copyright)); } && return; wasShown_Copyright=1;
	fEcho_Clean ""
	fEcho_Clean "${meName}, Copyright © ${thisCopyrightYear} ${thisAuthor}."  ## Don't show version info. Can confuse with the version of the product being built.
	fEcho_Clean "Licensed under the GNU General Public License v2.0 or later. Full text at:"
	fEcho_Clean "  https://spdx.org/licenses/GPL-2.0-or-later.html"
	fEcho_Clean "No warranty."
	fEcho_Clean "" ;:;}

fAbout(){ { ((doQuietly)) || ((wasShown_About)); } && return; wasShown_About=1;
	fEcho_Clean ""
	#           X-------------------------------------------------------------------------------X
	fEcho_Clean "CI/CD and dogfood:"
	if ((isCompileProject)); then
		fEcho_Clean "  • Builds the program. If successful:"
		fEcho_Clean "  • Cross-compile more versions. If those succeed:"
	fi
	fEcho_Clean "  • Run automated tests. If tests pass:"
	fEcho_Clean "  • Update locally-installed version to what was just compiled for dogfood."
	fEcho_Clean "  • Run git automation script (e.g. commit and push)."
	#           X-------------------------------------------------------------------------------X
	fEcho_Clean "" ;:;}

fSyntax(){  { ((doQuietly)) || ((wasShown_Syntax)); } && return; wasShown_Syntax=1;
	fEcho_Clean ""
	#           X-------------------------------------------------------------------------------X
	fEcho_Clean "Arguments:"
	fEcho_Clean "  --quiet"
	fEcho_Clean "      [optional]: Be less verbose, and don't prompt user to continue."
	fEcho_Clean "  --help, --version [or -h, -v]"
	#           X-------------------------------------------------------------------------------X
	fEcho_Clean "" ;:;}


#••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
fMain(){

	## Settings

	## Validate dependencies
	fMustBeInPath realpath
	fMustBeInPath trash

	## Determine first valid preferred install path
	local installPath=""
	for nextPath in "${preferredInstallTargetPaths[@]}"; do
		if [[ -d "${nextPath}" ]]; then
			installPath="${nextPath}"
			[[ -n "${dirAlsoCopyInstall_Subdir_Target}" ]]  &&  dirAlsoCopyInstall_Subdir_Target="${installPath}/${dirAlsoCopyInstall_Subdir_Target%%/}"
			break
		fi
	done;:

	## Resolve settings to full canonical paths
	fResolvePath_v1  dirPath_Base                            "${dirPath_Base}"                            ; readonly dirPath_Base
	fResolvePath_v1  dirPath_Source                          "${dirPath_Source}"                          ; readonly dirPath_Source
	fResolvePath_v1  filePath_ResultingExecToTestAndInstall  "${filePath_ResultingExecToTestAndInstall}"  ; readonly filePath_ResultingExecToTestAndInstall
	fResolvePath_v1  filePath_TesterExec                     "${filePath_TesterExec}"                     ; readonly filePath_TesterExec
	fResolvePath_v1  gitAutomationScript                     "${gitAutomationScript}"                     ; readonly gitAutomationScript
	fResolvePath_v1  dirAlsoCopyInstall_Subdir_Source        "${dirAlsoCopyInstall_Subdir_Source}"        ; readonly dirAlsoCopyInstall_Subdir_Source
	fResolvePath_v1  installPath                             "${installPath}"                             ; readonly installPath
	fResolvePath_v1  dirAlsoCopyInstall_Subdir_Target        "${dirAlsoCopyInstall_Subdir_Target}"  0     ; readonly dirAlsoCopyInstall_Subdir_Target

	## Validate paths
	[[ -d "${meDir}"                ]]  ||  fThrowError "Path not found: '${meDir}'"
	[[ -d "${dirPath_Base}"         ]]  ||  fThrowError "Path not found: '${dirPath_Base}'"
	[[ -d "${dirPath_Source}"       ]]  ||  fThrowError "Path not found: '${dirPath_Source}'"
	[[ -f "${filePath_TesterExec}"  ]]  ||  fThrowError "File not found: '${filePath_TesterExec}'"
	[[ -n "${gitAutomationScript}"  ]]  ||  fThrowError "Git automation script not found where specified or in path: '${gitAutomationScript}'."

	## Prompt to continue
	if ((! doQuietly)); then
		fCopyright
		fAbout
		fEcho_Clean "Base directory ...............: ${dirPath_Base}/"
		fEcho_Clean "Source directory .............: ${dirPath_Source}/"
		if [[ -n "${filePath_ResultingExecToTestAndInstall}" ]]; then
			if ((isCompileProject)); then
				fEcho_Clean "Executable to build etc. .....: ${filePath_ResultingExecToTestAndInstall}"
			else
				fEcho_Clean "Executable to test and install: ${filePath_ResultingExecToTestAndInstall}"
			fi
		fi
		if [[ -n "${dirAlsoCopyInstall_Subdir_Source}" ]]; then
			fEcho_Clean "Also install subdir source ...: ${dirAlsoCopyInstall_Subdir_Source}/"
		fi
		if [[ -n "${installPath}" ]]; then
			fEcho_Clean "Install path .................: ${installPath}/"
			if [[ -n "${dirAlsoCopyInstall_Subdir_Target}" ]]; then
				fEcho_Clean "Also to subdir target ........: ${dirAlsoCopyInstall_Subdir_Target}/"
			fi
		fi
		fEcho_Clean "Test script ..................: ${filePath_TesterExec}"
		fEcho_Clean "Git commit and push script ...: ${gitAutomationScript}"
		fIntroPromptToContinue  ""
		fEcho_Clean
	fi

	####
	#### MAKEITSO
	####

	cd "${dirPath_Base}"
	pushd "${dirPath_Source}" 1>/dev/null

	if ((isCompileProject)); then

		## make
		fEcho "$(date "+%Y%m%d-%H%M%S") make: Starting ..."
		make
		fEcho "$(date "+%Y%m%d-%H%M%S") Minimal execution test ..."
		"${filePath_ResultingExecToTestAndInstall}"  --version
		sleep 1  ## Long enough to see version

		## Hide single exe
		[[ -f "${filePath_ResultingExecToTestAndInstall}_staged" ]]  &&  trash "${filePath_ResultingExecToTestAndInstall}_staged"
		mv "${filePath_ResultingExecToTestAndInstall}"  "${filePath_ResultingExecToTestAndInstall}_staged"

		## Make release (part of testing - if they don't cross-compile then there' a problem)
		fEcho
		fEcho "$(date "+%Y%m%d-%H%M%S") make release: Starting ..."
		make release
		fEcho_ResetBlankCounter

		##Unhide single executable for testing and local installation
		mv "${filePath_ResultingExecToTestAndInstall}_staged"  "${filePath_ResultingExecToTestAndInstall}"

	fi

	## Test
	fEcho "$(date "+%Y%m%d-%H%M%S") Test: Starting ..."
	"${filePath_TesterExec}"
	fEcho_ResetBlankCounter

	popd 1>/dev/null

	## If passed testing, install locally (dogfood it)
	if [[ -n "${filePath_ResultingExecToTestAndInstall}"  &&  -n "${installPath}" ]]; then
		fEcho "$(date "+%Y%m%d-%H%M%S") Installing locally to '${installPath}' ..."
		if [[ "${installPath}" == "${HOME}/"* ]]; then

			## Install within ${HOME} without sudo
echo			cp -a --reflink=auto "${filePath_ResultingExecToTestAndInstall}"  "${installPath%%/}/"
			if [[ -n "${dirAlsoCopyInstall_Subdir_Source}"  &&  -n "${dirAlsoCopyInstall_Subdir_Target}" ]]; then
				## Also subdir
				[[ -d "${dirAlsoCopyInstall_Subdir_Target}" ]] || mkdir -p "${dirAlsoCopyInstall_Subdir_Target}"
echo				rsync -rulEXt "${dirAlsoCopyInstall_Subdir_Source%%/}/"  "${dirAlsoCopyInstall_Subdir_Target%%/}/"
			fi

		else

			## Install elsewhere, falling back to sudo if necessary
			cp -a --reflink=auto "${filePath_ResultingExecToTestAndInstall}"  "${installPath%%/}/" 2>/dev/null  || \
				sudo cp -a --reflink=auto "${filePath_ResultingExecToTestAndInstall}"  "${installPath%%/}/"
			if [[ -n "${dirAlsoCopyInstall_Subdir_Source}"  &&  -n "${dirAlsoCopyInstall_Subdir_Target}" ]]; then
				## Also subdir, falling back to sudo if necessary
				[[ -d "${dirAlsoCopyInstall_Subdir_Target}" ]] || { mkdir -p "${dirAlsoCopyInstall_Subdir_Target}" 2>/dev/null  || sudo mkdir -p "${dirAlsoCopyInstall_Subdir_Target}"; }
				rsync -rulEXt "${dirAlsoCopyInstall_Subdir_Source%%/}/"  "${dirAlsoCopyInstall_Subdir_Target%%/}/" 2>/dev/null  || \
					sudo rsync -rulEXt "${dirAlsoCopyInstall_Subdir_Source%%/}/"  "${dirAlsoCopyInstall_Subdir_Target%%/}/"
			fi

		fi

		if [[ -n "${dirAlsoCopyInstall_Subdir_Source}"  &&  -n "${dirAlsoCopyInstall_Subdir_Target}" ]]; then
			## Show results; also subdir
			fEcho; fEcho "ls '${filePath_ResultingExecToTestAndInstall}'):"
			ls  -lA  --color=always  --human-readable  --time-style=+"%Y-%m-%d %H:%M:%S"  "${dirAlsoCopyInstall_Subdir_Target%%/}/"
			fEcho_ResetBlankCounter
		fi

		## Show results; main executable
		fEcho; fEcho "ls \$(which '$(basename "${filePath_ResultingExecToTestAndInstall}")'):"
		ls  -lA  --color=always  --human-readable  --time-style=+"%Y-%m-%d %H:%M:%S"  "$(which "$(basename "${filePath_ResultingExecToTestAndInstall}")")"
		fEcho_ResetBlankCounter
	fi

	## Git automation script (e.g. commit, push)
	"${gitAutomationScript}"

	((! doQuietly)) && { fEcho "${meName}: Done."; fEcho; }
:;}


#••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
fCleanup(){
	if ((! doQuietly)); then
		fEcho_Clean
	fi
}








#•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
## Generic functions
fResolvePath_v1(){
	## Purpose: Resolves an argument to a canonical full path, while being careful to not be too broad as to resolve to something else with the same name.
	## Searches common 'include|lib'-like sub-paths, then if arg is a single filename, the system $PATH.
	## Subshells and external tools are OK in this very early function that preceeds any modules being loaded.
	## Validate nameref args
	[[ -v 1 ]] || { echo -e "\nError in $(basename "${BASH_SOURCE[0]}")·${FUNCNAME[0]}(): Calling function must pass a nameref to receive this function's output, as arg1.\n"                           ; return 1; }
	## Gather args
	local -n ref_Return_ResolvedPath_t4rej=$1  ; shift || :  ## Parent variable to store fully resolved path in.
	local -r nameOrPath="${1:-}"               ; shift || :  ## File or folder path (relative or absolute). If an executable file, can be just a name to search in $PATH, to fully resolve.
	local -i mustExist=${1:-1}                 ; shift || :  ## 1 [default]: path must exist or error occurs. 0: Just rationalize paths, doesn't have to exist.
	## Validate
	[[ "${nameOrPath}" ]] || { echo -e "\nError in $(basename "${BASH_SOURCE[0]}")·${FUNCNAME[0]}(): Path or executable name not specified.\n" ; return 1; }
	## Init
	ref_Return_ResolvedPath_t4rej=""
	## Obvious test, as-is
	[[ -e "${nameOrPath}" ]] && { ref_Return_ResolvedPath_t4rej="$(realpath -e "${nameOrPath}")"; return 0; }
	## Test file with common sub-paths
	local -r mePath_t4rej="$(dirname "${BASH_SOURCE[0]}")"  ## Pathspec to this script.
	local -a tryRelSubs=('/'  '/lib/'  '/include/'  '/includes/') ; local -a tryRelPaths=()  ## Common generic library subdirs.
	for nextSub in "${tryRelSubs[@]}"; do tryRelPaths+=("${BASH_SOURCE[0]}.d${nextSub}${nameOrPath}") ; done  ## "[this script's full pathspec].d/[each common subdir]/[argument]".
	for nextSub in "${tryRelSubs[@]}"; do tryRelPaths+=("${mePath_t4rej}${nextSub}${nameOrPath}")     ; done  ## "[this script's folder]/[each common subdir]/[argument]".
	for nextPath in "${tryRelPaths[@]}"; do [[ -e "${nextPath}" ]] && { ref_Return_ResolvedPath_t4rej="$(realpath -e "${nextPath}")"; return 0; }; done  ## Return realpath if found in the first match.
	local testPath=""
	## Try 'which', if arg is a single file.
	if [[ "${nameOrPath}" != */* ]]; then
		testPath="$(which "${nameOrPath}" 2>/dev/null || true)"
		[[ -n "${testPath}" ]] && { ref_Return_ResolvedPath_t4rej="$(realpath -e "${testPath}")"; return 0; }  ## Return 'which'
	fi
	## Haven't matched yet: revert to original argument
	testPath="${nameOrPath}"
	if ((mustExist)); then
		testPath="$(realpath -e "${testPath}" 2>/dev/null || true)"
		[[ -n "${testPath}" && -e "${testPath}" ]] || { echo -e "\nError in $(basename "${BASH_SOURCE[0]}")·${FUNCNAME[0]}(): Could not resolve path '${nameOrPath}' [£ǝŔs].\n"; return 1; }
	else
		testPath="$(realpath -m "${testPath}" 2>/dev/null || true)"
		[[ -n "${testPath}" ]] || { echo -e "\nError in $(basename "${BASH_SOURCE[0]}")·${FUNCNAME[0]}(): Could not resolve even optionally nonexistent path '${nameOrPath}' [£ǝŔs].\n"; return 1; }
	fi
	## Success
	ref_Return_ResolvedPath_t4rej="${testPath}"
}
fDoesDirHaveContents(){
	[[   -z "${1}" ]]  &&  fThrowError  "No directory specified as arg 1."  "fDoesDirHaveContents"
	[[ ! -d "${1}" ]]                                     && return 1
	[[   -z "$(ls -1A "${1%%/}/" 2>/dev/null || true)" ]] && return 1
	return 0; }
fBuildQuotedParams(){
	local -n varName_1mtkp9p=$1 ; shift || true
	local -i maxIdx=0
	for i in {1..32}; do [[ -n "${!i}" ]] && maxIdx=$i; done;:
	for i in $(seq 1 $maxIdx); do ((i > 1)) && varName_1mtkp9p="${varName_1mtkp9p}  "; varName_1mtkp9p="${varName_1mtkp9p}\"${!i}\""; done;:; }
fRunGUI(){ #( (nohup "$*" &>/dev/null) & disown);
	local -r toExec="${1}" ; shift || true
	local quotedParams=""; fBuildQuotedParams  quotedParams   "${@}"
	( (eval "'${toExec}'  ${quotedParams}  &>/dev/null") & disown ) &>/dev/null; }
fRunGuiAsSudo(){
	local -r toExec="${1:-}"  ## Only used for testing validity. When executed, it's just another "parameter".
	[[ -z "${toExec}" ]]                                                                &&  { echo -e "\nError in '$(basename "${0}").${FUNCNAME[0]}.()': No GUI executable specified to run. \n"                          ; exit 1; }
	{ [[ ! -x "${toExec}" ]] && [[ -z "$(which "${toExec}" 2>/dev/null || true)" ]]; }  &&  { echo -e "\nError in '$(basename "${0}").${FUNCNAME[0]}.()': Cannot find executable explicitly or in \$PATH: '${toExec}'. \n" ; exit 1; }
	local quotedParams=""; fBuildQuotedParams  quotedParams   "${@}"
	sudo true; ( (eval "sudo  DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/0/bus XDG_RUNTIME_DIR=/run/user/0  ${quotedParams}  &>/dev/null") & disown ) &>/dev/null; }
fMustBeInPath(){
	##	Unit tests passed on: 20250704.
	local -r programToCheckForInPath="${1:-}"
	if [[ -z "${programToCheckForInPath}" ]]; then
		fThrowError "Not program specified."  "${FUNCNAME[0]}"; return 1
	elif [[ -z "$(which ${programToCheckForInPath} 2>/dev/null || true)" ]]; then
		fThrowError "Not found in path: ${programToCheckForInPath}"; return 1
	fi ;:;}
fIntroPromptToContinue(){
	{ ((doQuietly)) || ((! doPromptToContinue)); } && return 0
	local -r extraInfoString="${1:-}"
	{ fEcho_Clean; fCopyright; fAbout; fEcho_Clean; }
	[[ -n "${extraInfoString}" ]]  &&  { fEcho_Clean; fEcho_Clean "${extraInfoString}"; }
	fPromptYN "Continue? (y|n): "  ||  { fEcho "User aborted."; return 1; }; }
fPromptYN(){
	((doQuietly)) && return 0
	local promptStr="${1:-}"
	[[ -z "${promptStr}" ]] && promptStr="Continue? (y|n): "
	read -r -p "${promptStr}" userAnswer
	fEcho_ResetBlankCounter
	{ [[ "${userAnswer,,}" == "y" ]] && return 0; } || return 1; }
fPressAnyKeyToContinue(){
	((doQuietly)) && return 0
	local promptStr="${1:-}"
	[[ -z "${promptStr}" ]] && promptStr="Press any key to continue ..."
	read -n 1 -s -p "${promptStr}" userAnswer
	fEcho_Clean_Force
	}

#•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
## Error-handling
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
	#	echo -e "Message ....: '${errMsg}'"      >&2
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
		_fSingleExitPoint "${@}"
	fi ;}
_fTrap_Error(){
	if [[ "${_wasCleanupRun}" == "0" ]]; then  ## String compare is less to fail than integer
		_wasCleanupRun=1
		fEcho_ResetBlankCounter
		_fSingleExitPoint "${@}"
	fi ;}
_fTrap_Error_Ignore(){ _ErrVal=1; true;  return 0; }
_fTrap_Error_Soft(){   _ErrVal=1; false; return 1; }
fThrowError(){
	local errMsg="${1:-}"         ; [[ -z "${errMsg}"      ]] && errMsg="An error occurred."
	local meNameLocal="${meName}" ; [[ -n "${meNameLocal}" ]] && errMsg="${meNameLocal}: ${errMsg}"
	local callStack=""
	for (( i = 1; i < ${#FUNCNAME[@]}; i++ )); do
		[[ "${FUNCNAME[i]}" =~ main|source ]] && continue
		[[ -n "${callStack}" ]] && callStack="${callStack}, "; callStack="${callStack}${FUNCNAME[i]}()"
	done;:
	[[ -n "${callStack}" ]] && callStack="Reverse call stack: ${callStack}"
	fEcho_Clean; echo -e "${errMsg}\n${callStack}" >&2; fEcho_ResetBlankCounter
	_ErrVal=1
	{ ((_doExitOnThrow)) && exit 1; } || return 1; }
fDefineTrap_Error_Fatal(){        :; _ErrVal=0; _doExitOnThrow=0; trap '_fTrap_Error         ERR    ${LINENO}  $?  $_' ERR; set -e; } ## Standard; exits script on any caught error; but 'set -e' has known inconsistencies catching or ignoring errors.
fDefineTrap_Error_ExitOnThrow(){  :; _ErrVal=0; _doExitOnThrow=0; trap '_fTrap_Error         ERR    ${LINENO}  $?  $_' ERR; set +e; } ## Only exits script on fThrowError().
fDefineTrap_Error_Soft(){         :; _ErrVal=0; _doExitOnThrow=0; trap '_fTrap_Error_Soft    ERR    ${LINENO}  $?  $_' ERR; set -e; } ## Returns error code of 1 on error.
fDefineTrap_Error_Ignore(){       :; _ErrVal=0; _doExitOnThrow=0; trap '_fTrap_Error_Ignore  ERR    ${LINENO}  $?  $_' ERR; set +e; } ## Eats errors and returns true.
fDefineTrap_Error_Fatal
trap '_fTrap_Error SIGHUP  ${LINENO} $? $_' SIGHUP
trap '_fTrap_Error SIGINT  ${LINENO} $? $_' SIGINT    ## CTRL+C
trap '_fTrap_Error SIGTERM ${LINENO} $? $_' SIGTERM
trap '_fTrap_Exit  EXIT    ${LINENO} $? $_' EXIT
trap '_fTrap_Exit  INT     ${LINENO} $? $_' INT
trap '_fTrap_Exit  TERM    ${LINENO} $? $_' TERM

##•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
## Echo-related (minified but not obfuscated)
declare -gi _wasLastEchoBlank=0
declare -gi _isEchoInRawInlineMode=0
fEcho_ResetBlankCounter()     { _wasLastEchoBlank=0;      }
fEcho_WasLastEchoBlank_Set()  { { [[ "${1:-}" == "1" ]] && _wasLastEchoBlank=1; } || _wasLastEchoBlank=0;  }
fEcho_WasLastEchoBlank_Get()  { { ((_wasLastEchoBlank > 0)) && return 0; } || return 1; }
fEcho_IsInRawInlineMode_Set() { { [[ "${1:-}" == "1" ]] && _isEchoInRawInlineMode=1; } || { _isEchoInRawInlineMode=0; _wasLastEchoBlank=0; echo; }; }  ## Script it telling fEcho* that something is going to be echoing to the screen in non-linefeed mode without its knowledge. (E.g. "echo -n 'something: '".)
fEcho_IsInRawInlineMode_Get() { { ((_isEchoInRawInlineMode)) && return 0; } || return 1; }
fEcho_Clean_byref(){
	## Validate nameref args:
	[[ -v 1  ]] || fThrowError "Calling function must pass a nameref to supply the input value to this function, as arg1 (string to echo)."
	## Gather args
	local -n ptr_ToEcho_t5jf2=$1
	## Logic
	((_isEchoInRawInlineMode)) && fEcho_IsInRawInlineMode_Set 0
	if [[ -n "${ptr_ToEcho_t5jf2}" ]]; then
		echo -e "${ptr_ToEcho_t5jf2}"
		_wasLastEchoBlank=0
	elif [[ $_wasLastEchoBlank -eq 0 ]]; then
		echo
		_wasLastEchoBlank=1
	fi
}
fEcho_Clean()        { local -r toEcho="${1:-}"; fEcho_Clean_byref toEcho; }
fEcho()              { { [[ -z "${1:-}" ]] && fEcho_Clean ""; } || { local -r toEcho="[ ${1:-} ]"; fEcho_Clean_byref toEcho; }; }
fEcho_Force()        { _wasLastEchoBlank=0; fEcho "${1:-}"; }
fEcho_Clean_Force()  { _wasLastEchoBlank=0; local -r toEcho="${1:-}"; fEcho_Clean_byref toEcho; }


## Bash environment settings (comment out what you don't want)
 set -u  #..................: Require variable declaration. Stronger than mere linting. But can struggle if functions are in sourced files.
 set -e  #..................: Exit on errors. This is inconsistent (made a little better with settings below), so eventually may move to 'set +e' (which is more constant work and mental overhead).
 set -E  #..................: Propagate ERR trap settings into functions, command substitutions, and subshells.
 set   -o pipefail  #.......: Make sure all stages of piped commands also fail the same.
 shopt -s inherit_errexit  #: Propagate 'set -e' ........ into functions, command substitutions, and subshells. Will fail on Bash <4.4.
 shopt -s dotglob  #........: Include usually-hidden 'dotfiles' in '*' glob operations - usually desired.
 shopt -s globstar  #.......: ** matches more stuff including recursion.

## Common constants but detect if already set
if [[ -z "${serialDT+x}"     ]]; then
	declare -r serialDT="$(date "+%Y%m%d-%H%M%S")"
	declare -r mePath="$(realpath -e "${BASH_SOURCE[0]}")"
	declare -r meName="$(basename "${mePath}")"
	declare -r meDir="$(dirname "${mePath}")"
	declare -r relaunch_Key_sudo="${meName}_relaunch_sudo_4KQDYluNbzLQHwMwsWxgdk"  ## This isn't for 'security' or uniqueness. It just needs to be an exceptionally unlikely user argument.
fi

## Make sure relative paths work
cd "${meDir}"

## Invoke main
fMain  "${@}"


##	Script history:
##		- 20260420 JC: Created.
##		- 20260421 JC: Finished.
##		- 20260422-23 JC: Copied and updated for convert-base-v1b.
##		- 20260422-23 JC: Copied and updated for x9bash5-template.
##		- 20260519 JC: Removed some unnecessary old boilerplate cruft from this script.
