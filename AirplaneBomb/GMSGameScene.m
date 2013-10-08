//
//  GMSMyScene.m
//  AirplaneBomb
//
//  Created by AJ Green on 10/3/13.
//  Copyright (c) 2013 Green Mailbox Studios. All rights reserved.
//

#import "GMSGameScene.h"
#import "GMSMainMenuScene.h"

#define SCALE_IPAD 0.6f
#define SCALE_IPHONE 0.3f
#define END_POINT_IPAD -100.0f
#define END_POINT_IPHONE -300.0f
#define ENEMY_FREQUENCY_LOW 1.1
#define ENEMY_FREQUENCY_HIGH 1
#define DIFFICULTY_LOW 7
#define DIFFICULTY_MEDIUM 5
#define DIFFICULTY_HIGH 3
#define GROUND_LEVEL 0
#define PLAYER_LEVEL 1
#define CLOUD_LEVEL 2
#define HUD_LEVEL 3
#define CLOUD_DENSITY_LOW 10
#define CLOUD_DENSITY_MEDIUM 100
#define CLOUD_DENSITY_HIGH 1000
#define CLOUD_DENSITY_BLINDING 2

@interface GMSGameScene ()

@property (nonatomic, strong) SKAction *spinForever;
@property (nonatomic, assign) NSInteger numberOfLives;

// Player
- (NSInteger) numberOfLivesForDifficulty:(NSInteger)currentDifficulty;

// NPCs
- (void) handleEnemiesAndClouds;
- (void) generateBasicEnemyWithImage:(NSString*)aSpriteImage;

// Scenery
- (void) generateCloud;

// Init
- (void) loadSpriteAtlases;
- (void) generatePause;
- (void) scheduleEnemyCreation;
- (void) startDetectingMotion;

- (void) moveToMainMenu;
-(void)outputAccelertionData:(CMAcceleration)acceleration;
-(int)getRandomNumberBetween:(int)from to:(int)to;

@end

@implementation GMSGameScene

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        // init several sizes used in all scene
        screenRect = [[UIScreen mainScreen] bounds];
        screenHeight = screenRect.size.height;
        screenWidth = screenRect.size.width;
        
        // setup physics, no gravity (whee!) and delegate
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
        
        // adding the background
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"airPlanesBackground"];
        background.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        [self addChild:background];
        
        self.numberOfLives = [self numberOfLivesForDifficulty:DIFFICULTY_LOW];
        
        [self loadSpriteAtlases];
        [self generatePause];
        [self generatePlayer];
        [self scheduleEnemyCreation];
        [self startDetectingMotion];
    }
    
    return self;
}

#pragma mark -
#pragma mark - Initialization Helpers
- (void) loadSpriteAtlases
{
    // load explosions
    SKTextureAtlas *explosionAtlas = [SKTextureAtlas atlasNamed:@"EXPLOSION"];
    NSArray *textureNames = [explosionAtlas textureNames];
    self.explosionTextures = [NSMutableArray new];
    for (NSString *name in textureNames)
    {
        SKTexture *texture = [explosionAtlas textureNamed:name];
        [self.explosionTextures addObject:texture];
    }
    
    // load clouds
    SKTextureAtlas *cloudsAtlas = [SKTextureAtlas atlasNamed:@"Clouds"];
    NSArray *textureNamesClouds = [cloudsAtlas textureNames];
    self.cloudsTextures = [[NSMutableArray alloc] initWithObjects:nil];
    for (NSString *name in textureNamesClouds)
    {
        SKTexture *texture = [cloudsAtlas textureNamed:name];
        [self.cloudsTextures addObject:texture];
    }
}

- (void) generatePause
{
    // pause
    SKSpriteNode *pause = [SKSpriteNode spriteNodeWithImageNamed:@"pause"];
    pause.name = @"pause";
    pause.scale = [GMSAppManager isiPad] ? SCALE_IPAD : SCALE_IPHONE;
    pause.zPosition = HUD_LEVEL;
    pause.position = CGPointMake(screenWidth-(pause.frame.size.width/2.0f), (pause.frame.size.height/2.0f));
    [self addChild:pause];
    
    self.isPaused = NO;
    
}

- (void) scheduleEnemyCreation
{
    //schedule enemies
    SKAction *wait = [SKAction waitForDuration:[GMSAppManager isiPad] ? ENEMY_FREQUENCY_HIGH : ENEMY_FREQUENCY_LOW];
    SKAction *callEnemies = [SKAction runBlock:^{
        [self handleEnemiesAndClouds];
    }];
    SKAction *updateEnemies = [SKAction sequence:@[wait,callEnemies]];
    [self runAction:[SKAction repeatActionForever:updateEnemies]];
}

- (void) startDetectingMotion
{
    //CoreMotion
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = .2;
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                                 [self outputAccelertionData:accelerometerData.acceleration];
                                                 if(error)
                                                 {
                                                     NSLog(@"%@", error);
                                                 }
                                             }];
}

#pragma mark -
#pragma mark - Touches Began
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"pause"]) // New Game
    {
        self.isPaused = !self.isPaused;
        self.view.paused = self.isPaused;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Paused"
                                                        message:@"Would you like to continue your flight?"
                                                       delegate:self
                                              cancelButtonTitle:@"I'm a Hero"
                                              otherButtonTitles:@"I'm a Coward", nil];
        
        [alert show];
    }
    else
    {
        /* Called when a touch begins */
        CGPoint location = [self.plane position];
        SKSpriteNode *bullet = [SKSpriteNode spriteNodeWithImageNamed:@"B 2.png"];
        
        bullet.position = CGPointMake(location.x,location.y+self.plane.size.height/2);
        bullet.zPosition = 1;
        bullet.scale = 0.8;
        bullet.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bullet.size];
        bullet.physicsBody.dynamic = NO;
        bullet.physicsBody.categoryBitMask = bulletCategory;
        bullet.physicsBody.contactTestBitMask = enemyCategory;
        bullet.physicsBody.collisionBitMask = 0;
        
        SKAction *action = [SKAction moveToY:self.frame.size.height+bullet.size.height duration:2];
        SKAction *remove = [SKAction removeFromParent];
        [bullet runAction:[SKAction sequence:@[action,remove]]];
        [self addChild:bullet];
    }
    
}

#pragma mark -
#pragma mark - Game Loop
-(void)update:(CFTimeInterval)currentTime
{
    [super update:currentTime];
    
    if (!self.isPaused)
    {
        if (self.spinForever == nil)
        {
            SKTexture *propeller1 = [SKTexture textureWithImageNamed:@"PLANE PROPELLER 1.png"];
            SKTexture *propeller2 = [SKTexture textureWithImageNamed:@"PLANE PROPELLER 2.png"];
            SKAction *spin = [SKAction animateWithTextures:@[propeller1,propeller2] timePerFrame:0.1];
            self.spinForever = [SKAction repeatActionForever:spin];
            [self.planePropeller runAction:self.spinForever];
            
            NSString *smokePath = [[NSBundle mainBundle] pathForResource:@"trail" ofType:@"sks"];
            self.smokeTrail = [NSKeyedUnarchiver unarchiveObjectWithFile:smokePath];
            self.smokeTrail.position = CGPointMake(screenWidth/2, 15);
            [self addChild:self.smokeTrail];
        }
        
        float maxY = screenWidth - self.plane.size.width/2;
        float minY = self.plane.size.width/2;
        float maxX = screenHeight - self.plane.size.height/2;
        float minX = self.plane.size.height/2;
        float newY = 0;
        float newX = 0;
        
        if(currentMaxAccelX > 0.05)
        {
            newX = currentMaxAccelX * 10;
            self.plane.texture = [SKTexture textureWithImageNamed:@"PLANE 8 R.png"];
        }
        else if(currentMaxAccelX < -0.05)
        {
            newX = currentMaxAccelX*10;
            self.plane.texture = [SKTexture textureWithImageNamed:@"PLANE 8 L.png"];
        }
        else
        {
            newX = currentMaxAccelX*10;
            self.plane.texture = [SKTexture textureWithImageNamed:@"PLANE 8 N.png"];
        }
        
        newY = 6.0 + currentMaxAccelY *10;
        float newXshadow = newX+self.planeShadow.position.x;
        float newYshadow = newY+self.planeShadow.position.y;
        newXshadow = MIN(MAX(newXshadow,minY+15),maxY+15);
        newYshadow = MIN(MAX(newYshadow,minX-15),maxX-15);
        float newXpropeller = newX+self.planePropeller.position.x;
        float newYpropeller = newY+self.planePropeller.position.y;
        newXpropeller = MIN(MAX(newXpropeller,minY),maxY);
        newYpropeller = MIN(MAX(newYpropeller,minX+(self.plane.size.height/2)-5),maxX+(self.plane.size.height/2)-5);
        newX = MIN(MAX(newX+self.plane.position.x,minY),maxY);
        newY = MIN(MAX(newY+self.plane.position.y,minX),maxX);
        self.plane.position = CGPointMake(newX, newY);
        self.planeShadow.position = CGPointMake(newXshadow, newYshadow);
        self.planePropeller.position = CGPointMake(newXpropeller, newYpropeller);
        self.smokeTrail.position = CGPointMake(newX,newY-(self.plane.size.height/2));
        
        //random Clouds
        int goOrNot = [GMSAppManager getRandomNumberBetween:0 to:25];
        
        if (goOrNot == 17)
        {
            int randomClouds = [GMSAppManager getRandomNumberBetween:0 to:CLOUD_DENSITY_LOW];
            if((randomClouds % 2) == 0)
            {
                [self generateCloud];
            }
        }
    }
    else
    {
        self.spinForever = nil;
        [self.smokeTrail runAction:[SKAction removeFromParent]];
        [self.planePropeller removeAllActions];
    }
}

#pragma mark -
#pragma mark - Acceleration
-(void)outputAccelertionData:(CMAcceleration)acceleration
{
    currentMaxAccelX = 0;
    currentMaxAccelY = 0;
    
    if(fabs(acceleration.x) > fabs(currentMaxAccelX))
    {
        currentMaxAccelX = acceleration.x;
    }
    
    if(fabs(acceleration.y) > fabs(currentMaxAccelY))
    {
        currentMaxAccelY = acceleration.y;
    }
}

#pragma mark -
#pragma mark - Collision Detection
-(void)didBeginContact:(SKPhysicsContact*)contact
{
    SKPhysicsBody *firstBody;
    SKPhysicsBody *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if (firstBody.categoryBitMask == bulletCategory)
    {
        if (secondBody.categoryBitMask == enemyCategory)
        {
            // remove bullet
            SKNode *projectile = (contact.bodyA.categoryBitMask & bulletCategory) ? contact.bodyA.node : contact.bodyB.node;
            SKNode *enemy = (contact.bodyA.categoryBitMask & bulletCategory) ? contact.bodyB.node : contact.bodyA.node;
            [projectile runAction:[SKAction removeFromParent]];
            [enemy runAction:[SKAction removeFromParent]];
            
            // add explosion
            SKSpriteNode *explosion = [SKSpriteNode spriteNodeWithTexture:[self.explosionTextures objectAtIndex:0]];
            explosion.zPosition = PLAYER_LEVEL;
            explosion.scale = 0.6;
            explosion.position = contact.bodyA.node.position;
            [self addChild:explosion];
            SKAction *explosionAction = [SKAction animateWithTextures:self.explosionTextures timePerFrame:0.07];
            SKAction *remove = [SKAction removeFromParent];
            [explosion runAction:[SKAction sequence:@[explosionAction,remove]]];
        }
    }
    
    if ((firstBody.categoryBitMask == playerCategory) || (firstBody.categoryBitMask == enemyCategory))
    {
        if ((secondBody.categoryBitMask == enemyCategory) || (secondBody.categoryBitMask == playerCategory))
        {
            // remove player
            SKAction *playerDied = [SKAction removeFromParent];
            [self.plane runAction:playerDied];
            [self.planePropeller runAction:playerDied];
            [self.planeShadow runAction:playerDied];
            [self.smokeTrail runAction:playerDied];
            
            SKNode *enemy = (firstBody.categoryBitMask & playerCategory) ? firstBody.node : secondBody.node;
            [enemy runAction:playerDied];
            
            //add explosion
            SKSpriteNode *explosion = [SKSpriteNode spriteNodeWithTexture:[self.explosionTextures objectAtIndex:0]];
            explosion.zPosition = PLAYER_LEVEL;
            explosion.scale = 0.6;
            explosion.position = contact.bodyA.node.position;
            [self addChild:explosion];
            SKAction *explosionAction = [SKAction animateWithTextures:self.explosionTextures timePerFrame:0.07];
            SKAction *remove = [SKAction removeFromParent];
            [explosion runAction:[SKAction sequence:@[explosionAction,remove]]];
            
            if (self.numberOfLives >= [self numberOfLivesForDifficulty:DIFFICULTY_LOW])
            {
                self.numberOfLives -= 1;
                
                [NSTimer scheduledTimerWithTimeInterval:0.5f
                                        target:self
                                      selector:@selector(generatePlayer)
                                      userInfo:nil
                                       repeats:NO];
            }
            else
            {
                // Game Over
                [self moveToMainMenu];
            }
        }
    }
}

#pragma mark -
#pragma mark - Player
- (void) generatePlayer
{
    // adding the airplane
    self.plane = [SKSpriteNode spriteNodeWithImageNamed:@"PLANE 8 N.png"];
    self.plane.scale = [GMSAppManager isiPad] ? SCALE_IPAD : SCALE_IPHONE;
    self.plane.zPosition = PLAYER_LEVEL;
    self.plane.position = CGPointMake(screenWidth/2, 15+self.plane.size.height/2);
    self.plane.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.plane.size];
    self.plane.physicsBody.dynamic = YES;
    self.plane.physicsBody.categoryBitMask = playerCategory;
    self.plane.physicsBody.contactTestBitMask = enemyCategory;
    self.plane.physicsBody.collisionBitMask = 0;
    [self addChild:self.plane];
    
    // adding the airplane's shadow
    self.planeShadow = [SKSpriteNode spriteNodeWithImageNamed:@"PLANE 8 SHADOW.png"];
    self.planeShadow.scale = [GMSAppManager isiPad] ? SCALE_IPAD : SCALE_IPHONE;
    self.planeShadow.zPosition = GROUND_LEVEL;
    self.planeShadow.position = CGPointMake(screenWidth/2+15, 0+self.planeShadow.size.height/2);
    [self addChild:self.planeShadow];
    
    // adding the airplane's propeller
    self.planePropeller = [SKSpriteNode spriteNodeWithImageNamed:@"PLANE PROPELLER 1.png"];
    self.planePropeller.scale = SCALE_IPHONE;
    self.planePropeller.position = CGPointMake(screenWidth/2, self.plane.size.height+10);
    [self addChild:self.planePropeller];
}

- (NSInteger) numberOfLivesForDifficulty:(NSInteger)currentDifficulty
{
    switch (currentDifficulty)
    {
        case DIFFICULTY_LOW:
            return 6;
        case DIFFICULTY_MEDIUM:
            return 3;
        default:
            return 1;
    }
}

#pragma mark -
#pragma mark - Scenery
- (void) generateCloud
{
    int whichCloud = [self getRandomNumberBetween:0 to:3];
    int abovePlayer = [self getRandomNumberBetween:0 to:10];
    SKSpriteNode *cloud = [SKSpriteNode spriteNodeWithTexture:[self.cloudsTextures objectAtIndex:whichCloud]];
    int randomXAxis = [self getRandomNumberBetween:0 to:screenRect.size.width];
    cloud.position = CGPointMake(randomXAxis, screenRect.size.height+cloud.size.height/2);
    cloud.zPosition = ((abovePlayer % 3)==0) ? CLOUD_LEVEL : GROUND_LEVEL;
    int randomTimeCloud = [self getRandomNumberBetween:9 to:19];
    SKAction *move =[SKAction moveTo:CGPointMake(randomXAxis, 0-cloud.size.width) duration:randomTimeCloud];
    SKAction *remove = [SKAction removeFromParent];
    [cloud runAction:[SKAction sequence:@[move,remove]]];
    [self addChild:cloud];
}

#pragma mark -
#pragma mark - NPCs
- (void) generateBasicEnemyWithImage:(NSString*)aSpriteImage
{
    SKSpriteNode *enemy = [SKSpriteNode spriteNodeWithImageNamed:aSpriteImage];
    
    enemy.scale = [GMSAppManager isiPad] ? SCALE_IPAD : SCALE_IPHONE;
    enemy.position = CGPointMake(0.0f, screenRect.size.height/2);
    enemy.zPosition = PLAYER_LEVEL;
    enemy.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:enemy.size];
    enemy.physicsBody.dynamic = YES;
    enemy.physicsBody.categoryBitMask = enemyCategory;
    enemy.physicsBody.contactTestBitMask = bulletCategory;
    enemy.physicsBody.collisionBitMask = 0;
    CGMutablePathRef cgpath = CGPathCreateMutable();
    
    //random values
    float xStart = [self getRandomNumberBetween:0+enemy.size.width to:screenRect.size.width-enemy.size.width ];
    float xEnd = [self getRandomNumberBetween:0+enemy.size.width to:screenRect.size.width-enemy.size.width ];
    
    //ControlPoint1
    float cp1X = [self getRandomNumberBetween:0+enemy.size.width to:screenRect.size.width-enemy.size.width ];
    float cp1Y = [self getRandomNumberBetween:0+enemy.size.width to:screenRect.size.width-enemy.size.height ];
    
    //ControlPoint2
    float cp2X = [self getRandomNumberBetween:0+enemy.size.width to:screenRect.size.width-enemy.size.width ];
    float cp2Y = [self getRandomNumberBetween:0 to:cp1Y];
    
    CGPoint s = CGPointMake(xStart, [GMSAppManager isiPad] ? 1024.0f : screenRect.size.width);
    CGPoint e = CGPointMake(xEnd, [GMSAppManager isiPad] ? END_POINT_IPAD : END_POINT_IPHONE);
    CGPoint cp1 = CGPointMake(cp1X, cp1Y);
    CGPoint cp2 = CGPointMake(cp2X, cp2Y);
    CGPathMoveToPoint(cgpath,NULL, s.x, s.y);
    CGPathAddCurveToPoint(cgpath, NULL, cp1.x, cp1.y, cp2.x, cp2.y, e.x, e.y);
    SKAction *planeDestroy = [SKAction followPath:cgpath duration:DIFFICULTY_LOW];
    [self addChild:enemy];
    SKAction *remove = [SKAction removeFromParent];
    [enemy runAction:[SKAction sequence:@[planeDestroy,remove]]];
    CGPathRelease(cgpath);
}

-(void) handleEnemiesAndClouds
{
    if (!self.isPaused)
    {
        ([self getRandomNumberBetween:0 to:1] == 1) ? [self generateBasicEnemyWithImage:([self getRandomNumberBetween:0 to:1] == 0) ? @"PLANE 1 N.png" : @"PLANE 2 N.png"] : nil;
    }
}

#pragma mark -
#pragma mark - Alert View Delegate
- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    self.isPaused = !self.isPaused;
    self.view.paused = self.isPaused;
    
    if (buttonIndex == 1)
    {
        [self moveToMainMenu];
    }
}

#pragma mark -
#pragma mark - Helpers
// Originally had this defined within this class
// Pulled it into AppManager to share amongst classes
// I'm to lazy to refactor the class from self to GMSAppManager
-(int)getRandomNumberBetween:(int)from to:(int)to
{
    return [GMSAppManager getRandomNumberBetween:from to:to];
}

- (void) moveToMainMenu
{
    // restart the game
    SKTransition* reveal = [SKTransition revealWithDirection:SKTransitionDirectionDown duration:1.5];
    GMSMainMenuScene *mainMenuScene = [GMSMainMenuScene sceneWithSize:self.view.bounds.size];
    [self.scene.view presentScene:mainMenuScene transition:reveal];
}

@end
