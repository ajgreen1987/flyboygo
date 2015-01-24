//
//GMSMessageWindow.m
//The MIT License (MIT)
//Copyright (c) 2013 AJ Green
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of
//this software and associated documentation files (the "Software"), to deal in
//the Software without restriction, including without limitation the rights to
//use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//the Software, and to permit persons to whom the Software is furnished to do so,
//subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


#import "GMSMessageWindow.h"

@interface GMSMessageWindow ()

+ (void)generateAnimatingLabelNodeWithMessage:(NSString *)message font:(NSString *)font fontSize:(CGFloat)fontSize fontColor:(UIColor *)fontColor duration:(CGFloat)duration inWindow:(GMSMessageWindow *)window;
+ (void)generateTapToContinueLabelNodeWithFont:(NSString *)font fontSize:(CGFloat)fontSize fontColor:(UIColor *)fontColor inWindow:(GMSMessageWindow *)window;

@end

@implementation GMSMessageWindow

+ (instancetype) windowWithMessage:(NSString*)message font:(NSString*)font fontSize:(CGFloat)fontSize fontColor:(UIColor*)fontColor duration:(CGFloat)duration size:(CGSize)size backgroundColor:(UIColor*)backgroundColor delegate:(id)delegate
{
    GMSMessageWindow *toReturn = [GMSMessageWindow spriteNodeWithColor:backgroundColor size:size];
    
    [self setupMessageWindow:toReturn delegate:delegate message:message font:font fontSize:fontSize fontColor:fontColor duration:duration];
    
    return toReturn;
}

+ (instancetype) windowWithMessage:(NSString*)message font:(NSString*)font fontSize:(CGFloat)fontSize duration:(CGFloat)duration size:(CGSize)size delegate:(id)delegate
{
    return [GMSMessageWindow windowWithMessage:message font:font fontSize:fontSize fontColor:[UIColor whiteColor] duration:duration size:size backgroundColor:[UIColor blackColor] delegate:delegate];
}

+ (instancetype) windowWithMessage:(NSString*)message font:(NSString*)font fontSize:(CGFloat)fontSize fontColor:(UIColor*)fontColor duration:(CGFloat)duration backgroundImage:(NSString*)backgroundImage delegate:(id)delegate
{
    GMSMessageWindow *toReturn = [GMSMessageWindow spriteNodeWithImageNamed:backgroundImage];
    
    [self setupMessageWindow:toReturn delegate:delegate message:message font:font fontSize:fontSize fontColor:fontColor duration:duration];
    
    return toReturn;
}

#pragma mark -
#pragma mark - Window Setup
+ (void)setupMessageWindow:(GMSMessageWindow *)window delegate:(id)delegate message:(NSString *)message font:(NSString *)font fontSize:(CGFloat)fontSize fontColor:(UIColor *)fontColor duration:(CGFloat)duration
{
    window.userInteractionEnabled = YES;
    window.zPosition = 100.0f;
    window.name = MESSAGE_NAME;
    window.delegate = delegate;
    
    [self generateAnimatingLabelNodeWithMessage:message font:font fontSize:fontSize fontColor:fontColor duration:duration inWindow:window];
    
    [self generateTapToContinueLabelNodeWithFont:font fontSize:fontSize fontColor:fontColor inWindow:window];
}

+ (void)generateAnimatingLabelNodeWithMessage:(NSString *)message font:(NSString *)font fontSize:(CGFloat)fontSize fontColor:(UIColor *)fontColor duration:(CGFloat)duration inWindow:(GMSMessageWindow *)window
{
    __block int counter = 0;
    
    NSInteger numberOfCharacters = message.length;
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:font];
    
    label.fontSize = fontSize;
    label.fontColor = fontColor;
    
    SKAction *drawCharacters = [SKAction customActionWithDuration:duration actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        SKLabelNode *label = (SKLabelNode*)node;
        
        if (counter < numberOfCharacters)
        {
            counter++;
            [label setText:[message substringToIndex:counter]];
        }
    }];
    
    [label runAction:drawCharacters];
    
    [window addChild:label];
}

+ (void)generateTapToContinueLabelNodeWithFont:(NSString *)font fontSize:(CGFloat)fontSize fontColor:(UIColor *)fontColor inWindow:(GMSMessageWindow *)window
{
    SKLabelNode *next = [SKLabelNode labelNodeWithFontNamed:font];
    
    next.text = @"Tap to continue...";
    next.fontSize = fontSize;
    next.fontColor = fontColor;
    next.zPosition = 1;
    next.position = CGPointMake(CGRectGetMaxX(window.frame)-((next.frame.size.width*0.5f)+10), CGRectGetMinY(window.frame)+4.0f);
    
    [window addChild:next];
}

#pragma mark -
#pragma mark - Touches
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self.delegate respondsToSelector:@selector(nextTouched)])
    {
        [self.delegate nextTouched];
    }
}

@end
