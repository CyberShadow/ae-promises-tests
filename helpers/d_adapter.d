module helpers.d_adapter;

import ae.utils.promise_;

struct adapter
{
static:
	Promise!T resolved(T)(T value)
	{
		auto p = new Promise!T;
		p.fulfill(value);
		return p;
	}

	Promise!T rejected(T)(E error)
	{
		auto p = new Promise!T;
		p.reject(error);
		return p;
	}

	struct Deferred(T, E = Exception)
	{
		Promise!T promise;

		void resolve(T value) { promise.fulfill(value); }
		void reject(E reason) { promise.reject(reason); }
	}

	Deferred!T deferred(T)()
	{
		return Deferred!T(new Promise!T);
	}
}
