#import "DashPlugin.h"
#import "CodaPlugInsController.h"

@interface DashPlugin ()

- (id)initWithController:(CodaPlugInsController*)inController;

@end


@implementation DashPlugin

- (id)initWithPlugInController:(CodaPlugInsController*)aController bundle:(NSBundle*)aBundle
{
    return [self initWithController:aController];
}

- (id)initWithPlugInController:(CodaPlugInsController*)aController plugInBundle:(NSObject <CodaPlugInBundle> *)plugInBundle
{
    return [self initWithController:aController];
}

- (id)initWithController:(CodaPlugInsController*)inController
{
	if ( (self = [super init]) != nil )
	{
		controller = inController;
        [controller registerActionWithTitle:@"Look Up in Dash" underSubmenuWithTitle:nil target:self selector:@selector(lookUp:) representedObject:nil keyEquivalent:@"^h" pluginName:@"Dash"];
	}
    
	return self;
}

- (NSString*)name
{
	return @"Dash";
}

- (BOOL)dashIsInstalled
{
    if(![[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier:@"com.kapeli.dashdoc"] && ![[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier:@"com.kapeli.dash"] && ![[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier:@"com.kapeli.dashbeta"])
    {
        if([[NSAlert alertWithMessageText:@"Dash" defaultButton:@"Download Dash" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@"Dash is not installed. Please download Dash."] runModal] == NSAlertDefaultReturn)
        {
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://kapeli.com/dash"]];
        }
        return NO;
    }
    return YES;
}

- (void)lookUp:(id)sender
{
    if([self dashIsInstalled])
    {
        CodaTextView *textView = [controller focusedTextView:self];
        if(textView)
        {
            NSString *searchString = [textView selectedText];
            if(!searchString || !searchString.length)
            {
                @try {
                    NSRange wordRange = [textView currentWordRange];
                    if(wordRange.location != NSNotFound)
                    {
                        searchString = [textView stringWithRange:wordRange];
                        if([searchString rangeOfCharacterFromSet:[NSCharacterSet alphanumericCharacterSet]].location != NSNotFound)
                        {
                            NSCharacterSet *trimSet = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
                            searchString = [searchString stringByTrimmingCharactersInSet:trimSet];
                        }
                    }
                    else
                    {
                        NSBeep();
                    }
                }
                @catch(NSException *exception) { NSBeep(); }
            }
            if(searchString && searchString.length)
            {
                searchString = [searchString stringByReplacingOccurrencesOfString:@"<" withString:@""];
                searchString = [searchString stringByReplacingOccurrencesOfString:@">" withString:@""];
                searchString = [searchString stringByReplacingOccurrencesOfString:@"/" withString:@""];
                if(searchString.length)
                {
                    NSPasteboard *pboard = [NSPasteboard pasteboardWithUniqueName];
                    [pboard setString:searchString forType:NSStringPboardType];
                    NSPerformService(@"Look Up in Dash", pboard);
                }
                else
                {
                    NSBeep();
                }
            }
        }
        else
        {
            NSBeep();
        }
    }
}

@end