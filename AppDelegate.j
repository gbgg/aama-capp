/*
 * 
 */

@import <Foundation/CPObject.j>
@import <AppKit/CPWebView.j>
@import "AamaDocumentController.j"
@import "AamaMenu.j"
@import "QueryController.j"

@implementation AppDelegate : CPObject
{
  @outlet CPWindow mainWindow;
  // @outlet QueryController _ctlrQuery;
}

- (void)awakeFromCib
{
  // CPLog("%@ awakeFromCib", self);
  // [theWindow setFrame:[CGPointFromString(@"200,200")]];
}

// - (void)loadQuery:(id)sender
// {
//   alert("loadQuery");
// }

// - application:openFile:
// {
  
// }

// - (BOOL) application:(CPApplication)app openURL:(CPURL)aURL
// {
//   CPLog("openURL");
// }

- (BOOL) applicationShouldOpenUntitledFile:(id)sender
{
  // CPLog("should open untitled file?");
  return NO;
}

- (void)applicationWillFinishLaunching:(CPNotification)aNotification
{
  // CPLog(@"%@ applicationWillFinishLaunching", self);
  //  CPSharedDocumentController = [[AamaDocumentController alloc] init];
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
  // CPLog(@"%@ applicationDidFinishLaunching", self);
  // Setup the menu bar.
  // [CPApp setMainMenu:menu];
  [CPApp setMainMenu:[[AamaMenu alloc] init]];
  [CPMenu setMenuBarVisible:YES];

    var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero()
						styleMask:CPBorderlessBridgeWindowMask],
      contentView = [theWindow contentView];

    [theWindow setFullPlatformWindow:YES];
    
    // var rect = [contentView bounds];
    // var bottomBar = [[CPBox alloc] initWithFrame:CGRectMake(CPRectGetMinX(rect), CPRectGetMaxY(rect)-20,
    // 							    CPRectGetWidth(rect), 20)];
    // // [bottomBar setBorderType:CPLineBorder];
    // // [bottomBar setBorderWidth:1];
    // [bottomBar setBackgroundColor:[CPColor colorWithHexString:@"ACB6BD"]]; //  lighter: B9C3C9"]];
    // // [bottomBar setAlpha:0];
    // [bottomBar setTag:66]; // mnemonic:  66 = bb
    // // [bottomBar setFrameOrigin:CGPointMake(0, 200)];
    // [contentView addSubview:bottomBar];

    [theWindow orderFront:self];

  // [CPApp sendAction:@selector(show:)
  // 		 to:catMgr
  // 	       from:self];

}

- (BOOL)applicationShouldOpenUntitledFile
{
  CPLog(@"app deleg: app should open untitled file");
  return YES;
}

// - (void)saveDocument:(id)aSender
// {
//   CPLog(@"AppDelegate: saveDocument");
// }

// - (CFAction)performDelete:(id)sender
// {
//   CPLog(@"AppDelegate: delete");
// }

@end
