//
//  GameView.h
//  DoodleJump
//
//  Created by berk on 2/9/17.
//  Copyright © 2017 berk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Doodle.h"
#import "Brick.h"

@interface GameView : UIView

@property (nonatomic, strong) Doodle *jumper;
@property (nonatomic, strong) NSMutableArray *bricks;
@property (nonatomic) float tilt;
-(void)arrange:(CADisplayLink *)sender;

@end
