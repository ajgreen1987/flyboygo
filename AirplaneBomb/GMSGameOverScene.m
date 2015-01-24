//
//  GMSGameOverScene.m
//  AirplaneBomb
//
//  Created by AJ Green on 5/9/14.
//  Copyright (c) 2014 Green Mailbox Studios. All rights reserved.
//

#import "GMSGameOverScene.h"

@implementation GMSGameOverScene

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        // init several sizes used in all scene
        screenRect = [[UIScreen mainScreen] bounds];
        screenHeight = screenRect.size.height;
        screenWidth = screenRect.size.width;
        
        // adding the background
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"airPlanesBackground"];
        background.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        [self addChild:background];
        
        [self addChild:[self menuItemWithText:@"Game Over"
                                         size:48.0f
                                      andFont:[GMSAppManager gameFont]]];
    }
    
    return self;
}

#pragma mark -
#pragma mark - Game Over


@end
