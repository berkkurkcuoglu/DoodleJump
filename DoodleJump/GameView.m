//
//  GameView.m
//  DoodleJump
//
//  Created by berk on 2/9/17.
//  Copyright © 2017 berk. All rights reserved.
//
#import <AudioToolbox/AudioServices.h>
#import "GameView.h"


NSInteger counter;


@implementation GameView

@synthesize jumper, bricks;
@synthesize tilt;


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    counter = 0;
    _scoreLabel.adjustsFontSizeToFitWidth = YES;
    _scoreLabel.minimumScaleFactor = 0.4;
    _highScoreLabel.adjustsFontSizeToFitWidth = YES;
    _highScoreLabel.minimumScaleFactor = 0.4;
    [_highScoreLabel setText:[NSString stringWithFormat:@"Best: %ld",_highScore]];
    [self updateScore];
    if (self)
    {
        CGRect bounds = [self bounds];
        
        jumper = [[Doodle alloc] initWithFrame:CGRectMake(bounds.size.width/2, bounds.size.height/2, 20, 20)];
        [jumper setBackgroundColor:[UIColor colorWithRed:153.0/255.0 green:254.0/255.0 blue:0/255.0 alpha:0.6]];
        [jumper setDx:0];
        [jumper setDy:10];
        [self addSubview:jumper];
        [self makeBricks:nil];
    }
    return self;
}

-(void)updateScore{
    if(_currentScore > _highScore){
        _highScore = _currentScore;
        if(_infinite)
            [[NSUserDefaults standardUserDefaults] setInteger:_highScore forKey:@"doodleInfiniteHighScore"];
        else
            [[NSUserDefaults standardUserDefaults] setInteger:_highScore forKey:@"doodleHighScore"];
    }
    [_scoreLabel setText:[NSString stringWithFormat:@"Score: %ld",_currentScore]];
    [_highScoreLabel setText:[NSString stringWithFormat:@"Best: %ld",_highScore]];
}
-(IBAction)makeBricks:(id)sender
{
    //CGRect bounds = [self bounds];
    //float width = bounds.size.width * .2;
    //float height = 20;
    if (bricks)
    {
        for (Brick *brick in bricks)
        {
            [brick removeFromSuperview];
        }
    }
    
    bricks = [[NSMutableArray alloc] init];
    for (int i = 0; i < 12; ++i)
    {
        [self addBrick];
    }
}

-(void)addBrick{
    CGRect bounds = [self bounds];
    Brick *b = [[Brick alloc] initWithFrame:CGRectMake(0, 0,(int)(bounds.size.width * .2), 20)];
    //[b setBackgroundColor:[UIColor colorWithRed:153.0/255.0 green:254.0/255.0 blue:0/255.0 alpha:1.0]];
    UIGraphicsBeginImageContext(b.frame.size);
    [[UIImage imageNamed:@"doodie.png"] drawInRect:b.frame];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    b.backgroundColor = [UIColor colorWithPatternImage:image];
    [self addSubview:b];
    [b setCenter:CGPointMake(rand() % (int)(bounds.size.width * .8), rand() % (int)(bounds.size.height * .8))];
    while([self isOverlapping:b])
        [b setCenter:CGPointMake(rand() % (int)(bounds.size.width * .8), rand() % (int)(bounds.size.height * .8))];
    [bricks addObject:b];
}

-(void)moveBricks:(float)jumperY{
    CGRect bounds = [self bounds];
    for (int i=0; i < [bricks count]; i++)
    {
        Brick *brick = [bricks objectAtIndex:i];
        CGRect bFrame = [brick frame];
        CGRect movedFrame = CGRectMake([brick center].x,[brick center].y+jumperY , bFrame.size.width,bFrame.size.height);
        if((bFrame.origin.y+bFrame.size.height)+jumperY < bounds.size.height ){
            if(![self isMoveOverlapping:movedFrame:brick])
                [brick setCenter:CGPointMake([brick center].x, [brick center].y+jumperY)];
        }
        else{
            [brick removeFromSuperview];
            [bricks removeObject:brick];
            [self addBrick];
        }

    }
}

-(BOOL)isOverlapping:(Brick*) brick{
    CGRect theFrame = [brick frame];
    //CGRect movedFrame = CGRectMake([brick center].x,[brick center].y, theFrame.size.width,theFrame.size.height);
    for (int i=0; i < [bricks count]; i++){
        Brick *otherBrick = [bricks objectAtIndex:i];
        CGRect otherFrame = [otherBrick frame];
        if(brick != otherBrick && CGRectIntersectsRect(theFrame, otherFrame))
            return true;
    }
    return false;
}

-(BOOL)isMoveOverlapping:(CGRect) bFrame :(Brick*) brick{
    //CGRect theFrame = [brick frame];
    //CGRect movedFrame = CGRectMake([brick center].x,[brick center].y, theFrame.size.width,theFrame.size.height);
    for (int i=0; i < [bricks count]; i++){
        Brick *otherBrick = [bricks objectAtIndex:i];
        CGRect otherFrame = [otherBrick frame];
        if(brick != otherBrick && CGRectIntersectsRect(bFrame, otherFrame))
            return true;
    }
    return false;
}


-(void)arrange:(CADisplayLink *)sender
{
    //CFTimeInterval ts = [sender timestamp];
    
    CGRect bounds = [self bounds];
    
    // Apply gravity to the acceleration of the jumper
    [jumper setDy:[jumper dy] - .3];
    
    // Apply the tilt.  Limit maximum tilt to + or - 5
    [jumper setDx:[jumper dx] + tilt];
    if ([jumper dx] > 5)
        [jumper setDx:5];
    if ([jumper dx] < -5)
        [jumper setDx:-5];
    
    // Jumper moves in the direction of gravity
    CGPoint p = [jumper center];
    p.x += [jumper dx];
    p.y -= [jumper dy];
    
    // If the jumper has fallen below the bottom of the screen,
    // add a positive velocity to move him
    if (p.y > bounds.size.height)
    {
        if(_infinite){
            [jumper setDy:10];
            p.y = bounds.size.height;
        }
        else{
            //NSLog(@"GG");
            NSString *path  = [[NSBundle mainBundle] pathForResource:@"blip" ofType:@"wav"];
            NSURL *pathURL = [NSURL fileURLWithPath : path];
            SystemSoundID audioEffect;
            AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &audioEffect);
            AudioServicesPlaySystemSound(audioEffect);
            [sender invalidate];
        }
    }
    
    // If we've gone past the top of the screen, wrap around
    if (p.y < 0)
        p.y += bounds.size.height;
    
    // If we have gone too far left, or too far right, wrap around
    if (p.x < 0)
        p.x += bounds.size.width;
    if (p.x > bounds.size.width)
        p.x -= bounds.size.width;
    
    // If we are moving down, and we touch a brick, we get
    // a jump to push us up.
    if ([jumper dy] < 0)
    {
        for (int i=0; i < [bricks count]; i++)
        {
            CGRect b = [[bricks objectAtIndex:i] frame];
            if (CGRectContainsPoint(b, p))
            {
                // Yay!  Bounce!
                //NSLog(@"Bounce!");
                [jumper setDy:10];
                [self moveBricks:p.y];
                _currentScore += p.y/5;
                [self updateScore];
            }
        }
    }
    [jumper setCenter:p];
    if(counter % 15 == 0){
       [self moveBricks:8];
    }
    // NSLog(@"Timestamp %f", ts);
    counter++;
}



@end
