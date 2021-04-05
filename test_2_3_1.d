module test_2_3_1; unittest {

import std.exception;

import core.exception;

import  helpers.d_shims;

import helpers.d_shims;

import helpers.d_adapter;
alias resolved = adapter.resolved;
alias rejected = adapter.rejected;

struct Dummy { string dummy = "dummy"; } Dummy dummy; // we fulfill or reject with this when we don't intend to test against it

describe("2.3.1: If `promise` and `x` refer to the same object, reject `promise` with a `TypeError' as the reason.",
         delegate () {
    auto e = collectException!Throwable(
        specify("via return from a fulfilled promise", delegate () {
            Promise!Dummy promise;
            promise = resolved(dummy).then(delegate (Dummy value) {
                return promise;
            });
        })
    );
    assert(cast(AssertError)e && e.msg == "Attempting to resolve a promise with itself");

    e = collectException!Throwable(
        specify("via return from a rejected promise", delegate (done) {
            Promise!Dummy promise;
            promise = rejected!Dummy(/*dummy*/null).then(null, delegate (error) {
                return promise;
            });
        })
    );
    assert(cast(AssertError)e && e.msg == "Attempting to resolve a promise with itself");
});
}
