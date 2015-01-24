//
//  GMSMyScene.h
//  AirplaneBomb
//

//  Copyright (c) 2013 Green Mailbox Studios. All rights reserved.
//

#import "GMSBaseScene.h"
#import "GMSMessageWindow.h"
#import <CoreMotion/CoreMotion.h>


static const uint8_t bulletCategory = 1;
static const uint8_t enemyCategory = 2;
static const uint8_t playerCategory = 3;

@interface GMSGameScene : GMSBaseScene <UIAccelerometerDelegate, SKPhysicsContactDelegate, UIAlertViewDelegate, GMSMessageWindowDelegate>
{
    double currentMaxAccelX;
    double currentMaxAccelY;
}

@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) SKSpriteNode *plane;
@property (nonatomic, strong) SKSpriteNode *planeShadow;
@property (nonatomic, strong) SKSpriteNode *planePropeller;
@property (nonatomic, strong) SKEmitterNode *smokeTrail;
@property (nonatomic, strong) NSMutableArray *explosionTextures;
@property (nonatomic, strong) NSMutableArray *cloudsTextures;
@property (nonatomic, assign) BOOL isPaused;
@property (nonatomic, assign) BOOL isGameOver;

@end
