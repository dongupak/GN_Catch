//
//  GameScene.h
//  GNCatch
//
//  Created by DongGyu Park( @dongupak ) on 11. 9. 8..
//  Copyright 2011 DongGyu Park. ( http://Cocos2dDev.com/ )All rights reserved.
//
//  2011 경남 모바일 앱 공모전"에서 최우수 수상앱
//
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h> 

#import "SimpleAudioEngine.h"
#import "cocos2d.h"
#import "MessageNode.h"
#import "SceneManager.h"

#import "Player.h"      // 플레이어 

#import "Logo.h"
#import "GNLogo.h"      // 조커 역할을 하는 경남로고, 에너지와 점수 증가
#import "GNSubLogo.h"   // 점수를 얻을 수 있는 경남지역내 지자체 로고
#import "Bomb.h"        // life를 잃는 폭탄
#import "FakeLogo.h"    // 가짜 경남지자체 로고(먹으면 감점)

typedef enum {
    GNLogoType = 2900,
    GNSubLogoType,
    FakeLogoType,
    BombType,
} LOGOTYPE;

@interface GameLayer : CCLayer 
{
	Player  *player;   
	CGPoint playerVelocity;
    NSInteger   comboCount;
    
    CCLabel *scoreLabel;
    CCLabel *lifeLabel;
    
    CCNode  *logoGroupNode;     // 게임속 지자체 로고
    
    CCAnimate *smokeAnimate;
    CCAnimate *bombDownAnimate;
    CCAnimate *logoExplosionAnimate;
    CCAnimate *fakeLogoExplosionAnimate;
    
    CCSprite *bombSmoke;
    CCSprite *bombSprite;
    CCSprite *logoExplosion;
    CCSprite *fakeLogoExplosion;
    
    CCProgressTimer *ptEnergy;
    
    NSArray *logoImageArray;
    NSArray *fakeLogoImageArray;
		
	NSInteger gameScore, numOfLife;     // 게임 점수와 life 개수 
	MessageNode *message;
	
	SimpleAudioEngine *sae;
    
    // game control properties
	float bombGenInterval;      // 폭탄 생성 시간간격
    float logoGenInterval;      // 로고 생성 시간간격
    float fakelogoGenInterval;  // 가짜로고 생성 시간간격
    float jokerGenInterval;     // 조커로고 생성 시간간격
}

@property (nonatomic, retain) Player *player;

@property (nonatomic, retain) CCNode *logoGroupNode;

@property (nonatomic, retain) CCLabel *scoreLabel;
@property (nonatomic, retain) CCLabel *lifeLabel;

@property (nonatomic, retain) MessageNode *message;

// plist로부터 로고를 읽어들임
@property (nonatomic, retain) NSArray *logoImageArray;  
// plist로부터 가짜로고를 읽어들임
@property (nonatomic, retain) NSArray *fakeLogoImageArray;  

- (void) initImageArray;
- (void) displayScoreAndLife;

- (LOGOTYPE) chooseRandomLogoType;
- (void) animateLogoAndCountScore;

- (void) updateScore;
- (void) updateLifeLabel;

- (void) setBackground;
- (void) decreaseLife;
- (void) createBombSmoke;
- (void) createBombDownAnimation;
- (void) createLogoExplosion;
- (void) createEnergyBar;
- (void) gameOver;

@end
