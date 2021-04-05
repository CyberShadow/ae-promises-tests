module test_2_1_2; unittest {

import  helpers.d_shims;

import helpers.d_shims;
import helpers.testThreeCases : testFulfilled;

import helpers.d_adapter;
alias deferred = adapter.deferred;

struct Dummy { string dummy = "dummy"; } Dummy dummy; // we fulfill or reject with this when we don't intend to test against it

describe("2.1.2.1: When fulfilled, a promise: must not transition to any other state.", delegate () {
    testFulfilled(dummy, (Promise!Dummy promise, void delegate() done) {
        auto onFulfilledCalled = false;

        promise.then(delegate /*onFulfilled*/(value) {
            onFulfilledCalled = true;
        }, delegate /*onRejected*/(error) {
            assert_.strictEqual(onFulfilledCalled, false);
            done();
        });

        setTimeout(done, 100);
    });

    if (false) // 2.3.3.3.3
    specify("trying to fulfill then immediately reject", delegate (done) {
        auto d = deferred!Dummy();
        auto onFulfilledCalled = false;

        d.promise.then(delegate /*onFulfilled*/(value) {
            onFulfilledCalled = true;
        }, delegate /*onRejected*/(error) {
            assert_.strictEqual(onFulfilledCalled, false);
            done();
        });

        d.resolve(dummy);
        d.reject(null);
        setTimeout(done, 100);
    });

    if (false) // 2.3.3.3.3
    specify("trying to fulfill then reject, delayed", delegate (done) {
        auto d = deferred!Dummy();
        auto onFulfilledCalled = false;

        d.promise.then(delegate /*onFulfilled*/(value) {
            onFulfilledCalled = true;
        }, delegate /*onRejected*/(error) {
            assert_.strictEqual(onFulfilledCalled, false);
            done();
        });

        setTimeout(delegate () {
            d.resolve(dummy);
            d.reject(null);
        }, 50);
        setTimeout(done, 100);
    });

    if (false) // 2.3.3.3.3
    specify("trying to fulfill immediately then reject delayed", delegate (done) {
        auto d = deferred!Dummy();
        auto onFulfilledCalled = false;

        d.promise.then(delegate /*onFulfilled*/(value) {
            onFulfilledCalled = true;
        }, delegate /*onRejected*/(error) {
            assert_.strictEqual(onFulfilledCalled, false);
            done();
        });

        d.resolve(dummy);
        setTimeout(delegate () {
            d.reject(null);
        }, 50);
        setTimeout(done, 100);
    });
});
}
