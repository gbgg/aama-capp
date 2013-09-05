/*
 * DocumentOpen - contains both controller and windows controlled
 *TODO: change PdgmOpen prefixes to DocOpen
 * same logic, parameterized for doc type, works for all types
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

OPEN=1;
SAVE=2;
DATA=3;
OUTLINE=4;

COLLECTION=@"COLLECTION"

@implementation PdgmOpenPanel : CPWindow
{
  CPString path @accessors;
  CPString fileName @accessors;
  // CPObject     delegate;
  CPOutlineView theOutlineView;
}

+ (id)pdgmOpenPanel
{
    return [[CPOpenPanel alloc] init];
}

- (id)init
{
  CPLog(@"%@: init", self);
  [super initWithContentRect:CGRectMake(0,0,400,400) styleMask:CPDocModalWindowMask];
  [[self contentView] setBackgroundColor:[CPColor colorWithHexString:@"DADADA"]];
  var contentView = [self contentView];
  var bounds = [contentView bounds],
    w = CGRectGetWidth(bounds),
    h = CGRectGetHeight(bounds),
    lmarg = 10,
    topmarg=10,
    btnBoxHeight = 36;
  
  dataBox = [[CPBox alloc] initWithFrame:CGRectMake(lmarg,topmarg, w-(2*lmarg), h-btnBoxHeight-topmarg)];
  [dataBox setTag:DATA];
  [dataBox setAutoresizingMask:CPViewWidthSizable];
  [dataBox setBorderColor:[CPColor colorWithHexString:@"0000FF"]];
  [dataBox setBorderWidth:4];
  var dataBoxView = [dataBox contentView];

  var center = [dataBoxView center];
  var lbl = [CPTextField labelWithTitle:@"Fetching directory listing"];
  [lbl sizeToFit];
  [lbl setFrameOrigin:CGPointMake(center.x-CGRectGetWidth([lbl bounds])/2,
				  center.y+CGRectGetHeight([lbl bounds])/2 + 10)];
  [dataBoxView addSubview:lbl];
  
  var spinnerImgView = [[CPImageView alloc] initWithFrame:CGRectMake(center.x, center.y  ,16,16)];
  var spinnerImg = [[CPImage alloc] initWithContentsOfFile:[[CPBundle bundleForClass:[self class]]
								       pathForResource:@"spinner.gif"]
							      size:CGSizeMake(16.0, 16.0)];
  if (!spinnerImg) {alert("no spinner");}
  [spinnerImgView setImage:spinnerImg];
  
  // [spinnerImgView setImage:[[CPImage alloc] initWithContentsOfFile:[bundle
  // 								     pathForResource:@"CPApplication/New.png"]
  // 							      size:CGSizeMake(16.0, 16.0)]];
  [dataBoxView setBackgroundColor:[CPColor colorWithHexString:@"008888"]];
  [dataBoxView addSubview:spinnerImgView];

  btnBox = [[CPBox alloc] initWithFrame:CGRectMake(lmarg,h-btnBoxHeight, w-(2*lmarg), btnBoxHeight)];
  [btnBox setAutoresizingMask:CPViewWidthSizable];
  // [btnBox setBorderColor:[CPColor colorWithHexString:@"AAAAAA"]];
  // [btnBox setBorderWidth:4];
  // [btnBox setBorderType:CPLineBorder];
  var btnBoxView = [btnBox contentView];
  // [btnBoxView setBackgroundColor:[CPColor colorWithHexString:@"444444"]];

  btnOK = [[CPButton alloc] initWithFrame:CGRectMake(w-90-lmarg,6, 80, 24)];
  [btnOK setTag:OPEN];
  [btnOK setTitle:"Open"];
  [btnOK setBezelStyle:CPRoundedBezelStyle];
  [btnOK setAction:@selector(returnIri:)];
  [btnOK setTarget:_delegate];
  [btnBoxView addSubview:btnOK];

  btnCancel = [[CPButton alloc] initWithFrame:CGRectMake(w-200-lmarg,6, 80, 24)];
  [btnCancel setTitle:"Cancel"];
  [btnCancel setBezelStyle:CPRoundedBezelStyle];
  [btnCancel setAction:@selector(cancelOpen:)];
  [btnCancel setTarget:_delegate];
  [btnBoxView addSubview:btnCancel];

  [btnBox setContentView:btnBoxView];
  [btnBox sizeToFit];
  
  //[btnOK setDefaultButton:YES];
  // disable Open until data is displayed
  [btnOK setEnabled:NO];
  [self makeFirstResponder:btnOK];

  [contentView addSubview:dataBox];
  [contentView addSubview:btnBox];
  return self;
}

// - (id)initWithContentRect:(CGRect)aContentRect styleMask:(unsigned int)aStyleMask
// {
//   [super initWithContentRect:aContentRect styleMask:aStyleMask];
//   return [self init];
// }

- (id)initWithFrame:(CGRect)aFrame
{
  // [super initWithFrame:aFrame] styleMask:CPDocModalWindowMask];
  return [self init];
}

-(id)expandRoot:(id)theDataSource
{
  [theOutlineView expandItem:theDataSource expandChildren:YES];
}

-(id)displayDataFromSource:(id)theDataSource
{
  var dataView = [[self contentView] viewWithTag:DATA];
  bnds = [dataView bounds];
    w = CGRectGetWidth(bnds),
    h = CGRectGetHeight(bnds),
    lmarg = 10,
    topmarg=10,
    btnBoxHeight = 36;

  var scrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(lmarg, topmarg, w, h)];

  [scrollView setBackgroundColor:[CPColor colorWithHexString:@"e0ecfa"]];
  [scrollView setAutohidesScrollers:YES];

  theOutlineView = [[CPOutlineView alloc] initWithFrame:bnds];
  [theOutlineView setTag:OUTLINE];
  var fileColumn = [[CPTableColumn alloc] initWithIdentifier:@"TextColumn"];
  [fileColumn setWidth:200.0];
    
  // [theOutlineView setHeaderView:nil];
  // [theOutlineView setCornerView:nil];
  [theOutlineView addTableColumn:fileColumn];
  [theOutlineView setOutlineTableColumn:fileColumn];
  [theOutlineView setDataSource:theDataSource];
  [theOutlineView setDelegate:self];
    
  [scrollView setDocumentView:theOutlineView];
    
  // [dataView addSubview:scrollView];

  [[self contentView] replaceSubview:dataView with:scrollView];
  [self orderFront:self];
}

- (CPString)iri
{
  return [self path] + [self fileName];
}

////////////////////////////////////////////////////////////////
// outline delegate methods
- (void)outlineViewSelectionIsChanging:(CPNotification)notification
{//        Called when the user changes the selection of the outlineview, but before the change is made.
  CPLog(@"outlineViewSelectionIsChanging");
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
  CPLog(@"outlineView: shouldSelectItem: %@", [item valueForKey:@"BaseName"]);
  if ( [item valueForKey:@"FileType"] == kINDIVIDUAL ) {
    [self setFileName:[item valueForKey:@"BaseName"]];
    [[[self contentView] viewWithTag:OPEN] setEnabled:YES];
  } else {
    [[[self contentView] viewWithTag:OPEN] setEnabled:NO];
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
  // path = "/" + thePath;
  [self setPath:@"/" + thePath];
  CPLog(@"path: " + path);
  CPLog(@"filename: " + [self fileName]);
  return YES;
}

- (void)outlineViewSelectionDidChange:(CPNotification)notification;
{//        Called when the user changes the selection of the outlineview.
  CPLog(@"outlineViewSelectionDidChange ");
}

@end

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@implementation PdgmOpenPanelController : CPWindowController
{
  CPDictionary _items;
  CPWindow     docOpenPanel;
  CPString testServer;
  CPString localServer;
  var selection;
}

- (id)init
{
  CPLog(@"docOpenPanelController: init");
  [super init];

  // testServer = @"http://minkdev.appspot.com/aamadav";
  // localServer= @"http://localhost:8088/aamadav/";
  docOpenPanel = [[PdgmOpenPanel alloc] init];
			// initWithFrame:CGRectMake(20,100, 400, 200)];
  [docOpenPanel setDelegate:self];
  CPLog(@"    openPanel created");
  return self;
}

-(void)acquireIriFor:(int)OpenOrSave
{
  CPLog("PdgmOpenPanelController: acquireIriFor:" + OpenOrSave);
  [CPApp runModalForWindow:docOpenPanel];
  CPLog(@"initial open sheet display");
  // var localServer= @"/aamadav/";
  var localServer=@"http://localhost:8088/aamadav/";
  var aRequest = [CPURLRequest requestWithURL:[[CPURL alloc] initWithString:localServer]];
  CPLog(@"sending XHR");

  //FIXME:  add timeout logic in case host unavailable
  var connection = [CPURLConnection connectionWithRequest:aRequest delegate:self];
  return;
}

/* open button action: returnIri */
- (void)returnIri:(id)sender
{
  CPLog(@"DocumentOpener: returnIri %@", [docOpenPanel iri]);
  //either send a notification or call into doc controller directly
  [[CPNotificationCenter defaultCenter]
        postNotificationName:@"IriWasAcquired" object:[docOpenPanel iri]];
  [CPApp stopModal];
  [docOpenPanel orderOut:self];
  [docOpenPanel close];
}

- (void)cancelOpen:(id)sender
{
  CPLog(@"cancel open sheet");
  //FIXME:  add logic to cancel XHR request in progress
  // [docOpenPanel orderOut:self];
  [CPApp stopModal];
  [docOpenPanel close];
}

- (void)didEndSheet:(CPWindow)theSheet returnCode:(int)returnCode contextInfo:(id)contextInfo
{
  // CPLog(@"didEndSheet");
  // [docOpenPanel orderOut:self];
  [CPApp stopModal];
  [docOpenPanel close];
}
}

- (void)connection:(CPJSONPConnection) connection didReceiveData:(Object)data
{
  //This method is called when a connection receives a response. in a
  //multi-part request, this method will (eventually) be called multiple times,
  //once for each part in the response.

  CPLog(@"didReceiveData");
  // CPLog(@"\n" + data);
  
  var jsonString = [[CPString alloc] initWithString:data];
  jsonObj = [jsonString objectFromJSON];
  _items = [CPDictionary dictionaryWithJSObject:jsonObj recursively:YES];
  // CPLog(@"_items: \n" + _items);
  // construct tree
  [docOpenPanel displayDataFromSource:self];
  [docOpenPanel expandRoot:_items];
}

- (void)connection:(CPJSONPConnection)connection didFailWithError:(CPString)error
{
  //This method is called if the request fails for any reason.
  CPLog(@"didFailWithError " + error);
}

- (CPWindow)panel
{
  return docOpenPanel;
}
- (void) setDelegate:(CPObject)aDelegate
{
  _delegate = aDelegate;
}


- (id)treeNode:(CPTreeNode)theNode ForJSObject:(JSObject)theJSON recursively:(BOOL)recursively
{
  var child;
  //  [[theNode insertObject:theJSON in treeNode
  for (key in object) {
    var fileprops = [CPDictionary dictionaryWithJSObject:object[key]];
    var node = [CPTree initWithRepresentedObject:object[key]];
    if (object[key].constructor === Object) {
      for (k in object[key]) {
	child = [CPTree initWithRepresentedObject:object[key]];
      }
    }
    else if ([object[key] == @"dir"]) {
      
    } else { // value must be kINDIVIDUAL
      // continue; no children
    }
  }
}


@end
