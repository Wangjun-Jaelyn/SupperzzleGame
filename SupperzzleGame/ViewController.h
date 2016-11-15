//
//  ViewController.h
//  SupperzzleGame
//
//  Created by debao.com on 2016/11/14.
//  Copyright © 2016年 Debao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property(nonatomic)CGFloat bgHeight;
@property(nonatomic)CGFloat bgWidth;
@property(nonatomic, copy)UIButton *selectButton;
@property(nonatomic)int itemCount;
@property(nonatomic)int hiddenItemNum;
@property(nonatomic, copy)NSMutableArray *itemButtons;
@property(nonatomic, strong)UILabel *levelLabel;
@property(nonatomic)int level;
@property(nonatomic, strong)UILabel *scoreLabel;
@property(nonatomic)int score;
@property(nonatomic, strong)NSMutableDictionary *timerContainer;
@end

