#import <Cocoa/Cocoa.h>
#import "CodaPluginsController.h"

@class CodaPlugInsController;

@interface DashPlugin : NSObject <CodaPlugIn>
{
	CodaPlugInsController* controller;
}

@end
