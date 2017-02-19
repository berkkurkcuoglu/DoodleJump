//
//  ViewController1.m
//  DoodleJump
//
//  Created by berk on 2/17/17.
//  Copyright © 2017 berk. All rights reserved.
//

#import "ViewController1.h"

@interface ViewController1 ()

@end

@implementation ViewController1

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"doodie.png"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    _dyingButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    _dyingButton.titleLabel.minimumScaleFactor = 0.4;
    _inifiniteButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    _inifiniteButton.titleLabel.minimumScaleFactor = 0.4;
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
