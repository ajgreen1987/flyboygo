//
//  GMSBaseScene.m
//  AirplaneBomb
//
//  Created by AJ Green on 10/5/13.
//  Copyright (c) 2013 Green Mailbox Studios. All rights reserved.
//

#import "GMSBaseScene.h"

@interface GMSBaseScene ()

@property (nonatomic, assign) BOOL hasBeenSetup;

@end

@implementation GMSBaseScene

-(void)update:(CFTimeInterval)currentTime
{
    [super update:currentTime];
    
    if (!_hasBeenSetup)
    {
        _hasBeenSetup = YES;
        [GMSAppManager setupViewForDebugging:self.view];
    }
}

- (SKLabelNode *) menuItemWithText:(NSString*)text size:(CGFloat)size andFont:(NSString*)aFont
{
    SKLabelNode*  toReturn = [SKLabelNode labelNodeWithFontNamed:aFont];
    [toReturn setName:text];
    [toReturn setText:text];
    [toReturn setFontSize:size];
    [toReturn setZPosition:4];
    
    return toReturn;
}

@end
