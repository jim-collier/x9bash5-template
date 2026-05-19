#!/bin/bash

#  shellcheck disable=1091  ## 'Not following...'. Disable for sourcing scripts.
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

##	Purpose: Unit-testing for custom functions.
##	History:
##		- 20250713 JC: Broke out from main file.


fUnitTest_User(){



#	## Examples
#	_fUnitTest_PrintSectionHeader 'fFuncName()'
#	fFuncName tmpStr 'arg'; _fAssert_AreEqual            ¢£yμ  "${tmpStr}"             'expected val'
#	_fAssert_Eval_AreEqual                               ¢£y‡  "fFuncName 'arg'"       'expected val'
#	_fAssert_Eval_ShouldError                            ¢£yδ  "fFuncName 'bad arg'"
#	_fAssert_Eval_ShouldNotError                         ¢£y🝅  "fFuncName 'good arg'"
:;}
