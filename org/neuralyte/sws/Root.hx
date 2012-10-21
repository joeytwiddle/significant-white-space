package org.neuralyte.sws;

import neko.io.File;
import neko.io.FileInput;
import neko.io.FileOutput;

class Root {

	static function main() {

		var args = neko.Sys.args();

		trace("HELLO");

		var filePath : String = args[0];

		// if (!File.exists(filePath)) {
			// return;
		// }

		var f : FileInput = File.read(filePath,false);

		var s : String;

		try {

			while (true) {

				s = f.readLine();

				trace("Read line: "+s);

			}

		} catch (ex : haxe.io.Eof) {
			trace("Reached the End Of the File.");
		}

	}

}
