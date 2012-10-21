SWS is a preprocessor for source code files which performs transformation to and from meaningful-indentation style.

# Current Usage

PLEASE NOTE that sws arguments are subject to change in future.  But are the moment, they are:

    sws [ decurl | curl ] <source_filename>

For example:

    % sws decurl src/myapp.c

will create file src/myapp.c.sws

    % sws curl src/myapp.c

will read file src/myapp.c.sws and overwrite src/myapp.c


