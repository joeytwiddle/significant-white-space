$estr = function() { return js.Boot.__string_rec(this,''); }
if(typeof haxe=='undefined') haxe = {}
if(!haxe.io) haxe.io = {}
haxe.io.BytesBuffer = function(p) { if( p === $_ ) return; {
	this.b = new Array();
}}
haxe.io.BytesBuffer.__name__ = ["haxe","io","BytesBuffer"];
haxe.io.BytesBuffer.prototype.b = null;
haxe.io.BytesBuffer.prototype.addByte = function($byte) {
	this.b.push($byte);
}
haxe.io.BytesBuffer.prototype.add = function(src) {
	var b1 = this.b;
	var b2 = src.b;
	{
		var _g1 = 0, _g = src.length;
		while(_g1 < _g) {
			var i = _g1++;
			this.b.push(b2[i]);
		}
	}
}
haxe.io.BytesBuffer.prototype.addBytes = function(src,pos,len) {
	if(pos < 0 || len < 0 || pos + len > src.length) throw haxe.io.Error.OutsideBounds;
	var b1 = this.b;
	var b2 = src.b;
	{
		var _g1 = pos, _g = pos + len;
		while(_g1 < _g) {
			var i = _g1++;
			this.b.push(b2[i]);
		}
	}
}
haxe.io.BytesBuffer.prototype.getBytes = function() {
	var bytes = new haxe.io.Bytes(this.b.length,this.b);
	this.b = null;
	return bytes;
}
haxe.io.BytesBuffer.prototype.__class__ = haxe.io.BytesBuffer;
haxe.io.Input = function() { }
haxe.io.Input.__name__ = ["haxe","io","Input"];
haxe.io.Input.prototype.bigEndian = null;
haxe.io.Input.prototype.readByte = function() {
	return (function($this) {
		var $r;
		throw "Not implemented";
		return $r;
	}(this));
}
haxe.io.Input.prototype.readBytes = function(s,pos,len) {
	var k = len;
	var b = s.b;
	if(pos < 0 || len < 0 || pos + len > s.length) throw haxe.io.Error.OutsideBounds;
	while(k > 0) {
		b[pos] = this.readByte();
		pos++;
		k--;
	}
	return len;
}
haxe.io.Input.prototype.close = function() {
	null;
}
haxe.io.Input.prototype.setEndian = function(b) {
	this.bigEndian = b;
	return b;
}
haxe.io.Input.prototype.readAll = function(bufsize) {
	if(bufsize == null) bufsize = 16384;
	var buf = haxe.io.Bytes.alloc(bufsize);
	var total = new haxe.io.BytesBuffer();
	try {
		while(true) {
			var len = this.readBytes(buf,0,bufsize);
			if(len == 0) throw haxe.io.Error.Blocked;
			total.addBytes(buf,0,len);
		}
	}
	catch( $e0 ) {
		if( js.Boot.__instanceof($e0,haxe.io.Eof) ) {
			var e = $e0;
			null;
		} else throw($e0);
	}
	return total.getBytes();
}
haxe.io.Input.prototype.readFullBytes = function(s,pos,len) {
	while(len > 0) {
		var k = this.readBytes(s,pos,len);
		pos += k;
		len -= k;
	}
}
haxe.io.Input.prototype.read = function(nbytes) {
	var s = haxe.io.Bytes.alloc(nbytes);
	var p = 0;
	while(nbytes > 0) {
		var k = this.readBytes(s,p,nbytes);
		if(k == 0) throw haxe.io.Error.Blocked;
		p += k;
		nbytes -= k;
	}
	return s;
}
haxe.io.Input.prototype.readUntil = function(end) {
	var buf = new StringBuf();
	var last;
	while((last = this.readByte()) != end) buf.b[buf.b.length] = String.fromCharCode(last);
	return buf.b.join("");
}
haxe.io.Input.prototype.readLine = function() {
	var buf = new StringBuf();
	var last;
	var s;
	try {
		while((last = this.readByte()) != 10) buf.b[buf.b.length] = String.fromCharCode(last);
		s = buf.b.join("");
		if(s.charCodeAt(s.length - 1) == 13) s = s.substr(0,-1);
	}
	catch( $e0 ) {
		if( js.Boot.__instanceof($e0,haxe.io.Eof) ) {
			var e = $e0;
			{
				s = buf.b.join("");
				if(s.length == 0) throw e;
			}
		} else throw($e0);
	}
	return s;
}
haxe.io.Input.prototype.readFloat = function() {
	throw "Not implemented";
	return 0;
}
haxe.io.Input.prototype.readDouble = function() {
	throw "Not implemented";
	return 0;
}
haxe.io.Input.prototype.readInt8 = function() {
	var n = this.readByte();
	if(n >= 128) return n - 256;
	return n;
}
haxe.io.Input.prototype.readInt16 = function() {
	var ch1 = this.readByte();
	var ch2 = this.readByte();
	var n = this.bigEndian?ch2 | ch1 << 8:ch1 | ch2 << 8;
	if((n & 32768) != 0) return n - 65536;
	return n;
}
haxe.io.Input.prototype.readUInt16 = function() {
	var ch1 = this.readByte();
	var ch2 = this.readByte();
	return this.bigEndian?ch2 | ch1 << 8:ch1 | ch2 << 8;
}
haxe.io.Input.prototype.readInt24 = function() {
	var ch1 = this.readByte();
	var ch2 = this.readByte();
	var ch3 = this.readByte();
	var n = this.bigEndian?ch3 | ch2 << 8 | ch1 << 16:ch1 | ch2 << 8 | ch3 << 16;
	if((n & 8388608) != 0) return n - 16777216;
	return n;
}
haxe.io.Input.prototype.readUInt24 = function() {
	var ch1 = this.readByte();
	var ch2 = this.readByte();
	var ch3 = this.readByte();
	return this.bigEndian?ch3 | ch2 << 8 | ch1 << 16:ch1 | ch2 << 8 | ch3 << 16;
}
haxe.io.Input.prototype.readInt31 = function() {
	var ch1, ch2, ch3, ch4;
	if(this.bigEndian) {
		ch4 = this.readByte();
		ch3 = this.readByte();
		ch2 = this.readByte();
		ch1 = this.readByte();
	}
	else {
		ch1 = this.readByte();
		ch2 = this.readByte();
		ch3 = this.readByte();
		ch4 = this.readByte();
	}
	if((ch4 & 128) == 0 != ((ch4 & 64) == 0)) throw haxe.io.Error.Overflow;
	return ch1 | ch2 << 8 | ch3 << 16 | ch4 << 24;
}
haxe.io.Input.prototype.readUInt30 = function() {
	var ch1 = this.readByte();
	var ch2 = this.readByte();
	var ch3 = this.readByte();
	var ch4 = this.readByte();
	if((this.bigEndian?ch1:ch4) >= 64) throw haxe.io.Error.Overflow;
	return this.bigEndian?ch4 | ch3 << 8 | ch2 << 16 | ch1 << 24:ch1 | ch2 << 8 | ch3 << 16 | ch4 << 24;
}
haxe.io.Input.prototype.readInt32 = function() {
	var ch1 = this.readByte();
	var ch2 = this.readByte();
	var ch3 = this.readByte();
	var ch4 = this.readByte();
	return this.bigEndian?(ch1 << 8 | ch2) << 16 | (ch3 << 8 | ch4):(ch4 << 8 | ch3) << 16 | (ch2 << 8 | ch1);
}
haxe.io.Input.prototype.readString = function(len) {
	var b = haxe.io.Bytes.alloc(len);
	this.readFullBytes(b,0,len);
	return b.toString();
}
haxe.io.Input.prototype.__class__ = haxe.io.Input;
StringTools = function() { }
StringTools.__name__ = ["StringTools"];
StringTools.urlEncode = function(s) {
	return encodeURIComponent(s);
}
StringTools.urlDecode = function(s) {
	return decodeURIComponent(s.split("+").join(" "));
}
StringTools.htmlEscape = function(s) {
	return s.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;");
}
StringTools.htmlUnescape = function(s) {
	return s.split("&gt;").join(">").split("&lt;").join("<").split("&amp;").join("&");
}
StringTools.startsWith = function(s,start) {
	return s.length >= start.length && s.substr(0,start.length) == start;
}
StringTools.endsWith = function(s,end) {
	var elen = end.length;
	var slen = s.length;
	return slen >= elen && s.substr(slen - elen,elen) == end;
}
StringTools.isSpace = function(s,pos) {
	var c = s.charCodeAt(pos);
	return c >= 9 && c <= 13 || c == 32;
}
StringTools.ltrim = function(s) {
	var l = s.length;
	var r = 0;
	while(r < l && StringTools.isSpace(s,r)) {
		r++;
	}
	if(r > 0) return s.substr(r,l - r);
	else return s;
}
StringTools.rtrim = function(s) {
	var l = s.length;
	var r = 0;
	while(r < l && StringTools.isSpace(s,l - r - 1)) {
		r++;
	}
	if(r > 0) {
		return s.substr(0,l - r);
	}
	else {
		return s;
	}
}
StringTools.trim = function(s) {
	return StringTools.ltrim(StringTools.rtrim(s));
}
StringTools.rpad = function(s,c,l) {
	var sl = s.length;
	var cl = c.length;
	while(sl < l) {
		if(l - sl < cl) {
			s += c.substr(0,l - sl);
			sl = l;
		}
		else {
			s += c;
			sl += cl;
		}
	}
	return s;
}
StringTools.lpad = function(s,c,l) {
	var ns = "";
	var sl = s.length;
	if(sl >= l) return s;
	var cl = c.length;
	while(sl < l) {
		if(l - sl < cl) {
			ns += c.substr(0,l - sl);
			sl = l;
		}
		else {
			ns += c;
			sl += cl;
		}
	}
	return ns + s;
}
StringTools.replace = function(s,sub,by) {
	return s.split(sub).join(by);
}
StringTools.hex = function(n,digits) {
	var s = "";
	var hexChars = "0123456789ABCDEF";
	do {
		s = hexChars.charAt(n & 15) + s;
		n >>>= 4;
	} while(n > 0);
	if(digits != null) while(s.length < digits) s = "0" + s;
	return s;
}
StringTools.fastCodeAt = function(s,index) {
	return s.cca(index);
}
StringTools.isEOF = function(c) {
	return c != c;
}
StringTools.prototype.__class__ = StringTools;
haxe.Log = function() { }
haxe.Log.__name__ = ["haxe","Log"];
haxe.Log.trace = function(v,infos) {
	js.Boot.__trace(v,infos);
}
haxe.Log.clear = function() {
	js.Boot.__clear_trace();
}
haxe.Log.prototype.__class__ = haxe.Log;
if(typeof sws=='undefined') sws = {}
sws.SWSOutput = function() { }
sws.SWSOutput.__name__ = ["sws","SWSOutput"];
sws.SWSOutput.prototype.writeString = null;
sws.SWSOutput.prototype.close = null;
sws.SWSOutput.prototype.__class__ = sws.SWSOutput;
StringBuf = function(p) { if( p === $_ ) return; {
	this.b = new Array();
}}
StringBuf.__name__ = ["StringBuf"];
StringBuf.prototype.add = function(x) {
	this.b[this.b.length] = x;
}
StringBuf.prototype.addSub = function(s,pos,len) {
	this.b[this.b.length] = s.substr(pos,len);
}
StringBuf.prototype.addChar = function(c) {
	this.b[this.b.length] = String.fromCharCode(c);
}
StringBuf.prototype.toString = function() {
	return this.b.join("");
}
StringBuf.prototype.b = null;
StringBuf.prototype.__class__ = StringBuf;
haxe.Int32 = function() { }
haxe.Int32.__name__ = ["haxe","Int32"];
haxe.Int32.make = function(a,b) {
	return a << 16 | b;
}
haxe.Int32.ofInt = function(x) {
	return x;
}
haxe.Int32.toInt = function(x) {
	if((x >> 30 & 1) != x >>> 31) throw "Overflow " + x;
	return x & -1;
}
haxe.Int32.toNativeInt = function(x) {
	return x;
}
haxe.Int32.add = function(a,b) {
	return a + b;
}
haxe.Int32.sub = function(a,b) {
	return a - b;
}
haxe.Int32.mul = function(a,b) {
	return a * b;
}
haxe.Int32.div = function(a,b) {
	return Std["int"](a / b);
}
haxe.Int32.mod = function(a,b) {
	return a % b;
}
haxe.Int32.shl = function(a,b) {
	return a << b;
}
haxe.Int32.shr = function(a,b) {
	return a >> b;
}
haxe.Int32.ushr = function(a,b) {
	return a >>> b;
}
haxe.Int32.and = function(a,b) {
	return a & b;
}
haxe.Int32.or = function(a,b) {
	return a | b;
}
haxe.Int32.xor = function(a,b) {
	return a ^ b;
}
haxe.Int32.neg = function(a) {
	return -a;
}
haxe.Int32.complement = function(a) {
	return ~a;
}
haxe.Int32.compare = function(a,b) {
	return a - b;
}
haxe.Int32.prototype.__class__ = haxe.Int32;
EReg = function(r,opt) { if( r === $_ ) return; {
	opt = opt.split("u").join("");
	this.r = new RegExp(r,opt);
}}
EReg.__name__ = ["EReg"];
EReg.prototype.r = null;
EReg.prototype.match = function(s) {
	this.r.m = this.r.exec(s);
	this.r.s = s;
	this.r.l = RegExp.leftContext;
	this.r.r = RegExp.rightContext;
	return this.r.m != null;
}
EReg.prototype.matched = function(n) {
	return this.r.m != null && n >= 0 && n < this.r.m.length?this.r.m[n]:(function($this) {
		var $r;
		throw "EReg::matched";
		return $r;
	}(this));
}
EReg.prototype.matchedLeft = function() {
	if(this.r.m == null) throw "No string matched";
	if(this.r.l == null) return this.r.s.substr(0,this.r.m.index);
	return this.r.l;
}
EReg.prototype.matchedRight = function() {
	if(this.r.m == null) throw "No string matched";
	if(this.r.r == null) {
		var sz = this.r.m.index + this.r.m[0].length;
		return this.r.s.substr(sz,this.r.s.length - sz);
	}
	return this.r.r;
}
EReg.prototype.matchedPos = function() {
	if(this.r.m == null) throw "No string matched";
	return { pos : this.r.m.index, len : this.r.m[0].length};
}
EReg.prototype.split = function(s) {
	var d = "#__delim__#";
	return s.replace(this.r,d).split(d);
}
EReg.prototype.replace = function(s,by) {
	return s.replace(this.r,by);
}
EReg.prototype.customReplace = function(s,f) {
	var buf = new StringBuf();
	while(true) {
		if(!this.match(s)) break;
		buf.b[buf.b.length] = this.matchedLeft();
		buf.b[buf.b.length] = f(this);
		s = this.matchedRight();
	}
	buf.b[buf.b.length] = s;
	return buf.b.join("");
}
EReg.prototype.__class__ = EReg;
sws.Options = function(p) { if( p === $_ ) return; {
	null;
}}
sws.Options.__name__ = ["sws","Options"];
sws.Options.prototype.debugging = null;
sws.Options.prototype.javaStyleCurlies = null;
sws.Options.prototype.addRemoveSemicolons = null;
sws.Options.prototype.doNotCurlMultiLineParentheses = null;
sws.Options.prototype.useCoffeeFunctions = null;
sws.Options.prototype.unwrapParenthesesForCommands = null;
sws.Options.prototype.continuationKeywords = null;
sws.Options.prototype.mayPrecedeOneLineIndent = null;
sws.Options.prototype.blockLeadSymbol = null;
sws.Options.prototype.blockLeadSymbolIndicatedRE = null;
sws.Options.prototype.blockLeadSymbolContraIndicatedRE = null;
sws.Options.prototype.blockLeadSymbolContraIndicatedRE2AnonymousFunctions = null;
sws.Options.prototype.leadLinesRequiringSemicolonEnd = null;
sws.Options.prototype.newline = null;
sws.Options.prototype.onlyWrapParensAtBlockStart = null;
sws.Options.prototype.guessEndGaps = null;
sws.Options.prototype.fixIndent = null;
sws.Options.prototype.joinMixedIndentLinesToLast = null;
sws.Options.prototype.addRemoveCurlies = null;
sws.Options.prototype.trackSlashStarCommentBlocks = null;
sws.Options.prototype.retainLineNumbers = null;
sws.Options.prototype.__class__ = sws.Options;
sws.SWSInput = function() { }
sws.SWSInput.__name__ = ["sws","SWSInput"];
sws.SWSInput.prototype.readLine = null;
sws.SWSInput.prototype.__class__ = sws.SWSInput;
sws.SWSStringInput = function(input) { if( input === $_ ) return; {
	this.lines = input.split("\n");
}}
sws.SWSStringInput.__name__ = ["sws","SWSStringInput"];
sws.SWSStringInput.prototype.lines = null;
sws.SWSStringInput.prototype.readLine = function() {
	if(this.lines.length > 0) {
		var line = this.lines.shift();
		if(line.charAt(line.length - 1) == "\r") {
			line = line.substr(0,line.length - 1);
		}
		return line;
	}
	else {
		throw "End of stringfile";
	}
	return null;
}
sws.SWSStringInput.prototype.__class__ = sws.SWSStringInput;
sws.SWSStringInput.__interfaces__ = [sws.SWSInput];
haxe.io.Output = function() { }
haxe.io.Output.__name__ = ["haxe","io","Output"];
haxe.io.Output.prototype.bigEndian = null;
haxe.io.Output.prototype.writeByte = function(c) {
	throw "Not implemented";
}
haxe.io.Output.prototype.writeBytes = function(s,pos,len) {
	var k = len;
	var b = s.b;
	if(pos < 0 || len < 0 || pos + len > s.length) throw haxe.io.Error.OutsideBounds;
	while(k > 0) {
		this.writeByte(b[pos]);
		pos++;
		k--;
	}
	return len;
}
haxe.io.Output.prototype.flush = function() {
	null;
}
haxe.io.Output.prototype.close = function() {
	null;
}
haxe.io.Output.prototype.setEndian = function(b) {
	this.bigEndian = b;
	return b;
}
haxe.io.Output.prototype.write = function(s) {
	var l = s.length;
	var p = 0;
	while(l > 0) {
		var k = this.writeBytes(s,p,l);
		if(k == 0) throw haxe.io.Error.Blocked;
		p += k;
		l -= k;
	}
}
haxe.io.Output.prototype.writeFullBytes = function(s,pos,len) {
	while(len > 0) {
		var k = this.writeBytes(s,pos,len);
		pos += k;
		len -= k;
	}
}
haxe.io.Output.prototype.writeFloat = function(x) {
	throw "Not implemented";
}
haxe.io.Output.prototype.writeDouble = function(x) {
	throw "Not implemented";
}
haxe.io.Output.prototype.writeInt8 = function(x) {
	if(x < -128 || x >= 128) throw haxe.io.Error.Overflow;
	this.writeByte(x & 255);
}
haxe.io.Output.prototype.writeInt16 = function(x) {
	if(x < -32768 || x >= 32768) throw haxe.io.Error.Overflow;
	this.writeUInt16(x & 65535);
}
haxe.io.Output.prototype.writeUInt16 = function(x) {
	if(x < 0 || x >= 65536) throw haxe.io.Error.Overflow;
	if(this.bigEndian) {
		this.writeByte(x >> 8);
		this.writeByte(x & 255);
	}
	else {
		this.writeByte(x & 255);
		this.writeByte(x >> 8);
	}
}
haxe.io.Output.prototype.writeInt24 = function(x) {
	if(x < -8388608 || x >= 8388608) throw haxe.io.Error.Overflow;
	this.writeUInt24(x & 16777215);
}
haxe.io.Output.prototype.writeUInt24 = function(x) {
	if(x < 0 || x >= 16777216) throw haxe.io.Error.Overflow;
	if(this.bigEndian) {
		this.writeByte(x >> 16);
		this.writeByte(x >> 8 & 255);
		this.writeByte(x & 255);
	}
	else {
		this.writeByte(x & 255);
		this.writeByte(x >> 8 & 255);
		this.writeByte(x >> 16);
	}
}
haxe.io.Output.prototype.writeInt31 = function(x) {
	if(x < -1073741824 || x >= 1073741824) throw haxe.io.Error.Overflow;
	if(this.bigEndian) {
		this.writeByte(x >>> 24);
		this.writeByte(x >> 16 & 255);
		this.writeByte(x >> 8 & 255);
		this.writeByte(x & 255);
	}
	else {
		this.writeByte(x & 255);
		this.writeByte(x >> 8 & 255);
		this.writeByte(x >> 16 & 255);
		this.writeByte(x >>> 24);
	}
}
haxe.io.Output.prototype.writeUInt30 = function(x) {
	if(x < 0 || x >= 1073741824) throw haxe.io.Error.Overflow;
	if(this.bigEndian) {
		this.writeByte(x >>> 24);
		this.writeByte(x >> 16 & 255);
		this.writeByte(x >> 8 & 255);
		this.writeByte(x & 255);
	}
	else {
		this.writeByte(x & 255);
		this.writeByte(x >> 8 & 255);
		this.writeByte(x >> 16 & 255);
		this.writeByte(x >>> 24);
	}
}
haxe.io.Output.prototype.writeInt32 = function(x) {
	if(this.bigEndian) {
		this.writeByte(haxe.Int32.toInt(x >>> 24));
		this.writeByte(haxe.Int32.toInt(x >>> 16) & 255);
		this.writeByte(haxe.Int32.toInt(x >>> 8) & 255);
		this.writeByte(haxe.Int32.toInt(x & 255));
	}
	else {
		this.writeByte(haxe.Int32.toInt(x & 255));
		this.writeByte(haxe.Int32.toInt(x >>> 8) & 255);
		this.writeByte(haxe.Int32.toInt(x >>> 16) & 255);
		this.writeByte(haxe.Int32.toInt(x >>> 24));
	}
}
haxe.io.Output.prototype.prepare = function(nbytes) {
	null;
}
haxe.io.Output.prototype.writeInput = function(i,bufsize) {
	if(bufsize == null) bufsize = 4096;
	var buf = haxe.io.Bytes.alloc(bufsize);
	try {
		while(true) {
			var len = i.readBytes(buf,0,bufsize);
			if(len == 0) throw haxe.io.Error.Blocked;
			var p = 0;
			while(len > 0) {
				var k = this.writeBytes(buf,p,len);
				if(k == 0) throw haxe.io.Error.Blocked;
				p += k;
				len -= k;
			}
		}
	}
	catch( $e0 ) {
		if( js.Boot.__instanceof($e0,haxe.io.Eof) ) {
			var e = $e0;
			null;
		} else throw($e0);
	}
}
haxe.io.Output.prototype.writeString = function(s) {
	var b = haxe.io.Bytes.ofString(s);
	this.writeFullBytes(b,0,b.length);
}
haxe.io.Output.prototype.__class__ = haxe.io.Output;
haxe.io.Bytes = function(length,b) { if( length === $_ ) return; {
	this.length = length;
	this.b = b;
}}
haxe.io.Bytes.__name__ = ["haxe","io","Bytes"];
haxe.io.Bytes.alloc = function(length) {
	var a = new Array();
	{
		var _g = 0;
		while(_g < length) {
			var i = _g++;
			a.push(0);
		}
	}
	return new haxe.io.Bytes(length,a);
}
haxe.io.Bytes.ofString = function(s) {
	var a = new Array();
	{
		var _g1 = 0, _g = s.length;
		while(_g1 < _g) {
			var i = _g1++;
			var c = s.cca(i);
			if(c <= 127) a.push(c);
			else if(c <= 2047) {
				a.push(192 | c >> 6);
				a.push(128 | c & 63);
			}
			else if(c <= 65535) {
				a.push(224 | c >> 12);
				a.push(128 | c >> 6 & 63);
				a.push(128 | c & 63);
			}
			else {
				a.push(240 | c >> 18);
				a.push(128 | c >> 12 & 63);
				a.push(128 | c >> 6 & 63);
				a.push(128 | c & 63);
			}
		}
	}
	return new haxe.io.Bytes(a.length,a);
}
haxe.io.Bytes.ofData = function(b) {
	return new haxe.io.Bytes(b.length,b);
}
haxe.io.Bytes.prototype.length = null;
haxe.io.Bytes.prototype.b = null;
haxe.io.Bytes.prototype.get = function(pos) {
	return this.b[pos];
}
haxe.io.Bytes.prototype.set = function(pos,v) {
	this.b[pos] = v & 255;
}
haxe.io.Bytes.prototype.blit = function(pos,src,srcpos,len) {
	if(pos < 0 || srcpos < 0 || len < 0 || pos + len > this.length || srcpos + len > src.length) throw haxe.io.Error.OutsideBounds;
	var b1 = this.b;
	var b2 = src.b;
	if(b1 == b2 && pos > srcpos) {
		var i = len;
		while(i > 0) {
			i--;
			b1[i + pos] = b2[i + srcpos];
		}
		return;
	}
	{
		var _g = 0;
		while(_g < len) {
			var i = _g++;
			b1[i + pos] = b2[i + srcpos];
		}
	}
}
haxe.io.Bytes.prototype.sub = function(pos,len) {
	if(pos < 0 || len < 0 || pos + len > this.length) throw haxe.io.Error.OutsideBounds;
	return new haxe.io.Bytes(len,this.b.slice(pos,pos + len));
}
haxe.io.Bytes.prototype.compare = function(other) {
	var b1 = this.b;
	var b2 = other.b;
	var len = this.length < other.length?this.length:other.length;
	{
		var _g = 0;
		while(_g < len) {
			var i = _g++;
			if(b1[i] != b2[i]) return b1[i] - b2[i];
		}
	}
	return this.length - other.length;
}
haxe.io.Bytes.prototype.readString = function(pos,len) {
	if(pos < 0 || len < 0 || pos + len > this.length) throw haxe.io.Error.OutsideBounds;
	var s = "";
	var b = this.b;
	var fcc = $closure(String,"fromCharCode");
	var i = pos;
	var max = pos + len;
	while(i < max) {
		var c = b[i++];
		if(c < 128) {
			if(c == 0) break;
			s += fcc(c);
		}
		else if(c < 224) s += fcc((c & 63) << 6 | b[i++] & 127);
		else if(c < 240) {
			var c2 = b[i++];
			s += fcc((c & 31) << 12 | (c2 & 127) << 6 | b[i++] & 127);
		}
		else {
			var c2 = b[i++];
			var c3 = b[i++];
			s += fcc((c & 15) << 18 | (c2 & 127) << 12 | c3 << 6 & 127 | b[i++] & 127);
		}
	}
	return s;
}
haxe.io.Bytes.prototype.toString = function() {
	return this.readString(0,this.length);
}
haxe.io.Bytes.prototype.getData = function() {
	return this.b;
}
haxe.io.Bytes.prototype.__class__ = haxe.io.Bytes;
IntIter = function(min,max) { if( min === $_ ) return; {
	this.min = min;
	this.max = max;
}}
IntIter.__name__ = ["IntIter"];
IntIter.prototype.min = null;
IntIter.prototype.max = null;
IntIter.prototype.hasNext = function() {
	return this.min < this.max;
}
IntIter.prototype.next = function() {
	return this.min++;
}
IntIter.prototype.__class__ = IntIter;
haxe.io.Error = { __ename__ : ["haxe","io","Error"], __constructs__ : ["Blocked","Overflow","OutsideBounds","Custom"] }
haxe.io.Error.Blocked = ["Blocked",0];
haxe.io.Error.Blocked.toString = $estr;
haxe.io.Error.Blocked.__enum__ = haxe.io.Error;
haxe.io.Error.Overflow = ["Overflow",1];
haxe.io.Error.Overflow.toString = $estr;
haxe.io.Error.Overflow.__enum__ = haxe.io.Error;
haxe.io.Error.OutsideBounds = ["OutsideBounds",2];
haxe.io.Error.OutsideBounds.toString = $estr;
haxe.io.Error.OutsideBounds.__enum__ = haxe.io.Error;
haxe.io.Error.Custom = function(e) { var $x = ["Custom",3,e]; $x.__enum__ = haxe.io.Error; $x.toString = $estr; return $x; }
sws.Heuristics = function() { }
sws.Heuristics.__name__ = ["sws","Heuristics"];
sws.Heuristics.prototype.__class__ = sws.Heuristics;
sws.SWS = function(_options,out) { if( _options === $_ ) return; {
	this.options = _options != null?_options:sws.Options.defaultOptions;
	this.reporter = new sws.OptionalReporter(out,this.options);
}}
sws.SWS.__name__ = ["sws","SWS"];
sws.SWS.main = function() {
	null;
}
sws.SWS.getFirstWord = function(line) {
	if(sws.SWS.firstTokenRE.match(line)) {
		return sws.SWS.firstTokenRE.matched(1);
	}
	else {
		return "";
	}
}
sws.SWS.countIndent = function(indentString,line) {
	if(indentString == null || line == null) {
		return 0;
	}
	var i, j, count;
	i = 0;
	j = 0;
	count = 0;
	while(true) {
		if(line.charAt(i) == indentString.charAt(j)) {
			i++;
			if(i >= line.length) {
				break;
			}
			j++;
			if(j >= indentString.length) {
				j = 0;
				count++;
			}
		}
		else {
			break;
		}
	}
	return count;
}
sws.SWS.repeatString = function(count,str) {
	var sb = new StringBuf();
	{
		var _g = 0;
		while(_g < count) {
			var i = _g++;
			sb.b[sb.b.length] = str;
		}
	}
	return sb.b.join("");
}
sws.SWS.prototype.options = null;
sws.SWS.prototype.reporter = null;
sws.SWS.prototype.decurl = function(input,output) {
	var endsWithOpeningCurly = new EReg("\\s*{\\s*$","");
	var startsWithClosingCurly = new EReg("^\\s*}\\s*","");
	var startsWithCurlyReplacer = new EReg("}\\s*","");
	var endsWithSemicolon = new EReg("\\s*;\\s*$","");
	var reader = new sws.SuperDuperReader(input,this);
	var out = new sws.Outputter(output,this.options);
	var indentCountAtLineEnd = 0;
	try {
		while(true) {
			var indentCountAtLineStart = indentCountAtLineEnd;
			var wasInsideComment = reader.insideComment;
			var wholeLine = reader.getNextLine();
			if(wholeLine == null) {
				break;
			}
			var res = this.splitLineAtComment(wholeLine);
			var line = res[0];
			var trailingComment = res[1];
			var wholeLineIsComment = sws.SWS.wholeLineIsCommentRE.match(line);
			if(!wholeLineIsComment && !wasInsideComment) {
				if(startsWithClosingCurly.match(line)) {
					if(new EReg("^\\s*}\\s*;\\s*$","").match(line)) {
						this.reporter.error("We do not currently support \"...};\" end-lines, try wrapping into \"(...});\".  " + line);
					}
					line = startsWithCurlyReplacer.replace(line,"");
					indentCountAtLineStart--;
					indentCountAtLineEnd--;
					if(sws.SWS.emptyOrBlank.match(line + trailingComment)) {
						continue;
					}
				}
				if(endsWithOpeningCurly.match(line)) {
					indentCountAtLineEnd++;
					line = endsWithOpeningCurly.replace(line,"");
					if(this.options.blockLeadSymbol != null && !sws.SWS.emptyOrBlank.match(line)) {
						var indicated = this.options.blockLeadSymbolIndicatedRE != null && this.options.blockLeadSymbolIndicatedRE.match(line);
						var contraIndicated = this.options.blockLeadSymbolContraIndicatedRE != null && this.options.blockLeadSymbolContraIndicatedRE.match(line);
						if(this.options.blockLeadSymbolContraIndicatedRE2AnonymousFunctions.match(line)) {
							contraIndicated = true;
						}
						if(!indicated && !contraIndicated) {
							this.reporter.debug("blockLeadSymbol neither indicated or contra-indicated for: " + line);
						}
						if(indicated) {
							line += this.options.blockLeadSymbol;
						}
					}
					if(sws.SWS.emptyOrBlank.match(line + trailingComment)) {
						continue;
					}
				}
				else {
					if(!wholeLineIsComment && !reader.insideComment && !sws.SWS.emptyOrBlank.match(line)) {
						if(this.options.addRemoveSemicolons) {
							if(endsWithSemicolon.match(line)) {
								line = endsWithSemicolon.replace(line,"");
								if(sws.SWS.emptyOrBlank.match(line)) {
									continue;
								}
							}
							else {
								reader.updateIndentInfo(line);
								if(reader.indent_of_nextNonEmptyLine > reader.indent_of_currentLine) {
									if(this.options.joinMixedIndentLinesToLast && new EReg("^\t* +","").match(reader.nextNonEmptyLine)) {
										line += " \\";
									}
									else {
										var firstToken = sws.SWS.getFirstWord(line);
										if(!Lambda.has(this.options.mayPrecedeOneLineIndent,firstToken)) {
											this.reporter.warn("The lines following this are indented, but do not have curlies, and may gain them! " + line);
										}
									}
								}
								else {
									var nextLineIsCurl = false;
									var nextLine = reader.peekLine(1);
									if(nextLine != null && new EReg("^\\s*{\\s*$","").match(nextLine)) {
										nextLineIsCurl = true;
									}
									if(!sws.Heuristics.endsWithComma.match(line) && !nextLineIsCurl) {
										line += " \\";
									}
								}
							}
						}
					}
				}
				if(this.options.useCoffeeFunctions) {
					if(sws.SWS.anonymousFunctionRE.match(line)) {
						line = sws.SWS.anonymousFunctionRE.replace(line,sws.SWS.anonymousFunctionReplace);
					}
				}
				if(this.options.unwrapParenthesesForCommands != null) {
					var firstToken = sws.SWS.getFirstWord(line);
					if(Lambda.has(this.options.unwrapParenthesesForCommands,firstToken)) {
						var res1 = this.splitLineAtComment(line);
						var beforeComment = res1[0];
						var afterComment = res1[1];
						var replacementRE = new EReg(firstToken + "\\s*[(](.*)[)]\\s*$","");
						beforeComment = replacementRE.replace(beforeComment,firstToken + " $1");
						line = beforeComment + afterComment;
					}
				}
			}
			wholeLine = line + trailingComment;
			if(this.options.fixIndent && !reader.insideComment && !wasInsideComment) {
				if(sws.SWS.emptyOrBlank.match(wholeLine)) {
					wholeLine = "";
				}
				else {
					var fixedIndentStr = sws.SWS.repeatString(indentCountAtLineStart,"\t");
					wholeLine = fixedIndentStr + sws.SWS.indentRE.replace(wholeLine,"");
				}
			}
			out.writeLine(wholeLine);
		}
	}
	catch( $e0 ) {
		{
			var ex = $e0;
			null;
		}
	}
	out.close();
}
sws.SWS.prototype.curl = function(input,output) {
	var currentLine;
	var helper = new sws.SuperDuperReader(input,this);
	var currentLine1;
	var indentString = null;
	var currentIndent = 0;
	var out = new sws.Outputter(output,this.options);
	var openingLines = new sws.LineStack();
	while(true) {
		var wasInsideComment = helper.insideComment;
		currentLine1 = helper.getNextLine();
		if(currentLine1 == null) {
			break;
		}
		var isInsideBrackets = helper.depthInsideParentheses > 0;
		if(wasInsideComment || isInsideBrackets && this.options.doNotCurlMultiLineParentheses) {
			out.writeLine(currentLine1);
			continue;
		}
		if(!sws.SWS.emptyOrBlank.match(currentLine1)) {
			currentIndent = sws.SWS.countIndent(indentString,currentLine1);
		}
		var nextNonEmptyLine;
		nextNonEmptyLine = helper.getNextNonEmptyLine();
		if(indentString == null && nextNonEmptyLine != null && !helper.insideComment) {
			sws.SWS.indentRE.match(nextNonEmptyLine);
			var indentPart = sws.SWS.indentRE.matched(0);
			if(indentPart != "") {
				indentString = indentPart;
				this.reporter.debug("Found first indent, length " + indentString.length);
			}
		}
		var indent_of_nextNonEmptyLine = sws.SWS.countIndent(indentString,nextNonEmptyLine);
		var wholeLineIsComment = sws.SWS.wholeLineIsCommentRE.match(currentLine1);
		if(wholeLineIsComment) {
			var lineLikelyToBeRegexpDefinition = sws.SWS.looksLikeRegexpLine.match(currentLine1);
			if(lineLikelyToBeRegexpDefinition) {
				wholeLineIsComment = false;
			}
		}
		if(this.options.useCoffeeFunctions) {
			if(sws.SWS.anonymousCoffeeFunctionRE.match(currentLine1)) {
				currentLine1 = sws.SWS.anonymousCoffeeFunctionRE.replace(currentLine1,sws.SWS.anonymousCoffeeFunctionReplace);
			}
		}
		if(!this.options.onlyWrapParensAtBlockStart) {
			currentLine1 = this.wrapParens(currentLine1);
		}
		if(!helper.insideComment && indent_of_nextNonEmptyLine > currentIndent) {
			if(this.options.onlyWrapParensAtBlockStart) {
				currentLine1 = this.wrapParens(currentLine1);
			}
			if(indent_of_nextNonEmptyLine > currentIndent + 1) {
				this.reporter.error("Unexpected double indent on: " + nextNonEmptyLine);
			}
			if(this.options.blockLeadSymbol != null) {
				var res = this.splitLineAtComment(currentLine1);
				var beforeComment = res[0];
				var afterComment = res[1];
				var i = beforeComment.lastIndexOf(this.options.blockLeadSymbol);
				if(i >= 0) {
					var beforeSymbol = beforeComment.substr(0,i);
					var afterSymbol = beforeComment.substr(i + this.options.blockLeadSymbol.length);
					if(sws.SWS.emptyOrBlank.match(afterSymbol)) {
						beforeComment = beforeSymbol + afterSymbol;
						currentLine1 = beforeComment + afterComment;
					}
				}
			}
			if(this.options.javaStyleCurlies) {
				out.writeLine(this.appendToLine(currentLine1," {"));
			}
			else {
				out.writeLine(currentLine1);
				out.writeLine(sws.SWS.repeatString(currentIndent,indentString) + "{");
			}
			currentIndent++;
			openingLines.push(new sws.LineRecord(0,currentLine1));
			continue;
		}
		if(!helper.insideComment && indent_of_nextNonEmptyLine < currentIndent) {
			currentLine1 = this.considerSemicolonInjection(currentLine1,this.options,wholeLineIsComment);
			out.writeLine(currentLine1);
			var delayLastCurly = null;
			if(nextNonEmptyLine != null) {
				var firstToken = sws.SWS.getFirstWord(nextNonEmptyLine);
				if(Lambda.has(this.options.continuationKeywords,firstToken)) {
					delayLastCurly = " ";
				}
				if(firstToken.charAt(0) == ")" || firstToken.charAt(0) == ",") {
					delayLastCurly = "";
				}
			}
			var i = currentIndent - 1;
			while(i >= indent_of_nextNonEmptyLine) {
				var lineWeStartedOn = openingLines.pop().line;
				var indentAtThisLevel = sws.SWS.repeatString(i,indentString);
				if(delayLastCurly != null && i == indent_of_nextNonEmptyLine) {
					var nextLine = null;
					while(true) {
						nextLine = helper.getNextLine();
						if(sws.SWS.emptyOrBlank.match(nextLine)) {
							out.writeLine(nextLine);
						}
						else {
							break;
						}
					}
					var updatedLine;
					if(this.options.javaStyleCurlies) {
						nextLine = this.wrapParens(nextLine);
						updatedLine = indentAtThisLevel + "}" + delayLastCurly + sws.Heuristics.leadingIndentRE.replace(nextLine,"");
					}
					else {
						out.writeLine(indentAtThisLevel + "}");
						updatedLine = nextLine;
					}
					helper.pushBackLine(updatedLine);
					break;
				}
				else {
					if(this.options.guessEndGaps) {
						var spaceCurly = true;
						var indentsToGo = i - indent_of_nextNonEmptyLine + 1;
						var numEmptyLinesRequired = indentsToGo + 1;
						if(delayLastCurly != null) {
							numEmptyLinesRequired--;
						}
						{
							var _g = 0;
							while(_g < numEmptyLinesRequired) {
								var j = _g++;
								var peekLine = helper.peekLine(j + 1);
								if(peekLine == null) {
									if(j < numEmptyLinesRequired - 1) {
										spaceCurly = false;
									}
									break;
								}
								else if(!sws.SWS.emptyOrBlank.match(peekLine)) {
									spaceCurly = false;
									break;
								}
							}
						}
						if(spaceCurly) {
							var nextLine = helper.getNextLine();
							out.writeLine(nextLine);
						}
					}
					if(this.options.leadLinesRequiringSemicolonEnd != null && this.options.leadLinesRequiringSemicolonEnd.match(lineWeStartedOn)) {
						out.writeLine(indentAtThisLevel + "};");
					}
					else {
						out.writeLine(indentAtThisLevel + "}");
					}
				}
				i--;
			}
			currentIndent = indent_of_nextNonEmptyLine;
			if(delayLastCurly != null) null;
			continue;
		}
		currentLine1 = this.considerSemicolonInjection(currentLine1,this.options,wholeLineIsComment);
		out.writeLine(currentLine1);
	}
	out.close();
}
sws.SWS.prototype.considerSemicolonInjection = function(currentLine,options,wholeLineIsComment) {
	if(options.addRemoveSemicolons && !wholeLineIsComment && !sws.SWS.emptyOrBlank.match(currentLine)) {
		if(sws.Heuristics.endsWithComma.match(currentLine)) {
			return currentLine;
		}
		else {
			if(sws.Heuristics.looksLikePreproc.match(currentLine)) {
				return currentLine;
			}
			else {
				if(sws.Heuristics.endsWithBackslash.match(currentLine)) {
					return sws.Heuristics.endsWithBackslash.replace(currentLine,"");
				}
				else {
					return this.appendToLine(currentLine,";");
				}
			}
		}
	}
	return currentLine;
}
sws.SWS.prototype.wrapParens = function(currentLine) {
	if(this.options.unwrapParenthesesForCommands != null) {
		var firstToken = sws.SWS.getFirstWord(currentLine);
		if(Lambda.has(this.options.unwrapParenthesesForCommands,firstToken)) {
			var res = this.splitLineAtComment(currentLine);
			var beforeComment = res[0];
			var afterComment = res[1];
			var replacementRE = new EReg(firstToken + "\\s","");
			beforeComment = replacementRE.replace(beforeComment,firstToken + " (") + ")";
			currentLine = beforeComment + afterComment;
		}
	}
	return currentLine;
}
sws.SWS.prototype.appendToLine = function(line,toAppend) {
	var res = this.splitLineAtComment(line);
	var beforeComment = res[0];
	var afterComment = res[1];
	return beforeComment + toAppend + afterComment;
}
sws.SWS.prototype.splitLineAtComment = function(line) {
	var hasTrailingComment = sws.SWS.trailingCommentOutsideQuotes.match(line) && sws.SWS.trailingCommentOutsideApostrophes.match(line);
	if(!hasTrailingComment) {
		return [line,""];
	}
	else {
		if(sws.SWS.trailingCommentOutsideQuotes.matched(1) != sws.SWS.trailingCommentOutsideApostrophes.matched(1)) {
			this.reporter.warn("trailingCommentOutsideQuotes and trailingCommentOutsideApostrophes could not agree where the comment boundary is: " + line);
			this.reporter.warn("  trailingCommentOutsideQuotes.matched(1) = " + sws.SWS.trailingCommentOutsideQuotes.matched(1));
			this.reporter.warn("  trailingCommentOutsideApostrophes.matched(1) = " + sws.SWS.trailingCommentOutsideApostrophes.matched(1));
			return [line,""];
		}
		if(sws.SWS.looksLikeRegexpLine.match(line)) {
			this.reporter.debug("could be a comment line but could equally be a regexp literal!  " + line);
			return [line,""];
		}
		try {
			if(sws.SWS.couldbeRegexpEndingSlashSlash.match(line)) {
				this.reporter.debug("could be a // comment but probably actually a regexp!  " + line);
				return [line,""];
			}
		}
		catch( $e0 ) {
			{
				var ex = $e0;
				{
					this.reporter.warn("Exception applying couldbeRegexpEndingSlashSlash: \"" + ex + "\" on line: " + line);
				}
			}
		}
		var beforeComment = sws.SWS.trailingCommentOutsideQuotes.matched(1);
		var afterComment = sws.SWS.trailingCommentOutsideQuotes.matched(4);
		var trailingSpaces = new EReg("\\s*$","");
		if(trailingSpaces.match(beforeComment)) {
			afterComment = trailingSpaces.matched(0) + afterComment;
			beforeComment = trailingSpaces.replace(beforeComment,"");
		}
		return [beforeComment,afterComment];
	}
}
sws.SWS.prototype.echo = function(str) {
	this.reporter.echo("[Rest] " + str);
}
sws.SWS.prototype.__class__ = sws.SWS;
sws.HelpfulReader = function(_input) { if( _input === $_ ) return; {
	this.input = _input;
	this.queue = new Array();
}}
sws.HelpfulReader.__name__ = ["sws","HelpfulReader"];
sws.HelpfulReader.prototype.input = null;
sws.HelpfulReader.prototype.queue = null;
sws.HelpfulReader.prototype.getNextLine = function() {
	if(this.queue.length > 0) {
		return this.queue.shift();
	}
	try {
		return this.input.readLine();
	}
	catch( $e0 ) {
		{
			var ex = $e0;
			{
				return null;
			}
		}
	}
}
sws.HelpfulReader.prototype.pushBackLine = function(line) {
	this.queue.unshift(line);
}
sws.HelpfulReader.prototype.peekLine = function(i) {
	while(this.queue.length < i) {
		try {
			var nextLine = this.input.readLine();
			this.queue.push(nextLine);
		}
		catch( $e0 ) {
			{
				var ex = $e0;
				{
					return null;
				}
			}
		}
	}
	return this.queue[i - 1];
}
sws.HelpfulReader.prototype.findNextNonEmptyLine = function() {
	var i;
	{
		var _g1 = 0, _g = this.queue.length;
		while(_g1 < _g) {
			var i1 = _g1++;
			if(!sws.SWS.emptyOrBlank.match(this.queue[i1])) {
				return this.queue[i1];
			}
		}
	}
	while(true) {
		try {
			var line = this.input.readLine();
			this.queue.push(line);
			if(!sws.SWS.emptyOrBlank.match(line)) {
				return line;
			}
		}
		catch( $e0 ) {
			{
				var ex = $e0;
				{
					break;
				}
			}
		}
	}
	return null;
}
sws.HelpfulReader.prototype.__class__ = sws.HelpfulReader;
sws.Reporter = function(_out) { if( _out === $_ ) return; {
	this.out = _out;
}}
sws.Reporter.__name__ = ["sws","Reporter"];
sws.Reporter.prototype.out = null;
sws.Reporter.prototype.echo = function(s) {
	if(this.out == null) {
		haxe.Log.trace(s,{ fileName : "SWS.hx", lineNumber : 837, className : "sws.Reporter", methodName : "echo"});
	}
	else {
		this.out.writeString(s + "\n");
	}
}
sws.Reporter.prototype.debug = function(s) {
	this.echo("[Debug] " + s);
}
sws.Reporter.prototype.info = function(s) {
	this.echo("[Info] " + s);
}
sws.Reporter.prototype.warn = function(s) {
	this.echo("[Warning] " + s);
}
sws.Reporter.prototype.error = function(s) {
	this.echo("[Error] " + s);
}
sws.Reporter.prototype.__class__ = sws.Reporter;
sws.OptionalReporter = function(out,_options) { if( out === $_ ) return; {
	sws.Reporter.call(this,out);
	this.options = _options;
}}
sws.OptionalReporter.__name__ = ["sws","OptionalReporter"];
sws.OptionalReporter.__super__ = sws.Reporter;
for(var k in sws.Reporter.prototype ) sws.OptionalReporter.prototype[k] = sws.Reporter.prototype[k];
sws.OptionalReporter.prototype.options = null;
sws.OptionalReporter.prototype.echo = function(s) {
	if(this.out == null) {
		sws.Reporter.prototype.echo.call(this,s);
	}
	else {
		this.out.writeString(s + this.options.newline);
	}
}
sws.OptionalReporter.prototype.debug = function(s) {
	if(this.options.debugging) {
		this.echo("[Debug] " + s);
	}
}
sws.OptionalReporter.prototype.__class__ = sws.OptionalReporter;
sws.Outputter = function(_output,_options) { if( _output === $_ ) return; {
	this.output = _output;
	this.options = _options;
}}
sws.Outputter.__name__ = ["sws","Outputter"];
sws.Outputter.prototype.output = null;
sws.Outputter.prototype.options = null;
sws.Outputter.prototype.writeLine = function(str) {
	this.output.writeString(str + this.options.newline);
}
sws.Outputter.prototype.close = function() {
	this.output.close();
}
sws.Outputter.prototype.__class__ = sws.Outputter;
sws.CommentTrackingReader = function(input,_sws) { if( input === $_ ) return; {
	sws.HelpfulReader.call(this,input);
	this.sws = _sws;
	this.reporter = this.sws.reporter;
	this.insideComment = false;
	this.depthInsideParentheses = 0;
}}
sws.CommentTrackingReader.__name__ = ["sws","CommentTrackingReader"];
sws.CommentTrackingReader.__super__ = sws.HelpfulReader;
for(var k in sws.HelpfulReader.prototype ) sws.CommentTrackingReader.prototype[k] = sws.HelpfulReader.prototype[k];
sws.CommentTrackingReader.prototype.insideComment = null;
sws.CommentTrackingReader.prototype.depthInsideParentheses = null;
sws.CommentTrackingReader.prototype.sws = null;
sws.CommentTrackingReader.prototype.reporter = null;
sws.CommentTrackingReader.prototype.getNextLine = function() {
	var line = sws.HelpfulReader.prototype.getNextLine.call(this);
	if(line == null) {
		return line;
	}
	var res = this.sws.splitLineAtComment(line);
	var lineBeforeComment = res[0];
	var trailingComment = res[1];
	if(sws.CommentTrackingReader.lineOpensCommentRE.match(line)) {
		var indexOfSingleLineComment = line.indexOf("//");
		var indexOfCommentStart = line.indexOf("/" + "*");
		if(indexOfSingleLineComment != -1 && indexOfSingleLineComment < indexOfCommentStart) {
			this.reporter.echo("Looks like opening comment but *after* one-line comment, so ignoring it: " + line);
		}
		else if(sws.SWS.looksLikeRegexpLine.match(line)) null;
		else {
			this.insideComment = true;
			if(sws.SWS.seemsToContainRegexp.match(lineBeforeComment)) {
				this.reporter.warn("Looks like start of comment block but also like a regexp!  " + line);
			}
		}
	}
	if(sws.CommentTrackingReader.lineClosesCommentRE.match(line)) {
		if(sws.SWS.looksLikeRegexpLine.match(line)) null;
		else {
			this.insideComment = false;
			if(sws.SWS.seemsToContainRegexp.match(lineBeforeComment)) {
				this.reporter.warn("Looks like end of comment block but also like a regexp!  " + line);
			}
		}
	}
	var openBracketCount = this.countInString(lineBeforeComment,40);
	var closeBracketCount = this.countInString(lineBeforeComment,41);
	if(sws.CommentTrackingReader.parenthesisInsideQuotes.match(lineBeforeComment) || sws.CommentTrackingReader.parenthesisInsideApostrophes.match(lineBeforeComment)) {
		if(openBracketCount == closeBracketCount) null;
		else {
			if(this.sws.options.doNotCurlMultiLineParentheses) {
				this.reporter.debug("Ignoring untrustworthy parentheses: " + line);
			}
			else null;
		}
	}
	else {
		this.depthInsideParentheses += openBracketCount - closeBracketCount;
	}
	return line;
}
sws.CommentTrackingReader.prototype.countInString = function(s,c) {
	var count = 0;
	{
		var _g1 = 0, _g = s.length;
		while(_g1 < _g) {
			var i = _g1++;
			if(s.charCodeAt(i) == c) {
				count++;
			}
		}
	}
	return count;
}
sws.CommentTrackingReader.prototype.__class__ = sws.CommentTrackingReader;
sws.SuperDuperReader = function(input,_sws) { if( input === $_ ) return; {
	sws.CommentTrackingReader.call(this,input,_sws);
	this.firstWord = null;
	this.lineThatOpenedIndent = new Array();
}}
sws.SuperDuperReader.__name__ = ["sws","SuperDuperReader"];
sws.SuperDuperReader.__super__ = sws.CommentTrackingReader;
for(var k in sws.CommentTrackingReader.prototype ) sws.SuperDuperReader.prototype[k] = sws.CommentTrackingReader.prototype[k];
sws.SuperDuperReader.prototype.indent_of_currentLine = null;
sws.SuperDuperReader.prototype.nextNonEmptyLine = null;
sws.SuperDuperReader.prototype.indent_of_nextNonEmptyLine = null;
sws.SuperDuperReader.prototype.firstWord = null;
sws.SuperDuperReader.prototype.lineThatOpenedIndent = null;
sws.SuperDuperReader.prototype.getNextNonEmptyLine = function() {
	this.nextNonEmptyLine = this.findNextNonEmptyLine();
	return this.nextNonEmptyLine;
}
sws.SuperDuperReader.prototype.updateIndentInfo = function(currentLine) {
	sws.Heuristics.leadingIndentRE.match(currentLine);
	this.indent_of_currentLine = sws.Heuristics.leadingIndentRE.matched(0).length;
	var nextNonEmptyLine = this.getNextNonEmptyLine();
	if(nextNonEmptyLine == null) {
		nextNonEmptyLine = "";
	}
	sws.Heuristics.leadingIndentRE.match(nextNonEmptyLine);
	this.indent_of_nextNonEmptyLine = sws.Heuristics.leadingIndentRE.matched(0).length;
}
sws.SuperDuperReader.prototype.__class__ = sws.SuperDuperReader;
sws.LineRecord = function(_number,_line) { if( _number === $_ ) return; {
	this.number = _number;
	this.line = _line;
}}
sws.LineRecord.__name__ = ["sws","LineRecord"];
sws.LineRecord.prototype.number = null;
sws.LineRecord.prototype.line = null;
sws.LineRecord.prototype.__class__ = sws.LineRecord;
sws.Stack = function(p) { if( p === $_ ) return; {
	this.items = new Array();
}}
sws.Stack.__name__ = ["sws","Stack"];
sws.Stack.prototype.items = null;
sws.Stack.prototype.push = function(item) {
	this.items.push(item);
}
sws.Stack.prototype.pop = function() {
	return this.items.pop();
}
sws.Stack.prototype.__class__ = sws.Stack;
sws.LineStack = function(p) { if( p === $_ ) return; {
	sws.Stack.call(this);
}}
sws.LineStack.__name__ = ["sws","LineStack"];
sws.LineStack.__super__ = sws.Stack;
for(var k in sws.Stack.prototype ) sws.LineStack.prototype[k] = sws.Stack.prototype[k];
sws.LineStack.prototype.__class__ = sws.LineStack;
Std = function() { }
Std.__name__ = ["Std"];
Std["is"] = function(v,t) {
	return js.Boot.__instanceof(v,t);
}
Std.string = function(s) {
	return js.Boot.__string_rec(s,"");
}
Std["int"] = function(x) {
	if(x < 0) return Math.ceil(x);
	return Math.floor(x);
}
Std.parseInt = function(x) {
	var v = parseInt(x,10);
	if(v == 0 && x.charCodeAt(1) == 120) v = parseInt(x);
	if(isNaN(v)) return null;
	return v;
}
Std.parseFloat = function(x) {
	return parseFloat(x);
}
Std.random = function(x) {
	return Math.floor(Math.random() * x);
}
Std.prototype.__class__ = Std;
Lambda = function() { }
Lambda.__name__ = ["Lambda"];
Lambda.array = function(it) {
	var a = new Array();
	{ var $it0 = it.iterator();
	while( $it0.hasNext() ) { var i = $it0.next();
	a.push(i);
	}}
	return a;
}
Lambda.list = function(it) {
	var l = new List();
	{ var $it0 = it.iterator();
	while( $it0.hasNext() ) { var i = $it0.next();
	l.add(i);
	}}
	return l;
}
Lambda.map = function(it,f) {
	var l = new List();
	{ var $it0 = it.iterator();
	while( $it0.hasNext() ) { var x = $it0.next();
	l.add(f(x));
	}}
	return l;
}
Lambda.mapi = function(it,f) {
	var l = new List();
	var i = 0;
	{ var $it0 = it.iterator();
	while( $it0.hasNext() ) { var x = $it0.next();
	l.add(f(i++,x));
	}}
	return l;
}
Lambda.has = function(it,elt,cmp) {
	if(cmp == null) {
		{ var $it0 = it.iterator();
		while( $it0.hasNext() ) { var x = $it0.next();
		if(x == elt) return true;
		}}
	}
	else {
		{ var $it1 = it.iterator();
		while( $it1.hasNext() ) { var x = $it1.next();
		if(cmp(x,elt)) return true;
		}}
	}
	return false;
}
Lambda.exists = function(it,f) {
	{ var $it0 = it.iterator();
	while( $it0.hasNext() ) { var x = $it0.next();
	if(f(x)) return true;
	}}
	return false;
}
Lambda.foreach = function(it,f) {
	{ var $it0 = it.iterator();
	while( $it0.hasNext() ) { var x = $it0.next();
	if(!f(x)) return false;
	}}
	return true;
}
Lambda.iter = function(it,f) {
	{ var $it0 = it.iterator();
	while( $it0.hasNext() ) { var x = $it0.next();
	f(x);
	}}
}
Lambda.filter = function(it,f) {
	var l = new List();
	{ var $it0 = it.iterator();
	while( $it0.hasNext() ) { var x = $it0.next();
	if(f(x)) l.add(x);
	}}
	return l;
}
Lambda.fold = function(it,f,first) {
	{ var $it0 = it.iterator();
	while( $it0.hasNext() ) { var x = $it0.next();
	first = f(x,first);
	}}
	return first;
}
Lambda.count = function(it,pred) {
	var n = 0;
	if(pred == null) { var $it0 = it.iterator();
	while( $it0.hasNext() ) { var _ = $it0.next();
	n++;
	}}
	else { var $it1 = it.iterator();
	while( $it1.hasNext() ) { var x = $it1.next();
	if(pred(x)) n++;
	}}
	return n;
}
Lambda.empty = function(it) {
	return !it.iterator().hasNext();
}
Lambda.indexOf = function(it,v) {
	var i = 0;
	{ var $it0 = it.iterator();
	while( $it0.hasNext() ) { var v2 = $it0.next();
	{
		if(v == v2) return i;
		i++;
	}
	}}
	return -1;
}
Lambda.concat = function(a,b) {
	var l = new List();
	{ var $it0 = a.iterator();
	while( $it0.hasNext() ) { var x = $it0.next();
	l.add(x);
	}}
	{ var $it1 = b.iterator();
	while( $it1.hasNext() ) { var x = $it1.next();
	l.add(x);
	}}
	return l;
}
Lambda.prototype.__class__ = Lambda;
List = function(p) { if( p === $_ ) return; {
	this.length = 0;
}}
List.__name__ = ["List"];
List.prototype.h = null;
List.prototype.q = null;
List.prototype.length = null;
List.prototype.add = function(item) {
	var x = [item];
	if(this.h == null) this.h = x;
	else this.q[1] = x;
	this.q = x;
	this.length++;
}
List.prototype.push = function(item) {
	var x = [item,this.h];
	this.h = x;
	if(this.q == null) this.q = x;
	this.length++;
}
List.prototype.first = function() {
	return this.h == null?null:this.h[0];
}
List.prototype.last = function() {
	return this.q == null?null:this.q[0];
}
List.prototype.pop = function() {
	if(this.h == null) return null;
	var x = this.h[0];
	this.h = this.h[1];
	if(this.h == null) this.q = null;
	this.length--;
	return x;
}
List.prototype.isEmpty = function() {
	return this.h == null;
}
List.prototype.clear = function() {
	this.h = null;
	this.q = null;
	this.length = 0;
}
List.prototype.remove = function(v) {
	var prev = null;
	var l = this.h;
	while(l != null) {
		if(l[0] == v) {
			if(prev == null) this.h = l[1];
			else prev[1] = l[1];
			if(this.q == l) this.q = prev;
			this.length--;
			return true;
		}
		prev = l;
		l = l[1];
	}
	return false;
}
List.prototype.iterator = function() {
	return { h : this.h, hasNext : function() {
		return this.h != null;
	}, next : function() {
		if(this.h == null) return null;
		var x = this.h[0];
		this.h = this.h[1];
		return x;
	}};
}
List.prototype.toString = function() {
	var s = new StringBuf();
	var first = true;
	var l = this.h;
	s.b[s.b.length] = "{";
	while(l != null) {
		if(first) first = false;
		else s.b[s.b.length] = ", ";
		s.b[s.b.length] = Std.string(l[0]);
		l = l[1];
	}
	s.b[s.b.length] = "}";
	return s.b.join("");
}
List.prototype.join = function(sep) {
	var s = new StringBuf();
	var first = true;
	var l = this.h;
	while(l != null) {
		if(first) first = false;
		else s.b[s.b.length] = sep;
		s.b[s.b.length] = l[0];
		l = l[1];
	}
	return s.b.join("");
}
List.prototype.filter = function(f) {
	var l2 = new List();
	var l = this.h;
	while(l != null) {
		var v = l[0];
		l = l[1];
		if(f(v)) l2.add(v);
	}
	return l2;
}
List.prototype.map = function(f) {
	var b = new List();
	var l = this.h;
	while(l != null) {
		var v = l[0];
		l = l[1];
		b.add(f(v));
	}
	return b;
}
List.prototype.__class__ = List;
if(typeof js=='undefined') js = {}
js.Lib = function() { }
js.Lib.__name__ = ["js","Lib"];
js.Lib.isIE = null;
js.Lib.isOpera = null;
js.Lib.document = null;
js.Lib.window = null;
js.Lib.alert = function(v) {
	alert(js.Boot.__string_rec(v,""));
}
js.Lib.eval = function(code) {
	return eval(code);
}
js.Lib.setErrorHandler = function(f) {
	js.Lib.onerror = f;
}
js.Lib.prototype.__class__ = js.Lib;
haxe.io.Eof = function(p) { if( p === $_ ) return; {
	null;
}}
haxe.io.Eof.__name__ = ["haxe","io","Eof"];
haxe.io.Eof.prototype.toString = function() {
	return "Eof";
}
haxe.io.Eof.prototype.__class__ = haxe.io.Eof;
js.Boot = function() { }
js.Boot.__name__ = ["js","Boot"];
js.Boot.__unhtml = function(s) {
	return s.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;");
}
js.Boot.__trace = function(v,i) {
	var msg = i != null?i.fileName + ":" + i.lineNumber + ": ":"";
	msg += js.Boot.__unhtml(js.Boot.__string_rec(v,"")) + "<br/>";
	var d = document.getElementById("haxe:trace");
	if(d == null) alert("No haxe:trace element defined\n" + msg);
	else d.innerHTML += msg;
}
js.Boot.__clear_trace = function() {
	var d = document.getElementById("haxe:trace");
	if(d != null) d.innerHTML = "";
	else null;
}
js.Boot.__closure = function(o,f) {
	var m = o[f];
	if(m == null) return null;
	var f1 = function() {
		return m.apply(o,arguments);
	}
	f1.scope = o;
	f1.method = m;
	return f1;
}
js.Boot.__string_rec = function(o,s) {
	if(o == null) return "null";
	if(s.length >= 5) return "<...>";
	var t = typeof(o);
	if(t == "function" && (o.__name__ != null || o.__ename__ != null)) t = "object";
	switch(t) {
	case "object":{
		if(o instanceof Array) {
			if(o.__enum__ != null) {
				if(o.length == 2) return o[0];
				var str = o[0] + "(";
				s += "\t";
				{
					var _g1 = 2, _g = o.length;
					while(_g1 < _g) {
						var i = _g1++;
						if(i != 2) str += "," + js.Boot.__string_rec(o[i],s);
						else str += js.Boot.__string_rec(o[i],s);
					}
				}
				return str + ")";
			}
			var l = o.length;
			var i;
			var str = "[";
			s += "\t";
			{
				var _g = 0;
				while(_g < l) {
					var i1 = _g++;
					str += (i1 > 0?",":"") + js.Boot.__string_rec(o[i1],s);
				}
			}
			str += "]";
			return str;
		}
		var tostr;
		try {
			tostr = o.toString;
		}
		catch( $e0 ) {
			{
				var e = $e0;
				{
					return "???";
				}
			}
		}
		if(tostr != null && tostr != Object.toString) {
			var s2 = o.toString();
			if(s2 != "[object Object]") return s2;
		}
		var k = null;
		var str = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) { ;
		if(hasp && !o.hasOwnProperty(k)) continue;
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__") continue;
		if(str.length != 2) str += ", \n";
		str += s + k + " : " + js.Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str += "\n" + s + "}";
		return str;
	}break;
	case "function":{
		return "<function>";
	}break;
	case "string":{
		return o;
	}break;
	default:{
		return String(o);
	}break;
	}
}
js.Boot.__interfLoop = function(cc,cl) {
	if(cc == null) return false;
	if(cc == cl) return true;
	var intf = cc.__interfaces__;
	if(intf != null) {
		var _g1 = 0, _g = intf.length;
		while(_g1 < _g) {
			var i = _g1++;
			var i1 = intf[i];
			if(i1 == cl || js.Boot.__interfLoop(i1,cl)) return true;
		}
	}
	return js.Boot.__interfLoop(cc.__super__,cl);
}
js.Boot.__instanceof = function(o,cl) {
	try {
		if(o instanceof cl) {
			if(cl == Array) return o.__enum__ == null;
			return true;
		}
		if(js.Boot.__interfLoop(o.__class__,cl)) return true;
	}
	catch( $e0 ) {
		{
			var e = $e0;
			{
				if(cl == null) return false;
			}
		}
	}
	switch(cl) {
	case Int:{
		return Math.ceil(o%2147483648.0) === o;
	}break;
	case Float:{
		return typeof(o) == "number";
	}break;
	case Bool:{
		return o === true || o === false;
	}break;
	case String:{
		return typeof(o) == "string";
	}break;
	case Dynamic:{
		return true;
	}break;
	default:{
		if(o == null) return false;
		return o.__enum__ == cl || cl == Class && o.__name__ != null || cl == Enum && o.__ename__ != null;
	}break;
	}
}
js.Boot.__init = function() {
	js.Lib.isIE = typeof document!='undefined' && document.all != null && typeof window!='undefined' && window.opera == null;
	js.Lib.isOpera = typeof window!='undefined' && window.opera != null;
	Array.prototype.copy = Array.prototype.slice;
	Array.prototype.insert = function(i,x) {
		this.splice(i,0,x);
	}
	Array.prototype.remove = Array.prototype.indexOf?function(obj) {
		var idx = this.indexOf(obj);
		if(idx == -1) return false;
		this.splice(idx,1);
		return true;
	}:function(obj) {
		var i = 0;
		var l = this.length;
		while(i < l) {
			if(this[i] == obj) {
				this.splice(i,1);
				return true;
			}
			i++;
		}
		return false;
	}
	Array.prototype.iterator = function() {
		return { cur : 0, arr : this, hasNext : function() {
			return this.cur < this.arr.length;
		}, next : function() {
			return this.arr[this.cur++];
		}};
	}
	if(String.prototype.cca == null) String.prototype.cca = String.prototype.charCodeAt;
	String.prototype.charCodeAt = function(i) {
		var x = this.cca(i);
		if(x != x) return null;
		return x;
	}
	var oldsub = String.prototype.substr;
	String.prototype.substr = function(pos,len) {
		if(pos != null && pos != 0 && len != null && len < 0) return "";
		if(len == null) len = this.length;
		if(pos < 0) {
			pos = this.length + pos;
			if(pos < 0) pos = 0;
		}
		else if(len < 0) {
			len = this.length + len - pos;
		}
		return oldsub.apply(this,[pos,len]);
	}
	$closure = js.Boot.__closure;
}
js.Boot.prototype.__class__ = js.Boot;
sws.SWSStringOutput = function(p) { if( p === $_ ) return; {
	this.lines = [];
}}
sws.SWSStringOutput.__name__ = ["sws","SWSStringOutput"];
sws.SWSStringOutput.prototype.lines = null;
sws.SWSStringOutput.prototype.writeString = function(s) {
	this.lines.push(s);
}
sws.SWSStringOutput.prototype.close = function() {
	null;
}
sws.SWSStringOutput.prototype.toString = function() {
	return this.lines.join("\n");
}
sws.SWSStringOutput.prototype.__class__ = sws.SWSStringOutput;
sws.SWSStringOutput.__interfaces__ = [sws.SWSOutput];
$_ = {}
js.Boot.__res = {}
js.Boot.__init();
{
	String.prototype.__class__ = String;
	String.__name__ = ["String"];
	Array.prototype.__class__ = Array;
	Array.__name__ = ["Array"];
	Int = { __name__ : ["Int"]};
	Dynamic = { __name__ : ["Dynamic"]};
	Float = Number;
	Float.__name__ = ["Float"];
	Bool = { __ename__ : ["Bool"]};
	Class = { __name__ : ["Class"]};
	Enum = { };
	Void = { __ename__ : ["Void"]};
}
{
	Math.__name__ = ["Math"];
	Math.NaN = Number["NaN"];
	Math.NEGATIVE_INFINITY = Number["NEGATIVE_INFINITY"];
	Math.POSITIVE_INFINITY = Number["POSITIVE_INFINITY"];
	Math.isFinite = function(i) {
		return isFinite(i);
	}
	Math.isNaN = function(i) {
		return isNaN(i);
	}
}
{
	js.Lib.document = document;
	js.Lib.window = window;
	onerror = function(msg,url,line) {
		var f = js.Lib.onerror;
		if( f == null )
			return false;
		return f(msg,[url+":"+line]);
	}
}
sws.Options.defaultOptions = { debugging : true, javaStyleCurlies : true, addRemoveSemicolons : true, doNotCurlMultiLineParentheses : false, useCoffeeFunctions : true, unwrapParenthesesForCommands : ["if","while","for","catch","switch"], continuationKeywords : ["else","catch"], mayPrecedeOneLineIndent : ["if","while","else","for","try","catch"], blockLeadSymbol : " =>", blockLeadSymbolIndicatedRE : new EReg("(\\s|^)function\\s+[a-zA-Z_$]",""), blockLeadSymbolContraIndicatedRE : new EReg("^\\s*(if|else|while|for|try|catch|finally|switch|class)($|[^A-Za-z0-9_$@])",""), blockLeadSymbolContraIndicatedRE2AnonymousFunctions : new EReg("(^|[^A-Za-z0-9_$@])function\\s*[(]",""), leadLinesRequiringSemicolonEnd : new EReg("([ \t\\[\\]a-zA-Z_$]=[ \t\\[\\]a-zA-Z_$]|^\\s*return( |\t|$))",""), newline : "\n", addRemoveCurlies : true, trackSlashStarCommentBlocks : true, retainLineNumbers : true, onlyWrapParensAtBlockStart : true, guessEndGaps : true, fixIndent : false, joinMixedIndentLinesToLast : true};
sws.Heuristics.leadingIndentRE = new EReg("^\\s*","");
sws.Heuristics.whitespaceRE = new EReg("\\s+","");
sws.Heuristics.endsWithBackslash = new EReg("\\s?\\\\$","");
sws.Heuristics.endsWithComma = new EReg(",\\s*$","");
sws.Heuristics.looksLikePreproc = new EReg("^\\s*#","");
sws.SWS.emptyOrBlank = new EReg("^\\s*$","");
sws.SWS.indentRE = new EReg("^\\s*","");
sws.SWS.wholeLineIsCommentRE = new EReg("(^\\s*//|^\\s*/\\*|\\*/\\s*$)","");
sws.SWS.evenNumberOfQuotes = "(([^\"]*\"[^\"]*\"[^\"]*)*|[^\"]*)";
sws.SWS.evenNumberOfQuotesDislikeSlashes = "(([^\"/]*\"[^\"]*\"[^\"/]*)*|[^\"/]*|[^\"/]*/)";
sws.SWS.evenNumberOfApostrophesDislikeSlashes = new EReg("\"","g").replace(sws.SWS.evenNumberOfQuotesDislikeSlashes,"'");
sws.SWS.trailingCommentOutsideQuotes = new EReg("^(" + sws.SWS.evenNumberOfQuotesDislikeSlashes + ")(\\s*(//|/[*]).*)$","");
sws.SWS.trailingCommentOutsideApostrophes = new EReg("^(" + sws.SWS.evenNumberOfApostrophesDislikeSlashes + ")(\\s*(//|/[*]).*)$","");
sws.SWS.looksLikeRegexpLine = new EReg("^[^/]*=\\s*~?/[^*/].*/;?\\s*$","");
sws.SWS.seemsToContainRegexp = new EReg("[^/]~?/[^*/].*/","");
sws.SWS.evenNumberOfQuotesWithNoSlashes = "(([^\"/]*\"[^\"]*\"[^\"/]*)*|[^\"/]*)";
sws.SWS.couldbeRegexpEndingSlashSlash = new EReg("^" + sws.SWS.evenNumberOfQuotesWithNoSlashes + "~?\\/[^*+?/].*\\/\\/","");
sws.SWS.anonymousFunctionRE = new EReg("([^a-zA-Z0-9])function\\s*([(][a-zA-Z0-9@$_, \t]*[)])","g");
sws.SWS.anonymousFunctionReplace = "$1$2 ->";
sws.SWS.anonymousCoffeeFunctionRE = new EReg("([(][a-zA-Z0-9@$_, \t]*[)])\\s*->","g");
sws.SWS.anonymousCoffeeFunctionReplace = "function$1";
sws.SWS.firstTokenRE = new EReg("^\\s*([^\\s]*)","");
sws.CommentTrackingReader.lineOpensCommentRE = new EReg("/\\*","");
sws.CommentTrackingReader.lineClosesCommentRE = new EReg("\\*/","");
sws.CommentTrackingReader.parenthesisInsideQuotes = new EReg("^[^\"]*\"[^\"]*[()][^\"]*\"","");
sws.CommentTrackingReader.parenthesisInsideApostrophes = new EReg("^[^']*'[^']*[()][^']*'","");
js.Lib.onerror = null;
sws.SWS.main()