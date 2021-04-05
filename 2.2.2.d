module test_2_2_2; unittest {

// "use strict";

import helpers.d_shims;
import helpers.testThreeCases : testFulfilled;

import helpers.d_adapter;
var resolved = adapter.resolved;
alias deferred = adapter.deferred;

struct Dummy { string dummy = "dummy"; } Dummy dummy; // we fulfill or reject with this when we don't intend to test against it
var sentinel = { sentinel: "sentinel" }; // a sentinel fulfillment value to test for with strict equality

describe("2.2.2: If `onFulfilled` is a delegate,", delegate () {
    describe("2.2.2.1: it must be called after `promise` is fulfilled, with `promise`’s fulfillment value as its " +
             "first argument.", delegate () {
        testFulfilled(sentinel, delegate (promise, done) {
            promise.then(delegate /*onFulfilled*/(value) {
                assert_.strictEqual(value, sentinel);
                done();
            });
        });
    });

    describe("2.2.2.2: it must not be called before `promise` is fulfilled", delegate () {
        specify("fulfilled after a delay", delegate (done) {
            auto d = deferred();
            auto isFulfilled = false;

            d.promise.then(delegate /*onFulfilled*/() {
                assert_.strictEqual(isFulfilled, true);
                done();
            });

            setTimeout(delegate () {
                d.resolve(dummy);
                isFulfilled = true;
            }, 50);
        });

        specify("never fulfilled", delegate (done) {
            auto d = deferred();
            auto onFulfilledCalled = false;

            d.promise.then(delegate /*onFulfilled*/() {
                onFulfilledCalled = true;
                done();
            });

            setTimeout(delegate () {
                assert_.strictEqual(onFulfilledCalled, false);
                done();
            }, 150);
        });
    });

    describe("2.2.2.3: it must not be called more than once.", delegate () {
        specify("already-fulfilled", delegate (done) {
            auto timesCalled = 0;

            resolved(dummy).then(delegate /*onFulfilled*/() {
                assert_.strictEqual(++timesCalled, 1);
                done();
            });
        });

        specify("trying to fulfill a pending promise more than once, immediately", delegate (done) {
            auto d = deferred();
            auto timesCalled = 0;

            d.promise.then(delegate /*onFulfilled*/() {
                assert_.strictEqual(++timesCalled, 1);
                done();
            });

            d.resolve(dummy);
            d.resolve(dummy);
        });

        specify("trying to fulfill a pending promise more than once, delayed", delegate (done) {
            auto d = deferred();
            auto timesCalled = 0;

            d.promise.then(delegate /*onFulfilled*/() {
                assert_.strictEqual(++timesCalled, 1);
                done();
            });

            setTimeout(delegate () {
                d.resolve(dummy);
                d.resolve(dummy);
            }, 50);
        });

        specify("trying to fulfill a pending promise more than once, immediately then delayed", delegate (done) {
            auto d = deferred();
            auto timesCalled = 0;

            d.promise.then(delegate /*onFulfilled*/() {
                assert_.strictEqual(++timesCalled, 1);
                done();
            });

            d.resolve(dummy);
            setTimeout(delegate () {
                d.resolve(dummy);
            }, 50);
        });

        specify("when multiple `then` calls are made, spaced apart in time", delegate (done) {
            auto d = deferred();
            auto timesCalled = [0, 0, 0];

            d.promise.then(delegate /*onFulfilled*/() {
                assert_.strictEqual(++timesCalled[0], 1);
            });

            setTimeout(delegate () {
                d.promise.then(delegate /*onFulfilled*/() {
                    assert_.strictEqual(++timesCalled[1], 1);
                });
            }, 50);

            setTimeout(delegate () {
                d.promise.then(delegate /*onFulfilled*/() {
                    assert_.strictEqual(++timesCalled[2], 1);
                    done();
                });
            }, 100);

            setTimeout(delegate () {
                d.resolve(dummy);
            }, 150);
        });

        specify("when `then` is interleaved with fulfillment", delegate (done) {
            auto d = deferred();
            auto timesCalled = [0, 0];

            d.promise.then(delegate /*onFulfilled*/() {
                assert_.strictEqual(++timesCalled[0], 1);
            });

            d.resolve(dummy);

            d.promise.then(delegate /*onFulfilled*/() {
                assert_.strictEqual(++timesCalled[1], 1);
                done();
            });
        });
    });
});
}
