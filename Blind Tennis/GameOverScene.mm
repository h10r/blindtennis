//
//  GameOverScene.m
//  Cocos2DSimpleGame
//


#import "GameOverScene.h"
#import "GameScene.h"

@implementation GameOverScene
@synthesize layer = _layer;

- (id)init {

	if ((self = [super init])) {
		self.layer = [GameOverLayer node];
		[self addChild:_layer];
	}
	return self;
}

- (void)dealloc {
	[_layer release];
	_layer = nil;
	[super dealloc];
}

@end

@implementation GameOverLayer
@synthesize label = _label;
@synthesize newScore = _newScore;

-(id) init
{
	if( (self=[super init] )) {
		CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        // HIGHSCORE
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        
        if (standardUserDefaults) {
            scoresArray = [[NSMutableArray alloc] initWithArray:[standardUserDefaults objectForKey:@"highscore"]];
            
            //CCLOG(@"-- Read highscore from stndardUserDefaults");
            
            if (scoresArray == nil) {
                //CCLOG(@"-- Created new NSUserDefaults shit");
                scoresArray = [[NSMutableArray alloc] init];
            }
        }
        
        NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
        //NSLog(@"The device's specified language is %@", language);
        
        // BACKGROUND
        if ([language isEqualToString:@"de"]) {
            CCSprite *background = [CCSprite spriteWithFile:@"gameover-DE.png" 
                                                       rect:CGRectMake(0, 0, winSize.width, winSize.height)];
            background.position = ccp(background.contentSize.width/2, background.contentSize.height/2);
            [self addChild:background z:-1000];
        } else {
            CCSprite *background = [CCSprite spriteWithFile:@"gameover.png" 
                                                       rect:CGRectMake(0, 0, winSize.width, winSize.height)];
            
            background.position = ccp(background.contentSize.width/2, background.contentSize.height/2);
            [self addChild:background z:-1000];
        }
        
        //self.label = [CCLabelTTF labelWithString:@"" fontName:@"Helvetica" fontSize:14 ];
        self.label = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(200,260) alignment:UITextAlignmentCenter fontName:@"HelveticaNeue-CondensedBlack" fontSize:32];
        _label.color = ccc3(255,255,255);
        //_label.color = ccc3(0,0,0);
        _label.position = ccp(winSize.width/2, winSize.height - 230);
        [self addChild:_label];
        
        self.isTouchEnabled = YES;
        
        stillWaiting = true;
        
        [self runAction:[CCSequence actions:
						 [CCDelayTime actionWithDuration:1],
						 [CCCallFunc actionWithTarget:self selector:@selector(waitingOver)],
						 nil]];
	}	
	return self;
}

-(void)saveToUserDefaults:(NSMutableArray*)myArray {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        [standardUserDefaults setObject:myArray forKey:@"highscore"];
        [standardUserDefaults synchronize];
        //CCLOG(@"-- SAVED highscore to file");
    }
}

-(void)update {
    
    if ( ![scoresArray containsObject:[NSNumber numberWithInt:_newScore]] ) {
        [scoresArray addObject:[NSNumber numberWithInt:_newScore]];
    }
    
    [scoresArray sortUsingComparator: ^(id obj1, id obj2) {
        
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([obj1 integerValue] > [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    //CCLOG(@"%i", [scoresArray count]);
    
    while ( [scoresArray count] > 6 ) {
        [scoresArray removeLastObject];
    }
    
    //CCLOG(@"%i", [scoresArray count]);
    
    NSMutableString *highscores = [[NSMutableString alloc] init];
    
    for (int i = 0; i < [scoresArray count]; i++)
    {
        int obj = [ [scoresArray objectAtIndex:i] integerValue];
        
        [highscores appendFormat:@"%d: %d\n", i+1, obj ];
        //CCLOG(@"-- %d",obj);
    }
    
    [_label setString:highscores ];
    
    [self saveToUserDefaults:scoresArray];
    
    scoresArray = nil;
    
}

-(void)waitingOver {
    stillWaiting = false;
}

- (void)gameOverDone {
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInT transitionWithDuration:0.5f scene:[GameScene scene]]];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //CCLOG(@"Touched, gameOverDone");
    if (!stillWaiting) {
        [self gameOverDone];
    }
}


- (void)dealloc {
    [scoresArray release];
    scoresArray = nil;
    
    [_label release];
    _label = nil;
    
	[super dealloc];
}

@end
