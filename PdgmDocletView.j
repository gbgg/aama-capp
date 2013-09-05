/*
 * PdgmDocletView.j
 *
 *  The DocletView displays data; it uses the Doclet as its data source.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "PdgmDoclet.j"

@implementation PdgmDocletView : CPView // or CPTableView?
{
    CPTableView _table  @accessors;
    PdgmDoclet _doclet  @accessors(property=doclet);  // datasource and delegate
}

- (id)init
{
  CPLog(@"%@ init", self);
  [super init];
  return self;
}

- (id)initWithFrame:(CGRect)theFrame
{
  CPLog(@"%@ initWithFrame", self);
  [super initWithFrame:theFrame];
  return self;
}

- (id)makeTableForView:(CPView)contentView
{
    var scrollView = [[CPScrollView alloc] initWithFrame:[contentView bounds]];
    [scrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    
    var tableView = [[CPTableView alloc] initWithFrame:[scrollView bounds]];
    [tableView setDelegate:self];
    [tableView setDataSource:_doclet];

    var rdf = [_doclet _docData];
    var row = rdf["head"]["vars"];
    var c = row.length;
    console.dir("nbr of cols: " + c);

    var name, column;
    for (i=0; i<c; i++) {
	name = rdf.head.vars[i];
	column = [[CPTableColumn alloc] initWithIdentifier:name];
	[column setWidth:300];
	[[column headerView] setStringValue:name];
	[tableView addTableColumn:column];
    }
    
    [scrollView setDocumentView:tableView];
    [contentView addSubview:scrollView];
}

////////////////////////////////////////////////////////////////
-(void)XaddTabViewToView:(CPView)contentView
{
  CPLog(@"%@: addTabViewToView", self);

    if (!contentView)
	contentView = [[self window] contentView];
      
  var tabView = [[CPTabView alloc]
		  initWithFrame: CGRectMake(10,10,
					    CGRectGetWidth([contentView bounds])
					    - 20,
					    CGRectGetHeight([contentView bounds])
					    - 20)];
  [tabView setTabViewType:CPTopTabsBezelBorder];

  /* CPViewMinXMargin CPViewMaxXMargin */
  [tabView setAutoresizingMask: CPViewWidthSizable | CPViewHeightSizable];

  [contentView addSubview:tabView];

  [self addPdgmTabToTabView:tabView];
  [self addSpreadsheetTabToTabView:tabView];
  [tabView selectFirstTabViewItem:self];
}


@end

////////////////////////////////////////////////////////////////
@implementation PdgmGridItem : CPView
{
  CPTextField item;
}
- (void)setSelected:(BOOL)isSelected
{
    [self setBackgroundColor:isSelected ? [CPColor grayColor] : nil];
}

- (void)setView:(id)anObject
{
  CPLog(@"%@: PdgmGridItem setView: %@", self, anObject);
}

- (void)setFrameSize:(id)anObject
{
  // CPLog(@"%@: PdgmGridItem.setFrameSize " + anObject.width + ", " + anObject.height);
  // for (var m in anObject) { CPLog(m); };
  [super setFrameSize:anObject];
}

- (void)setRepresentedObject:(id)anObject
{
  // CPLog(@"setRepresentedObject: " + anObject);
    if (!item)
    {
      item = [[CPTextField alloc] initWithFrame:CGRectMake(5,5, 50, 25)];
      [item setImageScaling:CPScaleProportionally];
      [item setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
      [self addSubview:item];
    }
    [item setObjectValue:anObject];
}

// - (CFAction) saveDoclet:(id)aSender
// {
//   CPLog(@"%@: saveDoclet", self);
// }
- (CFAction)showDocPropertySheet:(id)sender
{
  CPLog(@"wincon showDocPropertySheet");
}

- (CFAction)removeDoclet:(id)sender
{
  CPLog(@"%@: removeDoclet: %@", self, [thePdgmDoc fileURL]);
  CPLog(@"nextResponder: %@", [self nextResponder]);
  [super removeDoclet:sender];
}


@end
