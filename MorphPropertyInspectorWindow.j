/*
 * 
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
// @import "Constants.j"
@import "MorphPropertyInspectorWindowController.j"
@import "MICPBrowser.j"

COLLECTION=@"COLLECTION"

@implementation MorphPropertyInspectorWindow : CPWindow
{
  CPString path @accessors;
  CPString fileName @accessors;
  CPScrollView scrollView;
  // CPBrowser theBrowser @accessors;
  MICPBrowser theBrowser @accessors;
  CPTextField txtFileName;

  BOOL isMaxed;
  CGRect saveFrame;
}

// + (id)docOpenPanel
// {
//     return [[CPOpenPanel alloc] init];
// }

- (id)init
{
}

- (id)initWithContentRect:(CGRect)aContentRect styleMask:(unsigned int)aStyleMask
{
  // CPLog(@"%@: initWithContentRect %@", self, aContentRect);

  [super initWithContentRect:aContentRect styleMask:aStyleMask];
  
  var bwin = [[[CPApp mainWindow] platformWindow] nativeContentRect],
    center = CGPointMake(CGRectGetWidth(bwin)/2, CGRectGetHeight(bwin)/2),
    w = 600,
    h = 400,
    lmarg = 10,
      vmargin=10,
      toolbarh=0;

  // var n = [[CPSharedDocumentController documents] count];
  // var menuBarH = [[CPApp mainMenu] menuBarHeight];
  // _window = [[MorphPropertyInspectorWindow alloc] initWithContentRect:CGRectMake( (n-1)*menuBarH/2, (n+2)*menuBarH, 800, 400)


  // var win = [super initWithContentRect:
  // 		     CGRectMake(center.x - .75*w, 100+vmargin, w, h+toolbarh)
  // 				  styleMask:
  // 		     CPTitledWindowMask
  // 		   | CPMiniaturizableWindowMask
  // 		   | CPMaximizableWindowMask
  // 		   | CPRefreshableWindowMask
  // 		   | CPClosableWindowMask
  // 		   | CPResizableWindowMask];


  // mainMenu = [CPMenu new];
  // var CtxMenuItem = [[CPMenuItem alloc] initWithTitle:@"Open" action:nil keyEquivalent:nil];
  //{DEBUG
  // var pwin = [win platformWindow];
  // CPLog(@"    ....self: %@, super: %@; pwin: %@", self, win, pwin);
  //DEBUG}
  
  var contentView = [self contentView];
  [contentView setBackgroundColor:[CPColor colorWithHexString:@"DADADA"]];
  var bounds = [contentView bounds],
    w = CGRectGetWidth(bounds),
    h = CGRectGetHeight(bounds),
      toolbarh = 0,
    btnBoxHeight = 36,
    fnBoxHeight = 40;  // filename box
  
  // dataBox = [[CPView alloc] initWithFrame:
  // 			      CGRectMake(lmarg,vmargin, w-(2*lmarg), h-2*vmargin)];
  // 			      // CGRectMake(lmarg,vmargin, w-(2*lmarg), h-btnBoxHeight-fnBoxHeight-vmargin)];
  // [dataBox setTag:DATA];
  // [dataBox setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

  [self setDelegate:self];

  scrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(lmarg, vmargin, w-lmarg*2, h-3*vmargin-toolbarh)];
  [scrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [scrollView setBackgroundColor:[CPColor colorWithHexString:@"e0ecfa"]];
  [scrollView setAutohidesScrollers:YES];
  [scrollView setHasVerticalScroller:NO];

  theBrowser = [[MICPBrowser alloc] initWithFrame:[scrollView bounds]];
  [theBrowser setTag:OUTLINE];
  [theBrowser setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

  // [theBrowser setAction:@selector(openDocument:)]; // single click
  [theBrowser setDoubleAction:@selector(openDocument:)];
  [theBrowser setTarget:nil];
  // [theBrowser setTarget:[AamaDocumentController sharedDocumentController]];
  
  var CtxMenu = [[CPMenu alloc] initWithTitle:@"Open"];
  [CtxMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Open" action:@selector(openDocument:) keyEquivalent:@"c"]];
  [CtxMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Move to Trash" action:@selector(trashFile:) keyEquivalent:@"v"]];
  // [CtxMenuItem setSubmenu:CtxMenu];
  // [mainMenu addItem:CtxMenuItem];

  [theBrowser setMenu:CtxMenu];

  [scrollView setDocumentView:theBrowser];
    
  [contentView addSubview:scrollView];

  // CPLog(@"/%@ init", self);
  return self;
}

// - (id)initWithContentRect:(CGRect)aContentRect styleMask:(unsigned int)aStyleMask
// {
//   [super initWithContentRect:aContentRect styleMask:aStyleMask];
//   return [self init];
// }

- (void) setDelegate:(CPObject)aDelegate
{
  [super setDelegate:aDelegate];
  // [catToolbar setDelegate:_delegate];
  // [catToolbar setTarget:_delegate];
  [theBrowser setDelegate:_delegate];
}

//@delegate
-(BOOL)windowShouldClose:(id)window
{
  CPLog(@"%@ windowShouldClose", self);
  return YES;
}

// - (void)shouldCloseWindowController:(CPWindowController)controller
// 			   delegate:(id)delegate
// 		shouldCloseSelector:(SEL)selector
// 			contextInfo:(Object)info
// {
//   CPLog(@"%@ shouldCloseWindowController %@ delegate %@ selector %@", self, controller, delegate, selector);
//   [super shouldCloseWindowController:controller
// 			    delegate:delegate
// 		 shouldCloseSelector:selector
// 			 contextInfo:info];
// }

- (void)showData
{
    // CPLog(@"%@: showData", self);
    // var dataView = [[self contentView] viewWithTag:DATA];
    // [[self contentView] replaceSubview:dataView with:scrollView];
    // [theBrowser setBackgroundColor:[CPColor colorWithHexString:@"FF0000"]];
    // highlight first row of first col
    [theBrowser selectRow:0 inColumn:0];
    [theBrowser _column:1 clickedRow:0];
    // [theBrowser reloadColumn:1];
}

- (CPString)selectedItem
{
    // CPLog(@"%@ selectedPath for %@", self, [theBrowser selectedItem]);
    return [theBrowser selectedItem];
}

- (CFAction)openDocument:(id)aSender
{
    // CPLog(@"%@ openDocument", self);
    [CPApp sendAction:@selector(openSelectedDocument:)
		   to:[AamaDocumentController sharedDocumentController]
		 from:self];
}

- (CPString)iri
{
  return [self path] + [self fileName];
}

- (CPString)fileName
{
  return [txtFileName objectValue];
}

- (void)setFileName:(CPString)theFileName
{
  [txtFileName setObjectValue:theFileName];
}

// - (MIBrowser)browser
// {
//   return theBrowser;
// }

- (void)resume:(id)sender
{
  // CPLog(@"resuming");
}

////////////////////////////////////////////////////////////////
// @override
- (void)performMiniaturize:(id)aSender
{
  CPLog(@"MorphPropertyInspectorWindow performMiniaturize");
  [super miniaturize:self]; // @override
}

////////////////////////////////////////////////////////////////
-(CFAction)windowWillMiniaturize:(id)sender
{
    if (sender == self)
	CPLog(@"windowWillMiniaturize");
}
-(CFAction)windowDidMiniaturize:(id)sender
{
    if (sender == self)
	CPLog(@"windowDidMiniaturize");
}
-(CFAction)windowDidDeminiaturize:(id)sender
{
    if (sender == self)
      CPLog(@"%@: windowDidDeminiaturize", self);
}

////////////////////////////////////////////////////////////////
// @override
- (void)performMaximize:(id)aSender
{
  CPLog(@"%@: MorphPropertyInspectorWindow performMaximize", self);
  [self maximize:self];
}

- (void)maximize:(id)sender
{
  CPLog(@"%@: maximize", self);
    [[CPNotificationCenter defaultCenter] postNotificationName:CPWindowWillMaximizeNotification object:self];
    //NB:  cappuccino implementation of -izing is only for non-browser environments
    //MI [[self platformWindow] maximize:sender];
    //TODO:  miniaturize window in browser env

    var frame,
      origin;
    if (isMaxed) {
      CPLog(@"    restoring window size and pos");
      frame = saveFrame;
      origin = frame.origin;
      isMaxed = NO;
    } else {
      saveFrame = [self frame];
      var rect = [[[CPApp mainWindow] platformWindow] nativeContentRect];
      var menu = [CPApp mainMenu];
      origin = CGPointMake(0,[menu menuBarHeight]);
      frame = CGRectInset(rect, 0, [menu menuBarHeight]/2);
      isMaxed = YES;
    }
    [self setFrame:frame];
    [self setFrameOrigin:origin];
    [self orderFront];

    // [self makeKeyAndOrderFrontWindows];
    [[CPNotificationCenter defaultCenter] postNotificationName:CPWindowDidMaximizeNotification object:self];
    _isMaximized = YES;
  CPLog(@"%@: maximize", self);
}

-(CFAction)windowWillMaximize:(id)sender
{
    if (sender == self)
      CPLog(@"%@: windowWillMaximize", self);
}
-(CFAction)windowDidMaximize:(id)sender
{
    if (sender == self)
      CPLog(@"%@: windowDidMaximize", self);
}

////////////////////////////////////////////////////////////////
// @override
/*!
    Restores a maximized window to it's original size.
*/
- (void)demaximize:(id)sender
{
    [[self platformWindow] demaximize:sender];
    [[CPNotificationCenter defaultCenter] postNotificationName:CPWindowDidDemaximizeNotification object:self];
    _isMaximized = NO;
}

-(CFAction)windowWillDemaximize:(id)sender
{
    if (sender == self)
      CPLog(@"%@: windowWillMaximize", self);
}
-(CFAction)windowDidDemaximize:(id)sender
{
    if (sender == self)
      CPLog(@"%@: windowDidDemaximize", self);
}

////////////////////////////////////////////////////////////////
// @override
- (void)refresh:(id)aSender
{
  CPLog(@" refresh", self);
  [_delegate refresh:aSender];
}

-(CFAction)windowWillRefresh:(id)sender
{
    // if (sender == self)
    //   CPLog(@"%@: windowWillRefresh", self);
}
-(CFAction)windowDidRefresh:(id)sender
{
    // if (sender == self)
    //   CPLog(@"%@: windowDidRefresh", self);
}

- (void)unhighlightButtonTimerDidFinish:(id)sender
{
  // CPLog(@"%@: unhighlightButtonTimerDidFinish", self);
    // [self highlight:NO];
}

- (CFAction)refreshButtonPush:(id)theDoc
{
  CPLog(@"%@: refreshButtonPush", self);
  // 1. find window for theDoc
  [super refreshButtonPush:self];
}

- (CFAction)refreshButtonPop:(id)theDoc
{
  // CPLog(@"%@: refreshButtonPop", self);
  // 1. find window for theDoc
  [super refreshButtonPop:self];
}

////////////////////////////////////////////////////////////////
// @override
// - (void)performClose:(id)sender
// {
//   CPLog(@"%@: performClose:sender", self);
//   [super performClose:sender];
// }

////////////////////////////////////////////////////////////////
// text field handlers
- (void)saveFileName:(id)sender
{
  CPLog(@"saveFileName");
}
// - (BOOL)controlTextShouldBeginEditing:(NSText *)textObject
// {
//   CPLog(@"textShouldBeginEditing");
// }

- (void)controlTextDidBeginEditing:(NSNotification *)aNotification
{
  CPLog(@"textDidBeginEditing");
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
  CPLog(@"textDidChange to %@", [txtFileName objectValue]);
  [self setFileName:[txtFileName objectValue]];
}

- (void)controlTextDidEndEditing:(NSNotification *)aNotification
{
  CPLog(@"textDidEndEditing");
}

- (void)controlTextDidFocus:(NSNotification *)aNotification
{
  CPLog(@"textFieldDidFocus");
}
- (void)controlTextDidBlur:(NSNotification *)aNotification
{
  CPLog(@"textFieldDidBlur");
}

// - (BOOL)textShouldEndEditing:(NSText *)textObject
// {
//   CPLog(@"textShouldEndEditing");
// }

////////////////////////////////////////////////////////////////
// outline delegate methods
- (void)outlineViewSelectionIsChanging:(CPNotification)notification
{//        Called when the user changes the selection of the outlineview, but before the change is made.
  CPLog(@"outlineViewSelectionIsChanging");
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
  CPLog(@"%@ outlineView: shouldSelectItem", self);
  [[[self contentView] viewWithTag:SAVE] setEnabled:YES];
  if ( [item valueForKey:@"FileType"] == kINDIVIDUAL ) {
    [self setFileName:[item valueForKey:@"BaseName"]];
  }

  var result = @"",
    theItem = item,
    thePath = ""; // [theItem valueForKey:@"BaseName"];
  while (theItem) {
    if ([theItem valueForKey:@"Type"] == COLLECTION) {
      thePath = [theItem valueForKey:@"BaseName"] + "/" + thePath;
    }
    theItem = [outlineView parentForItem:theItem];
  }
  [self setPath:@"/" + thePath];
  CPLog(@"path: " + [self path]);
  CPLog(@"filename: " + [self fileName]);
  return YES;
}

- (CPString)pathForItem:(id)item
{
  // CPLog(@": pathForItem %@"); //, item);
  path = [item valueForKey:@"URI"];
  // CPLog(@"    item url: %@", path);
  return path;
}

- (void)outlineViewSelectionDidChange:(CPNotification)notification;
{//        Called when the user changes the selection of the outlineview.
  CPLog(@"outlineViewSelectionDidChange ");
}

- (CFAction)removeDocument:(id)theDoc
{
  CPLog(@"%@: removeDocument: %@", self, theDoc);
}

// - (void)orderFront:(id)aSender
// {
//   CPLog(@"%@ orderFront", self);
//   [super orderFront:aSender];
// }

// - (void)makeKeyAndOrderFront:(id)aSender
// {
//   CPLog(@"%@ makeKeyAndOrderFront", self);
//   [super makeKeyAndOrderFront:aSender];
// }

// - (void)makeKeyWindow
// {
//   CPLog(@"%@ makeKeyWindow", self);
//   [super makeKeyWindow];
// }

// - (void)becomeMainWindow
// {
//   CPLog(@"%@ becomeMainWindow", self);
//   CPLog(@"    delegate: %@", [self delegate]);
//   CPLog(@"    main win: %@", [CPApp mainWindow]);
//   CPLog(@"    key win:  %@", [CPApp keyWindow]);
//   [super becomeMainWindow];
//   [CPApp setState:CPOnState forWindow:self];
//   CPLog(@"    main win: %@", [CPApp mainWindow]);
//   CPLog(@"    key win:  %@", [CPApp keyWindow]);
// }

// - (void)resignKeyWindow
// {
//   CPLog(@"%@ resignKeyWindow", self);
//   [CPApp setState:CPOffState forWindow:self];
//   [super resignKeyWindow];
// }

// -(void)windowDidResignMain:(CPNotification)notification
// {
//   CPLog(@"%@ windowDidResignMain");
//   [CPApp setState:CPOffState forWindow:self];
// }

// -(void)windowDidBecomeMain:(CPNotification)notification
// {
//   CPLog(@"%@ windowDidBecomeMain");
//   [CPApp setState:CPOnState forWindow:self];
// }

- (BOOL)validateMenuItem:(CPMenuItem)theMenuItem
{
  // CPLog(@"%@ validateMenuItem: %@; action %@", self, [theMenuItem title], [theMenuItem action]);
  // CPLog(@"    main win: %@", [CPApp mainWindow]);
  // CPLog(@"    key win:  %@", [CPApp keyWindow]);
  // CPLog(@"    delegate: %@", [self delegate]);

  if ([theMenuItem action] == @selector(performClose:)) return YES;
  if ([theMenuItem action] == @selector(minimize:)) return YES;
  if ([theMenuItem action] == @selector(maximize:)) return YES;
  if ([theMenuItem action] == @selector(removeDocumenent:)) return YES;
  if ([theMenuItem action] == @selector(makeKeyAndOrderFront:)) return YES;
  return NO;
}

@end
