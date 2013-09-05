/*
 * 
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
// @import "CPNotificationCenter.j"
// @import "PdgmToolbar.j"
@import "MICPBrowser.j"


// WINDOW DELEGATE: CatalogManagerWindowController

@implementation CatalogManagerWindow : CPWindow
{
  CPString path @accessors;
  CPString fileName @accessors;
  CPScrollView scrollView;
  MICPBrowser theBrowser @accessors;
  CPTextField txtFileName;
  // CPObject _delegate;

  BOOL isMaxed @accessors;
  CGRect saveFrame @accessors;
}

// + (id)docOpenPanel
// {
//     return [[CPOpenPanel alloc] init];
// }

//TODO:  make this initWithContentRect
- (id)setBrowserDelegate:(id)theDelegate
{
  CPLog(@"%@ setBrowserDelegate %@", self, theDelegate);
  [theBrowser setDelegate:theDelegate];
  [theBrowser setTarget:_delegate];
  // [theBrowser setAction:@selector(handleSelection:)];
}

- (id)init
{
  CPLog(@"%@: init", self);
  isMaxed = NO;


  //TODO:  the view stuff should go in a view controller
  // CPLog(@"%@    setting up browser (TODO: move to view controller)", self);
  var bwin = [[[CPApp mainWindow] platformWindow] nativeContentRect],
    center = CGPointMake(CGRectGetWidth(bwin)/2, CGRectGetHeight(bwin)/2),
    w = 600,
    h = 400,
    lmarg = 10,
    vmargin=10;

  var docs = [CPSharedDocumentController documents]; 
  var nWins = 0;
  for (var i=0; i<[docs count]; i++) {
    nWins = nWins + [[[docs objectAtIndex:i] windowControllers] count];
  }
  var menuBarH = [[CPApp mainMenu] menuBarHeight];

  var win = [super initWithContentRect:
		     // CGRectMake(center.x - w/2, menuBarH*3, w, h)
		     // CGRectMake( CGRectGetWidth(bwin)-w-menuBarH, nWins*menuBarH+menuBarH*2, w, h)
		     CGRectMake( 30 + nWins*10,
				 menuBarH*2.5 + nWins*menuBarH, w, h)
			     styleMask:CPTitledWindowMask
		   | CPMiniaturizableWindowMask
		   | CPMaximizableWindowMask
		   | CPRefreshableWindowMask
		   | CPClosableWindowMask
		   | CPResizableWindowMask];

  // mainMenu = [CPMenu new];
  // var CtxMenuItem = [[CPMenuItem alloc] initWithTitle:@"Open" action:nil keyEquivalent:nil];
  //{DEBUG
  var pwin = [win platformWindow];
  // CPLog(@"    ....self: %@, super: %@; pwin: %@", self, win, pwin);
  //DEBUG}
  
  var contentView = [self contentView];
  [contentView setBackgroundColor:[CPColor colorWithHexString:@"DADADA"]];
  var bounds = [contentView bounds],
    w = CGRectGetWidth(bounds),
    h = CGRectGetHeight(bounds),
    btnBoxHeight = 36,
    fnBoxHeight = 40;  // filename box
  
  // dataBox = [[CPView alloc] initWithFrame:
  // 			      CGRectMake(lmarg,vmargin, w-(2*lmarg), h-2*vmargin)];
  // 			      // CGRectMake(lmarg,vmargin, w-(2*lmarg), h-btnBoxHeight-fnBoxHeight-vmargin)];
  // [dataBox setTag:DATA];
  // [dataBox setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

  scrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(lmarg, vmargin, w-lmarg*2, h-3*vmargin)];
  [scrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [scrollView setBackgroundColor:[CPColor colorWithHexString:@"e0ecfa"]];
  [scrollView setAutohidesScrollers:YES];
  [scrollView setHasVerticalScroller:NO];

  theBrowser = [[MICPBrowser alloc] initWithFrame:[scrollView bounds]];
  [theBrowser setTag:OUTLINE];
  [theBrowser setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

  // [theBrowser setDelegate:_delegate];
  // [theBrowser setAction:@selector(fetchContent:)]; // single click
  // [theBrowser setDoubleAction:@selector(openDocument:)];
  // [theBrowser setTarget:_delegate];

  // [theBrowser setTarget:[AamaDocumentController sharedDocumentController]];
  
  var CtxMenu = [[CPMenu alloc] initWithTitle:@"Open"];
  [CtxMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Open" action:@selector(openDocument:) keyEquivalent:@"c"]];

  var mi;

  mi = [[CPMenuItem alloc] initWithTitle:@"Rename" action:@selector(rename:) keyEquivalent:@"r"];
  [mi setTag:@"rename"];
  [CtxMenu addItem:mi];
  
  mi = [[CPMenuItem alloc] initWithTitle:@"New Folder" action:@selector(newDoc:) keyEquivalent:@"f"];
  [mi setTag:@"folder"];
  [CtxMenu addItem:mi];

  mi = [[CPMenuItem alloc] initWithTitle:@"New Paradigm" action:@selector(newDoc:) keyEquivalent:@"f"];
  [mi setTag:@"pdgm"];
  [CtxMenu addItem:mi];

  mi = [[CPMenuItem alloc] initWithTitle:@"New Webpage" action:@selector(newWebpage:) keyEquivalent:@"w"];
  [mi setTag:@"webpage"];
  [CtxMenu addItem:mi];

  mi = [[CPMenuItem alloc] initWithTitle:@"Move to Trash" action:@selector(trash:) keyEquivalent:@"v"];
  [mi setTag:@"trash"];
  [CtxMenu addItem:mi];
  
  // [CtxMenuItem setSubmenu:CtxMenu];
  // [mainMenu addItem:CtxMenuItem];

  [theBrowser setMenu:CtxMenu];

  [scrollView setDocumentView:theBrowser];
    
  [contentView addSubview:scrollView];

  // CPLog(@/"%@    setting up browser (TODO: move to view controller", self);
  // CPLog(@"%@ /init", self);
  return self;
}

// - (id)initWithContentRect:(CGRect)aContentRect styleMask:(unsigned int)aStyleMask
// {
//   [super initWithContentRect:aContentRect styleMask:aStyleMask];
//   return [self init];
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
    CPLog(@"%@ selectedPath for %@", self, [theBrowser selectedItem]);
    return [theBrowser selectedItem];
}

- (CFAction)openDocument:(id)aSender
{
    CPLog(@"%@ openDocument", self);
    [CPApp sendAction:@selector(openSelectedDocument:)
		   to:[AamaDocumentController sharedDocumentController]
		 from:self];
}

- (id)initWithFrame:(CGRect)aFrame
{
  // [super initWithFrame:aFrame] styleMask:CPDocModalWindowMask];
  return [self init];
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

- (MIBrowser)browser
{
  return theBrowser;
}

- (void)resume:(id)sender
{
  // CPLog(@"resuming");
}

////////////////////////////////////////////////////////////////
// @override
- (void)performMiniaturize:(id)aSender
{
  // CPLog(@"CatalogManagerWindow performMiniaturize");
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
  // CPLog(@"%@: CatalogManagerWindow performMaximize", self);
  [self maximize:self];
}

- (void)maximize:(id)sender
{
  // CPLog(@"%@: maximize", self);
  [[CPNotificationCenter defaultCenter] postNotificationName:CPWindowWillMaximizeNotification object:self];
  //NB:  cappuccino implementation of -izing is only for non-browser environments
  //MI [[self platformWindow] maximize:sender];
  //TODO:  miniaturize window in browser env

  var frame,
    origin;
  if (isMaxed) {
    // CPLog(@"    restoring window size and pos");
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

  // [self makeKeyAndOrderFront];
  [[CPNotificationCenter defaultCenter] postNotificationName:CPWindowDidMaximizeNotification object:self];
  _isMaximized = YES;
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
  // CPLog(@"CatalogManagerWindow refresh");
  // [_delegate refresh:aSender];
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
  // CPLog(@"%@: refreshButtonPush", self);
  // 1. find window for theDoc
  [super refreshButtonPush:self];
}

- (CFAction)refreshButtonPop:(id)theDoc
{
  // CPLog(@"%@: refreshButtonPop", self);
  // 1. find window for theDoc
  [super refreshButtonPop:self];
}

- (CFAction)saveDocumentAs:(id)theDoc
{
  CPLog(@"%@: saveDocumentAs: %@", self, theDoc);
}

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
  if ( [item valueForKey:@"FileType"] == "file" ) {
    [self setFileName:[item valueForKey:@"BaseName"]];
  }

  var result = @"",
    theItem = item,
    thePath = ""; // [theItem valueForKey:@"BaseName"];
  while (theItem) {
    if ([theItem valueForKey:@"Type"] == "COLLECTION") {
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
  // CPLog(@"CatalogManager: pathForItem %@"); //, item);
  path = [item valueForKey:@"URI"];
  // CPLog(@"CatalogManager item url: %@", path);
  return path;
}

- (void)outlineViewSelectionDidChange:(CPNotification)notification;
{//        Called when the user changes the selection of the outlineview.
  CPLog(@"outlineViewSelectionDidChange ");
}

// - (void)resignKeyWindow
// {
//   CPLog(@"%@ resignKeyWindow", self);
//   [CPApp setState:CPOffState forWindow:self];
//   [super resignKeyWindow];
// }

// - (void)makeKeyAndOrderFront:(id)aSender
// {
//   CPLog(@"%@ makeKeyAndOrderFront", self);
//   CPLog(@"    delegate: %@", [self delegate]);
//   CPLog(@"    main win: %@", [CPApp mainWindow]);
//   CPLog(@"    key win:  %@", [CPApp keyWindow]);
//   [super makeKeyAndOrderFront:aSender];
//   CPLog(@"    main win: %@", [CPApp mainWindow]);
//   CPLog(@"    key win:  %@", [CPApp keyWindow]);
//   CPLog(@"/%@ makeKeyAndOrderFront", self);
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

// - (void)orderFront:(id)aSender
// {
//   CPLog(@"%@ orderFront", self);
//   [super orderFront:aSender];
// }

- (void)performClose:(id)sender
{
  CPLog(@"CatalogManager:performClose:sender");
  [super performClose:sender];
}

//**************************************************************
- (void)windowDidLoad
{
  CPLog(@"%@: windowDidLoad", self);
}

- (BOOL)validateMenuItem:(CPMenuItem)theMenuItem
{
  // CPLog(@"%@ validateMenuItem: %@; action %@", self, [theMenuItem title], [theMenuItem action]);
  // CPLog(@"    main win: %@", [CPApp mainWindow]);
  // CPLog(@"    key win:  %@", [CPApp keyWindow]);
  // CPLog(@"    delegate: %@", [self delegate]);

  if ([theMenuItem action] == @selector(performClose:)) return YES;
  if ([theMenuItem action] == @selector(maximize:)) return YES;
  if ([theMenuItem action] == @selector(openDocument:)) return YES;
  if ([theMenuItem action] == @selector(saveDocument:)) return NO;
  if ([theMenuItem action] == @selector(saveDocumentAs:)) return NO;
  if ([theMenuItem action] == @selector(removeDocument:)) return NO;
  if ([theMenuItem action] == @selector(makeKeyAndOrderFront:)) return YES;
  return NO;
}

@end
