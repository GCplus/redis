此目录包含Redis所有的依赖项，但由操作系统提供的libc除外。

* **Jemalloc** 是我们的内存分配器，默认情况下用作Linux系统的 libc malloc 的替代品。它具有良好的性能和出色的内存碎片管理行为。 该组件会不定期进行升级。
* **geohash-int** 位于依赖项目录中，但实际上是Redis项目的一部分，因为它是我们最初为Ardb开发的库的私有fork（经过大量修改），Ardb又是Redis的一个分支。
* **hiredis** 是Redis官方用C库编写的客户端。 它可以被redis-cli，redis-benchmark和Redis Sentinel使用。 它是Redis官方生态系统的一部分，但是它独立于Redis仓库进行开发，因此我们只根据需要进行升级即可。
* **linenoise** 是readline的替代品。 它由Redis的同一作者开发，但作为一个单独的项目进行管理，并根据需要（不时）进行更新。
* **lua** 是对安全性和其他库进行了少量修改的lua 5.1版本。

如何升级上面的依赖项
===

Jemalloc
---

Jemalloc is unmodified. We only change settings via the `configure` script of Jemalloc using the `--with-lg-quantum` option, setting it to the value of 3 instead of 4. This provides us with more size classes that better suit the Redis data structures, in order to gain memory efficiency.

So in order to upgrade jemalloc:

1. Remove the jemalloc directory.
2. Substitute it with the new jemalloc source tree.

Geohash
---

This is never upgraded since it's part of the Redis project. If there are changes to merge from Ardb there is the need to manually check differences, but at this point the source code is pretty different.

Hiredis
---

Hiredis uses the SDS string library, that must be the same version used inside Redis itself. Hiredis is also very critical for Sentinel. Historically Redis often used forked versions of hiredis in a way or the other. In order to upgrade it is adviced to take a lot of care:

1. Check with diff if hiredis API changed and what impact it could have in Redis.
2. Make sure thet the SDS library inside Hiredis and inside Redis are compatible.
3. After the upgrade, run the Redis Sentinel test.
4. Check manually that redis-cli and redis-benchmark behave as expecteed, since we have no tests for CLI utilities currently.

Linenoise
---

Linenoise is rarely upgraded as needed. The upgrade process is trivial since
Redis uses a non modified version of linenoise, so to upgrade just do the
following:

1. Remove the linenoise directory.
2. Substitute it with the new linenoise source tree.

Lua
---

We use Lua 5.1 and no upgrade is planned currently, since we don't want to break
Lua scripts for new Lua features: in the context of Redis Lua scripts the
capabilities of 5.1 are usually more than enough, the release is rock solid,
and we definitely don't want to break old scripts.

So upgrading of Lua is up to the Redis project maintainers and should be a
manual procedure performed by taking a diff between the different versions.

Currently we have at least the following differences between official Lua 5.1
and our version:

1. Makefile is modified to allow a different compiler than GCC.
2. We have the implementation source code, and directly link to the following external libraries: `lua_cjson.o`, `lua_struct.o`, `lua_cmsgpack.o` and `lua_bit.o`.
3. There is a security fix in `ldo.c`, line 498: The check for `LUA_SIGNATURE[0]` is removed in order toa void direct bytecode exectuion.
