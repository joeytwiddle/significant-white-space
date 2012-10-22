package org.neuralyte.sws;

import neko.io.File;
import neko.io.FileInput;
import neko.io.FileOutput;
import neko.FileSystem;

using Lambda;

class Root {

	static var newline : String = "\r\n";
	static var pathSeparator = "/";
	static var javaStyleCurlies : Bool = true;
	static var addRemoveSemicolons : Bool = true;

	public static var emptyOrBlank : EReg = ~/^\s*$/;
	static var indentRE : EReg = ~/^\s*/;
	static var commentRE : EReg = ~/(^\s*\/\/|^\s*\/\*|\*\/\s*$)/;
	// Warning: Do not be tempted to search for "  //" mid-line.  That could be a comment, or it could be part of a string on a line requiring semicolon injection!
	static var couldbeRegexp : EReg = ~/=[ \t]*~?\/[^\/].*\*\/\s*$/;
	// That catches Haxe EReg literal declared with = ~/...*/, or Javascript RegExp literal declared with = /...*/ whilst ignoring comment lines declared with //

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

		var currentLine : String;

		var helper = new HelpfulReader(infile);

		var output : FileOutput = File.write(outfile,false);

		var currentLine : String;

		var indentString : String = null;

		var currentIndent : Int = 0;

		while ( (currentLine = helper.nextLine()) != null) {

			// trace("currentLine = "+currentLine);

			// TODO: Do not seek curlies on comment lines, such as this trouble-maker here:
			// if (!emptyOrBlank.match(currentLine)) {

			if (!emptyOrBlank.match(currentLine)) {
				currentIndent = countIndent(indentString, currentLine);
			} // otherwise we keep last indent

			var nextNonEmptyLine : String;
			nextNonEmptyLine = helper.nextNonBlankLine();
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
			// We assume comment lines are irrelevant for indentation (but this is not really true if the nextNonBlankLine is indented, although that illegal in Coffeescript anyway).
			var isAComment = commentRE.match(currentLine);
			if (isAComment) {
				// Now a nasty fudge for lines ending */ because they are a Haxe EReg definition.
				var lineCouldbeRegexp = couldbeRegexp.match(currentLine);
				if (!lineCouldbeRegexp) {
					// trace("Is a comment line: "+currentLine);
					output.writeString(currentLine + newline);
					continue;
				}
			}

			if (indent_of_nextNonEmptyLine > currentIndent) {

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
				// TODO: We should not act on comment lines!
				if (addRemoveSemicolons && !emptyOrBlank.match(currentLine)) {
					currentLine += ";";
				}
				output.writeString(currentLine + newline);

				var i : Int;
				i = currentIndent-1;
				while (i >= indent_of_nextNonEmptyLine) {
					// trace("De-curlifying with i="+i);
					// TODO: If the next non-empty line starts with the "else" or "catch" or "typedef" keyword, then:
					//   in Javastyle, we could join that line on after the }
					//   in either braces style, any blank lines between us and the next line can be outputted *before* the } we are about to write.
					output.writeString(repeatString(i,indentString) + "}" + newline);
					i--;
				}
				currentIndent = indent_of_nextNonEmptyLine;
				continue;

			}

			// }

			// If we got here then we have neither indented nor outdented

			// TODO: DRY - this is a clone of earlier code!
			// TODO: We should not act on comment lines!
			if (addRemoveSemicolons && !emptyOrBlank.match(currentLine)) {
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
			var swsFile = srcFile + ".sws";

			var direction : Int;   // 1=to_sws 2=from_sws
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
				} else {
					direction = 1;
				}
			}

			if (direction == 1) {
				trace("Decurling "+srcFile+" -> "+swsFile);
				// traceCall(decurl(srcFile, swsFile));
				// decurl(srcFile, swsFile);
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
		var tempFile = inFile + ".res";
		inverseFn(outFile, tempFile);
		trace("Now compare "+inFile+" against "+tempFile);
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

	public function nextLine() : String {
		if (queue.length > 0) {
			return queue.shift();
		}
		try {
			return input.readLine();
		} catch (ex : haxe.io.Eof) {
			return null;
		}
	}

	public function nextNonBlankLine() : String {
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

}

