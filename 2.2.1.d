module test_2_2_1; unittest {

// "use strict";

import helpers.d_adapter;
var resolved = adapter.resolved;
var rejected = adapter.rejected;

struct Dummy { string dummy = "dummy"; } Dummy dummy; // we fulfill or reject with this when we don't intend to test against it

describe("2.2.1: Both `onFulfilled` and `onRejected` are optional arguments.", delegate () {
    describe("2.2.1.1: If `onFulfilled` is not a delegate, it must be ignored.", delegate () {
        describe("applied to a directly-rejected promise", delegate () {
            delegate /*testNonFunction*/(nonFunction, stringRepresentation) {
                specify("`onFulfilled` is " + stringRepresentation, delegate (done) {
                    rejected(dummy).then(nonFunction, delegate () {
                        done();
                    });
                });
            }

            testNonFunction(undefined, "`undefined`");
            testNonFunction(null, "`null`");
            testNonFunction(false, "`false`");
            testNonFunction(5, "`5`");
            testNonFunction({}, "an object");
        });

        describe("applied to a promise rejected and then chained off of", delegate () {
            delegate /*testNonFunction*/(nonFunction, stringRepresentation) {
                specify("`onFulfilled` is " + stringRepresentation, delegate (done) {
                    rejected(dummy).then(delegate () { }, undefined).then(nonFunction, delegate () {
                        done();
                    });
                });
            }

            testNonFunction(undefined, "`undefined`");
            testNonFunction(null, "`null`");
            testNonFunction(false, "`false`");
            testNonFunction(5, "`5`");
            testNonFunction({}, "an object");
        });
    });

    describe("2.2.1.2: If `onRejected` is not a delegate, it must be ignored.", delegate () {
        describe("applied to a directly-fulfilled promise", delegate () {
            delegate /*testNonFunction*/(nonFunction, stringRepresentation) {
                specify("`onRejected` is " + stringRepresentation, delegate (done) {
                    resolved(dummy).then(delegate () {
                        done();
                    }, nonFunction);
                });
            }

            testNonFunction(undefined, "`undefined`");
            testNonFunction(null, "`null`");
            testNonFunction(false, "`false`");
            testNonFunction(5, "`5`");
            testNonFunction({}, "an object");
        });

        describe("applied to a promise fulfilled and then chained off of", delegate () {
            delegate /*testNonFunction*/(nonFunction, stringRepresentation) {
                specify("`onRejected` is " + stringRepresentation, delegate (done) {
                    resolved(dummy).then(undefined, delegate () { }).then(delegate () {
                        done();
                    }, nonFunction);
                });
            }

            testNonFunction(undefined, "`undefined`");
            testNonFunction(null, "`null`");
            testNonFunction(false, "`false`");
            testNonFunction(5, "`5`");
            testNonFunction({}, "an object");
        });
    });
});
}
