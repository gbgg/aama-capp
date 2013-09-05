/*
 * DocumentSave - contains both controller and windows controlled
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "Constants.j"

var AAMADAVURI=@"http://minkdev.appspot.com/aamadav/";
var AAMADAVROOT=@"/aamadav/";

OPEN=1;
SAVE=2;
NEWFOLDER=3;
DATA=4;
OUTLINE=5;
FILENAME=6;

@implementation DocSavePanel : CPWindow
{
  CPString path @accessors;
  CPString fileName @accessors;
  CPTextField txtFileName;
}

// + (id)docOpenPanel
// {
//     return [[CPOpenPanel alloc] init];
// }

- (id)init
{
  CPLog(@"%@: init", self);
  [super initWithContentRect:CGRectMake(0,0,600,400) styleMask:CPDocModalWindowMask | CPResizableWindowMask];
  [[self contentView] setBackgroundColor:[CPColor colorWithHexString:@"DADADA"]];
  var contentView = [self contentView];
  var bounds = [contentView bounds],
    w = CGRectGetWidth(bounds),
    h = CGRectGetHeight(bounds),
    lmarg = 10,
    topmarg=10,
    btnBoxHeight = 36,
    fnBoxHeight = 40;  // filename box
  
  dataBox = [[CPView alloc] initWithFrame:CGRectMake(lmarg,topmarg, w-(2*lmarg), h-btnBoxHeight-fnBoxHeight-topmarg)];
  [dataBox setTag:DATA];
  [dataBox setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  // [dataBox setBorderColor:[CPColor colorWithHexString:@"0000FF"]];
  // [dataBox setBorderWidth:4];
  var dataBoxView = dataBox; //[dataBox contentView];
  [dataBoxView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

  var center = [dataBoxView center];
  var lbl = [CPTextField labelWithTitle:@"Fetching directory listing"];
  [lbl sizeToFit];
  [lbl setFrameOrigin:CGPointMake(center.x-CGRectGetWidth([lbl bounds])/2,
				  center.y+CGRectGetHeight([lbl bounds])/2 + 10)];
  [lbl setAutoresizingMask:
		    CPViewMinXMargin
		  | CPViewMaxXMargin
		  | CPViewMinYMargin
		  | CPViewMaxYMargin];

  [dataBoxView addSubview:lbl];
  
  var spinnerImgView = [[CPImageView alloc] initWithFrame:CGRectMake(center.x, center.y  ,16,16)];
  var spinnerImg = [[CPImage alloc] initWithContentsOfFile:[[CPBundle bundleForClass:[self class]]
								       pathForResource:@"spinner.gif"]
							      size:CGSizeMake(16.0, 16.0)];
  [spinnerImgView setAutoresizingMask:
		    CPViewMinXMargin
		  | CPViewMaxXMargin
		  | CPViewMinYMargin
		  | CPViewMaxYMargin];

  if (!spinnerImg) {alert("no spinner");}
  [spinnerImgView setImage:spinnerImg];
  
  // [spinnerImgView setImage:[[CPImage alloc] initWithContentsOfFile:[bundle
  // 								     pathForResource:@"CPApplication/New.png"]
  // 							      size:CGSizeMake(16.0, 16.0)]];
  [dataBoxView setBackgroundColor:[CPColor colorWithHexString:@"008888"]];
  [dataBoxView addSubview:spinnerImgView];

  fnBox = [[CPBox alloc] initWithFrame:CGRectMake(lmarg,h-btnBoxHeight-fnBoxHeight, w-(2*lmarg), fnBoxHeight)];
  [fnBox setBackgroundColor:[CPColor colorWithHexString:@"FFFFC8"]];
  [fnBox setAutoresizingMask:CPViewWidthSizable | CPViewMinYMargin];
  [fnBox setTag:FILENAME];
  var fnBoxView = [fnBox contentView];

  txtFileName = [[CPTextField alloc] initWithFrame:CGRectMake(4,0,w-20,fnBoxHeight-4)];
  [txtFileName setStringValue:@"Untitled.pdgm"]; 
  // [txtFileName setFont:[CPFont boldSystemFontOfSize:24.0]]; 
  [txtFileName setAutoresizingMask:CPViewWidthSizable];
	       // | CPViewMinXMargin
	       // | CPViewMaxXMargin
	       // | CPViewMinYMargin
	       // | CPViewMaxYMargin]; 
  [txtFileName setFrameOrigin:CGPointMake(0,0)]; 
  [txtFileName setEditable:YES];
  [txtFileName setBordered:YES];
  [txtFileName setBezeled: YES];
  [txtFileName setBezelStyle:CPTextFieldRoundedBezel];
  [txtFileName setDelegate: self]; 
  // [txtFileName setTarget: self]; 
  // [txtFileName setAction: @selector(saveFileName:)];
  
  [fnBoxView addSubview:txtFileName];

  btnBox = [[CPBox alloc] initWithFrame:CGRectMake(lmarg,h-btnBoxHeight, w-(2*lmarg), btnBoxHeight)];
  [btnBox setBackgroundColor:[CPColor colorWithHexString:@"EBF5FF"]];
  [btnBox setAutoresizingMask:CPViewWidthSizable | CPViewMinYMargin];
  // [btnBox setBorderColor:[CPColor colorWithHexString:@"AAAAAA"]];
  // [btnBox setBorderWidth:4];
  // [btnBox setBorderType:CPLineBorder];
  var btnBoxView = [btnBox contentView];
  [btnBoxView setAutoresizingMask:CPViewWidthSizable | CPViewMinYMargin];
  // [btnBoxView setBackgroundColor:[CPColor colorWithHexString:@"444444"]];

  btnNewFolder = [[CPButton alloc] initWithFrame:CGRectMake(lmarg,6, 120, 24)];
  [btnNewFolder setTag:NEWFOLDER];
  [btnNewFolder setTitle:"New Folder"];
  [btnNewFolder setAutoresizingMask:CPViewMaxXMargin];
  [btnNewFolder setBezelStyle:CPRoundedBezelStyle];
  [btnNewFolder setAction:@selector(makeNewFolder:)];
  [btnNewFolder setTarget:_delegate];
  [btnBoxView addSubview:btnNewFolder];

  btnCancel = [[CPButton alloc] initWithFrame:CGRectMake(w-180-2*lmarg,6, 80, 24)];
  [btnCancel setTitle:"Cancel"];
  [btnCancel setBezelStyle:CPRoundedBezelStyle];
  [btnCancel setAutoresizingMask:CPViewMinXMargin];
  [btnCancel setAction:@selector(cancelSave:)];
  [btnCancel setTarget:_delegate];
  [btnBoxView addSubview:btnCancel];

  btnOK = [[CPButton alloc] initWithFrame:CGRectMake(w-90-2*lmarg,6, 80, 24)];
  [btnOK setTag:SAVE];
  [btnOK setTitle:"Save"];
  [btnOK setAutoresizingMask:CPViewMinXMargin];
  [btnOK setBezelStyle:CPRoundedBezelStyle];
  [btnOK setAction:@selector(returnIri:)];
  [btnOK setTarget:_delegate];
  [self setDefaultButtonCell:btnOK];
  [self makeFirstResponder:btnOK];
  [btnOK setEnabled:NO];

  [btnBoxView addSubview:btnOK];

  [btnBox setContentView:btnBoxView];
  // [btnBox sizeToFit];
  
  //[btnOK setDefaultButton:YES];
  // disable Open until data is displayed

  [self makeFirstResponder:fnBox];

  [contentView addSubview:dataBox];
  [contentView addSubview:fnBox];
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

- (void)resume:(id)sender
{
  CPLog(@"resuming");
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
  CPLog(@"outlineView: shouldSelectItem");
  [[[self contentView] viewWithTag:SAVE] setEnabled:YES];
  if ( [item valueForKey:@"FileType"] == kINDIVIDUAL ) {
    [self setFileName:[item valueForKey:@"BaseName"]];
  }

  var result = @"",
    theItem = item,
    thePath = ""; // [theItem valueForKey:@"BaseName"];
  while (theItem) {
    if ([theItem valueForKey:@"FileType"] == kCOLLECTION) {
      thePath = [theItem valueForKey:@"BaseName"] + "/" + thePath;
    }
    theItem = [outlineView parentForItem:theItem];
  }
  [self setPath:@"/" + thePath];
  CPLog(@"path: " + [self path]);
  CPLog(@"filename: " + [self fileName]);
  return YES;
}

- (void)outlineViewSelectionDidChange:(CPNotification)notification;
{//        Called when the user changes the selection of the outlineview.
  CPLog(@"outlineViewSelectionDidChange ");
}
@end

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@implementation DocSavePanelController : CPWindowController
{
  CPDictionary _items;
  DocSavePanel docSavePanel;
  CPString testServer;
  CPString localServer;
  CPString path;
  CPString filename;
}

- (id)init
{
  CPLog(@"%@: init", self);
  [super init];

  // testServer = AAMADAVURI;
  // localServer= @"http://localhost:8088/aama/";
  docSavePanel = [[DocSavePanel alloc] init];
			// initWithFrame:CGRectMake(20,100, 400, 200)];
  [docSavePanel setDelegate:self];
  CPLog(@"/%@ init", self);
  return self;
}

-(void)acquireIriFor:(int)OpenOrSave
{
  CPLog("%@: acquireIriFor %@", self, OpenOrSave);
  // Save dialog is document modal
  // TODO:  check geometry and temporarily move mainWindow if necessary to keep entire save dialog onscreen
  [CPApp beginSheet: docSavePanel
     modalForWindow: [CPApp mainWindow]
      modalDelegate: self
     didEndSelector: @selector(didEndSheet:returnCode:contextInfo:)
	contextInfo: CPString];

  var localServer= AAMADAVROOT;
   // @"/aama/" // @"http://localhost:8088/aama/";
  var aRequest = [CPURLRequest requestWithURL:[[CPURL alloc] initWithString:localServer]];

 //FIXME:  add timeout logic in case host unavailable
  var connection = [CPURLConnection connectionWithRequest:aRequest delegate:self];
  CPLog("/%@: acquireIriFor %@", self, OpenOrSave);
  return;
}

/* save button action: openSelectedDocument */
- (void)returnIri:(id)sender
{ //TODO:  obtain file name from text fld
  CPLog(@"saveToIri: " + [docSavePanel iri]);
  CPLog(@"stopping modal");
  [CPApp endSheet:docSavePanel];
  // [CPApp abortModal];
  // [CPApp endSheet:docSavePanel];
  // [docSavePanel close];
  //either send a notification or call into doc controller directly
  CPLog(@"sending iri notification");
  [[CPNotificationCenter defaultCenter]
        postNotificationName:@"IriWasAcquired" object:[docSavePanel iri]];
}

- (void)cancelSave:(id)sender
{
  CPLog(@"cancel save sheet");
  //FIXME:  add logic to cancel XHR request in progress
  // [docSavePanel orderOut:self];
  [CPApp endSheet:docSavePanel];
  [[CPNotificationCenter defaultCenter]
        postNotificationName:@"SaveDidCancelNotification" object:nil];
}

- (void)didEndSheet:(CPWindow)theSheet returnCode:(int)returnCode contextInfo:(id)contextInfo
{
  // CPLog(@"didEndSheet");
  [docSavePanel orderOut:self];
  [docSavePanel close];
}
}

- (void)connection:(CPJSONPConnection) connection didReceiveData:(Object)data
{
  CPLog(@"%@: didReceiveData", self);
  //This method is called when a connection receives a response. in a
  //multi-part request, this method will (eventually) be called multiple times,
  //once for each part in the response.

  // CPLog(@"\n" + data);
  
  var jsonString = [[CPString alloc] initWithString:data];
  jsonObj = [jsonString objectFromJSON];
  _items = [CPDictionary dictionaryWithJSObject:jsonObj recursively:YES];
  // CPLog(@"_items: \n" + _items);
  // construct tree

  var dataView = [[docSavePanel contentView] viewWithTag:DATA];
  bnds = [dataView bounds];
    w = CGRectGetWidth(bnds),
    h = CGRectGetHeight(bnds),
    lmarg = 10,
    topmarg=10,
    btnBoxHeight = 36;

  var scrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(lmarg, topmarg, w, h)];
  [scrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [scrollView setBackgroundColor:[CPColor colorWithHexString:@"e0ecfa"]];
  [scrollView setAutohidesScrollers:YES];
  var outlineView = [[CPOutlineView alloc] initWithFrame:bnds];
  [outlineView setTag:OUTLINE];
  [outlineView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  var fileColumn = [[CPTableColumn alloc] initWithIdentifier:@"TextColumn"];
  [fileColumn setWidth:200.0];
    
  // [outlineView setHeaderView:nil];
  // [outlineView setCornerView:nil];
  [outlineView addTableColumn:fileColumn];
  [outlineView setOutlineTableColumn:fileColumn];
  [outlineView setDataSource:self];
  [outlineView setDelegate:docSavePanel];
    
  [scrollView setDocumentView:outlineView];
    
  // [dataView addSubview:scrollView];

  [[docSavePanel contentView] replaceSubview:dataView with:scrollView];
  [docSavePanel orderFront:self];
  CPLog(@"%@: didReceiveData", self);
}

- (void)connection:(CPJSONPConnection)connection didFailWithError:(CPString)error
{
  //This method is called if the request fails for any reason.
  CPLog(@"didFailWithError " + error);
}

- (CPWindow)panel
{
  return docSavePanel;
}

////////////////////////////////////////////////////////////////
//  outline datasource callbacks
- (id)outlineView:(CPOutlineView)outlineView child:(int)index ofItem:(id)item
{
  // CPLog("1 outlineView: child:%@ ofItem:", index); //, item);

  if (item === nil)
    {
      // CPLog(@"processing root item");
      // console.log(@"key: " + [keys objectAtIndex:index]);
      // return [keys objectAtIndex:index];
      return _items;
    }
  else
    {
      return [[item objectForKey:@"CHILDREN"] objectAtIndex:index];
    }
}

- (BOOL)outlineView:(CPOutlineView)outlineView isItemExpandable:(id)item
{
  // CPLog("2 outlineView: isItemExpandable:%@"); //, item);
  // var values = [_items objectForKey:item];
  // console.log(@"value count: " + ([values count] > 0));
  // return ([values count] > 0);
  // if FileType is directory and children > 0 return YES
  var ftype = [item objectForKey:@"FileType"];
  if (ftype == kCOLLECTION & [[item objectForKey:@"CHILDREN"] count] > 0) {
    // CPLog(@"YES");
    return YES;
  } else {
    // CPLog(@"NO");
    return NO;
  }
}

- (int)outlineView:(CPOutlineView)outlineView numberOfChildrenOfItem:(id)item
{
  // CPLog("3 outlineView:%@ numberOfChildrenOfItem:%@"); //, outlineView, item);

  if (item === nil)
    {
      // CPLog(@"processing root item");
      return 1;  // root always has just one child, a/k/a "/"
    }
  else
    {
      // CPLog(@"processing non-root item, child count: " + [[_items objectForKey:@"CHILDREN"] count]);
      return [[item objectForKey:@"CHILDREN"] count];
      // var values = [_items objectForKey:item];
      // console.log([values count]);
      // return [values count];
    }
}

- (id)outlineView:(CPOutlineView)outlineView objectValueForTableColumn:(CPTableColumn)tableColumn byItem:(id)item
{
  // CPLog("4 outlineView: objectValueForTableColumn:%@ byItem:%@"); //, tableColumn, item);
  // CPLog(@"item keys: " + [item allKeys]);
  //  CPLog(@"item vals: " + [item allValues]);
  // if ( [item objectForKey:@"FileType"] == kCOLLECTION ) {
  //   return;
  // }
  return [item objectForKey:@"BaseName"];
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
