//
//  LYTDrawView.m
//  TouchTracker
//
//  Created by 栾云腾 on 15/12/15.
//  Copyright © 2015年 栾云腾. All rights reserved.
//

#import "LYTDrawView.h"
#import "LYTLine.h"

@interface LYTDrawView() <UIGestureRecognizerDelegate>

//@property (nonatomic,strong) LYTLine *currentLine;
@property (nonatomic,strong) NSMutableDictionary *linesInProgress;
@property (nonatomic,strong) NSMutableArray *finishedLines;
@property (nonatomic,weak) LYTLine *selectedLine; //选中的线
@property (nonatomic,strong) UIPanGestureRecognizer *moveRecognizer;
@property BOOL flag;//记录是否出现menuController
@end

@implementation LYTDrawView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.linesInProgress = [[NSMutableDictionary alloc] init];
        self.finishedLines = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor grayColor];
        self.flag = NO;
        
        //支持多点触控
        self.multipleTouchEnabled = YES;
        
        //双击事件识别
        UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        doubleTapRecognizer.numberOfTapsRequired = 2;
        
        //解决双击时出现红点的问题
        doubleTapRecognizer.delaysTouchesBegan = YES;
        
        [self addGestureRecognizer:doubleTapRecognizer];
        
        //单击事件识别
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        tapRecognizer.delaysTouchesBegan = YES;
        
        //解决单击与双击之间的冲突问题
        [tapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
        
        [self addGestureRecognizer:tapRecognizer];
        
        //长按事件识别
        UILongPressGestureRecognizer *longPressRecognizer =[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [self addGestureRecognizer:longPressRecognizer];
        
        //拖动事件识别
        self.moveRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveLine:)];
        self.moveRecognizer.delegate = self;
        self.moveRecognizer.cancelsTouchesInView = NO;
        [self addGestureRecognizer:self.moveRecognizer];
    }
    return self;
}

//拖动事件
-(void)moveLine:(UIPanGestureRecognizer *)gr{
    //如果没有选中的线条就直接返回
    if (self.flag == YES) {
        return;
    }
    if (!self.selectedLine) {
        return;
    }
    
    //如果UIPanGestureRecognizer处于“变化后”状态
    if (gr.state == UIGestureRecognizerStateChanged) {
        //获取手指的拖动距离
        CGPoint translation = [gr translationInView:self];
        
        CGPoint begin = self.selectedLine.begin;
        CGPoint end = self.selectedLine.end;
        begin.x += translation.x;
        begin.y += translation.y;
        end.x += translation.x;
        end.y +=translation.y;
        
        //为选中的线条设置新的起点和终点
        self.selectedLine.begin = begin;
        self.selectedLine.end = end;
        
        [self setNeedsDisplay];
        
        [gr setTranslation:CGPointZero inView:self];
    }
}

//双击事件
-(void)doubleTap:(UIGestureRecognizer *)gr{
    NSLog(@"Recognized Double Tap");
    
    [self.linesInProgress removeAllObjects];
    [self.finishedLines removeAllObjects];
    [self setNeedsDisplay];
}

//单击事件
-(void)tap:(UIGestureRecognizer *)gr{
    NSLog(@"Recognized Tap");
    
    CGPoint p = [gr locationInView:self];
    self.selectedLine = [self lineAtPoint:p];
    
    //利用UIMenuController显示菜单
    if (self.selectedLine) {
        //使视图成为UIMenuItem动作消息的对象
        [self becomeFirstResponder];
        
        //获取UIMenuController对象
        UIMenuController *menu = [UIMenuController sharedMenuController];
        
        //创建一个新的标题为“DELETE”的UIMenuItem
        UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(deleteLine:)];
        menu.menuItems = @[deleteItem];
        
        //先为menuItem设置显示区域并设置为可见
        [menu setTargetRect:CGRectMake(p.x, p.y, 2, 2) inView:self];
        [menu setMenuVisible:YES animated:YES];
        self.flag = YES;
    } else{
        //如果没有选中的线条，就隐藏UIMenuController对象
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
        self.flag = NO;
    }
    
    [self setNeedsDisplay];
}

//长按事件
-(void)longPress:(UIGestureRecognizer *)gr{
    if (gr.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [gr locationInView:self];
        self.selectedLine = [self lineAtPoint:point];
        
        if (self.selectedLine) {
            [self.linesInProgress removeAllObjects];
        }
    }else if (gr.state ==UIGestureRecognizerStateEnded){
        self.selectedLine = nil;
    }
    
    [self setNeedsDisplay];
}


//处理长按和拖动的冲突问题
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    if (gestureRecognizer == self.moveRecognizer) {
        return YES;
    }
    return NO;
}

//如果要设置一个自定义的VIEW为第一响应对象，必须覆盖该方法
-(BOOL)canBecomeFirstResponder{
    return YES;
}

-(void)deleteLine:(id)sender{
    [self.finishedLines removeObject:self.selectedLine];
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect{
    static int test = 0;
    NSLog(@"%i",test);
    test++;
    //[[UIColor blackColor] set];
    for (LYTLine *line in self.finishedLines) {
        float x = line.end.x-line.begin.x;
        float y = line.end.y-line.begin.y;
        float z = sqrt(x*x+y*y);   //斜边
        float sin;
        if (z!=0) {
            sin = x/z;
        }else{
            sin = 0;
        }
        NSLog(@"sin:%f",sin);
        UIColor *sinColor = [UIColor colorWithHue: sqrt(sin*sin) saturation:0.8 brightness:0.8 alpha:1.0];
        [sinColor set];
        [self strokeLine:line];
    }
    
//    if (self.currentLine) {
//        //用红色绘制正在画的线条
//        [[UIColor redColor] set];
//        [self strokeLine:self.currentLine];
//    }
    
    [[UIColor redColor] set];
    for (NSValue *key in self.linesInProgress) {
        [self strokeLine:self.linesInProgress[key]];
    }
    
    //用绿色绘制选中的线条
    
    if (self.selectedLine) {
        [[UIColor greenColor] set];
        [self strokeLine:self.selectedLine];
    }
}

//绘制直线
-(void)strokeLine:(LYTLine *)line{
    UIBezierPath *bp = [UIBezierPath bezierPath];
    bp.lineWidth = 10;
    bp.lineCapStyle = kCGLineCapRound;
    
    [bp moveToPoint:line.begin];
    [bp addLineToPoint:line.end];
    [bp stroke];
}

//找到距离最近的直线
-(LYTLine*)lineAtPoint:(CGPoint)p{
    
    for(LYTLine *line in self.finishedLines){
        CGPoint start = line.begin;
        CGPoint end = line.end;
        
        //检查线条的若干点
        for(float t = 0;t<=1.0;t+=0.05){
            float x = start.x +t*(end.x-start.x);
            float y = start.y +t*(end.y-start.y);
            
            //如果距离小于20个点，则返回
            if(hypot(x-p.x,y-p.y)<20.0){
                return line;
            }
        }
    }
    return nil;
}
#pragma mark - 触摸事件相关
//单点触控方法
//-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    UITouch *t = [touches anyObject];
//    
//    //根据触摸位置创建LYTLine对象
//    CGPoint location = [t locationInView:self];
//    self.currentLine = [[LYTLine alloc] init];
//    self.currentLine.begin = location;
//    self.currentLine.end = location;
//    
//    [self setNeedsDisplay];//重绘
//}

//多点触控方法
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //向控制台输出日志，查看触摸事件发生顺序
    NSLog(@"%@",NSStringFromSelector(_cmd));
    
    for (UITouch *t in touches) {
        CGPoint location = [t locationInView:self];
        
        LYTLine *line = [[LYTLine alloc] init];
        line.begin = location;
        line.end = location;
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        [self.linesInProgress setObject:line forKey:key];
    }
    
    [self setNeedsDisplay];
}

//单点触控方法
//-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    UITouch *t = [touches anyObject];
//    CGPoint location = [t locationInView:self];
//    
//    self.currentLine.end = location;
//    
//    [self setNeedsDisplay];
//}

//多点触控方法
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //向控制台输出日志，查看触摸事件发生的顺序
    NSLog(@"%@",NSStringFromSelector(_cmd));
    if (touches.count == 3) {
        NSLog(@"三指滑动");
    }
    for (UITouch *t in touches) {
        CGPoint location = [t locationInView:self];
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        LYTLine *line = self.linesInProgress[key];
        line.end = location;
    }
    
    [self setNeedsDisplay];
}

//单点触控方法
//-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [self.finishedLines addObject:self
//     .currentLine];
//    self.currentLine = nil;
//    
//    [self setNeedsDisplay];
//}

//多点触控方法
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    for (UITouch *t in touches) {
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        LYTLine *line = self.linesInProgress[key];
        
        [self.finishedLines addObject:line];
        [self.linesInProgress removeObjectForKey:key];
    }
    
    [self setNeedsDisplay];
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //向控制台输出日志，查看触摸事件发生顺序
    NSLog(@"%@",NSStringFromSelector(_cmd));
    
    for (UITouch *t in touches) {
        NSValue * key = [NSValue valueWithNonretainedObject:t];
        [self.linesInProgress removeObjectForKey:key];
    }
    
    [self setNeedsDisplay];
}
@end
