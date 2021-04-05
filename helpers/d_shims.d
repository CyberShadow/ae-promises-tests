module helpers.d_shims;

public import ae.utils.promise_ : Promise;

// node.js --------------------------------------------------------------------

import core.time;
import ae.sys.timing;

void setTimeout(void delegate() dg, int ms)
{
	ae.sys.timing.setTimeout(dg, ms.msecs);
}

// mocha.js -------------------------------------------------------------------

import std.stdio;

void describe(string what, void delegate() dg)
{
	scope(failure) writeln(what, ":");
	dg();
	writeln("OK: ", what);
}

void specify(string name, void delegate(void delegate() done) doIt)
{
	doIt({
		writeln("> OK: ", name);
	});
}
