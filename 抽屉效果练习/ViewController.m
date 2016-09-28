//
//  ViewController.m
//  抽屉效果练习
//
//  Created by qianfeng on 16/9/27.
//  Copyright © 2016年 com.xuwenjie. All rights reserved.
//

#import "ViewController.h"

#import "mainContentViewController.h"
#import "LeftView.h"
#import "MainContentView.h"

#define kScreenSize            [[UIScreen mainScreen] bounds].size
#define kScreenWidth           [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight          [[UIScreen mainScreen] bounds].size.height

#define kOffxScale             0.6  //抽屉效果占比
#define kOffyMax               80

@interface ViewController ()

{
    mainContentViewController *_mainVC;
}

@property (nonatomic,weak) LeftView *leftView;
@property (nonatomic,weak) MainContentView *mainContentView;


@property (nonatomic,assign) CGFloat scaleNum;    //缩放比例  （0.000000-1.000000）

@end

@implementation ViewController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self leftView];
    
    [self mainContentView];
    
    [self createMainVC];
    
}
#pragma mark - Lazy Load
- (UIView *)leftView {
    if (!_leftView) {
        LeftView *leftView = [[LeftView alloc] initWithFrame:self.view.bounds];
        leftView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:leftView];
        _leftView = leftView;
    }
    return _leftView;
}

- (UIView *)mainContentView {
    if (!_mainContentView) {
        MainContentView *mainContentView = [[MainContentView alloc] initWithFrame:self.view.bounds];
        mainContentView.backgroundColor = [UIColor orangeColor];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandle:)];
        
        [mainContentView addGestureRecognizer:pan];
        
        [self.view addSubview:mainContentView];
        _mainContentView = mainContentView;
    }
    return _mainContentView;
}

#pragma mark - Others
- (void)panHandle:(UIPanGestureRecognizer *)pan {
    
    CGPoint panPoint = [pan translationInView:self.view];

    //禁止向左滑动
    if (_mainContentView.frame.origin.x == 0 && panPoint.x < 0) {
        return;
    }
    
    //移动主视图
    CGPoint mainViewCenter = _mainContentView.center;

    mainViewCenter.x += panPoint.x;
    mainViewCenter.y = kScreenHeight / 2;
    
    _mainContentView.center = mainViewCenter;
    
    [pan setTranslation:CGPointMake(0, 0) inView:self.view];
    
    //原点偏移量
    CGFloat offX = _mainContentView.frame.origin.x;
    
    _mainContentView.frame = [self calculateWithOffx:offX];
    
    //停止拖动时触发
    if (pan.state == UIGestureRecognizerStateEnded) {
        if (offX <= kScreenWidth / 2) {
            offX = 0;
        } else {
            offX = kScreenWidth * kOffxScale;
        }
        [UIView animateWithDuration:0.25 animations:^{
            
            _mainContentView.frame = [self calculateWithOffx:offX];
        }];
    }
}




/**
 根据偏移量计算这个时候的mainContentView的frame

 @param offx 横向偏移量

 @return 此时mainContentView的frame
 */
- (CGRect)calculateWithOffx:(CGFloat)offx {
    
    self.scaleNum = offx / (kScreenWidth * kOffxScale);
    
    //height因该减小的高度
    CGFloat y_short = kOffyMax * self.scaleNum;
    
    //mainContentView应该变为原来尺寸的比例
    CGFloat mainContentViewScale = (kScreenHeight - y_short) / kScreenHeight;
    
    CGRect rect = CGRectMake(offx, y_short / 2, kScreenWidth * mainContentViewScale, kScreenHeight * mainContentViewScale);
   
    return rect;
}


/**
 创建主页面控制器
 */
- (void)createMainVC {
    
    mainContentViewController *mainVC = [[mainContentViewController alloc] init];
    _mainVC = mainVC;
    
    UINavigationController *mainNV = [[UINavigationController alloc] initWithRootViewController:mainVC];

    mainVC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"我" style:UIBarButtonItemStylePlain target:self action:@selector(showLeftView:)];
    
    [_mainContentView addSubview:mainNV.view];
}


/**
 显示左边的页面（抽屉效果）
 */
- (void)showLeftView:(UIBarButtonItem *)sender {
    
    BOOL isShow = _mainContentView.frame.origin.x == 0 ? YES : NO;
    
    CGFloat offX = 0;
    if (isShow) {
        offX = kScreenWidth * kOffxScale;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        _mainContentView.frame = [self calculateWithOffx:offX];
    }];
}

@end
