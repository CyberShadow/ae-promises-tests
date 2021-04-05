module test_2_2_6; unittest {

import  helpers.d_shims;

import helpers.d_shims;
// var sinon = require("sinon");
import helpers.testThreeCases : testFulfilled;
import helpers.testThreeCases : testRejected;

struct Dummy { string dummy = "dummy"; } Dummy dummy; // we fulfill or reject with this when we don't intend to test against it
Dummy other = { "other" }; // a value we don't want to be strict equal to
struct Sentinel { string sentinel = "sentinel"; } Sentinel sentinel; // a sentinel fulfillment value to test for with strict equality
Sentinel sentinel2 = { "sentinel2" };
Sentinel sentinel3 = { "sentinel3" };
auto error  = new Exception("error");
auto error2 = new Exception("error2");
auto error3 = new Exception("error3");

auto callbackAggregator(int times, void delegate() ultimateCallback) {
    auto soFar = 0;
    return delegate () {
        if (++soFar == times) {
            ultimateCallback();
        }
    };
}

describe("2.2.6: `then` may be called multiple times on the same promise.", delegate () {
    describe("2.2.6.1: If/when `promise` is fulfilled, all respective `onFulfilled` callbacks must execute in the " ~
             "order of their originating calls to `then`.", delegate () {
        describe("multiple boring fulfillment handlers", delegate () {
            testFulfilled(sentinel, delegate (Promise!Sentinel promise, done) {
                auto handler1 = sinon.stub!(Dummy, Sentinel).returns(other);
                auto handler2 = sinon.stub!(Dummy, Sentinel).returns(other);
                auto handler3 = sinon.stub!(Dummy, Sentinel).returns(other);

                auto spy = sinon.spy!(Dummy, Exception);
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
            testFulfilled(sentinel, delegate (Promise!Sentinel promise, done) {
                auto handler1 = sinon.stub!(Dummy, Sentinel).returns(other);
                auto handler2 = sinon.stub!(Dummy, Sentinel).throws(/*other*/new Exception("handler2"));
                auto handler3 = sinon.stub!(Dummy, Sentinel).returns(other);

                auto spy = sinon.spy!(Dummy, Exception);
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

                promise.then(delegate (value) {
                    return sentinel;
                }).then(delegate (value) {
                    assert_.strictEqual(value, sentinel);
                    semiDone();
                });

                promise.then(delegate (value) {
                    throw error2;
                }).then(null, delegate (reason) {
                    assert_.strictEqual(reason, error2);
                    semiDone();
                });

                promise.then(delegate (value) {
                    return sentinel3;
                }).then(delegate (value) {
                    assert_.strictEqual(value, sentinel3);
                    semiDone();
                });
            });
        });

        describe("`onFulfilled` handlers are called in the original order", delegate () {
            testFulfilled(dummy, (Promise!Dummy promise, void delegate() done) {
                auto handler1 = sinon.spy!(void, Dummy)();
                auto handler2 = sinon.spy!(void, Dummy)();
                auto handler3 = sinon.spy!(void, Dummy)();

                promise.then(handler1);
                promise.then(handler2);
                promise.then(handler3);

                promise.then(delegate (value) {
                    sinon.assert_.callOrder(handler1, handler2, handler3);
                    done();
                });
            });

            describe("even when one handler is added inside another handler", delegate () {
                testFulfilled(dummy, (Promise!Dummy promise, void delegate() done) {
                    auto handler1 = sinon.spy!(void, Dummy)();
                    auto handler2 = sinon.spy!(void, Dummy)();
                    auto handler3 = sinon.spy!(void, Dummy)();

                    promise.then(delegate (value) {
                        handler1(value);
                        promise.then(handler3);
                    });
                    promise.then(handler2);

                    promise.then(delegate (value) {
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

    describe("2.2.6.2: If/when `promise` is rejected, all respective `onRejected` callbacks must execute in the " ~
             "order of their originating calls to `then`.", delegate () {
        describe("multiple boring rejection handlers", delegate () {
            testRejected!Sentinel(error, delegate (Promise!Sentinel promise, void delegate() done) {
                auto handler1 = sinon.stub!(void, Exception);
                auto handler2 = sinon.stub!(void, Exception);
                auto handler3 = sinon.stub!(void, Exception);

                auto spy = sinon.spy!(void, Sentinel);
                promise.then(spy, handler1);
                promise.then(spy, handler2);
                promise.then(spy, handler3);

                promise.then(null, delegate (reason) {
                    assert_.strictEqual(reason, error);

                    sinon.assert_.calledWith(handler1, sinon.match.same(error));
                    sinon.assert_.calledWith(handler2, sinon.match.same(error));
                    sinon.assert_.calledWith(handler3, sinon.match.same(error));
                    sinon.assert_.notCalled(spy);

                    done();
                });
            });
        });

        describe("multiple rejection handlers, one of which throws", delegate () {
            testRejected!Sentinel(error, delegate (promise, done) {
                auto handler1 = sinon.stub!(Dummy, Exception).returns(other);
                auto handler2 = sinon.stub!(Dummy, Exception).throws(/*other*/new Exception("handler2"));
                auto handler3 = sinon.stub!(Dummy, Exception).returns(other);

                auto spy = sinon.spy!(Dummy, Sentinel);
                promise.then(spy, handler1);
                promise.then(spy, handler2);
                promise.then(spy, handler3);

                promise.then(null, delegate (reason) {
                    assert_.strictEqual(reason, error);

                    sinon.assert_.calledWith(handler1, sinon.match.same(error));
                    sinon.assert_.calledWith(handler2, sinon.match.same(error));
                    sinon.assert_.calledWith(handler3, sinon.match.same(error));
                    sinon.assert_.notCalled(spy);

                    done();
                });
            });
        });

        describe("results in multiple branching chains with their own fulfillment values", delegate () {
            testRejected!Sentinel(error, delegate (promise, done) {
                auto semiDone = callbackAggregator(3, done);

                promise.then(null, delegate (error) {
                    return sentinel;
                }).then(delegate (value) {
                    assert_.strictEqual(value, sentinel);
                    semiDone();
                });

                promise.then(null, delegate (error) {
                    throw error2;
                }).then(null, delegate (reason) {
                    assert_.strictEqual(reason, error2);
                    semiDone();
                });

                promise.then(null, delegate (error) {
                    return sentinel3;
                }).then(delegate (value) {
                    assert_.strictEqual(value, sentinel3);
                    semiDone();
                });
            });
        });

        describe("`onRejected` handlers are called in the original order", delegate () {
            testRejected!Dummy(/*dummy*/null, (Promise!Dummy promise, void delegate() done) {
                auto handler1 = sinon.spy!(void, Exception)();
                auto handler2 = sinon.spy!(void, Exception)();
                auto handler3 = sinon.spy!(void, Exception)();

                promise.then(null, handler1);
                promise.then(null, handler2);
                promise.then(null, handler3);

                promise.then(null, delegate (error) {
                    sinon.assert_.callOrder(handler1, handler2, handler3);
                    done();
                });
            });

            describe("even when one handler is added inside another handler", delegate () {
                testRejected!Dummy(/*dummy*/null, (Promise!Dummy promise, void delegate() done) {
                    auto handler1 = sinon.spy!(void, Exception)();
                    auto handler2 = sinon.spy!(void, Exception)();
                    auto handler3 = sinon.spy!(void, Exception)();

                    promise.then(null, delegate (error) {
                        handler1(null);
                        promise.then(null, handler3);
                    });
                    promise.then(null, handler2);

                    promise.then(null, delegate (error) {
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
