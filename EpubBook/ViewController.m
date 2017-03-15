//
//  ViewController.m
//  EpubBook
//
//  Created by KingOfSea on 2017/3/15.
//  Copyright © 2017年 KingOfSea. All rights reserved.
//

#import "ViewController.h"
#import "EpubReaderViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 30)];
    btn.center = self.view.center;
    btn.backgroundColor = [UIColor orangeColor];
    [btn addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
}

- (void)click{
    [self.navigationController pushViewController:[EpubReaderViewController new] animated:YES];
}

@end
