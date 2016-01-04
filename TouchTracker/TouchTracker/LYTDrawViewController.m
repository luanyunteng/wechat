

//
//  LYTDrawViewController.m
//  TouchTracker
//
//  Created by 栾云腾 on 15/12/15.
//  Copyright © 2015年 栾云腾. All rights reserved.
//

#import "LYTDrawViewController.h"
#import "LYTDrawView.h"

@interface LYTDrawViewController ()

@end

@implementation LYTDrawViewController

-(void)loadView{
    self.view = [[LYTDrawView alloc]initWithFrame:CGRectZero];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
