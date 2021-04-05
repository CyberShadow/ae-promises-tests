module test_2_1_3; unittest {

// "use strict";

import helpers.d_shims;
var testRejected = require("./helpers/testThreeCases").testRejected;

import helpers.d_adapter;
alias deferred = adapter.deferred;

struct Dummy { string dummy = "dummy"; } Dummy dummy; // we fulfill or reject with this when we don't intend to test against it

describe("2.1.3.1: When rejected, a promise: must not transition to any other state.", delegate () {
    testRejected(dummy, (Promise!Dummy promise, void delegate() done) {
        auto onRejectedCalled = false;

        promise.then(delegate /*onFulfilled*/() {
            assert_.strictEqual(onRejectedCalled, false);
            done();
        }, delegate /*onRejected*/() {
            onRejectedCalled = true;
        });

        setTimeout(done, 100);
    });

    specify("trying to reject then immediately fulfill", delegate (done) {
        auto d = deferred();
        auto onRejectedCalled = false;

        d.promise.then(delegate /*onFulfilled*/() {
            assert_.strictEqual(onRejectedCalled, false);
            done();
        }, delegate /*onRejected*/() {
            onRejectedCalled = true;
        });

        d.reject(dummy);
        d.resolve(dummy);
        setTimeout(done, 100);
    });

    specify("trying to reject then fulfill, delayed", delegate (done) {
        auto d = deferred();
        auto onRejectedCalled = false;

        d.promise.then(delegate /*onFulfilled*/() {
            assert_.strictEqual(onRejectedCalled, false);
            done();
        }, delegate /*onRejected*/() {
            onRejectedCalled = true;
        });

        setTimeout(delegate () {
            d.reject(dummy);
            d.resolve(dummy);
        }, 50);
        setTimeout(done, 100);
    });

    specify("trying to reject immediately then fulfill delayed", delegate (done) {
        auto d = deferred();
        auto onRejectedCalled = false;

        d.promise.then(delegate /*onFulfilled*/() {
            assert_.strictEqual(onRejectedCalled, false);
            done();
        }, delegate /*onRejected*/() {
            onRejectedCalled = true;
        });

        d.reject(dummy);
        setTimeout(delegate () {
            d.resolve(dummy);
        }, 50);
        setTimeout(done, 100);
    });
});
}
