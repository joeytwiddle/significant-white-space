package sws;

class SWSStringOutput implements SWSOutput {

	var lines : Array<String>;

	public function new() {
		lines = [];
	}

	public function writeString(s) {
		lines.push(s);
	}

	public function close() {
		// do nothing
	}

	public function toString() {
		return lines.join("\n");
	}

}
