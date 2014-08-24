package thx.promise;

import thx.promise.Deferred;
using thx.promise.Promise;
import thx.core.Error;
import utest.Assert;
using thx.core.Arrays;
using thx.core.Tuple;

class TestPromise {
	public function new() {}

	public function testResolveBefore() {
		var done = Assert.createAsync(),
			deferred = new Deferred();
		deferred.resolve(1);
		deferred.promise.success(function(v) {
			Assert.equals(1, v);
			done();
		});
	}

	public function testResolveAfter() {
		var done = Assert.createAsync(),
			deferred = new Deferred();
		deferred.promise.success(function(v) {
			Assert.equals(1, v);
			done();
		});
		deferred.resolve(1);
	}

	public function testRejectBefore() {
		var done = Assert.createAsync(),
			deferred = new Deferred(),
			error = new Error("Nooooo!");
		deferred.reject(error);
		deferred.promise.failure(function(e) {
			Assert.equals(error, e);
			done();
		});
	}

	public function testRejectAfter() {
		var done = Assert.createAsync(),
			deferred = new Deferred(),
			error = new Error("Nooooo!");
		deferred.promise.failure(function(e) {
			Assert.equals(error, e);
			done();
		});
		deferred.reject(error);
	}

	public function testMapSuccessWithValue() {
		var done = Assert.createAsync();
		Promise.value(1).mapSuccess(function(v) {
			return Promise.value(v * 2);
		}).success(function(v) {
			Assert.equals(2, v);
			done();
		});
	}

	public function testMapSuccessWithFailure() {
		var done = Assert.createAsync(),
			err = new Error("error");
		Promise.reject(err).mapSuccess(function(v) {
			Assert.fail("should never touch this");
			return Promise.value(v * 2);
		}).failure(function(e) {
			Assert.equals(err, e);
			done();
		});
	}

	public function testAllSuccess() {
		var done = Assert.createAsync();
		Promise.all([
			Promise.value(1),
			Promise.value(2)
		]).success(function(arr) {
			Assert.equals(3, arr.reduce(function(acc, v) return acc + v, 0));
			done();
		});
	}

	public function testAllFailure() {
		var done = Assert.createAsync(),
			err  = new Error("error");
		Promise.all([
			Promise.value(1),
			Promise.reject(err)
		])
		.success(function(arr) {
			Assert.fail("should never happen");
		})
		.failure(function(e) {
			Assert.equals(err, e);
			done();
		});
	}

	public function testJoinSuccess() {
		var done = Assert.createAsync();
		Promise.value(1)
			.join(Promise.value(2))
			.success(function(t) {
				Assert.equals(1, t._0);
				Assert.equals(2, t._1);
				done();
			});
	}

	public function testJoinFailure() {
		var done = Assert.createAsync(),
			err  = new Error("error");
		Promise.value(1)
			.join(Promise.reject(err))
			.failure(function(e) {
				Assert.equals(err, e);
				done();
			})
			.success(function(t) {
				Assert.fail("should never happen");
			});
	}

	public function testMapTupleSuccess() {
		var done = Assert.createAsync();
		Promise.value(new Tuple2(1, 2))
			.mapTuple(function(a, b) {
				return Promise.value(a/b);
			})
			.success(function(v) {
				Assert.equals(0.5, v);
				done();
			});
	}

	public function testMapTupleFailure() {
		var done = Assert.createAsync(),
			err  = new Error("error");
		Promise.reject(err)
			.mapTuple(function(a, b) {
				return Promise.value(a/b);
			})
			.failure(function(e) {
				Assert.equals(err, e);
				done();
			});
	}

	public function testAllMapToTupleFailure() {
		var done = Assert.createAsync(),
			err  = new Error("error");
		Promise.all([
			Promise.reject(err),
			Promise.reject(err)
		])
		.mapSuccess(function(v) {
			Assert.fail("should never happen");
			return Promise.value(new Tuple2(1, 2));
		})
		.mapTuple(function(a, b) {
			Assert.fail("should never happen");
			return Promise.value(a / b);
		})
		.failure(function(e) {
			Assert.equals(err, e);
			done();
		});
	}
}