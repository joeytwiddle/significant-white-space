package org.neuralyte.sws;

import neko.io.File;
import neko.io.FileInput;
import neko.io.FileOutput;
import neko.FileSystem;

using Lambda;

class Root {

	static var javaStyleCurlies : Bool = true;
	static var addRemoveSemicolons : Bool = true;

	static var newline : String = "\r\n";
	static var pathSeparator = "/";

	public static var emptyOrBlank : EReg = ~/^\s*$/;
	static var indentRE : EReg = ~/^\s*/;
	static var commentRE : EReg = ~/(^\s*\/\/|^\s*\/\*|\*\/\s*$)/;
	// Warning: Do not be tempted to search for "  //" mid-line.  Yes that could indicate an appended comment, but it could just as easily be part of a string on a line which requires semicolon injection!
	static var couldbeRegexp : EReg = ~/=[ \t]*~?\/[^\/].*\*\/\s*$/;
	// That catches Haxe EReg literal declared with = ~/...*/, or Javascript RegExp literal declared with = /...*/ whilst ignoring comment lines declared with //

	static var continuationKeywords = [ "else", "catch" ];

	static var validExtensions = [ "java", "c", "C", "cpp", "c++", "h", "hx", "uc" ];   // "jpp"

	static function main() {

		var args = neko.Sys.args();

		if (args[0] == "--help") {

			showHelp();

		} else if (args[0] == "curl") {

			curl(args[1], args[2]);

		} else if (args[0] == "decurl") {

			decurl(args[1], args[2]);

		} else if (args[0] == "sync") {

			if (args[1] != null) {
				doSync(args[1]);
			} else {
				doSync(".");
			}

		} else {

			showHelp();

		}

	}

	static function showHelp() {
		// Sys.out.
		trace("sws curl <filename> <outname>");
		trace("sws decurl <filename> <outname>");
		trace("sws sync [<folder/filename>]");
	}

	static function decurl(infile : String, outfile : String) {

		// We detect lines which end with an opening curly brace
		var endsWithCurly : EReg = ~/\s*{\s*$/;
		// And lines which start with a closing curly brace
		var startsWithCurly : EReg = ~/^\s*}\s*/;
		var startReplacer : EReg = ~/}\s*/;   // We don't want to strip the indent
		// And sometimes lines ending in a semicolon.
		var endsWithSemicolon : EReg = ~/\s*;\s*$/;

		var input : FileInput = File.read(infile,false);

		var output : FileOutput = File.write(outfile,false);

		try {

			while (true) {

				var line : String = input.readLine();

				// trace("Read line: "+line);

				// We don't want to strip anything from comment lines
				var isAComment = commentRE.match(line);
				if (!isAComment) {

					if (startsWithCurly.match(line)) {
						line = startReplacer.replace(line,"");
						if (emptyOrBlank.match(line)) {
							continue;
						}
					}

					if (endsWithCurly.match(line)) {
						line = endsWithCurly.replace(line,"");
						if (emptyOrBlank.match(line)) {
							continue;
						}
					}

					if (addRemoveSemicolons && endsWithSemicolon.match(line)) {
						line = endsWithSemicolon.replace(line,"");
					}

				}

				// trace("Line: "+line);
				output.writeString(line + newline);

			}

		} catch (ex : haxe.io.Eof) {
			// trace("Reached the End Of the File.");
		}

		output.close();

	}

	static function curl(infile : String, outfile : String) {

		var leadingIndentRE : EReg = ~/^\s*/;
		var whitespaceRE : EReg = ~/\s+/;

		var currentLine : String;

		var helper = new HelpfulReader(infile);

		var output : FileOutput = File.write(outfile,false);

		var currentLine : String;

		var indentString : String = null;

		var currentIndent : Int = 0;

		while ( (currentLine = helper.getNextLine()) != null) {

			// trace("currentLine = "+currentLine);

			// TODO: Do not seek curlies on comment lines, such as this trouble-maker here:
			// if (!emptyOrBlank.match(currentLine)) {

			if (!emptyOrBlank.match(currentLine)) {
				currentIndent = countIndent(indentString, currentLine);
			} // otherwise we keep last indent

			var nextNonEmptyLine : String;
			nextNonEmptyLine = helper.getNextNonEmptyLine();
			// NOTE: nextNonEmptyLine may be null which means EOF which should be understood as indent 0.

			if (indentString == null && nextNonEmptyLine!=null) {
				indentRE.match(nextNonEmptyLine);
				var indentPart = indentRE.matched(0);
				if (indentPart != "") {
					indentString = indentPart;
					trace("Found first indent, length "+indentString.length);
				}
			}

			var indent_of_nextNonEmptyLine = countIndent(indentString, nextNonEmptyLine);

			// trace("curr:" + currentIndent+"  next: "+indent_of_nextNonEmptyLine);

			// We want to avoid semicolon addition on comment lines
			// But we do want consider comment lines for indentation / bracing
			var isAComment = commentRE.match(currentLine);
			if (isAComment) {
				// Now a nasty fudge for lines ending */ because they are a Haxe EReg or Javascript RegExp literal, not a comment.
				var lineCouldbeRegexp = couldbeRegexp.match(currentLine);
				if (lineCouldbeRegexp) {
					isAComment = false;
				}
			}

			if (indent_of_nextNonEmptyLine > currentIndent) {

				// Assumption: indent never increases by more than one
				// Append open curly to current line
				// Then write it
				if (javaStyleCurlies) {
					output.writeString(currentLine + " {" + newline);
				} else {
					output.writeString(currentLine + newline);
					output.writeString(repeatString(currentIndent,indentString) + "{" + newline);
				}
				currentIndent++;
				continue;

			}

			if (indent_of_nextNonEmptyLine < currentIndent) {

				// Write current line
				// Write close curly (at lower indent)
				// In fact write as many as we need...

				// DONE: We need to check/apply addRemoveSemicolons rule to currentLine before we output it.
				// TODO: DRY - this is a clone of later code!
				// DONE: We should not act on comment lines!
				if (!isAComment && addRemoveSemicolons && !emptyOrBlank.match(currentLine)) {
					currentLine += ";";
				}
				output.writeString(currentLine + newline);

				var delayLastCurly = false;
				// DONE: If the next non-empty line starts with the "else" or "catch" keyword, then:
				//   in Javastyle, we could join that line on after the }
				//   in either braces style, any blank lines between us and the next line can be outputted *before* the } we are about to write.
				// I am not quite sure how this should work on multiple outdents - for now only trying delayLastCurly on the last.  Yes that is right.
				// Other things which like to trail after closing } is the name following a "typedef struct { ... } Name;".  Since that name could be anything, we could look for just one word, but then that would misfire on other single words like "break" "continue" "debugger" and "i++"!
				if (nextNonEmptyLine != null) {
					var tokens = leadingIndentRE.replace(nextNonEmptyLine,'').split(" ");   // TODO: should really split on whitespaceRE
					var firstToken = tokens[0];
					if (continuationKeywords.has(firstToken) || firstToken.charAt(0)==')') {
						delayLastCurly = true;
					}
				}
				// DONE: One other situation where we might want to join lines, is when the next symbol after the "}" is a ")".  (Consider restriction: Only if that ")" line has the same indent as our "}" line would?)

				var i = currentIndent - 1;   // We could actually just continue to use currentIndent instead of i.
				while (i >= indent_of_nextNonEmptyLine) {
					// trace("De-curlifying with i="+i);

					var indentAtThisLevel = repeatString(i,indentString);

					// DONE: Even if we don't detect a continuation keyword, if the next *two* lines are both blanks, then emit one of them before the curly.  This won't always be right, but it may be right more often than wrong.
					// This rule could be applied for every outdent, checking the next two lines again on each.

					if (delayLastCurly && i == indent_of_nextNonEmptyLine) {

						// We are guaranteed a nextLine
						var nextLine = null;
						while (true) {
							nextLine = helper.getNextLine();
							if (emptyOrBlank.match(nextLine)) {
								output.writeString(nextLine + newline);
							} else {
								break;
							}
							// nextLine should be === nextNonEmptyLine now
						}
						var updatedLine;
						if (javaStyleCurlies) {
							// Join the next line to the curly
							updatedLine = indentAtThisLevel + "} " + leadingIndentRE.replace(nextLine,"");
							// output.writeString(updatedLine + newline);
							// But now we want to consider this line for opening an indent :O
							// Feck!  Oh ... hmmm ... Managed that using pushBackLine.  :)
						} else {
							// Write the curly on its own line
							output.writeString(indentAtThisLevel + "}" + newline);
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
						if (delayLastCurly) {
							numEmptyLinesRequired--;
						}
						for (j in 0...numEmptyLinesRequired) {
							var peekLine = helper.peekLine(j+1);
							if (peekLine == null || !emptyOrBlank.match(peekLine)) {
								spaceCurly = false;
								break;
							}
						}

						if (spaceCurly) {
							// Do not write the '}' just yet ...
							// Consume and write the blank line now, and the '}' right after.
							var nextLine = helper.getNextLine();
							output.writeString(nextLine + newline);
						}

						output.writeString(indentAtThisLevel + "}" + newline);

					}

					i--;
				}

				currentIndent = indent_of_nextNonEmptyLine;
				if (delayLastCurly) {
					// We have unshifted the line back into the queue
					// continue is good, we will handle it next
				}
				continue;

			}

			// }

			// If we got here then we have neither indented nor outdented

			// TODO: DRY - this is a clone of earlier code!
			// DONE: We should not act on comment lines!
			if (!isAComment && addRemoveSemicolons && !emptyOrBlank.match(currentLine)) {
				currentLine += ";";
			}
			output.writeString(currentLine + newline);

		}

		output.close();

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

	static function getExtension(filename : String) {
		var words = filename.split(".");
		if (words.length > 1) {
			return words[words.length-1];
		} else {
			return "";
		}
	}

	static function doSync(root : String) {

		// We want to collect all files ending with ".sws" or with a valid source extension.
		// Sometimes we will pick up a pair, but we merge them into one by canonicalisation.
		var filesToDo : Array<String> = [];
		forAllFilesBelow(root, function(f) {
			// trace("Checking file: "+f);
			var ext = getExtension(f);
			if (validExtensions.has(ext)) {
				// Canonicalise to the non-sws name
				if (ext == "sws") {
					var words = f.split(".");
					words = words.slice(0,words.length-1);
					f = words.join(".");
				}
				if (!filesToDo.has(f)) {
					filesToDo.push(f);
				}
				// trace("pushing: "+f);
			}
		});

		for (srcFile in filesToDo) {
			syncFile(srcFile);
		}

	}

	static function syncFile(srcFile) {

		var swsFile = srcFile + ".sws";

		var direction : Int = 0;   // 0=none, 1=to_sws, 2=from_sws
		if (!FileSystem.exists(swsFile)) {
			direction = 1;
		} else if (!FileSystem.exists(srcFile)) {
			direction = 2;
		} else {
			var srcStat = FileSystem.stat(srcFile);
			var swsStat = FileSystem.stat(swsFile);
			// trace(srcStat + " <-> "+swsStat);
			if (srcStat.mtime.getTime() < swsStat.mtime.getTime()) {
				direction = 2;
			} else if (srcStat.mtime.getTime() > swsStat.mtime.getTime()) {
				direction = 1;
			}
		}

		if (direction == 1) {
			trace("Decurling "+srcFile+" -> "+swsFile);
			// traceCall(decurl(srcFile, swsFile));
			// decurl(srcFile, swsFile);    // NOTE: safeCurl is now mandatory, because it deals with date updating
			doSafely(decurl, srcFile, swsFile, curl);
			// TODO: safeCurl and safeDecurl
			// After transformation, transform *back* (to a tempfile), and check if the result matches the original.  If not warn user, showing differences.  (If they are minor he may ignore them.)
			// Also to be safe, we should store a backup of the target file before it is overwritten.
		} else if (direction == 2) {
			trace("Curling "+swsFile+" -> "+srcFile);
			// traceCall(curl(swsFile, srcFile));
			// curl(swsFile, srcFile);
			doSafely(curl, swsFile, srcFile, decurl);
		}

	}

	static function forAllFilesBelow<ResType>(root : String, fn : String -> ResType) {
		var children = FileSystem.readDirectory(root);
		for (child in children) {
			var childPath = root + pathSeparator + child;
			if (FileSystem.isDirectory(childPath)) {
				// trace("Descending to folder: "+childPath);
				forAllFilesBelow(childPath,fn);
			} else {
				fn(childPath);
			}
		}
	}

	static function doSafely(fn : Dynamic, inFile : String, outFile : String, inverseFn : Dynamic) {
		var backupFile = outFile + ".bak";
		if (FileSystem.exists(outFile)) {
			File.copy(outFile, backupFile);
		}
		fn(inFile, outFile);
		// Now we want to mark the outFile with identical modification time to the inFile, so that sws knows it need not translate between them.
		// Unfortunately neko FileSystem does not expose this ability
		// So we will simply try to touch the inFile ASAP, and if the time is a millisecond too late, accept the consequences (this source will be uneccessarily transformed again).
		touchFile(inFile);
		// Woop!  It worked!  (It might not work on very large files.)
		var tempFile = inFile + ".inv";
		inverseFn(outFile, tempFile);
		// trace("Now compare "+inFile+" against "+tempFile);
		if (File.getContent(inFile) != File.getContent(tempFile)) {
			trace("Warning: Inverse differs from original.  Differences may or may not be cosmetic!");
			// trace("Compare files: \""+inFile+"\" \""+tempFile+"\"");
			trace("Compare: vimdiff \""+inFile+"\" \""+tempFile+"\"");
			// trace("Compare: jdiff \""+inFile+"\" \""+tempFile+"\"");
		}
	}

	static function touchFile(filename) {
		File.copy(filename,filename+".touch");
		FileSystem.rename(filename+".touch",filename);
	}

	static function traceCall(fn : Dynamic, args : Array<Dynamic>) : Dynamic {
		trace("Calling "+fn+" with args "+args);
		return fn(args);
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
		var i : Int;
		for (i in 0...queue.length) {
			if (!Root.emptyOrBlank.match(queue[i])) {
				return queue[i];
			}
		}
		// We ran out of queue to check!
		while (true) {
			try {
				var line = input.readLine();
				queue.push(line);
				if (!Root.emptyOrBlank.match(line)) {
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

