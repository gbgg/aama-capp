/*
 * 
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "PdgmDocWinController.j"
// @import "PdgmToolbar.j"

var ActionToolbarItemIdentifier = @"ActionToolbarItemIdentifier",
  AddToolbarItemIdentifier = @"AddToolbarItemIdentifier",
  RemoveToolbarItemIdentifier = @"RemoveToolbarItemIdentifier";

@implementation PdgmDocWindow : CPWindow
{
  CPTabView tabView @accessors;
  BOOL isMaxed @accessors;
  CGRect savedFrame @accessors;
  CGRect savedPdgmGridFrame @accessors;
  CGRect savedDatatableFrame @accessors;
}

- (id)initWithContentRect:(CGRect)aContentRect styleMask:(unsigned int)aStyleMask
{
  CPLog(@"%@: initWithContentRect", self);
  self = [super initWithContentRect:aContentRect styleMask:aStyleMask];
  [self setBackgroundColor:[CPColor colorWithHexString:@"D5E1E8"]];
  // [self setDelegate:self];
  return self;
}

//TODO:  refactor this to:  init, then setDocument?
// why?  windows do not track docs; that's the win controller's job
- (id)initWithDocumentX:(id)theDoc
{
  CPLog(@"%@: initWithDocument: %@", self, theDoc);
  // thePdgmDoc = theDoc;
  // var docs = [[CPSharedDocumentController documents] count];
  // [self initWithContentRect: CGRectMake((docs*20),(50+docs*24), 600, 320)
  // 		   styleMask:
  // 	    CPTitledWindowMask
  // 	| CPMiniaturizableWindowMask
  // 	| CPMaximizableWindowMask
  // 	| CPRefreshableWindowMask
  // 	| CPClosableWindowMask
  // 	| CPResizableWindowMask];
  // [self setBackgroundColor:[CPColor colorWithHexString:@"D5E1E8"]];
  // [self setTitle:@"Aama Paradigm Window"];
  // [self setDelegate:self];

  var contentView = [self contentView];
  [contentView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

  var boxData = [[CPBox alloc] initWithFrame:CGRectMake(10,10, 580, 260)];
  [boxData setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [boxData setTag:@"rootView"];
  [boxData setBorderColor:[CPColor blueColor]];
  [boxData setBorderWidth:2];
  [boxData setBorderType:CPBezelBorder];

  [contentView addSubview:boxData];

  return self;
}

// - (void)keyDown:(CPEvent)theEvent
// {
//   CPLog(@"PdgmDocWindow keyDown");
//   [super keyDown:theEvent];
// }

// //{DEBUG
// - (BOOL)performKeyEquivalent:(CPEvent)anEvent
// {
//   CPLog(@"PdgmDocWindow performKeyEquivalent");
//   return YES;
//   // return [super performKeyEquivalent:anEvent];
//   // return [[self contentView] performKeyEquivalent:anEvent];
// }
// //DEBUG}

- (void)addLocation {
  CPLog(@"addLocation");
  // if (!locations) {
  //   locations = [[CPArray alloc] init];
  // }

  // loc = [[Location alloc] init];
  // [loc setDescription:@""];
  // [loc setPosition:([locations count] + 1)];
  // [locations addObject:loc];
  // [locationListView setContent:locations];
  // [locationListView reloadContent];
  // [locationListView setSelectionIndexes:[CPIndexSet indexSetWithIndex:([locations count] - 1)]];
}

- (void)removeLocation {
  CPLog(@"removeLocation");
  // if (![self selectedLocation]) {
  //   return;
  // }

  // if (confirm('Are you sure?'))
  //   {
  //     if ([[self selectedLocation] isNewRecord]) {
  // 	[self removeSelectedLocation];
  //     } else {
  // 	//we'll implement this later
  //     }
  //   }
}

- (void)removeSelectedLocation {
  CPLog(@"removeSelectedLocation");
  // [locations removeObjectAtIndex:[[locationListView selectionIndexes] firstIndex]];
  // [locationListView setContent:locations];
  // [locationListView reloadContent];
  // [locationListView setSelectionIndexes:[CPIndexSet indexSetWithIndex:([locations count] - 1)]];
}

// Return an array of toolbar item identifier (all the toolbar items that may be present in the toolbar)
- (CPArray)toolbarAllowedItemIdentifiers:(CPToolbar)aToolbar
{
  return [ActionToolbarItemIdentifier];
}

// Return an array of toolbar item identifier (the default toolbar items that are present in the toolbar)
- (CPArray)toolbarDefaultItemIdentifiers:(CPToolbar)aToolbar
{
  return [ActionToolbarItemIdentifier];
}

- (CPToolbarItem)toolbar:(CPToolbar)aToolbar itemForItemIdentifier:(CPString)anItemIdentifier willBeInsertedIntoToolbar:(BOOL)aFlag
{
  var toolbarItem = [[CPToolbarItem alloc] initWithItemIdentifier:anItemIdentifier];
  if (anItemIdentifier == ActionToolbarItemIdentifier)
    {
      var mainBundle = [CPBundle mainBundle];
      var bundle = [CPBundle bundleForClass:[CPWindow class]];

      CPLog(@"bundle path %@", [bundle bundlePath]);
      var image = [[CPImage alloc]
		    initWithContentsOfFile:[bundle
					     pathForResource:@"action_button.png"]
				      size:CPSizeMake(30, 25)];
      var highlighted = [[CPImage alloc]
      			  initWithContentsOfFile:[bundle pathForResource:@"action_button.png"]
      					    size:CPSizeMake(30, 25)];
      
      [toolbarItem setImage:image];
      [toolbarItem setAlternateImage:highlighted];

      // [toolbarItem setTarget:self];
      // [toolbarItem setAction:@selector(remove:)];
      // [toolbarItem setLabel:"Remove Photo List"];
      
      [toolbarItem setMinSize:CGSizeMake(22, 14)];
      [toolbarItem setMaxSize:CGSizeMake(22, 14)];
    }
    
  return toolbarItem;
}

////////////////////////////////////////////////////////////////
- (void)showData
{
  // CPLog(@"%@: showData", self);
  //TODO:  ??
  // var dataView = [[self contentView] viewWithTag:DATA];
  // [[self contentView] replaceSubview:dataView with:scrollView];
  // [theBrowser setBackgroundColor:[CPColor colorWithHexString:@"FF0000"]];
  // highlight first row of first col
  // [theBrowser selectRow:0 inColumn:0];
  // [theBrowser _column:1 clickedRow:0];
  // [theBrowser reloadColumn:1];
}

////////////////////////////////////////////////////////////////
// - (CFAction)splitHorizontal:(id)theSender
// {
//   CPLog(@"%@: splitHorizontal", self);
// }

// - (CFAction)splitVertical:(id)theSender
// {
//   CPLog(@"%@: splitVertical", self);
// }

////////////////////////////////////////////////////////////////
// @override
- (void)performMiniaturize:(id)aSender
{
  CPLog(@"PdgmDocWindow performMiniaturize");
  [super miniaturize:self]; // @override
}

- (void)miniaturize:(id)sender
{
  CPLog(@"PdgmDocWindow:miniaturize");
  [super miniaturize:sender];
}

////////////////////////////////////////////////////////////////
- (CFAction)performRefresh:(id)sender
{
  // CPLog(@"%@: performRefresh, sender: %@", self, sender);
  [self refreshButtonPush:sender];
  [super refresh:self];
  // [_windowController refresh:self];
}

- (CFAction)cancelRefresh:(id)sender
{
  // CPLog(@"%@: cancelRefresh, sender: %@", self, sender);
  [self refreshButtonPop:sender];
  // [super refresh:self];
  // [_windowController refresh:self];
}

- (CFAction)refreshButtonPush:(id)theDoc
{
  CPLog(@"%@: refreshButtonPush", self);
  [super refreshButtonPush:self];
}

////////////////////////////////////////////////////////////////
-(CFAction)windowWillMaximize:(id)sender
{
  CPLog(@"%@: windowWillMaximize", self);
}
////
-(CFAction)windowWillMiniaturize:(id)sender
{
  CPLog(@"windowWillMiniaturize");
}
-(CFAction)windowDidMiniaturize:(id)sender
{
  CPLog(@"windowDidMiniaturize");
}
-(CFAction)windowDidDeminiaturize:(id)sender
{
  CPLog(@"windowDidDeminiaturize");
}

////////////////////////////////////////////////////////////////
- (void)performMaximize:(id)aSender
{
  CPLog(@"PdgmDocWindow performMaximize");
  [self maximize:self];
}

- (void)maximize:(id)sender
{
  CPLog(@"%@: maximize", self);
    [[CPNotificationCenter defaultCenter] postNotificationName:CPWindowWillMaximizeNotification object:self];
    //NB:  cappuccino implementation of -izing is only for non-browser environments
    //MI [[self platformWindow] maximize:sender];
    //TODO:  miniaturize window in browser env

    var tvi = [tabView selectedTabViewItem];
    CPLog(@"    tvi %@", tvi);

    var frame,
      origin;
    if (isMaxed) {
      CPLog(@"    restoring window size and pos");
      if ( [tvi label] == @"Datatable" ) {
	CPLog(@"    restoring datatable view");
	frame = savedDatatableFrame;
	origin = frame.origin;
	isMaxed = NO;
      }
      if ( [tvi label] == @"Paradigm" ) {
	CPLog(@"    restoring paradigm view");
	frame = savedPdgmGridFrame;
	origin = frame.origin;
	isMaxed = NO;
      }
    } else {
      if ( [tvi label] == @"Datatable" ) {
	CPLog(@"    maximizing datatable view");
	savedDatatableFrame = [self frame];
	var rect = [[[CPApp mainWindow] platformWindow] nativeContentRect];
	var menu = [CPApp mainMenu];
	origin = CGPointMake(0,[menu menuBarHeight]);
	frame = CGRectInset(rect, 0, [menu menuBarHeight]/2);
	isMaxed = YES;
      }
      if ( [tvi label] == @"Paradigm" ) {
	CPLog(@"    maximizing paradigm view");
	savedPdgmGridFrame = [self frame];
	var rect = [[[CPApp mainWindow] platformWindow] nativeContentRect];
	var menu = [CPApp mainMenu];
	origin = CGPointMake(0,[menu menuBarHeight]);
	frame = CGRectInset(rect, 0, [menu menuBarHeight]/2);
	isMaxed = YES;
      }
    }
    [self setFrame:frame];
    [self setFrameOrigin:origin];
    [self orderFront];

    [self _updateMainAndKeyWindows];
    [[CPNotificationCenter defaultCenter] postNotificationName:CPWindowDidMaximizeNotification object:self];
    _isMaximized = YES;
}

/*!
    Restores a maximized window to it's original size.
*/
- (void)demaximize:(id)sender
{
    [[self platformWindow] demaximize:sender];
    [[CPNotificationCenter defaultCenter] postNotificationName:CPWindowDidDemaximizeNotification object:self];
    _isMaximized = NO;
}

-(CFAction)windowWillMaximize:(id)sender
{
    if (sender == self)
	CPLog(@"windowWillMaximize");
}
-(CFAction)windowDidMaximize:(id)sender
{
    if (sender == self)
	CPLog(@"windowDidMaximize");
}
-(CFAction)windowWillDemaximize:(id)sender
{
    if (sender == self)
	CPLog(@"windowWillDemaximize");
}
-(CFAction)windowDidDemaximize:(id)sender
{
    if (sender == self)
	CPLog(@"windowDidDemaximize");
}

////////////////////////////////////////////////////////////////
//@delegate
- (void)windowDidBecomeMain:(CPNotification)notification
{
  CPLog(@"%@ windowDidBecomeMain notification", self);
  var mainMenu = [CPApp mainMenu];
  CPLog(@"    main menu: %@", mainMenu);
  [mainMenu update];

}

//@delegate
- (void)windowDidResignMain:(CPNotification)notification
{
  CPLog(@"PdgmDocWindow windowDidResignMain notification");
    // Sent from the notification center when the delegate's window has
    // resigned main window status.
    // @param notification contains information about the event
}

//@delegate
-(BOOL)windowShouldClose:(id)window
{
  CPLog(@"%@ windowShouldClose", self);
  return YES;
}

// - (void)performClose:(id)sender
// {
//   CPLog(@"PdgmDocWindow:performClose:sender");
//   [super performClose:sender];
// }

- (void)close:(id)sender
{
  CPLog(@"PdgmDocWindow:close");
}

}
-(void)alertDidEnd:(CPAlert)theAlert returnCode:(int)returnCode
{
  CPLog(@"alertDidEnd");
	if (returnCode == 0)
	{
		[label setStringValue:@"OK !"];
		
		[webView setMainFrameURL:@"http://cappuccino.org/"];
	}
	else if (returnCode == 1)
	{
		[label setStringValue:@"Cancel !"];
		// [webView setMainFrameURL:@"http://www.nice-panorama.com/"];
		
		[self sendSynchronousRequest];
	}

}

- (void)closeAlertDidEnd:(CPAlert)alert
	      returnCode:(CPInteger)returnCode
	     contextInfo:(void)contextInfo
{
  if (returnCode == CPAlertFirstButtonReturn) {
    [super performClose:sender];
  }
}

// - (CFAction) saveDocument:(id)aSender
// {
//   CPLog(@"PdgmDocWindow: saveDocument");
// }

- (void)onInspectorDidAccept:(CPNotification)aNotification
{
  CPLog(@"%@: onInspectorDidAccept for doc %@", self, aNotification);
  [[CPNotificationCenter defaultCenter]
    removeObserver:self
	      name:@"InspectorDidAcceptNotification" 
	    object:nil];
  [[CPNotificationCenter defaultCenter]
    removeObserver:self
	      name:@"InspectorDidCancelNotification"
	    object:nil];
  var theDoc = [aNotification object];
  CPLog(@"theDoc %@", theDoc);
  var reloadFlag = [[theDoc doclet] reloadFlag];
  // if ( (reloadFlag == CPOnState) ) {
  // [self reloadDocData:self];
  [[theDoc doclet] reload];
  // }
}
 
- (void)onInspectorDidCancel:(CPNotification)aNotification
{
  CPLog(@"%@: onInspectorDidCancel", self);
  [[CPNotificationCenter defaultCenter]
    removeObserver:self
	      name:@"InspectorDidCancelNotification" 
	    object:nil];
  [[CPNotificationCenter defaultCenter]
    removeObserver:self
	      name:@"InspectorDidAcceptNotification" 
	    object:nil];
}

- (CFAction)showDocPropertySheet:(id)sender
{
  CPLog(@"%@: showDocPropertySheet", self);
  // // newly created doc should be the main app window; use it to host property sheet
  // var mainWin = [CPApp mainWindow];
  var theDoc = [[self windowController] document];
  var pdgmDocInspector = [[PdgmDocInspector alloc] initWithDoc:theDoc];
  CPLog(@"pdgmDocInspector: " + pdgmDocInspector);
  [[CPNotificationCenter defaultCenter ]
            addObserver:self
               selector:@selector(onInspectorDidAccept:)
                   name:@"InspectorDidAcceptNotification"
                 object:nil];
  [[CPNotificationCenter defaultCenter ]
            addObserver:self
               selector:@selector(onInspectorDidCancel:)
                   name:@"InspectorDidCancelNotification"
                 object:nil];
  [pdgmDocInspector showDocPropertySheetForType:[theDoc fileType]];
  CPLog(@"/%@: showDocPropertySheet", self);
}


- (CFAction)dumpResponderChain
{
  CPLog(@"%@: dumpResponderChain", self);
  var it = self;
  while ([it nextResponder]) {
    it = [it nextResponder];
    CPLog(@"    nextResponder: %@", it);
  }
}
- (CFAction)removeDocument:(id)sender
{
  CPLog(@"%@: removeDocument: %@", self, [thePdgmDoc fileURL]);
//   CPLog(@"nextResponder: %@", [self nextResponder]);
//   // [CPApp sendAction:@selector(removeDocument:)
//   // 		 to:[AamaDocumentController sharedDocumentController]
//   // 	       from:thePdgmDoc];
//   [super removeDocument:sender];
}

// - (CFAction) closeDocument:(id)aSender
// {
//   CPLog(@"PdgmDocWindow: closeDocument");
//   [super closeDocument:aSender];
// }

// splitview
- (CFAction)splitHorizontal:(id)theSender
{
  CPLog(@"%@: splitHorizontal; sender: %@", self, theSender);
  [[self windowController] splitHorizontal:theSender]
}

////////////////////////////////////////////////////////////////
- (CFAction)sortPdgm:(id)theSender
{
  CPLog(@"%@: sortPdgm; sender: %@", self, theSender);
  [[self windowController] sortPdgm:theSender]
}

-(void)windowDidResignMain:(CPNotification)notification
{
  CPLog(@"%@ windowDidResignMain");
  [CPApp setState:CPOffState forWindow:self];
}

-(void)windowDidBecomeMain:(CPNotification)notification
{
  CPLog(@"%@ windowDidBecomeMain", self);
  [CPApp setState:CPOnState forWindow:self];
}

- (BOOL)validateMenuItem:(CPMenuItem)theMenuItem
{
  CPLog(@"%@ validateMenuItem: %@; action %@", self, [theMenuItem title], [theMenuItem action]);
  if ([theMenuItem action] == @selector(openDocument:)) return NO;
  if ([theMenuItem action] == @selector(makeKeyAndOrderFront:)) return YES;
  return YES;
}

@end
