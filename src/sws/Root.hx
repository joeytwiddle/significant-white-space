package sws;

import sys.io.File;
import sys.io.FileInput;
import sys.io.FileOutput;
import sys.FileSystem;
import Sys;
import sys.io.Process;

import haxe.CallStack;

import sws.Options;
import sws.SWS;

// For arg parsing
import Type;

using Lambda;

// TODO: Track input file line numbers, and use these when printing warnings.

// TODO: We could suppress warnings for JS regexps if we know we're working in Haxe or Java.

// DONE: We are still stripping ;s from commented lines with extra trailing comments (see blockLeadSymbol)

// TODO: using blockLeadSymbol only for functions, we may as well adapt useCoffeeFunctions to handle anonymous and not anonymous.  Or maybe not!  It's nice to have a semantic difference between anonymous and declared functions.  If they are both the same, we will have to ensure we convert any anonymous -> functions back before stripping any redundant -> for a declaration.

// TODO: Complete refactoring into file-free tool.

// TODO: Warn when decurling expects un () wrapping but does not get it, e.g.:
//   if (name.equals(v.name)) return true;

// TODO: Upgrade some warnings to errors; if we are confident it has caused / will cause a problem.

// Recommend config file do like HaXe and MPlayer, just put cmdline args there, and parse them the same way.


class Root {

	static function main() {

		var args = Sys.args();

		var options = Options.defaultOptions;
		var syncOptions = new SyncOptions();

		checkForOptions(args,options);
		checkForOptions(args,syncOptions);

		// Cannot name this sws as it conflicts with package!
		var _sws = new SWS(options,Sys.stdout());
		var sync = new Sync(options,syncOptions);

		try {

			if (args[0] == "--help") {

				showHelp();

			} else if (args[0] == "curl") {

				_sws.curl(new SWSFileInput(args[1]), new SWSFileOutput(args[2]));

			} else if (args[0] == "decurl") {

				_sws.decurl(new SWSFileInput(args[1]), new SWSFileOutput(args[2]));

			} else if (args[0] == "safe-curl") {

				sync.safeCurl(args[1], args[2]);

			} else if (args[0] == "safe-decurl") {

				sync.safeDecurl(args[1], args[2]);

			} else if (args[0] == "sync") {

				if (args[1] != null) {
					sync.doSync(args[1]);
				} else {
					sync.doSync(".");
				}

			} else {

				showHelp();
			}

		} catch (ex : Dynamic) {
			echo("Exception occurred: "+ex);
			// echo(haxe.Stack.toString(haxe.Stack.callStack()))
			echoPure(CallStack.toString(CallStack.exceptionStack()));
			// var stackArray = haxe.Stack.exceptionStack()
 {			// for stackElem in stackArray
				// echo(""+stackElem)
			}
			Sys.exit(2);
		}

		Sys.exit(0);
	}

	static function showHelp() {
		echo("sws curl   <filename> <outname>");
		echo("sws decurl <filename> <outname>");
		echo("sws safe-curl   <filename> <outname>    - safe mode checks whether");
		echo("sws safe-decurl <filename> <outname>    - inversion reproduces original");
		echo("sws sync [<folder/filename>]");
		echo("Language transformation options:");
		showOptions(Options.defaultOptions);
		echo("Sync options:");
		showOptions(new SyncOptions());
	}

	static function showOptions(opts : Dynamic) {
		var fields = Reflect.fields(opts);
		for (field in fields) {
			var opt = "-"+field.toLowerCase();
			var currentValue = Reflect.field(opts,field);
			var type = Type.typeof(currentValue);
			echo("  "+opt+" "+currentValue);
			/// currentValue and type are too messy, even on strings!
			// +" : default "+currentValue+" (type "+type+") 
		}
	}

	static function echo(s:String) {
		echoPure("[Root] " + s);
	}

	static function echoPure(s:String) {
		Sys.stdout().writeString(s + "\n");
	}

	static function checkForOptions(args : Array<String>, opts:Dynamic) {
		var fields = Reflect.fields(opts);
		for (field in fields) {
			var opt = "-"+field.toLowerCase();
			// for arg in args            // We need an index
			// for i in 0...args.length   // "Loop variable cannot be modified"
			var i = 0;
			while (i < args.length) {
				var arg = args[i];
				if (arg == opt) {
					var currentValue = Reflect.field(opts,field);
					var type = Type.typeof(currentValue);
					if (type == TBool) {
						Reflect.setField(opts,field,!currentValue);
						args.splice(i,1);
						i--;
					} else {
						echo("Do not know how to handle type of option "+field+": "+type);
					}
				}
				i++;
			}
		}

	}

}

class SyncOptions {

	public var validExtensions : Array<String>;

	public var skipFoldersNamed : Array<String>;

	public var safeSyncMakeBackups : Bool;
	public var safeSyncCheckInverse : Bool;

	public var breakOnFirstFailedInverse : Bool;

	public var pathSeparator : String;

	public function new() {
		validExtensions = [ "sws", "java", "c", "C", "cpp", "c++", "h", "hx", "uc", "js" ];   // "jpp"
		skipFoldersNamed = [ "CVS", ".git", ".svn" ];
		safeSyncMakeBackups  = true;
		safeSyncCheckInverse = true;
		breakOnFirstFailedInverse = true;
		pathSeparator = "/";

	}

}

class Sync {

	var sws : SWS;

	var syncOptions : SyncOptions;

	public function new(_options, _syncOptions) {
		sws = new SWS(_options,Sys.stdout());
		syncOptions = _syncOptions;
	}

	public function safeDecurl(infile, outfile) {
		doSafely(sws.decurl, infile, outfile, sws.curl);
	}

	public function safeCurl(infile, outfile) {
		doSafely(sws.curl, infile, outfile, sws.decurl);
	}

	// Loving the first-order functions.
	// However in this particular case, I wouldn't mind getting more specific, because this is really not applicable to all functions in general.
	// E.g. we should only accept fn/class which implements "FileTransformer".
	public function doSafely(fn : Dynamic, inFile : String, outFile : String, inverseFn : Dynamic) {

		if (syncOptions.safeSyncMakeBackups) {
			var backupFile = outFile + ".bak";
			if (FileSystem.exists(outFile)) {
				File.copy(outFile, backupFile);
			}
		}

		var originalResult = null;
		if (FileSystem.exists(outFile)) {
			originalResult = File.getContent(outFile);
		}

		var input = new SWSFileInput(inFile);
		var output = new SWSFileOutput(outFile);
		fn(input, output);
		// Now we want to mark the outFile with identical modification time to the inFile, so that sws knows it need not translate between them.
		// Unfortunately neko FileSystem does not expose this ability
		// So instead, we will simply try to touch the inFile ASAP, and if the time is a millisecond too late, accept the consequences (this source will be uneccessarily transformed again).
		//touchFile(inFile)
		// Woop!  It worked!  (It might not work on very large files, or fine-grained filesystems.)  I think it worked for me because ext2/3/4 uses second-based timestamps, not millisecond-based.
		// But anyway that was a nasty solution.  Really we want to force the timestamp of the outFile
		cloneTimestamp(inFile, outFile);

		if (originalResult != null) {
			var newResult = File.getContent(outFile);
			if (newResult != originalResult) {
				// This is perfectly normal, if we have changed the source file.
				info("There were changes to "+outFile+" since the last time ("+originalResult.length+" -> "+newResult.length+")");
			} else {
				info("The new version of "+outFile+" is identical to the old version.");
			}
			if (syncOptions.safeSyncCheckInverse) {
				info("As for the inverse...");
			} else {
				info("Not checking the inverse.  Good luck!");
			}
		}

		if (syncOptions.safeSyncCheckInverse) {
			var tempFile = inFile + ".inv";
			var input = new SWSFileInput(outFile);
			var output = new SWSFileOutput(tempFile);
			inverseFn(input, output);
			// echo("Now compare "+inFile+" against "+tempFile);
			if (File.getContent(inFile) != File.getContent(tempFile)) {
				warn("Inverse differs from original.  Differences may or may not be cosmetic!");
				// echo("Compare files: \""+inFile+"\" \""+tempFile+"\"");
				// echo("Compare: jdiff \""+inFile+"\" \""+tempFile+"\"");
				warn("Compare:");
				pureEcho("  vimdiff \""+inFile+"\" \""+tempFile+"\"");
				if (syncOptions.breakOnFirstFailedInverse) {
					echo("Exiting so user can inspect.  There may be more files which need processing...");
					// Lies: tempFile won't be checked! echo("Whichever file you edit will be transformed on the next pass, or if neither are edited, we will pick up where we left off, on the next file.")
					echo("If you edit the source file now, it be transformed again on the next sync; if not we will pick up where we left off, on the next file.");
					Sys.exit(5);
				}
			} else {
				info("File matches inverse perfectly.");
			}
		}
	}

	/*
	static function touchFile(filename) =>
		File.copy(filename,filename+".touch")
		FileSystem.rename(filename+".touch",filename)
	*/

	static function cloneTimestamp(srcFile, destFile) {
		// A Unix-only solution, until I find something better.
		var process = new Process("touch", ["-r", srcFile, destFile]);
		process.exitCode();   // Don't let it zombie!
		// Not needed but noting it: var mediaSize:String = process.stdout.readAll().toString()
	}

	function traceCall(fn : Dynamic, args : Array<Dynamic>) : Dynamic {
		echo("Calling "+fn+" with args "+args);
		return fn(args);
	}

	static function getExtension(filename : String) {
		var words = filename.split(".");
		if (words.length > 1) {
			return words[words.length-1];
		} else {
			return "";
		}
	}

	public function doSync(root : String) {

		var validExtensionsLocal = syncOptions.validExtensions;

		// We want to collect all files ending with ".sws" or with a valid source extension.
		// Sometimes we will pick up a pair, but we merge them into one by canonicalisation.
		var filesToDo : Array<String> = [];
		forAllFilesBelow(root, function(f) {
			// echo("Checking file: "+f);
			var ext = getExtension(f);
			if (validExtensionsLocal.has(ext)) {
				// Canonicalise to the non-sws name
				if (ext == "sws") {
					var words = f.split(".");
					words = words.slice(0,words.length-1);
					f = words.join(".");
				}
				if (!filesToDo.has(f)) {
					filesToDo.push(f);
				}
				// echo("pushing: "+f);
			}
		});

		for (curlyFile in filesToDo) {
			syncFile(curlyFile);
		}
	}

	function syncFile(curlyFile) {

		var swsFile = curlyFile + ".sws";

		var direction : Int = 0;   // 0=none, 1=to_sws, 2=from_sws
		if (!FileSystem.exists(swsFile)) {
			direction = 1;
		} else if (!FileSystem.exists(curlyFile)) {
			direction = 2;
		} else {
			var srcStat = FileSystem.stat(curlyFile);
			var swsStat = FileSystem.stat(swsFile);
			// echo(srcStat + " <-> "+swsStat);
			if (srcStat.mtime.getTime() < swsStat.mtime.getTime()) {
				direction = 2;
			} else if (srcStat.mtime.getTime() > swsStat.mtime.getTime()) {
				direction = 1;
			}
		}

		if (direction == 1) {
			echo("Decurling "+curlyFile+" -> "+swsFile);
			safeDecurl(curlyFile, swsFile);
		} else if (direction == 2) {
			echo("Curling "+swsFile+" -> "+curlyFile);
			safeCurl(swsFile, curlyFile);
		}
	}

	function forAllFilesBelow<ResType>(node : String, fn : String -> ResType) {
		if (FileSystem.isDirectory(node)) {
			if (!syncOptions.skipFoldersNamed.has(node)) {
				var children = FileSystem.readDirectory(node);
				for (child in children) {
					var childPath = node + syncOptions.pathSeparator + child;
					forAllFilesBelow(childPath,fn);
				}
			}
		} else {
			fn(node);
		}
	}

	function echo(s) {
		sws.reporter.echo("[Sync] "+s);
	}

	function pureEcho(s) {
		sws.reporter.echo(s);
	}

	function info(s) {
		sws.reporter.info(s);
	}

	function warn(s) {
		sws.reporter.warn(s);

	}

}
