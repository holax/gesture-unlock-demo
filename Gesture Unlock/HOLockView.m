//
//  HOLockView.m
//  Gesture Unlock
//
//  Created by Phoenix on 10/14/16.
//  Copyright © 2016 Phoenix. All rights reserved.
//

#import "HOLockView.h"

@interface HOLockView ()

@property (nonatomic, strong)NSMutableArray <UIButton *> *btnsArray;

@property (nonatomic, strong)NSMutableArray <UIButton *> *highlightedBtn;

@property (nonatomic ,strong)UIColor *lineColor;

@property (nonatomic, assign)CGPoint endPoint;

@end

@implementation HOLockView



#pragma mark - 画线:依据高亮的按钮集合

- (void)drawRect:(CGRect)rect
{
    //创建路径
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    
        //起点
    
    for (NSInteger i = 0; i < _highlightedBtn.count; i++)
    {
        if (i == 0)
        {
            [linePath moveToPoint:[_highlightedBtn firstObject].center];
        }
        else
        {
            [linePath addLineToPoint:_highlightedBtn[i].center];
        }

    }
    
    //判断是否有起点
    if (_highlightedBtn.count)
    {
        [linePath addLineToPoint:_endPoint];
    }
    
    
    //渲染
    [self.lineColor set];
    
    linePath.lineCapStyle = kCGLineJoinRound;
    
    linePath.lineJoinStyle = kCGLineJoinRound;
    
    linePath.lineWidth = 5;
    
    [linePath stroke];
    
    
}

- (UIColor *)lineColor
{
    if (!_lineColor)
    {
        _lineColor = [UIColor whiteColor];
    }
    return _lineColor;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _highlightedBtn = [NSMutableArray array];
}


#pragma mark - 实现按钮高亮

//按钮自身有事件,系统优先处理
//解决方式:关闭按钮的用户交互
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //1.获取手指触摸的位置
    
    UITouch *touch = [touches anyObject];
    
    CGPoint loction = [touch locationInView:self];
    
    //2.判断触摸的位置是否在九个按钮的frame内
    for (UIButton *btn in _btnsArray)
    {
        //如果在手动设置高亮
        if (CGRectContainsPoint(btn.frame, loction) && !btn.highlighted)
        {
            btn.highlighted = YES;
            [_highlightedBtn addObject:btn];
        }
    }
//    [self setNeedsDisplay];
}


- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //1.获取手指触摸的位置
    
    UITouch *touch = [touches anyObject];
    
    CGPoint location = [touch locationInView:self];
    
    
    
    self.endPoint = location;
    //2.判断触摸的位置是否在九个按钮的frame内
    for (UIButton *btn in _btnsArray)
    {
        //如果在手动设置高亮
        if (CGRectContainsPoint(btn.frame, location) && !btn.highlighted)
        {
            btn.highlighted = YES;
            [_highlightedBtn addObject:btn];
        }
    }
    [self setNeedsDisplay];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    self.endPoint = [_highlightedBtn lastObject].center;
    //拼接tag
    NSMutableString *strM = [NSMutableString string];
    
    for (UIButton *btn in _highlightedBtn)
    {
        [strM appendFormat:@"%@",@(btn.tag)];
    }
    
    
    
    if ([_delegate respondsToSelector:@selector(lockView:withPasswd:)])
    {
        BOOL isTure = [_delegate lockView:self withPasswd:strM];
        
        if (isTure)
        {
            [self clearLine];
        }
        else
        {
            for (UIButton *btn in _highlightedBtn)
            {
                //button不能同时设置两种状态
                btn.highlighted = NO;
                btn.selected = YES;
            }
            self.lineColor = [UIColor redColor];
            
            [self setNeedsDisplay];
            
            //关闭用户交互
            
            self.userInteractionEnabled = NO;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                           {
                               [self clearLine];
                               //清除画线之后打开交互
                               self.userInteractionEnabled = YES;
                           });
        }
    }
    //    if ([strM isEqualToString:@"012345"])
    //    {
    //        UIViewController *newVC = [[UIViewController alloc] init];
    //        newVC.view.backgroundColor = [UIColor purpleColor];
    //
    //        [self clearLine];
    //    }
    
}

- (void)clearLine
{
    //取消高亮
    for (UIButton *btn in _highlightedBtn)
    {
        btn.highlighted = NO;
        btn.selected = NO;
    }
    //清除画线
    
    [_highlightedBtn removeAllObjects];
    [self setNeedsDisplay];
    
    self.lineColor = [UIColor whiteColor];

}

- (NSMutableArray<UIButton *> *)btnsArray
{
    if (!_btnsArray)
    {
        _btnsArray = [NSMutableArray array];
        for (NSInteger i = 0; i < 36; i++)
        {
            UIButton *btn = [[UIButton alloc] init];
            
            btn.tag = i;
            //关闭按钮的交互
            btn.userInteractionEnabled = NO;
            
            [btn setImage:[UIImage imageNamed:@"gesture_node_normal"] forState:UIControlStateNormal];
            
            [btn setImage:[UIImage imageNamed:@"gesture_node_highlighted"] forState:UIControlStateHighlighted];
            [btn setImage:[UIImage imageNamed:@"gesture_node_error"] forState:UIControlStateSelected];
            
            [self addSubview:btn];
            [_btnsArray addObject:btn];
        }

    }
    return _btnsArray;
}

#pragma mark - 自动布局

- (void)layoutSubviews
{
    [super layoutSubviews];
//    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Home_refresh_bg"]];
    self.opaque = NO;
    
    self.backgroundColor = nil;
    
    NSInteger columns = 6;
    
    CGFloat lockW = self.bounds.size.width;
    
    CGFloat btnW = 40;
    CGFloat btnH = 40;
    
    CGFloat marginW = (lockW - columns * btnW) / 5;
    
    [self.btnsArray enumerateObjectsUsingBlock:^(UIButton * btn, NSUInteger idx, BOOL * _Nonnull stop) {
        //列索引
        NSInteger col = idx % columns;
        //行索引
        NSInteger row = idx / columns;
        
        CGFloat btnX = col * (btnW + marginW);
        CGFloat btnY = row * (btnH + marginW);
        
        //设置按钮的frame
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
    }];
    
}
@end
