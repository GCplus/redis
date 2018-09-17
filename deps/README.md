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

Jemalloc未经修改。 我们使用`--with-lg-quantum`选项通过Jemalloc的`configure`脚本更改设置，将其值设置为3，替代默认的4。 这为我们提供了更多适合Redis数据结构的类 ，以获得存储效率。

所以为了升级jemalloc:

1. 删除 jemalloc 目录（文件夹）。
2. 用新的jemalloc源代码树替换它。

Geohash
---

这从来没有升级，因为它是Redis项目的一部分。 如果有变化，从Ardb合并过来需要手动检查差异，在这一点上，双方的源代码有巨大的差异。

Hiredis
---

Hiredis使用SDS字符串库，它必须与Redis本身内部使用的版本相同。 Hiredis对Sentinel也非常关键。 历史上，Redis经常以某种方式使用hiredis的fork版本。 为了升级，建议采取很多措施：

1. 如果hiredis API发生了变化，请使用diff命令进行检查它们的不同，以及它对Redis的影响。
2. 确保Redis内部的SDS库和Redis内部的相兼容。
3. 升级完成后，运行Redis Sentinel测试。
4. 手动检查redis-cli和redis-benchmark的行为是否符合预期，因为我们目前没有对CLI应用程序进行测试。

Linenoise
---

Linenoise很少需要升级。 由于Redis使用的是非修改版本的linenoise，因此升级过程非常简单，因此升级只需执行以下操作：

1. 删除 linenoise 目录（文件夹）。
2. 用新的linenoise源码树替换它。

Lua
---

我们使用Lua 5.1并且目前没有计划升级，因为我们不想破坏Lua脚本以获得新的Lua功能：在Redis里面，Lua脚本的上下文中，Lua5.1的功能通常绰绰有余，版本坚如磐石， 这无疑让我们不想打破这个旧脚本。

因此，升级Lua取决于Redis项目维护者的意见，并且应该是通过在不同版本之间进行差异比较来决定执行的手动程序。

目前，官方Lua 5.1与我们的版本之间至少存在以下差异：

1. 修改Makefile以允许与GCC不同的编译器进行交互。
2. 我们拥有lua的实现源代码，并直接链接到以下外部库：`lua_cjson.o`，`lua_struct.o`，`lua_cmsgpack.o`和`lua_bit.o`。
3. 在`ldo.c`中有一个安全修复，第498行：删除了对`LUA_SIGNATURE[0]`的检查，以避免直接执行字节码。
