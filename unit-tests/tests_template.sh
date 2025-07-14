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


##	Purpose: Unit-testing for generic functions in template script.
##	History:
##		- 20250713 JC: Broke out from main file.


fUnitTest_Toolbox(){
	local -i tmpInt=0
	local    tmpStr=""

	fUnitTest_PrintSectionHeader 'fIsInt()'
	fAssert_Eval_AreEqual  ¢§YI   '{ fIsInt   123     && echo Y; } || echo N'  'Y'
	fAssert_Eval_AreEqual  ¢§Yẑ   '{ fIsInt   123.    && echo Y; } || echo N'  'Y'  'Trailing decimal point is OK.'
	fAssert_Eval_AreEqual  ¢¿Bď   '{ fIsInt  -123     && echo Y; } || echo N'  'Y'
	fAssert_Eval_AreEqual  ¢§YẼ   '{ fIsInt   x123    && echo Y; } || echo N'  'N'
	fAssert_Eval_AreEqual  s78k0  '{ fIsInt  \$123    && echo Y; } || echo N'  'Y'  '$ and other currency symbols are OK.'
	fAssert_Eval_AreEqual  s78k1  '{ fIsInt    123%   && echo Y; } || echo N'  'N'  '% is inherently not an integer.'
	#exit

	fUnitTest_PrintSectionHeader  'fIsNum()'
	fAssert_Eval_AreEqual  ¢§Y2   '{ fIsNum      123        && echo Y; } || echo N'  'Y'
	fAssert_Eval_AreEqual  ¢§YA   '{ fIsNum        0.023    && echo Y; } || echo N'  'Y'
	fAssert_Eval_AreEqual  ¢¿BĀ   '{ fIsNum         .023    && echo Y; } || echo N'  'Y'
	fAssert_Eval_AreEqual  ¢¿BĪ   '{ fIsNum        -.023    && echo Y; } || echo N'  'Y'
	fAssert_Eval_AreEqual  ¢¿BȲ   '{ fIsNum       -1.023    && echo Y; } || echo N'  'Y'
	fAssert_Eval_AreEqual  ¢¿Bē   '{ fIsNum      xyz        && echo Y; } || echo N'  'N'
	fAssert_Eval_AreEqual  ¢¿Bū   '{ fIsNum    x123z        && echo Y; } || echo N'  'N'
	fAssert_Eval_AreEqual  ¢¿Xᛏ   '{ fIsNum         .1      && echo Y; } || echo N'  'Y'
	fAssert_Eval_AreEqual  ¢¿Xᛝ   '{ fIsNum        1.       && echo Y; } || echo N'  'Y'
	fAssert_Eval_AreEqual  s78gr  '{ fIsNum  '-1,112.58'    && echo Y; } || echo N'  'Y'  'With comma.'
	fAssert_Eval_AreEqual  s78js  '{ fIsNum  '192.168.1.1'  && echo Y; } || echo N'  'N'  'IP address'
	fAssert_Eval_AreEqual  s78ju  '{ fIsNum  '867-5309'     && echo Y; } || echo N'  'N'  'Phone number'
	fAssert_Eval_AreEqual  s78jv  '{ fIsNum       39%       && echo Y; } || echo N'  'Y'  '%'
	fAssert_Eval_AreEqual  s78jw  '{ fIsNum     \$49.37     && echo Y; } || echo N'  'Y'  '$'
	#exit

	fUnitTest_PrintSectionHeader 'fIsVal1_gt_Val2()'
	fAssert_Eval_AreEqual  ¢§bŕ  "{ fIsVal1_gt_Val2  2      1           && echo Y; } || echo N"  'Y'
	fAssert_Eval_AreEqual  ¢§eM  "{ fIsVal1_gt_Val2  1.1    2.1         && echo Y; } || echo N"  'N'
	fAssert_Eval_AreEqual  ¢§eO  "{ fIsVal1_gt_Val2  1.1    2.1         && echo Y; } || echo N"  'N'
	fAssert_Eval_AreEqual  ¢¿Bㅸ  "{ fIsVal1_gt_Val2   .1    0.01        && echo Y; } || echo N"  'Y'
	fAssert_Eval_AreEqual  ¢¿Bッ  "{ fIsVal1_gt_Val2  3      3           && echo Y; } || echo N"  'N'
	fAssert_Eval_AreEqual  ¢¿Bぇ  "{ fIsVal1_gt_Val2  1     -3           && echo Y; } || echo N"  'Y'
	fAssert_Eval_AreEqual  ¢¿Tč  "{ fIsVal1_gt_Val2  x     y           && echo Y; } || echo N"  'N'   'Works on text too.'
	#exit

	fUnitTest_PrintSectionHeader 'fIsVal1_lt_Val2()'
	fAssert_Eval_AreEqual  ¢¿CR  "{ fIsVal1_lt_Val2   2      1           && echo Y; } || echo N"  'N'
	fAssert_Eval_AreEqual  ¢¿CT  "{ fIsVal1_lt_Val2   1.1    2.1         && echo Y; } || echo N"  'Y'
	fAssert_Eval_AreEqual  ¢¿C1  "{ fIsVal1_gt_Val2   3      3           && echo Y; } || echo N"  'N'
	fAssert_Eval_AreEqual  ¢¿C4  "{ fIsVal1_gt_Val2  -9      8           && echo Y; } || echo N"  'N'
	#exit

	fUnitTest_PrintSectionHeader 'fIsRegexMatch()'
	fAssert_Eval_AreEqual  ¢¢sň  "{ fIsRegexMatch  'hello'        '^h[^/]+$' && echo 1; } || echo 0"  '1'
	fAssert_Eval_AreEqual  ¢§aѢ  "{ fIsRegexMatch  'hello/there'  '^[^/]+$'  && echo 1; } || echo 0"  '0'
	fAssert_Eval_AreEqual  ¢§aɤ  "{ fIsRegexMatch  ''             '^[^/]+$'  && echo 1; } || echo 0"  '0'
	fAssert_Eval_AreEqual  ¢§a⍤  "{ fIsRegexMatch  'hello'        'hello'    && echo 1; } || echo 0"  '1'
	fAssert_Eval_AreEqual  ¢§a⌲  "{ fIsRegexMatch  ''             ''         && echo 1; } || echo 0"  '1'
	fAssert_Eval_AreEqual  ¢§a⍋  "{ fIsRegexMatch  'hello'        ''         && echo 1; } || echo 0"  '1'
	#exit

	fUnitTest_PrintSectionHeader 'fGetMinVal()'
	fGetMinVal  tmpStr  20032.00023    5     ; fAssert_AreEqual  ¢§h⍤  $tmpStr  5
	fGetMinVal  tmpStr      -.00023    1.1   ; fAssert_AreEqual  ¢§h⍋  $tmpStr  -.00023
	fGetMinVal  tmpStr    xyz        abc     ; fAssert_AreEqual  ¢¿7Û  $tmpStr  abc   'Works on text too.'
	#exit

	fUnitTest_PrintSectionHeader 'fGetMaxVal()'
	fGetMaxVal  tmpStr  20032.00023    5     ; fAssert_AreEqual  ¢¿7Ϡ  $tmpStr  20032.00023
	fGetMaxVal  tmpStr    xyz          1.1   ; fAssert_AreEqual  ¢¿7Ω  $tmpStr    xyz   'Works on text & numbers too.'
	#exit

	fUnitTest_PrintSectionHeader 'fGetBool()'
	fGetBool tmpInt   1                 ;  fAssert_AreEqual  ¢¢wŚ   $tmpInt  1
	fGetBool tmpInt  -1                 ;  fAssert_AreEqual  ¢¿FĒ   $tmpInt  1
	fGetBool tmpInt   5                 ;  fAssert_AreEqual  ¢¿FŌ   $tmpInt  1
	fGetBool tmpInt   0                 ;  fAssert_AreEqual  ¢¿Fď   $tmpInt  0
	fGetBool tmpInt  'true'             ;  fAssert_AreEqual  ¢¿FȲ   $tmpInt  1
	fGetBool tmpInt  't'                ;  fAssert_AreEqual  ¢¿Fē   $tmpInt  1
	fGetBool tmpInt  'y'                ;  fAssert_AreEqual  ¢¿Fō   $tmpInt  1
	fGetBool tmpInt  'yes'              ;  fAssert_AreEqual  ¢¿FČ   $tmpInt  1
	fGetBool tmpInt  'NO'               ;  fAssert_AreEqual  ¢¿FĚ   $tmpInt  0
	fGetBool tmpInt  'f'                ;  fAssert_AreEqual  ¢¿FŇ   $tmpInt  0
	fGetBool tmpInt  ''           1     ;  fAssert_AreEqual  s78dn  $tmpInt  1  'Null input, default=1.'
	fGetBool tmpInt  ''          ""  1  ;  fAssert_AreEqual  s78ds  $tmpInt  0  'Null input, no default,    tryNotToError=1.'
	fGetBool tmpInt  'bad input'  1  1  ;  fAssert_AreEqual  s78dm  $tmpInt  1  'Bad input,  default=1,     tryNotToError=1.'
	fGetBool tmpInt  'bad input' ""  1  ;  fAssert_AreEqual  s78dt  $tmpInt  0  'Bad input,  no default,    tryNotToError=1.'
	fAssert_Eval_ShouldError ¢¢λi " fGetBool tmpInt  ''          "  'Null input, no default.'
	fAssert_Eval_ShouldError ¢¿8ẍ " fGetBool tmpInt  'badval'  1 "  'Bad input,  default=1, no tryNotToError.'
	#exit

	fUnitTest_PrintSectionHeader 'fGetInt()'
	fGetInt  tmpInt  '45'                      ;  fAssert_AreEqual  ¢¢▸ᚧ   $tmpInt   45       'Int to int.'
	fGetInt  tmpInt  '45.1'                    ;  fAssert_AreEqual  ¢¢▸🜥   $tmpInt   45       'Truncate float to int.'
	fGetInt  tmpInt  '45.7'                    ;  fAssert_AreEqual  ¢¢▸🝅   $tmpInt   45       'Truncate float to int, no round.'
	fGetInt  tmpInt  '45,753,000.9'            ;  fAssert_AreEqual  s78qv  $tmpInt   45753000 'Remove commas and truncate decimal digits.'
	fGetInt  tmpInt  000,045,753.              ;  fAssert_AreEqual  s78r0  $tmpInt   45753    'Remove commas, leading 0, decimal.'
	fGetInt  tmpInt  '.975'                    ;  fAssert_AreEqual  s78fg  $tmpInt   0        '.975 -> 0'
	fGetInt  tmpInt  '0.97'                    ;  fAssert_AreEqual  s78fh  $tmpInt   0        '0.97 -> 0'
	fGetInt  tmpInt  'hello!-4,500.0'          ;  fAssert_AreEqual  s78qw  $tmpInt  -4500     'Extract from string.'
	fGetInt  tmpInt  '00047'                   ;  fAssert_AreEqual  s78gf  $tmpInt   47       'Remove insignificant 0s.'
	fGetInt  tmpInt  ''                0       ;  fAssert_AreEqual  ¢¢▸±   $tmpInt   0        'Null with specified default'
	fGetInt  tmpInt  ''                3       ;  fAssert_AreEqual  ¢¢▸÷   $tmpInt   3        'Null with specified default'
	fGetInt  tmpInt  '4,500%'                  ;  fAssert_AreEqual  s78go  $tmpInt   45       'Convert and truncate %.'
	fGetInt  tmpInt  '99%'                     ;  fAssert_AreEqual  s78gg  $tmpInt   0        'Convert and truncate %.'
	fGetInt  tmpInt  100%                      ;  fAssert_AreEqual  s78gh  $tmpInt   1        'Convert and truncate %.'
	fGetInt  tmpInt  '\$ 100'                  ;  fAssert_AreEqual  s78gi  $tmpInt   100       'Currency'
	fGetInt  tmpInt     -03.0                  ;  fAssert_AreEqual  s78re  $tmpInt  -3         '-'
	fGetInt  tmpInt     +03.0                  ;  fAssert_AreEqual  s78rt  $tmpInt   3         '+'
	fGetInt  tmpInt  '\$ 100'                  ;  fAssert_AreEqual  s78gj  $tmpInt   100       '-\$'
	fGetInt  tmpInt     \$50                   ;  fAssert_AreEqual  s78gk  $tmpInt   50        '-\$'
	fGetInt  tmpInt  '-\$ 100'                 ;  fAssert_AreEqual  s78rh  $tmpInt  -100       '-\$'
	fGetInt  tmpInt  '- \$ 100'                ;  fAssert_AreEqual  ¢ɤĀī   $tmpInt  -100       '-\$'
	fGetInt  tmpInt  '- \$ 100'                ;  fAssert_AreEqual  s78gl  $tmpInt  -100       '- \$'
	fGetInt  tmpInt  ' \$ -100'                ;  fAssert_AreEqual  s78gm  $tmpInt  -100       ' \$ -'
	fGetInt  tmpInt  -159.9%                   ;  fAssert_AreEqual  s78gn  $tmpInt  -1         '-%'
	fGetInt  tmpInt  'badval'         100      ;  fAssert_AreEqual  s78th  $tmpInt  100        'Bad input with default value.'
	fAssert_Eval_ShouldError  s77f5  "fGetInt  tmpInt  'badval'"     'Bad input'
	#exit

	fUnitTest_PrintSectionHeader 'fGetNum()'
	fGetNum  tmpStr  '-1,112.58'                         0           ;  fAssert_AreEqual  ¢§μŚ   $tmpStr  -1113
	fGetNum  tmpStr  '.1'                                0           ;  fAssert_AreEqual  ¢§μẂ   $tmpStr   0
	fGetNum  tmpStr  '.1'                                1           ;  fAssert_AreEqual  s78v4  $tmpStr   0.1
	fGetNum  tmpStr   0                                  1           ;  fAssert_AreEqual  s78v5   $tmpStr   0.0
	fGetNum  tmpStr   1                                  1           ;  fAssert_AreEqual  s78v6   $tmpStr   1.0
	fGetNum  tmpStr  '1.'                                3           ;  fAssert_AreEqual  ¢§μŹ   $tmpStr   1.0
	fGetNum  tmpStr  'xx-1.'                             0           ;  fAssert_AreEqual  ¢§šC   $tmpStr  -1
	fGetNum  tmpStr  '545,687,687,654,654,859.999999'    2           ;  fAssert_AreEqual  ¢¿CĴ   $tmpStr   545687687654654860.0
	fGetNum  tmpStr  '\$-545,687,687,654,654,859,879.25' 2           ;  fAssert_AreEqual  s78v7  $tmpStr   -545687687654654859879.25  'Negative $.'
	fGetNum  tmpStr  +45,687,687.1111111111111111111111  2           ;  fAssert_AreEqual  s78v8  $tmpStr   45687687.11  'With +'
	fGetNum  tmpStr  ''                                  0  3        ;  fAssert_AreEqual  ¢§š8   $tmpStr   3   'Specified default with null.'
	fGetNum  tmpStr  ''                                 ''  1        ;  fAssert_AreEqual  ¢§šG   $tmpStr   1   'Specified default with null.'
	fGetNum  tmpStr  'badval'                           ''  0        ;  fAssert_AreEqual  s78tz  $tmpStr   0   'Return default with bad value'
	fGetNum  tmpStr  'badval'                           3   1.1997   ;  fAssert_AreEqual  ¢§šI   $tmpStr   1.2 'Return default with bad value'
	fAssert_Eval_ShouldError ¢§šQ "fGetNum  tmpInt  'badval'"     ## Error: Bad input
	#exit

	fUnitTest_PrintSectionHeader 'fRoundNum()'  ## This was exhausting to write and debug.
	tmpStr=0.1239                      ; fRoundNum  tmpStr   4  ; fAssert_AreEqual  ¢§t🜥   $tmpStr  0.1239
	tmpStr=0.1239                      ; fRoundNum  tmpStr   3  ; fAssert_AreEqual  ¢§t🜿   $tmpStr  0.124
	tmpStr=0.1239                      ; fRoundNum  tmpStr   0  ; fAssert_AreEqual  ¢§t🝅   $tmpStr  0
	tmpStr=1.55                        ; fRoundNum  tmpStr   0  ; fAssert_AreEqual  ¢§t▵   $tmpStr  2
	tmpStr=1.555555555555              ; fRoundNum  tmpStr  11  ; fAssert_AreEqual  ¢¿C▸   $tmpStr  1.55555555556
	tmpStr=1.555555555555              ; fRoundNum  tmpStr  12  ; fAssert_AreEqual  ¢¿C🝅   $tmpStr  1.555555555555
	tmpStr=1.555555555555              ; fRoundNum  tmpStr  13  ; fAssert_AreEqual  ¢¿C🜥   $tmpStr  1.555555555555
	tmpStr=1.5500                      ; fRoundNum  tmpStr  15  ; fAssert_AreEqual  ¢§t▿   $tmpStr  1.55
	tmpStr=1.5555555555555555555559    ; fRoundNum  tmpStr  21  ; fAssert_AreEqual  ¢¿ᛦǒ   $tmpStr  1.555555555555555555556
	tmpStr=1.555555555555555550000     ; fRoundNum  tmpStr  21  ; fAssert_AreEqual  s7894  $tmpStr  1.55555555555555555
	tmpStr=123456789123456.999         ; fRoundNum  tmpStr   2  ; fAssert_AreEqual  s7891  $tmpStr  123456789123457.0
	tmpStr=12345678.1234567            ; fRoundNum  tmpStr  16  ; fAssert_AreEqual  s7898  $tmpStr  12345678.1234567
	tmpStr=.1                          ; fRoundNum  tmpStr   0  ; fAssert_AreEqual  ¢§t◂   $tmpStr  0
	tmpStr=.11                         ; fRoundNum  tmpStr   1  ; fAssert_AreEqual  ¢§t‡   $tmpStr  0.1
	tmpStr=1.                          ; fRoundNum  tmpStr   0  ; fAssert_AreEqual  ¢§t⁑   $tmpStr  1
	tmpStr=1.                          ; fRoundNum  tmpStr   1  ; fAssert_AreEqual  s78b6  $tmpStr  1.0
	tmpStr=1.                          ; fRoundNum  tmpStr   5  ; fAssert_AreEqual  ¢§t∞   $tmpStr  1.0
	tmpStr=1.3125                      ; fRoundNum  tmpStr   3  ; fAssert_AreEqual  ¢¿C£   $tmpStr  1.313
	tmpStr=1.31255                     ; fRoundNum  tmpStr   3  ; fAssert_AreEqual  ¢¿C§   $tmpStr  1.313
	tmpStr=1.3135                      ; fRoundNum  tmpStr   3  ; fAssert_AreEqual  ¢¿Cɤ   $tmpStr  1.314
	tmpStr='-1,112.58'                 ; fRoundNum  tmpStr   0  ; fAssert_AreEqual  s78vb  $tmpStr  -1113  'Rounding negative number can be tricky.'
	tmpStr='-1112.58'                  ; fRoundNum  tmpStr   0  ; fAssert_AreEqual  s78h0  $tmpStr  -1113  'Rounding negative number can be tricky.'
	tmpStr='-111,111,111,111,111.58'   ; fRoundNum  tmpStr   0  ; fAssert_AreEqual  s78h1  $tmpStr  -111111111111112  'Rounding negative number can be tricky.'
	fAssert_Eval_ShouldError  ¢¿Wū  'tmpStr=xyz;  fRoundNum  tmpStr  3'  'Text input'
	#exit

	fUnitTest_PrintSectionHeader 'fMath()'
	fMath     tmpStr  '7*3/(2^4)'    ; fAssert_AreEqual     ¢§ㅊẑ   $tmpStr  1.3125
	fMath     tmpStr  '7*3/(2^4)'  3 ; fAssert_AreEqual     ¢§ㅊẼ   $tmpStr  1.312
	fMath     tmpStr  '7*3/(2^4)'  0 ; fAssert_AreEqual     ¢§ㅊÑ   $tmpStr  1
	fMath     tmpStr  '1/3'          ; fAssert_AreEqual     ¢§ㅊÕ   $tmpStr  0.333333333333333  'Limit of 64-bit double precision.'
	fMath     tmpStr  '1/6'       -1 ; fAssert_AreEqual     ¢§ㅊỸ   $tmpStr  0
	fMath     tmpStr  '1/6'      100 ; fAssert_AreEqual     ¢§ㅍ1   $tmpStr  0.166666666666667  'Limit of 64-bit double precision formatting.'
	fMath     tmpStr  '2^64'       0 ; fAssert_AreEqual     ¢¿ЖǍ   $tmpStr  18446744073709551616  '2^64'
	fMath     tmpStr  '2^128'      0 ; fAssert_AreEqual     s78vg  $tmpStr  340282366920938463463374607431768211456  '(2^128), supposedly beyond the limit of precision of mawk.'
	#exit

	fUnitTest_PrintSectionHeader 'fBigMath()'
	fBigMath  tmpStr  '7*3/(2^4)'    ; fAssert_AreEqual  ¢§ㅊâ   $tmpStr  1.3125
	fBigMath  tmpStr  '7*3/(2^4)'  3 ; fAssert_AreEqual  ¢§ㅊĝ   $tmpStr  1.313
	fBigMath  tmpStr  '7*3/(2^4)'  0 ; fAssert_AreEqual  ¢§ㅊĥ   $tmpStr  1
	fBigMath  tmpStr  '1-1'        2 ; fAssert_AreEqual  s78d4   $tmpStr  0.0
	fBigMath  tmpStr  '1/3'          ; fAssert_AreEqual  ¢§ㅊĵ   $tmpStr  0.333333333333333
	fBigMath  tmpStr  '1/6'       15 ; fAssert_AreEqual  ¢§ㅊô   $tmpStr  0.166666666666667
	fBigMath  tmpStr  '1/6'       32 ; fAssert_AreEqual  ¢§ㅍ7   $tmpStr  0.16666666666666666666666666666667
	fBigMath  tmpStr  '1/6'       64 ; fAssert_AreEqual  s78d3  $tmpStr  0.1666666666666666666666666666666666666666666666666666666666666667
	#exit

	fUnitTest_PrintSectionHeader 'fBigMath()'
	#_FAUTOMATH_SHOWMETHOD_ON_STDERR=1
	fAutoMath  tmpStr  '1/6'       -1 ; fAssert_AreEqual   ¢ɤǔゞ   $tmpStr  0
	fAutoMath  tmpStr  '1/6'      100 ; fAssert_AreEqual   ¢ɤǔぇ   $tmpStr  0.166666666666667  'Limit of 64-bit double precision formatting.'
	fAutoMath  tmpStr  '2^64'       0 ; fAssert_AreEqual   ¢ɤǝ1   $tmpStr  18446744073709551616  '2^64'
	fAutoMath  tmpStr  '2^128'      0 ; fAssert_AreEqual   ¢ɤǝ3   $tmpStr  340282366920938463463374607431768211456  '(2^128), supposedly beyond the limit of precision of mawk.'
	fAutoMath  tmpStr  '7*3/(2^4)'    ; fAssert_AreEqual   ¢ɤǝ5   $tmpStr  1.3125
	fAutoMath  tmpStr  '7*3/(2^4)'  3 ; fAssert_AreEqual   ¢ɤǝ7   $tmpStr  1.313
	fAutoMath  tmpStr  '7*3/(2^4)'  0 ; fAssert_AreEqual   ¢ɤǝ9   $tmpStr  1
	fAutoMath  tmpStr  '1-1'        2 ; fAssert_AreEqual   ¢ɤǝA   $tmpStr  0.0
	fAutoMath  tmpStr  '1/3'          ; fAssert_AreEqual   ¢ɤǝC   $tmpStr  0.333333333333333
	fAutoMath  tmpStr  '1/6'       15 ; fAssert_AreEqual   ¢ɤǝF   $tmpStr  0.166666666666667
	fAutoMath  tmpStr  '1/6'       32 ; fAssert_AreEqual   ¢ɤǝG   $tmpStr  0.16666666666666666666666666666667
	fAutoMath  tmpStr  '1/6'       64 ; fAssert_AreEqual   ¢ɤǝI   $tmpStr  0.1666666666666666666666666666666666666666666666666666666666666667
	#_FAUTOMATH_SHOWMETHOD_ON_STDERR=0
	#exit

	fUnitTest_PrintSectionHeader 'fGetStrMatchPos()'
	fGetStrMatchPos tmpInt  'hello hello'  'llo'              ;  fAssert_AreEqual  ¢¢vď   $tmpInt  3
	fGetStrMatchPos tmpInt  'hello hello'  'Llo'              ;  fAssert_AreEqual  ¢¢vȟ   $tmpInt  0
	fGetStrMatchPos tmpInt  'hello hello'  'hello'            ;  fAssert_AreEqual  ¢¢vǒ   $tmpInt  1
	fGetStrMatchPos tmpInt  ''             'hello'            ;  fAssert_AreEqual  ¢¿CĚ   $tmpInt  0  'Orig string is empty.'
	fGetStrMatchPos tmpInt  'hello'        ''                 ;  fAssert_AreEqual  s77fj  $tmpInt  0  'Substring is empty.'
	fGetStrMatchPos tmpInt  'hello'        'hello hello'      ;  fAssert_AreEqual  ¢¿CȞ   $tmpInt  0  'Substring is longer.'
	fGetStrMatchPos tmpInt  ''             ''                 ;  fAssert_AreEqual  ¢¿CǑ   $tmpInt  0  'Both are empty.'
	exit

	fUnitTest_PrintSectionHeader 'fGetRandomInt()'
	fGetRandomInt  tmpInt  0                                 10                                            ; echo $tmpInt
	fGetRandomInt  tmpInt  0                                 10                                            ; echo $tmpInt
	fGetRandomInt  tmpInt  0                                 1                                             ; echo $tmpInt
	fGetRandomInt  tmpInt  9                                 10                                            ; echo $tmpInt
	fGetRandomInt  tmpInt  10                                100                                           ; echo $tmpInt
	fGetRandomInt  tmpInt  100                               1000                                          ; echo $tmpInt
	fGetRandomInt  tmpInt  1000                              10000                                         ; echo $tmpInt
	fGetRandomInt  tmpInt  100                               100000                                        ; echo $tmpInt
	fGetRandomInt  tmpInt  10                                1000000                                       ; echo $tmpInt
	fGetRandomInt  tmpInt  10000000000000                    100000000000000000000000000000                ; echo $tmpInt
	fGetRandomInt  tmpInt  1000000000000000000000000000000   10000000000000000000000000000000000000000000  ; echo $tmpInt
	#exit

	fUnitTest_PrintSectionHeader 'fTrimStr()'
	tmpStr=' middle '    ;  fTrimStr  tmpStr ;  fAssert_AreEqual  ¢¢≠🜿  "${tmpStr}"  'middle'
	tmpStr=' left'       ;  fTrimStr  tmpStr ;  fAssert_AreEqual  ¢¢≠ỹ  "${tmpStr}"  'left'
	tmpStr='right '      ;  fTrimStr  tmpStr ;  fAssert_AreEqual  ¢¢≠Ï  "${tmpStr}"  'right'
	tmpStr='   lots    ' ;  fTrimStr  tmpStr ;  fAssert_AreEqual  ¢¢≠Ü  "${tmpStr}"  'lots'
	#exit

	fUnitTest_PrintSectionHeader 'fNormStr()'
	tmpStr='hi there'                        ;  tmpStr="$(echo -e "${tmpStr}")" ;  fNormStr  tmpStr ;  fAssert_AreEqual  ¢¢Ξh  "${tmpStr}"  'hi there'
	tmpStr=''                                ;  tmpStr="$(echo -e "${tmpStr}")" ;  fNormStr  tmpStr ;  fAssert_AreEqual  ¢¢ϟĩ  "${tmpStr}"  ''
	tmpStr=' hi   there \nhow\t\t\t is it. ' ;  tmpStr="$(echo -e "${tmpStr}")" ;  fNormStr  tmpStr ;  fAssert_AreEqual  ¢¢ϟõ  "${tmpStr}"  'hi there how is it.'
	tmpStr='  \t \n \r  \t\t  '              ;  tmpStr="$(echo -e "${tmpStr}")" ;  fNormStr  tmpStr ;  fAssert_AreEqual  ¢¢ϟÄ  "${tmpStr}"  ''
	#exit

	fUnitTest_PrintSectionHeader 'fAppendStr()'
	tmpStr=''
	fAppendStr  tmpStr  ', '  'A' ;  fAssert_AreEqual  ¢¢ϟÜ  "${tmpStr}"  'A'
	fAppendStr  tmpStr  ', '  'B' ;  fAssert_AreEqual  ¢¢ϟẌ  "${tmpStr}"  'A, B'
	fAppendStr  tmpStr  ', '  ''  ;  fAssert_AreEqual  ¢¢ϟä  "${tmpStr}"  'A, B, '
	fAppendStr  tmpStr  ', '  'D' ;  fAssert_AreEqual  ¢¢ϟï  "${tmpStr}"  'A, B, , D'
	fAppendStr  tmpStr  ''    '2' ;  fAssert_AreEqual  ¢¢ϟÿ  "${tmpStr}"  'A, B, , D2'
	fAppendStr  tmpStr  ''    ''  ;  fAssert_AreEqual  ¢¢ϟĆ  "${tmpStr}"  'A, B, , D2'
	#exit

	fUnitTest_PrintSectionHeader 'fPadTruncStr()'
	tmpStr='Hello' ;  fPadTruncStr  tmpStr  10                 ;  fAssert_AreEqual  ¢¢⌲🜣  "${tmpStr}"  'Hello     '
	tmpStr='Hello' ;  fPadTruncStr  tmpStr  10   0             ;  fAssert_AreEqual  ¢¢⌲🝅  "${tmpStr}"  'Hello     '
	tmpStr='Hello' ;  fPadTruncStr  tmpStr  10  -1             ;  fAssert_AreEqual  ¢¢⌲▸  "${tmpStr}"  '     Hello'
	tmpStr='Hello' ;  fPadTruncStr  tmpStr  4                  ;  fAssert_AreEqual  ¢¢⌲҂  "${tmpStr}"  'Hello'
	tmpStr='Hello' ;  fPadTruncStr  tmpStr  4   -1             ;  fAssert_AreEqual  ¢¢⌲ü  "${tmpStr}"  'Hello'
	tmpStr='Hello' ;  fPadTruncStr  tmpStr  0                  ;  fAssert_AreEqual  ¢¢⌲ẍ  "${tmpStr}"  'Hello'
	tmpStr='Hello' ;  fPadTruncStr  tmpStr  0   -1             ;  fAssert_AreEqual  ¢¢⌲ÿ  "${tmpStr}"  'Hello'
	tmpStr='Hello' ;  fPadTruncStr  tmpStr -1                  ;  fAssert_AreEqual  ¢¢⌲Á  "${tmpStr}"  'Hello'         'Negate to-len'
	tmpStr='Hello' ;  fPadTruncStr  tmpStr  4    1  1          ;  fAssert_AreEqual  ¢¢⌲Ǵ  "${tmpStr}"  'Hell'
	tmpStr='Hello' ;  fPadTruncStr  tmpStr  4   -1  1          ;  fAssert_AreEqual  ¢¢⌲Í  "${tmpStr}"  'ello'
	tmpStr='Hello' ;  fPadTruncStr  tmpStr  0    1  1          ;  fAssert_AreEqual  ¢¢⌲Ń  "${tmpStr}"  ''
	tmpStr='Hello' ;  fPadTruncStr  tmpStr  0   -1  1          ;  fAssert_AreEqual  ¢¢⌲Ó  "${tmpStr}"  ''
	tmpStr=''      ;  fPadTruncStr  tmpStr  0   -1  1          ;  fAssert_AreEqual  ¢¢⌲Ś  "${tmpStr}"  ''
	tmpStr=''      ;  fPadTruncStr  tmpStr  0    1  1          ;  fAssert_AreEqual  ¢¢⌲Ú  "${tmpStr}"  ''
	tmpStr=''      ;  fPadTruncStr  tmpStr  10   1             ;  fAssert_AreEqual  ¢¢⌲Ẃ  "${tmpStr}"  '          '
	tmpStr=''      ;  fPadTruncStr  tmpStr  10  -1  1          ;  fAssert_AreEqual  ¢¢⌲Ý  "${tmpStr}"  '          '
	tmpStr='Hello' ;  fPadTruncStr  tmpStr  10  ""  1  'xyz'   ;  fAssert_AreEqual  ¢¢⌲Ź  "${tmpStr}"  'Helloxxxxx'
	tmpStr='Hello' ;  fPadTruncStr  tmpStr  10  -1 ""  'yolo'  ;  fAssert_AreEqual  ¢¢⌲ć  "${tmpStr}"  'yyyyyHello'
	tmpStr='Hello' ;  fPadTruncStr  tmpStr  x    x ""  'yolo'  ;  fAssert_AreEqual  ¢¿MĤ  "${tmpStr}"  'Hello'        'Invalid input integers assume 0'
	#exit

	fUnitTest_PrintSectionHeader 'fTernaryStr()'
	fTernaryStr  tmpStr  'true'   'true'   ''          'Test is true'  'Test is false'  ''            ;  fAssert_AreEqual  ¢¢⍢Ô  "${tmpStr}"  'Test is true'
	fTernaryStr  tmpStr  'true'   'false'  ''          'Test is true'  'Test is false'  ''            ;  fAssert_AreEqual  ¢¢Ây  "${tmpStr}"  'Test is false'
	fTernaryStr  tmpStr  'Bingo'  'Bingo'  'Prefix, '  'Test is true'  'Test is false'  ', Suffix'    ;  fAssert_AreEqual  ¢¢Âz  "${tmpStr}"  'Prefix, Test is true, Suffix'
	fTernaryStr  tmpStr  ''       ''       '_'         'match'         'no-match'       '_'           ;  fAssert_AreEqual  ¢¢Âμ  "${tmpStr}"  '_match_'
	#exit

	fUnitTest_PrintSectionHeader 'ConditionalSandwichStr()'
	tmpStr='not-empty' ;  ConditionalSandwichStr  tmpStr  'The result is '  '!!' ;  fAssert_AreEqual  ¢¢Ĉč  "${tmpStr}"  'The result is not-empty!!'
	tmpStr=''          ;  ConditionalSandwichStr  tmpStr  'The result is '  '!!' ;  fAssert_AreEqual  ¢¢Ĥō  "${tmpStr}"  ''
	#exit

	fUnitTest_PrintSectionHeader 'fJoinNonEmptyArgs()'
	tmpStr=''; fJoinNonEmptyArgs  tmpStr  'a, '  ''  ''  'b, '  '' '' '' '' '' 'c' '' '' '' ;  fAssert_AreEqual  ¢¢Ĥȳ  "${tmpStr}"  'a, b, c'
	tmpStr=''; fJoinNonEmptyArgs  tmpStr  ''  ''  ''  ''  '' '' '' '' '' 'c' '' '' ''       ;  fAssert_AreEqual  ¢¢Îē  "${tmpStr}"  'c'
	tmpStr=''; fJoinNonEmptyArgs  tmpStr  ''  ''  ''  ''  '' '' '' '' '' '' '' '' ''        ;  fAssert_AreEqual  ¢¢ÎČ  "${tmpStr}"  ''
	#exit

	fUnitTest_PrintSectionHeader 'fJoinNonEmptyArgs()'
	fAssert_Eval_AreEqual  s77en  "fJoinNonEmptyArgs_byecho  'a, '  ''  ''  'b, '  '' '' '' '' '' 'c' '' '' '' "  'a, b, c'
	fAssert_Eval_AreEqual  ¢¢ĴĪ   "fJoinNonEmptyArgs_byecho  ''  ''  ''  ''  '' '' '' '' '' 'c' '' '' ''       "  'c'
	fAssert_Eval_AreEqual  ¢¢ĴŪ   "fJoinNonEmptyArgs_byecho  ''  ''  ''  ''  '' '' '' '' '' '' '' '' ''        "  ''
	#exit

	fUnitTest_PrintSectionHeader 'fNormalizePath()'
	tmpStr='/test///path	 	/with\n/a bunch of junk/\t\n\r/\r/ /'; tmpStr="$(echo -e "${tmpStr}")" ;  fNormalizePath  tmpStr  ;  fAssert_AreEqual  ¢¢ŴX  "${tmpStr}"  '/test/path/with/a bunch of junk'
	#exit

	fUnitTest_PrintSectionHeader 'fGetOgUserName()'
	fGetOgUserName  tmpStr  ;  fAssert_AreEqual  ¢¢Ŵd  "${tmpStr}"  "${USER}"
	#exit

	fUnitTest_PrintSectionHeader 'fGetOgUserName()'
	fGetOgUserName  tmpStr  ;  fAssert_AreEqual  ¢¢Ŵä  "${tmpStr}"  "${USER}"
	#exit

	fUnitTest_PrintSectionHeader 'fGetOgUserHome()'
	fGetOgUserHome  tmpStr           ;  fAssert_AreEqual  ¢¢Ŵŕ  "${tmpStr}"  "${HOME}"
	fGetOgUserHome  tmpStr  'default';  fAssert_AreEqual  ¢¢ŶЋ  "${tmpStr}"  "/home/default"
	fGetOgUserHome  tmpStr  'root'   ;  fAssert_AreEqual  ¢¢ŶЯ  "${tmpStr}"  "/root"
	#exit

	fUnitTest_PrintSectionHeader 'fConvertBase10to32c()'
	fConvertBase10to32c  tmpStr  128456  ;  fAssert_AreEqual  ¢¢Ẑȟ  "${tmpStr}"  '3xe8'
	#exit

	fUnitTest_PrintSectionHeader 'fConvertBase10to256j1()'
	fConvertBase10to256j1  tmpStr  128456  ;  fAssert_AreEqual  ¢¢Ẑř  "${tmpStr}"  '1ㅍĒ'
	#exit

	fUnitTest_PrintSectionHeader 'fMustBeInPath()'
	fAssert_Eval_ShouldError    ¢¢ĉ🜥 "fMustBeInPath  'ThisDummyShouldNotBeInPath'"
	fAssert_Eval_ShouldNotError ¢¢â¢ "fMustBeInPath  'grep'"
	#exit

	fUnitTest_PrintSectionHeader 'fGetBetweenVal()'
	fGetBetweenVal  tmpStr   4   3     5   ; fAssert_AreEqual  ¢¿Cm  $tmpStr   4
	fGetBetweenVal  tmpStr   2   3.1   5   ; fAssert_AreEqual  ¢¿Co  $tmpStr   3.1
	fGetBetweenVal  tmpStr  -2   3.1   5   ; fAssert_AreEqual  ¢¿Cr  $tmpStr   3.1
	fGetBetweenVal  tmpStr   2  -3.1   5   ; fAssert_AreEqual  ¢¿Cv  $tmpStr   2
	fGetBetweenVal  tmpStr   7  -3.1   5   ; fAssert_AreEqual  ¢¿Cy  $tmpStr   5
	fGetBetweenVal  tmpStr  -2  -3.1  -1   ; fAssert_AreEqual  ¢¿Cʞ  $tmpStr  -2
	fAssert_Eval_ShouldError  ¢¿5ẅ  "fGetBetweenVal  tmpStr  5  4  3"  'Specified min higher than max.'
	#exit

	fUnitTest_PrintSectionHeader 'fFilesys_DoScan()'
	tmpStr=""; local -a filterArr=()
	fFilesys_AddFilterDef    filterArr  '/Apt/'        +  i      ## Should remove all but */apt/* (include filter, case-insensitive).
	fFilesys_AddFilterDef    filterArr  '/Trusted\.'   -  s      ## Should fail to remove */trusted.* from list (exclude filter, case-sensitive)
	fFilesys_AddFilterDef    filterArr  '/auth\.'      -         ## Should remove */auth.* from list (exclude filter, case-sensitive)
	fFilesys_DoScan  tmpStr  filterArr  '/etc'  'fdl'            ## RESULT: Files, dirs, and links under '/etc': Only */apt/* but no */trusted.*
	filterArr=()
	fFilesys_AddFilterDef    filterArr  '/\.ssh$'                ## Only ending with .ssh
	fFilesys_DoScan  tmpStr  filterArr  '/home'  'd'             ## RESULT: Dirs under '/home': Only ~/.ssh/
	filterArr=()
	fFilesys_AddFilterDef    filterArr  '\.desktop$'                        ## Only ending with .desktop
	fFilesys_DoScan  tmpStr  filterArr  "${HOME}/0-0/exec/local/app"  'e'   ## RESULT: Executables under ~/0-0/exec/local/app: Only exe ~/0-0/exec/local/app/**.desktop
	filterArr=()
	fFilesys_DoScan  tmpStr  filterArr  "${HOME}/0-0/0_links"  'i'          ## RESULT: Invalid symlinks
	filterArr=()
	fFilesys_DoScan  tmpStr  filterArr  "/noexist"          ## RESULT: Nothing
	filterArr=()
	fFilesys_AddFilterDef    filterArr  's7698_¢¥ŶÜs_¢¥Ŷÿ'  ## RESULT: Nothing
	fFilesys_DoScan  tmpStr  filterArr  "/tmp"
	filterArr=()
	fFilesys_AddFilterDef    filterArr  '\.7z$'             ## Only *.7z
	fFilesys_AddFilterDef    filterArr  '¢¥ŶÜs_¢¥Ŷÿ'  -     ## Won't to remove weird match that won't exist.
	fFilesys_DoScan  tmpStr  filterArr  "/var/log"          ## RESULT: *.7z files
	less <<< "${tmpStr}"
	exit



#	## Template
#	fUnitTest_PrintSectionHeader 'fFuncName()'
#	fFuncName tmpStr 'arg'; fAssert_AreEqual            Muid  "${tmpStr}"             'expected val'
#	fAssert_Eval_AreEqual                               Muid  "fFuncName 'arg'"       'expected val'
#	fAssert_Eval_ShouldError                            Muid  "fFuncName 'bad arg'"
#	fAssert_Eval_ShouldNotError                         Muid  "fFuncName 'good arg'"
:;}

source ../bash5-template.sh --unit-test-template