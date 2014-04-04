package sws;

import sys.io.File;

class SWSFileOutput implements SWSOutput {

	var output : haxe.io.Output;

	public function new(fname : String) {
		output = File.write(fname,false);
	}

	public function writeString(s) {
		output.writeString(s);
	}

	public function close() {
		output.close();
	}

}
