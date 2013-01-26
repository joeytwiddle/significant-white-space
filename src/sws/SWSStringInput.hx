package sws;

class SWSStringInput implements SWSInput {

	var lines : Array<String>;

	public function new(input : String) {
		lines = input.split("\n");
	}

	public function readLine() : String {
		if (lines.length > 0) {
			var line = lines.shift();
			if (line.charAt(line.length-1) == '\r') {
				line = line.substr(0,line.length-1);
			}
			return line;
		} else {
			throw "End of stringfile";
		}
		return null;
	}

}
