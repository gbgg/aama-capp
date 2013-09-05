/*
 * 
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "PdgmDocument.j"
@import "AamaDocumentController.j"
@import "PdgmDocWindow.j"
@import "PdgmDocletViewController.j" //TODO: rename to: PdgmDataTableViewController.j
@import "LPMultiLineTextField.j"

@implementation PdgmDocWinController : CPWindowController
{
  // superclass holds refs to window and doc(s), etc.

  CPWindow pdgmPropertySheet;
  CPArray cells;  //FIXME: move to pgrid constructor
  CPMutableArray docletViewControllers @accessors;
}

- (id)init
{
  CPLog(@"PdgmDocWinController init");
  [super init];
  return self;
}

- (id)initWithWindow:(CPWindow)aWindow
{
  CPLog(@"%@: initWithWindow %@", self, aWindow);
  self = [super initWithWindow:aWindow];
  docletViewControllers = [[CPArray alloc] init];
  [aWindow setDelegate:self];
  [aWindow setNextResponder:self];
  return self;
}

- (void)setWindow:(CPWindow)aWindow
{
  CPLog(@"%@: setWindow %@", self, aWindow);
  [super setWindow:aWindow];
}

// //{DEBUG
// - (CPWindow)window
// {
//   // CPLog(@"PdgmDocWinController window");
//   // super implementation calls [self loadWindow] if it doesn't already exist
//   return [super window];
// }
// //DEBUG}
// //{DEBUG
// - (CPDocument)document
// {
//   CPLog(@"PdgmDocWinController.document");
//     return _document;
// }
// //DEBUG}

- (CFAction)miniaturize:(id)sender
{
  CPLog(@"PdgmDocWinController:miniaturize");
}

- (CFAction)showDocPropertySheet:(id)sender
{
  CPLog(@"%@ showDocPropertySheet", self);
}

- (void)setDocument:(CPDocument)theDocument
{
  CPLog(@"%@ setDocument %@", self, theDocument);
  // the super impl is complicated; calls addDocument, isDocumentEdited
  // in particular, calls [self window] to steup toolbar; side-effect is that
  // window gets created if not already created
  // why setDocument has anything to do with windows is another question
  // should be factored out to setWindowForDocument
  [super setDocument:theDocument];
  //for each doclet, create docletViewController
  CPLog(@"%@: setDocument doclets: %@", self, [theDocument doclet]);
  [[theDocument doclet] setDocument:theDocument];
  // for (doclet in [theDocument doclets]) {
  //   [docletViewControllers addObject:[[PdgmDocletViewController alloc] initWithDoclet:doclet]];
  // }
  //TODO: only add if doclet not already added
  [docletViewControllers removeAllObjects];
  [docletViewControllers addObject:[[PdgmDocletViewController alloc] initWithDoclet:[[self document] doclet]
									  forWindow:_window]];
  // [docletViewControllers addObject:[[PdgmGridViewController alloc] initWithDoclet:[[self document] doclet]
  // 									  forWindow:_window]];
  CPLog(@"/%@: setDocument: %@", self, theDocument);
}

- (void)setWindowForDocument:(CPDocument)document
{
  CPLog(@"PdgmDocWinController.setWindowForDocument");
  // if we were to refactor, this would be called after setDocument
  // the implementation would be the same as CPWindowController.window, plus
  // any code needed to frob the window decorations, etc
}


- (CFAction)closeDocument  //:(id)aSender
{
  CPLog(@"PdgmDocWinController: closeDocument");
  [super closeDocument:aSender];
}

////////////////////////////////////////////////////////////////
// CAPPUCCINO-specific
////////////////////////////////////////////////////////////////
// WINDOW CONTROLLER mgmt
//   BOOL                _supportsMultipleDocuments;
// - (void)setSupportsMultipleDocuments:(BOOL)shouldSupportMultipleDocuments
// - (BOOL)supportsMultipleDocuments
//
//  NOTE: Why would a wc support multiple docs?  Standard cocoa
//  doc-based apps have one doc (and one window) per wc.  Is this
//  multiple doclets in disguise?


////////////////////////////////////////////////////////////////
////  STANDARD OVERRIDES
////////////////////////////////////////////////////////////////
// - (void)windowWillLoad
// - (void)windowDidLoad
// - (CPString)windowTitleForDocumentDisplayName:(CPString)aDisplayName

// - (CPString)windowTitleForDocumentDisplayName:(CPString)aDisplayName
// {
//   return _winDisplayName;
// }
/*!
  STANDARD OVERRIDE:  The method notifies the controller that it's window is about to load.
*/
- (void)windowWillLoad
{
  CPLog(@"PdgmDocWinController: windowWillLoad");
}
/*!
  STANDARD OVERRIDE: The method notifies the controller that it's window has loaded.
*/
- (void)windowDidLoad
{
  CPLog(@"%@: windowDidLoad", self);
  var mainMenu = [CPApp mainMenu];
  [mainMenu update];
  // set tab and table views?
  // [super windowDidLoad];
  // [self showWindow:nil];
}


- (void)loadWindow
{
  // DO NOT call [super loadWindow]; it tries to load window from CIB, which fails
  CPLog(@"%@ loadWindow", self);
  if (!_window) {
      theWindow = [PdgmDocWindow alloc]; // initWithDocument:[super document]];
      CPLog(@"theWindow: " + theWindow);
      [super setWindow:theWindow];
      [theWindow orderFront:self];
  }
}

//{DEBUG
- (@action)showWindow:(id)aSender
{
    CPLog(@"%@/: showWindow: %@ for doc %@", self, _window, aSender);

    //TODO:  makeViewControllers???

    [_window showData];
    [super showWindow:aSender];

    // var theWindow = [self window];
    // if ([theWindow respondsToSelector:@selector(becomesKeyOnlyIfNeeded)] && [theWindow becomesKeyOnlyIfNeeded])
    //     [theWindow orderFront:aSender];
    // else
    //     [theWindow makeKeyAndOrderFront:aSender];

    // [theWindow makeKeyAndOrderFront:aSender];
}

// - (CPWindow)window
// {
//     CPLog(@"CatalogManagerWindowController:Window");
//     [super window];
// }
//DEBUG}

////////////////////////////////////////////////////////////////
- (CFAction)splitHorizontal:(id)theSender
{
  CPLog(@"%@: splitHorizontal; sender: %@", self, theSender);
  [docletViewControllers makeObjectsPerformSelector:@selector(splitHorizontal:) withObject:theSender];
}

////////////////////////////////////////////////////////////////
- (CFAction)sortPdgm:(id)theSender
{
  CPLog(@"%@: sortPdgm; sender: %@", self, theSender);
  [docletViewControllers makeObjectsPerformSelector:@selector(sortPdgm:) withObject:theSender];
}

////////////////////////////////////////////////////////////////
- (CFAction)orderFront:(id)sender
{
  [_window orderFront:sender];
  [_window makeMainWindow];
  [_window makeKeyWindow];
}


- (void)openPdgmDoc:(id)sender
{
    CPLog(@"PdgmDocWinController:openPdgmDoc");
  theWindow = [[PdgmDocWindow alloc] init];
  CPLog(@"theWindow: " + theWindow);
  [super setWindow:theWindow];
  [theWindow orderFront:self];
}

- (void)alertDidEnd:(CPAlert)alert returnCode:(int)returnCode contextInfo:(void)contextInfo {
  if (returnCode == CPAlertFirstButtonReturn) {
  }
}

// -(void) addSpreadsheetTabToTabView:(CGRect)tabView
// {
//   var tabSpreadsheet = [[CPTabViewItem alloc] initWithIdentifier:@"Spreadsheet"];
//   [tabSpreadsheet setLabel:@"Spreadsheet View"];
//   var view = [[CPView alloc] initWithFrame: CGRectMake(0, 0, 100, 150)];

//   [self addPGridToView:view];

//   [tabSpreadsheet setView:view];
//   [tabView addTabViewItem:tabSpreadsheet];
// }

// - (void)addPGridToView:(CPView)theView
// {
//   // CPLog(@"PdgmDocWinController: addPGridToView");

//   var scrollView = [[CPScrollView alloc] initWithFrame:[theView bounds]];
        
//   [scrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
//   [scrollView setAutohidesScrollers:YES];
//   [[scrollView contentView] setBackgroundColor:[CPColor whiteColor]];
//   [theView addSubview:scrollView];

//   var tabContentRect = theView._box; //HACK
//   [pgridView setContent:cells];
//   // CPLog("finished pgridView setup");
//   [theView addSubview:pgridView];
// }

// ////////////////////////////////////////////////////////////////
// // CPCollectionView Delegate Methods
//  -(void)collectionViewDidChangeSelection:(CPCollectionView)collectionView;
//  {
//    CPLog(@"PdgmDocWinController collectionViewDidChangeSelection");
//     // Called when the selection in the collection view has changed.
//     // @param collectionView the collection view who's selection changed
//  }

// -(void)collectionView:(CPCollectionView)collectionView didDoubleClickOnItemAtIndex:(int)index;
// {
//   CPLog(@"PdgmDocWinController didDoubleClickOnItemAtIndex");
//     // Called when the user double-clicks on an item in the collection view.
//     // @param collectionView the collection view that received the double-click
//     // @param index the index of the item that received the double-click
// }

// -(CPData)collectionView:(CPCollectionView)collectionView dataForItemsAtIndexes:(CPIndexSet)indices forType:(CPString)aType;
// {
//   CPLog(@"PdgmDocWinController dataForItemsAtIndexes");
//   return [CPKeyedArchiver archivedDataWithRootObject:[cells objectAtIndex:[indices firstIndex]]];
//   // Invoked to obtain data for a set of indices.
//   // @param collectionView the collection view to obtain data for
//   // @param indices the indices to return data for
//   // @param aType the data type
//   // @return a data object containing the index items
// }

// -(CPArray)collectionView:(CPCollectionView)collectionView dragTypesForItemsAtIndexes:(CPIndexSet)indices;
// {
//   CPLog(@"PdgmDocWinController dragTypesForItemsAtIndexes");
//   // Invoked to obtain the data types supported by the specified indices for placement on the pasteboard.
//   // @param collectionView the collection view the items reside in
//   // @param indices the indices to obtain drag types
//   // @return an array of drag types (CPString)
// }

////////////////////////////////////////////////////////////////
-(void)XaddTabViewToView:(CGRect)theView
{
  CPLog(@"%@: addTabViewToView", self);

  if (!theView)
    theView = [[self window] contentView];
      
  var tabView = [[CPTabView alloc]
		  initWithFrame: CGRectMake(10,10,
					    CGRectGetWidth([theView bounds])
					    - 20,
					    CGRectGetHeight([theView bounds])
					    - 20)];
  [tabView setTabViewType:CPTopTabsBezelBorder];

  /* CPViewMinXMargin CPViewMaxXMargin */
  [tabView setAutoresizingMask: CPViewWidthSizable | CPViewHeightSizable];

  [theView addSubview:tabView];

  [self addPdgmTabToTabView:tabView];
  [self addSpreadsheetTabToTabView:tabView];
  [tabView selectFirstTabViewItem:self];
}

////////////////////////////////////////////////////////////////
- (CFAction)performRefresh:(id)sender
{
  CPLog(@"%@: performRefresh, sender: %@, window: %@", self, sender, [self window]);
  [[self window] refreshButtonPush:self];
  [[self window] performRefresh:sender];
}

////////////////////////////////////////////////////////////////
- (CFAction)refreshViews:(id)sender
{
  // CPLog(@"%@: refreshViews, sender: %@", self, sender);
  [docletViewControllers makeObjectsPerformSelector:@selector(refreshForWindow:) withObject:_window];
  [self refreshButtonPop:sender];
  // [[docletViewControllers objectAtIndex:0] refreshForWindow:_window];
  // [self setNextResponder:[docletViewControllers objectAtIndex:0]];
  // CPLog(@"/%@: refreshViews, sender: %@", self, sender);
}

////////////////////////////////////////////////////////////////
////   WINDOW DELEGATE METHODS
////////////////////////////////////////////////////////////////
- (CFAction)refresh:(id)sender
{
  CPLog(@"%@: refresh, sender: %@", self, sender);
  // [thePdgmDoc reloadDocData:self];
  // [super refreshButtonPush:self];
  // for (doclet in [[self document] doclets]) {


  //   [docletViewControllers addObject:[[PdgmDocletViewController alloc] initWithDoclet:doclet]];
  // }
  // var vc = [[PdgmDocletViewController alloc] initWithDoclet:[[self document] doclet]
  // 						  forWindow:_window];
  // CPLog(@"%@ pdvc: %@", self, vc);
  // [docletViewControllers addObject:vc];
  // [docletViewControllers makeObjectsPerformSelector:@selector(refreshForWindow:) withObject:_window];

  CPLog(@"%@: refresh: %@", self, document);
  return;
}
- (CFAction)refreshButtonPush:(id)theDoc
{
  // CPLog(@"%@ refreshButtonPush doc: %@", self, theDoc);
  // 1. find window for theDoc
  [[self window] refreshButtonPush:self];
}

- (CFAction)refreshButtonPop:(id)theDoc
{
  // CPLog(@"%@ refreshButtonPop doc: %@", self, theDoc);
  // 1. find window for theDoc
  [[self window] refreshButtonPop:self];
}

-(CFAction)windowWillRefresh:(id)sender
{
  // CPLog(@"%@/: windowWillRefresh", self);
  [_document reload];
}

-(CFAction)windowDidRefresh:(id)sender
{
  // CPLog(@"%@: windowDidRefresh", self);
}

////////////////////////////////////////////////////////////////
////  WINDOW NOTIFICATIONS
////////////////////////////////////////////////////////////////
-(void)windowDidResize:(CPNotification)notification
{
  CPLog(@"%@/ windowDidResize obj: %@", self, [notification object]);
}

////////////////////////////////////////////////////////////////
////  WINDOW DELEGATION METHODS
////////////////////////////////////////////////////////////////
-(void)windowDidResignMain:(CPNotification)notification
{
  CPLog(@"%@ windowDidResignMain obj: %@", self, [notification object]);
  [CPApp setState:CPOffState forWindow:[self window]];
  [[self window] setAlphaValue:0.7];
}

-(void)windowDidBecomeMain:(CPNotification)notification
{
  CPLog(@"%@ windowDidBecomeMain obj: %@", self, [notification object]);
  [CPApp setState:CPOnState forWindow:[self window]];
  [[self window] setAlphaValue:1.0];
}

-(void)windowDidResignKey:(CPNotification)notification
{
  // CPLog(@"%@ windowDidResignKey obj: %@", self, [notification object]);
}

-(void)windowDidResize:(CPNotification)notification
{
  // CPLog(@"%@ windowDidResize", self);
}

-(CPUndoManager)windowWillReturnUndoManager:(CPWindow)window
{
  CPLog(@"%@ windowWillReturnUndoManager", self);
}

-(BOOL)windowShouldClose:(id)window
{
  CPLog(@"%@ windowShouldClose %@", self, window);
  [CPApp removeWindowsItem:[self window]];
  return YES;
}

////////////////////////////////////////////////////////////////
////  WINDOWCONTROLLER OVERRIDE METHODS
////////////////////////////////////////////////////////////////
// must override in subclass in order to create and load programmatically rather than from CIB
// override, in order to create and load programmatically rather than from CIB
- (void)loadWindow
{
  // DO NOT call [super loadWindow]; it tries to load window from CIB, which fails
  CPLog(@"%@ loadWindow", self);
  if (!_window) {
      _window = [[MorphPropertyInspectorWindow alloc] init];
      [super setWindow:_window];
      [_window orderFront:self];
  }
}

- (void)windowWillLoad
{
  CPLog(@"%@ windowWillLoad", self);  
}

- (void)windowDidLoad
{
  CPLog(@"%@: windowDidLoad", self);
  // set tab and table views?
  // [super windowDidLoad];
  // [self showWindow:nil];
}

- (BOOL)shouldCloseDocument
{
  CPLog(@"%@ shouldCloseDocument", self);  
    return [super shouldCloseDocument];
}

//****************************************************************

- (BOOL)validateMenuItem:(CPMenuItem)theMenuItem
{
  CPLog(@"%@ validateMenuItem: %@; action %@", self, [theMenuItem title], [theMenuItem action]);
  if ([theMenuItem action] == @selector(makeKeyAndOrderFront:)) return YES;
  return NO;
}

@end

