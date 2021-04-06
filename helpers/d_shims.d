module helpers.d_shims;

public import ae.utils.promise : Promise;

// node.js --------------------------------------------------------------------

import core.memory;
import core.time;
import ae.net.asockets;
import ae.sys.timing;
import ae.utils.meta;

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
	GC.collect();
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
	GC.collect();

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

// sinon.js --------------------------------------------------------------------

struct sinon
{
static:
	size_t callIndex;

	class Stub(R, Args...)
	{
		static struct Call { size_t callIndex; Args args; }
		Call[] calls;
		BoxVoid!R returnValue;
		Throwable throwValue;

		R opCall(Args args)
		{
			calls ~= Call(callIndex++, args);
			if (throwValue)
				throw throwValue;
			return unboxVoid(returnValue);
		}

		@property R delegate(Args) dg() { return &opCall; }
		alias dg this;

		static if (!is(R == void)) auto returns(R value) { returnValue = value; return this; }
		auto throws(Throwable value) { this.throwValue = value; return this; }
	}
	auto stub(R, Args...)() { return new Stub!(R, Args)(); }

	auto spy(R, Args...)() { return new Stub!(R, Args)(); }

	struct assert_
	{
	static:
		void calledWith(R, Args...)(Stub!(R, Args) stub, bool delegate(Args) matcher)
		{
			assert(stub.calls.length == 1 && matcher(stub.calls[0].args));
		}

		void notCalled(R, Args...)(Stub!(R, Args) stub)
		{
			assert(stub.calls.length == 0);
		}

		void callOrder(R, Args...)(scope Stub!(R, Args)[] stubs...)
		{
			foreach (i; 1 .. stubs.length)
				assert(
					stubs[i-1].calls.length == 1 &&
					stubs[i  ].calls.length == 1 &&
					stubs[i-1].calls[0].callIndex <
					stubs[i  ].calls[0].callIndex
				);
		}
	}

	struct match
	{
	static:
		bool delegate(Args) same(Args...)(Args args)
		{
			return (Args args2) { return args == args2; };
		}
	}
}
