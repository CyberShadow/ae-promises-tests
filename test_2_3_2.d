module test_2_3_2; unittest {

import  helpers.d_shims;

import helpers.d_shims;

import helpers.d_adapter;
alias resolved = adapter.resolved;
alias rejected = adapter.rejected;
alias deferred = adapter.deferred;

struct Dummy { string dummy = "dummy"; } Dummy dummy; // we fulfill or reject with this when we don't intend to test against it
struct Sentinel { string sentinel = "sentinel"; } Sentinel sentinel; // a sentinel fulfillment value to test for with strict equality

delegate /*testPromiseResolution*/(xFactory, test) {
    specify("via return from a fulfilled promise", delegate (done) {
        auto promise = resolved(dummy).then(delegate /*onBasePromiseFulfilled*/() {
            return xFactory();
        });

        test(promise, done);
    });

    specify("via return from a rejected promise", delegate (done) {
        auto promise = rejected!Dummy(/*dummy*/null).then(null, delegate /*onBasePromiseRejected*/() {
            return xFactory();
        });

        test(promise, done);
    });
}

describe("2.3.2: If `x` is a promise, adopt its state", delegate () {
    describe("2.3.2.1: If `x` is pending, `promise` must remain pending until `x` is fulfilled or rejected.",
             delegate () {
        auto xFactory() {
            return deferred().promise;
        }

        testPromiseResolution(xFactory, delegate (promise, done) {
            auto wasFulfilled = false;
            auto wasRejected = false;

            promise.then(
                auto onPromiseFulfilled() {
                    wasFulfilled = true;
                },
                auto onPromiseRejected() {
                    wasRejected = true;
                }
            );

            setTimeout(delegate () {
                assert_.strictEqual(wasFulfilled, false);
                assert_.strictEqual(wasRejected, false);
                done();
            }, 100);
        });
    });

    describe("2.3.2.2: If/when `x` is fulfilled, fulfill `promise` with the same value.", delegate () {
        describe("`x` is already-fulfilled", delegate () {
            auto xFactory() {
                return resolved(sentinel);
            }

            testPromiseResolution(xFactory, delegate (promise, done) {
                promise.then(delegate /*onPromiseFulfilled*/(value) {
                    assert_.strictEqual(value, sentinel);
                    done();
                });
            });
        });

        describe("`x` is eventually-fulfilled", delegate () {
            auto d = null;

            auto xFactory() {
                d = deferred!Dummy();
                setTimeout(delegate () {
                    d.resolve(sentinel);
                }, 50);
                return d.promise;
            }

            testPromiseResolution(xFactory, delegate (promise, done) {
                promise.then(delegate /*onPromiseFulfilled*/(value) {
                    assert_.strictEqual(value, sentinel);
                    done();
                });
            });
        });
    });

    describe("2.3.2.3: If/when `x` is rejected, reject `promise` with the same reason.", delegate () {
        describe("`x` is already-rejected", delegate () {
            auto xFactory() {
                return rejected(sentinel);
            }

            testPromiseResolution(xFactory, delegate (promise, done) {
                promise.then(null, delegate /*onPromiseRejected*/(reason) {
                    assert_.strictEqual(reason, sentinel);
                    done();
                });
            });
        });

        describe("`x` is eventually-rejected", delegate () {
            auto d = null;

            auto xFactory() {
                d = deferred!Dummy();
                setTimeout(delegate () {
                    d.reject(sentinel);
                }, 50);
                return d.promise;
            }

            testPromiseResolution(xFactory, delegate (promise, done) {
                promise.then(null, delegate /*onPromiseRejected*/(reason) {
                    assert_.strictEqual(reason, sentinel);
                    done();
                });
            });
        });
    });
});
}
