//
//  GameScene.h
//  deaf_pong
//
//  Created by Hendrik Heuer on 1/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"
#import "MyContactListener.h"

@interface GameScene : CCLayer {   
    int w,h;
    
    float w2;
    
    CCLabelTTF *labelLives, *labelLevel, *labelPoints;
    int lives, level; 
    float levelChangeCounter;
    
    bool gameRunning, movingLeft, movingRight;
    
    b2World *_world;
    
    b2Body *_groundBody, *_paddleBody, *_ballBody;
    
    b2Fixture *_bottomFixture;
    b2Fixture *_ballFixture;
    
    CCSprite *paddle;
    b2Fixture *_paddleFixture;
    b2PolygonShape paddleShape;
    
    b2Fixture *_ballsLastContactFixture;
    
    b2MouseJoint *_mouseJoint;
    
    b2BodyDef ballBodyDef, paddleBodyDef;
    b2Vec2 forceOnBall;
    
    CCSprite *curtain,*highlightCircleSprite;
    
    NSString *strLabelLives, *strLabelLevel, *strLabelPoints;
    
    MyContactListener *_contactListener;
    
    int soundTimer, soundTimerLimit, points, pointsTimer, pointsTimerLimit;    
}

+ (id) scene;
- (void) teleportBall;
- (int) randomWidth:(int) margin;
- (float) randomFloat;
- (float) randomFloatBetween:(float) smallNumber andBigNumber:(float) bigNumber includingNegative:(bool) withNegative;
- (bool) isNegative;

@end