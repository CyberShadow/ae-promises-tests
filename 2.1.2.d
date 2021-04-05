module test_2_1_2; unittest {

// "use strict";

import helpers.d_shims;
import helpers.testThreeCases : testFulfilled;

import helpers.d_adapter;
alias deferred = adapter.deferred;

struct Dummy { string dummy = "dummy"; } Dummy dummy; // we fulfill or reject with this when we don't intend to test against it

describe("2.1.2.1: When fulfilled, a promise: must not transition to any other state.", delegate () {
    testFulfilled(dummy, (Promise!Dummy promise, void delegate() done) {
        auto onFulfilledCalled = false;

        promise.then(delegate /*onFulfilled*/() {
            onFulfilledCalled = true;
        }, delegate /*onRejected*/() {
            assert_.strictEqual(onFulfilledCalled, false);
            done();
        });

        setTimeout(done, 100);
    });

    specify("trying to fulfill then immediately reject", delegate (done) {
        auto d = deferred();
        auto onFulfilledCalled = false;

        d.promise.then(delegate /*onFulfilled*/() {
            onFulfilledCalled = true;
        }, delegate /*onRejected*/() {
            assert_.strictEqual(onFulfilledCalled, false);
            done();
        });

        d.resolve(dummy);
        d.reject(dummy);
        setTimeout(done, 100);
    });

    specify("trying to fulfill then reject, delayed", delegate (done) {
        auto d = deferred();
        auto onFulfilledCalled = false;

        d.promise.then(delegate /*onFulfilled*/() {
            onFulfilledCalled = true;
        }, delegate /*onRejected*/() {
            assert_.strictEqual(onFulfilledCalled, false);
            done();
        });

        setTimeout(delegate () {
            d.resolve(dummy);
            d.reject(dummy);
        }, 50);
        setTimeout(done, 100);
    });

    specify("trying to fulfill immediately then reject delayed", delegate (done) {
        auto d = deferred();
        auto onFulfilledCalled = false;

        d.promise.then(delegate /*onFulfilled*/() {
            onFulfilledCalled = true;
        }, delegate /*onRejected*/() {
            assert_.strictEqual(onFulfilledCalled, false);
            done();
        });

        d.resolve(dummy);
        setTimeout(delegate () {
            d.reject(dummy);
        }, 50);
        setTimeout(done, 100);
    });
});
}
