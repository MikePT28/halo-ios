//
//  ViewController.m
//  HaloObjCDemo
//
//  Created by Borja Santos-Díez on 17/06/15.
//  Copyright (c) 2015 MOBGEN Technology. All rights reserved.
//

#import "HALMainViewController.h"
#import <Halo/Halo-Swift.h>

@interface HALMainViewController ()

@end

@implementation HALMainViewController

@dynamic view;

- (void)loadView {
    [super loadView];
    
    self.view = [HALMainView new];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)submitAction:(id)sender {
    
}

@end
