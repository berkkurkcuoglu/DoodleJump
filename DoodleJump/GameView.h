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
@property (nonatomic) NSInteger highScore;
@property (nonatomic) NSInteger currentScore;
@property (nonatomic) BOOL infinite;
@property (strong, nonatomic) IBOutlet UILabel *scoreLabel;
@property (strong, nonatomic) IBOutlet UILabel *highScoreLabel;
-(void)arrange:(CADisplayLink *)sender;

@end
