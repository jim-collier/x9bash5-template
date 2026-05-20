<!-- markdownlint-disable MD007 -- Unordered list indentation -->
<!-- markdownlint-disable MD010 -- No hard tabs -->
<!-- markdownlint-disable MD033 -- No inline html -->
<!-- markdownlint-disable MD055 -- Table pipe style [Expected: leading_and_trailing; Actual: leading_only; Missing trailing pipe] -->
<!-- markdownlint-disable MD041 -- First line in a file should be a top-level heading -->

# Readme - legacy functions

Most of the functions in the scripts in this directory - although battle-tested even in production environments - have too many problems to include in a module yet - or possibly ever.

Many of them bring performance to its knees in long-running loops, due to heavy reliance on external tools like `grep` and `sed`, for even trivial operations that could be done natively without forking to several subshells. (But to be fair, some problems will be much harder to solve natively, without such powerful external tools.)

The files are in this repository, as a convenient place for possible/eventual consideration of the worthiness of the functions, for refactoring (gradually one at a time) into non-forking, idiomatic Bash 5 form.

## Evaluate each function to consider

1. Is it even necessary. There may be (and often are) simple, bash-idiomatic, one-liner ways to do the same thing, that aren't too hard to remember (especially if you don't have a crutch wrapper function to always fall back on).

2. Can it be refactored without too much effort, to conform to the objectives below? Or at least, would a complete rewrite be easier and also justifiable? Each function's purpose is usually tiny enough in scope, that the intended input and output is either obvious, or explicitly stated - with no hidden "business logic" or other gotchas typical of, say, rewriting an entire enterprise application codebase.

## Objectives for each function

- Avoid forking: any use of subshells, pipes, or external tools like `grep`, `sed`, `awk`, `tr`, `head`, etc.

	- If those powerful tools can be leveraged to make quick work of large amounts of data, let the calling script do it itself.

	- *Or at least indicate some kind of 'large data' as part of the function name to signal that.*

- For functions likely to be called in a long-running loop, absolutely no such forking, piping, etc., as a hard requirement.

- Be not just fully Bash-idiomatic (most of which these are not), but Bash 5 idiomatic. (*2014 called and wants their legacy Bash scripts back. 1988 called and wants their POSIX scripts back.*)

- Conform to author's own "[Bash 5 Ultimate Guide](https://github.com/jim-collier/bash-5-ultimate-guide)", which includes the former guidelines and more.