package org.neuralyte.sws;

import neko.io.File;
import neko.io.FileInput;
import neko.io.FileOutput;
import neko.FileSystem;
import neko.Sys;

using Lambda;

// Does it matter if we indent this line?  Yes!  Indent once and we get a curly block starting from the Lambda line; indent twice and the indent level is detected as two tabs!

/*
	FIXED!
	If the comment line above is not indented, then the indent of this line is critical.
	Both these problems are worth addressing, to avoid issues with comments in the wild.
	They are only problematic for curling, not decurling.
	We need to get HelpfulReader tracking whether or not we are inside a comment block.
	And we should then ignore comments for indentation?
	(That would invalidate our advice to use a comment to force curling of empty blocks.)
	(Perhaps we should ignore multi-line comments for indentation, but still recognise one-line comments.)
*/

// TODO: Uses of .insideComment may not deal well with cases of mixed comment/code lines.

// TODO: Track input file line numbers, and use these when printing warnings.

// TODO: We could suppress warnings for JS regexps if we know we're working in Haxe or Java.

// TODO: We are still stripping ;s from commented lines with extra trailing comments (see blockLeadSymbol)

// TODO: using blockLeadSymbol only for functions, we may as well adapt useCoffeeFunctions to handle anonymous and not anonymous

// TODO: Complete refactoring into file-free tool.

// TODO: Warn when decurling expects un () wrapping but does not get it, e.g.:
//   if (name.equals(v.name)) return true;

// TODO: Upgrade some warnings to errors; if we are confident it has caused / will cause a problem.

// Recommend config file do like HaXe and MPlayer, just put cmdline args there, and parse them the same way.


class Root {

	static function main() {

		var args = neko.Sys.args();

		var options = Options.defaultOptions;
		var syncOptions = new SyncOptions();

		var sws = new SWS(options);
		var sync = new Sync(options,syncOptions);

		try {

			if (args[0] == "--help") {

				showHelp();

			} else if (args[0] == "curl") {

				sws.curl(args[1], args[2]);

			} else if (args[0] == "decurl") {

				sws.decurl(args[1], args[2]);

			} else if (args[0] == "safe-curl") {

				sync.safeCurl(args[1], args[2]);

			} else if (args[0] == "safe-decurl") {

				sync.safeDecurl(args[1], args[2]);

			} else if (args[0] == "sync") {

				if (args[1] != null) {
					sync.doSync(args[1]);
				} else {
					sync.doSync(".");
				}

			} else {

				showHelp();
			}

		} catch (ex : Dynamic) {
			echo("Caught exception: "+ex);
			// echo(haxe.Stack.toString(haxe.Stack.callStack()))
			echo(haxe.Stack.toString(haxe.Stack.exceptionStack()));
			// TODO: Where do they keep the damn stacktrace?!  ex is just a string
			return 5; // TODO: This is not being set as the exit code ... we must use neko.Sys?
		}

		return 0;
	}

	static function showHelp() {
		echo("sws curl <filename> <outname>");
		echo("sws decurl <filename> <outname>");
		echo("sws sync [<folder/filename>]");
	}

	static function echo(s:String) {
		File.stdout().writeString("[Root] " + s + "\n");

	}

}

class Options {

	// public static var defaultOptions : Options = cast { debugging: true, javaStyleCurlies: true, addRemoveSemicolons: true, doNotCurlMultiLineParentheses: false, useCoffeeFunctions: true, unwrapParenthesesForCommands: [ "if", "while", "for", "catch", "switch" ], blockLeadSymbol: " =>", blockLeadSymbolIndicatedRE: ~/(\s|^)function\s+[a-zA-Z_$]/, blockLeadSymbolContraIndicatedRE: ~/^\s*(if|else|while|for|try|catch|finally|switch|class)($|[^A-Za-z0-9_$@])/, blockLeadSymbolContraIndicatedRE2AnonymousFunctions: ~/(^|[^A-Za-z0-9_$@])function\s*[(]/, newline: "\n", addRemoveCurlies: true, trackSlashStarCommentBlocks: true, retainLineNumbers: true }

	// The (...)s are required here to get the needed trailing ;
	// The cast is the only way I found in Haxe so far.  It's fine I guess?
	public static var defaultOptions : Options = cast ( {
		debugging: true,
		javaStyleCurlies: true,
		addRemoveSemicolons: true,
		doNotCurlMultiLineParentheses: false,
		useCoffeeFunctions: true,
		unwrapParenthesesForCommands: [ "if", "while", "for", "catch", "switch" ],
		// , "elseif"
		blockLeadSymbol: " =>", blockLeadSymbolIndicatedRE: ~/(\s|^)function\s+[a-zA-Z_$]/,
		blockLeadSymbolContraIndicatedRE: ~/^\s*(if|else|while|for|try|catch|finally|switch|class)($|[^A-Za-z0-9_$@])/,
		blockLeadSymbolContraIndicatedRE2AnonymousFunctions: ~/(^|[^A-Za-z0-9_$@])function\s*[(]/,
		newline: "\n",
		addRemoveCurlies: true,
		trackSlashStarCommentBlocks: true,
		retainLineNumbers: true,
		onlyWrapParensAtBlockStart: true,
		joinMixedIndentLinesToLast: true
	});

	// Recently: Decurl adds trailing ' \' when semicolon was expected but not found.
	//           Curl removes trailing ' \' and does not add semicolon when encountered.
	//
	// GONE: This has pushed a problem with the commented line looksLikeRegexpLineWithEndComment back up to the surface.  I think before those ambiguous lines (splitLineAtComment) were getting semicolons stripped and reinjected?  New ' \' may be avoiding stripping a bit more heavily.  Perhaps it too should check ambiguity?

	public var debugging : Bool;

	// Options {{{

	public var javaStyleCurlies : Bool;

	public var addRemoveSemicolons : Bool;

	// doNotCurlMultiLineParentheses:
	//   true - You can write multi-line expressions with (...).
	//          But you will not be able to create curly indented blocks within them.
	//          The contents of (...) will remain unchanged.  Doesn't that mean we *can* put curlies inside, but they won't be de/re-curled?
	//   false - Multi-line expressions will be subject to curling and SCI, with or without (...)
	//           new {...} blocks should work fine provided they are in the middle of an otherwise unbroken line.  (They do require at least one trailing that is not '}' or ';'.)
	public var doNotCurlMultiLineParentheses : Bool;

	// Rename: useCoffeeFunctionSymbolForAnonymousFunctions?  Maybe not.
	public var useCoffeeFunctions : Bool;

	// NOTE: Current implementation will *not* unbrace or re-brace if(...) - because we peek the first symbol, a space is required: if (...)
	public var unwrapParenthesesForCommands : Array<String>;

	//// blockLeadSymbol is an entirely optional symbol used to indicate the start of certain blocks.  This works much like Python's ":" symbol, but with SWS we want fine-grained control over when they are used.
	// static var blockLeadSymbol = null;
	// static var blockLeadSymbol = ":";         // Like Python
	// static var blockLeadSymbol = " :";        // But : looks rather odd in Haxe, where function lines may already end in ": Type"
	// static var blockLeadSymbol = " =";        // Quite passable, although not as true as when CS defines functions this way.
	// static var blockLeadSymbol = " {";        // hehe this actually works without error; of course no matching } is introduced
	// public var blockLeadSymbol = " =>"          // I like this for HaXe
	public var blockLeadSymbol : String;
	// TODO: keywordsHintSymbols : Map<String,String>

	//// s/Indicated/Wanted/g ?

	// static var blockLeadSymbolContraIndicatedRE = null;
	// Catches non-anonymous function declarations in HaXe (e.g. declaring a method within a class).  Anonymous functions differ in that they are handled by useCoffeeFunctions.
	// The start ensures a word.  The end requires at least one name char, to distinguish "function (e) {" from "function myFunc(e)"
	// TODO: What about Java?
	// TODO: There is no indicator for Java ... no keyword!
	public var blockLeadSymbolIndicatedRE : EReg;
	// static var blockLeadSymbolIndicatedRE = ~/(\s|^)(if|while|.*)/;   // Not sure when Python users want their ":"s

	// Use this blockLeadSymbolContraIndicatedRE if you only want blockLeadSymbol on function declarations (i.e. none of the things mentioned here).
	// TODO: To suppress warnings, contra-indicate anonymous functions.
	// These would be neater in a list, checked against the first word on the line.
	public var blockLeadSymbolContraIndicatedRE : EReg;
	public var blockLeadSymbolContraIndicatedRE2AnonymousFunctions : EReg;
	// static var blockLeadSymbolContraIndicatedRE = null;   // Not sure when Python users want their ":"s
	// TODO: DRY.  useCoffeeFunctions already detects anonymous functions, and therefore can contra-indicate them without the need for a repeat regexp.
	// TODO: Java does not have anonymous functions, but we should check that inline interface implementations are working ok.

	// static var newline : String = "\r\n";
	public var newline : String;

	// If we always wrap parens for an "if..." line, we cannot accept single-line if statements.
	// If we only wrap when we are starting an indented block, we can't have single-line parensWrapping, e.g.: throwError "message" -> to throwError("message")   - I don't think we ever really need that!  No languages have syntax that looks like functions!
	public var onlyWrapParensAtBlockStart : Bool;

	// }}}

	// TODO:
	public var addRemoveCurlies : Bool;
	public var trackSlashStarCommentBlocks : Bool;   // can be disabled if they will never be used, saving concerns about slash-stars appearing hidden in strings or regexps.
	public var retainLineNumbers : Bool;             // does not squash up empty lines on decurl (on curl we should drop/replace an empty line when closing curls)
	public var joinMixedIndentLinesToLast : Bool;    // My Eclipse formatting settings add spaces after the tab indentation when breaking a long line.  This might not be an uncommon semantic approach used elsewhere, so worth including.

	public function new() {
		//
	}

}

class SyncOptions {

	public var validExtensions : Array<String>;

	public var skipFoldersNamed : Array<String>;

	public var safeSyncMakeBackups : Bool;
	public var safeSyncCheckInverse : Bool;

	public var breakOnFirstFailedInverse : Bool;

	public var pathSeparator : String;

	public function new() {
		validExtensions = [ "java", "c", "C", "cpp", "c++", "h", "hx", "uc", "js" ];   // "jpp"
		skipFoldersNamed = [ "CVS", ".git" ];
		safeSyncMakeBackups  = true;
		safeSyncCheckInverse = true;
		breakOnFirstFailedInverse = true;
		pathSeparator = "/";

	}

}

class Reporter {

	// Try not to use echo!  info is preferred.
	public function echo(s : String) {
		File.stdout().writeString(s + "\n");
	}

	public function debug(s : String) {
		echo("[Debug] "+s);
	}

	public function info(s : String) {
		echo("[Info] "+s);
	}

	public function warn(s : String) {
		echo("[Warning] "+s);
	}

	public function error(s : String) {
		echo("[Error] "+s);

	}

}

class OptionalReporter extends Reporter {

	var options : Options;

	public function new(_options) {
		options = _options;
	}

	public override function echo(s : String) {
		// trace(s);
		File.stdout().writeString(s + options.newline);
	}

	public override function debug(s : String) {
		if (options.debugging) {
			echo("[Debug] "+s);
		}

	}

}

class Outputter {

	var output : FileOutput;      // (for now)
	var options : Options;

	public function new(_output,_options) {
		output = _output;
		options = _options;
	}

	public function writeLine(str) {
		output.writeString(str + options.newline);
	}

	public function close() {
		output.close();

	}

}

class SWS {

	public var options : Options;

	public var reporter : Reporter;

	public function new(?_options) {
		// options = new Options()
		options = _options!=null ? _options : Options.defaultOptions;
		reporter = new OptionalReporter(options);

	}


	// Sync options:

	static var continuationKeywords = [ "else", "catch" ];


	// Constants:

	public static var emptyOrBlank : EReg = ~/^\s*$/;
	static var indentRE : EReg = ~/^\s*/;
	static var wholeLineIsCommentRE : EReg = ~/(^\s*\/\/|^\s*\/\*|\*\/\s*$)/;
	// Warning: Do not be tempted to search for "  //" mid-line.  Yes that could indicate an appended comment, but it could just as easily be part of a string on a line which requires semicolon injection!

	// Sorry I really could not resist the temptation.
	//// This regexp throws an exception via nekotools: "An error occured while running pcre_exec"
	// static var evenNumberOfQuotes = '([^"]*"[^"]*"[^"]*|[^"]*)*';
	//// This ensures an even number of " chars, but not an even number of ' chars.  Since one may contain the other, we really can't do this without a proper parser.
	static var evenNumberOfQuotes = '(([^"]*"[^"]*"[^"]*)*|[^"]*)';
	// static var evenNumberOfApostrophes = (~/"/g).replace(evenNumberOfQuotes,"'");
	//// This is an attempt to catch an even number of both, but for some reason it works on "s but not 's.
	//// Even if it did work on 's, it still doesn't work on escaped \" within a "..." string, or the equivalent for 's.
	// static var evenNumberOfQuotes = '(('+"[^'\"]*'[^']*'[^'\"]*"+'|[^"\']*"[^"]*"[^"\']*'+')*|[^"]*)';
	// static var forExample = "This \" will break";   // if we follow it with a comment
	// DONE: We should also check the //s are outside of an even number of 's
	static var evenNumberOfQuotesDislikeSlashes = '(([^"/]*"[^"]*"[^"/]*)*|[^"/]*|[^"/]*/)';
	static var evenNumberOfApostrophesDislikeSlashes = (~/"/g).replace(evenNumberOfQuotesDislikeSlashes,"'");
	static var trailingCommentOutsideQuotes = new EReg("^("+evenNumberOfQuotesDislikeSlashes+")(\\s*(//|/[*]).*)$",'');
	static var trailingCommentOutsideApostrophes = new EReg("^("+evenNumberOfApostrophesDislikeSlashes+")(\\s*(//|/[*]).*)$",'');
	// Unfortunately this regexp is greedy and eats all the spaces in the first () leaving none in the last ().  This problem is addressed by splitLineAtComment.
	// TODO: If // is a trailing comment then we should probably assume that /* is too.  Looking at this line right here, we can see we really want to match the first occurrence!
	// In the general case, a line might contain any number of /*...*/ blocks, and then a // at the end, and maybe even a leading */ or trailing /*!  Can we handle that?  ^^
	// This version is unsafe:
	// static var trailingCommentOutsideQuotes = new EReg("^(.*)(\\s*//.*)$",'');
	// NOTE: trailingCommentOutsideQuotes may need more checks if "//" can appear outside a string literal, e.g. inside a regexp literal.

	//// Uncomment these to cause trouble!
	// static var indentREJSTEST = "    = /^\\s*/";
	// static var startsWithCurlyReplacer : EReg = ~/}\s*/;   // We don't want to strip the indent
	//// Older problems which we have fixed:
	// static var testStringTryingToCauseTrouble = "blah // ";

	//// Almost certainly a regexp literal (JS or Haxe) which ends in */ which is not a comment ending!
	// public static var looksLikeRegexpLineWithEndComment : EReg = ~/=[ \t]*~?\/[^*\/].*\*\/;?\s*$/
	//// Almost certainly a regexp literal assignment, not in a comment
	public static var looksLikeRegexpLine : EReg = ~/^[^\/]*=\s*~?\/[^*\/].*\/;?\s*$/;
	//// Might be a regexp literal, not neccessarily assigned; uncertain.
	public static var seemsToContainRegexp : EReg = ~/~?\/[^*\/].*\//;
	// If you want to cause trouble, swap \/ and * like this: ~/~?\/[^\/*].*\//;  The line will fill with semicolons!
	// public static var couldbeRegexpEndingSlashSlash : EReg = ~/~?\/[^*\/].*\/\//;
	// We allow slash inside quotes.  We fail to check for an even number of 's, or mask /s inside them!
	static var evenNumberOfQuotesWithNoSlashes = '(([^"/]*"[^"]*"[^"/]*)*|[^"/]*)';
	public static var couldbeRegexpEndingSlashSlash : EReg = new EReg("^"+evenNumberOfQuotesWithNoSlashes+"~?\\/[^*/].*\\/\\/",'');
	// That catches Haxe EReg literal declared with = ~/...*/, or Javascript RegExp literal declared with = /...*/ whilst ignoring comment lines declared with //.  It does not notice regexps declares without assignment, e.g. passed immediately.

	// The first char matched is to ensure function starts at a word boundary, i.e. not res = my_favourite_function(a,b,c);
	public static var anonymousFunctionRE = ~/([^a-zA-Z0-9])function\s*([(][a-zA-Z0-9@$_, 	]*[)])/g;
	public static var anonymousFunctionReplace = "$1$2 ->";

	public static var anonymousCoffeeFunctionRE = ~/([(][a-zA-Z0-9@$_, 	]*[)])\s*->/g;
	public static var anonymousCoffeeFunctionReplace = "function$1";

	public function decurl(infile : String, outfile : String) {

		// TODO: Count number of in/out curlies swallowed, and compare them against indent.  Warn when they do not look right!

		// We detect lines which end with an opening curly brace
		var endsWithCurly : EReg = ~/\s*{\s*$/;
		// And lines which start with a closing curly brace
		var startsWithCurly : EReg = ~/^\s*}\s*/;
		// We don't want to strip the indent
		var startsWithCurlyReplacer : EReg = ~/}\s*/;
		// And sometimes lines ending in a semicolon.
		var endsWithSemicolon : EReg = ~/\s*;\s*$/;

		// var input : FileInput = File.read(infile,false);
		var reader = new CommentTrackingReader(infile,this);

		var output : FileOutput = File.write(outfile,false);

		var out = new Outputter(output,options);

		try {

			while (true) {

				var wasInsideComment = reader.insideComment;

				var wholeLine : String = reader.getNextLine();
				if (wholeLine == null) {   // Unlike input, our reader does not throw Eof.
					break;
				}

				var res = splitLineAtComment(wholeLine);
				var line = res[0];
				var trailingComment = res[1];

				// reporter.debug("Read line: "+line);

				// We don't want to strip anything from comment lines
				var wholeLineIsComment = wholeLineIsCommentRE.match(line);
				// DISABLED: splitLineAtComment can deal with this now
				// var wholeLineIsComment = false
				// if true    // TODO BUG: Put the commented if line below the live one, and it will interfere with curling!
				if (!wholeLineIsComment && !wasInsideComment) {

					if (startsWithCurly.match(line)) {
						line = startsWithCurlyReplacer.replace(line,"");
						if (emptyOrBlank.match(line + trailingComment)) {
							continue;
						}
					}

					if (endsWithCurly.match(line)) {
						line = endsWithCurly.replace(line,"");
						if (options.blockLeadSymbol != null) {
							var indicated = options.blockLeadSymbolIndicatedRE!=null && options.blockLeadSymbolIndicatedRE.match(line);
							var contraIndicated = options.blockLeadSymbolContraIndicatedRE!=null && options.blockLeadSymbolContraIndicatedRE.match(line);
							if (options.blockLeadSymbolContraIndicatedRE2AnonymousFunctions.match(line)) {
								contraIndicated = true;
							}
							// if (line.indexOf("function") == -1) {
							if (!indicated && !contraIndicated) {
								reporter.debug("blockLeadSymbol neither indicated or contra-indicated for: "+line);
							}
							if (indicated) {
								line += options.blockLeadSymbol;
							}
							// This may look rather odd if the "{" was on a line on its own, now the ":" will be too.  To avoid it, we would have to recall the last newline we emitted, so we can append to the previous line.  Although if javaStyleCurlies is set, this may clean itself up after two runs.
						}
						if (emptyOrBlank.match(line + trailingComment)) {
							continue;
						}

					} else {

						if (!wholeLineIsComment && !reader.insideComment && !emptyOrBlank.match(line)) {
							if (options.addRemoveSemicolons) {
								if (endsWithSemicolon.match(line)) {
									line = endsWithSemicolon.replace(line,"");
								} else {
									// We only addRemoveSemicolons if the line does not start or end in a curl.
									// However, some languages allow single-line if result without curls.
									// If that is well indented, we do not need to remove ';' or more importantly add '\'
									var nextNonEmptyLine = reader.getNextNonEmptyLine();
									Heuristics.leadingIndentRE.match(line);
									var indent_of_currentLine = Heuristics.leadingIndentRE.matched(0).length;
									Heuristics.leadingIndentRE.match(nextNonEmptyLine);
									var indent_of_nextNonEmptyLine = Heuristics.leadingIndentRE.matched(0).length;
									//// TODO: We should not demand tabs-spaces here.  We should check for any extra indent after matching/stripping indentString, e.g. to pick up 2 space indent in a 4 spaced file.
									//// But we don't have indentString.  HelpfulReader could find and hold it.
									// var indent_of_currentLine = countIndent(indentString, currentLine)
									if (indent_of_nextNonEmptyLine > indent_of_currentLine) {
										if (options.joinMixedIndentLinesToLast && ~/^\t+ +/.match(nextNonEmptyLine)) {
											line += " \\";     // TODO: Clean up sws: We don't *have* to join them with \ on decurl.  We *could* look for mixed indent on curling, and handle it there.  But this fits logically with the other places we use '\'.
										} else {
											// We are about to indent; do not be concerned about missing ;
											reporter.debug("About to indent despite no curlies, hopefully a one-line if: "+line);
											// reporter.debug("indent_of_nextNonEmptyLine="+indent_of_nextNonEmptyLine+" nextNonEmptyLine="+nextNonEmptyLine)
										}
									} else {
										// Lines ending ',' do not need trailing \ marker
										if (!Heuristics.endsWithComma.match(line)) {
											line += " \\";
										}
									}
								}
							}
						}
					}

					if (options.useCoffeeFunctions) {
						if (anonymousFunctionRE.match(line)) {
							line = anonymousFunctionRE.replace(line,anonymousFunctionReplace);
						}
					}

					if (options.unwrapParenthesesForCommands != null) {
						var firstToken = getFirstWord(line);
						if (options.unwrapParenthesesForCommands.has(firstToken)) {
							var res = splitLineAtComment(line);
							var beforeComment = res[0];
							var afterComment = res[1];
							var replacementRE = new EReg(firstToken+"\\s*[(](.*)[)]\\s*$",'');
							// reporter.debug("Trying "+replacementRE+" on "+beforeComment);
							beforeComment = replacementRE.replace(beforeComment,firstToken+" $1");
							line = beforeComment + afterComment;
						}
					}

				}

				wholeLine = line + trailingComment;
				out.writeLine(wholeLine);

			}

		} catch (ex : haxe.io.Eof) {
			// reporter.debug("Reached the End Of the File.");
		}

		out.close();

	}

	public function curl(infile : String, outfile : String) {

		var currentLine : String;

		var helper = new CommentTrackingReader(infile,this);

		var output : FileOutput = File.write(outfile,false);

		var currentLine : String;

		var indentString : String = null;

		var currentIndent : Int = 0;

		var out = new Outputter(output,options);

		while (true) {

			var wasInsideComment = helper.insideComment;

			currentLine = helper.getNextLine();
			if (currentLine == null) {
				break;
			}

			var isInsideBrackets = helper.depthInsideParentheses > 0;

			// If we are inside a multi-line /* ... */ block or if ( ... ) block, then we do not want to do any indent-based curling or semicolon insertion.
			// BUG TODO: That is not strictly true, in many languages we can open blocks inside expressions, e.g. in JS function(){ ... }, or inline anonymous implementation of interface in Java and Haxe.  I'm sure you agree it will be pretty hard to detect that in decurled files.  This is something of a "show-stopper" for Javascript, where anonymous callback functions are often passed directly to function calls.  Therefore, probably for Javascript we should *reject* parentheses from affecting curling&SCI, pushing the problem back to multi-line expressions (indented or otherwise).
			// It may be worth nothing that we hadn't fully solved multi-line expressions anyway, specifically any *not* wrapped in brackets (...).
			// I feel so much better about this whole business having document doNotCurlMultiLineParentheses.  One feature or the other is a fair conclusion.
			if (wasInsideComment || (isInsideBrackets && options.doNotCurlMultiLineParentheses)) {
				// For the moment, just skip the entire line.
				out.writeLine(currentLine);
				continue;
			}

			// reporter.debug("currentLine = "+currentLine);

			// DONE: Do not seek curlies on comment lines, such as this trouble-maker here:
			// if (!emptyOrBlank.match(currentLine)) {

			if (!emptyOrBlank.match(currentLine)) {
				currentIndent = countIndent(indentString, currentLine);
			}
			 // otherwise we keep last indent

			var nextNonEmptyLine : String;
			nextNonEmptyLine = helper.getNextNonEmptyLine();
			// NOTE: nextNonEmptyLine may be null which means EOF which should be understood as indent 0.

			// We detect indent from the nextNonEmptyLine, rather than the currentLine, so we can get it sooner rather than later.
			// But we can detect indent wrong if the nextNonEmptyLine is inside a comment.
			// So currently we simply skip detection if our current line ends inside a comment.
			if (indentString == null && nextNonEmptyLine!=null && !helper.insideComment) {
				indentRE.match(nextNonEmptyLine);
				var indentPart = indentRE.matched(0);
				if (indentPart != "") {
					indentString = indentPart;
					reporter.debug("Found first indent, length "+indentString.length);
				}
			}

			var indent_of_nextNonEmptyLine = countIndent(indentString, nextNonEmptyLine);

			// reporter.debug("curr:" + currentIndent+"  next: "+indent_of_nextNonEmptyLine);

			// We want to avoid semicolon addition on comment lines
			// But we do want consider comment lines for indentation / bracing
			var wholeLineIsComment = wholeLineIsCommentRE.match(currentLine);
			if (wholeLineIsComment) {
				// Now a nasty fudge for lines ending */ because they are a Haxe EReg or Javascript RegExp literal, not a comment.
				var lineLikelyToBeRegexpDefinition = looksLikeRegexpLine.match(currentLine);
				if (lineLikelyToBeRegexpDefinition) {
					wholeLineIsComment = false;
					//// No need to warn, this regexp imbues confidence
					// reporter.warn("Looked like a comment, but could be a regexp: "+currentLine)
				}
			}
			// But it could be a regexp line with a trailing comment!
			/*
			if (!wholeLineIsComment) {
				var containsTrailingComment = trailingCommentOutsideQuotes.match(currentLine);
				if (containsTrailingComment) {
					// trace("Found trailing comment on: "+currentLine);
					// wholeLineIsComment = true;
				}
			}
			*/

			// wholeLineIsComment = false; // Let splitLineAtComment handle this concern.  This approach fails with current code below - it adds semicolons on lines containing only a comment, because semicolon injection checks the whole line for emptiness, not the split part of the line!  The split is only done inside appendToLine at the moment.  :f
			// This only affects semicolon injection, which is just where we need it.  :)

			// TODO: Should really be done after splitLineAtComment
			if (options.useCoffeeFunctions) {
				if (anonymousCoffeeFunctionRE.match(currentLine)) {
					currentLine = anonymousCoffeeFunctionRE.replace(currentLine,anonymousCoffeeFunctionReplace);
				}
			}

			if (!options.onlyWrapParensAtBlockStart) {
				currentLine = wrapParens(currentLine);
			}

			if (!helper.insideComment && indent_of_nextNonEmptyLine > currentIndent) {

				if (options.onlyWrapParensAtBlockStart) {
					currentLine = wrapParens(currentLine);
				}

				if (indent_of_nextNonEmptyLine > currentIndent+1) {
					reporter.error("Unexpected double indent on: "+nextNonEmptyLine);
				}

				// DONE: Should be done after splitLineAtComment and then we can check it should only appear at the end.
				if (options.blockLeadSymbol != null) {
					var res = splitLineAtComment(currentLine);
					var beforeComment = res[0];
					var afterComment = res[1];
					var i = beforeComment.lastIndexOf(options.blockLeadSymbol);
					if (i >= 0) {
						var beforeSymbol = beforeComment.substr(0,i);
						var afterSymbol = beforeComment.substr(i+options.blockLeadSymbol.length);
						// We only strip the symbol if it is the last thing on the (comment split) line.
						if (emptyOrBlank.match(afterSymbol)) {
							beforeComment = beforeSymbol + afterSymbol;
							currentLine = beforeComment + afterComment;
						}
					}
				}

				// Assumption: indent never increases by more than one
				// Append open curly to current line
				// Then write it
				if (options.javaStyleCurlies) {
					out.writeLine(appendToLine(currentLine," {"));
				} else {
					out.writeLine(currentLine);
					out.writeLine(repeatString(currentIndent,indentString) + "{");
				}
				currentIndent++;
				continue;

			}

			if (!helper.insideComment && indent_of_nextNonEmptyLine < currentIndent) {

				// Write current line
				// Write close curly (at lower indent)
				// In fact write as many as we need...

				// DONE: We need to check/apply addRemoveSemicolons rule to currentLine before we output it.
				// TODO: DRY - this is a clone of later code!
				// DONE: We should not act on comment lines!
				if (options.addRemoveSemicolons && !wholeLineIsComment && !emptyOrBlank.match(currentLine)) {
					if (Heuristics.endsWithComma.match(currentLine)) {
						// currentLine = currentLine
					} else {
						if (Heuristics.endsWithBackslash.match(currentLine)) {
							currentLine = Heuristics.endsWithBackslash.replace(currentLine,"");
						} else {
							currentLine = appendToLine(currentLine,";");
						}
					}
				}
				out.writeLine(currentLine);

				var delayLastCurly = null;
				// DONE: If the next non-empty line starts with the "else" or "catch" keyword, then:
				//   in Javastyle, we could join that line on after the }
				//   in either braces style, any blank lines between us and the next line can be outputted *before* the } we are about to write.
				// I am not quite sure how this should work on multiple outdents - for now only trying delayLastCurly on the last.  Yes that is right.
				// Other things which like to trail after closing } is the name following a "typedef struct { ... } Name;".  Since that name could be anything, we could look for just one word, but then that would misfire on other single words like "break" "continue" "debugger" and "i++"!
				// Now added ')' and ',' as tokens for joining too.
				if (nextNonEmptyLine != null) {
					// var tokens = Heuristics.leadingIndentRE.replace(nextNonEmptyLine,'').split(" ");   // TODO: should really split on whitespaceRE
					// var firstToken = tokens[0];
					var firstToken = getFirstWord(nextNonEmptyLine);
					if (continuationKeywords.has(firstToken)) {
						delayLastCurly = " ";
					}
					if (firstToken.charAt(0)==')' || firstToken.charAt(0)==',') {
						delayLastCurly = "";
						// TODO: Certainly in the ',' and maybe in the ')' case, we do not really want to add a space after the curly when we print it later.  However in the "else" and "catch" cases we must.
					}
				}
				// DONE: One other situation where we might want to join lines, is when the next symbol after the "}" is a ")".  (Consider restriction: Only if that ")" line has the same indent as our "}" line would?)

				var i = currentIndent - 1;   // We could actually just continue to use currentIndent instead of i.
				while (i >= indent_of_nextNonEmptyLine) {
					// reporter.debug("De-curlifying with i="+i);

					var indentAtThisLevel = repeatString(i,indentString);

					// DONE: Even if we don't detect a continuation keyword, if the next *two* lines are both blanks, then emit one of them before the curly.  This won't always be right, but it may be right more often than wrong.
					// This rule could be applied for every outdent, checking the next two lines again on each.

					if (delayLastCurly!=null && i == indent_of_nextNonEmptyLine) {

						// We are guaranteed a nextLine
						var nextLine = null;
						while (true) {
							nextLine = helper.getNextLine();
							if (emptyOrBlank.match(nextLine)) {
								out.writeLine(nextLine);
							} else {
								break;
							}
							// nextLine should be === nextNonEmptyLine now
						}

						// If the line we are joining to is an else or catch continuation, we may need to wrap parens.
						nextLine = wrapParens(nextLine);

						var updatedLine;
						if (options.javaStyleCurlies) {
							// Join the next line to the curly
							updatedLine = indentAtThisLevel + "}" + delayLastCurly + Heuristics.leadingIndentRE.replace(nextLine,"");
							// out.writeLine(updatedLine);
							// But now we want to consider this line for opening an indent :O
							// Feck!  Oh ... hmmm ... Managed that using pushBackLine.  :)
						} else {
							// Write the curly on its own line
							out.writeLine(indentAtThisLevel + "}");
							// Handle the next line normally
							updatedLine = nextLine;
						}
						helper.pushBackLine(updatedLine);
						break; // We were going to anyway tbh

					} else {

						// var nextLine = helper.peekLine(1);
						// var lineAfterThat = helper.peekLine(2);
						// if (nextLine!=null && emptyOrBlank.match(nextLine) && lineAfterThat!=null && emptyOrBlank.match(lineAfterThat)) {
						// Hmm but if I have two curlies to go out, I really want to check if 3 lines are empty!
						// I don't want to gap the first curly if I can't gap the second.  Well really we dunno what we want.  :P
						var spaceCurly = true;
						var indentsToGo = (i - indent_of_nextNonEmptyLine) + 1;   // +1 cos "to go" includes this one we are about to do
						var numEmptyLinesRequired = indentsToGo + 1;
						// DONE: This seems to do what I want.  Except in one exceptional circumstance.  If the next non-empty line will have delayLastCurly applied (e.g. because it starts with a continuationKeywords) then we need not be concerned about spacing that last curly, therefore we can require one less space for our earlier curlies to reach the spaceCurly condition!
						if (delayLastCurly != null) {
							numEmptyLinesRequired--;
						}
						for (j in 0...numEmptyLinesRequired) {
							var peekLine = helper.peekLine(j+1);
							if (peekLine == null) {
								// An exception.  EOF pretends to be 1 blank line.
								if (j < numEmptyLinesRequired - 1) {
									spaceCurly = false;
								}
								break;
							} else if (!emptyOrBlank.match(peekLine)) {
								spaceCurly = false;
								break;
							}
						}

						if (spaceCurly) {
							// Do not write the '}' just yet ...
							// Consume and write the blank line now, and the '}' right after.
							var nextLine = helper.getNextLine();
							out.writeLine(nextLine);
						}

						out.writeLine(indentAtThisLevel + "}");

					}

					i--;
				}

				currentIndent = indent_of_nextNonEmptyLine;
				if (delayLastCurly != null) {
					// We have unshifted the line back into the queue
					// continue is good, we will handle it next
				}
				continue;

			}

			// }

			// If we got here then we have neither indented nor outdented

			// TODO: DRY - this is a clone of earlier code!
			// DONE: We should not act on comment lines!
			if (options.addRemoveSemicolons && !wholeLineIsComment && !emptyOrBlank.match(currentLine)) {
				if (Heuristics.endsWithBackslash.match(currentLine)) {
					currentLine = Heuristics.endsWithBackslash.replace(currentLine,"");
				} else {
					currentLine = appendToLine(currentLine,";");
				}
			}
			out.writeLine(currentLine);

		}

		out.close();

	}

	function wrapParens(currentLine) {

		if (options.unwrapParenthesesForCommands != null) {
			var firstToken = getFirstWord(currentLine);
			if (options.unwrapParenthesesForCommands.has(firstToken)) {
				var res = splitLineAtComment(currentLine);
				var beforeComment = res[0];
				var afterComment = res[1];
				var replacementRE = new EReg(firstToken+"\\s*",'');
				beforeComment = replacementRE.replace(beforeComment,firstToken+" (") + ")";
				currentLine = beforeComment + afterComment;
			}
		}

		return currentLine;

	}

	// appends the string to the line, except if there is a trailing comment on the line, the append is done *before* the comment.
	function appendToLine(line : String, toAppend : String) {
		var res = splitLineAtComment(line);
		var beforeComment = res[0];
		var afterComment = res[1];
		return beforeComment + toAppend + afterComment;
	}

	// TODO: Does Haxe have a better way to return tuples, or use "out" arguments like UScript or &var pointers like C?
	public function splitLineAtComment(line : String) {
		var hasTrailingComment = trailingCommentOutsideQuotes.match(line) && trailingCommentOutsideApostrophes.match(line);
		// Actually it might only be trailing after indentation, no content!
		if (!hasTrailingComment) {
			return [line,""];
		} else {
			if (trailingCommentOutsideQuotes.matched(1) != trailingCommentOutsideApostrophes.matched(1)) {
				reporter.warn("trailingCommentOutsideQuotes and trailingCommentOutsideApostrophes could not agree where the comment boundary is: "+line);
				return [line,""];   // Do not try to split
			}
			// Regexps can end in ...\// - we do not want to split on that!
			if (looksLikeRegexpLine.match(line)) {
				// No logging - we have confidence in this?
				reporter.debug("could be a comment line but could equally be a regexp literal!  "+line);
				return [line,""];
			}
			try {
				if (couldbeRegexpEndingSlashSlash.match(line)) {
					// reporter.warn("looks like a // comment but could be regexp!  "+line);
					// This regexp is less ambiguous now - let's trust it and do-the-right-thing by ignoring the //.
					reporter.debug("could be a // comment but probably actually a regexp!  "+line);
					return [line,""];
				}
			} catch (ex : Dynamic) {
				reporter.warn("Exception applying couldbeRegexpEndingSlashSlash: \""+ex+"\" on line: "+line);
			}
			// trace("Line has trailing comment!  "+line);
			// This regexp finds the *last* occurrence of // on the line.  But sometimes a // comment contains // inside it!
			// We really want the first // which is not inside a string (or a regexp - unlikely).
			// Unfortunately we can't tell our evenNumberOfQuotes regexp to stop on /s, because a single / is a valid division operator.
			// OK managed to squeeze them.
			var beforeComment = trailingCommentOutsideQuotes.matched(1);
			var afterComment = trailingCommentOutsideQuotes.matched(4);
			// trace("beforeComment = "+beforeComment);
			// trace("afterComment="+afterComment);
			// Deal with annoying greediness: move the spaces from the end of beforeComment into the front of afterComment.
			var trailingSpaces = ~/\s*$/;
			if (trailingSpaces.match(beforeComment)) {
				afterComment = trailingSpaces.matched(0) + afterComment;
				beforeComment = trailingSpaces.replace(beforeComment,'');
			}
			return [beforeComment,afterComment];
		}
	}

	static var firstTokenRE = ~/^\s*([^\s]*)/;
	static function getFirstWord(line) {
		if (firstTokenRE.match(line)) {
			return firstTokenRE.matched(1);
		} else {
			return "";
		}
	}

	static function countIndent(indentString : String, line : String) : Int {
		if (indentString == null || line == null) {
			return 0;
		}
		var i,j,count : Int;
		i = 0;
		j = 0;
		count = 0;
		while (true) {
			if (line.charAt(i) == indentString.charAt(j)) {
				i++;
				if (i >= line.length) {
					break;
				}
				j++;
				if (j >= indentString.length) {
					j = 0;
					count++;
				}
			} else {
				break;
			}
		}
		return count;
	}

	static function repeatString(count : Int, str : String) {
		var sb : StringBuf = new StringBuf();
		for (i in 0...count) {
			sb.add(str);
		}
		return sb.toString();
	}

	function echo(str) {
		reporter.echo("[Rest] "+str);
	}

}

class Sync {

	var sws : SWS;

	var syncOptions : SyncOptions;

	public function new(_options, _syncOptions) {
		sws = new SWS(_options);
		syncOptions = _syncOptions;
	}

	public function safeDecurl(infile, outfile) {
		doSafely(sws.decurl, infile, outfile, sws.curl);
	}

	public function safeCurl(infile, outfile) {
		doSafely(sws.curl, infile, outfile, sws.decurl);
	}

	// Loving the first-order functions.
	// However in this particular case, I wouldn't mind getting more specific, because this is really not applicable to all functions in general.
	// E.g. we should only accept fn/class which implements "FileTransformer".
	public function doSafely(fn : Dynamic, inFile : String, outFile : String, inverseFn : Dynamic) {

		if (syncOptions.safeSyncMakeBackups) {
			var backupFile = outFile + ".bak";
			if (FileSystem.exists(outFile)) {
				File.copy(outFile, backupFile);
			}
		}

		var originalResult = null;
		if (FileSystem.exists(outFile)) {
			originalResult = File.getContent(outFile);
		}

		fn(inFile, outFile);
		// Now we want to mark the outFile with identical modification time to the inFile, so that sws knows it need not translate between them.
		// Unfortunately neko FileSystem does not expose this ability
		// So instead, we will simply try to touch the inFile ASAP, and if the time is a millisecond too late, accept the consequences (this source will be uneccessarily transformed again).
		touchFile(inFile);
		// Woop!  It worked!  (It might not work on very large files, or fine-grained filesystems.)

		if (syncOptions.safeSyncCheckInverse) {
			var tempFile = inFile + ".inv";
			inverseFn(outFile, tempFile);
			// echo("Now compare "+inFile+" against "+tempFile);
			if (File.getContent(inFile) != File.getContent(tempFile)) {
				warn("Warning: Inverse differs from original.  Differences may or may not be cosmetic!");
				// echo("Compare files: \""+inFile+"\" \""+tempFile+"\"");
				// echo("Compare: jdiff \""+inFile+"\" \""+tempFile+"\"");
				warn("Compare:");
				pureEcho("  vimdiff \""+inFile+"\" \""+tempFile+"\"");
				if (syncOptions.breakOnFirstFailedInverse) {
					echo("Exiting so user can inspect.  There may be more files which need processing...");
					// Lies: tempFile won't be checked! echo("Whichever file you edit will be transformed on the next pass, or if neither are edited, we will pick up where we left off, on the next file.")
					echo("If you edit edit the source file, it be transformed again on the next pass, if not we will pick up where we left off, on the next file.");
					Sys.exit(5);
				}
			}
		}

		if (originalResult != null) {
			var newResult = File.getContent(outFile);
			if (newResult != originalResult) {
				// This is perfectly normal, if we have changed the source file.
				info("There were changes to "+inFile+" since the last time ("+originalResult.length+" -> "+newResult.length+")");
			} else {
				// info("There were no changes since the last time ("+originalResult.length+" == "+newResult.length+")")
			}
		}
	}

	static function touchFile(filename) {
		File.copy(filename,filename+".touch");
		FileSystem.rename(filename+".touch",filename);
	}

	function traceCall(fn : Dynamic, args : Array<Dynamic>) : Dynamic {
		echo("Calling "+fn+" with args "+args);
		return fn(args);
	}

	static function getExtension(filename : String) {
		var words = filename.split(".");
		if (words.length > 1) {
			return words[words.length-1];
		} else {
			return "";
		}
	}

	public function doSync(root : String) {

		var validExtensionsLocal = syncOptions.validExtensions;

		// We want to collect all files ending with ".sws" or with a valid source extension.
		// Sometimes we will pick up a pair, but we merge them into one by canonicalisation.
		var filesToDo : Array<String> = [];
		forAllFilesBelow(root, function(f) {
			// echo("Checking file: "+f);
			var ext = getExtension(f);
			if (validExtensionsLocal.has(ext)) {
				// Canonicalise to the non-sws name
				if (ext == "sws") {
					var words = f.split(".");
					words = words.slice(0,words.length-1);
					f = words.join(".");
				}
				if (!filesToDo.has(f)) {
					filesToDo.push(f);
				}
				// echo("pushing: "+f);
			}
		});

		for (curlyFile in filesToDo) {
			syncFile(curlyFile);
		}
	}

	function syncFile(curlyFile) {

		var swsFile = curlyFile + ".sws";

		var direction : Int = 0;   // 0=none, 1=to_sws, 2=from_sws
		if (!FileSystem.exists(swsFile)) {
			direction = 1;
		} else if (!FileSystem.exists(curlyFile)) {
			direction = 2;
		} else {
			var srcStat = FileSystem.stat(curlyFile);
			var swsStat = FileSystem.stat(swsFile);
			// echo(srcStat + " <-> "+swsStat);
			if (srcStat.mtime.getTime() < swsStat.mtime.getTime()) {
				direction = 2;
			} else if (srcStat.mtime.getTime() > swsStat.mtime.getTime()) {
				direction = 1;
			}
		}

		if (direction == 1) {
			echo("Decurling "+curlyFile+" -> "+swsFile);
			// echo(decurl(curlyFile, swsFile));
			// decurl(curlyFile, swsFile);    // NOTE: safeCurl is now mandatory, because it deals with date updating
			// DONE: safeCurl and safeDecurl, done via doSafely; much nicer.
			// doSafely(decurl, curlyFile, swsFile, curl)
			safeDecurl(curlyFile, swsFile);
			// After transformation, transform *back* (to a tempfile), and check if the result matches the original.  If not warn user, showing differences.  (If they are minor he may ignore them.)
			// Also to be safe, we should store a backup of the target file before it is overwritten.
		} else if (direction == 2) {
			echo("Curling "+swsFile+" -> "+curlyFile);
			// traceCall(curl(swsFile, curlyFile));
			// curl(swsFile, curlyFile);
			// doSafely(curl, swsFile, curlyFile, decurl)
			safeCurl(swsFile, curlyFile);
		}
	}

	function forAllFilesBelow<ResType>(root : String, fn : String -> ResType) {
		var children = FileSystem.readDirectory(root);
		for (child in children) {
			var childPath = root + syncOptions.pathSeparator + child;
			if (FileSystem.isDirectory(childPath)) {
				if (!syncOptions.skipFoldersNamed.has(child)) {
					// echo("Descending to folder: "+childPath);
					forAllFilesBelow(childPath,fn);
				}
			} else {
				fn(childPath);
			}
		}
	}

	function echo(s) {
		sws.reporter.echo("[Sync] "+s);
	}

	function pureEcho(s) {
		sws.reporter.echo(s);
	}

	function info(s) {
		sws.reporter.info(s);
	}

	function warn(s) {
		sws.reporter.warn(s);
	}

}

class HelpfulReader {

	var input : haxe.io.Input;

	var queue : Array<String>;

	public function new(infile : String) {
		input = File.read(infile,false);
		queue = new Array<String>();
	}

	public function getNextLine() : String {
		if (queue.length > 0) {
			return queue.shift();
		}
		try {
			return input.readLine();
		} catch (ex : haxe.io.Eof) {
			return null;
		}
	}

	public function getNextNonEmptyLine() : String {
		// This could be rafactored to use peekLine
		var i : Int;
		for (i in 0...queue.length) {
			if (!SWS.emptyOrBlank.match(queue[i])) {
				return queue[i];
			}
		}
		// We ran out of queue to check!
		while (true) {
			try {
				var line = input.readLine();
				queue.push(line);
				if (!SWS.emptyOrBlank.match(line)) {
					return line;
				}
			} catch (ex: haxe.io.Eof) {
				break;
			}
		}
		return null;
	}

	public function pushBackLine(line : String) {
		queue.unshift(line);
	}

	// peekLine provides lines from the stream's future, without actually consuming them.
	// i starts from 1, not 0.  This may be a sub-optimal design.
	public function peekLine(i : Int) : String {
		while (queue.length < i) {
			try {
				var nextLine = input.readLine();
				queue.push(nextLine);
			} catch (ex : haxe.io.Eof) {
				return null;   // Beware: Do not attempt regexp matching on a null String - it will causes a segfault!
				// return "DUMMY";
			}
		}
		return queue[i - 1];
	}

}

// This streamer maintains whether we are inside a /*...*/ comment, or how deep we are inside nested parentheses (...).  It is not a proper lexer and therefore might be fooled by clever comments, or string or regexp literals.

// TODO: Multi-line comments can nest in Dart, but not in most older languages.  We can implement this similarly to parentheses but should offer an option to switch between the two schemes.

class CommentTrackingReader extends HelpfulReader {

	// Currently completely noob yet still unreadable xD
	public static var lineOpensCommentRE = ~/.*\/\*.*/;
	public static var lineClosesCommentRE = ~/.*\*\/.*/;

	public var insideComment : Bool; // = false;

	// Let's also track parentheses noobishly

	public static var parenthesisInsideQuotes = ~/[^"]*"[^"]*[()][^"]*"/;
	public static var parenthesisInsideApostrophes = ~/[^']*'[^']*[()][^']*"/;

	public var depthInsideParentheses : Int; // = false;

	var sws : SWS;
	var reporter : Reporter;

	public function new(infile,_sws) {
		super(infile);
		sws = _sws;
		reporter = sws.reporter;
		insideComment = false;
		depthInsideParentheses = 0;
	}

	public override function getNextLine() : String {
		var line = super.getNextLine();
		if (line == null) {
			return line;
		}
		var res = sws.splitLineAtComment(line);
		var lineBeforeComment = res[0];
		var trailingComment = res[1];

		if (lineOpensCommentRE.match(line)) {
			if (SWS.looksLikeRegexpLine.match(line)) {
				// reporter.echo("Looks like regexp literal declaration; assuming not a comment start: "+line);
			} else {
				insideComment = true;
				if (SWS.seemsToContainRegexp.match(lineBeforeComment)) {
					reporter.warn("Looks like start of comment block but also like a regexp!  "+line);
				}
			}
		}
		if (lineClosesCommentRE.match(line)) {
			if (SWS.looksLikeRegexpLine.match(line)) {
				// reporter.echo("Looks like regexp literal declaration; assuming not a comment end: "+line);
			} else {
				insideComment = false;
				if (SWS.seemsToContainRegexp.match(lineBeforeComment)) {
					reporter.warn("Looks like end of comment block but also like a regexp!  "+line);
				}
			}
		}

		// TODO: We should really be counting parentheses *outside* string and regexp literals!
		var openBracketCount = countInString(lineBeforeComment,"(".code);
		var closeBracketCount = countInString(lineBeforeComment,")".code);
		if (parenthesisInsideQuotes.match(lineBeforeComment) || parenthesisInsideApostrophes.match(lineBeforeComment)) {
			if (openBracketCount == closeBracketCount) {
				// Let's not cause a fuss if we don't have to.
			} else {
				// reporter.echo("I am not trusting the parentheses on this line, although their could be some!");
				reporter.debug("Ignoring untrustworthy parentheses: "+line);
			}
			// TODO: Perhaps we can count how many are inside "s, how many are inside 's and thus deduce how many are left outside?
			// Ofc we have also forgotten (s or )s inside Regexp literals.
			// And our "-pairing regexps cannot handle \" inside them, likewise for '...\'...'
			// For now, this is likely to fail on lines such as:
			//   if (myString.charAt(0) == "(")      // blah blah
		} else {
			depthInsideParentheses += (openBracketCount - closeBracketCount);
		}

		// reporter.echo("["+depthInsideParentheses+"] "+line);

		return line;
	}

	function countInString(s : String, c) : Int {
		var count = 0;
		for (i in 0...s.length) {
			if (s.charCodeAt(i) == c) {
				count++;
			}
		}
		return count;
	}

}

class Heuristics {

	public static var leadingIndentRE : EReg = ~/^\s*/;
	public static var whitespaceRE : EReg = ~/\s+/;
	public static var endsWithBackslash : EReg = ~/\s?\\$/;
	public static var endsWithComma : EReg = ~/,\s*$/;

}
