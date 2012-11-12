package sws;

import neko.io.File;

class SWSFileInput implements SWSInput {

	var input : haxe.io.Input;

	public function new(fname : String) {
		input = File.read(fname,false);
	}

	public function readLine() : String {
		return input.readLine();
	}

}
