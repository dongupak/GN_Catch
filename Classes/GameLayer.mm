//
//  GameScene.m
//  GNCatch
//
//  Created by DongGyu Park( @dongupak ) on 11. 9. 8..
//  Copyright 2011 DongGyu Park. ( http://Cocos2dDev.com/ )All rights reserved.
//
//  2011 경남 모바일 앱 공모전"에서 최우수 수상앱
//

#import "GameLayer.h"
#import "GameOverLayer.h"
#import "GNCatchAppDelegate.h"

// int값 min에서 max사이의 난수를 생성하여 float로 반환하는 기능
float clampRandomNumber(int min, int max)
{
	int t = arc4random()%(max-min);
	
	return (t+min)*1.0f; // 실수로 바꾸어서 반환함
}

@implementation GameLayer

enum {
    kTagBackground = 1400,
    kTagMenu,
    kTagPlayer,
    kTagSprite,
    kTagSpriteSheet,
    kTagScoreLabel,
    kTagLifeLabel,
    kTagBombGroup,
    kTagLogoGroup,
    kTagFakeLogoGroup,
    kTagJokerGroup,
    kTagMessage,
};

enum {
    kTagGNLogo = 3500,
    kTagGNSubLogo,
    kTagBomb,
    kTagFakeLogo,
};

@synthesize player;

@synthesize logoGroupNode;

@synthesize scoreLabel, lifeLabel;
@synthesize message;

@synthesize  logoImageArray;
@synthesize  fakeLogoImageArray;

#define NUM_OF_GAMER_LIFE   (3)
#define INIT_SCORE          (0)

-(id) init
{
	if ((self = [super init]))
	{
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
		float imageHeight = 0;
        
		gameScore = INIT_SCORE;
        numOfLife   = NUM_OF_GAMER_LIFE;
        smokeAnimate = nil;
        comboCount = 0; // 콤보 계산을 위한 카운터
        
        logoGenInterval = 1.0f;
        fakelogoGenInterval = 0.8f;
        bombGenInterval = 6.0f;
        
        [self initImageArray];
        [self setBackground];
        [self createBombSmoke];
        [self createLogoExplosion];
        [self createBombDownAnimation];
        [self createEnergyBar];
        
		// audio engine
		sae=[SimpleAudioEngine sharedEngine];
        [sae preloadEffect:@"GN_bg_sound.mp3"];
		[sae preloadEffect:@"GN_fire.m4a"];
        [sae preloadEffect:@"GN_bell.m4a"];
        [sae preloadEffect:@"GN_bellOing.m4a"];
        [sae playBackgroundMusic:@"GN_bg_sound.mp3"];
		
        GNCatchAppDelegate *appDelegate = (GNCatchAppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.gameScore = 0;
        
        [self displayScoreAndLife];
        
		self.message = [MessageNode node];
		[self addChild:self.message z:1200 tag:kTagMessage];
		
		// 가속도 입력
		self.isAccelerometerEnabled = YES;
		
        [self setScreenSaverEnabled:NO];
        
		// 게임 플레이어 스프라이트 추가
		player = [Player spriteWithFile:@"character.png"];
        [player playerAnimation];
        
        // 스프라이트 배치 플레이어 첫 시작위치
		imageHeight = player.contentSize.height;
		player.position = ccp(screenSize.width/2, imageHeight/2);
        [self addChild:player z:400 tag:kTagPlayer];
				
        logoGroupNode = [CCNode node];
        
        [self addChild:logoGroupNode z:90 tag:kTagLogoGroup];
        
		[self schedule:@selector(generateLogoAndFakeLogo) interval:logoGenInterval];
        [self schedule:@selector(animateLogoAndCountScore)];
        [self scheduleUpdate];
	}
	
	return self;
}

-(void) createEnergyBar
{
    CCSprite *ptEnergyEmpty = [CCSprite spriteWithFile:@"pole_em.png"];
    ptEnergyEmpty.anchorPoint = ccp(0, 0);
    ptEnergyEmpty.position = ccp(280, 85);
    [self addChild:ptEnergyEmpty z:20];
    
    ptEnergy = [CCProgressTimer progressWithFile:@"pole_en.png"];
    ptEnergy.type = kCCProgressTimerTypeVerticalBarBT;
    ptEnergy.anchorPoint = ccp(0, 0);
    ptEnergy.position = ccp(280, 85);
    ptEnergy.percentage=100;
    [self addChild:ptEnergy z:21];
}

-(void) updateEnergyBar
{
    if ( player.playerHP < 0) {
        player.playerHP = 0;
    }
    else if( player.playerHP > 100){
        player.playerHP = 99;
    }
    
    ptEnergy.percentage = player.playerHP;
}

-(void) setBackground
{
    // 배경그림 입히기 
    CCSprite *bgSprite=[CCSprite spriteWithFile:@"bg_game.png"];
    bgSprite.anchorPoint=CGPointZero;
    bgSprite.position=CGPointZero;
    [self addChild:bgSprite z:0 tag:kTagBackground];
}

-(void) displayScoreAndLife
{
    // 점수를 표시할 레이블(CCLabel)을 만듭니다.
    // 처음에 보일 스트링으로 Score: 0000을 사용합니다.
    // 폰트는 Arial을 사용하며 폰트의 크기를 22로 정합니다.
    NSString *scoreString = [NSString stringWithFormat:@"Score: %05d", gameScore];
    CCLabel* label = [[CCLabel alloc] initWithString:scoreString
                                            fontName:@"Arial" 
                                            fontSize:22];
    self.scoreLabel = label;
    self.scoreLabel.anchorPoint = CGPointZero;
    self.scoreLabel.position = ccp(15, 450);
    [self addChild:self.scoreLabel z:1000 tag:kTagScoreLabel];
    [label release];
    
    NSString *lifeString = [NSString stringWithFormat:@"Life: %2d", numOfLife];
    label = [[CCLabel alloc] initWithString:lifeString
                                             fontName:@"Arial" 
                                             fontSize:22];
    self.lifeLabel = label;
    self.lifeLabel.anchorPoint = CGPointZero;
    self.lifeLabel.position = ccp(235, 450);
    [self addChild:self.lifeLabel z:1000 tag:kTagLifeLabel];
    
    [label release];
}

-(void) createBombDownAnimation
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] 
     addSpriteFramesWithFile:@"bombDown.plist"];
    
    NSMutableArray *bombFrames = [NSMutableArray array];
    for(NSInteger idx = 1; idx < 5; idx++) {
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"bomb%1d.png",idx]];
        [bombFrames addObject:frame];
    }
    
    CCAnimation *bombDownAnimation = [CCAnimation animationWithName:@"bombDownAnimation"
                                                           delay:0.07
                                                          frames:bombFrames];
    
    bombDownAnimate = [[CCAnimate alloc] initWithAnimation:bombDownAnimation 
                                   restoreOriginalFrame:NO];
}

-(void)createLogoExplosion
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] 
        addSpriteFramesWithFile:@"bubble.plist"];
    
    logoExplosion = [[CCSprite alloc] init];
    [self addChild:logoExplosion z:500];    
    
    NSMutableArray *frames = [NSMutableArray array];
    for(NSInteger idx = 1; idx < 6; idx++) {
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"bb_bob_yellow%1d.png",idx]];
        [frames addObject:frame];
    }
    
    CCAnimation *bubbleAnimation = [CCAnimation animationWithName:@"bubbleAnimation"
                                                           delay:0.07
                                                          frames:frames];
    
    logoExplosionAnimate = [[CCAnimate alloc] initWithAnimation:bubbleAnimation restoreOriginalFrame:NO];

    fakeLogoExplosion = [[CCSprite alloc] init];
    [self addChild:fakeLogoExplosion z:500];    
    
    frames = [NSMutableArray array];
    for(NSInteger idx = 1; idx < 6; idx++) {
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"bb_bob_blue%1d.png",idx]];
        [frames addObject:frame];
    }
    
    bubbleAnimation = [CCAnimation animationWithName:@"bubbleAnimation"
                                                            delay:0.07
                                                           frames:frames];
    
    fakeLogoExplosionAnimate = [[CCAnimate alloc] initWithAnimation:bubbleAnimation restoreOriginalFrame:NO];
}

-(void)createBombSmoke
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] 
            addSpriteFramesWithFile:@"gun.plist"];
    
    bombSmoke = [[CCSprite alloc] init];
    [self addChild:bombSmoke z:500];    
    
    NSMutableArray *smokeFrames = [NSMutableArray array];
    for(NSInteger idx = 1; idx < 10; idx++) {
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"shotgun_smoke2_%04d.png",idx]];
        [smokeFrames addObject:frame];
    }
    
    CCAnimation *smokeAnimation = [CCAnimation animationWithName:@"bombAnimation"
                                                           delay:0.07
                                                          frames:smokeFrames];
    
    smokeAnimate = [[CCAnimate alloc] initWithAnimation:smokeAnimation restoreOriginalFrame:NO];
}

-(void)showBombEffect:(CGPoint) point
{
    if(smokeAnimate == nil)
        [self createBombSmoke];
        
    bombSmoke.position = point;
    
    if (![smokeAnimate isDone]) 
        [bombSmoke stopAction:smokeAnimate];  
    [bombSmoke runAction:smokeAnimate];
    [sae playEffect:@"GN_fire.m4a"];
}

-(void) decreaseLife
{
    [self.message showMessage:LIFE_MINUS_MESSAGE];
    
    numOfLife = numOfLife - 1;
    
    if ( numOfLife <= 0)
        [self gameOver];
    else {
        player.playerHP = 100;
        [self updateEnergyBar];
    }
    
    [self updateLifeLabel];
}

-(void)showGNLogoEffect:(CGPoint) point
{
    if(logoExplosionAnimate == nil)
        [self createLogoExplosion];
    
    logoExplosion.position = point;
    
    if (![logoExplosionAnimate isDone]) 
        [logoExplosion stopAction:logoExplosionAnimate];  
    [logoExplosion runAction:logoExplosionAnimate];
}

-(void)showFakeLogoEffect:(CGPoint) point
{
    if(fakeLogoExplosionAnimate == nil)
        [self createLogoExplosion];
    
    fakeLogoExplosion.position = point;
    
    if (![fakeLogoExplosionAnimate isDone]) 
        [fakeLogoExplosion stopAction:fakeLogoExplosionAnimate];  
    [fakeLogoExplosion runAction:fakeLogoExplosionAnimate];
}

- (void) showComboMessage
{
    CGPoint randomPoint = ccp(clampRandomNumber(100,250), clampRandomNumber(200,400));
    
//    if ( comboCount == 2 ) {
//        [message showMessage:COMBO2_MESSAGE atPosition:randomPoint];
//    }
    if( comboCount == 3 ) {
        [message showMessage:COMBO3_MESSAGE atPosition:randomPoint];
    }
    else if ( comboCount > 3 ){
        [message showMessage:COMBO_COMBO_MESSAGE atPosition:randomPoint];
        comboCount = 0; // reset Combo Count
    }
    
}
#define GN_LOGO_HP_VALUE    (10)
#define GN_LOGO_VALUE       (100)
#define GN_SUB_LOGO_VALUE   (10)

-(void) getGNBonus
{
    [self showComboMessage];
    [sae playEffect:@"GN_yeh.m4a"];
    
    gameScore += GN_LOGO_VALUE;
    player.playerHP += GN_SUB_LOGO_VALUE * 2;
    if( player.playerHP > 100 )
        player.playerHP = 100;
    
    [self updateEnergyBar];
    [self updateScore];
}

-(void) getGNSubBonus
{
    [self showComboMessage];
    [sae playEffect:@"GN_bell.m4a"];

    gameScore += GN_SUB_LOGO_VALUE;
    [self updateScore];
}

-(void) getFakeLogo
{
    [sae playEffect:@"GN_bellOing.m4a"];
    
    if (gameScore <= 0) // 점수가 0점 이하이면 업데이트 안함 
        return;
    
    gameScore -= GN_SUB_LOGO_VALUE;
    player.playerHP -= GN_SUB_LOGO_VALUE;
    
    // playerHP가 -가 되면 Life가 줄어들고 Life도 1감소한다
    if (player.playerHP < 0)  {
        player.playerHP = 100;
        [self decreaseLife];
        [message showMessage:LIFE_MINUS_MESSAGE];
    }
    
    [self updateEnergyBar];
    [self updateScore];
}

-(void) countLifeAndScoreWith:(NSArray *)collisionArray
{
    for (Logo *aLogo in collisionArray) {
        switch (aLogo.tag) {
            case kTagBomb :
                comboCount = 0;     // reset Combo Count
                // life가 감소함
                [self decreaseLife];
                [self showBombEffect:aLogo.position];
                break;
            case kTagGNLogo :
                comboCount++;
                [self showGNLogoEffect:aLogo.position];
                [self getGNBonus];
                break;
            case kTagGNSubLogo:
                comboCount++;
                [self showGNLogoEffect:aLogo.position];
                [self getGNSubBonus];
                break;
            case kTagFakeLogo:
                // reset Combo Count
                comboCount = 0;     
                [self showFakeLogoEffect:aLogo.position];
                [self getFakeLogo];
                break;
            default:
                break;
        }
    }
}

#define GN_LOGO_MISS_VALUE      (10)
#define GN_SUB_LOGO_MISS_VALUE  (5)

// GNLogo(경남 로고)를 놓지면 감점..
-(void) missGNLogo
{
    // 경남 로고를 놓쳤으므로 combo Count가 reset됨
    comboCount = 0; // reset Combo Count
    
    if ( gameScore <= 0)
        return;
    
    gameScore -= GN_LOGO_MISS_VALUE;
    [self updateScore];
}

// GNSub(경남 산하지자체 로고)를 놓지면 감점
-(void) missGNSubLogo
{
    comboCount = 0; // reset Combo Count
    player.playerHP -= GN_SUB_LOGO_MISS_VALUE;
    if ( player.playerHP <= 0) {
        player.playerHP = 100;
        [self decreaseLife];
    }
    
    [self updateEnergyBar];
    if ( gameScore <= 0)
        return;
    
    gameScore -= GN_SUB_LOGO_MISS_VALUE;
    [self updateScore];
}

-(void)animateLogoAndCountScore
{
    CGSize winsize = [[CCDirector sharedDirector] winSize];
    const int toBeDeletedArraySize = [[logoGroupNode children] count]+1;
    
    // 로고들 중에서 화면을 벗어난 것들이 있는지 있으면 그룹 노드에서 삭제함
    NSMutableArray *toBeDeletedLogos = [[NSMutableArray alloc] 
                                        initWithCapacity:toBeDeletedArraySize];
    
    for (Logo *aLogo in [logoGroupNode children]) {
        if ([aLogo isOutsideWindow:winsize] == YES) {
            switch ( aLogo.tag ) {
                case kTagBomb :
                    break;
                case kTagGNLogo:
                    [self missGNLogo];
                    break;
                case kTagGNSubLogo:
                    [self missGNSubLogo];
                    break;
                case kTagFakeLogo:
                    break;
                default:
                    break;
            }
            // 화면 밖으로 로고가 나가면 toBeDeletedLogos 배열에 넣어서 나중에 삭제 
            [toBeDeletedLogos addObject:aLogo];
        }
        else if( [player hasCollionWith:logoGroupNode] )
        {
            [self countLifeAndScoreWith:player.collisonLogoArray];
            // 플레이어와 충돌한 로고들은 toBeDeletedLogos에 넣어둔다..
            // 나중에 한꺼번에 제거시키도록 한다.
            [toBeDeletedLogos addObjectsFromArray:player.collisonLogoArray];
        }
    }
    
    for(Logo *aLogo in toBeDeletedLogos) {
		[logoGroupNode removeChild:aLogo cleanup:NO];
	}
    [toBeDeletedLogos release];
}

-(void)updateScore
{
    if( gameScore < 0 )        // 점수가 - 가 되면 안되요..
        gameScore = 0;
    
    if ( gameScore > 3000) {
        logoGenInterval = 0.8f;
        fakelogoGenInterval = 0.6f;
        bombGenInterval = 4.0f;
    }
    else if( gameScore > 10000 )
    {
        logoGenInterval = 0.6f;
        fakelogoGenInterval = 0.4f;
        bombGenInterval = 3.0f;
    }
    
    NSString *str = [NSString stringWithFormat:@"Score: %05d", gameScore];
    [self.scoreLabel setString:str];
    
    id scaleAction = [CCSequence actions:
                      [CCScaleTo actionWithDuration:0.1 scale:1.1],
                      [CCScaleTo actionWithDuration:0.1 scale:1.0], nil];
    [self.scoreLabel runAction:scaleAction];
}

-(void)updateLifeLabel
{
    if ( numOfLife < 0)     // life가 -가 되면 안되요
        numOfLife = 0;

    NSString *str = [NSString stringWithFormat:@"Life: %2d", numOfLife];
    [self.lifeLabel setString:str];
    
    id scaleAction = [CCSequence actions:
                      [CCScaleTo actionWithDuration:0.1 scale:1.1],
                      [CCScaleTo actionWithDuration:0.1 scale:1.0], nil];
    
    [self.lifeLabel runAction:scaleAction];
}


-(void) initImageArray
{
    // 임시로 지자체 이미지 대신 휠 배열을 사용하자.
	NSString *glSubLogoPath = [[NSBundle mainBundle] pathForResource:@"gnSubLogo"
                                                           ofType:@"plist"];
	NSArray *gnSubLogoArray = [[NSArray alloc] initWithContentsOfFile:glSubLogoPath];
	self.logoImageArray = gnSubLogoArray;
    [gnSubLogoArray release];
    
    // 가짜 지자체 이미지도 여기서 읽도록 한다.
	NSString *fakeLogoPath = [[NSBundle mainBundle] pathForResource:@"FakeLogo"
                                                           ofType:@"plist"];
	NSArray *fakeLogoArray = [[NSArray alloc] initWithContentsOfFile:fakeLogoPath];
    NSLog (@"fakeLogo = %@", fakeLogoArray);
	self.fakeLogoImageArray = fakeLogoArray;
    [fakeLogoArray release];
}

-(LOGOTYPE) chooseRandomLogoType
{
    LOGOTYPE aLogoType;
    int randomRange = 30;
    int chooseObj = arc4random() % randomRange;
    
    switch (chooseObj) {
        case 0 :     
        case 1 :        // 10% 확률로 경남로고
            aLogoType = GNLogoType;
            break;
        case 2 :
        case 3 :
        case 4 :
        case 5 :        // 20% 확률로 폭탄이 떨어짐
            aLogoType = BombType;
            break;
        case 6 :
        case 7 :
        case 8 :
        case 9 :
        case 10 :
        case 11 :
        case 12 :       // 35% 확률로 가짜 로고
            aLogoType = FakeLogoType;
            break;
        default:        // 35% 확률로 경남 산하 로고
            aLogoType = GNSubLogoType;
            break;
    }
        
    return aLogoType;
}

#define CONTENT_OFFSET      (100)
#define LOGO_GYEONGNAM      (@"logo_gyeongnam.png")
#define DEFAULT_LOGO_WIDTH     (50)

-(GNLogo *)generateGNLogo
{
    int halfOfLogoWidth = DEFAULT_LOGO_WIDTH, pointX = 100 ;    // default value
	float timeDuration = 0.0f ; // default time duration
    CGSize winsize = [[CCDirector sharedDirector] winSize];

    GNLogo *aGNLogo = [GNLogo spriteWithFile:LOGO_GYEONGNAM];
    [aGNLogo logoAction];
    halfOfLogoWidth = aGNLogo.contentSize.width/2.0;
    // 화면내에 랜덤하게 경남로고가 나타나도록 함 
    pointX = clampRandomNumber(halfOfLogoWidth, winsize.width - halfOfLogoWidth);
	aGNLogo.position = ccp(pointX, winsize.height + halfOfLogoWidth);
    
    // aBomb의 목적지 Y값은 content크기보다 더 아래쪽으로 두어
    // 사라졌는지 검사가 쉽도록 한다
    float targetPointY = -aGNLogo.contentSize.height-CONTENT_OFFSET;
    // 로고가 생성되어 떨어지는 시간..
	timeDuration = clampRandomNumber(100, 400)/50.0f;
	id actionMove=[CCMoveTo actionWithDuration:timeDuration
                                      position:ccp(aGNLogo.position.x,targetPointY)];
	[aGNLogo runAction:[CCSequence actions:actionMove, nil]];
    // logoGroupNode에 FakeLogo를 추가하고 애니메이션 시킨다.
    [logoGroupNode addChild:aGNLogo z:300 tag:kTagGNLogo];

    return aGNLogo;
}

-(GNSubLogo *)generateGNSubLogo
{
    int randLogoIndex = arc4random() % [self.logoImageArray count];
    int halfOfLogoWidth = DEFAULT_LOGO_WIDTH, pointX = 100 ;    // default value
	float timeDuration = 0.0f ;
    CGSize winsize = [[CCDirector sharedDirector] winSize];
    
    // plist로 부터 지자체의 로고를 읽어서 랜덤하게 그려주도록 하지...
    NSString *logoFileName = [self.logoImageArray objectAtIndex:randLogoIndex];
    
    NSLog(@"logoFileName = %@", logoFileName);
    GNSubLogo *logo = [GNSubLogo spriteWithFile:logoFileName];
    NSLog(@"logo = %@", logo );
    // 떨어지면서 회전하는 액션
    [logo logoAction];
    halfOfLogoWidth = logo.contentSize.width/2.0;
    pointX = clampRandomNumber(halfOfLogoWidth, winsize.width - halfOfLogoWidth);
	logo.position = ccp(pointX, winsize.height + halfOfLogoWidth);
    
	// logo의 목적지 Y값은 content크기보다 더 아래쪽으로 두어
    // 사라졌는지 검사가 쉽도록 한다
    float targetPointY = -logo.contentSize.height-CONTENT_OFFSET;
    // 로고가 생성되어 떨어지는 시간..
	timeDuration = clampRandomNumber(100, 400)/50.0f;
	id actionMove = [CCMoveTo actionWithDuration:timeDuration 
                                        position:ccp(logo.position.x,targetPointY)];
	[logo runAction:[CCSequence actions:actionMove, nil]];
    [logoGroupNode addChild:logo z:300 tag:kTagGNSubLogo];

    return logo;
}

-(Bomb *)generateBomb
{
    int halfOfLogoWidth = DEFAULT_LOGO_WIDTH, pointX = 100 ;    // default value
	float timeDuration = 0.0f ;
    CGSize winsize = [[CCDirector sharedDirector] winSize];
    
    Bomb *aBomb = [Bomb spriteWithFile:@"bomb1.png"];
    // 떨어지면서 회전하는 액션
    
    [aBomb logoAction];
    if ( bombDownAnimate != nil) {
        NSLog(@"bombDownAnimate not nil");
        CCRepeatForever *repeatAction = [CCRepeatForever actionWithAction:bombDownAnimate];
        [aBomb runAction:repeatAction];
    }
    halfOfLogoWidth = aBomb.contentSize.width/2.0;
    pointX = clampRandomNumber(halfOfLogoWidth, winsize.width - halfOfLogoWidth);
	aBomb.position = ccp(pointX, winsize.height + halfOfLogoWidth);
    
    // aBomb의 목적지 Y값은 content크기보다 더 아래쪽으로 두어
    // 사라졌는지 검사가 쉽도록 한다
    float targetPointY = -aBomb.contentSize.height-CONTENT_OFFSET;
    // 로고가 생성되어 떨어지는 시간..
	timeDuration = clampRandomNumber(100, 400)/50.0f;
	id actionMove=[CCMoveTo actionWithDuration:timeDuration
                                      position:ccp(aBomb.position.x,targetPointY)];
	[aBomb runAction:[CCSequence actions:actionMove, nil]];
    // logoGroupNode에 FakeLogo를 추가하고 애니메이션 시킨다.
    [logoGroupNode addChild:aBomb z:300 tag:kTagBomb];
    
    return aBomb;
}

-(FakeLogo *)generateFakeLogo
{
    int randLogoIndex = arc4random() % [self.fakeLogoImageArray count];
    int halfOfLogoWidth = DEFAULT_LOGO_WIDTH, pointX = 100 ;    // default value
	float timeDuration = 0.0f ;
    CGSize winsize = [[CCDirector sharedDirector] winSize];
    
    // plist로 부터 지자체의 로고를 읽어서 랜덤하게 그려주도록 하지...
    NSString *logoFileName = [self.fakeLogoImageArray objectAtIndex:randLogoIndex];
    
    FakeLogo *aFakeLogo = [FakeLogo spriteWithFile:logoFileName];
    // 떨어지면서 회전하는 액션
    [aFakeLogo logoAction];
    halfOfLogoWidth = aFakeLogo.contentSize.width/2.0;
    pointX = clampRandomNumber(halfOfLogoWidth, winsize.width - halfOfLogoWidth);
	aFakeLogo.position = ccp(pointX, winsize.height + halfOfLogoWidth);
    
    // fakeLogo의 목적지 Y값은 content크기보다 더 아래쪽으로 두어
    // 사라졌는지 검사가 쉽도록 한다
    float targetPointY = -aFakeLogo.contentSize.height-CONTENT_OFFSET;
    // 로고가 생성되어 떨어지는 시간..
	timeDuration = clampRandomNumber(100, 400)/50.0f;
	id actionMove=[CCMoveTo actionWithDuration:timeDuration
                                      position:ccp(aFakeLogo.position.x,targetPointY)];
	[aFakeLogo runAction:[CCSequence actions:actionMove, nil]];
    // logoGroupNode에 FakeLogo를 추가하고 애니메이션 시킨다.
    [logoGroupNode addChild:aFakeLogo z:300 tag:kTagFakeLogo];
    
    return aFakeLogo;
}

- (void) generateLogoAndFakeLogo
{
    switch ([self chooseRandomLogoType]) {
        case GNLogoType :
            [self generateGNLogo];
            break;
        case GNSubLogoType :
            [self generateGNSubLogo];
            break;
        case BombType:
            [self generateBomb];
            break;
        case FakeLogoType :
            [self generateFakeLogo];
            break;
        default:
            break;
    }
}	

#pragma mark Accelerometer Input

#define DEFAULT_DECELERATION    (0.4f)
#define DEFAULT_SENSITIVITY     (6.0F)
#define MAX_VELOCITY            (100)

-(void) accelerometer:(UIAccelerometer *)accelerometer 
        didAccelerate:(UIAcceleration *)acceleration
{	
    NSLog(@"updateInterval = %6.2f", accelerometer.updateInterval);
    
	// 현재 가속도계의 가속에 따라 속도 조절
	playerVelocity.x = playerVelocity.x * DEFAULT_DECELERATION + acceleration.x * DEFAULT_SENSITIVITY;
	
	// 플레이어 스프라이트 최대 속도 제한
	if (playerVelocity.x > MAX_VELOCITY)
		playerVelocity.x = MAX_VELOCITY;
	else if (playerVelocity.x < -MAX_VELOCITY)
		playerVelocity.x = -MAX_VELOCITY;
}

#pragma mark update

-(void) update:(ccTime)delta
{
	// player.position.x를 임시 변수로 설정
	CGPoint pos = player.position;
    pos.x += playerVelocity.x;
    
	// 플레이어 화면밖으로 이동하면 안됨
	// 플레이어 스프라이트의 위치는 이미지의 중심에 있음
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	float halfOfContentWidth = player.contentSize.width * 0.5f;
	float leftBorderLimit = halfOfContentWidth;
	float rightBorderLimit = screenSize.width - halfOfContentWidth;
	
	// 이미지 크기와 기준에 따라 화면밖으로 이동 못하게 설정
	if (pos.x < leftBorderLimit)
	{
		pos.x = leftBorderLimit;
		// 가속도가 제로이나 속도가 남아있을때 가장자리를 향해 가속함으로 제어 
		playerVelocity = CGPointZero;
	}
	else if (pos.x > rightBorderLimit)
	{
		pos.x = rightBorderLimit;
		// 가속도가 제로이나 속도가 남아있을때 가장자리를 향해 가속함으로 제어
		playerVelocity = CGPointZero;
	}
	
	player.position = pos;
}

// The game is played only using the accelerometer. The screen may go dark while playing because the player
// won't touch the screen. This method allows the screensaver to be disabled during gameplay.
-(void) setScreenSaverEnabled:(bool)enabled
{
	UIApplication *thisApp = [UIApplication sharedApplication];
	thisApp.idleTimerDisabled = !enabled;
}

-(void)gotoGameCloseLayer
{	
    [SceneManager goGameOver];
}

#pragma mark gameOver

-(void) gameOver
{
    [player setVisible:NO]; // 게임이 끝나서 플레이어는 보이지 않음
    
    GNCatchAppDelegate *appDelegate = (GNCatchAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.gameScore = gameScore;
    
    // 모든 로고에 대하여 액션 중지
    for (Logo *aLogo in [logoGroupNode children])
        [aLogo stopAllActions];
    
	// 사용 중인 schdule을 모두 끕니다.
	[self unschedule:@selector(generateLogoAndFakeLogo)];
    [self unschedule:@selector(animateLogoAndCountScore)];
    [self unscheduleUpdate];    // 플레이어의 동작 중지
	
	// 배경음악 종료
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	
    // 더 이상 사용되지않는 그래픽 캐시를 지웁니다.
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
	
    [self performSelector:@selector(gotoGameCloseLayer) 
			   withObject:nil 
               afterDelay:4.1];
}

@end
