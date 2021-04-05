module test_2_3_4; unittest {

import  helpers.d_shims;

import helpers.d_shims;
import helpers.testThreeCases : testFulfilled;
import helpers.testThreeCases : testRejected;

struct Dummy { string dummy = "dummy"; } Dummy dummy; // we fulfill or reject with this when we don't intend to test against it

describe("2.3.4: If `x` is not an object or delegate, fulfill `promise` with `x`", delegate () {
    auto testValue(T)(T expectedValue, string stringRepresentation, void delegate() beforeEachHook = null, void delegate() afterEachHook = null) {
        describe("The value is " ~ stringRepresentation, delegate () {
            // if (beforeEachHook) {
            //     beforeEach(beforeEachHook);
            // }
            // if (afterEachHook) {
            //     afterEach(afterEachHook);
            // }

            testFulfilled(dummy, delegate (Promise!Dummy promise1, done) {
                auto promise2 = promise1.then(delegate /*onFulfilled*/(value) {
                    return expectedValue;
                });

                promise2.then(delegate /*onPromise2Fulfilled*/(actualValue) {
                    assert_.strictEqual(actualValue, expectedValue);
                    done();
                });
            });
            testRejected!T(/*dummy*/null, delegate (Promise!T promise1, done) {
                auto promise2 = promise1.then(null, delegate /*onRejected*/(error) {
                    return expectedValue;
                });

                promise2.then(delegate /*onPromise2Fulfilled*/(actualValue) {
                    assert_.strictEqual(actualValue, expectedValue);
                    done();
                });
            });
        });
    }

    // testValue(undefined, "`undefined`");
    testValue(null, "`null`");
    // testValue(false, "`false`");
    // testValue(true, "`true`");
    // testValue(0, "`0`");

    // testValue(
    //     true,
    //     "`true` with `Boolean.prototype` modified to have a `then` method",
    //     delegate () {
    //         Boolean.prototype.then = delegate () {};
    //     },
    //     delegate () {
    //         delete Boolean.prototype.then;
    //     }
    // );

    // testValue(
    //     1,
    //     "`1` with `Number.prototype` modified to have a `then` method",
    //     delegate () {
    //         Number.prototype.then = delegate () {};
    //     },
    //     delegate () {
    //         delete Number.prototype.then;
    //     }
    // );
});
}
