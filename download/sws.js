(function () { "use strict";
var $estr = function() { return js.Boot.__string_rec(this,''); };
function $extend(from, fields) {
	function Inherit() {} Inherit.prototype = from; var proto = new Inherit();
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var EReg = function(r,opt) {
	opt = opt.split("u").join("");
	this.r = new RegExp(r,opt);
};
EReg.__name__ = true;
EReg.prototype = {
	match: function(s) {
		if(this.r.global) this.r.lastIndex = 0;
		this.r.m = this.r.exec(s);
		this.r.s = s;
		return this.r.m != null;
	}
	,matched: function(n) {
		if(this.r.m != null && n >= 0 && n < this.r.m.length) return this.r.m[n]; else throw "EReg::matched";
	}
	,replace: function(s,by) {
		return s.replace(this.r,by);
	}
};
var HxOverrides = function() { };
HxOverrides.__name__ = true;
HxOverrides.cca = function(s,index) {
	var x = s.charCodeAt(index);
	if(x != x) return undefined;
	return x;
};
HxOverrides.substr = function(s,pos,len) {
	if(pos != null && pos != 0 && len != null && len < 0) return "";
	if(len == null) len = s.length;
	if(pos < 0) {
		pos = s.length + pos;
		if(pos < 0) pos = 0;
	} else if(len < 0) len = s.length + len - pos;
	return s.substr(pos,len);
};
HxOverrides.iter = function(a) {
	return { cur : 0, arr : a, hasNext : function() {
		return this.cur < this.arr.length;
	}, next : function() {
		return this.arr[this.cur++];
	}};
};
var Lambda = function() { };
Lambda.__name__ = true;
Lambda.has = function(it,elt) {
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		if(x == elt) return true;
	}
	return false;
};
var Std = function() { };
Std.__name__ = true;
Std.string = function(s) {
	return js.Boot.__string_rec(s,"");
};
var StringBuf = function() {
	this.b = "";
};
StringBuf.__name__ = true;
var haxe = {};
haxe.io = {};
haxe.io.Bytes = function(length,b) {
	this.length = length;
	this.b = b;
};
haxe.io.Bytes.__name__ = true;
haxe.io.Bytes.ofString = function(s) {
	var a = new Array();
	var _g1 = 0;
	var _g = s.length;
	while(_g1 < _g) {
		var i = _g1++;
		var c = s.charCodeAt(i);
		if(c <= 127) a.push(c); else if(c <= 2047) {
			a.push(192 | c >> 6);
			a.push(128 | c & 63);
		} else if(c <= 65535) {
			a.push(224 | c >> 12);
			a.push(128 | c >> 6 & 63);
			a.push(128 | c & 63);
		} else {
			a.push(240 | c >> 18);
			a.push(128 | c >> 12 & 63);
			a.push(128 | c >> 6 & 63);
			a.push(128 | c & 63);
		}
	}
	return new haxe.io.Bytes(a.length,a);
};
haxe.io.Eof = function() { };
haxe.io.Eof.__name__ = true;
haxe.io.Eof.prototype = {
	toString: function() {
		return "Eof";
	}
};
haxe.io.Error = { __ename__ : true, __constructs__ : ["Blocked","Overflow","OutsideBounds","Custom"] };
haxe.io.Error.Blocked = ["Blocked",0];
haxe.io.Error.Blocked.toString = $estr;
haxe.io.Error.Blocked.__enum__ = haxe.io.Error;
haxe.io.Error.Overflow = ["Overflow",1];
haxe.io.Error.Overflow.toString = $estr;
haxe.io.Error.Overflow.__enum__ = haxe.io.Error;
haxe.io.Error.OutsideBounds = ["OutsideBounds",2];
haxe.io.Error.OutsideBounds.toString = $estr;
haxe.io.Error.OutsideBounds.__enum__ = haxe.io.Error;
haxe.io.Error.Custom = function(e) { var $x = ["Custom",3,e]; $x.__enum__ = haxe.io.Error; $x.toString = $estr; return $x; };
haxe.io.Output = function() { };
haxe.io.Output.__name__ = true;
haxe.io.Output.prototype = {
	writeByte: function(c) {
		throw "Not implemented";
	}
	,writeBytes: function(s,pos,len) {
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
	,writeFullBytes: function(s,pos,len) {
		while(len > 0) {
			var k = this.writeBytes(s,pos,len);
			pos += k;
			len -= k;
		}
	}
	,writeString: function(s) {
		var b = haxe.io.Bytes.ofString(s);
		this.writeFullBytes(b,0,b.length);
	}
};
var js = {};
js.Boot = function() { };
js.Boot.__name__ = true;
js.Boot.__string_rec = function(o,s) {
	if(o == null) return "null";
	if(s.length >= 5) return "<...>";
	var t = typeof(o);
	if(t == "function" && (o.__name__ || o.__ename__)) t = "object";
	switch(t) {
	case "object":
		if(o instanceof Array) {
			if(o.__enum__) {
				if(o.length == 2) return o[0];
				var str = o[0] + "(";
				s += "\t";
				var _g1 = 2;
				var _g = o.length;
				while(_g1 < _g) {
					var i = _g1++;
					if(i != 2) str += "," + js.Boot.__string_rec(o[i],s); else str += js.Boot.__string_rec(o[i],s);
				}
				return str + ")";
			}
			var l = o.length;
			var i1;
			var str1 = "[";
			s += "\t";
			var _g2 = 0;
			while(_g2 < l) {
				var i2 = _g2++;
				str1 += (i2 > 0?",":"") + js.Boot.__string_rec(o[i2],s);
			}
			str1 += "]";
			return str1;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( e ) {
			return "???";
		}
		if(tostr != null && tostr != Object.toString) {
			var s2 = o.toString();
			if(s2 != "[object Object]") return s2;
		}
		var k = null;
		var str2 = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) {
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
			continue;
		}
		if(str2.length != 2) str2 += ", \n";
		str2 += s + k + " : " + js.Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str2 += "\n" + s + "}";
		return str2;
	case "function":
		return "<function>";
	case "string":
		return o;
	default:
		return String(o);
	}
};
var sws = {};
sws.Options = function() {
};
sws.Options.__name__ = true;
sws.Heuristics = function() { };
sws.Heuristics.__name__ = true;
sws.SWS = function(_options,out) {
	if(_options != null) this.options = _options; else this.options = sws.Options.defaultOptions;
	this.reporter = new sws.OptionalReporter(out,this.options);
};
sws.SWS.__name__ = true;
sws.SWS.main = function() {
};
sws.SWS.getFirstWord = function(line) {
	if(sws.SWS.firstTokenRE.match(line)) return sws.SWS.firstTokenRE.matched(1); else return "";
};
sws.SWS.countIndent = function(indentString,line) {
	if(indentString == null || line == null) return 0;
	var i;
	var j;
	var count;
	i = 0;
	j = 0;
	count = 0;
	while(true) if(line.charAt(i) == indentString.charAt(j)) {
		i++;
		if(i >= line.length) break;
		j++;
		if(j >= indentString.length) {
			j = 0;
			count++;
		}
	} else break;
	return count;
};
sws.SWS.repeatString = function(count,str) {
	var sb = new StringBuf();
	var _g = 0;
	while(_g < count) {
		var i = _g++;
		if(str == null) sb.b += "null"; else sb.b += "" + str;
	}
	return sb.b;
};
sws.SWS.prototype = {
	decurl: function(input,output) {
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
				if(wholeLine == null) break;
				var res = this.splitLineAtComment(wholeLine);
				var line = res[0];
				var trailingComment = res[1];
				var wholeLineIsComment = sws.SWS.wholeLineIsCommentRE.match(line);
				if(!wholeLineIsComment && !wasInsideComment) {
					if(startsWithClosingCurly.match(line)) {
						if(new EReg("^\\s*}\\s*;\\s*$","").match(line)) this.reporter.error("We do not currently support \"...};\" end-lines, try wrapping into \"(...});\".  " + line);
						line = startsWithCurlyReplacer.replace(line,"");
						indentCountAtLineStart--;
						indentCountAtLineEnd--;
						if(sws.SWS.emptyOrBlank.match(line + trailingComment)) continue;
					}
					if(endsWithOpeningCurly.match(line)) {
						indentCountAtLineEnd++;
						line = endsWithOpeningCurly.replace(line,"");
						if(this.options.blockLeadSymbol != null && !sws.SWS.emptyOrBlank.match(line)) {
							var indicated = this.options.blockLeadSymbolIndicatedRE != null && this.options.blockLeadSymbolIndicatedRE.match(line);
							var contraIndicated = this.options.blockLeadSymbolContraIndicatedRE != null && this.options.blockLeadSymbolContraIndicatedRE.match(line);
							if(this.options.blockLeadSymbolContraIndicatedRE2AnonymousFunctions.match(line)) contraIndicated = true;
							if(!indicated && !contraIndicated) this.reporter.debug("blockLeadSymbol neither indicated or contra-indicated for: " + line);
							if(indicated) line += this.options.blockLeadSymbol;
						}
						if(sws.SWS.emptyOrBlank.match(line + trailingComment)) continue;
					} else if(!wholeLineIsComment && !reader.insideComment && !sws.SWS.emptyOrBlank.match(line)) {
						if(this.options.addRemoveSemicolons) {
							if(endsWithSemicolon.match(line)) {
								line = endsWithSemicolon.replace(line,"");
								if(sws.SWS.emptyOrBlank.match(line)) continue;
							} else {
								reader.updateIndentInfo(line);
								if(reader.indent_of_nextNonEmptyLine > reader.indent_of_currentLine) {
									if(this.options.joinMixedIndentLinesToLast && new EReg("^\t* +","").match(reader.nextNonEmptyLine)) line += " \\"; else {
										var firstToken = sws.SWS.getFirstWord(line);
										if(!Lambda.has(this.options.mayPrecedeOneLineIndent,firstToken)) this.reporter.warn("The lines following this are indented, but do not have curlies, and may gain them! " + line);
									}
								} else {
									var nextLineIsCurl = false;
									var nextLine = reader.peekLine(1);
									if(nextLine != null && new EReg("^\\s*{\\s*$","").match(nextLine)) nextLineIsCurl = true;
									if(!sws.Heuristics.endsWithComma.match(line) && !nextLineIsCurl && !sws.Heuristics.looksLikePreproc.match(line)) line += " \\";
								}
							}
						}
					}
					if(this.options.useCoffeeFunctions) {
						if(sws.SWS.anonymousFunctionRE.match(line)) line = sws.SWS.anonymousFunctionRE.replace(line,sws.SWS.anonymousFunctionReplace);
					}
					if(this.options.unwrapParenthesesForCommands != null) {
						var firstToken1 = sws.SWS.getFirstWord(line);
						if(Lambda.has(this.options.unwrapParenthesesForCommands,firstToken1)) {
							var res1 = this.splitLineAtComment(line);
							var beforeComment = res1[0];
							var afterComment = res1[1];
							var replacementRE = new EReg(firstToken1 + "\\s*[(](.*)[)]\\s*$","");
							beforeComment = replacementRE.replace(beforeComment,firstToken1 + " $1");
							line = beforeComment + afterComment;
						}
					}
				}
				wholeLine = line + trailingComment;
				if(this.options.fixIndent && !reader.insideComment && !wasInsideComment) {
					if(sws.SWS.emptyOrBlank.match(wholeLine)) wholeLine = ""; else {
						var fixedIndentStr = sws.SWS.repeatString(indentCountAtLineStart,"\t");
						wholeLine = fixedIndentStr + sws.SWS.indentRE.replace(wholeLine,"");
					}
				}
				out.writeLine(wholeLine);
			}
		} catch( ex ) {
		}
		out.close();
	}
	,curl: function(input,output) {
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
			if(currentLine1 == null) break;
			var isInsideBrackets = helper.depthInsideParentheses > 0;
			if(wasInsideComment || isInsideBrackets && this.options.doNotCurlMultiLineParentheses) {
				out.writeLine(currentLine1);
				continue;
			}
			if(!sws.SWS.emptyOrBlank.match(currentLine1)) currentIndent = sws.SWS.countIndent(indentString,currentLine1);
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
				if(lineLikelyToBeRegexpDefinition) wholeLineIsComment = false;
			}
			if(this.options.useCoffeeFunctions) {
				if(sws.SWS.anonymousCoffeeFunctionRE.match(currentLine1)) currentLine1 = sws.SWS.anonymousCoffeeFunctionRE.replace(currentLine1,sws.SWS.anonymousCoffeeFunctionReplace);
			}
			if(!this.options.onlyWrapParensAtBlockStart) currentLine1 = this.wrapParens(currentLine1);
			if(!helper.insideComment && indent_of_nextNonEmptyLine > currentIndent) {
				if(this.options.onlyWrapParensAtBlockStart) currentLine1 = this.wrapParens(currentLine1);
				if(indent_of_nextNonEmptyLine > currentIndent + 1) this.reporter.error("Unexpected double indent on: " + nextNonEmptyLine);
				if(this.options.blockLeadSymbol != null) {
					var res = this.splitLineAtComment(currentLine1);
					var beforeComment = res[0];
					var afterComment = res[1];
					var i = beforeComment.lastIndexOf(this.options.blockLeadSymbol);
					if(i >= 0) {
						var beforeSymbol = HxOverrides.substr(beforeComment,0,i);
						var afterSymbol = HxOverrides.substr(beforeComment,i + this.options.blockLeadSymbol.length,null);
						if(sws.SWS.emptyOrBlank.match(afterSymbol)) {
							beforeComment = beforeSymbol + afterSymbol;
							currentLine1 = beforeComment + afterComment;
						}
					}
				}
				if(this.options.javaStyleCurlies) out.writeLine(this.appendToLine(currentLine1," {")); else {
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
					if(Lambda.has(this.options.continuationKeywords,firstToken)) delayLastCurly = " ";
					if(firstToken.charAt(0) == ")" || firstToken.charAt(0) == ",") delayLastCurly = "";
				}
				var i1 = currentIndent - 1;
				while(i1 >= indent_of_nextNonEmptyLine) {
					var lineWeStartedOn = openingLines.pop().line;
					var indentAtThisLevel = sws.SWS.repeatString(i1,indentString);
					if(delayLastCurly != null && i1 == indent_of_nextNonEmptyLine) {
						var nextLine = null;
						while(true) {
							nextLine = helper.getNextLine();
							if(sws.SWS.emptyOrBlank.match(nextLine)) out.writeLine(nextLine); else break;
						}
						var updatedLine;
						if(this.options.javaStyleCurlies) {
							nextLine = this.wrapParens(nextLine);
							updatedLine = indentAtThisLevel + "}" + delayLastCurly + sws.Heuristics.leadingIndentRE.replace(nextLine,"");
						} else {
							out.writeLine(indentAtThisLevel + "}");
							updatedLine = nextLine;
						}
						helper.pushBackLine(updatedLine);
						break;
					} else {
						if(this.options.guessEndGaps) {
							var spaceCurly = true;
							var indentsToGo = i1 - indent_of_nextNonEmptyLine + 1;
							var numEmptyLinesRequired = indentsToGo + 1;
							if(delayLastCurly != null) numEmptyLinesRequired--;
							var _g = 0;
							while(_g < numEmptyLinesRequired) {
								var j = _g++;
								var peekLine = helper.peekLine(j + 1);
								if(peekLine == null) {
									if(j < numEmptyLinesRequired - 1) spaceCurly = false;
									break;
								} else if(!sws.SWS.emptyOrBlank.match(peekLine)) {
									spaceCurly = false;
									break;
								}
							}
							if(spaceCurly) {
								var nextLine1 = helper.getNextLine();
								out.writeLine(nextLine1);
							}
						}
						if(this.options.leadLinesRequiringSemicolonEnd != null && this.options.leadLinesRequiringSemicolonEnd.match(lineWeStartedOn)) out.writeLine(indentAtThisLevel + "};"); else out.writeLine(indentAtThisLevel + "}");
					}
					i1--;
				}
				currentIndent = indent_of_nextNonEmptyLine;
				if(delayLastCurly != null) {
				}
				continue;
			}
			currentLine1 = this.considerSemicolonInjection(currentLine1,this.options,wholeLineIsComment);
			out.writeLine(currentLine1);
		}
		out.close();
	}
	,considerSemicolonInjection: function(currentLine,options,wholeLineIsComment) {
		if(options.addRemoveSemicolons && !wholeLineIsComment && !sws.SWS.emptyOrBlank.match(currentLine)) {
			if(sws.Heuristics.endsWithComma.match(currentLine)) return currentLine; else if(sws.Heuristics.looksLikePreproc.match(currentLine)) return currentLine; else if(sws.Heuristics.endsWithBackslash.match(currentLine)) return sws.Heuristics.endsWithBackslash.replace(currentLine,""); else return this.appendToLine(currentLine,";");
		}
		return currentLine;
	}
	,wrapParens: function(currentLine) {
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
	,appendToLine: function(line,toAppend) {
		var res = this.splitLineAtComment(line);
		var beforeComment = res[0];
		var afterComment = res[1];
		return beforeComment + toAppend + afterComment;
	}
	,splitLineAtComment: function(line) {
		var hasTrailingComment = sws.SWS.trailingCommentOutsideQuotes.match(line) && sws.SWS.trailingCommentOutsideApostrophes.match(line);
		if(!hasTrailingComment) return [line,""]; else {
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
			} catch( ex ) {
				this.reporter.warn("Exception applying couldbeRegexpEndingSlashSlash: \"" + Std.string(ex) + "\" on line: " + line);
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
	,echo: function(str) {
		this.reporter.echo("[Rest] " + str);
	}
};
sws.HelpfulReader = function(_input) {
	this.input = _input;
	this.queue = new Array();
};
sws.HelpfulReader.__name__ = true;
sws.HelpfulReader.prototype = {
	getNextLine: function() {
		if(this.queue.length > 0) return this.queue.shift();
		try {
			return this.input.readLine();
		} catch( ex ) {
			return null;
		}
	}
	,pushBackLine: function(line) {
		this.queue.unshift(line);
	}
	,peekLine: function(i) {
		while(this.queue.length < i) try {
			var nextLine = this.input.readLine();
			this.queue.push(nextLine);
		} catch( ex ) {
			return null;
		}
		return this.queue[i - 1];
	}
	,findNextNonEmptyLine: function() {
		var i;
		var _g1 = 0;
		var _g = this.queue.length;
		while(_g1 < _g) {
			var i1 = _g1++;
			if(!sws.SWS.emptyOrBlank.match(this.queue[i1])) return this.queue[i1];
		}
		while(true) try {
			var line = this.input.readLine();
			this.queue.push(line);
			if(!sws.SWS.emptyOrBlank.match(line)) return line;
		} catch( ex ) {
			break;
		}
		return null;
	}
};
sws.Reporter = function(_out) {
	this.out = _out;
};
sws.Reporter.__name__ = true;
sws.Reporter.prototype = {
	echo: function(s) {
		if(this.out == null) console.log(s); else this.out.writeString(s + "\n");
	}
	,debug: function(s) {
		this.echo("[Debug] " + s);
	}
	,info: function(s) {
		this.echo("[Info] " + s);
	}
	,warn: function(s) {
		this.echo("[Warning] " + s);
	}
	,error: function(s) {
		this.echo("[Error] " + s);
	}
};
sws.OptionalReporter = function(out,_options) {
	sws.Reporter.call(this,out);
	this.options = _options;
};
sws.OptionalReporter.__name__ = true;
sws.OptionalReporter.__super__ = sws.Reporter;
sws.OptionalReporter.prototype = $extend(sws.Reporter.prototype,{
	echo: function(s) {
		if(this.out == null) sws.Reporter.prototype.echo.call(this,s); else this.out.writeString(s + this.options.newline);
	}
	,debug: function(s) {
		if(this.options.debugging) this.echo("[Debug] " + s);
	}
});
sws.Outputter = function(_output,_options) {
	this.output = _output;
	this.options = _options;
};
sws.Outputter.__name__ = true;
sws.Outputter.prototype = {
	writeLine: function(str) {
		this.output.writeString(str + this.options.newline);
	}
	,close: function() {
		this.output.close();
	}
};
sws.CommentTrackingReader = function(input,_sws) {
	sws.HelpfulReader.call(this,input);
	this.sws = _sws;
	this.reporter = this.sws.reporter;
	this.insideComment = false;
	this.depthInsideParentheses = 0;
};
sws.CommentTrackingReader.__name__ = true;
sws.CommentTrackingReader.__super__ = sws.HelpfulReader;
sws.CommentTrackingReader.prototype = $extend(sws.HelpfulReader.prototype,{
	getNextLine: function() {
		var line = sws.HelpfulReader.prototype.getNextLine.call(this);
		if(line == null) return line;
		var res = this.sws.splitLineAtComment(line);
		var lineBeforeComment = res[0];
		var trailingComment = res[1];
		if(sws.CommentTrackingReader.lineOpensCommentRE.match(line)) {
			var indexOfSingleLineComment = line.indexOf("//");
			var indexOfCommentStart = line.indexOf("/" + "*");
			if(indexOfSingleLineComment != -1 && indexOfSingleLineComment < indexOfCommentStart) this.reporter.echo("Looks like opening comment but *after* one-line comment, so ignoring it: " + line); else if(sws.SWS.looksLikeRegexpLine.match(line)) {
			} else {
				this.insideComment = true;
				if(sws.SWS.seemsToContainRegexp.match(lineBeforeComment)) this.reporter.warn("Looks like start of comment block but also like a regexp!  " + line);
			}
		}
		if(sws.CommentTrackingReader.lineClosesCommentRE.match(line)) {
			if(sws.SWS.looksLikeRegexpLine.match(line)) {
			} else {
				this.insideComment = false;
				if(sws.SWS.seemsToContainRegexp.match(lineBeforeComment)) this.reporter.warn("Looks like end of comment block but also like a regexp!  " + line);
			}
		}
		var openBracketCount = this.countInString(lineBeforeComment,40);
		var closeBracketCount = this.countInString(lineBeforeComment,41);
		if(sws.CommentTrackingReader.parenthesisInsideQuotes.match(lineBeforeComment) || sws.CommentTrackingReader.parenthesisInsideApostrophes.match(lineBeforeComment)) {
			if(openBracketCount == closeBracketCount) {
			} else if(this.sws.options.doNotCurlMultiLineParentheses) this.reporter.debug("Ignoring untrustworthy parentheses: " + line); else {
			}
		} else this.depthInsideParentheses += openBracketCount - closeBracketCount;
		return line;
	}
	,countInString: function(s,c) {
		var count = 0;
		var _g1 = 0;
		var _g = s.length;
		while(_g1 < _g) {
			var i = _g1++;
			if(HxOverrides.cca(s,i) == c) count++;
		}
		return count;
	}
});
sws.SuperDuperReader = function(input,_sws) {
	sws.CommentTrackingReader.call(this,input,_sws);
	this.firstWord = null;
	this.lineThatOpenedIndent = new Array();
};
sws.SuperDuperReader.__name__ = true;
sws.SuperDuperReader.__super__ = sws.CommentTrackingReader;
sws.SuperDuperReader.prototype = $extend(sws.CommentTrackingReader.prototype,{
	getNextNonEmptyLine: function() {
		this.nextNonEmptyLine = this.findNextNonEmptyLine();
		return this.nextNonEmptyLine;
	}
	,updateIndentInfo: function(currentLine) {
		sws.Heuristics.leadingIndentRE.match(currentLine);
		this.indent_of_currentLine = sws.Heuristics.leadingIndentRE.matched(0).length;
		var nextNonEmptyLine = this.getNextNonEmptyLine();
		if(nextNonEmptyLine == null) nextNonEmptyLine = "";
		sws.Heuristics.leadingIndentRE.match(nextNonEmptyLine);
		this.indent_of_nextNonEmptyLine = sws.Heuristics.leadingIndentRE.matched(0).length;
	}
});
sws.LineRecord = function(_number,_line) {
	this.number = _number;
	this.line = _line;
};
sws.LineRecord.__name__ = true;
sws.Stack = function() {
	this.items = new Array();
};
sws.Stack.__name__ = true;
sws.Stack.prototype = {
	push: function(item) {
		this.items.push(item);
	}
	,pop: function() {
		return this.items.pop();
	}
};
sws.LineStack = function() {
	sws.Stack.call(this);
};
sws.LineStack.__name__ = true;
sws.LineStack.__super__ = sws.Stack;
sws.LineStack.prototype = $extend(sws.Stack.prototype,{
});
sws.SWSInput = function() { };
sws.SWSInput.__name__ = true;
sws.SWSOutput = function() { };
sws.SWSOutput.__name__ = true;
sws.SWSStringInput = function(input) {
	this.lines = input.split("\n");
};
sws.SWSStringInput.__name__ = true;
sws.SWSStringInput.__interfaces__ = [sws.SWSInput];
sws.SWSStringInput.prototype = {
	readLine: function() {
		if(this.lines.length > 0) {
			var line = this.lines.shift();
			if(line.charAt(line.length - 1) == "\r") line = HxOverrides.substr(line,0,line.length - 1);
			return line;
		} else throw "End of stringfile";
		return null;
	}
};
sws.SWSStringOutput = function() {
	this.lines = [];
};
sws.SWSStringOutput.__name__ = true;
sws.SWSStringOutput.__interfaces__ = [sws.SWSOutput];
sws.SWSStringOutput.prototype = {
	writeString: function(s) {
		this.lines.push(s);
	}
	,close: function() {
	}
	,toString: function() {
		return this.lines.join("\n");
	}
};
function $iterator(o) { if( o instanceof Array ) return function() { return HxOverrides.iter(o); }; return typeof(o.iterator) == 'function' ? $bind(o,o.iterator) : o.iterator; }
var $_, $fid = 0;
function $bind(o,m) { if( m == null ) return null; if( m.__id__ == null ) m.__id__ = $fid++; var f; if( o.hx__closures__ == null ) o.hx__closures__ = {}; else f = o.hx__closures__[m.__id__]; if( f == null ) { f = function(){ return f.method.apply(f.scope, arguments); }; f.scope = o; f.method = m; o.hx__closures__[m.__id__] = f; } return f; }
String.__name__ = true;
Array.__name__ = true;
sws.Options.defaultOptions = { debugging : true, javaStyleCurlies : true, addRemoveSemicolons : true, doNotCurlMultiLineParentheses : false, useCoffeeFunctions : true, unwrapParenthesesForCommands : ["if","while","for","catch","switch"], continuationKeywords : ["else","catch"], mayPrecedeOneLineIndent : ["if","while","else","for","try","catch"], blockLeadSymbol : " =>", blockLeadSymbolIndicatedRE : new EReg("(\\s|^)function\\s+[a-zA-Z_$]",""), blockLeadSymbolContraIndicatedRE : new EReg("^\\s*(if|else|while|for|try|catch|finally|switch|class|interface)($|[^A-Za-z0-9_$@])",""), blockLeadSymbolContraIndicatedRE2AnonymousFunctions : new EReg("(^|[^A-Za-z0-9_$@])function\\s*[(]",""), leadLinesRequiringSemicolonEnd : new EReg("([ \t\\[\\]a-zA-Z_$]=[ \t\\[\\]a-zA-Z_$]|^\\s*return( |\t|$))",""), newline : "\n", addRemoveCurlies : true, trackSlashStarCommentBlocks : true, retainLineNumbers : true, onlyWrapParensAtBlockStart : true, guessEndGaps : true, fixIndent : false, joinMixedIndentLinesToLast : true};
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
sws.SWS.main();
})();
