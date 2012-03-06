//
//  GameScene.m
//  deaf_pong
//
//  Created by Hendrik Heuer on 1/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameScene.h"
#import "Helpers.h"
#import "SimpleAudioEngine.h"
#import "GameOverScene.h"

#define PTM_RATIO 32

@implementation GameScene

+ (id)scene {
    CCScene *scene = [CCScene node];
    GameScene *layer = [GameScene node];
    [scene addChild:layer];
    return scene;
    
}

- (id)init {
    
    if ((self=[super init])) {
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        h = winSize.height;
        w = winSize.width;
        
        lives = 3;
        level = 0;
        levelChangeCounter = 0.0f;
        
        self.isTouchEnabled = YES;
        
        // LANGUAGE
        
        NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
        //NSLog(@"The device's specified language is %@", language);
        
        if ([language isEqualToString:@"de"]) {
            strLabelLives = @"Leben ";
            strLabelLevel = @"Level ";
            strLabelPoints = @"Punkte ";
        } else {
            strLabelLives = @"Lives ";
            strLabelLevel = @"Level ";
            strLabelPoints = @"Points ";
        }
        
        // BACKGROUND
        CCSprite *background = [CCSprite spriteWithFile:@"bg.png" 
                                                   rect:CGRectMake(0, 0, w, h)];
        background.position = ccp(background.contentSize.width/2, background.contentSize.height/2);
        [self addChild:background z:-1000];
        
        // Create paddle and add it to the layer
        curtain = [CCSprite spriteWithFile:@"curtain.png"];
        curtain.position = ccp(curtain.contentSize.width/2, curtain.contentSize.height/2 + h - 225.0f );
        curtain.tag = 0;
        [self addChild:curtain z:-1];
        
        highlightCircleSprite = [CCSprite spriteWithFile:@"circle.png" rect:CGRectMake(0, 0, 33.0f, 33.0f) ];
        highlightCircleSprite.visible = false;
        [self addChild:highlightCircleSprite z:-1];
         
        // Cache sounds
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"ball.aiff"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"paddle.aiff"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"wall.aiff"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"ball_out.aiff"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"game_over.aiff"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"game_starts.aiff"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"level_up.aiff"];
        
        [[SimpleAudioEngine sharedEngine] playEffect:@"game_starts.aiff" pitch:1.0f pan:0.0 gain:1.0f];
        
        //CCLabelTTF for true-type fonts
        labelLives = [CCLabelTTF labelWithString:@"" fontName:@"HelveticaNeue-CondensedBlack" fontSize:18];
        [labelLives setPosition:ccp( 40.0f, h - 25.0f) ];
        [labelLives setColor:ccc3(255,255,255)];
        [self addChild:labelLives z:100];
        
        labelLevel = [CCLabelTTF labelWithString:@"" fontName:@"HelveticaNeue-CondensedBlack" fontSize:18];
        [labelLevel setPosition:ccp( w / 2.0, h - 25.0f) ];
        [labelLevel setColor:ccc3(255,255,255)];
        [self addChild:labelLevel z:100];
        
        labelPoints = [CCLabelTTF labelWithString:@"" fontName:@"HelveticaNeue-CondensedBlack" fontSize:18];
        [labelPoints setPosition:ccp( w - 50.f, h - 25.0f) ];
        [labelPoints setColor:ccc3(255,255,255)];
        [self addChild:labelPoints z:100];
        
        [labelLives setString:[NSString stringWithFormat:@"%@%i", strLabelLives, lives ]];
        [labelLevel setString:[NSString stringWithFormat:@"%@%i", strLabelLevel, level ]];
        [labelPoints setString:[NSString stringWithFormat:@"%@%i", strLabelPoints, points ]];
        
        // Create a world
        b2Vec2 gravity = b2Vec2(0.0f, 0.0f);
        bool doSleep = true;
        _world = new b2World(gravity, doSleep);
        
        // Create edges around the entire screen
        b2BodyDef groundBodyDef;
        groundBodyDef.position.Set(0,0);
        _groundBody = _world->CreateBody(&groundBodyDef);
        b2PolygonShape groundBox;
        b2FixtureDef groundBoxDef;
        groundBoxDef.shape = &groundBox;
        groundBoxDef.friction = 0.0f; // to avoid getting stuck HH
        groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(winSize.width/PTM_RATIO, 0));
        _bottomFixture = _groundBody->CreateFixture(&groundBoxDef);
        groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(0, winSize.height/PTM_RATIO));
        _groundBody->CreateFixture(&groundBoxDef);
        groundBox.SetAsEdge(b2Vec2(0, winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO, 
                                                                        winSize.height/PTM_RATIO));
        _groundBody->CreateFixture(&groundBoxDef);
        groundBox.SetAsEdge(b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO), 
                            b2Vec2(winSize.width/PTM_RATIO, 0));
        _groundBody->CreateFixture(&groundBoxDef);
        
        // Create sprite and add it to the layer
        CCSprite *ball = [CCSprite spriteWithFile:@"ball.png" 
                                             rect:CGRectMake(0, 0, 17, 17)];
        ball.position = ccp(100, 100);
        ball.tag = 1;
        [self addChild:ball z:-10];
        
        // Create ball body 
        ballBodyDef.type = b2_dynamicBody;
        ballBodyDef.position.Set([self randomWidth:50] / PTM_RATIO, (h - 25.0f) / PTM_RATIO );
        ballBodyDef.userData = ball;
        
        _ballBody = _world->CreateBody(&ballBodyDef);
        
        // Create circle shape
        b2CircleShape circle;
        circle.m_radius = 7.5f/PTM_RATIO;
        
        // Create shape definition and add to body
        b2FixtureDef ballShapeDef;
        ballShapeDef.shape = &circle;
        ballShapeDef.density = 1.0f;
        ballShapeDef.friction = 0.0f;
        ballShapeDef.restitution = 1.0f;
        _ballFixture = _ballBody->CreateFixture(&ballShapeDef);
        
        _ballsLastContactFixture = _ballBody->CreateFixture(&ballShapeDef);
        
        [self teleportBall];
        /*
        forceOnBall = b2Vec2(0, 0);
        _ballBody->ApplyLinearImpulse(forceOnBall, ballBodyDef.position);
        */
         
        // Create paddle and add it to the layer
        CCSprite *paddle = [CCSprite spriteWithFile:@"paddle.png"];
        paddle.position = ccp(winSize.width/2, 50);
        paddle.tag = 2;
        [self addChild:paddle z:-5];
        
        // Create paddle body
        b2BodyDef paddleBodyDef;
        paddleBodyDef.type = b2_dynamicBody;
        paddleBodyDef.position.Set(winSize.width/2/PTM_RATIO, 50/PTM_RATIO);
        paddleBodyDef.userData = paddle;
        _paddleBody = _world->CreateBody(&paddleBodyDef);
        
        // Create paddle shape
        b2PolygonShape paddleShape;
        paddleShape.SetAsBox(paddle.contentSize.width/PTM_RATIO/2, 
                             paddle.contentSize.height/PTM_RATIO/2);
        
        // Create shape definition and add to body
        b2FixtureDef paddleShapeDef;
        paddleShapeDef.shape = &paddleShape;
        paddleShapeDef.density = 10.0f;
        paddleShapeDef.friction = 0.4f;
        paddleShapeDef.restitution = 0.0f;
        _paddleFixture = _paddleBody->CreateFixture(&paddleShapeDef);
        
        b2PrismaticJointDef jointDef;
        b2Vec2 worldAxis(1.0f, 0.0f);
        jointDef.collideConnected = true;
        jointDef.Initialize(_paddleBody, _groundBody, 
                            _paddleBody->GetWorldCenter(), worldAxis);
        _world->CreateJoint(&jointDef);
        
        // Create contact listener
        _contactListener = new MyContactListener();
        _world->SetContactListener(_contactListener);
        
        [self schedule:@selector(tick:)];
        
        soundTimer = 0; 
        soundTimerLimit = 30;
        
        pointsTimer = 0;
        pointsTimerLimit = 150;
        
        points = 0;
        
        gameRunning = true;
    }
    return self;
}

- (int) randomWidth:(int) margin {
    return (int)( margin + abs( arc4random() % (w - margin) ) );
}

- (float) randomFloat {   
    return (rand() / RAND_MAX) * 1;
}

- (float)randomFloatBetween:(float)smallNumber andBigNumber:(float)bigNumber includingNegative:(bool) withNegative {
    float diff = bigNumber - smallNumber;
    if (withNegative and [self isNegative]) {
        return -(((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
    } else {
        return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
    }
}

- (bool) isNegative {
    return rand() <  0.5f * RAND_MAX;
}

- (void) teleportBall {
    _ballBody->SetLinearDamping(0.0f);
    _ballBody->SetAngularDamping(0.0f);
    _ballBody->SetAngularVelocity(0.0f);
    _ballBody->SetLinearVelocity(b2Vec2(0.0f,0.0f));

    _ballBody->SetTransform( b2Vec2( [self randomWidth:50] / PTM_RATIO, (h - 25.0f) / PTM_RATIO  ), _ballBody->GetAngle() );
        
    forceOnBall.Set( 3.0f*[self randomFloatBetween:0.4f andBigNumber:1.0f includingNegative:true], 2.0f*[self randomFloatBetween:0.5f andBigNumber:1.0f  includingNegative:false] );
    _ballBody->ApplyLinearImpulse(forceOnBall, ballBodyDef.position);     
}

- (void)tick:(ccTime) dt {
    
    CGPoint ballPoint,paddlePoint;
    
    _world->Step(dt, 1, 1);    
    for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {    
        if (b->GetUserData() != NULL) {
            CCSprite *sprite = (CCSprite *)b->GetUserData();                        
            sprite.position = ccp(b->GetPosition().x * PTM_RATIO,
                                  b->GetPosition().y * PTM_RATIO);
            sprite.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
            
            if (sprite.tag == 1) {
                int maxSpeed = 9;
                
                ballPoint = sprite.position;
                
                b2Vec2 velocity = b->GetLinearVelocity();
                float32 speed = velocity.Length();

                //CCLOG(@"%f", speed);
                
                if (speed > maxSpeed) {
                    b->SetLinearDamping(0.8);
                } else if (speed < maxSpeed) {
                    b->SetLinearDamping(0.0);
                }
                
            }
            
            if (sprite.tag == 2) {
                paddlePoint = sprite.position;
            }
        }
    }
    
    pointsTimer += 1;
    if (pointsTimer >= pointsTimerLimit) {

        int prevLevel = level;
        
        levelChangeCounter += 0.008;
        level = (int) ( 10 * ( ( pow(levelChangeCounter-1.0f, 3.0f) + 1 ) ) );
        [labelLevel setString:[NSString stringWithFormat:@"%@%i", strLabelLevel, level ]];
        
        //CCLOG(@"%f", levelChangeCounter);
        //CCLOG(@"%i", level);
        
        if ( prevLevel < level ) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"level_up.aiff" pitch:1.0f pan:0.0 gain:1.0f];
            
            id actionMove = [CCMoveTo actionWithDuration:1.5f 
                                                position:ccp(curtain.position.x, curtain.position.y - 20)];
            [curtain runAction:[CCSequence actions:actionMove, nil]];
        }
        
        pointsTimer = 0;
    }
    
    soundTimer += 1;
    if (soundTimer >= soundTimerLimit) {
           
        float thisGain = distanceBetweenPoints( ccp(paddlePoint.x,paddlePoint.y), ccp(ballPoint.x, ballPoint.y) );    
        thisGain = map(thisGain, 0.0f, 400.0f, 1.0f, 0.25f );
        
        float thisPan = map(ballPoint.x, 0.0f, w, -1.0f, 1.0f);
        
        /*
        CCLOG(@"distance %f", thisGain);
        CCLOG(@"panning  %f", thisPan);
        */
         
        [[SimpleAudioEngine sharedEngine] playEffect:@"ball.aiff" pitch:1.0f pan:thisPan gain:thisGain];
        
        soundTimer = 0;
    }

    
    std::vector<MyContact>::iterator pos;
    for(pos = _contactListener->_contacts.begin(); pos != _contactListener->_contacts.end(); ++pos) {
        MyContact contact = *pos;
        
        if (contact.fixtureA == _ballsLastContactFixture || contact.fixtureB == _ballsLastContactFixture ) {
            //CCLOG(@"*** avoided double detection");
            continue;
        }
        
        if ((contact.fixtureA == _bottomFixture && contact.fixtureB == _ballFixture) ||
            (contact.fixtureA == _ballFixture && contact.fixtureB == _bottomFixture)) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"ball_out.aiff" pitch:1.0f pan:0.0 gain:1.0f];
            
            lives -= 1;            
            [labelLives setString:[NSString stringWithFormat:@"%@%i", strLabelLives, lives ]];
            
            if (lives <= 0) {
                gameRunning = false;
                
                [[SimpleAudioEngine sharedEngine] playEffect:@"game_over.aiff" pitch:1.0f pan:0.0 gain:1.0f];
                
                GameOverScene *gameOverScene = [GameOverScene node];
                
                [gameOverScene.layer setNewScore:points];
                [gameOverScene.layer update];
                
                [[CCDirector sharedDirector] replaceScene:gameOverScene];
            }
            
            //CCLOG(@"Dropped out down!");
            
            [self teleportBall];
        } else if (contact.fixtureA == _ballFixture || contact.fixtureB == _ballFixture) {
            if (contact.fixtureA == _paddleFixture || contact.fixtureB == _paddleFixture) {
                [[SimpleAudioEngine sharedEngine] playEffect:@"paddle.aiff" pitch:1.0f pan:0.0 gain:0.3f];
                
                levelChangeCounter += 0.012;
                level = (int) ( 10 * ( ( pow(levelChangeCounter-1.0f, 3.0f) + 1 ) ) );
                [labelLevel setString:[NSString stringWithFormat:@"%@%i", strLabelLevel, level ]];
                
                points += 10*level;
                [labelPoints setString:[NSString stringWithFormat:@"%@%i", strLabelPoints, points ]];
                
                b2Vec2 addedVel = _ballBody->GetLinearVelocity();
                addedVel.Set(addedVel.x * 0.1f, (addedVel.y * 0.1f));
                
                _ballBody->ApplyLinearImpulse(addedVel, ballBodyDef.position );
                
            } else {
                highlightCircleSprite.position = ccp(ballPoint.x, ballPoint.y);
                highlightCircleSprite.visible = true;
                highlightCircleSprite.scale = 1.0f;
                
                id actionScale = [CCScaleTo actionWithDuration:0.3f scale:0.0f];
                [highlightCircleSprite runAction:actionScale];
                
                float thatPan = map(ballPoint.x, 0.0f, w, -1.0f, 1.0f);                
                [[SimpleAudioEngine sharedEngine] playEffect:@"wall.aiff" pitch:1.0f pan:thatPan gain:0.8f];
                
                if (ballPoint.x < 30) {
                    _ballBody->ApplyLinearImpulse(b2Vec2(0.4f, 0.0f), ballBodyDef.position );
                } else if (ballPoint.x > w-30) {
                    _ballBody->ApplyLinearImpulse(b2Vec2(-0.4f, 0.0f), ballBodyDef.position );
                }
            }
        }
        
        
        if (contact.fixtureA == _ballFixture ) {
            _ballsLastContactFixture = contact.fixtureB;
        } 
        
        if ( contact.fixtureB == _ballFixture ) {
            _ballsLastContactFixture = contact.fixtureA;
        }
    }    
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_mouseJoint != NULL) return;
    
    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:[myTouch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    b2Vec2 locationWorld = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    
    if (_paddleFixture->TestPoint(locationWorld)) {
        b2MouseJointDef md;
        md.bodyA = _groundBody;
        md.bodyB = _paddleBody;
        md.target = locationWorld;
        md.collideConnected = true;
        md.maxForce = 100.0f * _paddleBody->GetMass();
        
        _mouseJoint = (b2MouseJoint *)_world->CreateJoint(&md);
        _paddleBody->SetAwake(true);
    }
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_mouseJoint == NULL) return;
    
    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:[myTouch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    b2Vec2 locationWorld = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    
    _mouseJoint->SetTarget(locationWorld);
    
}

-(void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_mouseJoint) {
        _world->DestroyJoint(_mouseJoint);
        _mouseJoint = NULL;
    }
    
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_mouseJoint) {
        _world->DestroyJoint(_mouseJoint);
        _mouseJoint = NULL;
    }  
}

- (void)dealloc {
    
    delete _world;
    _groundBody = NULL;
    [super dealloc];
    
}

@end