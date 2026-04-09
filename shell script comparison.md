<!-- markdownlint-disable MD007 -- Unordered list indentation -->
<!-- markdownlint-disable MD010 -- No hard tabs -->
<!-- markdownlint-disable MD033 -- No inline html -->
<!-- markdownlint-disable MD041 -- First line in a file should be a top-level heading -->
<!-- markdownlint-disable MD055 -- Table pipe style [Expected: leading_and_trailing; Actual: leading_only; Missing trailing pipe] -->
# System shell script language comparison

## Table of contents

<!-- TOC -->

- [Table of contents](#table-of-contents)
- [Introduction](#introduction)
- [Requirements to replace Bash for certain projects](#requirements-to-replace-bash-for-certain-projects)
- [Not Requirements](#not-requirements)
- [The contenders](#the-contenders)
	- [Ksh*, Zsh, Yash, Fish, etc.](#ksh-zsh-yash-fish-etc)
	- [Nushell, YSH](#nushell-ysh)
	- [Powershell Core](#powershell-core)
	- [Node.jnodeJS via Deno or zx](#nodejnodejs-via-deno-or-zx)
	- [Python via Plumbum or Xonsh](#python-via-plumbum-or-xonsh)
	- [NET C# formerly ".NET Core"](#net-c-formerly-net-core)
	- [Java via Groovy, Kotlin](#java-via-groovy-kotlin)
	- [Rust, C++](#rust-c)
	- [Go](#go)
- [The winner](#the-winner)

<!-- /TOC -->

## Introduction

Bash ("Bourne-Again SHell") is the 800 lbs gorilla of shell scripting languages. It's the default shell on most Linux distros (and the biggest among them).

It was designed to be backwards-compatible with the original Bourne Shell from 1979. The POSIX standard was later based on the Bourne Shell in 1988, and essentially retroactively blessed it. It's now a a crusty-old closed-source shell that originally had very small ambitions. It's now embodied by the open-source clone Dash. (There are also a few ways to put Bash itself into "POSIX" mode, which isn't exactly the same as Bourne Shell, but close.)

In spite of significant language and syntax improvements, and the ability to do surprisingly advanced things (including the ability to use a more advanced C-like syntax for nearly everything), Bash can still feel pretty crusty, clumsy, and error-prone compared to modern alternatives. Especially when (easily) misused.

The following list isn't meant to be comprehensive.

## Requirements to replace Bash for certain projects

Replacing a shell-scripting language is no easy task. There's a reason why Bash (and more broadly `sh`) is so universal in the *nix world. (Even on macOS, and on Windows via WSL.) On native Windows, PowerShell has done a good job of replacing the horrible, clunky old `cmd` (a hand-me-down from the Intel 8088 DOS interpreter), and is even better on Linux - as it waits for native commands to finish without a lot of extra work. But is very verbose and hard to remember.

So can we do better than Bash or PowerShell? The requirements:

- Modern language features such as strong typing, advanced math and array features, dictionaries/hashmaps, methods and properties, collections of "object"-like structures, syntactic sugaring, etc.
- Cross-platform (Linux, Windows, macOS)
- Long-term stability. Shell scripts are often used for five, ten, twenty years. None should ever break in subtle ways on some runtime updates.
- Either no runtime required, runtime bundled into one distributable file, or is trivially easy to acquire on most operating systems and package managers.
	- If a runtime is required: total confidence in version stability and resistance to foreseeable bitrot.
		- E.g. The runtime environment must inherently support any number of simultaneous runtime versions being installed in parallel (without containers or janky "virtual environments"). And/or future runtime versions must militantly maintain backwards script/program compatibility.
- Significantly faster than Bash. Either advanced parsing/lexing+JIT, or static compilation.
- Interactive debugging.
- IDE features like "jump to definition". (Which some IDEs even support for Bash, but tends to be fragile.)
	- Not really a language feature, but some languages like Bash make it harder to implement.
- Good ecosystem, e.g. CI tooling.

## Not Requirements

- POSIX-compliance. (In fact POSIX-compliance should be considered a burden and a distinct *anti*-requirement, and not a "positive" attribute for any modern language.)
- Expansive third-party module library. (In fact the tyranny of choice and fragmentation can be a burden. E.g. the overwhelming choices in front-end web development.)
- Popularity. Nice to have, but too limiting.

## The contenders

### Ksh*, Zsh, Yash, Fish, etc.

- Pros:
	- Ksh and Zsh are readily available on most distros.
	- Marginal improvements in things like math and array features.
- Cons:
	- All are basically "Bash+", even if that wasn't their goal. Not worth changing for such small incremental gains.
	- Some, like Yash and Fish, are actually slower than Bash for things like loops and arrays.

Verdict: Incremental feature improvements over Bash aren't enough to retool everything.

### Nushell, YSH

These two have very different philosophies, syntax, and optimal use-cases. But they are similar in that they adopt advanced language features while maintaining direct shell-level features, and would be ideal for "pure" shell scripting. YSH in particular seems excellent for things like CI/CD automation glue.

- Pros:
	- Generational leaps beyond Bash (and the other *sh languages).
	- Strong typing, data structures, math and array features, better error-handling.
		- YSH in particular is just super-elegant specifically for system shell scripting, for things like CI/CD glue.
- Cons:
	- Both are actually *slower* than Bash, sometimes significantly so. Which depending on the specific script use-case, may very well be a deal-breaker.
		- This is expected to improve over time for both projects, but that's not something to bank on.
	- No live debuggers AFAIK.
	- YSH seems kind of janky in terms of how the runtime is built, and executes - but that may not matter in daily use.
	- YSH is harder to obtain.
	- Both are uncommon.

Verdict: ❌. Possibly perfection as system shell scripting languages (esp YSH). But the cons (esp speed) unfortunately outweigh that, in terms of our documented requirements.

### Powershell Core

- Pros:
	- Advanced parsing and JIT compilation *should* in theory make it much faster than Bash for large scripts.
	- Strong error-handling.
	- Excellent type system.
	- Fully object-oriented.
	- Possibly the best live-debugging support of any pure scripting language.
		- Mostly up to the editor, but VS Code/Visual Studio are well-integrated with Powershell.
	- For Windows, Microsoft has committed to making it a first-class citizen, and it can basically manipulate anything - settings, services, scheduled tasks, application lifecycle, registry, filesystem, COM, .NET, Active Directory, Outlook, etc.
- Neutral or a wash
	- Multiple parallel runtime versions can be installed, and backwards-compatibility is good but not perfect.
	- Reasonably easy to install the runtime, but must use Microsoft's external repos both on Windows and Linux.
	- On Linux it can directly invoke external system tools - inline and blocking, just like Bash at al. But on Windows, it can't.
		- *Mitigated somewhat by Windows lacking the excellent coreutils of Linux anyway.*
- Cons
	- Some tests show it to be much *slower* than Bash at many simple loops and tasks. (And will definitely be slower than e.g. `awk`, `sed`, `grep` on large amounts of data at once - although Powershell on Linux can also invoke those tools directly on Linux, which makes this point more or less moot.)
	- Syntax is insanely verbose and difficult to remember, and often with long "dot" pipelines for simple tasks.
	- Version/dependency problems over time. Scripts have - and will continue to - become obsolete, with occasional runtime breaking changes.

Verdict: 🤔 Might use (and occasionally do) for smaller projects where OO, type-safety, and strong live-debugging - in a pure native first-party script - is important.

### Node.jnodeJS (via Deno or zx)

- Pros:
	- Everyone knows JS.
	- Typescript can offer an extra layer of type safety etc., at the cost of portability (making TS even via Deno a nonstarter).
	- Easy to manage many installed versions of node.
	- Fast and mature JIT.
- Cons:
	- Everyone has PTSD over JS.
	- Shell scripting with JS is nightmare (but projects like zx and Deno make it easier or possibly even "easy").
	- Scripts don't - and can't - run under a defined node version, though scripts can use their own internal code to refuse to run if an arbitrary version test isn't met.
		- This somewhat obviates the Pro above about managing installed versions.
			- However, the odds of broken *backwards* compatibility is very low (given the compatibility-over-time requirements of the WWW itself).

Verdict: ❌. Sloppy type-safety and error-handling. As long as we're considering a step up into general-purpose programming, we might as well go further to a "real" language.

### Python (via Plumbum or Xonsh)

- Pros:
	- A fun and elegant language, although some aspects (like object constructors) feel like a janky afterthought.
	- Well-known to be great at working with and transforming large amounts of data, thanks to math libraries like 'pandas' and 'numpy'.
	- Difficult for shell scripting, but [Plumbum](https://plumbum.readthedocs.io/en/latest/) helps with that, and [Xonsh](https://xon.sh/contents.html) solves as a python-based shell language.
	- Much faster than Bash.
	- Xonsh is also a pretty neat shell. (Hence the name.)
- Cons:
	- Slow.
	- Difficult to achieve CPU parallelism.
	- An unmatched, unmitigated disaster of runtime, dependency, compatibility, and portability *hell*.
		- Containers, virtual environments, and a mess of incompatible dependency management tools are not acceptable solutions for system shell scripts that need to be highly portable not only across machines and organizations, but sometimes even operating systems.
		- Also: distro-specific library locations, native extensions break across platforms, compiled C bindings are brittle and break, OS-specific native standard libraries, no native app packager and brittle third-party tools, poor runtime version management, and subtle minor version incompatibilities. no built-in package resolver (`pip` will happily install conflicting requirements), namespace collisions,
	- Breaking backwards compatibility. Sometimes subtle, sometimes total. (v3 is literally a different language than 2, but even smaller releases often introduce breaking changes.)
		- Can be mitigated only somewhat by:
			- Not using any third-party dependencies at all - not even `numpy`, `scipy`, `cryptography`.
			- Not using uncommon language features.
			- *Re-running all unit tests after minor release versions*.

Verdict: 🤮. An admittedly nice language but an absolute disaster in practice. Not in a million years.

### .NET C# (formerly ".NET Core")

- Pros:
	- C# is (very arguably) the most advanced language listed here in terms of features and syntax. (Depending on your perspective and tastes. Go or Rust probably has the edge in parallelism and "modernity".)
	- Its JIT is very fast.
- Neutral:
	- Reasonably easy to install the runtime, but must use Microsoft's external repos both on Windows and Linux.
	- Can be "statically compiled" to a single executable that needs no runtime installed.
		- But that really means the compiler "compiles" to bytecode, then stuffs the entire runtime into the executable, which gets extracted at runtime.
		- While that means you don't have to worry about runtime versioning problems, it does greatly balloon the executable size.
- Cons:
	- Poorly-suited to traditional inline blocking shell scripting.

Verdict: 😥. Large executables (at least no runtime installation needed), and sadly just poorly-suited to shell scripting.

### Java (via Groovy, Kotlin)

Your mom or dad's programming language. (Their parents' language was COBOL and FORTRAN.) I have no significant working experience with either, so this is mostly surface-level knowledge:

- Pros:
	- Java is a solid language. Type safety, OO, advanced features, it's all there. Old != bad.
	- JVM performance.
- Cons:
	- Even with Groovy, shell syntax isn't linear or shell-like.

Verdict: ❌. Mostly I just don't want to deal with the heavy Java syntax for system shell scripting. (Though TBF it's not much "worse" than C#, which was "inspired" by Java, and is a nice language.) I also admit to being biased against the Java JVM due to its ownership by Oracle, even though good open-source alternatives exist.

### Rust, C++

There is or used to be a pretty cool C++ shell scripting system. But the cons:

- I think it was/is Windows-only.
- IIRC it is/was closed-source and commercial, possibly requiring sign-up to use, even if it had a more limited free version.
- It's C++. For shell scripting??
- Rust: Too many ways to do things, too steep of a learning curve for shell scripting type tasks, too verbose for scripting. But `rust-script` at least makes scripting possible.

Verdict: 🫪. Who hurt you?

### Go

- Pros:
	- Small, natively machine-code compiled executables that are **100% dependency-free and runtime-free** - that can run on any Linux distro old or new, and indefinitely into the future.
		- We can be pretty confident in that (specific project coding side-effects notwithstanding), since its only real "dependency" is the Linux userland itself - which Linus Torvalds has asserted (somewhat obviously) must never introduce breaking changes. For Windows CLI apps and the WinAPI/CRT, and MacOS' BSD and POSIX userland ABI and APIs, the longevity situation is similar. Simple Linux CLI apps can and do routinely work for decades. Potentially even longer than Bash script backwards-compatibility. Similarly for Windows: the only thing that stops Windows CLI programs from working, are things like having been compiled for a no-longer supported architecture (e.g. 16-bit), the program itself using non-core APIs or extinct Windows features, or making too many hard-coded assumptions about filesystem structure etc. (The same benefits can apply to CLI apps from lower-level languages like Rust or C++, but come on now - we've established that that's just a bridge too far.)
	- Apps can easily be compiled for other platforms (e.g. for Windows CLI from Linux), with just a flag. (To my knowledge this is a unique benefit to Go.)
	- Strong typing, live-debugging, and being able to do the kinds of things that OO can do, albeit differently.
	- The entire versioned development environment can be (and often is) included in Git repos, so that the version a project was built with, is always available and used for maintenance indefinitely into the future.
- Neutral:
	- There's always the risk that the dev environment itself will no longer work on some future Linux version, even if the output executable itself does so forever. But that's no different that any other dev environment. And the fact that it can run from any directory without "installation", already makes it more likely to survive.
- Cons
	- While not as heavy and boilerplate-y as C# or Java, a project is still not as lean as a real scripting language like Bash, YSH, or Powershell.
	- While being compiled is generally a benefit - for performance and security - there are benefits to being able to rapidly edit a script in-place to debug it, then re-run it right away.

Like most real general-purpose languages (as you can see above), Go by itself is ill-suited to system shell scripting. But these modules close the gap a fair amount:

- [go-cmd](https://github.com/go-cmd/cmd) for running system commands with low code and mental overhead.
- [script](https://github.com/bitfield/script) for functions that provide cross-platform capabilities of must-have tools like `awk`, `sed`, `grep`, etc. (and with nice pipelining).
- [afero](https://github.com/spf13/afero) for simplified filesystem handling.

Verdict: 🤷 The tiny, dependency-free executables, that can be compiled on any platform for any other platform, is an attractive feature. It's a fantastic language. Being scriptable, though in not a very portable way, is nice. The modules that make "script-like" duties easy, are also nice - but to be fair those can also be found for pretty much any "real" language. In the end, this is probably the best "real" compiled language on this list for the task, but still not well-suited for shell scripting.

## The winner

Unfortunately there is no clear winner. Everything has tradeoffs. YSH is nice, but a little janky under the hood and not universal. NuShell is nice and more broadly/easily obtainable, but slow. Go is the cross-platform/no-depedency winner, but only when compiled. PowerShell has type-safety, JIT, and OO - but has some subtle breaking version issues over time, and is not trivially easy to obtain. JavaScript is not well-suited for shell scripting.

Non-starters: Python, C++, Rust, CMD, Java. With the worst being Python for long-term script stability.
