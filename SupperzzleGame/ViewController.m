//
//  ViewController.m
//  SupperzzleGame
//
//  Created by debao.com on 2016/11/14.
//  Copyright © 2016年 Debao. All rights reserved.
//

#import "ViewController.h"
#import "WJGCDTimerManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor grayColor];
    
    [self initData];
    [self initMenu];
    [self initMap];
    [self startGame];
    
}

- (void)initData{
    _bgWidth = [UIScreen mainScreen].bounds.size.width;
    _bgHeight = [UIScreen mainScreen].bounds.size.height;
    _hiddenItemNum = 0;
    _itemButtons = [[NSMutableArray alloc] init];
    _level = 1;
    _score = 0;
    _timerContainer = [[NSMutableDictionary alloc] init];
}

- (void)initMenu{
    _levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 120, 40)];
    _levelLabel.text = @"当前关卡:1";
    [self.view addSubview:_levelLabel];
    _scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(_bgWidth-10-120, 10, 120, 40)];
    _scoreLabel.text = @"当前得分:0";
    [self.view addSubview:_scoreLabel];
}

- (void)startGame{
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Failed" message:@"闯关失败，请再接再厉" preferredStyle:UIAlertControllerStyleAlert];
//        [self presentViewController:alertController animated:YES completion:nil];
//        UIAlertAction *actionAgain = [UIAlertAction actionWithTitle:@"重玩" style:UIAlertActionStyleDefault handler: ^(UIAlertAction * _Nonnull action) {
//            [self playAgain];
//        }];
//        [alertController addAction:actionAgain];
//    });
    
    //拿到一个队列
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t queue = dispatch_get_main_queue();
    //创建一个timer放到队列里面
    dispatch_source_t timer = [self.timerContainer objectForKey:@"GameFailed"];
    if (!timer) {
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        //激活timer
        dispatch_resume(timer);
        //将定时器对象加到容器中，这一步操作不做，延时操作不生效
        [self.timerContainer setObject:timer forKey:@"GameFailed"];
    }
    /* timer精度为0.1秒 */
    //设置timer的首次执行时间、执行时间间隔、精确度
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, 6 * NSEC_PER_SEC), 6 * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
    
    __weak typeof(self) weakSelf = self;
    //设置timer执行的事件
    dispatch_source_set_event_handler(timer, ^{
        [weakSelf gameFailed];
    });
    
    //取消timer
//    dispatch_source_cancel(timer);
    
    /*
     改写JX_GCDTimerManager为WJGCDTimerManager
     以后遇到好的代码都可以用WJ+类名的形式实现，形成一套规范
     */
//    [[WJGCDTimerManager sharedInstance] scheduledDispatchTimerWithName:@"GameFailed" timeInterval:10 queue:nil repeats:NO actionOption:AbandonPreviousAction action:^{
//        [self gameFailed];
//    }];
//    [[WJGCDTimerManager sharedInstance] scheduledDispatchTimerWithName:@"GameFailed" timeInterval:10 queue:dispatch_get_main_queue() repeats:YES actionOption:AbandonPreviousAction action:^{
//        [self gameFailed];
//    }];
}

- (void)gameFailed{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Failed" message:@"闯关失败，请再接再厉" preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alertController animated:YES completion:nil];
    UIAlertAction *actionAgain = [UIAlertAction actionWithTitle:@"重玩" style:UIAlertActionStyleDefault handler: ^(UIAlertAction * _Nonnull action) {
        [self playAgain];
    }];
    [alertController addAction:actionAgain];
    dispatch_source_t timer = [self.timerContainer objectForKey:@"GameFailed"];
    if (timer) {
        //取消timer
        dispatch_source_cancel(timer);
        [self.timerContainer removeObjectForKey:@"GameFailed"];
    }
}

- (void)playAgain{
    [self reset];
    [self initMap];
    [self startGame];
}

- (void)playNext{
    _level = _level+1;
    _levelLabel.text = [NSString stringWithFormat:@"当前关卡:%d", _level];
    [self reset];
    [self initMap];
    [self startGame];
}

- (void)reset{
    if ([_itemButtons count] > 0) {
        for (int i = [_itemButtons count]-1; i>=0 ; i--) {
            UIButton *button = [_itemButtons objectAtIndex:i];
            [_itemButtons removeObjectAtIndex:i];
            [button removeFromSuperview];
        }
    }
}

- (void)initMap{
    UIImage* temp = [UIImage imageNamed:@"center.bmp"];
    CGFloat itemWidth = temp.size.width;
    CGFloat itemHeight = temp.size.height;
    NSArray* file_name = [NSArray arrayWithObjects:@"tiao1.bmp", @"center.bmp", @"east.bmp", @"fafa.bmp", @"north.bmp", @"south.bmp", @"west.bmp", nil];
    NSMutableArray* itemCreate = [[NSMutableArray alloc] init];
    NSMutableArray* gameMap = [[NSMutableArray alloc] init];
    _itemCount = 36;
    for(int i = 0 ; i < _itemCount/2 ; i++){
        int value = (int)random()%[file_name count];
        if(i<[file_name count]){
            value = i;
        }
        [itemCreate setObject:[NSNumber numberWithInt:value] atIndexedSubscript:i];
    }
    for(int i = 0 ; i < _itemCount ; i++){
        [gameMap setObject:[NSNumber numberWithInt:-1] atIndexedSubscript:i];
    }
    for(int i = 0 ; i < _itemCount/2 ; i++){
        int pos = random()%_itemCount;
        while(true){
            NSNumber *num = [gameMap objectAtIndex:pos];
            if([num intValue]==-1){
                break;
            }
            pos = random()%_itemCount;
        }
        [gameMap setObject:itemCreate[i] atIndexedSubscript:pos];
        pos = random()%_itemCount;
        while(true){
            NSNumber *num = [gameMap objectAtIndex:pos];
            if([num intValue]==-1){
                break;
            }
            pos = random()%_itemCount;
        }
        [gameMap setObject:itemCreate[i] atIndexedSubscript:pos];
    }
    for(int i = 0 ; i < _itemCount ; i++){
        NSLog(@"%d", [[gameMap objectAtIndex:i] intValue]);
    }
    
    CGFloat centerX = _bgWidth/2;
    CGFloat centerY = _bgHeight/2;
    for(int i = 0 ; i < _itemCount ; i++){
        int index = [[gameMap objectAtIndex:i] intValue];
        NSString *filename = [file_name objectAtIndex:index];
        NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setBackgroundImage:image forState:UIControlStateNormal];
        button.frame = CGRectMake(centerX+(i%6-3)*itemWidth, centerY+(i/6)*itemHeight, image.size.width, image.size.height);
        [self.view addSubview:button];
        [button addTarget:self action:@selector(pressBtn:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = index;
        [_itemButtons setObject:button atIndexedSubscript:i];
    }
}

- (void)pressBtn:(UIButton *)button{
    static BOOL hasSelected = NO;
    if(hasSelected==NO){
        _selectButton = button;
        button.enabled = NO;
        button.alpha = 0.5;
        hasSelected = true;
        return;
    }
    if (_selectButton.tag == button.tag) {
        _selectButton.hidden = YES;
        button.hidden = YES;
        _hiddenItemNum+=2;
        if (_hiddenItemNum==_itemCount) {
            [self gameSuccess];
        }
    }
    _selectButton.enabled = YES;
    _selectButton.alpha = 1;
    hasSelected = NO;
    _selectButton = nil;
}

- (void)gameSuccess{
    
    dispatch_source_t timer = [self.timerContainer objectForKey:@"GameFailed"];
    if (timer) {
        //取消timer
        dispatch_source_cancel(timer);
        [self.timerContainer removeObjectForKey:@"GameFailed"];
    }
    _score = _score+_level*10;
    _scoreLabel.text = [NSString stringWithFormat:@"当前得分:%d", _score];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Success" message:@"恭喜您过关！" preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alertController animated:YES completion:nil];
    UIAlertAction *actionAgain = [UIAlertAction actionWithTitle:@"重玩" style:UIAlertActionStyleCancel handler: ^(UIAlertAction * _Nonnull action) {
        [self playAgain];
    }];
    [alertController addAction:actionAgain];
    UIAlertAction *actionNext = [UIAlertAction actionWithTitle:@"下一关" style:UIAlertActionStyleDefault handler: ^(UIAlertAction * _Nonnull action) {
        [self playNext];
    }];
    [alertController addAction:actionNext];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
