---
layout: post
title: Objective-C中的锁及应用
date: 2014-02-26 18:45
---
在多线程编程中，锁是非常重要的工具，而Objective-C提供了好几种不同类型的锁，下面就来看一下这些锁都是怎么用的。
 
##0. POSIX Mutex Lock
 
Mutex lock也就是互斥锁，是Unix/Linux平台上提供的一套同步机制。互斥锁提供了三个函数，从函数名就可以知道他们的作用：
 
{% hl %}
 
int pthread_mutex_lock(pthread_mutex_t *mutex);
int pthread_mutex_trylock(pthread_mutex_t *mutex);
int pthread_mutex_unlock(pthread_mutex_t *mutex); 
 
{% endhl %}
 
函数`pthread_mutex_trylock`和`pthread_mutex_lock`的功能完全一致，只不过前者在获取锁失败的情况下会立即返回，而后者则会一直阻塞在那里直到获取到锁为止。互斥锁的使用非常的简单，直接调用上面三个API就可以了：
 
{% hl %}
 
pthread_mutex_t mutex;
void MyInitFunction()
{
    pthread_mutex_init(&mutex, NULL);
}
 
void MyLockingFunction()
{
    pthread_mutex_lock(&mutex);
    // Do work.
    pthread_mutex_unlock(&mutex);
}
 
{% endhl %}
 
##1. NSLock
 
NSLock类使用的是POSIX线程来实现它的锁操作，而且需要注意的是必须在同一线程内发送unlock消息，否则会发生不确定的情况。NSLock不能被用来实现迭代锁，因为如果发生lock消息两次的话，整个线程将被永久锁住。
 
{% hl %}
 
BOOL moreToDo = YES;
NSLock *theLock = [[NSLock alloc] init];
...
while (moreToDo) {
    /* Do another increment of calculation */
    /* until there’s no more to do. */
    if ([theLock tryLock]) {
        /* Update display used by all threads. */
        [theLock unlock];
    }
}
 
{% endhl %}
 
##2. @synchronized
 
@synchronized是在Objective-C中最简单方法，只要有个Objective-C对象就可以完成线程同步操作。
 
{% hl %}
 
- (void)myMethod:(id)anObj
{
    @synchronized(anObj)
    {
        // Everything between the braces is protected by the @synchronized directive.
    }
}
 
{% endhl %}
 
需要注意的是，@synchronized会隐式地添加异常处理代码，也就是当发生异常时会自动释放互斥锁，所以会有一定的性能损耗。
 
##3. NSRecursiveLock
 
NSRecursiveLock类定义了可以被同一线程获取多次而不会造成死锁的锁。NSRecursiveLock可以被用在递归调用中，但是只有当多次获取的锁全部释放时，NSRecursiveLock才能被其他线程获取。
 
{% hl %}
 
NSRecursiveLock *theLock = [[NSRecursiveLock alloc] init];
 
void MyRecursiveFunction(int value)
{
    [theLock lock];
    if (value != 0)
    {
        --value;
        MyRecursiveFunction(value);
    }
    [theLock unlock];
}
 
MyRecursiveFunction(5);
 
{% endhl %}
 
##4. NSConditionLock
 
NSConditionLock定义了一个条件互斥锁，也就是当条件成立时就会获取到锁，反之就会释放锁。因为这个特性，条件锁可以被用在有特定顺序的处理流程中，比如生产者-消费者问题。
 
{% hl %}
 
id condLock = [[NSConditionLock alloc] initWithCondition:NO_DATA];
 
// producer
while(true)
{
    [condLock lock];
    /* Add data to the queue. */
    [condLock unlockWithCondition:HAS_DATA];
}
 
// consumer
while (true)
{
    [condLock lockWhenCondition:HAS_DATA];
    /* Remove data from the queue. */
    [condLock unlockWithCondition:(isEmpty ? NO_DATA : HAS_DATA)];
 
    // Process the data locally.
}
 
{% endhl %}
 
条件锁的初始状态是`NO_DATA`，所以生产者线程在这个时候就会获取到锁，生产完成后再把状态设置为`HAS_DATA`；这时消费者线程发现条件变成`HAS_DATA`后就可以获取到锁，直到消费结束后再把状态设置成`NO_DATA`。
 
##5. NSDistributedLock
 
NSDistributedLock是跨进程的分布式锁，底层是用文件系统实现的互斥锁。NSDistributedLock没有实现NSLocking协议，所以没有会阻塞线程的lock方法，取而代之的是非阻塞的tryLock方法。NSDistributedLock只有在锁持有者显式地释放后才会被释放，也就是说当持有锁的应用崩溃后，其他应用就不能访问受保护的共享资源了。
 
##6. NSCondition
 
NSCondition类是互斥锁和条件锁的结合体，也就是一个线程在等待信号而阻塞时，可以被另外一个线程唤醒。需要注意的是，由于操作系统实现的差异，即使在代码中没有发送signal消息，线程也有可能被唤醒，所以需要增加谓词变量来保证程序的正确性。
 
{% hl %}
 
[cocoaCondition lock];
while (timeToDoWork <= 0)
    [cocoaCondition wait];
 
timeToDoWork--;
 
// Do real work here.
 
[cocoaCondition unlock];
 
{% endhl %}
 
在其他线程中唤醒：
 
{% hl %}
 
[cocoaCondition lock];
timeToDoWork++;
[cocoaCondition signal];
[cocoaCondition unlock];
 
{% endhl %}
 
##7. POSIX Conditions
 
在Unix/Linux平台上也提供了一套条件互斥锁的API：
 
{% hl %}
 
// 初始化
int pthread_cond_init (pthread_cond_t *cond, pthread_condattr_t *attr);
 
// 等待（会阻塞）
int pthread_cond_wait (pthread_cond_t *cond, pthread_mutex_t *mut);
 
// 定时等待
int pthread_cond_timedwait (pthread_cond_t *cond, pthread_mutex_t *mut, const struct timespec *abstime);
 
// 唤醒
int pthread_cond_signal (pthread_cond_t *cond);
 
// 广播唤醒
int pthread_cond_broadcast (pthread_cond_t *cond);
 
// 销毁
int pthread_cond_destroy (pthread_cond_t *cond);
 
{% endhl %}
 
和NSCondition类一样，POSIX Conditions也需要和谓词配合使用以确保程序的正确性。
 
{% hl %}
 
pthread_mutex_t mutex;
pthread_cond_t condition;
Boolean     ready_to_go = true;
 
void MyCondInitFunction()
{
    pthread_mutex_init(&mutex);
    pthread_cond_init(&condition, NULL);
}
 
void MyWaitOnConditionFunction()
{
    // Lock the mutex.
    pthread_mutex_lock(&mutex);
 
    // If the predicate is already set, then the while loop is bypassed;
    // otherwise, the thread sleeps until the predicate is set.
    while(ready_to_go == false)
    {
        pthread_cond_wait(&condition, &mutex);
    }
 
    // Do work. (The mutex should stay locked.)
 
    // Reset the predicate and release the mutex.
    ready_to_go = false;
    pthread_mutex_unlock(&mutex);
}
 
void SignalThreadUsingCondition()
{
    // At this point, there should be work for the other thread to do.
    pthread_mutex_lock(&mutex);
    ready_to_go = true;
 
    // Signal the other thread to begin work.
    pthread_cond_signal(&condition);
 
    pthread_mutex_unlock(&mutex);
}
 
{% endhl %}
 
 
##参考资料
 
[1] [Threading Programming Guide](https://developer.apple.com/library/mac/documentation/cocoa/conceptual/Multithreading/ThreadSafety/ThreadSafety.html)