//
//  GameOverScene.h
//  Cocos2DSimpleGame
//
//  Created by Ray Wenderlich on 2/10/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import "cocos2d.h"

@interface GameOverLayer : CCLayer {
    int w,h;
    
	CCLabelTTF *_label;
    
    NSMutableArray *scoresArray;
    
    int _newScore;

}

-(void)update;
-(void)saveToUserDefaults:(NSMutableArray*)myArray;

@property (nonatomic, retain) CCLabelTTF *label;
@property (readwrite, assign) int newScore;

@end

@interface GameOverScene : CCScene {
	GameOverLayer *_layer;
}

@property (nonatomic, retain) GameOverLayer *layer;

@end
