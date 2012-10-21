package org.neuralyte.sws;

import neko.io.File;
import neko.io.FileInput;
import neko.io.FileOutput;

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

	/*
	public function peekLine() : String {
		try {
			var line : String = input.readLine();
			queue.push(line);
			return line;
		} catch (ex : haxe.io.Eof) {
			return null;
		}
	}
	*/

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

class Root {

	static var newline : String = "\r\n";
	static var javaStyleCurlies : Bool = false;

	public static var emptyOrBlank : EReg = ~/^\s*$/;
	static var indentRE : EReg = ~/^\s*/;

	static function main() {

		var args = neko.Sys.args();

		trace("HELLO");

		if (args[0] == "curl") {

			var filePath : String = args[1];
			curl(filePath+".sws", filePath);

		} else if (args[0] == "decurl") {

			var filePath : String = args[1];
			decurl(filePath, filePath+".sws");

		} else {

			// showHelp();

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

	static function curl(infile : String, outfile : String) {

		var currentLine : String;

		var helper = new HelpfulReader(infile);

		var output : FileOutput = File.write(outfile,false);

		var currentLine : String;

		var indentString : String = null;

		var currentIndent : Int = 0;

		while ( (currentLine = helper.nextLine()) != null) {

			trace("currentLine = "+currentLine);

			// if (!emptyOrBlank.match(currentLine)) {

				if (indentString == null) {
					indentRE.match(currentLine);
					var currentLineIndentString = indentRE.matched(0);
					if (currentLineIndentString != "") {
						indentString = currentLineIndentString;
						trace("Found first indent, length "+indentString.length);
					}
				}

				if (!emptyOrBlank.match(currentLine)) {
					currentIndent = countIndent(indentString, currentLine);
				} // otherwise we keep last indent

				var nextNonEmptyLine : String;
				/*
				// Out peekLine implementation is vaguely defined and fails!
				while ( (nextNonEmptyLine = helper.peekLine()) != null) {
					if (!emptyOrBlank.match(nextNonEmptyLine)) {
						trace("[next-non-empty]: "+nextNonEmptyLine);
						break; // found it
					}
				}
				*/
				nextNonEmptyLine = helper.nextNonBlankLine();
				// NOTE: nextNonEmptyLine may be null which means EOF which should be understood as indent 0.

				var indent_of_nextNonEmptyLine = countIndent(indentString, nextNonEmptyLine);

				trace("curr:" + currentIndent+"  next: "+indent_of_nextNonEmptyLine);

				if (indent_of_nextNonEmptyLine > currentIndent) {

					// Append open curly to current line
					// Then write it
					if (javaStyleCurlies) {
						output.writeString(currentLine + " {" + newline);
					} else {
						output.writeString(currentLine + newline);
						output.writeString(repeatString(currentIndent,indentString)+"{" + newline);
					}
					currentIndent++;
					continue;

				}

				if (indent_of_nextNonEmptyLine < currentIndent) {

					// Write current line
					// Write close curly (at lower indent)
					// In fact write as many as we need...
					output.writeString(currentLine + newline);
					var i : Int;
					i = currentIndent-1;
					while (i >= indent_of_nextNonEmptyLine) {
						trace("De-curlifying with i="+i);
						var outLine : String = "";
						for (j in 0...i) {
							trace("Iterating with j="+j);
							outLine = outLine + indentString;
						}
						output.writeString(outLine + "}" + newline);
						i--;
					}
					currentIndent = indent_of_nextNonEmptyLine;
					continue;

				}

			// }

			output.writeString(currentLine + newline);

		}

		output.close();

	}

	static function repeatString(count : Int, str : String) {
		var sb : StringBuf = new StringBuf();
		for (i in 0...count) {
			sb.add(str);
		}
		return sb.toString();
	}

	static function decurl(infile : String, outfile : String) {

		var startsWithCurly : EReg = ~/^\s*}\s*/;
		var startReplacer : EReg = ~/}\s*/;   // We don't want to strip the indent
		var endsWithCurly : EReg = ~/\s*{\s*$/;

		var input : FileInput = File.read(infile,false);

		var output : FileOutput = File.write(outfile,false);

		try {

			while (true) {

				var line : String = input.readLine();

				// trace("Read line: "+line);

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

				trace("Line: "+line);
				output.writeString(line + newline);

			}

		} catch (ex : haxe.io.Eof) {
			trace("Reached the End Of the File.");
		}

		output.close();

	}

}

