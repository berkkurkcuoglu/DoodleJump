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
        jumper = [[Doodle alloc] initWithFrame:CGRectMake(bounds.size.width/2, bounds.size.height, 20, 20)];
        [jumper setBackgroundColor:[UIColor colorWithRed:153.0/255.0 green:254.0/255.0 blue:0/255.0 alpha:0.6]];
        [jumper setDx:0];
        [jumper setDy:10];
        [self addSubview:jumper];
        [self makeBricks];
        [self protectBricks];
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

//place 5 bricks to bottom at the beginning to avoid instant dead
-(void)protectBricks{
    for (int i = 0; i < 5; ++i)
    {
        CGRect bounds = [self bounds];
        Brick *b = [[Brick alloc] initWithFrame:CGRectMake(0, 0,(int)(bounds.size.width * .25), 20)];
        //[b setBackgroundColor:[UIColor colorWithRed:153.0/255.0 green:254.0/255.0 blue:0/255.0 alpha:1.0]];
        UIGraphicsBeginImageContext(b.frame.size);
        [[UIImage imageNamed:@"doodie.png"] drawInRect:b.frame];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        b.backgroundColor = [UIColor colorWithPatternImage:image];
        [self addSubview:b];
        [b setCenter:CGPointMake((int)(bounds.size.width * .2 * (i+1)), (int)(bounds.size.height * .95))];
        [bricks addObject:b];
    }
}
//create bricks total 12
-(void)makeBricks
{
    if (bricks)
        for (Brick *brick in bricks)
            [brick removeFromSuperview];
    
    bricks = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 7; ++i)
        [self addBrick];
    
}
//method to add a single brick
-(void)addBrick{
    CGRect bounds = [self bounds];
    Brick *b = [[Brick alloc] initWithFrame:CGRectMake(0, 0,(int)(bounds.size.width * .25), 20)];
    UIGraphicsBeginImageContext(b.frame.size);
    [[UIImage imageNamed:@"doodie.png"] drawInRect:b.frame];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    b.backgroundColor = [UIColor colorWithPatternImage:image];
    [self addSubview:b];
    [b setCenter:CGPointMake(rand() % (int)(bounds.size.width * .85), rand() % (int)(bounds.size.height * .65))];
    while([self isOverlapping:b])
        [b setCenter:CGPointMake(rand() % (int)(bounds.size.width * .85), rand() % (int)(bounds.size.height * .65))];
    [bricks addObject:b];
}
//method to move bricks
-(void)moveBricks:(float)jumperY{
    CGRect bounds = [self bounds];
    //bricks array need to be sorted to avoid unit collision (ones closer to bottom moves first)
    bricks = [NSMutableArray arrayWithArray:[self brickSort:bricks]];
    for (int i=0; i < [bricks count]; i++)
    {
        Brick *brick = [bricks objectAtIndex:i];
        CGRect bFrame = [brick frame];
        if((bFrame.origin.y+bFrame.size.height)+jumperY < bounds.size.height ){
                [brick setCenter:CGPointMake([brick center].x, [brick center].y+jumperY)];
        }
        else{
            [brick removeFromSuperview];
            [bricks removeObject:brick];
            [self addBrick];
        }
    }
}
//method to check if a brick is overlapping with another one
-(BOOL)isOverlapping:(Brick*) brick{
    CGRect theFrame = [brick frame];    
    for (int i=0; i < [bricks count]; i++){
        Brick *otherBrick = [bricks objectAtIndex:i];
        CGRect otherFrame = [otherBrick frame];
        if(brick != otherBrick && CGRectIntersectsRect(theFrame, otherFrame))
            return true;
    }
    return false;
}
//bricksort = mergesort according to y coordinate of bricks
-(NSArray *)brickSort:(NSArray *)unsortedArray
{
    if ([unsortedArray count] < 2)
    {
        return unsortedArray;
    }
    long middle = ([unsortedArray count]/2);
    NSRange left = NSMakeRange(0, middle);
    NSRange right = NSMakeRange(middle, ([unsortedArray count] - middle));
    NSArray *rightArr = [unsortedArray subarrayWithRange:right];
    NSArray *leftArr = [unsortedArray subarrayWithRange:left];
    //Or iterate through the unsortedArray and create your left and right array
    //for left array iteration starts at index =0 and stops at middle, for right array iteration starts at midde and end at the end of the unsorted array
    NSArray *resultArray =[self merge:[self brickSort:leftArr] andRight:[self brickSort:rightArr]];
    return resultArray;
}
//merge sort is from http://www.knowstack.com/sorting-algorithms-in-objective-c/
-(NSArray *)merge:(NSArray *)leftArr andRight:(NSArray *)rightArr
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    int right = 0;
    int left = 0;
    while (left < [leftArr count] && right < [rightArr count])
    {
        if ([[leftArr objectAtIndex:left] center].y > [[rightArr objectAtIndex:right] center].y)
        {
            [result addObject:[leftArr objectAtIndex:left++]];
        }
        else
        {
            [result addObject:[rightArr objectAtIndex:right++]];
        }
    }
    NSRange leftRange = NSMakeRange(left, ([leftArr count] - left));
    NSRange rightRange = NSMakeRange(right, ([rightArr count] - right));
    NSArray *newRight = [rightArr subarrayWithRange:rightRange];
    NSArray *newLeft = [leftArr subarrayWithRange:leftRange];
    newLeft = [result arrayByAddingObjectsFromArray:newLeft];
    return [newLeft arrayByAddingObjectsFromArray:newRight];
}

-(void)arrange:(CADisplayLink *)sender
{
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
        p.y += bounds.size.height * 0.8;
    
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
                [jumper setDx:0];
                [jumper setDy:10];
                [self moveBricks:10];
                _currentScore += p.y/5;
                [self updateScore];
            }
        }
    }
    [jumper setCenter:p];
    if(counter % 15 == 0){
       [self moveBricks:10];
    }
    counter++;
}



@end
