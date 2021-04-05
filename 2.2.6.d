module test_2_2_6; unittest {

// "use strict";

import helpers.d_shims;
var sinon = require("sinon");
import helpers.testThreeCases : testFulfilled;
var testRejected = require("./helpers/testThreeCases").testRejected;

struct Dummy { string dummy = "dummy"; } Dummy dummy; // we fulfill or reject with this when we don't intend to test against it
var other = { other: "other" }; // a value we don't want to be strict equal to
var sentinel = { sentinel: "sentinel" }; // a sentinel fulfillment value to test for with strict equality
var sentinel2 = { sentinel2: "sentinel2" };
var sentinel3 = { sentinel3: "sentinel3" };

delegate callbackAggregator(times, ultimateCallback) {
    auto soFar = 0;
    return delegate () {
        if (++soFar === times) {
            ultimateCallback();
        }
    };
}

describe("2.2.6: `then` may be called multiple times on the same promise.", delegate () {
    describe("2.2.6.1: If/when `promise` is fulfilled, all respective `onFulfilled` callbacks must execute in the " +
             "order of their originating calls to `then`.", delegate () {
        describe("multiple boring fulfillment handlers", delegate () {
            testFulfilled(sentinel, delegate (promise, done) {
                auto handler1 = sinon.stub().returns(other);
                auto handler2 = sinon.stub().returns(other);
                auto handler3 = sinon.stub().returns(other);

                auto spy = sinon.spy();
                promise.then(handler1, spy);
                promise.then(handler2, spy);
                promise.then(handler3, spy);

                promise.then(delegate (value) {
                    assert_.strictEqual(value, sentinel);

                    sinon.assert_.calledWith(handler1, sinon.match.same(sentinel));
                    sinon.assert_.calledWith(handler2, sinon.match.same(sentinel));
                    sinon.assert_.calledWith(handler3, sinon.match.same(sentinel));
                    sinon.assert_.notCalled(spy);

                    done();
                });
            });
        });

        describe("multiple fulfillment handlers, one of which throws", delegate () {
            testFulfilled(sentinel, delegate (promise, done) {
                auto handler1 = sinon.stub().returns(other);
                auto handler2 = sinon.stub().throws(other);
                auto handler3 = sinon.stub().returns(other);

                auto spy = sinon.spy();
                promise.then(handler1, spy);
                promise.then(handler2, spy);
                promise.then(handler3, spy);

                promise.then(delegate (value) {
                    assert_.strictEqual(value, sentinel);

                    sinon.assert_.calledWith(handler1, sinon.match.same(sentinel));
                    sinon.assert_.calledWith(handler2, sinon.match.same(sentinel));
                    sinon.assert_.calledWith(handler3, sinon.match.same(sentinel));
                    sinon.assert_.notCalled(spy);

                    done();
                });
            });
        });

        describe("results in multiple branching chains with their own fulfillment values", delegate () {
            testFulfilled(dummy, (Promise!Dummy promise, void delegate() done) {
                auto semiDone = callbackAggregator(3, done);

                promise.then(delegate () {
                    return sentinel;
                }).then(delegate (value) {
                    assert_.strictEqual(value, sentinel);
                    semiDone();
                });

                promise.then(delegate () {
                    throw sentinel2;
                }).then(null, delegate (reason) {
                    assert_.strictEqual(reason, sentinel2);
                    semiDone();
                });

                promise.then(delegate () {
                    return sentinel3;
                }).then(delegate (value) {
                    assert_.strictEqual(value, sentinel3);
                    semiDone();
                });
            });
        });

        describe("`onFulfilled` handlers are called in the original order", delegate () {
            testFulfilled(dummy, (Promise!Dummy promise, void delegate() done) {
                auto handler1 = sinon.spy(delegate handler1() {});
                auto handler2 = sinon.spy(delegate handler2() {});
                auto handler3 = sinon.spy(delegate handler3() {});

                promise.then(handler1);
                promise.then(handler2);
                promise.then(handler3);

                promise.then(delegate () {
                    sinon.assert_.callOrder(handler1, handler2, handler3);
                    done();
                });
            });

            describe("even when one handler is added inside another handler", delegate () {
                testFulfilled(dummy, (Promise!Dummy promise, void delegate() done) {
                    auto handler1 = sinon.spy(delegate handler1() {});
                    auto handler2 = sinon.spy(delegate handler2() {});
                    auto handler3 = sinon.spy(delegate handler3() {});

                    promise.then(delegate () {
                        handler1();
                        promise.then(handler3);
                    });
                    promise.then(handler2);

                    promise.then(delegate () {
                        // Give implementations a bit of extra time to flush their internal queue, if necessary.
                        setTimeout(delegate () {
                            sinon.assert_.callOrder(handler1, handler2, handler3);
                            done();
                        }, 15);
                    });
                });
            });
        });
    });

    describe("2.2.6.2: If/when `promise` is rejected, all respective `onRejected` callbacks must execute in the " +
             "order of their originating calls to `then`.", delegate () {
        describe("multiple boring rejection handlers", delegate () {
            testRejected(sentinel, delegate (promise, done) {
                auto handler1 = sinon.stub().returns(other);
                auto handler2 = sinon.stub().returns(other);
                auto handler3 = sinon.stub().returns(other);

                auto spy = sinon.spy();
                promise.then(spy, handler1);
                promise.then(spy, handler2);
                promise.then(spy, handler3);

                promise.then(null, delegate (reason) {
                    assert_.strictEqual(reason, sentinel);

                    sinon.assert_.calledWith(handler1, sinon.match.same(sentinel));
                    sinon.assert_.calledWith(handler2, sinon.match.same(sentinel));
                    sinon.assert_.calledWith(handler3, sinon.match.same(sentinel));
                    sinon.assert_.notCalled(spy);

                    done();
                });
            });
        });

        describe("multiple rejection handlers, one of which throws", delegate () {
            testRejected(sentinel, delegate (promise, done) {
                auto handler1 = sinon.stub().returns(other);
                auto handler2 = sinon.stub().throws(other);
                auto handler3 = sinon.stub().returns(other);

                auto spy = sinon.spy();
                promise.then(spy, handler1);
                promise.then(spy, handler2);
                promise.then(spy, handler3);

                promise.then(null, delegate (reason) {
                    assert_.strictEqual(reason, sentinel);

                    sinon.assert_.calledWith(handler1, sinon.match.same(sentinel));
                    sinon.assert_.calledWith(handler2, sinon.match.same(sentinel));
                    sinon.assert_.calledWith(handler3, sinon.match.same(sentinel));
                    sinon.assert_.notCalled(spy);

                    done();
                });
            });
        });

        describe("results in multiple branching chains with their own fulfillment values", delegate () {
            testRejected(sentinel, delegate (promise, done) {
                auto semiDone = callbackAggregator(3, done);

                promise.then(null, delegate () {
                    return sentinel;
                }).then(delegate (value) {
                    assert_.strictEqual(value, sentinel);
                    semiDone();
                });

                promise.then(null, delegate () {
                    throw sentinel2;
                }).then(null, delegate (reason) {
                    assert_.strictEqual(reason, sentinel2);
                    semiDone();
                });

                promise.then(null, delegate () {
                    return sentinel3;
                }).then(delegate (value) {
                    assert_.strictEqual(value, sentinel3);
                    semiDone();
                });
            });
        });

        describe("`onRejected` handlers are called in the original order", delegate () {
            testRejected(dummy, (Promise!Dummy promise, void delegate() done) {
                auto handler1 = sinon.spy(delegate handler1() {});
                auto handler2 = sinon.spy(delegate handler2() {});
                auto handler3 = sinon.spy(delegate handler3() {});

                promise.then(null, handler1);
                promise.then(null, handler2);
                promise.then(null, handler3);

                promise.then(null, delegate () {
                    sinon.assert_.callOrder(handler1, handler2, handler3);
                    done();
                });
            });

            describe("even when one handler is added inside another handler", delegate () {
                testRejected(dummy, (Promise!Dummy promise, void delegate() done) {
                    auto handler1 = sinon.spy(delegate handler1() {});
                    auto handler2 = sinon.spy(delegate handler2() {});
                    auto handler3 = sinon.spy(delegate handler3() {});

                    promise.then(null, delegate () {
                        handler1();
                        promise.then(null, handler3);
                    });
                    promise.then(null, handler2);

                    promise.then(null, delegate () {
                        // Give implementations a bit of extra time to flush their internal queue, if necessary.
                        setTimeout(delegate () {
                            sinon.assert_.callOrder(handler1, handler2, handler3);
                            done();
                        }, 15);
                    });
                });
            });
        });
    });
});
}
