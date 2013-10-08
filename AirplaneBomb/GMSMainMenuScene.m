//
//  GMSMainMenuScene.m
//  AirplaneBomb
//
//  Created by AJ Green on 10/3/13.
//  Copyright (c) 2013 Green Mailbox Studios. All rights reserved.
//

#import "GMSMainMenuScene.h"
#import "GMSGameScene.h"

@interface GMSMainMenuScene ()

- (void) setupMenu;
- (void) setupScrollingBackground;
- (SKLabelNode *) menuItemWithText:(NSString*)text size:(CGFloat)size andFont:(NSString*)aFont;

@end

@implementation GMSMainMenuScene

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
        
        [self setupMenu];
        [self setupScrollingBackground];
    }
    
    return self;
}

#pragma mark -
#pragma mark - Game Loop
-(void)update:(CFTimeInterval)currentTime
{
    [super update:currentTime];    
    
    //random Clouds
    int goOrNot = [GMSAppManager getRandomNumberBetween:0 to:25];
    
    if (goOrNot == 17)
    {
        int randomClouds = [GMSAppManager getRandomNumberBetween:0 to:100];
        if((randomClouds % 9) == 0)
        {
            int whichCloud = [GMSAppManager getRandomNumberBetween:0 to:3];
            SKSpriteNode *cloud = [SKSpriteNode spriteNodeWithTexture:[_cloudsTextures objectAtIndex:whichCloud]];
            int randomXAxis = [GMSAppManager getRandomNumberBetween:0 to:screenRect.size.width];
            cloud.position = CGPointMake(randomXAxis, screenRect.size.height+cloud.size.height/2);
            cloud.zPosition = 1;
            int randomTimeCloud = [GMSAppManager getRandomNumberBetween:9 to:19];
            SKAction *move =[SKAction moveTo:CGPointMake(randomXAxis, 0-cloud.size.width) duration:randomTimeCloud];
            SKAction *remove = [SKAction removeFromParent];
            [cloud runAction:[SKAction sequence:@[move,remove]]];
            [self addChild:cloud];
        }
    }
}

#pragma mark -
#pragma mark - Menu Setup
- (void) setupMenu
{
    self.menuItems = @[@"New Game",@"Options",@"History of WWII"];
    
    CGFloat startingOffset = 100.0f;
    CGFloat offset = 25.0f;
    int counter = 0;
    
    // Print all font names to find your new one
    //[GMSAppManager loopAndLogFontsAndFamilyNames];
    
    for (NSString *title in self.menuItems)
    {
        SKLabelNode*  menuItem = [self menuItemWithText:self.menuItems[counter] size:25.0f andFont:[GMSAppManager gameFont]];
        [menuItem setPosition:CGPointMake(CGRectGetMidX(self.frame)+5,(CGRectGetMidY(self.frame)-startingOffset)-(counter * offset))];

        [self addChild:menuItem];
        counter += 1;
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

#pragma mark - 
#pragma mark - Touches
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:self.menuItems[0]]) // New Game
    {
        // Scene Transition Animation
        SKTransition* reveal = [SKTransition revealWithDirection:SKTransitionDirectionUp duration:1.5];
        GMSGameScene* gameScene = [GMSGameScene sceneWithSize:self.view.bounds.size];
        [self.scene.view presentScene:gameScene transition:reveal];
    }
    else if([node.name isEqualToString:self.menuItems[1]]) // Options
    {
        // Scene Transition Animation
    }
    else // History
    {
        
    }
}

#pragma mark -
#pragma mark - Awesome Scrolling Background
- (void) setupScrollingBackground
{
    // load clouds
    SKTextureAtlas *cloudsAtlas = [SKTextureAtlas atlasNamed:@"Clouds"];
    NSArray *textureNamesClouds = [cloudsAtlas textureNames];
    _cloudsTextures = [NSMutableArray new];
    
    for (NSString *name in textureNamesClouds)
    {
        SKTexture *texture = [cloudsAtlas textureNamed:name];
        [_cloudsTextures addObject:texture];
    }
}

@end
