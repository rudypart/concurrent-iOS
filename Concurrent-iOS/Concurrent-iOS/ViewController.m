//
//  ViewController.m
//  Concurrent-iOS
//
//  Created by joey_qi on 2017/9/29.
//  Copyright © 2017年 joey_qi. All rights reserved.
//

#import "ViewController.h"
#import "UIImageView+WebCache.h"
#import "NSString+Crp.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *webImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.view.backgroundColor = [UIColor redColor];
    [self.webImageView sd_setImageWithURL:[NSURL URLWithString:@"https://blog.ibireme.com/wp-content/uploads/2015/05/RunLoop_0.png"]];
    
    NSString *str = [@"hehe" crp];
    NSLog(@"%@", str);
}

/*
 1.将需要执行的操作封装到一个NSOperation对象中
 2.将NSOperation对象添加到NSOperationQueue中
 3.系统将自动从队列中取出操作对象
 5.将NSOperation对象放到一条新的线程中执行（并发）
 */
- (void)test1
{
    //
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//    queue.maxConcurrentOperationCount = 1;
    for (int i=0; i<10000; i++) {
        NSOperation *op = [self taskWithData:[NSString stringWithFormat:@"%d op",i]];
        //[op start];
        [queue addOperation:op];
    }
}

- (void)test2
{
    //
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSOperation *op0 = [self taskWithData:@0];
    NSOperation *op1 = [self taskWithData:@1];
    NSOperation *op2 = [self taskWithData:@2];

    NSOperationQueue *queue1 = [[NSOperationQueue alloc] init];
    NSOperation *op3 = [self taskWithData:@3];
    NSOperation *op4 = [self taskWithData:@4];

    [op3 addDependency:op0];
    [op0 addDependency:op1];
    [op1 addDependency:op2];
    [op2 addDependency:op4];

    [queue1 addOperation:op3];
    [queue1 addOperation:op4];
    [queue addOperation:op0];
    [queue addOperation:op1];
    [queue addOperation:op2];
    
}


- (NSOperation *)taskWithData:(id)data
{
    NSInvocationOperation *theOp = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(myTaskMethod:) object:data];
    return theOp;
}

- (void)myTaskMethod:(id)data {
    // Perform the task.
    NSLog(@"data:%@,%@", data, [NSThread currentThread]);
}

#pragma mark -

- (void)test4
{
    dispatch_queue_t serialQueue = dispatch_queue_create("com.joey.qi", DISPATCH_QUEUE_SERIAL);
    for (int i=0; i<1000; i++) {
        dispatch_async(serialQueue, ^{
            NSLog(@"%d,%@", i, [NSThread currentThread]);
        });
    }
   
}

- (void)test5
{
    dispatch_queue_t myCustomQueue;
    myCustomQueue = dispatch_queue_create("com.example.MyCustomQueue", NULL);
    
    dispatch_async(myCustomQueue, ^{
        printf("Do some work here.\n");
    });
    
    printf("The first block may or may not have run.\n");
    
    dispatch_sync(myCustomQueue, ^{
        printf("Do some more work here.\n");
    });
    printf("Both blocks have completed.\n");
    
}

- (void)test6
{
    int count = 1000;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_apply(count, queue, ^(size_t i) {
        NSLog(@"%zu, %@",i,[NSThread currentThread]);
    });
}

- (void)test7
{
    NSLog(@"执行任务0");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"执行任务1");
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"执行1完毕");
        });
    });
    for (int i=2; i<10000; i++) {
        NSLog(@"执行任务%d", i);
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_suspend(queue);
    dispatch_resume(queue);
}

- (void)test8
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    //Add a task to the group
    dispatch_group_async(group, queue, ^{
        // Some asynchronous work
    });
    

    // Do some other work while the tasks execute.
    // When you cannot make any more forward progress,
    // wait on the group to block the current thread.
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
}

dispatch_source_t CreateDispatchTimer(uint64_t interval,
                                      uint64_t leeway,
                                      dispatch_queue_t queue,
                                      dispatch_block_t block)
{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                                     0, 0, queue);
    if (timer)
    {
        dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), interval, leeway);
        dispatch_source_set_event_handler(timer, block);
        dispatch_resume(timer);
    }
    return timer;
}

void MyCreateTimer()
{
}


@end
