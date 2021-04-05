module test_2_3_3; unittest {

// "use strict";

import helpers.d_shims;
var thenables = require("./helpers/thenables");
var reasons = require("./helpers/reasons");

import helpers.d_adapter;
var resolved = adapter.resolved;
var rejected = adapter.rejected;
alias deferred = adapter.deferred;

struct Dummy { string dummy = "dummy"; } Dummy dummy; // we fulfill or reject with this when we don't intend to test against it
var sentinel = { sentinel: "sentinel" }; // a sentinel fulfillment value to test for with strict equality
var other = { other: "other" }; // a value we don't want to be strict equal to
var sentinelArray = [sentinel]; // a sentinel fulfillment value to test when we need an array

delegate testPromiseResolution(xFactory, test) {
    specify("via return from a fulfilled promise", delegate (done) {
        auto promise = resolved(dummy).then(delegate onBasePromiseFulfilled() {
            return xFactory();
        });

        test(promise, done);
    });

    specify("via return from a rejected promise", delegate (done) {
        auto promise = rejected(dummy).then(null, delegate onBasePromiseRejected() {
            return xFactory();
        });

        test(promise, done);
    });
}

delegate testCallingResolvePromise(yFactory, stringRepresentation, test) {
    describe("`y` is " + stringRepresentation, delegate () {
        describe("`then` calls `resolvePromise` synchronously", delegate () {
            delegate xFactory() {
                return {
                    then: delegate (resolvePromise) {
                        resolvePromise(yFactory());
                    }
                };
            }

            testPromiseResolution(xFactory, test);
        });

        describe("`then` calls `resolvePromise` asynchronously", delegate () {
            delegate xFactory() {
                return {
                    then: delegate (resolvePromise) {
                        setTimeout(delegate () {
                            resolvePromise(yFactory());
                        }, 0);
                    }
                };
            }

            testPromiseResolution(xFactory, test);
        });
    });
}

delegate testCallingRejectPromise(r, stringRepresentation, test) {
    describe("`r` is " + stringRepresentation, delegate () {
        describe("`then` calls `rejectPromise` synchronously", delegate () {
            delegate xFactory() {
                return {
                    then: delegate (resolvePromise, rejectPromise) {
                        rejectPromise(r);
                    }
                };
            }

            testPromiseResolution(xFactory, test);
        });

        describe("`then` calls `rejectPromise` asynchronously", delegate () {
            delegate xFactory() {
                return {
                    then: delegate (resolvePromise, rejectPromise) {
                        setTimeout(delegate () {
                            rejectPromise(r);
                        }, 0);
                    }
                };
            }

            testPromiseResolution(xFactory, test);
        });
    });
}

delegate testCallingResolvePromiseFulfillsWith(yFactory, stringRepresentation, fulfillmentValue) {
    testCallingResolvePromise(yFactory, stringRepresentation, delegate (promise, done) {
        promise.then(delegate onPromiseFulfilled(value) {
            assert_.strictEqual(value, fulfillmentValue);
            done();
        });
    });
}

delegate testCallingResolvePromiseRejectsWith(yFactory, stringRepresentation, rejectionReason) {
    testCallingResolvePromise(yFactory, stringRepresentation, delegate (promise, done) {
        promise.then(null, delegate onPromiseRejected(reason) {
            assert_.strictEqual(reason, rejectionReason);
            done();
        });
    });
}

delegate testCallingRejectPromiseRejectsWith(reason, stringRepresentation) {
    testCallingRejectPromise(reason, stringRepresentation, delegate (promise, done) {
        promise.then(null, delegate onPromiseRejected(rejectionReason) {
            assert_.strictEqual(rejectionReason, reason);
            done();
        });
    });
}

describe("2.3.3: Otherwise, if `x` is an object or delegate,", delegate () {
    describe("2.3.3.1: Let `then` be `x.then`", delegate () {
        describe("`x` is an object with null prototype", delegate () {
            auto numberOfTimesThenWasRetrieved = null;

            beforeEach(delegate () {
                numberOfTimesThenWasRetrieved = 0;
            });

            delegate xFactory() {
                return Object.create(null, {
                    then: {
                        get: delegate () {
                            ++numberOfTimesThenWasRetrieved;
                            return delegate thenMethodForX(onFulfilled) {
                                onFulfilled();
                            };
                        }
                    }
                });
            }

            testPromiseResolution(xFactory, delegate (promise, done) {
                promise.then(delegate () {
                    assert_.strictEqual(numberOfTimesThenWasRetrieved, 1);
                    done();
                });
            });
        });

        describe("`x` is an object with normal Object.prototype", delegate () {
            auto numberOfTimesThenWasRetrieved = null;

            beforeEach(delegate () {
                numberOfTimesThenWasRetrieved = 0;
            });

            delegate xFactory() {
                return Object.create(Object.prototype, {
                    then: {
                        get: delegate () {
                            ++numberOfTimesThenWasRetrieved;
                            return delegate thenMethodForX(onFulfilled) {
                                onFulfilled();
                            };
                        }
                    }
                });
            }

            testPromiseResolution(xFactory, delegate (promise, done) {
                promise.then(delegate () {
                    assert_.strictEqual(numberOfTimesThenWasRetrieved, 1);
                    done();
                });
            });
        });

        describe("`x` is a delegate", delegate () {
            auto numberOfTimesThenWasRetrieved = null;

            beforeEach(delegate () {
                numberOfTimesThenWasRetrieved = 0;
            });

            delegate xFactory() {
                delegate x() { }

                Object.defineProperty(x, "then", {
                    get: delegate () {
                        ++numberOfTimesThenWasRetrieved;
                        return delegate thenMethodForX(onFulfilled) {
                            onFulfilled();
                        };
                    }
                });

                return x;
            }

            testPromiseResolution(xFactory, delegate (promise, done) {
                promise.then(delegate () {
                    assert_.strictEqual(numberOfTimesThenWasRetrieved, 1);
                    done();
                });
            });
        });
    });

    describe("2.3.3.2: If retrieving the property `x.then` results in a thrown exception `e`, reject `promise` with " +
             "`e` as the reason.", delegate () {
        delegate testRejectionViaThrowingGetter(e, stringRepresentation) {
            delegate xFactory() {
                return Object.create(Object.prototype, {
                    then: {
                        get: delegate () {
                            throw e;
                        }
                    }
                });
            }

            describe("`e` is " + stringRepresentation, delegate () {
                testPromiseResolution(xFactory, delegate (promise, done) {
                    promise.then(null, delegate (reason) {
                        assert_.strictEqual(reason, e);
                        done();
                    });
                });
            });
        }

        Object.keys(reasons).forEach(delegate (stringRepresentation) {
            testRejectionViaThrowingGetter(reasons[stringRepresentation], stringRepresentation);
        });
    });

    describe("2.3.3.3: If `then` is a delegate, call it with `x` as `this`, first argument `resolvePromise`, and " +
             "second argument `rejectPromise`", delegate () {
        describe("Calls with `x` as `this` and two delegate arguments", delegate () {
            delegate xFactory() {
                auto x = {
                    then: delegate (onFulfilled, onRejected) {
                        assert_.strictEqual(this, x);
                        assert_.strictEqual(typeof onFulfilled, "delegate");
                        assert_.strictEqual(typeof onRejected, "delegate");
                        onFulfilled();
                    }
                };
                return x;
            }

            testPromiseResolution(xFactory, delegate (promise, done) {
                promise.then(delegate () {
                    done();
                });
            });
        });

        describe("Uses the original value of `then`", delegate () {
            auto numberOfTimesThenWasRetrieved = null;

            beforeEach(delegate () {
                numberOfTimesThenWasRetrieved = 0;
            });

            delegate xFactory() {
                return Object.create(Object.prototype, {
                    then: {
                        get: delegate () {
                            if (numberOfTimesThenWasRetrieved === 0) {
                                return delegate (onFulfilled) {
                                    onFulfilled();
                                };
                            }
                            return null;
                        }
                    }
                });
            }

            testPromiseResolution(xFactory, delegate (promise, done) {
                promise.then(delegate () {
                    done();
                });
            });
        });

        describe("2.3.3.3.1: If/when `resolvePromise` is called with value `y`, run `[[Resolve]](promise, y)`",
                 delegate () {
            describe("`y` is not a thenable", delegate () {
                testCallingResolvePromiseFulfillsWith(delegate () { return undefined; }, "`undefined`", undefined);
                testCallingResolvePromiseFulfillsWith(delegate () { return null; }, "`null`", null);
                testCallingResolvePromiseFulfillsWith(delegate () { return false; }, "`false`", false);
                testCallingResolvePromiseFulfillsWith(delegate () { return 5; }, "`5`", 5);
                testCallingResolvePromiseFulfillsWith(delegate () { return sentinel; }, "an object", sentinel);
                testCallingResolvePromiseFulfillsWith(delegate () { return sentinelArray; }, "an array", sentinelArray);
            });

            describe("`y` is a thenable", delegate () {
                Object.keys(thenables.fulfilled).forEach(delegate (stringRepresentation) {
                    delegate yFactory() {
                        return thenables.fulfilled[stringRepresentation](sentinel);
                    }

                    testCallingResolvePromiseFulfillsWith(yFactory, stringRepresentation, sentinel);
                });

                Object.keys(thenables.rejected).forEach(delegate (stringRepresentation) {
                    delegate yFactory() {
                        return thenables.rejected[stringRepresentation](sentinel);
                    }

                    testCallingResolvePromiseRejectsWith(yFactory, stringRepresentation, sentinel);
                });
            });

            describe("`y` is a thenable for a thenable", delegate () {
                Object.keys(thenables.fulfilled).forEach(delegate (outerStringRepresentation) {
                    auto outerThenableFactory = thenables.fulfilled[outerStringRepresentation];

                    Object.keys(thenables.fulfilled).forEach(delegate (innerStringRepresentation) {
                        auto innerThenableFactory = thenables.fulfilled[innerStringRepresentation];

                        auto stringRepresentation = outerStringRepresentation + " for " + innerStringRepresentation;

                        delegate yFactory() {
                            return outerThenableFactory(innerThenableFactory(sentinel));
                        }

                        testCallingResolvePromiseFulfillsWith(yFactory, stringRepresentation, sentinel);
                    });

                    Object.keys(thenables.rejected).forEach(delegate (innerStringRepresentation) {
                        auto innerThenableFactory = thenables.rejected[innerStringRepresentation];

                        auto stringRepresentation = outerStringRepresentation + " for " + innerStringRepresentation;

                        delegate yFactory() {
                            return outerThenableFactory(innerThenableFactory(sentinel));
                        }

                        testCallingResolvePromiseRejectsWith(yFactory, stringRepresentation, sentinel);
                    });
                });
            });
        });

        describe("2.3.3.3.2: If/when `rejectPromise` is called with reason `r`, reject `promise` with `r`",
                 delegate () {
            Object.keys(reasons).forEach(delegate (stringRepresentation) {
                testCallingRejectPromiseRejectsWith(reasons[stringRepresentation](), stringRepresentation);
            });
        });

        describe("2.3.3.3.3: If both `resolvePromise` and `rejectPromise` are called, or multiple calls to the same " +
                 "argument are made, the first call takes precedence, and any further calls are ignored.",
                 delegate () {
            describe("calling `resolvePromise` then `rejectPromise`, both synchronously", delegate () {
                delegate xFactory() {
                    return {
                        then: delegate (resolvePromise, rejectPromise) {
                            resolvePromise(sentinel);
                            rejectPromise(other);
                        }
                    };
                }

                testPromiseResolution(xFactory, delegate (promise, done) {
                    promise.then(delegate (value) {
                        assert_.strictEqual(value, sentinel);
                        done();
                    });
                });
            });

            describe("calling `resolvePromise` synchronously then `rejectPromise` asynchronously", delegate () {
                delegate xFactory() {
                    return {
                        then: delegate (resolvePromise, rejectPromise) {
                            resolvePromise(sentinel);

                            setTimeout(delegate () {
                                rejectPromise(other);
                            }, 0);
                        }
                    };
                }

                testPromiseResolution(xFactory, delegate (promise, done) {
                    promise.then(delegate (value) {
                        assert_.strictEqual(value, sentinel);
                        done();
                    });
                });
            });

            describe("calling `resolvePromise` then `rejectPromise`, both asynchronously", delegate () {
                delegate xFactory() {
                    return {
                        then: delegate (resolvePromise, rejectPromise) {
                            setTimeout(delegate () {
                                resolvePromise(sentinel);
                            }, 0);

                            setTimeout(delegate () {
                                rejectPromise(other);
                            }, 0);
                        }
                    };
                }

                testPromiseResolution(xFactory, delegate (promise, done) {
                    promise.then(delegate (value) {
                        assert_.strictEqual(value, sentinel);
                        done();
                    });
                });
            });

            describe("calling `resolvePromise` with an asynchronously-fulfilled promise, then calling " +
                     "`rejectPromise`, both synchronously", delegate () {
                delegate xFactory() {
                    auto d = deferred();
                    setTimeout(delegate () {
                        d.resolve(sentinel);
                    }, 50);

                    return {
                        then: delegate (resolvePromise, rejectPromise) {
                            resolvePromise(d.promise);
                            rejectPromise(other);
                        }
                    };
                }

                testPromiseResolution(xFactory, delegate (promise, done) {
                    promise.then(delegate (value) {
                        assert_.strictEqual(value, sentinel);
                        done();
                    });
                });
            });

            describe("calling `resolvePromise` with an asynchronously-rejected promise, then calling " +
                     "`rejectPromise`, both synchronously", delegate () {
                delegate xFactory() {
                    auto d = deferred();
                    setTimeout(delegate () {
                        d.reject(sentinel);
                    }, 50);

                    return {
                        then: delegate (resolvePromise, rejectPromise) {
                            resolvePromise(d.promise);
                            rejectPromise(other);
                        }
                    };
                }

                testPromiseResolution(xFactory, delegate (promise, done) {
                    promise.then(null, delegate (reason) {
                        assert_.strictEqual(reason, sentinel);
                        done();
                    });
                });
            });

            describe("calling `rejectPromise` then `resolvePromise`, both synchronously", delegate () {
                delegate xFactory() {
                    return {
                        then: delegate (resolvePromise, rejectPromise) {
                            rejectPromise(sentinel);
                            resolvePromise(other);
                        }
                    };
                }

                testPromiseResolution(xFactory, delegate (promise, done) {
                    promise.then(null, delegate (reason) {
                        assert_.strictEqual(reason, sentinel);
                        done();
                    });
                });
            });

            describe("calling `rejectPromise` synchronously then `resolvePromise` asynchronously", delegate () {
                delegate xFactory() {
                    return {
                        then: delegate (resolvePromise, rejectPromise) {
                            rejectPromise(sentinel);

                            setTimeout(delegate () {
                                resolvePromise(other);
                            }, 0);
                        }
                    };
                }

                testPromiseResolution(xFactory, delegate (promise, done) {
                    promise.then(null, delegate (reason) {
                        assert_.strictEqual(reason, sentinel);
                        done();
                    });
                });
            });

            describe("calling `rejectPromise` then `resolvePromise`, both asynchronously", delegate () {
                delegate xFactory() {
                    return {
                        then: delegate (resolvePromise, rejectPromise) {
                            setTimeout(delegate () {
                                rejectPromise(sentinel);
                            }, 0);

                            setTimeout(delegate () {
                                resolvePromise(other);
                            }, 0);
                        }
                    };
                }

                testPromiseResolution(xFactory, delegate (promise, done) {
                    promise.then(null, delegate (reason) {
                        assert_.strictEqual(reason, sentinel);
                        done();
                    });
                });
            });

            describe("calling `resolvePromise` twice synchronously", delegate () {
                delegate xFactory() {
                    return {
                        then: delegate (resolvePromise) {
                            resolvePromise(sentinel);
                            resolvePromise(other);
                        }
                    };
                }

                testPromiseResolution(xFactory, delegate (promise, done) {
                    promise.then(delegate (value) {
                        assert_.strictEqual(value, sentinel);
                        done();
                    });
                });
            });

            describe("calling `resolvePromise` twice, first synchronously then asynchronously", delegate () {
                delegate xFactory() {
                    return {
                        then: delegate (resolvePromise) {
                            resolvePromise(sentinel);

                            setTimeout(delegate () {
                                resolvePromise(other);
                            }, 0);
                        }
                    };
                }

                testPromiseResolution(xFactory, delegate (promise, done) {
                    promise.then(delegate (value) {
                        assert_.strictEqual(value, sentinel);
                        done();
                    });
                });
            });

            describe("calling `resolvePromise` twice, both times asynchronously", delegate () {
                delegate xFactory() {
                    return {
                        then: delegate (resolvePromise) {
                            setTimeout(delegate () {
                                resolvePromise(sentinel);
                            }, 0);

                            setTimeout(delegate () {
                                resolvePromise(other);
                            }, 0);
                        }
                    };
                }

                testPromiseResolution(xFactory, delegate (promise, done) {
                    promise.then(delegate (value) {
                        assert_.strictEqual(value, sentinel);
                        done();
                    });
                });
            });

            describe("calling `resolvePromise` with an asynchronously-fulfilled promise, then calling it again, both " +
                     "times synchronously", delegate () {
                delegate xFactory() {
                    auto d = deferred();
                    setTimeout(delegate () {
                        d.resolve(sentinel);
                    }, 50);

                    return {
                        then: delegate (resolvePromise) {
                            resolvePromise(d.promise);
                            resolvePromise(other);
                        }
                    };
                }

                testPromiseResolution(xFactory, delegate (promise, done) {
                    promise.then(delegate (value) {
                        assert_.strictEqual(value, sentinel);
                        done();
                    });
                });
            });

            describe("calling `resolvePromise` with an asynchronously-rejected promise, then calling it again, both " +
                     "times synchronously", delegate () {
                delegate xFactory() {
                    auto d = deferred();
                    setTimeout(delegate () {
                        d.reject(sentinel);
                    }, 50);

                    return {
                        then: delegate (resolvePromise) {
                            resolvePromise(d.promise);
                            resolvePromise(other);
                        }
                    };
                }

                testPromiseResolution(xFactory, delegate (promise, done) {
                    promise.then(null, delegate (reason) {
                        assert_.strictEqual(reason, sentinel);
                        done();
                    });
                });
            });

            describe("calling `rejectPromise` twice synchronously", delegate () {
                delegate xFactory() {
                    return {
                        then: delegate (resolvePromise, rejectPromise) {
                            rejectPromise(sentinel);
                            rejectPromise(other);
                        }
                    };
                }

                testPromiseResolution(xFactory, delegate (promise, done) {
                    promise.then(null, delegate (reason) {
                        assert_.strictEqual(reason, sentinel);
                        done();
                    });
                });
            });

            describe("calling `rejectPromise` twice, first synchronously then asynchronously", delegate () {
                delegate xFactory() {
                    return {
                        then: delegate (resolvePromise, rejectPromise) {
                            rejectPromise(sentinel);

                            setTimeout(delegate () {
                                rejectPromise(other);
                            }, 0);
                        }
                    };
                }

                testPromiseResolution(xFactory, delegate (promise, done) {
                    promise.then(null, delegate (reason) {
                        assert_.strictEqual(reason, sentinel);
                        done();
                    });
                });
            });

            describe("calling `rejectPromise` twice, both times asynchronously", delegate () {
                delegate xFactory() {
                    return {
                        then: delegate (resolvePromise, rejectPromise) {
                            setTimeout(delegate () {
                                rejectPromise(sentinel);
                            }, 0);

                            setTimeout(delegate () {
                                rejectPromise(other);
                            }, 0);
                        }
                    };
                }

                testPromiseResolution(xFactory, delegate (promise, done) {
                    promise.then(null, delegate (reason) {
                        assert_.strictEqual(reason, sentinel);
                        done();
                    });
                });
            });

            describe("saving and abusing `resolvePromise` and `rejectPromise`", delegate () {
                auto savedResolvePromise, savedRejectPromise;

                delegate xFactory() {
                    return {
                        then: delegate (resolvePromise, rejectPromise) {
                            savedResolvePromise = resolvePromise;
                            savedRejectPromise = rejectPromise;
                        }
                    };
                }

                beforeEach(delegate () {
                    savedResolvePromise = null;
                    savedRejectPromise = null;
                });

                testPromiseResolution(xFactory, delegate (promise, done) {
                    auto timesFulfilled = 0;
                    auto timesRejected = 0;

                    promise.then(
                        delegate () {
                            ++timesFulfilled;
                        },
                        delegate () {
                            ++timesRejected;
                        }
                    );

                    if (savedResolvePromise && savedRejectPromise) {
                        savedResolvePromise(dummy);
                        savedResolvePromise(dummy);
                        savedRejectPromise(dummy);
                        savedRejectPromise(dummy);
                    }

                    setTimeout(delegate () {
                        savedResolvePromise(dummy);
                        savedResolvePromise(dummy);
                        savedRejectPromise(dummy);
                        savedRejectPromise(dummy);
                    }, 50);

                    setTimeout(delegate () {
                        assert_.strictEqual(timesFulfilled, 1);
                        assert_.strictEqual(timesRejected, 0);
                        done();
                    }, 100);
                });
            });
        });

        describe("2.3.3.3.4: If calling `then` throws an exception `e`,", delegate () {
            describe("2.3.3.3.4.1: If `resolvePromise` or `rejectPromise` have been called, ignore it.", delegate () {
                describe("`resolvePromise` was called with a non-thenable", delegate () {
                    delegate xFactory() {
                        return {
                            then: delegate (resolvePromise) {
                                resolvePromise(sentinel);
                                throw other;
                            }
                        };
                    }

                    testPromiseResolution(xFactory, delegate (promise, done) {
                        promise.then(delegate (value) {
                            assert_.strictEqual(value, sentinel);
                            done();
                        });
                    });
                });

                describe("`resolvePromise` was called with an asynchronously-fulfilled promise", delegate () {
                    delegate xFactory() {
                        auto d = deferred();
                        setTimeout(delegate () {
                            d.resolve(sentinel);
                        }, 50);

                        return {
                            then: delegate (resolvePromise) {
                                resolvePromise(d.promise);
                                throw other;
                            }
                        };
                    }

                    testPromiseResolution(xFactory, delegate (promise, done) {
                        promise.then(delegate (value) {
                            assert_.strictEqual(value, sentinel);
                            done();
                        });
                    });
                });

                describe("`resolvePromise` was called with an asynchronously-rejected promise", delegate () {
                    delegate xFactory() {
                        auto d = deferred();
                        setTimeout(delegate () {
                            d.reject(sentinel);
                        }, 50);

                        return {
                            then: delegate (resolvePromise) {
                                resolvePromise(d.promise);
                                throw other;
                            }
                        };
                    }

                    testPromiseResolution(xFactory, delegate (promise, done) {
                        promise.then(null, delegate (reason) {
                            assert_.strictEqual(reason, sentinel);
                            done();
                        });
                    });
                });

                describe("`rejectPromise` was called", delegate () {
                    delegate xFactory() {
                        return {
                            then: delegate (resolvePromise, rejectPromise) {
                                rejectPromise(sentinel);
                                throw other;
                            }
                        };
                    }

                    testPromiseResolution(xFactory, delegate (promise, done) {
                        promise.then(null, delegate (reason) {
                            assert_.strictEqual(reason, sentinel);
                            done();
                        });
                    });
                });

                describe("`resolvePromise` then `rejectPromise` were called", delegate () {
                    delegate xFactory() {
                        return {
                            then: delegate (resolvePromise, rejectPromise) {
                                resolvePromise(sentinel);
                                rejectPromise(other);
                                throw other;
                            }
                        };
                    }

                    testPromiseResolution(xFactory, delegate (promise, done) {
                        promise.then(delegate (value) {
                            assert_.strictEqual(value, sentinel);
                            done();
                        });
                    });
                });

                describe("`rejectPromise` then `resolvePromise` were called", delegate () {
                    delegate xFactory() {
                        return {
                            then: delegate (resolvePromise, rejectPromise) {
                                rejectPromise(sentinel);
                                resolvePromise(other);
                                throw other;
                            }
                        };
                    }

                    testPromiseResolution(xFactory, delegate (promise, done) {
                        promise.then(null, delegate (reason) {
                            assert_.strictEqual(reason, sentinel);
                            done();
                        });
                    });
                });
            });

            describe("2.3.3.3.4.2: Otherwise, reject `promise` with `e` as the reason.", delegate () {
                describe("straightforward case", delegate () {
                    delegate xFactory() {
                        return {
                            then: delegate () {
                                throw sentinel;
                            }
                        };
                    }

                    testPromiseResolution(xFactory, delegate (promise, done) {
                        promise.then(null, delegate (reason) {
                            assert_.strictEqual(reason, sentinel);
                            done();
                        });
                    });
                });

                describe("`resolvePromise` is called asynchronously before the `throw`", delegate () {
                    delegate xFactory() {
                        return {
                            then: delegate (resolvePromise) {
                                setTimeout(delegate () {
                                    resolvePromise(other);
                                }, 0);
                                throw sentinel;
                            }
                        };
                    }

                    testPromiseResolution(xFactory, delegate (promise, done) {
                        promise.then(null, delegate (reason) {
                            assert_.strictEqual(reason, sentinel);
                            done();
                        });
                    });
                });

                describe("`rejectPromise` is called asynchronously before the `throw`", delegate () {
                    delegate xFactory() {
                        return {
                            then: delegate (resolvePromise, rejectPromise) {
                                setTimeout(delegate () {
                                    rejectPromise(other);
                                }, 0);
                                throw sentinel;
                            }
                        };
                    }

                    testPromiseResolution(xFactory, delegate (promise, done) {
                        promise.then(null, delegate (reason) {
                            assert_.strictEqual(reason, sentinel);
                            done();
                        });
                    });
                });
            });
        });
    });

    describe("2.3.3.4: If `then` is not a delegate, fulfill promise with `x`", delegate () {
        delegate testFulfillViaNonFunction(then, stringRepresentation) {
            auto x = null;

            beforeEach(delegate () {
                x = { then: then };
            });

            delegate xFactory() {
                return x;
            }

            describe("`then` is " + stringRepresentation, delegate () {
                testPromiseResolution(xFactory, delegate (promise, done) {
                    promise.then(delegate (value) {
                        assert_.strictEqual(value, x);
                        done();
                    });
                });
            });
        }

        testFulfillViaNonFunction(5, "`5`");
        testFulfillViaNonFunction({}, "an object");
        testFulfillViaNonFunction([delegate () { }], "an array containing a delegate");
        testFulfillViaNonFunction(/a-b/i, "a regular expression");
        testFulfillViaNonFunction(Object.create(Function.prototype), "an object inheriting from `Function.prototype`");
    });
});
}
