module helpers.d_shims;

public import ae.utils.promise : Promise;

// node.js --------------------------------------------------------------------

import core.time;
import ae.net.asockets;
import ae.sys.timing;

void setTimeout(void delegate() dg, int ms)
{
	ae.sys.timing.setTimeout(dg, ms.msecs);
}

// mocha.js -------------------------------------------------------------------

import std.stdio;

private string indent;

void describe(string what, void delegate() dg)
{
	writeln(indent, "- ", what);
	{
		indent ~= "  ";
		scope(exit) indent = indent[0 .. $-2];
		dg();
	}
	// writeln(indent, "> OK");
}

void specify(string name, void delegate() doIt)
{
	writeln(indent, "- ", name);
	doIt();
	socketManager.loop();
	writeln(indent, "  OK");
}

void specify(string name, void delegate(void delegate() done) doIt)
{
	writeln(indent, "- ", name);

	bool isDone;

	doIt({
		assert(!isDone);
		isDone = true;
	});

	socketManager.loop();

	assert(isDone, "done() not called");

	writeln(indent, "  OK");
}

// assert ----------------------------------------------------------------------

import std.conv;

struct assert_
{
static:
	void strictEqual(T)(T a, T b)
	{
		assert(a is b, text(a) ~ " != " ~ text(b));
	}
}
