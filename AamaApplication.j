@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "AamaDocumentController.j"

@implementation AamaApplication : CPApplication
{
}

+ (AamaApplication)sharedApplication
{
  if (!CPApp)
    CPApp = [[AamaApplication alloc] init];
  // console.log("shared app");
  return CPApp;
}

- (void)finishLaunching
{
  CPLog(@"%@ finishLaunching", self);

  // TODO:  fetch user prefs

  _documentController = nil;
  _documentController = [[AamaDocumentController alloc] init];
  [super finishLaunching];

  [_documentController newMorphPropertyInspector:self];
  // [_documentController newCatalogManager:self];
  //// [_documentController setCatMgr:[[CatalogManager alloc] init]];
  //// [[_documentController catMgr] refresh];
  CPLog(@"%@ /finishLaunching", self);
}

- (void)setState:(int)theState forWindow:(CPWindow)theWindow
{
  // CPLog(@"%@ setState %@ for win %@ titled %@", self, theState, theWindow, [theWindow title]);
  var menu = [self mainMenu];
  var winmenu = [menu itemWithTitle:@"Window"];
  var winsubmenu = [winmenu submenu];
  var item = [winsubmenu itemWithTitle:[theWindow title]];
  if ( ! item ) return;
  [item setState:theState];
  // CPLog(@"/%@ setState %@ for win %@", self, theState, theWindow);
}

- (void)addWindowsItem:(NSWindow *)aWindow title:(NSString *)aString filename:(BOOL)isFilename
{
  // CPLog(@"%@/ addWindowsItem win %@ wintitle %@ title %@ isFilename? %@", self, aWindow, [aWindow title], aString, isFilename);
  var menu = [self mainMenu];
  var winmenu = [menu itemWithTitle:@"Window"];
   var winsubmenu = [winmenu submenu];
   var i = [winsubmenu indexOfItemWithTitle:aString];
   if (i>=0) return;
  var item = [winsubmenu itemWithTag:@"mainWin"];
  [item setTag:nil];
  [item setState:CPOffState];
  [item setEnabled:YES];

  var mi = [[CPMenuItem alloc] initWithTitle:aString action:@selector(makeKeyAndOrderFront:) keyEquivalent:nil];
  [mi setTarget:aWindow];
  [mi setEnabled:YES];
  [mi setState:CPOnState];
  [mi setTag:@"mainWin"];
  [winsubmenu addItem:mi];
  // CPLog(@"/%@ addWindowsItem win %@ title %@ isFilename? %@", self, aWindow, aString, isFilename);
}

- (void)removeWindowsItem:(NSWindow *)aWindow
{
  // CPLog(@"%@/ removeWindowsItem %@", self, aWindow);
  var menu = [self mainMenu];
  var winmenu = [menu itemWithTitle:@"Window"];
  var winsubmenu = [winmenu submenu];
  var i = [winsubmenu indexOfItemWithTitle:[aWindow title]];
  if (i == CPNotFound) return;
  [winsubmenu removeItemAtIndex:i];
}
}

// - (BOOL)sendAction:(SEL)anAction to:(id)aTarget from:(id)aSender
// {
//   CPLog(@"%@: sendAction: %@ to %@ from %@", self, anAction, aTarget, aSender);
//   // var mainWin = [CPApp mainWindow];
//   // CPLog(@"main win: %@", mainWin);
//   [super sendAction:anAction to:aTarget from:aSender];
// }

@end
