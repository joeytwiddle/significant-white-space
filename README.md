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

SWS is written in Haxe.  You might be able to export it to Java; so far I am building a binary via the CPP target.



# Status

Reached the second milestone.  SWS can now successfully decurl and recurl itself into working source!

Options are not yet parsed from command-line arguments, but can be changed by editing Root.hx.



# TODO

- Elegant handling of else / catch blocks.

- sws sync

- Argument parsing to set options from commandline

- Clear documentation, detection and warning of problematic code configurations.  (This will be a list of WONT_FIX examples.)



# Usage

So far we have implemented:

    sws decurl <normal_source_infile> <sws_source_outfile>

    sws curl <sws_source_infile> <normal_source_outfile>

For example:

    % sws decurl myapp.c myapp.c.sws

will strip curlies and semicolons from myapp.c and write file myapp.c.sws

    % sws curl myapp.c.sws myapp.c

will read file myapp.c.sws, inject curlies and semicolons, and overwrite myapp.c



# Future Usage

My planned use case is to have this at the top of my build chain:

    % sws sync

Sync will search the current folder and subfolders for all sws or sws-able files (by a default or provided extension list), and will sync up any new edits based on which file was modified most recently.  This will enable the user to edit files in either format, without having to worry about the direction in which changes will be propogated!  This way a single project can be edited both through its sws files, and through an IDE like Eclipse requiring traditional syntax.

## On the radar

We may implement stripping and re-injection of parenthesis ( and ) surrounding the conditional when we detect certain keywords (if, while).  This may not be applied to multi-line expressions.



# How it works

Indented code blocks are detected and wrapped in curlies.

The indent chars for detection are determined from the _first_ indented line found in the file.  So if later indents do not match the detected indent (e.g. spaces in a Tab-indented file, or 2 spaces in a 4-space-indented file), that indentation will be ignored for curlies, and preserved in the output.  For example:

    while (weHaveAFourSpaceIndentedFile)                            # indent 0
        if (ourLineIsTooLong() && weNeedToMakeItWrap() &&   \       # indent 1
          weCanUseATwoSpaceIndent() && thatWillBeIgnored())         # indent 1
            thisShouldStillGetTheCurliesItNeeds()                   # indent 2

However that example will have problems with semicolon injection after the '\'.

Semicolon injection appends a ';' to any non-empty line that is not part of an indent block.  Therefore it will also inject incorrectly into single-line blocks such as:

    if (condition) { action(); };

Blank lines containing only indentation/whitespace are ignored and preserved, so they do not affect curly wrapping.

Comment lines are not stripped or injected into, or used for indentation, where possible.  This works for many comment styles, but not in the body of multi-line comments.  (We also have some filthy heuristics to differentiate '*/' ending a comment from '*/' ending a regular expression literal.)



# Caveats

SWS uses a simple text-processing algorithm to transform files; it does not properly lex/parse or understand your code.  Because of this, it will probably only work on a _subset_ of the language you are using.  In other words, you may need to restrict your code-style a little, to something that SWS can handle.  Notable examples are:

  - Breaking a line up over multiple lines may introduce unwanted curlies if the later lines are indented.  (However, indenting with 2 spaces in an otherwise 4-spaced file you can get away-with.)

  - You can still express short { ... } blocks on-one-line if you want to, but don't mix things up.  Specifically, don't open a curly, continue for a while, then newline and indent.  That curly will not be stripped, whilst the indent will cause a new one to be injected.

  - Semicolon injection over multi-line comments is likely to get confused.  (SWS's algorithm basically works one line at a time, with a lookahead for the indent of the next non-empty line.)

  - I have not thought about how one would declare a typedef struct.  I suppose that might work fine.



# Vim users

Vim users who want syntax highlighting and tags to work like normal when they are editing sws files, can inform vim of the correct filetype by adding to their .vimrc:


    au BufRead,BufNewFile {*.hx.sws}             set ft=haxe
    au BufRead,BufNewFile {*.java.sws}           set ft=java
    au BufRead,BufNewFile {*.c.sws}              set ft=c
    au BufRead,BufNewFile {*.cpp.sws}            set ft=cpp

Some strict syntax files may complain about missing semicolons and curlies, whilst others will be flexible enough to work fine.


