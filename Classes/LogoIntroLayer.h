//
//  LogoIntroLayer.h
//  GNCatch
//
//  Created by DongGyu Park( @dongupak ) on 11. 9. 8..
//  Copyright 2011 DongGyu Park. ( http://Cocos2dDev.com/ )All rights reserved.
//
//  2011 경남 모바일 앱 공모전"에서 최우수 수상앱
//

#import "cocos2d.h"
#import "SceneManager.h"
//#import "IntroLogoScrollView.h"

enum {
	kTagLogoIntroBackground = 0,
	kTagLogoIntroMenu,
    kTagScrollView,
};

@interface LogoIntroLayer : CCLayer <UIScrollViewDelegate>{
    //IntroLogoScrollView *introLogoScrollView;
    UIScrollView *scrollView;
    UIImageView *imageView;
    UIImage *imageBG;
    
}

@property (nonatomic, retain) UIImage *imageBG;

-(void) menuMoveUpDown:(id)sender withOffset:(int)offset;
-(void) menuMove1:(id)sender;

@end
