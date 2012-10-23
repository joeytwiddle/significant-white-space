# SWS - Significant Whitespace
----------------------------

SWS is a preprocessor for traditional curly-brace languages (C, Java, Javascript, Haxe) which can perform transformation of source-code files to and from meaningful-indentation style (as seen in Coffescript and Python).

In well-indented code the { and } block markers are effectively redundant.  SWS allows you to code without them, using indentation alone to indicate blocks, and adds the { and } markers in for you later.

SWS is also able to strip / inject semicolons, under favourable conditions.  Please be aware of the caveats below.  There are some situations which SWS cannot solve, so it only really works on a (nice clean) subset of parseable languages.

As a simple example, SWS can turn code like this:

    if (indent_of_nextNonEmptyLine > currentIndent)
        output.writeString(currentLine + " {" + newline)

into the more traditional style:

    if (indent_of_nextNonEmptyLine > currentIndent) {
        output.writeString(currentLine + " {" + newline);
    }

SWS is written in Haxe.  Currently we build a binary via cpp, but you may be able to export the tool to Java or Javascript.



# Usage

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

The sync command can be used to transform a tree of files automatically.  De-curled files will be written with the ".sws" extension appended (e.g. "MyClass.java.sws").  The user may then edit either the curly file or the sws file, and on its next run sync will update the other file in the pair.

A good place to use sync would be at the top of your build chain.

Sync searches the current folder and subfolders for all sws or sws-able files (by a default or provided extension list), and will sync up any new edits based on which file was modified most recently.  This allows the user to edit files in either format, without having to worry about the direction in which changes will be propagated!  Thus a single project can be edited both through its sws files, and through its traditional files, for example using an IDE such as Eclipse.



# Status

Reached the third milestone: a working sync!

Options are not yet parsed from command-line arguments, but can be changed by editing Root.hx.



# Recent Changes

- sws sync
- Better handling of else / catch blocks.



# TODO

- Argument parsing to set options from commandline

- Clear documentation, detection and warning of problematic code configurations.  (This will be a list of WONT_FIX examples.)

- On the radar: We could implement stripping and re-injection of parenthesis ( and ) surrounding the conditional when we detect certain keywords (if, while).  This will probably only be applied to single-line expressions.



# How it works

## Decurling

When de-curling, curlies are stripped when a line ends with "{" or begins with "}".  Currently no checking is performed to ensure that indentation is correct; that is your duty before de-curling!  (TODO: implement checking.)

## Curling

Indented code blocks are detected and wrapped in curlies.

The indent chars for detection are determined from the _first_ indented line found in the file.  So if later indents do not match the detected indent (e.g. spaces in a Tab-indented file, or 2 spaces in a 4-space-indented file), that indentation will be ignored for curlies, and preserved in the output.  For example:

    while (weHaveAFourSpaceIndentedFile)                            # indent 0
        if (ourLineIsTooLong() && weNeedToMakeItWrap() &&   \       # indent 1
          weCanUseATwoSpaceIndent() && thatWillBeIgnored())         # indent 1
            thisShouldStillGetTheCurliesItNeeds()                   # indent 2

However that example will have problems if semicolon injection is enabled (one will be added after the '\').

Semicolon injection appends a ';' to any non-empty line that is not the start of an indent block.  Therefore it will also inject incorrectly after single-line blocks as seen here:

    if (condition) { action(); };

Blank lines containing only indentation/whitespace are ignored and preserved, so they do not affect curly wrapping.

Comment lines should not be stripped or injected into, or used for indentation.  This policy is followed for simple single-line comments, but not for comments appended to lines, and _not in the body of multi-line comments_.  (By the way, we also have some filthy heuristics to differentiate '*/' ending a comment from '*/' ending a regular expression literal.)



# Caveats

SWS uses a simple text-processing algorithm to transform files; it does not properly lex/parse or understand your code.  Because of this, it will probably only work on a _subset_ of the language you are using.  In other words, you may need to restrict your code-style a little, to something that SWS can handle.  Notable examples are:

  - Breaking a line up over multiple lines may introduce unwanted curlies if the later lines are indented.  (You can get away with indenting 2 spaces in an otherwise 4-spaced file, but may face issues with semicolon-injection.)

  - You can still express short { ... } blocks on-one-line if you want to, but don't mix things up.  Specifically do not follow a curly by text and then newline and indent.  That mid-line curly will not be stripped, whilst the indent will cause a new one to be injected.

  - Semicolon injection's inability to detect multi-line comments and appended comments can cause them to appear unwantedly.  (SWS's algorithm basically works one line at a time, with a lookahead for the indent of the next non-empty line.)  You can either stick with a strict single-line comment style, or try to stop caring about odd semicolons appearing in comments!

  - I have not thought about how one would declare a typedef struct.  I suppose that might work fine.



# Vim users

Vim users who want syntax highlighting and tags to work like normal when they are editing sws files, can inform vim of the correct filetype by adding to their .vimrc:

    au BufRead,BufNewFile {*.hx.sws}             set ft=haxe
    au BufRead,BufNewFile {*.java.sws}           set ft=java
    au BufRead,BufNewFile {*.c.sws}              set ft=c
    au BufRead,BufNewFile {*.cpp.sws}            set ft=cpp

Some strict syntax files may complain about missing semicolons and curlies, whilst others will be flexible enough to work fine.

