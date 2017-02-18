//
//  ViewController2.m
//  DoodleJump
//
//  Created by berk on 2/17/17.
//  Copyright © 2017 berk. All rights reserved.
//

#import "ViewController2.h"

@interface ViewController2 ()
@property (nonatomic, strong) CADisplayLink *displayLink;
@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _gameView.infinite = true;
    _gameView.currentScore = 0;
    _gameView.highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"doodleInfiniteHighScore"];
    _displayLink = [CADisplayLink displayLinkWithTarget:_gameView selector:@selector(arrange:)];
    [_displayLink setPreferredFramesPerSecond:60];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (IBAction)pause:(id)sender {
    self.displayLink.paused = YES;
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Paused"
                                  message:[NSString stringWithFormat:@""]
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* resume = [UIAlertAction
                             actionWithTitle:@"Resume"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 self.displayLink.paused = NO;
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    [alert addAction:resume];
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backed:(id)sender {
    [self.displayLink invalidate];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (IBAction)speedChange:(id)sender {
    UISlider *s = (UISlider *)sender;
    //NSLog(@"tilt %f", (float)[s value]);
    [_gameView setTilt:(float)([s value]-0.5)*5];
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
