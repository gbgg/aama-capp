/*
 * 
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "PdgmDoclet.j"
@import "PdgmDocletViewController.j"

@implementation PdgmDatatableViewController : CPViewController
{
  PdgmDoclet _doclet  @accessors(property=doclet);
  CPTabView _docletTabView @accessors(property=docletTabView);
  CPViewController docletViewController;
  CGRect winRect;
  CPArray _views; // array of CPView
  int voffset;
}

- (id)init
{
  // CPLog(@"%@ init", self);
  [super init];
  return self;
}

- (id)initWithDoclet:(CPObject)theDoclet
{
  // CPLog(@"\n\n\t\t%@ initWithDoclet %@ ", self, theDoclet)
  self = [super init];
  [self setDoclet:theDoclet];
  // CPLog(@"/%@ initWithDoclet %@", self, theDoclet);
  return self;
}

- (id)setDocletViewController:(CPViewController)theVC
{
  CPLog(@"%@ setDocletViewController", self);
  docletViewController = theVC;
}

////////////////
- (void)makeSubviewForTabViewItem:(CPView)theViewItem
{
  // CPLog(@"%@ makeSubviewForTabViewItem %@", self, theViewItem);

  var sw = [CPScroller scrollerWidth];

  var tableView = [[CPTableView alloc] initWithFrame:CGRectMakeZero()];
  [tableView setGridColor:[CPColor blackColor]];
  [tableView setGridStyleMask: CPTableViewSolidVerticalGridLineMask 
	     | CPTableViewSolidHorizontalGridLineMask ];

  var rdf = [[self doclet] docletData];
  var row = rdf["head"]["vars"];
  var cols = row.length;
  // CPLog(@"%@ nbr of cols: %@", self, cols);

  var name, column;
  for (i=0; i<cols; i++) {
    name = rdf.head.vars[i];
    // CPLog(@"%@ col name: %@", self, name);
    column = [[CPTableColumn alloc] initWithIdentifier:name];
    [column setWidth:75];
    [[column headerView] setStringValue:name];
    // [column sizeToFit];
    [tableView addTableColumn:column];
  }
  // CPLog(@"%@ tableView %@", self, tableView);

  // [tableView setDelegate:_doclet];
  [tableView setDataSource:self];
  var rows = rdf["results"]["bindings"].length;
  var deltaW = sw/2+1; //Math.ceil(sw/2) + 1; // + cols;
  var deltaH = 2;//Math.ceil(sw/2) + 1; // + rows;
  var scrollframe = CGRectOffset(CGRectInset([tableView frame], deltaW,-deltaH), 0,0); // Wdelta,Hdelta);
  // var scrollframe = [tableView frame];
  // [tableView setFrameOrigin:CGPointMake(20,20)];

  var scrollView = [[CPScrollView alloc] initWithFrame:scrollframe];
  [scrollView setHasVerticalScroller:YES];
  [scrollView setHasHorizontalScroller:YES];
  [scrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [scrollView setBorderType:CPLineBorder];
  [scrollView setBackgroundColor:[CPColor colorWithHexString:@"88000"]];

  [scrollView setDocumentView:tableView];

  var boxframe = CGRectOffset(CGRectInset([scrollView frame], -20,-20), 10,10);
  [scrollView setFrameOrigin:CGPointMake(0,0)];

  var boxGrid;
  // if (CPStringFromClass([theViewItem class]) == @"CPTabViewItem") {
  //   boxGrid = [[CPBox alloc] initWithFrame:[[theViewItem view] bounds]];
  // } else {
  //   boxGrid = [[CPBox alloc] initWithFrame:[theViewItem bounds]];
  // }
  boxGrid = [[CPBox alloc] initWithFrame:boxframe];
  // [boxGrid setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  // [[boxGrid contentView] setBackgroundColor:[CPColor colorWithHexString:@"FF00FF"]];
  [boxGrid setBorderType:CPBezelBorder];
  [boxGrid setBorderWidth:2];
  [boxGrid setBorderColor:[CPColor blackColor]]; // colorWithHexString:@"000000"]];

  [boxGrid setContentView:scrollView];
  [boxGrid setFrameOrigin:CGPointMake(0,14)];
  // CPLog(@"%@    finished box", self);
  
  var oldSubviews;
  if (CPStringFromClass([theViewItem class]) == @"CPTabViewItem") {
    oldSubviews = [[theViewItem view] subviews];  // CPArray
  } else {
    oldSubviews = [theViewItem subviews];  // CPArray
  }
  for (var i=0; i<[oldSubviews count]; i++) {
    v = [oldSubviews objectAtIndex:i];
    [v removeFromSuperview];
  }

  // CPLog(@"    subviews removed");
  
  [boxGrid setTag:@"databox"];

  var owningWin;
  if (CPStringFromClass([theViewItem class]) == @"CPTabViewItem") {
    [[theViewItem view] addSubview:boxGrid];
    owningWin = [[theViewItem tabView] window];
  } else {
    [theViewItem addSubview:boxGrid];
    owningWin = [theViewItem window];
  }

  var winfr = [owningWin frame];
  // console.log(" dt owning win %@ frame: %@", owningWin, winfr);
  var o = winfr.origin;
  // [self dumpWindowGeom:owningWin];
  var offset = 10;
  var winRect = CGRectOffset(CGRectInset([boxGrid frame], -offset, -(offset+28)), 0,0); // offset, offset+14);
  // console.log("    winRect: ", winRect, "winfr.h", winfr);
   if (winRect.size.height >= winfr.size.height) {
    // CPLog(@" ajusting height shorter");
    // winRect.size.height = winRect.size.height / 2;
  }
  // console.log("    winRect:", winRect);
  [owningWin setFrame:winRect];
  [owningWin setFrameOrigin:o];
  winfr = [owningWin frame];

  [boxGrid setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable | CPViewMaxYMargin ];

  // [tableView sizeLastColumnToFit];

  [[docletViewController _docletWindow] setSavedDatatableFrame:winfr];
  // [docletViewController setPrevOrigin:winfr.origin];
  // [docletViewController setPrevBox:[theViewItem view]];

  // [[theViewItem view] setPostsFrameChangedNotifications:YES];

  // CPLog(@"/%@ makeSubviewForTabViewItem", self);
}

////////////////////////////////////////////////////////////////
// -(CPView)makeTableForFrame:(CPRect)theRect
// {
//   CPLog(@"%@ makeTableForFrame %@", self, theRect);

//   var bnds = theRect;
//   bnds.origin.y = bnds.origin.y + 12;
//   bnds.height = bnds.height - 12;
//   var scrollView = [[CPScrollView alloc] initWithFrame:bnds];
//   [scrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    
//   var tableView = [[CPTableView alloc] initWithFrame:[scrollView bounds]];
//   // [tableView setDelegate:_doclet];
//   [tableView setDataSource:_doclet];

//   var rdf = [_doclet docletData];
//   var row = rdf["head"]["vars"];
//   var c = row.length;
//   // CPLog(@"%@ nbr of cols: %@", self, c);

//   var name, column;
//   for (i=0; i<c; i++) {
//     name = rdf.head.vars[i];
//     // CPLog(@"%@ col name: %@", self, name);
//     column = [[CPTableColumn alloc] initWithIdentifier:name];
//     [column setWidth:75];
//     [[column headerView] setStringValue:name];
//     [tableView addTableColumn:column];
//   }
//   // CPLog(@"%@ tableView %@", self, tableView);
    
//   [scrollView setDocumentView:tableView];

//   CPLog(@"/%@ makeTableForFrame", self);
//   return scrollView;
// }

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

/*!
    The method notifies the controller that it's window is about to load.
*/
- (void)windowWillLoad
{
  CPLog(@"%@: windowWillLoad", self);
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

/*!
    The method notifies the controller that it's window has loaded.
*/
- (void)windowDidLoad
{
  CPLog(@"%@: windowDidLoad", self);
  // set tab and table views?
  // [super windowDidLoad];
  // [self showView:nil];
}

// ////////////////////////////////////////////////////////////////
// // splitview
// - (CFAction)splitHorizontal:(id)theSender
// {
//   CPLog(@"%@: splitHorizontal; sender: %@", self, theSender);

//   var tvItem = [[self docletTabView] selectedTabViewItem];
//   var id = [tvItem identifier];
//   CPLog(@"%@ splitHorizontal tab: %@", self, id);

//   var bnds = [[tvItem view] bounds];
//   bnds.origin.y = bnds.origin.y + 12;
//   bnds.size.height = bnds.size.height - 12;
//   sv = [[CPSplitView alloc] initWithFrame:bnds];
//   [sv setVertical:YES];

//   var rect1 = CGRectMakeZero();
//   var rect2 = CGRectMakeZero();
//   CGRectDivide(bnds, rect1, rect2, (bnds.size.width)/2, CGMinXEdge);
//   console.log(bnds, rect1, rect2);
//   var tv = [self makeTableForFrame:rect1];
//   [sv addSubview:tv];

//   var tv2 = [self makeTableForFrame:rect2];
//   [sv addSubview:tv2];
//   // var box = [[CPBox alloc] initWithFrame:CGRectMake(10,10,200,200)];
//   // [box setBackgroundColor:[CPColor colorWithHexString:@"00DDDD"]];
//   // [sv addSubview:box];

//   CPLog(@"%@ setting tab", self);
//   [[tvItem view] addSubview:sv];

  
//   CPLog(@"/%@: splitHorizontal", self);
// }

// - (CFAction)splitVertical:(id)theSender
// {
//   CPLog(@"%@: splitVertical", self);
// }

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
////////////////////////////////////////////////////////////////
//  Table Datasource methods - for table in DocletView
//
- (int)numberOfRowsInTableView:(CPTableView)aTableView
{
  // CPLog(@"%@: numberOfRowsInTableView %@", self, aTableView, [_doclet docletData].results.bindings.length );
  return [_doclet docletData].results.bindings.length;
}

- (id)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aTableColumn row:(int)aRow
{
  // CPLog(@"%@: tableView:objectValueForTableColumn %@, row %@", self, [aTableColumn identifier], aRow);
  var id = [aTableColumn identifier];
  var foo = [_doclet docletData].results.bindings[aRow];
  var bar = foo[id][@"value"]; // plain javascript syntax
  return bar;
}

////////////////////////////////////////////////////////////////
//  Table delegate methods
//
- (BOOL)selectionShouldChangeInTableView:(CPTableView)aTableView
{
  // CPLog(@"%@/ selectionShouldChangeInTableView for table view %@", self, aTableView);
  return true;
}
// - (CPView)tableView:(CPTableView)tableView dataViewForTableColumn:(CPTableColumn)tableColumn row:(int)row
// {
//   CPLog(@"%@ dataViewForTableColumn %@ row %@ for table view %@", self, tableColumn, row, tableView);
// }

- (void)tableView:(CPTableView)tableView didClickTableColumn:(CPTableColumn)tableColumn
{
  CPLog(@"%@ didClickTableColumn %@ for table view %@", self, tableColumn, tableView);
//   // if (lastColumn == tableColumn) {
//   //   // User clicked same column, change sort order
//   //   sortDescending = !sortDescending;
//   // } else {
//   //   // User clicked new column, change old/new column headers,
//   //   // save new sorting selector, and re-sort the array.
//   //   sortDescending = NO;
//   //   if (lastColumn) {
//   //     [tableView setIndicatorImage: nil
//   // 		     inTableColumn: lastColumn];
//   //     [lastColumn release];
//   //   }
//   //   lastColumn = [tableColumn retain];
//   //   [tableView setHighlightedTableColumn: tableColumn];
//   //   columnSortSelector = CPSelectorFromString([CPString
//   // 						stringWithFormat: @"%@Comparison:",
//   // 						[tableColumn identifier]]);
//   //   [characters sortUsingSelector: columnSortSelector];
//   // }
//   // Set the graphic for the new column header
//   // [tableView setIndicatorImage: (sortDescending ?
//   // 				 [CPTableView _defaultTableHeaderReverseSortImage] :
//   // 				 [CPTableView _defaultTableHeaderSortImage])
// 		 // inTableColumn: tableColumn];
//   // [tableView reloadData];
//   CPLog(@"/%@ didClickTableColumn %@ for table view %@", self, tableColumn, tableView);
}

- (void)tableView:(CPTableView)tableView didDragTableColumn:(CPTableColumn)tableColumn
{
  // CPLog(@"%@ didDragTableColumn %@ for table view %@", self, tableColumn, tableView);
}

// - (float)tableView:(CPTableView)tableView heightOfRow:(int)row
// {
// }

// - (BOOL)tableView:(CPTableView)tableView isGroupRow:(int)row
// {
// }

// - (void)tableView:(CPTableView)tableView mouseDownInHeaderOfTableColumn:(CPTableColumn)tableColumn
// {
//   CPLog(@"%@ mouseDownInHeaderOfTableColumn %@ for table view %@", self, tableColumn, tableView);
// }

// - (int)tableView:(CPTableView)tableView nextTypeSelectMatchFromRow:(int)startRow
// 	   toRow:(int)endRow
//        forString:(CPString)searchString
// {
// }

// - (CPIndexSet)tableView:(CPTableView)tableView selectionIndexesForProposedSelection:(CPIndexSet)proposedSelectionIndexes
// {
// }

// - (BOOL)tableView:(CPTableView)aTableView shouldEditTableColumn:(CPTableColumn)aTableColumn row:(int)rowIndex
// {
// }

- (BOOL)tableView:(CPTableView)aTableView shouldSelectRow:(int)rowIndex
{
  return true;
}

- (BOOL)tableView:(CPTableView)aTableView shouldSelectTableColumn:(CPTableColumn)aTableColumn
{
  return true;
}

// - (BOOL)tableView:(CPTableView)aTableView shouldShowCellExpansionForTableColumn:(CPTableColumn)tableColumn row:(int)row
// {
// }

// - (BOOL)tableView:(CPTableView)aTableView shouldTrackView:(CPView)aView forTableColumn:(CPTableColumn)tableColumn row:(int)row
// {
// }

// - (BOOL)tableView:(CPTableView)aTableView shouldTypeSelectForEvent:(CPEvent)event withCurrentSearchString:(CPString)searchString
// {
// }

// - (CPString)tableView:(CPTableView)aTableView
//        toolTipForView:(CPView)aView
// 		 rect:(CPRectPointer)rect
// 	  tableColumn:(CPTableColumn)aTableColumn
// 		  row:(int)row
// 	mouseLocation:(CPPoint)mouseLocation
// {
// }

// - (CPString)tableView:(CPTableView)tableView typeSelectStringForTableColumn:(CPTableColumn)tableColumn row:(int)row
// {
// }

// - (void)tableView:(CPTableView)aTableView willDisplayView:(id)aView forTableColumn:(CPTableColumn)aTableColumn row:(int)rowIndex
// {
// }

- (void)tableViewSelectionDidChange:(CPNotification)aNotification
{
  // CPLog(@"%@ tableViewSelectionDidChange", self);
}

- (void)tableViewSelectionIsChanging:(CPNotification)aNotification
{
  // CPLog(@"%@ tableViewSelectionIsChanging", self);
}

- (BOOL)validateMenuItem:(CPMenuItem)theMenuItem
{
  CPLog(@"%@ validateMenuItem: %@; action %@", self, [theMenuItem title], [theMenuItem action]);
  if ([theMenuItem action] == @selector(openDocument:)) return NO;
  return YES;
}

@end

////////////////////////////////////////////////////////////////
