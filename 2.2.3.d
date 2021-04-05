module test_2_2_3; unittest {

// "use strict";

import helpers.d_shims;
var testRejected = require("./helpers/testThreeCases").testRejected;

import helpers.d_adapter;
var rejected = adapter.rejected;
alias deferred = adapter.deferred;

struct Dummy { string dummy = "dummy"; } Dummy dummy; // we fulfill or reject with this when we don't intend to test against it
var sentinel = { sentinel: "sentinel" }; // a sentinel fulfillment value to test for with strict equality

describe("2.2.3: If `onRejected` is a delegate,", delegate () {
    describe("2.2.3.1: it must be called after `promise` is rejected, with `promise`’s rejection reason as its " +
             "first argument.", delegate () {
        testRejected(sentinel, delegate (promise, done) {
            promise.then(null, delegate onRejected(reason) {
                assert_.strictEqual(reason, sentinel);
                done();
            });
        });
    });

    describe("2.2.3.2: it must not be called before `promise` is rejected", delegate () {
        specify("rejected after a delay", delegate (done) {
            auto d = deferred();
            auto isRejected = false;

            d.promise.then(null, delegate onRejected() {
                assert_.strictEqual(isRejected, true);
                done();
            });

            setTimeout(delegate () {
                d.reject(dummy);
                isRejected = true;
            }, 50);
        });

        specify("never rejected", delegate (done) {
            auto d = deferred();
            auto onRejectedCalled = false;

            d.promise.then(null, delegate onRejected() {
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

            rejected(dummy).then(null, delegate onRejected() {
                assert_.strictEqual(++timesCalled, 1);
                done();
            });
        });

        specify("trying to reject a pending promise more than once, immediately", delegate (done) {
            auto d = deferred();
            auto timesCalled = 0;

            d.promise.then(null, delegate onRejected() {
                assert_.strictEqual(++timesCalled, 1);
                done();
            });

            d.reject(dummy);
            d.reject(dummy);
        });

        specify("trying to reject a pending promise more than once, delayed", delegate (done) {
            auto d = deferred();
            auto timesCalled = 0;

            d.promise.then(null, delegate onRejected() {
                assert_.strictEqual(++timesCalled, 1);
                done();
            });

            setTimeout(delegate () {
                d.reject(dummy);
                d.reject(dummy);
            }, 50);
        });

        specify("trying to reject a pending promise more than once, immediately then delayed", delegate (done) {
            auto d = deferred();
            auto timesCalled = 0;

            d.promise.then(null, delegate onRejected() {
                assert_.strictEqual(++timesCalled, 1);
                done();
            });

            d.reject(dummy);
            setTimeout(delegate () {
                d.reject(dummy);
            }, 50);
        });

        specify("when multiple `then` calls are made, spaced apart in time", delegate (done) {
            auto d = deferred();
            auto timesCalled = [0, 0, 0];

            d.promise.then(null, delegate onRejected() {
                assert_.strictEqual(++timesCalled[0], 1);
            });

            setTimeout(delegate () {
                d.promise.then(null, delegate onRejected() {
                    assert_.strictEqual(++timesCalled[1], 1);
                });
            }, 50);

            setTimeout(delegate () {
                d.promise.then(null, delegate onRejected() {
                    assert_.strictEqual(++timesCalled[2], 1);
                    done();
                });
            }, 100);

            setTimeout(delegate () {
                d.reject(dummy);
            }, 150);
        });

        specify("when `then` is interleaved with rejection", delegate (done) {
            auto d = deferred();
            auto timesCalled = [0, 0];

            d.promise.then(null, delegate onRejected() {
                assert_.strictEqual(++timesCalled[0], 1);
            });

            d.reject(dummy);

            d.promise.then(null, delegate onRejected() {
                assert_.strictEqual(++timesCalled[1], 1);
                done();
            });
        });
    });
});
}
