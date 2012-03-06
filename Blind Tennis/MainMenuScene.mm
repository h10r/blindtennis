//
//  MainMenuScene.m
//  deaf_pong
//
//  Created by Hendrik Heuer on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainMenuScene.h"
#import "GameScene.h"

@implementation MainMenuScene

+(id) scene
{
    CCScene *scene = [CCScene node];
    
    MainMenuScene *layer = [MainMenuScene node];
    
    [scene addChild: layer];
    
    return scene;
}

-(id) init
{
    
    if( (self=[super init] )) {
        // BACKGROUND
        
        CGSize winSize = [CCDirector sharedDirector].winSize;        
        
        NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
        //NSLog(@"The device's specified language is %@", language);
        
        if ([language isEqualToString:@"de"]) {
            CCSprite *background = [CCSprite spriteWithFile:@"menu-DE.png" 
                                             rect:CGRectMake(0, 0, winSize.width, winSize.height)];
            background.position = ccp(background.contentSize.width/2, background.contentSize.height/2);
            [self addChild:background z:-1000];
        } else {
            CCSprite *background = [CCSprite spriteWithFile:@"menu.png" 
                                                       rect:CGRectMake(0, 0, winSize.width, winSize.height)];
        
            background.position = ccp(background.contentSize.width/2, background.contentSize.height/2);
            [self addChild:background z:-1000];
        }
        
        self.isTouchEnabled = YES;
    }
    return self;
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self startGame]; 
}

- (void) startGame
{
    //[[CCDirector sharedDirector] replaceScene:[GameScene scene]];
    [[CCDirector sharedDirector] replaceScene:
     [CCTransitionSlideInB transitionWithDuration:0.5f scene:[GameScene scene]]];
}

- (void) dealloc
{
    
    [super dealloc];
}
@end