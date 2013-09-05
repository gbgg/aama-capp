/*
 * 
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "PdgmDoclet.j"
@import "PdgmGridViewController.j"
@import "PdgmDatatableViewController.j"
// @import "LPMultiLineTextField.j"

// PdgmDocletViewController - controls views into doclet
//   a.  PdgmGrid view
//   b.  Datatable view
@implementation PdgmDocletViewController : CPViewController
{
  CPWindow _docletWindow @accessors;
  PdgmDoclet _doclet  @accessors(property=doclet);
  // PdgmDocletView docletView  @accessors(property=docletView);

  CPTabView _docletTabView @accessors(property=docletTabView);
  PdgmDatatableViewController dtViewController;
  PdgmGridViewController gridViewController;
}

- (id)init
{
  CPLog(@"%@ init", self);
  [super init];
  return self;
}

- (id)XinitWithCibName:(CPString)aCibNameOrNil bundle:(CPBundle)aCibBundleOrNil externalNameTable:(CPDictionary)anExternalNameTable
{
  CPLog(@"%@ initWithCibName %@", aCibBundleOrNil);
  return [super initWithCibName:aCibNameOrNil bundle:aCibBundleOrNil externalNameTable:anExternalNameTable];
}

- (id)initWithDoclet:(CPObject)theDoclet forWindow:(CPWindow)theWindow
{
  CPLog(@"%@ initWithDoclet %@ for window: %@", self, theDoclet, theWindow);
  _docletWindow = theWindow;
  self = [super init];
  _doclet = theDoclet;

  var theView = [theWindow contentView];
      
  _docletTabView = [[CPTabView alloc]
		  initWithFrame: CGRectMake(10,10,
					    CGRectGetWidth([theView bounds])
					    - 20,
					    CGRectGetHeight([theView bounds])
					    - 20)];
  [_docletTabView setDelegate:self];
  [_docletTabView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [_docletTabView setTabViewType:CPTopTabsBezelBorder];
  [_docletTabView setBackgroundColor:[CPColor colorWithHexString:@"e0ecfa"]];
  [_docletTabView setTag:999];
  [theWindow setTabView:_docletTabView];

  /* CPViewMinXMargin CPViewMaxXMargin */
  [_docletTabView setAutoresizingMask: CPViewWidthSizable | CPViewHeightSizable];

  [self addTabWithString:@"Paradigm"];
  gridViewController = [[PdgmGridViewController alloc]
			 initWithDoclet:theDoclet];
  [gridViewController setDocletViewController:self];
  [self addTabWithString:@"Datatable"];
  dtViewController = [[PdgmDatatableViewController alloc]
		       initWithDoclet:theDoclet];
  [dtViewController setDocletViewController:self];
  [_docletTabView selectFirstTabViewItem:self];

  [theView addSubview:_docletTabView];
  // CPLog(@"/%@ initWithDoclet %@ for window: %@; tabView: %@", self, theDoclet, theWindow, _docletTabView);
  return self;
}

- (id)initWithView:(CPView)theView
{
  CPLog(@"%@/ initWithView %@", self, theView);
  self = [super init];
  _view = theView;
  return self;
}

////////////////////////////////////////////////////////////////
-(void) addTabWithString:(CPString)theId
{
  var theTabViewItem = [[CPTabViewItem alloc] initWithIdentifier:theId];

  [theTabViewItem setLabel:theId];
  var bnds = [_docletTabView bounds];
  // bnds.origin.y = bnds.origin.y + 14;
  // bnds.size.height = bnds.size.height - 14;
  var view = [[CPView alloc] initWithFrame:bnds];
  // var subview = [[CPView alloc] initWithFrame:bnds];
  [view setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

  if (theId == "Datatable") {
    var CtxMenu = [[CPMenu alloc] initWithTitle:@"Tabs"];
    [CtxMenu setAutoenablesItems:NO];
    // var mi = [[CPMenuItem alloc] initWithTitle:@"Split Vertical" action:@selector(splitVertical:) keyEquivalent:nil];
    // [mi setEnabled:YES];
    // [CtxMenu addItem:mi];
    mi = [[CPMenuItem alloc] initWithTitle:@"Split Horizontal" action:@selector(splitHorizontal:) keyEquivalent:nil];
    [mi setEnabled:YES];
    [CtxMenu addItem:mi];
    [view setMenu:CtxMenu];
  }
  // var bnds = [view bounds];
  // bnds.origin.y = bnds.origin.y + 14;
  // bnds.size.height = bnds.size.height - 14;
  // var subview = [[CPView alloc] initWithFrame:bnds];
  [theTabViewItem setView:view];
  // [view addSubview:subview];
  [_docletTabView addTabViewItem:theTabViewItem];
}

////////////////////////////////////////////////////////////////
// TODO: retain split views across refreshes
- (CFAction)refreshForWindow:(CPWindow)theWindow
{
  // CPLog(@"%@ refreshForWindow %@, tabView: %@", self, theWindow, _docletTabView);
  [gridViewController buildPdgmHdrs:[[_doclet pdgmProps] copy]];
  // console.log([gridViewController pdgmProps]);
  [gridViewController setPdgmTerms:[[_doclet pdgmTerms] copy]];

  var i = [[self docletTabView] indexOfTabViewItemWithIdentifier:@"Datatable"];
  var tvItem = [[self docletTabView] tabViewItemAtIndex:i];
  [dtViewController makeSubviewForTabViewItem:tvItem];

  var i = [[self docletTabView] indexOfTabViewItemWithIdentifier:@"Paradigm"];
  var tvItem = [[self docletTabView] tabViewItemAtIndex:i];
  [gridViewController makeSubviewForTabViewItem:tvItem];
  // CPLog(@"%@ /refreshForWindow %@, tabView: %@", self, theWindow, _docletTabView);
}


// @override
- (void)setView:(CPDocletView)theView
{
  CPLog(@"%@ setView %@", self, theView);
  [super setView:theView];
}

- (void)setViewForDoclet:(CPDoclet)doclet
{
  CPLog(@"%@.setViewForDoclet", self);
}

- (CFAction)closeDoclet  //:(id)aSender
{
  CPLog(@"%@: closeDoclet", self);
  [super closeDoclet:aSender];
}

- (void)loadView
{
  // DO NOT call [super loadView]; it tries to load window from CIB, which fails
  CPLog(@"%@ loadView", self);
  if (!_window) {
    var theView = [[[_view class] alloc] initWithDoclet:[super doclet]];
    CPLog(@"theView: %@", self, theView);
    _view = theView;
    [theView orderFront:self];
  }
}

////////////////////////////////////////////////////////////////
- (CFAction)sortPdgm:(id)theSender
{
  CPLog(@"%@: sortPdgm; sender: %@", self, theSender);
  var tvItem = [[self docletTabView] selectedTabViewItem];
  var id = [tvItem identifier];
  CPLog(@"    sorting tab %@", id);
  [gridViewController sortPdgm];
  CPLog(@"/%@: sortPdgm; sender: %@", self, theSender);
}

////////////////////////////////////////////////////////////////
// splitview
- (CFAction)splitHorizontal:(id)theSender
{
  CPLog(@"%@: splitHorizontal; sender: %@", self, theSender);

  var tvItem = [[self docletTabView] selectedTabViewItem];
  var id = [tvItem identifier];
  // console.log(id);

  var oldSubviews = [[tvItem view] subviews];  // CPArray
  for (var i=0; i<[oldSubviews count]; i++) {
    v = [oldSubviews objectAtIndex:i];
    [v removeFromSuperview];
  }

  var bnds = [[tvItem view] bounds];
  bnds.origin.y = bnds.origin.y; // + 14;
  bnds.size.height = bnds.size.height; // - 14;
  sv = [[CPSplitView alloc] initWithFrame:bnds];
  [sv setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [sv setVertical:YES];

  CPLog(@"%@ setting tab", self);
  [[tvItem view] addSubview:sv];

  var rect1 = CGRectMakeZero();
  var rect2 = CGRectMakeZero();
  CGRectDivide(bnds, rect1, rect2, (bnds.size.width)/2, CGMinXEdge);
  // console.log(bnds, rect1, rect2);
  var v1 = [[CPView alloc] initWithFrame:rect1];
  [v1 setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [sv addSubview:v1];

  var v2 = [[CPView alloc] initWithFrame:rect2];
  [v2 setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [sv addSubview:v2];

  if (id == @"Paradigm") {
    CPLog(@"%@ splitH - making Paradigm view", self);
    [gridViewController makeSubviewForTabViewItem:v1];
    [gridViewController makeSubviewForTabViewItem:v2];
  } else {
    CPLog(@"%@ splitH - making Datatable view", self);
    [dtViewController makeSubviewForTabViewItem:v1];
    [dtViewController makeSubviewForTabViewItem:v2];
  }


  // var box = [[CPBox alloc] initWithFrame:CGRectMake(10,10,200,200)];
  // [box setBackgroundColor:[CPColor colorWithHexString:@"00DDDD"]];
  // [sv addSubview:box];
  
  CPLog(@"/%@: splitHorizontal", self);
}

////////////////////////////////////////////////////////////////
- (CFAction)splitVertical:(id)theSender
{
  CPLog(@"%@: splitVertical", self);
}

// splitview delegate methods
//Notifies the delegate when the subviews have resized.
- (void)splitViewDidResizeSubviews:(CPNotification)aNotification;
{
}

//Notifies the delegate when the subviews will be resized.
- (void)splitViewWillResizeSubviews:(CPNotification)aNotification;
{
}

//Lets the delegate specify a different rect for which the user can drag the splitView divider.
- (CGRect)XsplitView:(CPSplitView)aSplitView effectiveRect:(CGRect)aRect forDrawnRect:(CGRect)aDrawnRect ofDividerAtIndex:(int)aDividerIndex;
{
}  

//Lets the delegate specify an additional rect for which the user can drag the splitview divider.
- (CGRect)XsplitView:(CPSplitView)aSplitView additionalEffectiveRectOfDividerAtIndex:(int)indexOfDivider;
{
}

// Notifies the delegate that the splitview is about to be collapsed. This usually happens when the user
// Double clicks on the divider. Return YES if the subview can be collapsed, otherwise NO.
- (BOOL)XsplitView:(CPSplitView)aSplitView canCollapseSubview:(CPView)aSubview;
{
}

// Notifies the delegate that the subview at indexOfDivider is about to be collapsed. This usually happens when the user
// Double clicks on the divider. Return YES if the subview should be collapsed, otherwise NO.
- (BOOL)XsplitView:(CPSplitView)aSplitView shouldCollapseSubview:(CPView)aSubview forDoubleClickOnDividerAtIndex:(int)indexOfDivider;
 {
 }

// Allows the delegate to constrain the subview beings resized. This method is called continuously as the user resizes the divider.
// For example if the subview needs to have a width which is a multiple of a certain number you could return that multiple with this method.
- (float)XsplitView:(CPSplitView)aSpiltView constrainSplitPosition:(float)proposedPosition ofSubviewAt:(int)subviewIndex;
{
}

//Allows the delegate to constrain the minimum position of a subview.
- (float)XsplitView:(CPSplitView)aSplitView constrainMinCoordinate:(float)proposedMin ofSubviewAt:(int)subviewIndex;
{
}

//Allows the delegate to constrain the maximum position of a subview.
- (float)XsplitView:(CPSplitView)aSplitView constrainMaxCoordinate:(float)proposedMax ofSubviewAt:(int)subviewIndex;
{
}

// Allows the splitview to specify a custom resizing behavior. This is called when the splitview is resized.
// The sum of the views and the sum of the dividers should be equal to the size of the splitview.
- (void)XsplitView:(CPSplitView)aSplitView resizeSubviewsWithOldSize:(CGSize)oldSize;
{
  CPLog(@"%@: resizeSubviewsWithOldSize: %@", self, oldSize);
}

////////////////////////////////////////////////////////////////
- (void)tabView:(CPTabView *)tabView didSelectTabViewItem:(CPTabViewItem *)tabViewItem
{
  CPLog(@"%@ tabView didSelectTabViewItem %@", self, [tabViewItem label]);
  // CPLog(@"/%@ tabView didSelectTabViewItem %@", self, [tabViewItem label]);
}

////////////////////////////////////////////////////////////////
- (void)tabView:(CPTabView *)tabView willSelectTabViewItem:(CPTabViewItem *)tabViewItem
{
  CPLog(@"%@ tabView willSelectTabViewItem %@", self, [tabViewItem label]);
  if ( [_docletWindow isMaxed] ) {
    return;
  }
  var theRect = [_docletWindow frame];
  var theOrigin = theRect.origin;
  var theBox = [tabViewItem view];
  if ([tabViewItem label] == "Datatable") {
    CPLog(@"    selecting Datatable tab");
    var f = [_docletWindow savedDatatableFrame];
    CPLog(@"    saved frame %@", f);
    if (f) {
      [_docletWindow setSavedPdgmGridFrame:theRect];
      [_docletWindow setFrame:[_docletWindow savedDatatableFrame]];
    }
  }
  
  if ([tabViewItem label] == "Paradigm") {
    CPLog(@"    selecting Paradigm tab");
    var f = [_docletWindow savedPdgmGridFrame];
    CPLog(@"    saved frame %@", f);
    if (f) {
      [_docletWindow setSavedDatatableFrame:theRect];
      [_docletWindow setFrame:[_docletWindow savedPdgmGridFrame]];
    }
    // CPLog(@"    tabViewItem view: %@", [tabViewItem view]);
    // var boxView = [tabViewItem view];
    // CPLog(@"    boxView %@", boxView);
    // console.log([[[tabViewItem view] superview] frame]);
    // console.log(boxView);
  
    // var frameRect = [boxView frame];
    // console.log(frameRect);
    // [tabViewItem setView:theBox];
  }

  // [_docletWindowprevOrigin = theOrigin;
  // [_docletWindow setSavedFrame:theRect];
  // [_docletWindow setSavedBox:theBox];
  // [[tabViewItem tabView] setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

  // var  = CGRectOffset(CGRectInset([tableView frame], -delta,-delta), delta,delta);
}

@end

////////////////////////////////////////////////////////////////
