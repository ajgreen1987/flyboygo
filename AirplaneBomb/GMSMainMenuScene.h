//
//  GMSMainMenuScene.h
//  AirplaneBomb
//
//  Created by AJ Green on 10/3/13.
//  Copyright (c) 2013 Green Mailbox Studios. All rights reserved.
//

#import "GMSBaseScene.h"

@interface GMSMainMenuScene : GMSBaseScene
{
    CGRect screenRect;
    CGFloat screenWidth;
    CGFloat screenHeight;
}

@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) NSMutableArray *cloudsTextures;

@end
