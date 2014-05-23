//
//  Player.m
//  GNCatch
//
//  Created by DongGyu Park( @dongupak ) on 11. 9. 8..
//  Copyright 2011 DongGyu Park. ( http://Cocos2dDev.com/ )All rights reserved.
//

#import "Player.h"

@implementation Player

@synthesize playerVelocity, playerHP, isAlive;
@synthesize collisonLogoArray;

-(id)init
{
	if((self = [super init]))
	{
		self.isAlive = YES;
        self.playerHP = 100;
        self.collisonLogoArray = [[NSMutableArray alloc] init];
    }
	return self;
}

- (void)playerAnimation
{
    // playerCharacter.plist로 부터 spriteFrame을 읽어들임
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"playerCharacter.plist"];
    
    NSMutableArray *frames = [NSMutableArray array];
    for(NSInteger idx = 1; idx < 10; idx++) {
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"character%04d.png",idx]];
        [frames addObject:frame];
    }
    CCAnimation *playerAnimation = [CCAnimation animationWithName:@"playerAnimation"
                                                            delay:0.05f
                                                           frames:frames];
    CCAnimate *playerAnimate = [[CCAnimate alloc] initWithAnimation:playerAnimation restoreOriginalFrame:NO];

    id actionRepeat  = [CCRepeatForever actionWithAction:playerAnimate];
    [self runAction:actionRepeat];
}

- (CGRect) scaledRect:(float) theScaleOffset ofSprite:(CCSprite *)sprite
{
    // 스케일 오프셋 만큼 줄어든 사각형을 만들어 반환한다
    CGFloat startX = sprite.position.x-sprite.contentSize.width/2+theScaleOffset;
    CGFloat startY = sprite.position.y-sprite.contentSize.height/2+theScaleOffset;
    
	CGRect rect = CGRectMake(startX, startY,
                             sprite.contentSize.width-theScaleOffset, 
                             sprite.contentSize.height-theScaleOffset);
	return rect;
}

- (CGRect) scaledRect:(float) theScaleOffset
{
    // 스케일 오프셋 만큼 줄어든 사각형을 만들어 반환한다
    CGFloat startX = self.position.x-self.contentSize.width/2 + theScaleOffset;
    CGFloat startY = self.position.y-self.contentSize.height/2 + theScaleOffset;
    
	CGRect rect = CGRectMake(startX, startY,
                             self.contentSize.width-theScaleOffset, 
                             self.contentSize.height-theScaleOffset);
	return rect;
}

#define     SCALE_FACTOR            (0.4)
#define     COLLISION_TEST_OFFSET   (20)
#define     SCALE_OFFSET            (15.0)
#define     SMALL_SCALE_OFFSET      (15.0)

- (BOOL) collideWith: (Logo *)aLogo 
{	
    CGRect selfRect =  [self scaledRect:SCALE_OFFSET];
    CGRect logoSpriteRect = [self scaledRect:SMALL_SCALE_OFFSET ofSprite:aLogo];
    
    // 스케일을 변경한 player 스프라이트 영역과 로고 스프라이트 영역이 겹치는지 검사
    if ( CGRectIntersectsRect(selfRect, logoSpriteRect) )
        return YES;
    
    return NO;
}

#define LOGO_COLLISION_CHECK_THRESHOLD   (5)

- (BOOL) hasCollionWith:(CCNode *)logoGroup
{
    [collisonLogoArray removeAllObjects];
    
    for (Logo *aLogo in [logoGroup children]) {
        // 로고가 LOGO_COLLISION_CHECK_THRESHOLD 아래로
        // 화면의 외부에 있으면 충돌검사가 의미가 없음
        // 또한 로고가 이미 죽음 상태이면 검사가 필요없음
        if ((aLogo.position.y < LOGO_COLLISION_CHECK_THRESHOLD) ||
            (aLogo.isAlive == NO ))
            continue;
        else if ([self collideWith:aLogo] == YES) {
            NSLog(@"play와 logo가 충돌 확인");
            aLogo.isAlive = NO;
            [collisonLogoArray addObject:aLogo];
        }
	}
    
    if( [collisonLogoArray count] == 0 )
        return NO;  //  no collision
    
    return YES;  // collision occurred
}


- (void) dealloc
{
    [self removeAllChildrenWithCleanup:YES];
    [collisonLogoArray release];
	[super dealloc];
}


@end
