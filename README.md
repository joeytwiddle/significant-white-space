SWS is a preprocessor for source code files which performs transformation to and from meaningful-indentation style.

# Current Usage

PLEASE NOTE that sws arguments are subject to change in future.  But are the moment, they are:

    sws decurl <source_filename>

    sws curl <source_filename>

For example:

    % sws decurl myapp.c

will create file myapp.c.sws

    % sws curl myapp.c

will read file myapp.c.sws and overwrite myapp.c


