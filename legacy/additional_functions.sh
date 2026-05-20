#!/bin/bash
# shellcheck disable=2001  ## Complaining about use of sed istead of bash search & replace.
# shellcheck disable=2002  ## Useless use of cat. This works well though and I don't want to break it for the sake of syntax purity.
# shellcheck disable=2004  ## Inappropriate complaining of "$/${} is unnecessary on arithmetic variables."
# shellcheck disable=2034  ## Unused variables.
# shellcheck disable=2086
# shellcheck disable=2119  ## Disable confusing and inapplicable warning about function's $1 meaning script's $1.
# shellcheck disable=2120  ## OK with declaring variables that accept arguments, without calling with arguments (this is 'overloading').
# shellcheck disable=2143  ## Used grep -q instead of echo | grep
# shellcheck disable=2155  ## Disable check to 'Declare and assign separately to avoid masking return values'.
# shellcheck disable=2162
# shellcheck disable=2181
# shellcheck disable=2317  ## Can't reach
# shellcheck disable=2053  ## Disable Yoda Notation warning.


##############################################################################
##############################################################################
##
## NOTE:
##
## Most of these functions have too many problems to include in a module yet,
## or possibly ever. Each one needs to be evaluated one at a time to consider:
##
##   1) Is it even necesseray. There may be simple, bash-idiomatic, one-liner
##      ways to do the same thing, that aren't hard to remember.
##
##   2) Can it be refactored without too much effort, to conform to the
##      following objectives? Or would a rewrite be easier, and also
##      justifiable?
##
## Objectives for each function:
##
##   A) Avoid forking: any use of subshells, pipes, or external tools like
##      `grep`, `sed`, `awk`, `tr`, `head`, etc. If those powerful tools can
##      be leveraged to make quick work of large amounts of data, let the
##      calling script do it itself. (Or at least indicate some kind of
##      'large data' as part of the function name to signal that.)
##
##   B) For functions likely to be called in a long-running loop, absolutely
##      no such forking, piping, etc. - as a hard requirement.
##
##   C) Be not just fully Bash-idiomatic (most of which these are not), but
##      Bash 5 idiomatic.
##
##   D) Conform to my own "Bash 5 Ultimate Guide",
##      https://github.com/jim-collier/bash-5-ultimate-guide
##      which includes the former guidelines.
##
##############################################################################
##############################################################################



##	Purpose: Extra functions that can be copy/pasted into a script, but that don't need to weight-down main template.
##	History:
##		- 20250704 JC:
##			- Created by moving stuff out of TEMPLATE_simple_20250704.

_fStrJustify_byecho(){
	#@	Purpose:
	#@		- Left and right-justifies one or two strings.
	##		- Also doesn't allow the final output to go over specified columns. If it does, the minimum padding witdh is inserted in between a result split in the middle.
	#@	Arguments:
	#@		1 [optional]: String on left
	#@		2 [optional]: String on right
	#@		3 [optional]: Maximum width (default:79)
	#@		4 [optional]: String to pad in between with, usually just one character (default ".")
	#@	Returns via echo: Right-justified string
	##	History:
	##		- 20190925 JC: Created.
	##	TODO:
	##		- Figure out a better solution for too-long strings, other than cutting the middle out of the LEFT string.
	##		- Solution must:
	##			- Put "┈" in the middle (rather than just the left as currently), if both strings are > 1/2 max.
	##			- If any stirng is too long

	## Constants
	local -r -i default_rightmostCol=79
	local -r    default_padStr="."
	local -r    splitStrIndicatorIfTooLong="┈┈"

	## Args
	local       leftStr="$1"
	local       rightStr="$2"
	local    -i maxWidth=$(_fToInt_byecho "$3")
	local       padStr="$4"

	## Variables
	local       printfCommand=""
	local       wholePad=""
#	local    -i extraPlacesToRemove=0
	local    -i totalCharsFromPadToRemove=0
	local    -i maxHypotheticalWidth=0
	local    -i lenLeftPart=0
	local    -i lenRightPart=0
	local       tmpStr=""
	local       tmpPadStr=""
	local       returnStr=""

	## Init; default values
	if [[ -z "${maxWidth}" ]] || [[ ! ${maxWidth} =~ [0-9]+ ]] || [[ "${maxWidth}" == "0" ]]; then maxWidth="${default_rightmostCol}"; fi
	if [[ -z "${maxWidth}" ]] || [[ ! ${maxWidth} =~ [0-9]+ ]] || [[ "${maxWidth}" == "0" ]]; then maxWidth="${default_rightmostCol}"; fi
	if [[ -z "${padStr}" ]]; then padStr="${default_padStr}"; fi

	## Figure out if string is too long
	maxHypotheticalWidth=$((${#leftStr} + 1 + ${#rightStr}))
	tooLongBy=$((maxHypotheticalWidth - maxWidth))

	#fEchoVarAndVal leftStr
	#fEchoVarAndVal rightStr
	#fEchoVarAndVal maxHypotheticalWidth
	#fEchoVarAndVal tooLongBy

	if [[ ${tooLongBy} -gt 0 ]]; then

		## Update these values for inclusion of $splitStrIndicatorIfTooLong
		maxHypotheticalWidth=$((${#leftStr} + ${#splitStrIndicatorIfTooLong} + ${#rightStr}))
		tooLongBy=$((maxHypotheticalWidth - maxWidth))
		if [[ $tooLongBy -le 0 ]]; then tooLongBy=0; fi

		## The total output will be too long. Split the longest string in half and put $splitStrIndicatorIfTooLong in between.
		if [[ ${#rightStr} -gt ${#leftStr} ]]; then  ## If equal, left
			tmpStr="${rightStr}"
		else
			tmpStr="${leftStr}"
		fi

		## Split the longest string in half, and only for that longest string, hack off some of the right part of left half, and some of the left part of right half
			## Split the longest string in half. Round first half up; but Bash integer math always rounds down; this trick rounds up.
				#### result=$(( (numerator  + (denominator - 1) / denomonator) ))
				lenLeftPart=$(( (${#tmpStr} + 1               ) / 2            ))
				    ##Eg 13=$(( (25         + 1               ) / 2            ))
				## Now trim half of the overage off from left half, also rounding up (which evens it out)
				lenLeftPart=$(( lenLeftPart - ((tooLongBy+1)/2) ))
			## Round second half down; Bash always does this anyway
				## (( result=$(( (numerator  / denomonator) ))
				lenRightPart=$(( (${#tmpStr} / 2          ) ))
				   ##Eg   12=$(( (25         / 2          ) ))
				## Now trim half of the overage off from left half, also rounding up (which evens it out)
				lenRightPart=$(( lenRightPart - (tooLongBy/2) ))
			## Build the splint string
			tmpStr="$(_fStrKeepLeftN_byecho "${tmpStr}" ${lenLeftPart})${splitStrIndicatorIfTooLong}$(_fStrKeepRightN_byecho "${tmpStr}" ${lenRightPart})"

		## Replace longest string with the split result
		if [[ ${#rightStr} -gt ${#leftStr} ]]; then
			rightStr="${tmpStr}"
		else
			leftStr="${tmpStr}"
		fi
	fi

	printfCommand="printf '${padStr}%.0s' {1..${maxWidth}}"
	wholePad="$(eval "${printfCommand}")"
	if [[ -n "${leftStr}" ]]   && [[ $tooLongBy -le 0 ]]; then leftStr="${leftStr} "; fi
	if [[ -n "${rightStr}" ]]  && [[ $tooLongBy -le 0 ]]; then rightStr=" ${rightStr}"; fi
	totalCharsFromPadToRemove=$((${#leftStr} + ${#rightStr}))
	tmpPadStr="${wholePad:$totalCharsFromPadToRemove}"
	if [[ -z "${tmpPadStr}" ]] && [[ -n "${leftStr}" ]] && [[ -n "${rightStr}" ]]; then
		tmpPadStr=" "
	fi
	returnStr="${leftStr}${tmpPadStr}${rightStr}"

	## This logic isn't always correct, and isn't even really a good overall idea (at least for too long strings); so just in case, crop to max chars len
	returnStr="$(_fStrKeepLeftN_byecho "${returnStr}" ${maxWidth})"

	#fEchoVarAndVal padStr
	#fEchoVarAndVal maxWidth
	#fEchoVarAndVal wholePad
	#fEchoVarAndVal totalCharsFromPadToRemove
	#fEchoVarAndVal leftStr
	#fEchoVarAndVal tmpPadStr
	#fEchoVarAndVal rightStr
	#fEchoVarAndVal returnStr
	#return

	echo "${returnStr}"

:; }

_fEscapeStr_byecho(){
	local valStr="$1"
	valStr="$( echo -e "${valStr}" | sed ':a;N;$!ba;s/\n/⌁▸newline◂⌁/g'     2>/dev/null || true)"
	valStr="$( echo -e "${valStr}" | sed 's*\"*⌁▸dquote◂⌁*g'                2>/dev/null || true)"
	valStr="$( echo -e "${valStr}" | sed "s/'/⌁▸squote◂⌁/g"                 2>/dev/null || true)"
	valStr="$( echo -e "${valStr}" | sed 's/`/⌁▸backtick◂⌁/g'               2>/dev/null || true)"
	valStr="$( echo -e "${valStr}" | sed 's*\t*⌁▸tab◂⌁*g'                   2>/dev/null || true)"
	valStr="$( echo -e "${valStr}" | sed 's*\\*⌁▸backslash◂⌁*g'             2>/dev/null || true)"
	valStr="$( echo -e "${valStr}" | sed "s/\*/⌁▸asterisk◂⌁/g"              2>/dev/null || true)"
	valStr="$( echo -e "${valStr}" | sed "s/\?/⌁▸questionmark◂⌁/g"          2>/dev/null || true)"
	valStr="$( echo -e "${valStr}" | sed "s/|/⌁▸pipe◂⌁/g"                   2>/dev/null || true)"
	valStr="$( echo -e "${valStr}" | sed "s/</⌁▸lthan◂⌁/g"                  2>/dev/null || true)"
	valStr="$( echo -e "${valStr}" | sed "s/>/⌁▸gthan◂⌁/g"                  2>/dev/null || true)"
	# shellcheck disable=2016  ## False positive on non-expanding variable
	valStr="$( echo -e "${valStr}" | sed 's/\$(/⌁▸dollarlparen◂⌁/g'         2>/dev/null || true)"
	valStr="$( echo -e "${valStr}" | sed 's/\$/⌁▸dollarl◂⌁/g'               2>/dev/null || true)"
	echo "${valStr}"
:; }
_fUnEscapeStr_byecho(){
	local      valStr="$1"
	valStr="$( echo -e "${valStr}" | sed 's*⌁▸newline◂⌁*\n*g'               2>/dev/null || true)"
	valStr="$( echo -e "${valStr}" | sed 's*⌁▸dquote◂⌁*\"*g'                2>/dev/null || true)"
	valStr="$( echo -e "${valStr}" | sed "s/⌁▸squote◂⌁/'/g"                 2>/dev/null || true)"
	valStr="$( echo -e "${valStr}" | sed 's/⌁▸backtick◂⌁/`/g'               2>/dev/null || true)"
	valStr="$( echo -e "${valStr}" | sed 's*⌁▸tab◂⌁*\t*g'                   2>/dev/null || true)"
	valStr="$( echo -e "${valStr}" | sed 's*⌁▸backslash◂⌁*\\*g'             2>/dev/null || true)"
	valStr="$( echo -e "${valStr}" | sed "s/⌁▸asterisk◂⌁/\*/g"              2>/dev/null || true)"
	valStr="$( echo -e "${valStr}" | sed "s/⌁▸questionmark◂⌁/\?/g"          2>/dev/null || true)"
	valStr="$( echo -e "${valStr}" | sed "s/⌁▸pipe◂⌁/|/g"                   2>/dev/null || true)"
	valStr="$( echo -e "${valStr}" | sed "s/⌁▸lthan◂⌁/</g"                  2>/dev/null || true)"
	valStr="$( echo -e "${valStr}" | sed "s/⌁▸gthan◂⌁/>/g"                  2>/dev/null || true)"
	# shellcheck disable=2016  ## False positive on non-expanding variable
	valStr="$( echo -e "${valStr}" | sed 's/⌁▸dollarlparen◂⌁/\$(/g'         2>/dev/null || true)"
	valStr="$( echo -e "${valStr}" | sed 's/⌁▸dollarl◂⌁/\$/g'               2>/dev/null || true)"
	echo "${valStr}"
:; }

_fIsPathMounted(){
	## Depended on by: _UnmountZfsFilesys()
	local -r    mountPath="${1}"
	local    -i retVal=0
	[[ -n "$( mount | grep "${mountPath}" 2>/dev/null || true)" ]] && retVal=1
	echo $retVal
}

_fUmountPath(){

	## Purpose: Unmount a directory, safely at first, then with increasingly agressive tactics.
	## Args:
	##		1: Dir
	##		2: Ignore errors? [boolean], default 0 (will fail on errers).

	## Args
	local    -r unmountDir="$1"
	local       raw_ignoreError="$2"

	## Convert string arg[s] to boolean constant[s]
	local -i ignoreError=0; [[ "${raw_ignoreError}" =~ "1"|"true"|"TRUE" ]] && ignoreError=1; local -i -r ignoreError=$ignoreError

	## Validate
	[[   -z "${unmountDir}"              ]] && fThrowError  "No directory to unmount specified."                    "${FUNCNAME[0]}"
	[[ ! -d "${unmountDir}"              ]] && fThrowError  "Directory to unmount doesn't exist: '${unmountDir}'."  "${FUNCNAME[0]}"
	[[      "${unmountDir}" == "/"       ]] && fThrowError  "I refuse to try to unmount '/'!."                      "${FUNCNAME[0]}"
	[[      "${unmountDir}" == "${HOME}" ]] && fThrowError  "I refuse to try to unmount '${HOME}'!."                "${FUNCNAME[0]}"

	if [[ -z "$(mount | grep " ${unmountDir} " 2>/dev/null || true)" ]]; then
		fEcho "No need to umnout, as it's not mounted: '${unmountDir}' ..."
		return 0
	else
		fEcho "Unmounting '${unmountDir}' ..."
		umount "${unmountDir}" || true
	fi

	[[ -z "$(mount | grep " ${unmountDir} " 2>/dev/null || true)" ]] && return 0
	echo "Getting sudo for more forceful 'umount' ..."
	sudo echo "Sudo got."
	sync; sleep 1
	sudo umount -fR "${unmountDir}" || true

	[[ -z "$(mount | grep " ${unmountDir} " 2>/dev/null || true)" ]] && return 0
	sudo umount -fAR "${unmountDir}" || true

	## This is dangerous
	#[[ -z "$(mount | grep " ${unmountDir} " 2>/dev/null || true)" ]] && return 0
	#sudo umount -fARl "${unmountDir}" || true
	#sync; sleep 1

	[[ $ignoreError -eq 0 ]] && [[ -n "$(mount | grep " ${unmountDir} " 2>/dev/null || true)" ]] && fThrowError "Unable to unmount '${unmountDir}'." "${FUNCNAME[0]}"

}

_fUmountPath_AsSudo(){
	## Args
	local -r mountPath="$1"
	## Constants
	local -r -i tryFirstExport_Count=5
	local -r -i tryFirstExport_WaitSecsBetween=1
	## Loop
	[[ 0 -eq $(_fIsPathMounted "${mountPath}") ]] && return
	for ((i = 1 ; i <= ${tryFirstExport_Count} ; i++)); do
		fEchoPlus  "Attempt ${i} ..."  "${FUNCNAME[0]}"
		sync; sleep $tryFirstExport_WaitSecsBetween
		(( i >= 1 )) && (sudo umount                               "${mountPath}" || true)
		[[ 0 -eq $(_fIsPathMounted "${mountPath}") ]] && break
		(( i >= 2 )) && (sudo umount -f                            "${mountPath}" || true)
		[[ 0 -eq $(_fIsPathMounted "${mountPath}") ]] && break
		(( i >= 3 )) && (sudo umount -f --recursive                "${mountPath}" || true)
		[[ 0 -eq $(_fIsPathMounted "${mountPath}") ]] && break
		(( i >= 4 )) && (sudo umount -f --recursive --all-targets  "${mountPath}" || true)  ## Note: --lazy flag can break stuff.
		[[ 0 -eq $(_fIsPathMounted "${mountPath}") ]] && break
	done
}

_fIsZfsPoolImportable(){
	## Returns 1 if importable and not already imported. Trying doesn't harm or affect the pool.
	local -i returnVal=0
	[[ -n "$(sudo zpool import 2>/dev/null | grep -iP "${stringArg}" 2>/dev/null || true)" ]] && returnVal=1
	echo $returnVal
}

_fIsZfsPoolImported(){
	## Returns 1 if pool is imported; says nothing of healthy state.
	local -i returnVal=0
	if [[ 1 -eq $(_fIsZfsPoolImportable) ]]; then :
		## Skip to fi if it's importABLE, which means it's not currently imported.
	elif [[ -n "$(sudo zpool status ${stringArg} 2>/dev/null || true)" ]]; then
		## It does have a status, which means it is imported.
		returnVal=1
	fi
	echo $returnVal
}

_fIsZfsPoolImportedCleanly(){
	local -i returnVal=0
	if [[ 1 -eq $(_fIsZfsPoolImportable) ]]; then :
		## Skip to fi if it IS importABLE, which means it's not currently imported.
	elif [[ 0 -eq $(_fIsZfsPoolImported) ]]; then :
		## Skip to fi if it's not imported (and here also not importable - meaning probably doesn't exist).
	elif [[ -z "$(sudo zpool status ${stringArg} 2>&1 | grep -P "DEGRADED|UNAVAIL|FAULTED|cannot import|does not exist|no such pool|I/O error|Destroy" || true)" ]]; then
		## Yay - it is not importable, it is imported, and it's status has no known errors to look for.
		returnVal=1
	fi
	echo $returnVal
}

_UnmountZfsFilesys(){
	##	Dependencies: _fIsPathMounted()
	## Args
	local -r zfsName="$1"
	local -r zfsMountPath="$2"
	## Constants
	local -r -i tryFirstExport_Count=7
	local -r -i tryFirstExport_WaitSecsBetween=1
	## Loop
	[[ 0 -eq $(_fIsPathMounted "${zfsMountPath}") ]] && return
	for ((i = 1 ; i <= ${tryFirstExport_Count} ; i++)); do
		fEchoPlus  "Attempt ${i} ..."  "${FUNCNAME[0]}"
		sync; sleep $tryFirstExport_WaitSecsBetween
		(( i >= 1 )) && (sudo zfs unmount ${zfsName} || true)
		[[ 0 -eq $(_fIsPathMounted "${zfsMountPath}") ]] && break
		(( i >= 2 )) && (sudo zfs unmount -f ${zfsName} || true)
		[[ 0 -eq $(_fIsPathMounted "${zfsMountPath}") ]] && break
		(( i >= 3 )) && (sudo umount                                     "${zfsMountPath}" || true)
		(( i >= 4 )) && (sudo umount -f                                  "${zfsMountPath}" || true)
		(( i >= 5 )) && (sudo umount -f --recursive                      "${zfsMountPath}" || true)
		(( i >= 6 )) && (sudo umount -f --recursive --all-targets        "${zfsMountPath}" || true)  ## Note: --lazy flag can break stuff.
	done
}


declare -i _FGETINT_CONSTRAINED_NOERROR=0  ## Set to 1 to ignore errors, and return default or 0.
_fGetInt_Constrained(){
	## Converts, and optionally constrains, rounds, defaults, and/or validates an integer.
	##	Unit tests passed on: 20250704.
	local -n varRef_s74bm=$1             ## Arg <REQUIRED>: Variable for return integer.
	local -r arg_inputVal="$2"           ## Arg [optional]: Input string to convert to integer. If empty, default or 0 will be returned regardless of $_FGETINT_CONSTRAINED_NOERROR
	local -r arg_defaultVal="$3"         ## Arg [optional]: This will be used if input is blank, or if input is garbage and $_FGETINT_CONSTRAINED_NOERROR is 1.
	local -r arg_minNum="$4"             ## Arg [optional]: Errors if input is below, unless $_FGETINT_CONSTRAINED_NOERROR is 1, then input will be adjusted.
	local -r arg_maxNum="$5"             ## Arg [optional]: Errors if input is above, unless $_FGETINT_CONSTRAINED_NOERROR is 1, then input will be adjusted.
	local -i defaultVal=0 ; local -i isSet_defaultVal=0 ; [[ -n "${arg_defaultVal}" ]] && { isSet_defaultVal=1 ; defaultVal=$arg_defaultVal ; } ; local -ir defaultVal=$defaultVal ; local -ir isSet_defaultVal=$isSet_defaultVal
	local -i minVal=0     ; local -i isSet_minNum=0     ; [[ -n "${arg_minNum}"     ]] && { isSet_minNum=1     ; minVal=$arg_minNum         ; } ; local -ir minVal=$minVal         ; local -ir isSet_minNum=$isSet_minNum
	local -i maxVal=0     ; local -i isSet_maxNum=0     ; [[ -n "${arg_maxNum}"     ]] && { isSet_maxNum=1     ; maxVal=$arg_maxNum         ; } ; local -ir maxVal=$maxVal         ; local -ir isSet_maxNum=$isSet_maxNum
	{ ((isSet_minNum)) && ((isSet_maxNum)) && ((minVal > maxVal))             ; } && fThrowError  "The calling function gave a higher value for \$minVal than \$maxVal. Could be a bug in that function [¢фッǒ]."  "${FUNCNAME[0]}"
	{ ((isSet_minNum)) && ((isSet_defaultVal)) && ((arg_defaultVal < minVal)) ; } && fThrowError  "The calling function gave a lower value for \$arg_defaultVal than \$minVal. Could be a bug in that function [¢фゞᛯ]."  "${FUNCNAME[0]}"
	{ ((isSet_maxNum)) && ((isSet_defaultVal)) && ((arg_defaultVal > maxVal)) ; } && fThrowError  "The calling function gave a higher value for \$arg_defaultVal than \$maxVal. Could be a bug in that function [¢фゞᛯ]."  "${FUNCNAME[0]}"
	varRef_s74bm=0
	local    outValStr=""
	local -i outVal=0
	local -i hasValBeenSet=0
	if [[ -n "${arg_inputVal}" ]]; then
		outValStr="$(grep -Po '\-?[\.,0-9]+' <<< "${arg_inputVal}" | head -n 1 || true)"
		outValStr="${outValStr//','/''}"
		if [[ -n "${outValStr}" ]]; then
		#	outValStr="$(awk '{for(i=1;i<=NF;i++) if($i~ /^-?[0-9]+(\.[0-9]+)?$/) printf "%.0f\n", $i+0}' <<< "${outValStr}" || true)"
			outValStr=$(awk -v n=0 -v x=$outValStr 'BEGIN{printf "%.*f\n", n, x}')
			outVal=$outValStr  ## Success, we have an integer!
			hasValBeenSet=1
		else
			if ((_FGETINT_CONSTRAINED_NOERROR)); then
				if ((isSet_defaultVal)); then
					outVal=$defaultVal ; hasValBeenSet=1  ## If bad input but $_FGETINT_CONSTRAINED_NOERROR is 1, use default.
				else
					outVal=0 ; hasValBeenSet=1  ## If bad input and no default given, but $_FGETINT_CONSTRAINED_NOERROR is 1, use 0.
				fi
			else
				fThrowError  "The input value can't be converted to an integer: '${arg_inputVal}' [¢фぅǨ]."  "${FUNCNAME[0]}"
			fi
		fi
	else  ## Empty input
		if ((isSet_defaultVal)); then
			outVal=$defaultVal ; hasValBeenSet=1  ## No error no matter what, if empty input but default value is provided - whether or not $_FGETINT_CONSTRAINED_NOERROR is 1.
		else
			outVal=0 ; hasValBeenSet=1  ## If $_FGETINT_CONSTRAINED_NOERROR is 1 but no default set, default to 0.
		fi
	fi
	if ((isSet_minNum)) && ((outVal < minVal)); then
		if ((_FGETINT_CONSTRAINED_NOERROR)); then
			outVal=$minVal
		else
			fThrowError  "The input value '${arg_inputVal}' is less than the specified minimum '${minVal}' [¢¢G🜣]."  "${FUNCNAME[0]}"
		fi
	fi
	if ((isSet_maxNum)) && ((outVal > maxVal)); then
		if ((_FGETINT_CONSTRAINED_NOERROR)); then
			outVal=$maxVal
		else
			fThrowError  "The input value '${arg_inputVal}' is more than the specified maximum '${maxVal}' [¢¢G🜣]."  "${FUNCNAME[0]}"
		fi
	fi
	varRef_s74bm=$outVal
:;}

declare -i _FGETNUM_CONSTRAINED_NOERROR=0
_fGetNum_Constrained(){
	## Converts, and optionally constrains, rounds, defaults, and/or validates an integer or float.
	## For now, assumes ',' is thousands-separator, and '.' is decimal separator. (Search for '!locale-aware' comments.)
	local -n varRef_s76ej=$1             ## Arg <REQUIRED>: Variable for return number. Can be int or string.
	local -r arg_inputVal="$2"           ## Arg [optional]: Input string to convert to integer. If empty, default or 0 will be returned regardless of $_FGETINT_NOERROR
	local    arg_roundDigits="$2"        ## Arg [optional]: number of decimal places to round to.
	local -r arg_defaultVal="$3"         ## Arg [optional]: This will be used if input is blank, or if input is garbage and $_FGETINT_NOERROR is 1.
	local -r arg_minNum="$4"             ## Arg [optional]: Errors if input is below, unless $_FGETINT_NOERROR is 1, then input will be adjusted.
	local -r arg_maxNum="$5"             ## Arg [optional]: Errors if input is above, unless $_FGETINT_NOERROR is 1, then input will be adjusted.
#	local -r arg_doTruncateNotRound="$6" ## Arg [optional]: TODO
	local    defaultVal=0  ; local -i isSet_defaultVal=0  ; [[ -n "${arg_defaultVal}"  ]] && { defaultVal=$arg_defaultVal   ; isSet_defaultVal=1  ; } ; local -ir defaultVal=$defaultVal   ; local -ir isSet_defaultVal=$isSet_defaultVal
	local    minVal=0      ; local -i isSet_minNum=0      ; [[ -n "${arg_minNum}"      ]] && { minVal=$arg_minNum           ; isSet_minNum=1      ; } ; local -ir minVal=$minVal           ; local -ir isSet_minNum=$isSet_minNum
	local    maxVal=0      ; local -i isSet_maxNum=0      ; [[ -n "${arg_maxNum}"      ]] && { maxVal=$arg_maxNum           ; isSet_maxNum=1      ; } ; local -ir maxVal=$maxVal           ; local -ir isSet_maxNum=$isSet_maxNum
	local -i roundDigits=0 ; local -i isSet_roundDigits=0 ; [[ -n "${arg_roundDigits}" ]] && { roundDigits=$arg_roundDigits ; isSet_roundDigits=1 ; } ; local -ir roundDigits=$roundDigits ; local -ir isSet_roundDigits=$isSet_roundDigits
	## The following needs to use something to validate that's floating-point-aware, like 'a="1.6" b="1.4"; { awk -v f1="$a" -v f2="$b" 'BEGIN {exit !(f1 > f2)}' && echo y; } || echo n'. But not heavy.
	## For now, just don't validate it, for speed.
	#	{ ((isSet_minNum))      && ((isSet_maxNum))     && ((minVal > maxVal))         ; } && fThrowError  "The calling function gave a higher value for \$minVal than \$maxVal. Could be a bug in that function. [¢¥ŹI]"          "${FUNCNAME[0]}"
	#	{ ((isSet_minNum))      && ((isSet_defaultVal)) && ((arg_defaultVal < minVal)) ; } && fThrowError  "The calling function gave a lower value for \$arg_defaultVal than \$minVal. Could be a bug in that function. [¢¥ŹR]"   "${FUNCNAME[0]}"
	#	{ ((isSet_maxNum))      && ((isSet_defaultVal)) && ((arg_defaultVal > maxVal)) ; } && fThrowError  "The calling function gave a higher value for \$arg_defaultVal than \$maxVal. Could be a bug in that function. [¢¥ŹX]"  "${FUNCNAME[0]}"
	{ ((isSet_roundDigits)) && ((roundDigits < 0)) ; } && fThrowError  "The calling function gave a bad value for \$arg_numDecimalPlaces : '${arg_numDecimalPlaces}'. [¢¥ǵǧ]"                  "${FUNCNAME[0]}"
	varRef_s76ej=0
	local    outVal="${arg_inputVal}"
	local -i hasValBeenSet=0
	if [[ -n "${outVal}" ]]; then
		outVal="${outVal//','/''}" #......................................................: Remove thousands-place delimiter[s]. !locale-aware
		outVal="$(grep -Po '\-?([0-9]+\.[0-9]+|\.[0-9]+|[0-9]+)' <<< "${outVal}" | head -n 1 || true)" #...: Extract only number. !locale-aware
		if [[ -n "${outVal}" ]]; then
			hasValBeenSet=1
		else
			if ((_FGETINT_NOERROR)); then
				if ((isSet_defaultVal)); then
					outVal=$defaultVal ; hasValBeenSet=1  ## If bad input but $_FGETINT_NOERROR is 1, use default.
				else
					outVal=0 ; hasValBeenSet=1  ## If bad input and no default given, but $_FGETINT_NOERROR is 1, use 0.
				fi
			else
				fThrowError  "The input value can't be converted to a number: '${arg_inputVal}' [¢¥íŠ]."  "${FUNCNAME[0]}"
			fi
		fi
	else  ## Empty input
		if ((isSet_defaultVal)); then
			outVal=$defaultVal ; hasValBeenSet=1  ## No error no matter what, if empty input but default value is provided - whether or not $_FGETINT_NOERROR is 1.
		else
			outVal=0 ; hasValBeenSet=1  ## If $_FGETINT_NOERROR is 1 but no default set, default to 0.
		fi
	fi
	if ((isSet_minNum)); then
		if _fIsNum1_lt_Num2  ${outVal}  ${minVal}; then
			if ((_FGETINT_NOERROR)); then
				outVal=$minVal
			else
				fThrowError  "The input value '${arg_inputVal}' is less than the specified minimum '${minVal}' [¢¥śĴ]."  "${FUNCNAME[0]}"
			fi
		fi
	fi
	if ((isSet_maxNum)); then
		if _fIsNum1_gt_Num2  ${outVal}  ${maxVal}; then
			if ((_FGETINT_NOERROR)); then
				outVal=$maxVal
			else
				fThrowError  "The input value '${arg_inputVal}' is more than the specified maximum '${maxVal}' [¢¥śâ]."  "${FUNCNAME[0]}"
			fi
		fi
	fi
	if ((isSet_roundDigits)); then
		_fRoundNum outVal $roundDigits
	else
		outVal="$(sed -E 's/(\.[0-9]*[1-9])0+$/\1/; s/\.0+$//; s/\.$//' <<< "${outVal}")" ## Trim trailing zeros after decimal, '.0+', and lone trailing '.'
	fi
	varRef_s76ej=$outVal
:;}
