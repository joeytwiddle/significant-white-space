# SWS - Significant Whitespace
==============================

SWS is a preprocessor for traditional curly-brace languages (C, Java, HaXe, Javascript) which can perform transformation of source-code files to and from meaningful-indentation style (as seen in Coffescript and Python).

In well-indented code the `{` and `}` block markers are effectively redundant.  SWS allows you to code without them, using indentation alone to indicate blocks, and adds the curly braces in for you later.

SWS can also strip and inject `;` semicolons, and comes with a few more minor features.

As a simple example, SWS can turn code of the following form (in this case decurled HaXe code):

```js
    static function curl(infile, outfile) =>

        while readNextLine()

            if indent_of_nextNonEmptyLine > currentIndent
                writeLine(currentLine + " {")
            else
                writeLine(currentLine)

            if indent_of_nextNonEmptyLine < currentIndent
                writeLine("}")

```

into the more traditional style that HaXe requires for compilation:

```js
    static function curl(infile, outfile) {

        while (readNextLine()) {

            if (indent_of_nextNonEmptyLine > currentIndent) {
                writeLine(currentLine + " {");
            } else {
                writeLine(currentLine);
            }

            if (indent_of_nextNonEmptyLine < currentIndent) {
                writeLine("}");
            }

        }

    }
```

And SWS can also convert the code back again!

Options can be tweaked to rename or remove that `=>` symbol, generate Java or C-style curlies, retain brackets around `if` conditionals rather than remove them, and enable conversion of inline functions to Coffeescript's `->` form.  Python lovers may place `:`s at block starts if they wish.

Please be aware of the caveats below.  SWS only works on a (nice clean) subset of the target language.  It was written in a quick-and-dirty fashion to work on 99% of valid code, with heuristics and warnings to mitigate the edge-cases.  This allows us to employ SWS on a wide variety of languages, without having to use a number of different lexers for language-specific String and Regexp literals.

SWS is *not* a professional tool; it may or may not perform to your requirements.  Some of the options perform simple text-transformation, and can get confused.  For example, if you run SWS with support for `/* ... */` comment blocks enabled, then you also run the risk of incorrectly matching `/*` or `*/` occurrences inside String or regexp literals in your program!  Perhaps with the minimum options enabled, SWS is safe and deterministic.  Documenting for this may come in future.

SWS is written in HaXe.  Currently we build an executable binary via Neko, but you may be able to export the tool to Java or Javascript.



------------------------------
# Usage

Available commands are:

    sws decurl <curly_file> <sws_file>

    sws curl <sws_file> <curly_file>

    sws safe-decurl <curly_file> <sws_file>

    sws safe-curl <sws_file> <curly_file>

    sws sync [ <directory/filename> ]

## Common examples

    % sws decurl myapp.c myapp.c.sws

will strip curlies and semicolons from myapp.c and write file myapp.c.sws

    % sws curl myapp.c.sws myapp.c

will read file myapp.c.sws, inject curlies and semicolons, and overwrite myapp.c

## Safe modes

    % sws safe-decurl myapp.c myapp.c.sws

    % sws safe-curl myapp.c.sws myapp.c

Curl and decurl are minimal; they do their job and exit.  However the safe-curl and safe-decurl operations do some extra checking: they invert the generated file and compare the result to the original file, emitting a warning if they do not match.  This is useful to discover any formatting style in your code that SWS does not consider canonical (the sws standard).

## Sync

    % sws sync src/

The sync command can be used to transform a tree of files automatically.  De-curled files will be written with the `.sws` extension appended (e.g. `MyClass.java.sws`).  The user may then edit either the curly file or the sws file, and on its next run sync will update the other file in the pair.

A good place to use sync would be at the top of your build chain.

If no argument is provided, sws sync will search everything below the current folder.  If that does more than you hoped it would, you may want to delete all the files it generated: **/*.(sws|bak|inv)  (By default sync generates more files than it really needs to, to aid debugging and reverting.)

Sync searches the current folder and subfolders for all sws or sws-able files (by a default or provided extension list), and will sync up any new edits based on which file was modified most recently.  This allows the user to edit files in either format, without having to worry about the direction in which changes will be propagated!  Thus a single project can be edited both through its sws files, and through its traditional files, for example using an IDE such as Eclipse.



------------------------------
# Trying it out

Check out the project, and install dependencies:

    % aptitude install haxe neko
    % haxelib install hxcpp

Build sws and put it on your PATH:

    % ./build.sh
    % sudo ln -s $PWD/sws /usr/local/bin/

Clone your favourite curly code project (just to be safe):

    % cp -a ~/projects/MyApp ~/projects/MyAppSWS
    % cd ~/projects/MyAppSWS

Now let's de-curl your code to sws files:

    % sws sync src/

## Handling differences

On the first run, sync will likely throw up a warning that a resultant sws file did not invert back to the original source perfectly.  vimdiff the original and inverse files, checking for any differences.

- If the problems are cosmetic (unimportant), then just run sync again to process the next file.

- However if there are any non-cosmetic (problematic) differences, you need to fix them!  Edit the source file and try to fix it to make it SWS friendly; then *save it* before running `sws sync` again.  Repeat this until all the differences are fixed (or unimportant).  Now you should have a happy sws file which you can work on, instead of the original curly file.  Run sync without saving the file, so it will move on to the next file.

  (You don't *have* to fix post-decurl issues by editing the curly file; if it is nearly correct, you may choose to edit the sws file instead.  But beware when syncing that the sws file will overwrite your original curled file, so you will not be able to compare them!)

If a file inverts perfectly first time, or if you don't *save* the source file to indicate it needs re-syncing, then sync will move on to the next file.

Once all your files are in nice neat sws format, close all curly files, and start editing your projects through the sws files!  (If you want to edit the curly files in your favourite IDE, you can do that too - just be sure to run sync, to update the sws files when that's done.)



------------------------------
# Options

- `debugging: true`

  More output

- `javaStyleCurlies: true`

  Outputs ` {` at the end of lines.  Otherwise outputs C style, `{` on its own line.

- `addRemoveSemicolons: true`

  Those `;` chars at the ends of lines.  Who needs them?

- `unwrapParenthesesForCommands: [ "if", "while", "for", "catch", "switch" ]`

  Converts lines like `if abc` to and from `if (abc)`.  Notably *not currently working* for `else if abc`!

- `onlyWrapParensAtBlockStart: true`

  This prevents unwrapParenthesesForCommands from making a mess on lines like `if (abc) { doSmth(); }`.

- `useCoffeeFunctions: true`

  Converts anonymous `function (a,b) ...` (as seen in Haxe/Javascript) to and from `(a,b) -> ...` as seen in Coffeescript.  Does not affect named functions.

- `blockLeadSymbol: " =>"`

  After stripping all the curlies, some lines look a bit odd (e.g. function declaration lines).  This appends a special symbol to the end of such lines, to indicate that a code block is about to follow.

- `blockLeadSymbolIndicatedRE: ~/(\s|^)function\s+[a-zA-Z_$]/`

  When should we add a blockLeadSymbol?  This feature is likely to change in future into a blockLeadSymbolTable, for finer customisation.  Python lovers will be able to map `if` and `while` keywords to use the `:` symbol.

- `blockLeadSymbolContraIndicatedRE` and `blockLeadSymbolContraIndicatedRE2AnonymousFunctions` are heuristics, and should be moved out of the Options object.

- `newline: "\n"`

  Change this to `"\r\n"` if you want to output DOS-formatted files.

- `addRemoveCurlies: true`

  Not implemented.  Always happens!

- `trackSlashStarCommentBlocks: true`

  Currently enabled due to its prevalence in the body of existing code.  However for professional projects, it is recommended that you *disable* this feature, and do not use any `/*...*/` blocks, since this feature introduces rare bugs.

  It can potentially cause false-positives if it sees `/*` or `*/` within a string or regexp literal.  There are heuristics to avoid this in some situations, but not all.  One heuristic for example, aborts star-comment tracking for this line if it positively identifies a regexp, but of course this would cause problems if the line was followed by a `/*`!.  Another factor is that `/*`s can be mentioned in `//` comments, and should be ignored, making star-comment tracking dependent on the accuracy of `//` comment tracking, which may not itself be 100%.

  The difficulty with properly addressing this, is that we would need a parser/lexer for strings and regexps in all the various target languages.  This is beyond the scope of SWS, which aims to operate as a simple textual manipulator.

- `retainLineNumbers: true`

  Not yet implemented.  Does not remove `}` lines, just empties them, so line numbers correspond in both sws and curled file.

- `guessEndGaps: true`

  Cosmetic.  For curling.  When disabled, closing curlies `}` will come immediately after the indented block.  When enabled, `}`s will be spaced out if there are empty lines in the source file.

- `fixIndent: false`

  When de-curling, forces indentation to be re-calculated from `{`s and `}`s noticed.  Useful when reading a poorly-indented source file.  However, it may cause issues by stripping indentation from lazy non-curled one-line if bodies.

- `joinMixedIndentLinesToLast: true`

  If broken lines are indented by an indent less than the standard file-wide indent, we can detect this and bypass semi-colon insert (and the need for `\` to negate it).  This currently only works on space indents following a tab-indented line/file, but in future it should work on e.g. 2-spaces in a 4-indented file.  For example:

   --->public static final protected synchronized highoctave veryLongFunctionName(String
   --->      argument1, String argument2, String argument3) {

- `doNotCurlMultiLineParentheses: false`

  An old attempt at solving multi-line expressions.  Tracks `(` and `)` count, and prevents semicolon injection *and curling* while inside one.  Unfortunately this sacrifices passing of anonymous inline functions (their indentation does not create curlies), so is not recommended.



------------------------------
# Status

Still a little immature.

Working reasonably for a neat subset of HaXe, Java and C code.

Options are not yet exposed as command-line arguments, but can be changed by editing Root.hx.

Sws is a little ropey, but that was implicit in the original specification.  :)



------------------------------
# Recent Changes

- sws sync
- Better handling of else / catch blocks.
- Better spacing heuristics when closing curlies.
- Filthy regexps to find trailing comments without matching comment-like text in string literals.
- Better handling of trailing comments, by splitting and rejoining line.

- Rudimentary tracking of `/* ... */` blocks and `( ... )` blocks.  Multi-line comments should now cause fewer issues.
- Multi-line expressions are now possible, but must be wrapped inside `( ... )` (otherwise they are likely to suffer semicolon injection or indent-based curlies).
- You can now enable `useCoffeeFunctions`, to convert between *anonymous* JS/Haxe functions `function(a,b) { ... }` and Coffeescript style functions `(a,b) -> ...` in the sws file.  When declaring a single-line function in JS, curlies must be retained in the sws, e.g. `(x) ->{ return 2*x; }` whilst Haxe does not need these.
- Added optional `blockLeadSymbol` which when set to `:` outputs sws files which look rather like Python.  Personally I would prefer something like `=>` but *only* on function declarations, perhaps `:` on classes, and nothing on if, while, for, try and other in-code indents.
- Added `unwrapParenthesesForCommands`, which can remove the `(...)` parentheses around `if` and `while` conditions, and reintroduce them on curling.  (You can set the list of keywords you want this to work on, or just empty it.  (Personally I find the visual effect of `(...)` symbols useful if I have no syntax highlighting for the given language, but redundant if branch statements already stand out by colour.)

- Multi-line expressions are now possible, by appending `\` in sws files to suppress semicolon injection for that line.

## New multi-line support

Recently added somewhat gnarly multi-line support; although if later lines are indented they *must* be space-indented from a tab-indented baseline.

    --->var result = a > 200 \
    --->          || b > 300 \
    --->          || c > 500

The `\` markers are needed to prevent `;` semicolons from being injected when curling, but a trailing `,` can also prevent this.  Later-line indentation with Tabs will cause curly wrapping (fine if you're creating an object literal).  Later-line indentation with spaces (in a Tab-indenetd file) does not cause curly wrapping, so use this to break up expressions, or for a multi-line array literal:

    // An object literal
    --->var obj = (
    --->--->foo: 3,
    --->--->bar: 7 \
    --->)

    // An array literal
    --->var list = [
    --->  3,
    --->  7 \
    --->]

Basically multi-line expressions were never intended to be supported by sws, but since so much existing curly source code uses them, it's good to have a way to preserve them, even if it's not pretty.  We have to wrap that object literal in `(...)` if we want to get a semicolon on the last line.

Multi-line expressions which introduce an anonymous function should work, provided only one level of indentation is used:

    fs.readFile(options.input, function(err, contents)
        if (err)
            log(err)
        else
            input = contents
    )

The head of the function may not appear on its own line.  (You can try using `\` to lead into it, but you will probably want to indent it, and receive unwanted curlies from that.)



------------------------------
# TODO

- Parse options from command-line.

- Allow options to be set near top/bottom of file (like vim's modeline).

- Code and comment cleanup.

- Serious outstanding: multi-line *indented* expressions (e.g. assignments of a long formula) get curlies when they shouldn't.  Use heuristic: non-curled one-line if or else (or while or do ...) bodies are ok, but anything else indented that is not curled should produce Error, or receive marking (trailing `\` ok?) to explain that it is special.  (OK added error report for that at least.)

- Track line numbers (retainLineNumbers).

- There are other things which should warn but just silently plough ahead and produce a file which will not invert properly!  E.g. we consume a curly but there is no indentation to follow, and fixIndent is not enabled.  These are mostly during the decurling phase however, which was never really the priority - users are supposed to supply a "perfect" file.  :)

- Provide ready executables (Javascript/Node, Java jar, and neko binaries) for people too scared/lazy to install Haxe.

- FIXED: `(...)` wrapping fails on "else if" but works on "if"

- FIXED: Problem detecting false indent from files starting with a multi-line comment (e.g. well-documented Java files).  Ideal solution: Solve this alongside other issues, by doing our best to track when we are inside a multi-line comment.  (The plan was to do that in HelpfulReader, and for it to expose the state (in/out of a comment) of the parser after the current line has been read (at the beginning of the next line).)

- DONE: Get HelpfulReader to track whether we are inside or outside a multi-line comment.  (Consider how to deal with multiple mini comment blocks on one line, as well as the open-endedness of the state of each end of a line.  Our simple line-by-line approach would have been fine if it wasn't for those pesky `/*` ... `*/` blocks, users who like to split long lines, and `\"` chars inside `"`...`"` strings.)

- Argument parsing to select options from commandline calls.

- PARTLY: Refactor to tidy the code up into neat classes, and expose the tool for use in file-free environments.

- Clear documentation, detection and warning of problematic code configurations.  Easy to read definition of what is legal code structure, and list of the gotchas (common issues we cannot fix).

  The best form for this might be to list all the options.  When disabled, SWS should do nothing to the code, simply clone it.  As each option is listed, we can explain its features and any the problems that it may cause.

- If some problems we decide do not want to attempt to solve, because we do not want to increase complexity that far (e.g. situations where we really should parse string, char and regexp literals, comment blocks, etc.), then we should instead provide a covering set of tests/regexps that can look for potentially problematic situations and warn the user "I am not sure if this is bad or not, perhaps you could re-jigger it for me so I can regain confidence"; then a little escaping or reformatting (or option/warning toggling) may eliminate the issue.  This would be far preferable to ploughing onward as if the problems do not exist and can never occur, then producing some unrelated error (e.g. from a later compiler) when they do.

- An annoying issue (seen often in Javascript) with decurling: we end up stripping info from lines which need to end in `};` .  We can either: instead of removing `};` replace it with some marker (easy, ugly), or force wrapping of the expression in `(...)` (hard, need to track where it started!).  If we can achieve the second, then instead we may as well just check if before the expr there was an assignment operator `= += -= *= /=` ... and use that to decide to output a `;` after the close curly.

- DONE: We could try to avoid appending semicolons to *trailing* comment lines (currently undetected).  (Just need a regexp that ensures `//` did not appear inside a String.  Could that ever appear in a regexp literal?  A pretty naff one if so.  But if our sws comment symbol was ever changed to e.g. `#` then certainly we would need to check we are not in a regexp as well as not in a String.  Some languages even have a meaningful `$#`, but we could demand a gap before the `#` to address that.)

- DONE: But this still leaves us with the problem that trailing comment lines will not get semicolon injection or stripping of semicolons or curlies.  To address this, we should "remove" trailing comments when considering application of said features.

- DONE: Introduce endline `\` chars in the sws to represent lines which do not end in semicolons.

- Fix blockLeadSymbol for C-style blocks.

- Before attacking the next refactor, set up test script that can run against a large set of sources, and warn us when number of problems increases!

- Some refactoring: Central loop of curl could split comment early, saving a lot of repetition eblow, and avoiding introduction of ; on initial /* line.  Also split up more of the curl code into separate functions.

- Optional forceIndent for decurling.  This would discard incoming indentation, and replace it with its own indentation based on curly counts.

## On the radar

- DONE in `unwrapParenthesesForCommands`: We could implement stripping and re-injection of the parenthesis ( and ) surrounding the conditional when we detect certain keywords (if, while).  This will probably only be applied to single-line expressions.

- The header line of a block (e.g. class and function declarations) are stripped of all symbols, and this looks a bit odd.  In Python indented blocks are always preceeded by a `:`, and in Coffeescript either a `:` or an `=` (not true of classes).  We could give users the option of initialising blocks with a `:`.  Although one might still argue that such symbols are as redundant as curly braces, given significant indenting whitespace!  (Started work on this, see `blockLeadSymbol`.)

- The double-indent problem could be addressed by *expecting* multi-line `(...)` to cause an indent.

- We could allow multi-line expression in sws source with a \ at the end of the line, which could be stripped for languages that won't accept it.  But this would leave the problem of when to introduce \s on the decurling to sws.

- Our options are: either *ban* multi-line expressions or write a proper lexer to find `{...}` nodes below `(...)`s.

- We have not thought about other forms of multi-line expression, such as array literals.

- Some people might want a different blockLeadSymbol depending on the hint in the opening line, e.g. `=` for a class, `=>` for a function, `::` for a static function, `:` for a typedef struct (note this last is two tokens!).  To offer that kind of customisation, we could expose an editable map from hint to symbol.

- Are there any relevant curly languages which use different comment symbols?  If so we should make that switch easy to access.

## Over the horizon

- Decide how to gap closing curlies based on gap found at opening, for symmetry.



------------------------------
# How it works

## Decurling

When de-curling, curlies are stripped when a line ends with `{` or begins with `}`.  Currently no checking is performed to ensure that indentation is correct; that is your duty before de-curling!  (TODO: implement checking.)

## Curling

Indented code blocks are detected and wrapped in curlies.

The indent chars for detection are determined from the _first_ indented line found in the file.  So if later indents do not match the detected indent (e.g. spaces in a Tab-indented file, or 2 spaces in a 4-space-indented file), that indentation will be ignored for curlies, and preserved in the output.  For example:

    while (weHaveAFourSpaceIndentedFile)                            # indent 0
        if (ourLineIsTooLong() && weNeedToMakeItWrap() &&   \       # indent 1
          weCanUseATwoSpaceIndent() && thatWillBeIgnored())         # indent 1
            thisShouldStillGetTheCurliesItNeeds()                   # indent 2

However that example will have problems if semicolon injection is enabled (one will be added after the `\`).

Semicolon injection appends a `;` to any non-empty line that is not the start of an indent block.  Therefore it will also inject incorrectly after single-line blocks as seen here:

    if (condition) { action(); };

Blank lines containing only indentation/whitespace are ignored and preserved, so they do not affect curly wrapping.

Comment lines should not be stripped or injected into, or used for indentation.  This policy is followed for simple single-line comments, but not for trailing comments at the end of a line, and _not in the body of multi-line comments_.  (By the way, we also have some filthy heuristics to differentiate `*/` ending a comment from `*/` ending a regular expression literal.)



------------------------------
# Caveats

SWS uses a simple text-processing algorithm to transform files; it does not properly lex/parse or understand your code.  Because of this, it will probably only work on a _subset_ of the language you are using.  In other words, you may need to restrict your code-style a little, to something that SWS can handle.  Notable examples are:

- `{`s are only detected at the *end* of lines.  `}`s are only detected at the *beginning* of lines.  It is fine to use them mid-line, provided they match.  So, the following examples work, and curlies will be *retained* in the "de-curled" file.

    callFunc({width:300,height:200})

    var opts = {width:300, height:200}

  But instances like this may cause trouble:

    var opts = \
      { width: 300, height: 200 };

- Breaking a line up over multiple lines may introduce unwanted curlies if the later lines are indented, and will also suffer from semicolon-insertion.  (You can get away with indenting 2 spaces in an otherwise 4-spaced file, but then face issues with semicolon-injection.)  Unindented multi-line expressions should work fine if semicolonInsertion is disabled.

- SWS does not parse the code in a strict manner.  It uses a simple line-based approach for curling, with some extras tacked on.  Specifically, most of the time it does not track when it is inside or outside a String or Regexp literal, and as a result can get confused with regard to multi-line comments.  For example, the following was a problem before we introduced heuristics for it:

```
    log("It looks like /* I am starting a multi-line comment, but I'm not!")
```

  Common problem cases (some of which can be found in the SWS source code) are identified by heuristic regexps, and warnings are emitted if SWS is unsure how to correctly handle them.  However, heuristics only push the horizon; they usually fail to cover all cases.  In future we hope to present a clear description of the coding style and options neccessary to stay safe.  (For example, we might end up recommending that users at NASA never use `/* ... */` blocks, always put `//` comments on their own line, and set the options to take advantage of these simplified conditions and warn if they are breached.)

- Indentation of the original code must be correct for transformation to sws.  (E.g. this can be thrown up if you comment out the top and bottom lines of an if statement.)  A fix for this could be to parse `{` and `}`s and force correct indentation in the output.

- Indentation of single-line comments is meaningful.  If you have `//`s which look like outdent, curlies will be generated!  This may change in future, but at the moment it is considered a feature, allowing us to indicate empty blocks in the code (we need *something* to indent, or curlies cannot be generated).

- Multi-line block comments `/* ... */` are somewhat supported, but single-line entries in the middle of a line can cause trouble (e.g. on the line introducing an indented/curled code block).  (Reason: splitLineAtComment returns two Strings, left and right.  If we want to stick with single-line algorithm, we need to change that return to [start_state, code/comment, comment/code, code/comment, ..., comment/code, end_state])

- You can still express short `{ ... }` blocks on-one-line if you want to, but don't mix things up.  Specifically do not follow a curly by text and then newline and indent.  That mid-line curly will not be stripped, whilst the indent will cause a new one to be injected.

- FIXED: Semicolon injection's inability to detect multi-line comments and trailing comments can cause them to appear unwantedly.  (SWS's algorithm basically works one line at a time, with a lookahead for the indent of the next non-empty line.)  You can either stick with a strict single-line comment style, or try to stop caring about odd semicolons appearing in comments!

- Since indentation is required to create curlies `{` `}`, if you attempt to create a class or function (or any block) with an empty body, you had better add an indented dummy line too (e.g. a comment) or you won't get curlies (and with SCI you will get a semicolon).

- In Javascript, object and function definitions sometimes end with `};`.  When semicolon removal/injection is enabled, both these tokens will be stripped when decurling to sws, and the semicolon will *not* be re-introduced on curling.  However the semicolon can be retained by wrapping the definition in brackets, leaving a third symbol on the last line: `} );`

- OLD `doNotCurlMultiLineParentheses` You must choose between allowing multi-line expressions (provided they are wrapped in `(`...`)`) or allowing the definition of new indented blocks within `(`...`)` expressions.  For languages where you often declare anonymous functions or implementations and pass them immediately, you probably want the latter.  The option is currently called doNotCurlMultiLineParentheses.  Perhaps we can track a stack of what nested blocks we are in (e.g. `"{{{(({"`), although since we have no `{`s in sws files, `{` must be always implied by indentation, but at least we can avoid semicolon injection in flat or only-partially-indented multi-line expressions.  However this is not an easy task, we would need to correctly parse strings and *regexps* to discard non-structural `{ } ( )` symbols.

- For the moment you will not have much joy with `#ifdef` preprocessor macros.  They will suffer from semicolon and experience curly insertion just like normal code if their bodies are indented. 

- I have not thought about how one would declare a typedef struct.  That should work fine, although the final outer text will get pushed onto its own line after the closing `}`.

Let's also critique the sync algorithm:

- After syncing a pair of files we would like to set the modification time of the target file to match that of the source file, to indicate against syncing again on future runs.  Unfortunately Neko does not offer a way to set the stats of files directly.  Until we introduce C-specific code for this, as an alternative we "touch" the *source* file by cloning and replacing it.  That is only likely to match up the mtimes exactly on small/medium source files, and not on filesystems with fine-grained time-stamps.  (Although if the mtimes don't match, our approach will only cause the same transformation to be performed again on the next sync - not the end of the world.)  Another minor disadvantage of touching the source file is that your editor may think it has been updated when it hasn't.

- On filesystems with coarse-grained time-stamps, sync may not notice changes made to a source file very soon after it was synced (within 1 second).  This is rare, but could happen e.g. if a developer edits and saves a file while sync is running in the background.

Restrictions on code structure:

  - Curly-files should be well indented before decurling.  Support was added to read one-line well-indented if bodies without curlies; they will be given curlies on curling.

  - Indentation must be perfect as every indent/outdent will create `{...}` curlies.  (In a tab-indented file, extra space indents will be ignored.)

  - Empty blocks require an indented // comment line to mark the body, or no curlies will be generated.

  - ... This list is incomplete!  TODO




------------------------------
# Bugs

    - sync fails with exception `std@sys_file_type` if it encounters any broken symlinks in the scanned tree.
    - sws in general fails with with "Invalid field access : __s" if we forgot to pass an argument.
    - There are plenty more, but I don't want to spoil *all* your fun.



------------------------------
# Vim users

Vim users who want syntax highlighting and tags to work like normal when they are editing sws files, can inform vim of the correct filetype by adding to their .vimrc:

```vim
    au BufRead,BufNewFile {*.hx.sws}             set ft=haxe
    au BufRead,BufNewFile {*.java.sws}           set ft=java
    au BufRead,BufNewFile {*.c.sws}              set ft=c
    au BufRead,BufNewFile {*.cpp.sws}            set ft=cpp
```

Some strict syntax files may complain about missing semicolons and curlies, whilst others will be flexible enough to work fine.

We can also run sws automatically whenever we save .sws file:

```vim
    " Simple but messy: writes errors over your screen!
    autocmd BufWritePost,FileWritePost *.sws silent !sws curl "%" "%:r" >/dev/null

    " Better: output shown tidily, and also saved in quickfix list.
    set makeprg=sws
    autocmd BufWritePost,FileWritePost *.sws :make curl "%" "%:r"

    " Alternative: create and use a constant build script:
    set makeprg=bash\ ./build.sh
    autocmd BufWritePost,FileWritePost *.sws :make
```

When you have both curled and decurled files open, I recommend doing this on the file you are generating (not the one you are editing):

```vim
    :setlocal nomodifiable autoread
```

Some commands that can help when wrapping long lines:

```vim
    :set wrap
    :let &showbreak='    \\ '
    :set nolist linebreak
    :set list
    :set nowrap
```

Since Vim's breakindent patch no longer works, I wrote something similar:

- http://hwi.ath.cx/code/home/.vim/plugin/breakindent_beta.vim



------------------------------
# Debate

- "I like curly braces!"

   Don't use sws.  But also, try not to fear it.  sws sync allows you to edit *either* format, so you can collaborate with crazies without leaving your bubble.  (Having said that, sws does place some restrictions on the style of code in traditional format.)

- "Why do you hate curlies?"

   I haven't really made up my mind on this yet, I'm just trying to keep my options open.

- "Are there any advantages to coding without curlies?"

   - If you aren't using an IDE, then it can save a little time and work for your fingers.

   - The structure of your code is exhibited purely visually.  There is no need for the user to parse the symbols; they cannot be misled by incorrect indentation.

   - Arguably without the chaff, other symbols such as `(`...`)` stand out more clearly, making method calls more visible and bringing you closer to your code.

   - Refactoring code with copy-paste can be easier if you only have to worry about the code and the indentation, not the code, the indentation *and* the curlies.

   - Without the lonely closing curlies, which occupy a whole line each, you can fit more code on the screen!

   - We save a little disk-space.

- "Why were curlies ever introduced in the first place?"

   - Meaningful indentation is actually quite difficult for traditional compilers to parse.  They can build syntax trees far more easily by parsing `{` and `}` tokens.  Thus using these symbols is a good idea if you want to keep your parser and compiler simple.
  
   We certainly do not recommend an overhaul of traditional parsers.  As with Coffeescript, we are simply providing a preprocessor which introduces these tokens for the parser to consume.  This keeps two different problems separate, in the great tradition of unix, and allows us to operate with a broad family of languages.

   - Some people find curlies make it easier to see the structure of the code they are reading.  That's fine, for them.

- "What have you got against semicolons?"

   What have you got against newlines?

- "Why are some of the comments in the SWS source code longer than 80 chars?"

   Significant whitespace crusaders believe that newlines are meaningful.  A newline should not mean "people only had screens this wide in the 1980s".  A newline should mean the end of one thing, and the start of another.  If long lines look horrible in your editor, that is a problem with your editor.



------------------------------
# Musings

## When do we have enough heuristics?

Heuristics add complexity to SWS whilst extending it to work over a larger area of the target languages (or at least provide useful warnings).  Unfortunately they cannot cover the whole domain unless they reach the complexity of a proper parser.  So when do we stop?  I think the answer to that might be, when it works on *enough* of my code that I don't mind fixing the odd exception.  I feel I've reached pretty close to that now.

## Rewrite / refactor

Is there a better way to do this?  The core loop started off very simple, and worked "ok" like that.  But as we added options to deal with more cases, the complexity of that loops has grown immensely.

We could approach this project from the point of view of addressing concerns.  (Some of our options represent a single concern, but not all are there.)

We might be able to build the reformatter out of a chain of minor reformatters.  Addressing a concern would mean placing a reformatter or two at appropriate places in the chain.  Whilst this abstraction might help us to deal with each concern separately, there may be times when one concern needs to know about another, in order to decide how to proceed.  (E.g. joinMixedIndentLinesToLast can negate the need to append a `\`.)  Perhaps I must make an attempt at writing in this style, before I can see it's major flaws/benefits.

If you care to input to this discussion, we are talking about the major functions `curl()` and `decurl()`.  Is there a better way to present that code, by splitting it up?  Or it is it good to keep the whole algorithm in once place, minor options and all, so we can clearly see what is happening?

It could be said that the two classes `HelpfulReader` and `CommentTrackingReader` address some concerns is a nice separated fashion, although these are purely information concerns, not reformatting concerns.  I really meant to put `indentString` detection into a helper class too, but didn't get around to it.

Perhaps that is a better approach, to separate out extraction of information about the input, from decisions about the output.  Then our core loop would have no code to seek data, it would just accept all the processed information (a bunch of bools/Strings/getters), and decide what to do with it.

