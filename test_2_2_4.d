module test_2_2_4; unittest {

import  helpers.d_shims;

import helpers.d_shims;
import helpers.testThreeCases : testFulfilled;
import helpers.testThreeCases : testRejected;

import helpers.d_adapter;
alias resolved = adapter.resolved;
alias rejected = adapter.rejected;
alias deferred = adapter.deferred;

struct Dummy { string dummy = "dummy"; } Dummy dummy; // we fulfill or reject with this when we don't intend to test against it

describe("2.2.4: `onFulfilled` or `onRejected` must not be called until the execution context stack contains only " ~
         "platform code.", delegate () {
    describe("`then` returns before the promise becomes fulfilled or rejected", delegate () {
        testFulfilled(dummy, (Promise!Dummy promise, void delegate() done) {
            auto thenHasReturned = false;

            promise.then(delegate /*onFulfilled*/(value) {
                assert_.strictEqual(thenHasReturned, true);
                done();
            });

            thenHasReturned = true;
        });
        testRejected(dummy, (Promise!Dummy promise, void delegate() done) {
            auto thenHasReturned = false;

            promise.then(null, delegate /*onRejected*/() {
                assert_.strictEqual(thenHasReturned, true);
                done();
            });

            thenHasReturned = true;
        });
    });

    describe("Clean-stack execution ordering tests (fulfillment case)", delegate () {
        specify("when `onFulfilled` is added immediately before the promise is fulfilled",
                delegate () {
            auto d = deferred!Dummy();
            auto onFulfilledCalled = false;

            d.promise.then(delegate /*onFulfilled*/(value) {
                onFulfilledCalled = true;
            });

            d.resolve(dummy);

            assert_.strictEqual(onFulfilledCalled, false);
        });

        specify("when `onFulfilled` is added immediately after the promise is fulfilled",
                delegate () {
            auto d = deferred!Dummy();
            auto onFulfilledCalled = false;

            d.resolve(dummy);

            d.promise.then(delegate /*onFulfilled*/(value) {
                onFulfilledCalled = true;
            });

            assert_.strictEqual(onFulfilledCalled, false);
        });

        specify("when one `onFulfilled` is added inside another `onFulfilled`", delegate (done) {
            auto promise = resolved();
            auto firstOnFulfilledFinished = false;

            promise.then(delegate () {
                promise.then(delegate () {
                    assert_.strictEqual(firstOnFulfilledFinished, true);
                    done();
                });
                firstOnFulfilledFinished = true;
            });
        });

        specify("when `onFulfilled` is added inside an `onRejected`", delegate (done) {
            auto promise = rejected();
            auto promise2 = resolved();
            auto firstOnRejectedFinished = false;

            promise.then(null, delegate () {
                promise2.then(delegate () {
                    assert_.strictEqual(firstOnRejectedFinished, true);
                    done();
                });
                firstOnRejectedFinished = true;
            });
        });

        specify("when the promise is fulfilled asynchronously", delegate (done) {
            auto d = deferred!Dummy();
            auto firstStackFinished = false;

            setTimeout(delegate () {
                d.resolve(dummy);
                firstStackFinished = true;
            }, 0);

            d.promise.then(delegate () {
                assert_.strictEqual(firstStackFinished, true);
                done();
            });
        });
    });

    describe("Clean-stack execution ordering tests (rejection case)", delegate () {
        specify("when `onRejected` is added immediately before the promise is rejected",
                delegate () {
            auto d = deferred!Dummy();
            auto onRejectedCalled = false;

            d.promise.then(null, delegate /*onRejected*/() {
                onRejectedCalled = true;
            });

            d.reject(dummy);

            assert_.strictEqual(onRejectedCalled, false);
        });

        specify("when `onRejected` is added immediately after the promise is rejected",
                delegate () {
            auto d = deferred!Dummy();
            auto onRejectedCalled = false;

            d.reject(dummy);

            d.promise.then(null, delegate /*onRejected*/() {
                onRejectedCalled = true;
            });

            assert_.strictEqual(onRejectedCalled, false);
        });

        specify("when `onRejected` is added inside an `onFulfilled`", delegate (done) {
            auto promise = resolved();
            auto promise2 = rejected();
            auto firstOnFulfilledFinished = false;

            promise.then(delegate () {
                promise2.then(null, delegate () {
                    assert_.strictEqual(firstOnFulfilledFinished, true);
                    done();
                });
                firstOnFulfilledFinished = true;
            });
        });

        specify("when one `onRejected` is added inside another `onRejected`", delegate (done) {
            auto promise = rejected();
            auto firstOnRejectedFinished = false;

            promise.then(null, delegate () {
                promise.then(null, delegate () {
                    assert_.strictEqual(firstOnRejectedFinished, true);
                    done();
                });
                firstOnRejectedFinished = true;
            });
        });

        specify("when the promise is rejected asynchronously", delegate (done) {
            auto d = deferred!Dummy();
            auto firstStackFinished = false;

            setTimeout(delegate () {
                d.reject(dummy);
                firstStackFinished = true;
            }, 0);

            d.promise.then(null, delegate () {
                assert_.strictEqual(firstStackFinished, true);
                done();
            });
        });
    });
});
}
