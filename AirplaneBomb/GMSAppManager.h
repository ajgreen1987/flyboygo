//
//  GMSAppManager.h
//  AirplaneBomb
//
//  Created by AJ Green on 10/3/13.
//  Copyright (c) 2013 Green Mailbox Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IS_DEBUGGING 1
#define SCALE_IPAD 0.6f
#define SCALE_IPHONE 0.3f
#define ENEMY_FREQUENCY_LOW 1.1
#define ENEMY_FREQUENCY_HIGH 1
#define DIFFICULTY_LOW 7
#define DIFFICULTY_MEDIUM 5
#define DIFFICULTY_HIGH 3
#define GROUND_LEVEL 0
#define PLAYER_LEVEL 1
#define CLOUD_LEVEL 2
#define HUD_LEVEL 3

@interface GMSAppManager : NSObject

+ (void) setupViewForDebugging:(SKView*)aView;
+ (BOOL) isiPad;
+ (int)getRandomNumberBetween:(int)from to:(int)to;
+ (void) loopAndLogFontsAndFamilyNames;
+ (NSString*) gameFont;

@end
