本自述文件只是一个快速 *快速入门* 文档。 您可以在[redis.io](https://redis.io)找到更详细的文档。

什么是 Redis ？
--------------

Redis通常作为一个 *数据结构(data structures)* 服务器被提及。 这意味着Redis通过一组命令提供对可变数据结构的访问，这些命令使用带有TCP套接字(socket)和简单协议(simple protocol)的 *server-client* 模型发送。因此，不同的进程可以以共享的方式查询和修改相同的数据结构(data structures)。

Redis中实现的数据结构有一些特殊属性：

* Redis介意将它们存储在磁盘上，即使它们总是被存储并修改到服务器内存中。 这意味着Redis速度很快，但这也是非易失性的。
* 数据结构的实现强调内存效率，因此与使用高级编程语言建模的相同数据结构相比，Redis内部的数据结构能使用更少的内存。
* Redis提供了许多在数据库中自然可以找到的功能，如复制，可调节的持久化级别，群集，高可用性。

另一个很好的例子是将Redis视为memcached的更复杂版本，其中操作不仅仅是SET和GET，而是用于处理复杂数据类型（如Lists，Sets，有序数据结构等）的操作。

如果您想了解更多信息，请参阅选定的起始列表：

* Redis数据类型简介。 http://redis.io/topics/data-types-intro
* 直接在浏览器中尝试Redis。 http://try.redis.io
* Redis命令的完整列表。 http://redis.io/commands
* Redis官方文档中有更多内容。 http://redis.io/documentation

编译 Redis
--------------

Redis可以在Linux，OSX，OpenBSD，NetBSD，FreeBSD上编译和使用。
我们支持大字节序和小字节序架构，以及32位和64位系统。

它可以在Solaris派生系统（例如SmartOS）上编译，但是我们对这个平台的Redis支持是*尽力而为* ，并且不保证如同在Linux，OSX和\*BSD 中一样的工作效果。

编译简单：

    % make

您可以使用以下命令编译运行32位Redis执行文件：

    % make 32bit

在编译Redis之后，最好使用以下方法对其进行测试：

    % make test

修复依赖项或缓存编译选项的编译问题
---------

Redis有一些依赖项，它们包含在`deps`目录中。
即使依赖项源代码中的某些内容发生更改，`make`也不会自动重建依赖项。

当您使用`git pull`更新源代码或者以任何其他方式修改依赖项中的代码时，
请确保使用以下命令以便真正清理所有内容并从头开始重建：

    make distclean

这将清理：jemalloc，lua，hiredis，linenoise。

此外，如果您强制某些构建选项，如32位目标，没有C编译器优化（用于调试目的）和其他类似的构建选项，
那么这些选项将无限期地缓存，直到您发出`make distclean`命令。

修复编译32位执行文件的问题
---------

如果在使用32位系统编译Redis之后需要使用64位系统重新编译它，或者反过来，
则需要在Redis发行版的根目录中执行`make distclean`。

如果在尝试构建Redis的32位执行文件时出现编译错误，请尝试以下步骤：

* 安装包 libc6-dev-i386（也可以尝试 g++-multilib ）。
* 尝试使用以下命令行而不是`make 32bit`:
  `make CFLAGS="-m32 -march=native" LDFLAGS="-m32"`

分配器
---------

在编译Redis时选择非默认内存分配器是通过设置`MALLOC`环境变量来完成的。
默认情况下，Redis是针对libc malloc进行编译和链接的，除了jemalloc是Linux系统上的默认设置。 选择此默认值是因为jemalloc已证明比libc malloc具有更少的内存碎片问题。

要强制编译libc malloc，请使用：

    % make MALLOC=libc

要在Mac OS X系统上针对jemalloc进行编译，请使用：

    % make MALLOC=jemalloc

详细编译
-------------

默认情况下，Redis将使用用户友好的色彩输出进行编译。
如果要查看更详细的输出，请使用以下命令：

    % make V=1

运行 Redis
-------------

要使用默认配置运行Redis，只需输入：

    % cd src
    % ./redis-server

如果要提供redis.conf，则必须使用其他参数（配置文件的路径）运行它：

    % cd src
    % ./redis-server /path/to/redis.conf

可以通过使用命令行直接将参数作为选项传递来更改Redis配置。 例如：

    % ./redis-server --port 9999 --slaveof 127.0.0.1 6379
    % ./redis-server /etc/redis/6379.conf --loglevel debug

redis.conf中的所有选项也使用命令行作为选项支持，名称完全相同。

操作 Redis
------------------

您可以使用redis-cli操作Redis。 启动redis-server实例后，在另一个终端中尝试以下操作：

    % cd src
    % ./redis-cli
    redis> ping
    PONG
    redis> set foo bar
    OK
    redis> get foo
    "bar"
    redis> incr mycounter
    (integer) 1
    redis> incr mycounter
    (integer) 2
    redis>

您可以在 http://redis.io/commands 找到所有可用命令的列表

安装 Redis
-----------------

要将Redis执行文件安装到 /usr/local/bin 中，只需使用：

    % make install

如果您希望使用其他目录，可以使用`make PREFIX =/some/other/directory install`。

make install只会在系统中安装执行文件，但不会在适当的位置配置init脚本和配置文件。
如果您只想操作Redis ，则不需要这样做，但如果您正在为生产系统安装它，
我们有一个Ubuntu和Debian系统的脚本，你可以执行此操作：
    % cd utils
    % ./install_server.sh

该脚本将向您询问几个问题，并将设置Redis作为后台守护程序运行所需的一切，该守护程序将在系统启动时自动启动。

您将能够使用名为`/etc/init.d/redis_ <portnumber>`的脚本停止并启动Redis，例如`/etc/init.d/redis_6379`

贡献代码
-----------------

注意：可以通过任何形式向Redis项目提供代码，包括通过Github发送pull请求，
通过私人电子邮件或公共讨论组发送代码片段或补丁，您需要同意根据BSD许可条款发布您的代码，
BSD许可条款可以在Redis源代码发行版中包含的 [COPYING][1] 文件中找到。

有关详细信息，请参阅此源代码分发中的 [CONTRIBUTING][2] 文件。

[1]: https://github.com/antirez/redis/blob/unstable/COPYING
[2]: https://github.com/antirez/redis/blob/unstable/CONTRIBUTING

Redis internals
===

如果您正在阅读本自述文件，您可能会在Github页面前，或者您只是解开了Redis发行版的tar格式压缩包。
在这两种情况下，您距离源代码基本上都只有一步之遥，因此我们在这里解释Redis源代码布局，
每个文件中的大意，Redis服务器内部最重要的功能和结构等等。
我们将所有对话保持在高水平而不深入细节，因此这个文档会很大，
并且我们的代码库会不断变化，但总体思路应该是了解更多内容的良好起点。
此外，大多数代码都有很多注释并且易于跟进。

源代码布局(Source code layout)
---

Redis根目录只包含这个README，Makefile（调用`src`目录中的实际Makefile）以及Redis和Sentinel的示例配置。
您可以找到一些用于执行Redis，Redis Cluster和Redis Sentinel单元测试的shell脚本，
这些脚本实例在`tests`目录中。

根目录中有以下重要目录：

* `src`: 包含用C编写的Redis实现。
* `tests`: 包含单元测试，在Tcl中实现。
* `deps`: 包含Redis使用的库。 编译Redis所需的一切都在这个目录中；你的系统只需要提供`libc`，POSIX兼容接口和C编译器。值得注意的是，“deps”包含了一个`jemalloc`的副本，它是Linux下Redis的默认分配器。请注意，在`deps`下也有从Redis项目开始的东西，但主存储库不是`anitrez/redis`。这个规则的一个例外是`deps/geohash-int`，这是Redis使用的低级地理编码库：它源自一个不同的项目，但它分支太多，以至于它被直接开发为Redis存储库中的一个独立的实体。

还有一些目录，但它们对我们的目标并不重要。
我们将主要关注`src`，其中包含Redis实现，探索每个文件中的内容。
文件按照逻辑顺序公开，以便逐步地展示不同层面的复杂实现。

注意：最近Redis被重构了很多。函数名称和文件名已更改，因此您可能会发现此文档更密切地反映了`unstable`分支。
例如，Redis 3.0中的`server.c`和`server.h`文件被重新命名为`redis.c`和`redis.h`。
但总体结构是一样的。请记住，所有新开发和pull请求都应该针对`unstable`分支执行。

server.h
---

理解程序如何工作的最简单方法是理解它使用的数据结构。 所以我们将从Redis的主头文件开始，即`server.h`。

所有服务器配置和一般情况下的所有共享状态都在名为`server`的全局结构中定义，类型为`struct redisServer`。
该结构中的一些重要字段：

* `server.db` 是Redis数据库的数组，其中存储了数据。
* `server.commands` 是命令表。
* `server.clients` 是连接到服务器的客户端的链表。
* `server.master`是一个特殊的客户端，即主服务器，如果当前实例是从服务器。

还有很多其他字段。大多数字段都直接在结构定义中注释。

另一个重要的Redis数据结构是定义客户端的数据结构。
在过去它被称为`redisClient`，现在只是`client`。 结构有很多字段，这里我们只展示主要的字段：

    struct client {
        int fd;
        sds querybuf;
        int argc;
        robj **argv;
        redisDb *db;
        int flags;
        list *reply;
        char buf[PROTO_REPLY_CHUNK_BYTES];
        ... many other fields ...
    }

客户端结构定义了*connected client(连接的客户端)*：

* `fd`字段是客户端套接字文件描述符。
* 使用客户端执行的命令填充`argc`和`argv`，以便实现给定Redis命令的函数可以读取该参数。
* `querybuf`累积来自客户端的请求，Redis服务器根据Redis协议解析请求，并通过调用客户端正在执行的命令的实现来执行。
* `reply`和`buf`是动态和静态缓冲区，用于累积服务器发送给客户端的回复。 一旦文件描述符可写，这些缓冲区就会增量写入套接字。

正如您在上面的客户端结构中所看到的，命令中的参数被描述为`robj`结构。 以下是完整的`robj`结构，它定义了一个 *Redis object(Redis对象)* ：

    typedef struct redisObject {
        unsigned type:4;
        unsigned encoding:4;
        unsigned lru:LRU_BITS; /* lru time (相当于server.lruclock) */
        int refcount;
        void *ptr;
    } robj;

基本上，此结构可以表示所有基本的Redis数据类型，如字符串，列表，集合，排序集等。 有趣的是它有一个`type`字段，因此可以知道给定对象具有什么类型，以及`refcount`，这样可以在多个地方引用同一个对象而无需多次分配它。 最后，`ptr`字段指向对象的实际表示，即使对于相同的类型，也可能会有所不同，具体取决于所使用的`encoding`。

Redis对象在Redis内部广泛使用，但为了避免间接访问的开销，最近在很多地方我们只使用未包装在Redis对象中的普通动态字符串。

server.c
---

这是Redis服务器的入口点，其中定义了`main()`函数。 以下是启动Redis服务器的最重要步骤。

* `initServerConfig()`设置`server`结构的默认值。
* `initServer()` 分配操作所需的数据结构，设置侦听套接字等等。
* `aeMain()` 启动事件循环，侦听新连接。

事件循环定期调用两个特殊函数：

1. `serverCron()`周期性调用（根据`server.hz` 频率），并执行必须时不时执行的任务，例如检查timedout客户端。
2. `beforeSleep()`都会在事件循环触发的时候调用，Redis会提供一些请求，然后返回事件循环。

在server.c中，您可以找到处理Redis服务器其他重要事项的代码：

* `call()`用于调用客户端的上下文中给定的命令。
* `activeExpireCycle()` 通过`EXPIRE`命令处理键的生存时间。
* `freeMemoryIfNeeded()` 将会在 执行新的写入命令但是根据`maxmemory`指令Redis内存不足时 调用。
* 全局变量`redisCommandTable`定义所有Redis命令，指定命令的名称，实现命令的函数，所需的参数数量以及每个命令的其他属性。

networking.c
---

此文件定义了客户端、主服务器和从服务器（在Redis中只是特殊客户端）的所有 I/O 功能：

* `createClient()`分配并初始化一个新客户端。
* 命令实现使用`addReply*()`函数系列，以便将数据附加到客户端结构，该数据将作为对执行的给定命令的回复传输到客户端。
* `writeToClient()`将输出缓冲区中待处理的数据传送到客户端，并由 *writable event handler(writable事件处理程序)* `sendReplyToClient()`调用。
* `readQueryFromClient()`是 *readable event handler(可读事件处理程序)* ，并将从客户端读取的数据累积到查询缓冲区中。
* `processInputBuffer()`是根据Redis协议解析客户端查询缓冲区的入口点。 一旦命令准备好被处理，它就会调用`processCommand()`，它在`server.c`中定义，以便实际执行命令。
* `freeClient()`解除分配，断开连接并删除客户端。

aof.c 和 rdb.c
---

As you can guess from the names these files implement the RDB and AOF
persistence for Redis. Redis uses a persistence model based on the `fork()`
system call in order to create a thread with the same (shared) memory
content of the main Redis thread. This secondary thread dumps the content
of the memory on disk. This is used by `rdb.c` to create the snapshots
on disk and by `aof.c` in order to perform the AOF rewrite when the
append only file gets too big.

The implementation inside `aof.c` has additional functions in order to
implement an API that allows commands to append new commands into the AOF
file as clients execute them.

The `call()` function defined inside `server.c` is responsible to call
the functions that in turn will write the commands into the AOF.

db.c
---

Certain Redis commands operate on specific data types, others are general.
Examples of generic commands are `DEL` and `EXPIRE`. They operate on keys
and not on their values specifically. All those generic commands are
defined inside `db.c`.

Moreover `db.c` implements an API in order to perform certain operations
on the Redis dataset without directly accessing the internal data structures.

The most important functions inside `db.c` which are used in many commands
implementations are the following:

* `lookupKeyRead()` and `lookupKeyWrite()` are used in order to get a pointer to the value associated to a given key, or `NULL` if the key does not exist.
* `dbAdd()` and its higher level counterpart `setKey()` create a new key in a Redis database.
* `dbDelete()` removes a key and its associated value.
* `emptyDb()` removes an entire single database or all the databases defined.

The rest of the file implements the generic commands exposed to the client.

object.c
---

The `robj` structure defining Redis objects was already described. Inside
`object.c` there are all the functions that operate with Redis objects at
a basic level, like functions to allocate new objects, handle the reference
counting and so forth. Notable functions inside this file:

* `incrRefcount()` and `decrRefCount()` are used in order to increment or decrement an object reference count. When it drops to 0 the object is finally freed.
* `createObject()` allocates a new object. There are also specialized functions to allocate string objects having a specific content, like `createStringObjectFromLongLong()` and similar functions.

This file also implements the `OBJECT` command.

replication.c
---

This is one of the most complex files inside Redis, it is recommended to
approach it only after getting a bit familiar with the rest of the code base.
In this file there is the implementation of both the master and slave role
of Redis.

One of the most important functions inside this file is `replicationFeedSlaves()` that writes commands to the clients representing slave instances connected
to our master, so that the slaves can get the writes performed by the clients:
this way their data set will remain synchronized with the one in the master.

This file also implements both the `SYNC` and `PSYNC` commands that are
used in order to perform the first synchronization between masters and
slaves, or to continue the replication after a disconnection.

Other C files
---

* `t_hash.c`, `t_list.c`, `t_set.c`, `t_string.c` and `t_zset.c` contains the implementation of the Redis data types. They implement both an API to access a given data type, and the client commands implementations for these data types.
* `ae.c` implements the Redis event loop, it's a self contained library which is simple to read and understand.
* `sds.c` is the Redis string library, check http://github.com/antirez/sds for more information.
* `anet.c` is a library to use POSIX networking in a simpler way compared to the raw interface exposed by the kernel.
* `dict.c` is an implementation of a non-blocking hash table which rehashes incrementally.
* `scripting.c` implements Lua scripting. It is completely self contained from the rest of the Redis implementation and is simple enough to understand if you are familar with the Lua API.
* `cluster.c` implements the Redis Cluster. Probably a good read only after being very familiar with the rest of the Redis code base. If you want to read `cluster.c` make sure to read the [Redis Cluster specification][3].

[3]: http://redis.io/topics/cluster-spec

Anatomy of a Redis command
---

All the Redis commands are defined in the following way:

    void foobarCommand(client *c) {
        printf("%s",c->argv[1]->ptr); /* Do something with the argument. */
        addReply(c,shared.ok); /* Reply something to the client. */
    }

The command is then referenced inside `server.c` in the command table:

    {"foobar",foobarCommand,2,"rtF",0,NULL,0,0,0,0,0},

In the above example `2` is the number of arguments the command takes,
while `"rtF"` are the command flags, as documented in the command table
top comment inside `server.c`.

After the command operates in some way, it returns a reply to the client,
usually using `addReply()` or a similar function defined inside `networking.c`.

There are tons of commands implementations inside th Redis source code
that can serve as examples of actual commands implementations. To write
a few toy commands can be a good exercise to familiarize with the code base.

There are also many other files not described here, but it is useless to
cover everything. We want to just help you with the first steps.
Eventually you'll find your way inside the Redis code base :-)

Enjoy!
