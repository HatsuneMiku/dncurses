/*******************************************************************************
 * Basic ncurses functionality
 *
 * Core functions that don't depend on any other ncurses functionality
 *
 * Authors: Matthew Soucy, msoucy@csh.rit.edu
 * Date: Nov 12, 2012
 * Version: 0.0.1
 */
module metus.dncurses.base;


import std.string : toUpper, strlen;
import std.stdio : File;
public import metus.dncurses.errors;
package import nc = deimos.ncurses.ncurses;

/**
 * Get the ncurses version
 *
 * Returns: The version number as a string
 */
char[] ncurses_version() {
	char* ver = nc.curses_version();
	return ver[0..strlen(ver)];
}


/// Character type from Deimos
alias CharType = nc.chtype;
/// Stores whether ncurses is in echo mode or not
private static bool isEcho;


/**
 * Get echo mode
 *
 * Returns: The current echo mode
 */
bool echo() @safe @property nothrow {
	return isEcho;
}
/**
 * Change echo mode
 *
 * Params:
 * 		echoOn	=	Whether echo should be enabled
 * Returns: The old echo mode
 */
bool echo(bool echoOn) @property {
	bool currEcho = isEcho;
	if(((isEcho=echoOn)==true ? nc.echo() : nc.noecho()) != nc.OK) {
		throw new NCursesException("Could not change echo mode");
	}
	return currEcho;
}


/**
 * Control flush of input and output on interrupt
 *
 * Control flushing of input and output queues when an interrupt, quit,
 * or suspend character is sent to the terminal.
 *
 * Params:
 * 		shouldFlush	=	Enable (true) or disable (false) flushing
 */
void qiflush(bool shouldFlush) @property {
	if(shouldFlush) {
		nc.qiflush();
	} else {
		nc.noqiflush();
	}
}

/**
 * Control flush of output on interrupt
 *
 * If the value of shouldFlush is TRUE, then flushing of the output buffer
 * associated with the current screen will occur when an interrupt key
 * (interrupt, suspend, or quit) is pressed. If the value of shouldFlush is
 * FALSE, then no flushing of the buffer will occur when an interrupt key
 * is pressed.
 *
 * Params:
 * 		shouldFlush	=	Enable (true) or disable (false) flushing
 */
void intrflush(bool shouldFlush) @property {
	// nc.intrflush ignores the window parameter...
	if(nc.intrflush(nc.stdscr, shouldFlush) != nc.OK) {
		throw new NCursesException("Could not change flush behavior");
	}
}

/**
 * Key name wrapper
 *
 * Allows the use of Key.NAME instead of KEY_NAME to get key names
 */
struct Key {
	@disable this();
	/// Map key names to their deimos values
	template opDispatch(string key)
	{
		static if(key.length > 0) {
			static if(key.toUpper()[0] == 'F' && (key[1]>'0'&&key[1]<='9')) {
				enum opDispatch = mixin("nc.KEY_F("~key[1..$]~")");
			} else {
				enum opDispatch = mixin("nc.KEY_"~key.toUpper());
			}
		}
	}
}

/**
 * ACS (alternative character set) name wrapper
 *
 * Allows the use of ACS.Name instead of ACS_NAME to get alternative character sets
 */
struct ACS {
	@disable this();
	/// Map key names to their deimos values
	static CharType opDispatch(string key)() @property nothrow {
		return mixin("nc.ACS_"~key.toUpper());
	}
}

/// Position structure
struct Pos {
	/// The y coordinate (row)
	int y;
	/// The x coordinate (column)
	int x;
	/// The row - an alias for y
	alias row = y;
	/// The column - an alias for x
	alias col = x;
	/**
	 * Create a position
	 *
	 * 		_y	=	The y coordinate (row)
	 * 		_x	=	The x coordinate (column)
	 */
	this(int _y, int _x) nothrow {
		this.y = _y;
		this.x = _x;
	}
}

/// Create an audio beep
void beep() {
	nc.beep();
}
/// Create a visual flash as a "bell"
void flash() {
	nc.flash();
}

/// Set the file descriptor to use for typeahead
void typeahead(File fd) {
	if(nc.typeahead(fd.fileno()) != nc.OK) {
		throw new NCursesException("Could not set typeahead variable");
	}
}

/// Get the "kill" character
auto killchar() @property {
	return nc.killchar();
}
/// Get the "erase" character
auto erasechar() @property {
	return nc.erasechar();
}
