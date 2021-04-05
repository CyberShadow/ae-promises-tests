module test_2_2_1; unittest {

import  helpers.d_shims;

import helpers.d_adapter;
alias resolved = adapter.resolved;
alias rejected = adapter.rejected;

struct Dummy { string dummy = "dummy"; } Dummy dummy; // we fulfill or reject with this when we don't intend to test against it

describe("2.2.1: Both `onFulfilled` and `onRejected` are optional arguments.", delegate () {
    describe("2.2.1.1: If `onFulfilled` is not a delegate, it must be ignored.", delegate () {
        describe("applied to a directly-rejected promise", delegate () {
            auto testNonFunction(T)(T nonFunction, string stringRepresentation) {
                specify("`onFulfilled` is " ~ stringRepresentation, delegate (done) {
                    rejected!Dummy(null).then(nonFunction, delegate (error) {
                        done();
                    });
                });
            }

            // testNonFunction(undefined, "`undefined`");
            testNonFunction(null, "`null`");
            // testNonFunction(false, "`false`");
            // testNonFunction(5, "`5`");
            // testNonFunction({}, "an object");
        });

        describe("applied to a promise rejected and then chained off of", delegate () {
            auto testNonFunction(T)(T nonFunction, string stringRepresentation) {
                specify("`onFulfilled` is " ~ stringRepresentation, delegate (done) {
                    rejected!Dummy(null).then(delegate (value) { }, null).then(nonFunction, delegate (error) {
                        done();
                    });
                });
            }

            // testNonFunction(undefined, "`undefined`");
            testNonFunction(null, "`null`");
            // testNonFunction(false, "`false`");
            // testNonFunction(5, "`5`");
            // testNonFunction({}, "an object");
        });
    });

    describe("2.2.1.2: If `onRejected` is not a delegate, it must be ignored.", delegate () {
        describe("applied to a directly-fulfilled promise", delegate () {
            auto testNonFunction(T)(T nonFunction, string stringRepresentation) {
                specify("`onRejected` is " ~ stringRepresentation, delegate (done) {
                    resolved(dummy).then(delegate (value) {
                        done();
                    }, nonFunction);
                });
            }

            // testNonFunction(undefined, "`undefined`");
            testNonFunction(null, "`null`");
            // testNonFunction(false, "`false`");
            // testNonFunction(5, "`5`");
            // testNonFunction({}, "an object");
        });

        describe("applied to a promise fulfilled and then chained off of", delegate () {
            auto testNonFunction(T)(T nonFunction, string stringRepresentation) {
                specify("`onRejected` is " ~ stringRepresentation, delegate (done) {
                    resolved(dummy).then(null, delegate (error) { }).then(delegate () {
                        done();
                    }, nonFunction);
                });
            }

            // testNonFunction(undefined, "`undefined`");
            testNonFunction(null, "`null`");
            // testNonFunction(false, "`false`");
            // testNonFunction(5, "`5`");
            // testNonFunction({}, "an object");
        });
    });
});
}
