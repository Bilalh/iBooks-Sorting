IBooks Sorting {#readmeTitle}
==============
Allows sorting iBooks collections by any fields, as well as moving books about easily.
{#description}

Usage
-----

	usage: books_sortby [global options] command [command options]

	Global Options:
	    --help        - Show this message
	    -r, --reverse - Reverse ordering

	Commands:
	    author      - Sort by Author (sort author)
	    help        - Shows list of commands or help for one command
	    list        - List all collections with their ids
	    move        - Moves all books from one collection to an another
	    real_author - Sort by Author (actual author)
	    series      - Sort by Series
	    sort_title  - Sort by Sort Title
	    title       - Sort by Title

Prerequisites
-------------
* ruby 1.9 (should would with ruby 1.8 if you change the `#!/usr/bin/env ruby19` to `#!/usr/bin/env ruby`)
* gli gem
* iBooks


Install 
-------
* Put the scripts in your `$PATH`


Issues
------
None Yet

Licence
-------
[Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License](http://creativecommons.org/licenses/by-nc-sa/3.0/ "Full details")

Authors
-------
* Bilal Syed Hussain