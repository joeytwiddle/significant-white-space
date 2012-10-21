package org.neuralyte.sws;

import neko.io.File;
import neko.io.FileInput;
import neko.io.FileOutput;

class HelpfulReader {

	var input : haxe.io.Input;

	public function new(infile : String) {
		input = File.read(infile,false);
	}

}

class Root {

	static var newline : String = "\r\n";

	static function main() {

		var args = neko.Sys.args();

		trace("HELLO");

		if (args[0] == "curl") {

			var filePath : String = args[1];
			decurl(filePath+".sws", filePath);

		} else if (args[0] == "decurl") {

			var filePath : String = args[1];
			decurl(filePath, filePath+".sws");

		} else {

			// showHelp();

		}

	}

	static function decurl(infile : String, outfile : String) {

		var startsWithCurly : EReg = ~/^\s*}\s*/;
		var startReplacer : EReg = ~/}\s*/;   // We don't want to strip the indent
		var endsWithCurly : EReg = ~/\s*{\s*$/;
		var emptyOrBlank : EReg = ~/^\s*$/;

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

