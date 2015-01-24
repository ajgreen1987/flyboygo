//
//  GMSAppManager.m
//  AirplaneBomb
//
//  Created by AJ Green on 10/3/13.
//  Copyright (c) 2013 Green Mailbox Studios. All rights reserved.
//

#import "GMSAppManager.h"

@implementation GMSAppManager

+ (BOOL) isiPad
{
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}

#pragma mark -
#pragma mark - Logic Helpers
+ (void) setupViewForDebugging:(SKView*)aView
{
    aView.showsDrawCount = IS_DEBUGGING;
    aView.showsFPS = IS_DEBUGGING;
    aView.showsNodeCount = IS_DEBUGGING;
}

+ (int)getRandomNumberBetween:(int)from to:(int)to
{
    return (int)from + arc4random() % (to-from+1);
}

+ (void) loopAndLogFontsAndFamilyNames
{
    for (NSString* family in [UIFont familyNames])
    {
        NSLog(@"%@", family);
        
        for (NSString* name in [UIFont fontNamesForFamilyName: family])
        {
            NSLog(@"  %@", name);
        }
    }
}

+ (NSString*) gameFont
{
    return @"HeadlinerNo.45";
}

+ (void) setLeaderboardID:(NSString*)anID
{
    
}

+ (NSString*) leaderboardID
{
    
}


@end
