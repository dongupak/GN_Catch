#import "Cloud.h"


@implementation Cloud
-(id)initWithFile:(NSString *)filename {
	if((self = [super initWithFile:filename])) {
	}
	return self;
}

-(void)setting:(BOOL)d {
	direction = d;
	spd = (float)arc4random()/0x100000000;
	spd += 0.5f;
	NSLog(@"%f", spd);
	if(direction == TRUE) {
		spd = -spd;
		self.position = ccp(320+self.contentSize.width/2, arc4random()%480+200);
	} else {
		self.position = ccp(-self.contentSize.width/2, arc4random()%480+200);
	}
}

-(void)move {
	[self schedule:@selector(move_move)];
}
-(void)move_move {
	self.position = ccp(self.position.x + spd, self.position.y);
}

-(BOOL)getDirection {return direction;}

-(void)dealloc {
	[super dealloc];
}
@end
