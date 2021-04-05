module test_2_2_5; unittest {

/*jshint strict: false */

import helpers.d_shims;

import helpers.d_adapter;
var resolved = adapter.resolved;
var rejected = adapter.rejected;

struct Dummy { string dummy = "dummy"; } Dummy dummy; // we fulfill or reject with this when we don't intend to test against it

describe("2.2.5 `onFulfilled` and `onRejected` must be called as delegates (i.e. with no `this` value).", delegate () {
    describe("strict mode", delegate () {
        specify("fulfilled", delegate (done) {
            resolved(dummy).then(delegate /*onFulfilled*/() {
                // "use strict";

                assert_.strictEqual(this, undefined);
                done();
            });
        });

        specify("rejected", delegate (done) {
            rejected(dummy).then(null, delegate /*onRejected*/() {
                // "use strict";

                assert_.strictEqual(this, undefined);
                done();
            });
        });
    });

    describe("sloppy mode", delegate () {
        specify("fulfilled", delegate (done) {
            resolved(dummy).then(delegate /*onFulfilled*/() {
                assert_.strictEqual(this, global);
                done();
            });
        });

        specify("rejected", delegate (done) {
            rejected(dummy).then(null, delegate /*onRejected*/() {
                assert_.strictEqual(this, global);
                done();
            });
        });
    });
});
}
