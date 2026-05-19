#!/bin/bash

## Active shellchecks
# shellcheck disable=1090
# shellcheck disable=1091
# shellcheck disable=2001   ## Complaining about use of sed istead of bash search & replace.
# shellcheck disable=2002   ## Useless use of cat. This works well though and I don't want to break it for the sake of syntax purity.
# shellcheck disable=2004   ## Inappropriate complaining of "$/${} is unnecessary on arithmetic variables."
# shellcheck disable=2119   ## Disable confusing and inapplicable warning about function's $1 meaning script's $1.
# shellcheck disable=2120   ## OK with declaring variables that accept arguments, without calling with arguments (this is 'overloading').
# shellcheck disable=2143   ## Used grep -q instead of echo | grep
# shellcheck disable=2154
# shellcheck disable=2155   ## Disable check to 'Declare and assign separately to avoid masking return values'.
# shellcheck disable=2162
# shellcheck disable=2181
# shellcheck disable=2207
# shellcheck disable=2317   ## Can't reach

## Inactive shellchecks
# shellcheck disable=2034  ## Unused variables.


##	Purpose:
##		- CI/CD-friendly test harness that passes or fails.
##		- Tests random output and round-trips through v2 to make sure the initial output was correct (at least if v2 is also correct).
##		- This is NOT part of cicd script, as it's not a requirement to have v2 installed.
##	History: At bottom of this file. (Note: History for this is maintained outside of [or in addition to] git project.)

##	Copyright
##		Copyright © 2026 Jim Collier (ID: 1cv◂‡Vᛦ)
##		Licensed under the GNU General Public License v2.0 or later. Full text at:
##			https://spdx.org/licenses/GPL-2.0-or-later.html
##		SPDX-License-Identifier: GPL-2.0-or-later

## Global settings
declare doLongTest=0 ; [[ "${CICDTEST_DO_LONGTEST}" == "1" ]] && doLongTest=1


##•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
## For testing n8_mod_* modules

if [[ ! -v doQuietly ]]; then
	## Required by this template
	declare -gri ARGS_AT_LEAST_ONE_IS_REQUIRED=0
	declare -gri ARGS_MAX_POSITIONAL_COUNT=0
fi
if [[ ! -v THIS_FILEPATH ]]; then
	## Required by n8mod_core_v1
	declare -gr  THIS_FILEPATH="$(realpath -e "${0}")"
	declare -gr  THIS_FILENAME="$(basename "${THIS_FILEPATH}")"
	declare -gr  THIS_DIRPATH="$(dirname "${THIS_FILEPATH}")"
	declare -gri DO_CHAIN_SUDO=1  ## Don't have to use
	## Populated by n8mod_core_v1
	declare -g   SERIAL_DATETIME
	declare -g   RELAUNCH_SENTINELVAL
fi
if [[ ! -v THIS_VERSION ]]; then
	## Required by n8mod_user_v1
	declare -gi doQuietly=0
	declare -gi doPromptToContinue=1
	declare -gr THIS_VERSION="1.0.0-beta1"
	declare -gr THIS_BUILD="1n0pagv"
	declare -gr THIS_COPYRIGHT_YEARS="2011-2026"
	declare -gr THIS_AUTHOR="Jim Collier"
	declare -gr LICENSE_SPDX="GPL-2.0-or-later"   ## Valid so far: GPL-2.0-or-later
fi


fMain_Test(){

	fEcho_Clean
	fEcho_Clean "Ready to test."
	exit

	## Environment overrides
	local LANG="C.UTF-8"  ## Splitting won't work correctly without this

	## Resolve paths
	fResolvePath_v1  exe1       "${exe1}"

	## Variables
	local inputVal=""  expectVal=""  gotVal=""  tmpVal=""
	local -i loopCount=0

	####
	#### Will it even load at all

	fEcho_Clean
	fEcho_Clean "Exe source ...: ${exe1}"
	fEcho_Clean "Version ......: $("${exe1}" --version)"
	fEcho_Clean_Force
	sleep 1
	if ((doComareWith_v2)); then
		fEcho_Clean "v2 source ....: ${exe2}"
		fEcho_Clean "Version ......: $("${exe2}" --version)"
		fEcho_Clean_Force
		sleep 1
	fi



	fEcho; fEcho ">>> TESTSECTION: "; fEcho

	fRunTest  'error'  "${expectVal}"  "'${exe1}'  '${inputVal}'  bogusBaseName" #......: This one should fail
	fRunTest  '=='  "${expectVal}"  "'${exe1}'  ${inputVal}  128v1compat"
	fRunTest  '=='  "${expectVal}"  "'${exe1}'  ${inputVal}  128jc1"

	expectVal="FrĜЋŝĴR2§⁑⍤🝅⌲μr1ϟỹẼ⌲M§ỹλ🜥ψ🝅ᛘêᚼ75ĜᛝmÑ🜥Ĝλŝ▵ϠĜRλΞãᛎ8hÊᛯĝĵΩJĜ▿ĤxŴĵ£Cᛏẅ8ÂψvÉÉδPĝŷ"
	fRunTest  '!='  "${expectVal}"  "'${exe1}'  ${inputVal}  128jc1"

	fRunTest  'error'  "[anything or nothing]"  "'${exe1}'  --ibase 26  'ABCXYZ'  10"

	fRunChained_TestLast  '=='  "${expectVal}"  "'${exe1}'  --ibase 10  ${inputVal}  base16 ; '${exe1}'  --ibase 16  %CMD1_OUTPUT%  base10"

:;}


##•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
## Generic boilerplate

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

## Bash environment settings
 set -u  #..................: Require variable declaration. Stronger than mere linting.
 set -e  #..................: Exit on errors.
 set -E  #..................: Propagate ERR trap settings into functions, command substitutions, and subshells.
 set   -o pipefail  #.......: Make sure all stages of piped commands also fail the same.
 shopt -s inherit_errexit  #: Propagate 'set -e' ........ into functions, command substitutions, and subshells. Will fail on Bash <4.4.
 shopt -s dotglob  #........: Include usually-hidden 'dotfiles' in '*' glob operations - usually desired.
 shopt -s globstar  #.......: ** matches more stuff including recursion.

## Check if sourced
declare -i isSourced_t5ja1=0; [[ "${BASH_SOURCE[0]}" == "${0}" ]] || isSourced_t5ja1=1
#((isSourced_t5ja1)) || { echo -e "\nError in $(basename "${BASH_SOURCE[0]}"): This script is meant to be 'sourced' from within another script.\n"; exit 1; }
{ ((isSourced_t5ja1)) && [[ "${1:-}" != '--unit-test' ]]; }  &&  { echo -e "\nError in $(basename "${BASH_SOURCE[0]}"): This script is not meant to be 'sourced' from within another script, unless for unit-testing.\n"; exit 1; }


#••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
# Entry point
#••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••

if [[ -z "${meName_t4rgd+x}" ]]; then
	declare -r mePath_t4rgd="$(realpath -e "${BASH_SOURCE[0]}")"
	declare -r meName_t4rgd="$(basename "${mePath_t4rgd}")"
	declare -r meDir_t4rgd="$(dirname "${mePath_t4rgd}")"
	declare -r serialDT_t4rgd="$(date "+%Y%m%d-%H%M%S")"
fi

## Make sure relative paths work
cd "${meDir_t4rgd}"

## Source the generic script 'utility/n8test'.
declare n8test_resolved="../utility/include/n8lib_test"
fResolvePath_v1  n8test_resolved  "${n8test_resolved}" ; readonly n8test_resolved
[[ -n "${n8test_resolved}" ]] && source "${n8test_resolved}"

## Source the generic template
declare mainTemplate="../bin/template.bash"
fResolvePath_v1  mainTemplate  "${mainTemplate}" ; readonly mainTemplate
[[ -n "${mainTemplate}" ]] && source "${mainTemplate}" --unit-test

## Initialize logging (fPipe_LogAndShowPartialOutput_InitLogfile() is defined in 'n8test')
declare logFile="${mePath_t4rgd%.*}.log"
fResolvePath_v1  logFile    "${logFile}"  0
fPipe_LogAndShowPartialOutput_InitLogfile "${logFile}"

## Kick off testing (functions are defined in 'n8test')
fEntryPoint | fPipe_LogAndShowPartialOutput



#••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
##	Script history:
##		- 20260518 JC: Copied from convert-base-v1b and updated for this project.
