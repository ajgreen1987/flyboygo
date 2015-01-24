//
//  GMSAppManager.h
//  AirplaneBomb
//
//  Created by AJ Green on 10/3/13.
//  Copyright (c) 2013 Green Mailbox Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IS_DEBUGGING 0
#define SCALE_IPAD 0.6f
#define SCALE_IPHONE 0.3f
#define ENEMY_FREQUENCY_LOW 1.1
#define ENEMY_FREQUENCY_HIGH 1
#define DIFFICULTY_LOW 3
#define DIFFICULTY_MEDIUM 2
#define DIFFICULTY_HIGH 1
#define GROUND_LEVEL 0
#define PLAYER_LEVEL 1
#define CLOUD_LEVEL 2
#define HUD_LEVEL 3

#define GENERIC_TITLE @"Flyboy, Go!"
#define WWII_WIKI_URL @"http://en.wikipedia.org/wiki/World_War_II"
#define GMBSTUDIOS_URL @"http://www.greenmailboxstudios.com"

@interface GMSAppManager : NSObject

+ (void) setupViewForDebugging:(SKView*)aView;
+ (BOOL) isiPad;
+ (int)getRandomNumberBetween:(int)from to:(int)to;
+ (void) loopAndLogFontsAndFamilyNames;
+ (NSString*) gameFont;
+ (void) setLeaderboardID:(NSString*)anID;
+ (NSString*) leaderboardID;

@end
