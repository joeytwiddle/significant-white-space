# SWS - Significant Whitespace
------------------------------

SWS is a preprocessor for traditional curly-brace languages (C, Java, Javascript, Haxe) which can perform transformation of source-code files to and from meaningful-indentation style (as seen in Coffescript and Python).

In well-indented code the `{` and `}` block markers are effectively redundant.  SWS allows you to code without them, using indentation alone to indicate blocks, and adds the curly braces in for you later.

SWS is also able to strip and inject `;` semicolons.

As a simple example, SWS can turn code like this:

```js
    while (readNextLine())

        if (indent_of_nextNonEmptyLine > currentIndent)
            writeLine(currentLine + " {")
        else
            writeLine(currentLine)

        if (indent_of_nextNonEmptyLine < currentIndent)
            writeLine("}")

```

into the more traditional style:

```js
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
```

Please be aware of the caveats below.  SWS only works on a (nice clean) subset of the target language.

SWS is written in Haxe.  Currently we build an executable binary via Neko, but you may be able to export the tool to Java or Javascript.



# Usage
------------------------------

Available commands are:

    sws decurl <curly_file> <sws_file>

    sws curl <sws_file> <curly_file>

    sws sync [ <directory/filename> ]

## Examples

    % sws decurl myapp.c myapp.c.sws

will strip curlies and semicolons from myapp.c and write file myapp.c.sws

    % sws curl myapp.c.sws myapp.c

will read file myapp.c.sws, inject curlies and semicolons, and overwrite myapp.c

    % sws sync src/

The sync command can be used to transform a tree of files automatically.  De-curled files will be written with the `.sws` extension appended (e.g. `MyClass.java.sws`).  The user may then edit either the curly file or the sws file, and on its next run sync will update the other file in the pair.

A good place to use sync would be at the top of your build chain.

If no argument is provided, sws sync will search everything below the current folder.  If that does more than you hoped it would, you may want to delete all the files it generated: **/*.(sws|bak|inv)  (By default sync generates more files than it really needs to, to aid debugging and reverting.)

Sync searches the current folder and subfolders for all sws or sws-able files (by a default or provided extension list), and will sync up any new edits based on which file was modified most recently.  This allows the user to edit files in either format, without having to worry about the direction in which changes will be propagated!  Thus a single project can be edited both through its sws files, and through its traditional files, for example using an IDE such as Eclipse.



# Status
------------------------------

Now able to transform its own source leaving only 2 minor differences.

Significant problem detecting indentation of files which start with multi-line comments.

Options are not yet exposed as command-line arguments, but can be changed by editing Root.hx.



# Recent Changes
------------------------------

- sws sync
- Better handling of else / catch blocks.
- Better spacing heuristics when closing curlies.
- Filthy regexps to find trailing comments without matching comment-like text in string literals.
- Better handling of trailing comments, by splitting and rejoining line.



# TODO
------------------------------

- Problem detecting false indent from files starting with a multi-line comment (e.g. well-documented Java files).  Ideal solution: Solve this alongside other issues, by doing our best to track when we are inside a multi-line comment.  (The plan was to do that in HelpfulReader, and for it to expose the state (in/out of a comment) of the parser after the current line has been read (at the beginning of the next line).)

- Get HelpfulReader to track whether we are inside or outside a multi-line comment.  (Consider how to deal with multiple mini comment blocks on one line, as well as the open-endedness of the state of each end of a line.  Our simple line-by-line approach would have been fine if it wasn't for those pesky `/*` ... `*/` blocks, users who like to split long lines, and `\"` chars inside `"`...`"` strings.)

- Argument parsing to select options from commandline calls.

- Refactor to tidy the code up into neat classes, and expose the tool for use in file-free environments.

- Clear documentation, detection and warning of problematic code configurations.  Easy to read definition of what is legal code structure, and list of the gotchas (common issues we cannot fix).

- If some problems we decide do not want to attempt to solve, because we do not want to increase complexity that far (e.g. situations where we really should parse string, char and regexp literals, comment blocks, etc.), then we should instead provide a covering set of tests/regexps that can look for potentially problematic situations and warn the user "I am not sure if this is bad or not, perhaps you could re-jigger it for me so I can regain confidence"; then a little escaping or reformatting (or option/warning toggling) may eliminate the issue.  This would be far preferable to ploughing onward as if the problems do not exist and can never occur, then producing some unrelated error (e.g. from a later compiler) when they do.

- DONE: We could try to avoid appending semicolons to *trailing* comment lines (currently undetected).  (Just need a regexp that ensures `//` did not appear inside a String.  Could that ever appear in a regexp literal?  A pretty naff one if so.  But if our sws comment symbol was ever changed to e.g. `#` then certainly we would need to check we are not in a regexp as well as not in a String.  Some languages even have a meaningful `$#`, but we could demand a gap before the `#` to address that.)

- DONE: But this still leaves us with the problem that trailing comment lines will not get semicolon injection or stripping of semicolons or curlies.  To address this, we should "remove" trailing comments when considering application of said features.

## On the radar

- We could implement stripping and re-injection of the parenthesis ( and ) surrounding the conditional when we detect certain keywords (if, while).  This will probably only be applied to single-line expressions.

- The header line of a block (e.g. class and function declarations) are stripped of all symbols, and this looks a bit odd.  In Python indented blocks are always preceeded by a `:`, and in Coffeescript either a `:` or an `=` (not true of classes).  We could give users the option of initialising blocks with a `:`.  Although one might still argue that such symbols are as redundant as curly braces, given significant indenting whitespace!



# How it works
------------------------------

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



# Caveats
------------------------------

SWS uses a simple text-processing algorithm to transform files; it does not properly lex/parse or understand your code.  Because of this, it will probably only work on a _subset_ of the language you are using.  In other words, you may need to restrict your code-style a little, to something that SWS can handle.  Notable examples are:

  - Breaking a line up over multiple lines may introduce unwanted curlies if the later lines are indented.  (You can get away with indenting 2 spaces in an otherwise 4-spaced file, but may face issues with semicolon-injection.)

  - You can still express short `{ ... }` blocks on-one-line if you want to, but don't mix things up.  Specifically do not follow a curly by text and then newline and indent.  That mid-line curly will not be stripped, whilst the indent will cause a new one to be injected.

  - Semicolon injection's inability to detect multi-line comments and trailing comments can cause them to appear unwantedly.  (SWS's algorithm basically works one line at a time, with a lookahead for the indent of the next non-empty line.)  You can either stick with a strict single-line comment style, or try to stop caring about odd semicolons appearing in comments!

  - Indentation of the original code must be correct for transformation to sws.  (E.g. this can be thrown up if you comment out the top and bottom lines of an if statement.)  A fix for this could be to parse `{` and `}`s and force correct indentation in the output.

  - Since indentation is required to create curlies `{` `}`, if you attempt to create a class or function (or any block) with an empty body, you had better add an indented dummy line too (e.g. a comment) or you won't get curlies (and with SCI you will get a semicolon).

  - I have not thought about how one would declare a typedef struct.  I suppose that might work fine.

Let's also critique the sync algorithm:

  - After syncing a pair of files we would like to set the modification time of the target file to match that of the source file, to indicate against syncing again on future runs.  Unfortunately Neko does not offer a way to set the stats of files directly.  Until we introduce C-specific code for this, as an alternative we "touch" the *source* file by cloning and replacing it.  That is only likely to match up the mtimes exactly on small/medium source files, and not on filesystems with fine-grained time-stamps.  (Although if the mtimes don't match, our approach will only cause the same transformation to be performed again on the next sync - not the end of the world.)  Another minor disadvantage of touching the source file is that your editor may think it has been updated when it hasn't.

  - On filesystems with coarse-grained time-stamps, sync may not notice changes made to a source file very soon after it was synced (within 1 second).  This is rare, but could happen e.g. if a developer edits his file while sync is running in the background.



# Bugs:
------------------------------

  - sync fails with exception `std@sys_file_type` if it encounters any broken symlinks in the scanned tree.



# Vim users
------------------------------

Vim users who want syntax highlighting and tags to work like normal when they are editing sws files, can inform vim of the correct filetype by adding to their .vimrc:

```vim
    au BufRead,BufNewFile {*.hx.sws}             set ft=haxe
    au BufRead,BufNewFile {*.java.sws}           set ft=java
    au BufRead,BufNewFile {*.c.sws}              set ft=c
    au BufRead,BufNewFile {*.cpp.sws}            set ft=cpp
```

Some strict syntax files may complain about missing semicolons and curlies, whilst others will be flexible enough to work fine.

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


# Debate:
------------------------------

- "I like curly braces!"

  - Don't use sws.  And also don't fear it.  sws sync allows you to edit *either* format, so you can collaborate with crazies without leaving your bubble.  (Having said that, sws does place some restrictions on the style of code in traditional format.)

- "Why do you hate curlies?"

  - I haven't really made up my mind on this yet, I'm just trying to keep my options open.

- "Are there any advantages to coding without curlies?"

  - If you aren't using an IDE, then it can save a little time and work for your fingers.

  - The structure of your code is exhibited purely visually.  There is no need for the user to parse the symbols; they cannot be misled by incorrect indentation.

  - Arguably without the chaff, other symbols such as `(`...`)` stand out more clearly, making method calls more visible and bringing you closer to your code.

  - Refactoring code with copy-paste can be easier if you only have to worry about the code and the indentation, not the code, the indentation *and* the curlies.

  - Without the lonely closing curlies, which occupy a whole line each, you can fit more code on the screen!

  - We save a little disk-space.

- "Why were curlies ever introduced in the first place?"

  - Meaningful indentation is actually quite difficult for traditional compilers to parse.  They can build syntax trees far more easily by parsing `{` and `}` tokens.  Thus using these symbols is a good idea if you want to keep your parser and compiler simple.
  
  - We certainly do not recommend an overhaul of traditional parsers.  As with Coffeescript, we are simply providing a preprocessor which introduces these tokens for the parser to consume.  This keeps two different problems separate, in the great tradition of unix, and allows us to embrace a wide body of languages.

  - Some people find curlies make it easier to see the structure of the code they are reading.  That's fine, for them.

- "What have you got against semicolons?"

  - What have you got against newlines?

- "Why are some of the comments in the SWS source code longer than 80 chars?"

  - Significant whitespace crusaders believe that newlines are meaningful.  A newline should not mean "people only had screens this wide in the 1980s".  A newline should mean the end of one thing, and the start of another.  If long lines look horrible in your editor, that is a problem with your editor.

