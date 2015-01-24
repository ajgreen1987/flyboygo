//
//  GMSBaseScene.h
//  AirplaneBomb
//
//  Created by AJ Green on 10/5/13.
//  Copyright (c) 2013 Green Mailbox Studios. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GMSBaseScene : SKScene
{
    CGRect screenRect;
    CGFloat screenWidth;
    CGFloat screenHeight;
}

- (SKLabelNode *) menuItemWithText:(NSString*)text size:(CGFloat)size andFont:(NSString*)aFont;

@end
