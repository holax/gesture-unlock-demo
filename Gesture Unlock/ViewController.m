//
//  ViewController.m
//  Gesture Unlock
//
//  Created by Phoenix on 10/14/16.
//  Copyright © 2016 Phoenix. All rights reserved.
//

#import "ViewController.h"
#import "HOLockView.h"

@interface ViewController ()<HOLockViewDelegate>
@property (weak, nonatomic) IBOutlet HOLockView *lockView;

@end

@implementation ViewController



- (void)performDismiss:(NSTimer *)timer
{
    UIAlertController *alert = [timer userInfo];
    [alert dismissViewControllerAnimated:YES completion:nil];
    
    alert = nil;
}


- (BOOL)lockView:(HOLockView *)lockView withPasswd:(NSString *)passwd
{
    
    //Alert
    UIAlertController *rightAVC = [UIAlertController alertControllerWithTitle:@"FBI WARNING" message:@"密码正确!(次弹窗2s后消失)" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertController *wrongAVC = [UIAlertController alertControllerWithTitle:@"FBI WARNING" message:@"密码错误!!!(此弹窗2s后消失)" preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *cancelAct = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAct = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDestructive handler:nil];
    UIAlertAction *accessAct = [UIAlertAction actionWithTitle:@"进入下一个控制器" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        UIViewController *VC = [[UIViewController alloc] init];
        VC.view.backgroundColor = [UIColor grayColor];
        [self presentViewController:VC animated:YES completion:nil];
        
    }];

    [wrongAVC addAction:cancelAct];
    [wrongAVC addAction:okAct];
    
    [rightAVC addAction:cancelAct];
    [rightAVC addAction:accessAct];
    
    
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(performDismiss:) userInfo:wrongAVC repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(performDismiss:) userInfo:rightAVC repeats:NO];
    //判断
    if ([passwd isEqualToString:@"012345"])
    {
        [self presentViewController:rightAVC animated:YES completion:nil];
        return YES;
    }
    else
    {
        [self presentViewController:wrongAVC animated:YES completion:nil];
//        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        return NO;
    }
}





- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.lockView.delegate = self;
    
    
    UILabel *passlabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 160, 30)];
    
    passlabel.textAlignment = NSTextAlignmentCenter;
    passlabel.backgroundColor = [UIColor whiteColor];
    passlabel.text = @"初始密码为:012345";
    
    [self.view addSubview:passlabel];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Home_refresh_bg"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
