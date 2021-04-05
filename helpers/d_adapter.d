module helpers.d_adapter;

import ae.utils.promise;

struct adapter
{
static:
	Promise!void resolved()
	{
		auto p = new Promise!void;
		p.fulfill();
		return p;
	}

	Promise!T resolved(T)(T value)
	{
		auto p = new Promise!T;
		p.fulfill(value);
		return p;
	}

	Promise!(T, E) rejected(T, E = Exception)(E error)
	{
		auto p = new Promise!T;
		p.reject(error);
		return p;
	}

	struct Deferred(T, E = Exception)
	{
		Promise!T promise;

		static if (is(T == void))
			void resolve() { promise.fulfill(); }
		else
			void resolve(T value) { promise.fulfill(value); }
		void reject(E reason) { promise.reject(reason); }
	}

	Deferred!T deferred(T)()
	{
		return Deferred!T(new Promise!T);
	}
}
