module test_2_2_7; unittest {

import  helpers.d_shims;

import helpers.d_shims;
import helpers.testThreeCases : testFulfilled;
import helpers.testThreeCases : testRejected;
// var reasons = require("./helpers/reasons");

import helpers.d_adapter;
alias deferred = adapter.deferred;

struct Dummy { string dummy = "dummy"; } Dummy dummy; // we fulfill or reject with this when we don't intend to test against it
struct Sentinel { string sentinel = "sentinel"; } Sentinel sentinel; // a sentinel fulfillment value to test for with strict equality
Dummy other = { "other" }; // a value we don't want to be strict equal to
auto error = new Exception("error");

describe("2.2.7: `then` must return a promise: `promise2 = promise1.then(onFulfilled, onRejected)`", delegate () {
    specify("is a promise", delegate () {
        auto promise1 = deferred!void().promise;
        alias Promise2 = typeof(promise1.then!void(null));

        static assert(is(Promise2 == Promise!(T, E), T, E));
        // assert_.notStrictEqual(promise2, null);
        // assert_.strictEqual(typeof promise2.then, "delegate");
    });

    describe("2.2.7.1: If either `onFulfilled` or `onRejected` returns a value `x`, run the Promise Resolution " ~
             "Procedure `[[Resolve]](promise2, x)`", delegate () {
        specify("see separate 3.3 tests", delegate () { });
    });

    describe("2.2.7.2: If either `onFulfilled` or `onRejected` throws an exception `e`, `promise2` must be rejected " ~
             "with `e` as the reason.", delegate () {
        auto testReason(R)(R expectedReason, string stringRepresentation) {
            describe("The reason is " ~ stringRepresentation, delegate () {
                testFulfilled(dummy, delegate (Promise!Dummy promise1, done) {
                    auto promise2 = promise1.then(delegate /*onFulfilled*/(value) {
                        throw expectedReason;
                    });

                    promise2.then(null, delegate /*onPromise2Rejected*/(actualReason) {
                        assert_.strictEqual(actualReason, expectedReason);
                        done();
                    });
                });
                testRejected!Dummy(/*dummy*/null, delegate (promise1, done) {
                    auto promise2 = promise1.then(null, delegate /*onRejected*/(error) {
                        throw expectedReason;
                    });

                    promise2.then(null, delegate /*onPromise2Rejected*/(actualReason) {
                        assert_.strictEqual(actualReason, expectedReason);
                        done();
                    });
                });
            });
        }

        // Object.keys(reasons).forEach(delegate (stringRepresentation) {
            testReason(/*reasons[stringRepresentation]()*/new Exception("test"), /* stringRepresentation */ `new Exception("test")`);
        // });
    });

    describe("2.2.7.3: If `onFulfilled` is not a delegate and `promise1` is fulfilled, `promise2` must be fulfilled " ~
             "with the same value.", delegate () {

        auto testNonFunction(T)(T nonFunction, string stringRepresentation) {
            describe("`onFulfilled` is " ~ stringRepresentation, delegate () {
                testFulfilled(sentinel, delegate (Promise!Sentinel promise1, done) {
                    auto promise2 = promise1.then!Sentinel(nonFunction);

                    promise2.then(delegate /*onPromise2Fulfilled*/(value) {
                        assert_.strictEqual(value, sentinel);
                        done();
                    });
                });
            });
        }

        // testNonFunction(undefined, "`undefined`");
        testNonFunction(null, "`null`");
        // testNonFunction(false, "`false`");
        // testNonFunction(5, "`5`");
        // testNonFunction({}, "an object");
        // testNonFunction([delegate () { return other; }], "an array containing a delegate");
    });

    describe("2.2.7.4: If `onRejected` is not a delegate and `promise1` is rejected, `promise2` must be rejected " ~
             "with the same reason.", delegate () {

        auto testNonFunction(T)(T nonFunction, string stringRepresentation) {
            describe("`onRejected` is " ~ stringRepresentation, delegate () {
                testRejected!Dummy(error, delegate (promise1, done) {
                    auto promise2 = promise1.then!void(null, nonFunction);

                    promise2.then(null, delegate /*onPromise2Rejected*/(reason) {
                        assert_.strictEqual(reason, error);
                        done();
                    });
                });
            });
        }

        // testNonFunction(undefined, "`undefined`");
        testNonFunction(null, "`null`");
        // testNonFunction(false, "`false`");
        // testNonFunction(5, "`5`");
        // testNonFunction({}, "an object");
        // testNonFunction([delegate () { return other; }], "an array containing a delegate");
    });
});
}
