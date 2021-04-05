module test_2_2_3; unittest {

import  helpers.d_shims;

import helpers.d_shims;
import helpers.testThreeCases : testRejected;

import helpers.d_adapter;
alias rejected = adapter.rejected;
alias deferred = adapter.deferred;

struct Dummy { string dummy = "dummy"; } Dummy dummy; // we fulfill or reject with this when we don't intend to test against it
auto sentinel = new Exception("sentinel"); // a sentinel fulfillment value to test for with strict equality

describe("2.2.3: If `onRejected` is a delegate,", delegate () {
    describe("2.2.3.1: it must be called after `promise` is rejected, with `promise`’s rejection reason as its " ~
             "first argument.", delegate () {
        testRejected!Dummy(sentinel, delegate (promise, done) {
            promise.then(null, delegate /*onRejected*/(reason) {
                assert_.strictEqual(reason, sentinel);
                done();
            });
        });
    });

    describe("2.2.3.2: it must not be called before `promise` is rejected", delegate () {
        specify("rejected after a delay", delegate (done) {
            auto d = deferred!Dummy();
            auto isRejected = false;

            d.promise.then(null, delegate /*onRejected*/(error) {
                assert_.strictEqual(isRejected, true);
                done();
            });

            setTimeout(delegate () {
                d.reject(null);
                isRejected = true;
            }, 50);
        });

        specify("never rejected", delegate (done) {
            auto d = deferred!Dummy();
            auto onRejectedCalled = false;

            d.promise.then(null, delegate /*onRejected*/(error) {
                onRejectedCalled = true;
                done();
            });

            setTimeout(delegate () {
                assert_.strictEqual(onRejectedCalled, false);
                done();
            }, 150);
        });
    });

    describe("2.2.3.3: it must not be called more than once.", delegate () {
        specify("already-rejected", delegate (done) {
            auto timesCalled = 0;

            rejected!Dummy(/*dummy*/null).then(null, delegate /*onRejected*/(error) {
                assert_.strictEqual(++timesCalled, 1);
                done();
            });
        });

		if (false) // 2.3.3.3.3
        specify("trying to reject a pending promise more than once, immediately", delegate (done) {
            auto d = deferred!Dummy();
            auto timesCalled = 0;

            d.promise.then(null, delegate /*onRejected*/(error) {
                assert_.strictEqual(++timesCalled, 1);
                done();
            });

            d.reject(/*dummy*/null);
            d.reject(/*dummy*/null);
        });

		if (false) // 2.3.3.3.3
        specify("trying to reject a pending promise more than once, delayed", delegate (done) {
            auto d = deferred!Dummy();
            auto timesCalled = 0;

            d.promise.then(null, delegate /*onRejected*/(error) {
                assert_.strictEqual(++timesCalled, 1);
                done();
            });

            setTimeout(delegate () {
                d.reject(/*dummy*/null);
                d.reject(/*dummy*/null);
            }, 50);
        });

		if (false) // 2.3.3.3.3
        specify("trying to reject a pending promise more than once, immediately then delayed", delegate (done) {
            auto d = deferred!Dummy();
            auto timesCalled = 0;

            d.promise.then(null, delegate /*onRejected*/(error) {
                assert_.strictEqual(++timesCalled, 1);
                done();
            });

            d.reject(/*dummy*/null);
            setTimeout(delegate () {
                d.reject(/*dummy*/null);
            }, 50);
        });

        specify("when multiple `then` calls are made, spaced apart in time", delegate (done) {
            auto d = deferred!Dummy();
            auto timesCalled = [0, 0, 0];

            d.promise.then(null, delegate /*onRejected*/(error) {
                assert_.strictEqual(++timesCalled[0], 1);
            });

            setTimeout(delegate () {
                d.promise.then(null, delegate /*onRejected*/(error) {
                    assert_.strictEqual(++timesCalled[1], 1);
                });
            }, 50);

            setTimeout(delegate () {
                d.promise.then(null, delegate /*onRejected*/(error) {
                    assert_.strictEqual(++timesCalled[2], 1);
                    done();
                });
            }, 100);

            setTimeout(delegate () {
                d.reject(/*dummy*/null);
            }, 150);
        });

        specify("when `then` is interleaved with rejection", delegate (done) {
            auto d = deferred!Dummy();
            auto timesCalled = [0, 0];

            d.promise.then(null, delegate /*onRejected*/(error) {
                assert_.strictEqual(++timesCalled[0], 1);
            });

            d.reject(/*dummy*/null);

            d.promise.then(null, delegate /*onRejected*/(error) {
                assert_.strictEqual(++timesCalled[1], 1);
                done();
            });
        });
    });
});
}
