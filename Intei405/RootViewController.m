//
//  RootViewController.m
//  Intei405
//
//  Created by 栾云腾 on 16/1/6.
//  Copyright © 2016年 栾云腾. All rights reserved.
//

#import "RootViewController.h"
#import "EnvironmentViewController.h"
#import "BookViewController.h"
#import "PersonViewController.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
CGFloat const tabViewHeight = 49;
CGFloat const buttonWidth = 64;
CGFloat const buttonHeight = 45;

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBar.hidden = YES;
    [self initViewController];
    [self initTabBarView];
    // Do any additional setup after loading the view.
}

-(void)initViewController{
    EnvironmentViewController *environmentVC = [[EnvironmentViewController alloc] init];
    BookViewController *bookVC = [[BookViewController alloc]init];
    PersonViewController *personVC = [[PersonViewController alloc]init];
    NSArray *VCarray = @[environmentVC,bookVC,personVC];
    NSMutableArray *tabArray = [NSMutableArray arrayWithCapacity:VCarray.count];
    for (int i = 0; i<VCarray.count; i++) {
        UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:VCarray[i]];
        [tabArray addObject:nvc];
    }
    self.viewControllers = tabArray;
}
//自定义标签工具栏
-(void)initTabBarView{
    //初始化标签工具栏视图
    _tabBarView = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeight-tabViewHeight, kScreenWidth, tabViewHeight)];
    _tabBarView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_tabBarView];
    NSArray *imgArray = @[@"环境图标.jpg",@"书籍图标.jpg",@"人物图标.jpg"];
    for (int i = 0; i<imgArray.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[UIImage imageNamed:imgArray[i]] forState:UIControlStateNormal];
        btn.frame = CGRectMake((32+buttonWidth)*i+32, tabViewHeight-buttonHeight, buttonWidth, buttonHeight);
        btn.tag = 100+i;
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.tabBarView addSubview:btn];
    }

}

-(void)btnClicked:(UIButton *)button{
    self.selectedIndex = button.tag-100;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
