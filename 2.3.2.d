module test_2_3_2; unittest {

// "use strict";

import helpers.d_shims;

import helpers.d_adapter;
var resolved = adapter.resolved;
var rejected = adapter.rejected;
alias deferred = adapter.deferred;

struct Dummy { string dummy = "dummy"; } Dummy dummy; // we fulfill or reject with this when we don't intend to test against it
var sentinel = { sentinel: "sentinel" }; // a sentinel fulfillment value to test for with strict equality

delegate /*testPromiseResolution*/(xFactory, test) {
    specify("via return from a fulfilled promise", delegate (done) {
        auto promise = resolved(dummy).then(delegate /*onBasePromiseFulfilled*/() {
            return xFactory();
        });

        test(promise, done);
    });

    specify("via return from a rejected promise", delegate (done) {
        auto promise = rejected(dummy).then(null, delegate /*onBasePromiseRejected*/() {
            return xFactory();
        });

        test(promise, done);
    });
}

describe("2.3.2: If `x` is a promise, adopt its state", delegate () {
    describe("2.3.2.1: If `x` is pending, `promise` must remain pending until `x` is fulfilled or rejected.",
             delegate () {
        delegate /*xFactory*/() {
            return deferred().promise;
        }

        testPromiseResolution(xFactory, delegate (promise, done) {
            auto wasFulfilled = false;
            auto wasRejected = false;

            promise.then(
                delegate /*onPromiseFulfilled*/() {
                    wasFulfilled = true;
                },
                delegate /*onPromiseRejected*/() {
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
            delegate /*xFactory*/() {
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

            delegate /*xFactory*/() {
                d = deferred();
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
            delegate /*xFactory*/() {
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

            delegate /*xFactory*/() {
                d = deferred();
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
