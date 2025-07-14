# System shell script language comparison<!-- omit from toc -->

## Table of contents<!-- omit from toc -->

- [Introduction](#introduction)
- [Requirements to replace Bash for certain projects](#requirements-to-replace-bash-for-certain-projects)
- [Not Requirements](#not-requirements)
- [The contenders](#the-contenders)
	- [Ksh\*, Zsh, Yash, Fish, etc.](#ksh-zsh-yash-fish-etc)
	- [Nushell, YSH](#nushell-ysh)
	- [Powershell Core](#powershell-core)
	- [Node.jnodeJS (via Deno or zx)](#nodejnodejs-via-deno-or-zx)
	- [Python (via Plumbum or Xonsh)](#python-via-plumbum-or-xonsh)
	- [.NET C# (formerly ".NET Core")](#net-c-formerly-net-core)
	- [Java (via Groovy, Kotlin)](#java-via-groovy-kotlin)
	- [Rust, C++](#rust-c)
	- [Go](#go)


## Introduction

Bash ("Bourne-Again SHell") is the 800 lbs gorilla of shell scripting languages. It's the default shell on most Linux distros (and the biggest among them).

It was designed to be backwards-compatible with the original Bourne Shell from 1979 (which the POSIX standard was based on and essentially retroactively blessed in 1988). The Bourne Shell is a crusty-old closed-source shell that originally had very small ambitions (and is now embodied by the open-source clone Dash).

In spite of significant language and syntax improvements, and the ability to do surprisingly advanced things, Bash can still feel pretty crusty, clumsy, and error-prone compared to modern alternatives.

The following list isn't meant to be comprehensive.

## Requirements to replace Bash for certain projects

- Modern language features such as strong typing, advanced math and array features, dictionaries/hashmaps, methods and properties, collections of "object"-like structures, syntactic sugaring, etc.
- Cross-platform (Linux, Windows, macOS)
- Either no runtime required, or trivially easy to acquire on most operating systems and package managers.
	- If a runtime is required: total confidence in version stability and resistance to foreseeable bitrot.
		- E.g. The runtime environment must inherently support any number of simultaneous runtime versions being installed in parallel (without containers or janky "virtual environments"). And/or future runtime versions must militantly maintain backwards script/program compatibility.
- Significantly faster than Bash. Either advanced parsing/lexing+JIT, or static compilation.
- Interactive debugging.
- IDE features like "jump to definition". (Which some IDEs even support for Bash, but tends to fragile.)
	- Not really a language feature, but some languages like Bash make it harder to implement.
- Good ecosystem, e.g. CI tooling.

## Not Requirements

- POSIX-compliance. (In fact for a language, this is more of a burden and anti-requirement than a "positive" attribute.)
- Expansive third-party module library. (In fact the tyranny of choice and fragmentation can be a burden. E.g. front-end web development.)
- Popularity.

## The contenders

### Ksh*, Zsh, Yash, Fish, etc.

- Pros:
	- Ksh and Zsh are readily available on most distros.
	- Marginal improvements in things like math and array features.
- Cons:
	- All are basically "Bash+", even if that wasn't their goal. Not worth changing for such small incremental gains.
	- Some, like Yash and Fish, are actually slower than Bash for thing like loops and arrays.

Verdict: Incremental feature improvements over Bash aren't enough.

### Nushell, YSH

These two have very different philosophies, syntax, and optimal use-cases. But they are similar in that they adopt advanced language features while maintaining direct shell-level features, and would be ideal for "pure" shell scripting. YSH in particular seems excellent for things like CI/CD automation glue.

- Pros:
	- Generational leaps beyond Bash (and the other *sh languages).
	- Strong typing, data structures, math and array features, better error-handling.
		- YSH in particular is just super-elegant specifically for system shell scripting, for things like CI/CD glue.
- Cons:
	- Both are actually *slower* than Bash, sometimes significantly so. Which is alone is a disappointing requirements deal-breaker.
		- This is expected to improve over time for both projects, but that's not something to bank on.
	- No live debuggers AFAIK.
	- YSH seems kind of janky in terms of how the runtime is built, and executes, but that may not matter in daily use.
	- YSH harder to obtain.
	- Uncommon.

Verdict: ❌. Possibly perfection as system shell scripting languages (esp YSH). But the cons (esp speed) unfortunately outweigh that.

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
	- Some tests show it to be much *slower* than Bash at many simple loops and tasks. (And will definitely be slower than e.g. `awk`, `sed`, `grep` on large amounts of data at once - although Powershell on Linux can also invoke those tools directly on Linux.)
	- Syntax is insanely verbose and difficult to remember, and often with long "dot" pipelines for simple tasks.

Verdict: 🤔 Might use (and occasionally do) for smaller projects where OO, type-safety, and strong live-debugging - in a pure native first-party script - is important.

### Node.jnodeJS (via Deno or zx)

- Pros:
	- Everyone knows JS.
	- Typescript can offer an extra layer of type safety etc., at the cost of portability (making TS even via Deno a nonstarter).
	- Easy to manage many installed versions of node.
	- Fast and mature JIT.
- Cons:
	- Everyone has PTSD over JS.
	- Shell scripting with JS is nightmare (but projects like zx and Deno make it easier possibly even "easy").
	- Scripts don't - and can't - run under a defined node version, though scripts can refuse to run if an arbitrary version test isn't met.
		- This largely obviates the Pro above.
			- However, the odds of broken *backwards* compatibility is very low (given the compatibility-over-time requirements of the WWW itself).

Verdict: ❌. Sloppy type-safety and error-handling. As long as we're considering a step up into general-purpose programming, we might as well go further to a "real" language.

### Python (via Plumbum or Xonsh)

- Pros:
	- A fun and elegant language, although some aspects (like object constructors) feel like a janky afterthought.
	- Great at transforming large amounts of data.
	- Difficult for shell scripting, but [Plumbum](https://plumbum.readthedocs.io/en/latest/) helps with that, and [Xonsh](https://xon.sh/contents.html) solves as a python-based shell language.
	- Much faster than Bash.
	- Xonsh is also a pretty neat shell. (Hence the name.)
- Cons:
	- An unmatched, unmitigated disaster of runtime, dependency, compatibility, and portability *hell*.
		- Containers, virtual environments, and a mess of incompatible dependency management tools are not acceptable solutions for system shell scripts that need to be highly portable not only across machines and organizations, but sometimes even operating systems.
		- Also: distro-specific library locations, native extensions break across platforms, compiled C bindings are brittle and break, OS-specific native standard libraries, no native app packager and brittle third-party tools, horrific runtime version management, subtle minor version incompatibilities, no built-in package resolver (`pip` will happily install conflicting requirements), namespace collisions,
		- Breaking backwards compatibility. Sometimes subtle, sometimes total. (v3 is literally a different language that 2.)
		- Can be mitigated only somewhat by:
			- Not using any third-party dependencies at all - not even `numpy`, `scipy`, `cryptography`.
			- Not using uncommon language features.
			- *Re-running all unit tests after minor release versions*.

Verdict: 🤮. Not just no but **hell no**. Run. Run away as fast as you can.

### .NET C# (formerly ".NET Core")

- Pros:
	- C# is arguably the most advanced language listed here in terms of features and syntax. (Go probably has the edge on parallelism.)
	- Its JIT is very fast.
- Neutral:
	- Reasonably easy to install the runtime, but must use Microsoft's external repos both on Windows and Linux.
	- Can be "statically compiled" to a single executable that needs to runtime installed. But that really means the compiler "compiles" to bytecode, then stuffs the entire runtime into the executable, which gets extracted at runtime. But at least you don't have runtime installation or versioning problems.
- Cons:
	- Poorly-suited to traditional inline blocking shell scripting.

Verdict: 😥. Large executables (at least no runtime installation needed), and sadly just poorly-suited to shell scripting.

### Java (via Groovy, Kotlin)

I have no experience with either and this is surface-level knowledge.

- Pros:
	- Java is a solid language. Type safety, OO, advanced features, it's all there. Old != bad.
	- JVM performance.
- Cons:
	- Even with Groovy, shell syntax isn't linear or shell-like.

Verdict: ❌. Mostly I just don't want to deal with the heavy Java syntax for system shell scripting. (Though TBF it's not much worse than C#.) I also admit to being biased against the Java JVM due to its ownership by Oracle, even though good open-source alternatives exist.

### Rust, C++

Verdict: ❌. Who hurt you? (Ironically there is or used to be a pretty cool but commercial C++ shell scripting system. I think it was/is Windows-only. But not in this running.)

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