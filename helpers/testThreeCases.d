module helpers.testThreeCases;

import helpers.d_shims;
import ae.utils.promise;

import helpers.d_adapter;
alias resolved = adapter.resolved;
alias rejected = adapter.rejected;
alias deferred = adapter.deferred;

void testFulfilled(T)(T value, void delegate(Promise!T, void delegate() done) test) {
    specify("already-fulfilled", /*function*/ (done) {
        test(resolved(value), done);
    });

    specify("immediately-fulfilled", /* function */ (done) {
        auto d = deferred!T();
        test(d.promise, done);
        d.resolve(value);
    });

    specify("eventually-fulfilled", /* function */ (done) {
        auto d = deferred!T();
        test(d.promise, done);
        setTimeout(/* function */ () {
            d.resolve(value);
        }, 50);
    });
}

void testRejected(T)(Exception reason, void delegate(Promise!T, void delegate() done) test) {
    specify("already-rejected", /* function */ (done) {
        test(rejected!T(reason), done);
    });

    specify("immediately-rejected", /* function */ (done) {
        auto d = deferred!T();
        test(d.promise, done);
        d.reject(reason);
    });

    specify("eventually-rejected", /* function */ (done) {
        auto d = deferred!T();
        test(d.promise, done);
        setTimeout(/* function */ () {
            d.reject(reason);
        }, 50);
    });
}
