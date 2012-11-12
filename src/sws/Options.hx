package sws;

class Options {

	// The (...)s are required here to get the needed trailing ;
	// The cast is the only way I found in Haxe so far.  It's fine I guess?
	public static var defaultOptions : Options = cast ( {
		debugging: true,
		javaStyleCurlies: true,
		addRemoveSemicolons: true,
		doNotCurlMultiLineParentheses: false,
		useCoffeeFunctions: true,
		unwrapParenthesesForCommands: [ "if", "while", "for", "catch", "switch" ],
		// , "elseif"
		blockLeadSymbol: " =>",
		blockLeadSymbolIndicatedRE: ~/(\s|^)function\s+[a-zA-Z_$]/,
		blockLeadSymbolContraIndicatedRE: ~/^\s*(if|else|while|for|try|catch|finally|switch|class)($|[^A-Za-z0-9_$@])/,
		blockLeadSymbolContraIndicatedRE2AnonymousFunctions: ~/(^|[^A-Za-z0-9_$@])function\s*[(]/,
		newline: "\n",
		addRemoveCurlies: true,
		trackSlashStarCommentBlocks: true,
		retainLineNumbers: true,
		onlyWrapParensAtBlockStart: true,
		guessEndGaps: true,
		fixIndent: false,
		joinMixedIndentLinesToLast: true
	});

	// Recently: Decurl adds trailing ' \' when semicolon was expected but not found.
	//           Curl removes trailing ' \' and does not add semicolon when encountered.
	//
	// GONE: This has pushed a problem with the commented line looksLikeRegexpLineWithEndComment back up to the surface.  I think before those ambiguous lines (splitLineAtComment) were getting semicolons stripped and reinjected?  New ' \' may be avoiding stripping a bit more heavily.  Perhaps it too should check ambiguity?

	public var debugging : Bool;

	// Options {{{

	public var javaStyleCurlies : Bool;

	public var addRemoveSemicolons : Bool;

	// doNotCurlMultiLineParentheses:
	//   true - You can write multi-line expressions with (...).
	//          But you will not be able to create curly indented blocks within them.
	//          The contents of (...) will remain unchanged.  Doesn't that mean we *can* put curlies inside, but they won't be de/re-curled?
	//   false - Multi-line expressions will be subject to curling and SCI, with or without (...)
	//           new {...} blocks should work fine provided they are in the middle of an otherwise unbroken line.  (They do require at least one trailing that is not '}' or ';'.)
	public var doNotCurlMultiLineParentheses : Bool;

	// Rename: useCoffeeFunctionSymbolForAnonymousFunctions?  Maybe not.
	public var useCoffeeFunctions : Bool;

	// NOTE: Current implementation will *not* unbrace or re-brace if(...) - because we peek the first symbol, a space is required: if (...)
	public var unwrapParenthesesForCommands : Array<String>;

	//// blockLeadSymbol is an entirely optional symbol used to indicate the start of certain blocks.  This works much like Python's ":" symbol, but with SWS we want fine-grained control over when they are used.
	// static var blockLeadSymbol = null;
	// static var blockLeadSymbol = ":";         // Like Python
	// static var blockLeadSymbol = " :";        // But : looks rather odd in Haxe, where function lines may already end in ": Type"
	// static var blockLeadSymbol = " =";        // Quite passable, although not as true as when CS defines functions this way.
	// static var blockLeadSymbol = " {";        // hehe this actually works without error; of course no matching } is introduced
	// public var blockLeadSymbol = " =>"          // I like this for HaXe
	public var blockLeadSymbol : String;
	// TODO: keywordsHintSymbols : Map<String,String>

	//// s/Indicated/Wanted/g ?

	// static var blockLeadSymbolContraIndicatedRE = null;
	// Catches non-anonymous function declarations in HaXe (e.g. declaring a method within a class).  Anonymous functions differ in that they are handled by useCoffeeFunctions.
	// The start ensures a word.  The end requires at least one name char, to distinguish "function (e) {" from "function myFunc(e)"
	// TODO: What about Java?
	// TODO: There is no indicator for Java ... no keyword!
	public var blockLeadSymbolIndicatedRE : EReg;
	// static var blockLeadSymbolIndicatedRE = ~/(\s|^)(if|while|.*)/;   // Not sure when Python users want their ":"s

	// Use this blockLeadSymbolContraIndicatedRE if you only want blockLeadSymbol on function declarations (i.e. none of the things mentioned here).
	// TODO: To suppress warnings, contra-indicate anonymous functions.
	// These would be neater in a list, checked against the first word on the line.
	public var blockLeadSymbolContraIndicatedRE : EReg;
	public var blockLeadSymbolContraIndicatedRE2AnonymousFunctions : EReg;
	// static var blockLeadSymbolContraIndicatedRE = null;   // Not sure when Python users want their ":"s
	// TODO: DRY.  useCoffeeFunctions already detects anonymous functions, and therefore can contra-indicate them without the need for a repeat regexp.
	// TODO: Java does not have anonymous functions, but we should check that inline interface implementations are working ok.

	// static var newline : String = "\r\n";
	public var newline : String;

	// If we always wrap parens for an "if..." line, we cannot accept single-line if statements.
	// If we only wrap when we are starting an indented block, we can't have single-line parensWrapping, e.g.: throwError "message" -> to throwError("message")   - I don't think we ever really need that!  No languages have syntax that looks like functions!
	public var onlyWrapParensAtBlockStart : Bool;

	// Cosmetic: how blank lines are distributed around closing "}" lines.  Depends on your coding style / formatter.  When disabled, outdent immediate produces a "}" line.  When enabled, the closing "}" line will be separated from its block by an empty line, *if* enough empty lines are available in the sws.
	public var guessEndGaps : Bool;

	// Causes de-curling to override existing indentation with indentation generated from counting { and } symbols.
	// Might break (or at least improperly indent) non-curled bodies, e.g. from singe-line body of an if statement.
	public var fixIndent : Bool;

	// If your curly code formatter (e.g. Eclipse) adds spaces after tab indentation when breaking a long line, we can detect this and prevent semicolon insertion until the final line.
	public var joinMixedIndentLinesToLast : Bool;
	// Potential issue with too much faith in this feature: If the first line in your file has been broken this way, then the file's indent string may be incorrectly detected!  (Although it's unlikely Eclipse would format that way.)

	// }}}

	// TODO:
	public var addRemoveCurlies : Bool;
	public var trackSlashStarCommentBlocks : Bool;   // can be disabled if they will never be used, saving concerns about slash-stars appearing hidden in strings or regexps.
	public var retainLineNumbers : Bool;             // does not squash up empty lines on decurl (on curl we should drop/replace an empty line when closing curls)

	public function new() {
		//

	}

}
