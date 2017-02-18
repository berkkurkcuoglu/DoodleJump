//
//  ViewController2.h
//  DoodleJump
//
//  Created by berk on 2/17/17.
//  Copyright © 2017 berk. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "GameView.h"
@interface ViewController2 : UIViewController

@property (strong, nonatomic) IBOutlet GameView *gameView;
@property (strong, nonatomic) IBOutlet UIButton *pauseButton;

@end
