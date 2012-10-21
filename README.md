SWS - Significant Whitespace
============================

SWS is a preprocessor for source code files (e.g. C or Java) which can perform transformation to and from meaningful-indentation style (as seen in Coffescript and Python).

In correctly indentated code the { and } block markers are effectively redundant.  SWS allows you to code without them, using indentation only, and adds the { and } markers in for you later.



# Status

Almost reached first milestone.  In other words, not quite working properly.



# Current Usage

PLEASE NOTE that sws arguments are subject to change in future.  But are the moment, they are:

    sws decurl <source_filename>

    sws curl <source_filename>

For example:

    % sws decurl myapp.c

will create file myapp.c.sws

    % sws curl myapp.c

will read file myapp.c.sws and overwrite myapp.c



# Future Usage

My planned use-case is that:

    % sws

will search the current folder and subfolders for all sws or sws-able files (by a default extension list), and will sync up any new edits based on which file was accessed most recently.  This will enable the user to edit files in either format, without having to worry about the direction in which changes will be propogated!



# Caveats

SWS uses a simple text-processing algorithm to transform files; it does not properly lex/parse or understand your code.  Because of this, it will probably only work on a subset of the language you are using.  In other words, you may need to restrict your code-style a little, to something that SWS can handle.  Notable examples are:

  - Breaking a line up over two lines may cause trouble if the second line is indented.  (However, indenting with 2 spaces in an otherwise 4-spaced file you can get away-with.)

  - Remember: all indented code blocks will be given curlies later!

  - You can still express short { ... } blocks on one line if you want to, but don't mix things up.  Specifically, don't open a curly, continue for a while, then newline and indent.

  - I have not thought about how one would declare a typedef struct.  I suppose that might work fine.



