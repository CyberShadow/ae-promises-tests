module test_2_3_1; unittest {

import  helpers.d_shims;

import helpers.d_shims;

import helpers.d_adapter;
alias resolved = adapter.resolved;
alias rejected = adapter.rejected;

struct Dummy { string dummy = "dummy"; } Dummy dummy; // we fulfill or reject with this when we don't intend to test against it

describe("2.3.1: If `promise` and `x` refer to the same object, reject `promise` with a `TypeError' as the reason.",
         delegate () {
    specify("via return from a fulfilled promise", delegate (done) {
        auto promise = resolved(dummy).then(delegate () {
            return promise;
        });

        promise.then(null, delegate (reason) {
            assert(reason instanceof TypeError);
            done();
        });
    });

    specify("via return from a rejected promise", delegate (done) {
        auto promise = rejected(dummy).then(null, delegate () {
            return promise;
        });

        promise.then(null, delegate (reason) {
            assert(reason instanceof TypeError);
            done();
        });
    });
});
}
