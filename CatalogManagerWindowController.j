/*
 *
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "CatalogManager.j"
@import "AamaDocumentController.j"
@import "CatalogManagerWindow.j"
@import "LPMultiLineTextField.j"
@import "Constants.j"

var sparqlhost = @"http://fu.sibawayhi.org/ds";
// var sparqlhost = @"http://localhost";
var sparqlport = @"8080";

@implementation CatalogManagerWindowController : CPWindowController
{
  // superclass holds refs to window and doc(s), etc.
  CPMutableDictionary dataSource;
  CPTextField txtRename;
  CPPanel HUDPanel;
  CPURLConnection _readConnection;
  CPURLRequest        _writeRequest;
}

// - (id)init
// {
//   CPLog(@"CatalogManagerWindowController: init");
//   [super init];
//   CPLog(@"FINISHED CatalogManagerWindowController: init");
//   return self;
// }

//{DEBUG
- (id)initWithWindow:(CPWindow)aWindow
{
    // CPLog(@"%@: initWithWindow %@", self, aWindow);
    self = [super initWithWindow:aWindow];
    [aWindow setDelegate:self];
    // if (self)
    // {
    //     [self setWindow:aWindow];
    //     [self setShouldCloseDocument:NO];
    //     [self setNextResponder:CPApp];
    //     _documents = [];
    // }
    // CPLog(@"/%@: initWithWindow %@", self, aWindow);
    return self;
}
//DEBUG}

- (void)setWindow:(CPWindow)aWindow
{
    // CPLog(@"%@: setWindow %@", self, aWindow);
    [super setWindow:aWindow];
}

// //{DEBUG
// - (CPWindow)window
// {
//   // CPLog(@"CatalogManagerWindowController window");
//   // super implementation calls [self loadWindow] if it doesn't already exist
//   return [super window];
// }
// //DEBUG}

// //{DEBUG
// - (CPDocument)document
// {
//   CPLog(@"CatalogManagerWindowController.document");
//     return _document;
// }
// //DEBUG}

- (CFAction)miniaturize:(id)sender
{
  // CPLog(@"CatalogManagerWindowController:miniaturize");
}

- (CFAction)refreshButtonPush:(id)theDoc
{
  // CPLog(@"%@: refreshButtonPush doc: %@", self, theDoc);
  // 1. find window for theDoc
  [[self window] refreshButtonPush:self];
}
- (CFAction)refreshButtonPop:(id)theDoc
{
  // CPLog(@"%@: refreshButtonPop doc: %@", self, theDoc);
  // 1. find window for theDoc
  [[self window] refreshButtonPop:self];
}

- (CFAction)rename:(id)aSender
{
  CPLog(@"%@ rename %@", self, [aSender tag]);
  var theBrowser = [[self window] theBrowser];
  var sel = [theBrowser selectedItem];
  var c = [theBrowser selectedColumn];
  var r = [theBrowser selectedRowInColumn:c];
  CPLog(@"%@ selectedItem r %@ c %@: %@", self, r, c, sel);

  var doctype = [sel objectForKey:@"DataType"];
  CPLog(@"%@ doctype %@", doctype);

  var rect = [theBrowser rectOfRow:r inColumn:c];
  CPLog(@"%@ rect: %@, %@, %@, %@", self, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
  var wpt = [theBrowser convertPoint:rect.origin toView:nil];
  console.log("wpt ", wpt);

  HUDPanel = [[CPPanel alloc]
		   initWithContentRect:CGRectMake(0 + wpt.x,
						  0 + wpt.y + rect.size.height,
						  400, 80)
			     // styleMask:CPBorderlessWindowMask | CPClosableWindowMask];
  styleMask:CPHUDBackgroundWindowMask | CPClosableWindowMask];

  [HUDPanel setFloatingPanel:YES];
  [HUDPanel setTitle:@"Rename"];
  var panelContentView = [HUDPanel contentView];
  var bounds = [panelContentView bounds],
    w = CGRectGetWidth(bounds),
    h = CGRectGetHeight(bounds),
    marg = 10;

  var fnBox = [[CPBox alloc] initWithFrame:CGRectMake(marg,marg, w-(20), 40)];
  [fnBox setBackgroundColor:[CPColor colorWithHexString:@"FFFFC8"]];
  [fnBox setAutoresizingMask:CPViewWidthSizable | CPViewMinYMargin];
  [fnBox setTag:FILENAME];
  var fnBoxView = [fnBox contentView];

  txtRename = [[CPTextField alloc] initWithFrame: CGRectMake(4, 4, w-20, 36)];
  // var txtRename = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
  // // var txtRename = [CPTextField labelWithTitle:[sel objectForKey:@"Name"]];

  [txtRename setTag:doctype];

  [txtRename setStringValue:[sel objectForKey:@"Name"]];
  // [txtRename setFont:[CPFont boldSystemFontOfSize:24.0]];
  // [txtRename sizeToFit];
  // [txtRename setAutoresizingMask:CPViewWidthSizable + CPViewHeightSizable];
  // [txtRename setAutoresizingMask:
  // 	       CPViewMinXMargin
  // 	     | CPViewMaxXMargin
  // 	     | CPViewMinYMargin
  // 	     | CPViewMaxYMargin];
  [txtRename setFrameOrigin:CGPointMake(0,0)];
  [txtRename setEditable:YES];
  [txtRename setBordered:YES];
  [txtRename setBezeled: YES];
  [txtRename setBezelStyle:CPTextFieldRoundedBezel];
  // [txtRename setImageScaling:CPScaleProportionally];
  [txtRename setDelegate: self];
  // [txtRename setTarget: self];
  // [txtRename setAction: @selector(saveFileName:)];
  [fnBoxView addSubview:txtRename];
  // [txtRename setCenter:[panelContentView center]];

  [panelContentView addSubview:txtRename];
  // [panelContentView addSubview:fnBox];

  btnCancel = [[CPButton alloc] initWithFrame:CGRectMake(w-180-2*marg,40, 80, 24)];
  [btnCancel setTitle:"Cancel"];
  [btnCancel setBezelStyle:CPRoundedBezelStyle];
  [btnCancel setAutoresizingMask:CPViewMinXMargin];
  [btnCancel setAction:@selector(cancelRename:)];
  [btnCancel setTarget:self];
  [panelContentView addSubview:btnCancel];

  btnOK = [[CPButton alloc] initWithFrame:CGRectMake(w-90-2*marg,40, 80, 24)];
  [btnOK setTag:SAVE];
  [btnOK setTitle:"Save"];
  [btnOK setAutoresizingMask:CPViewMinXMargin];
  [btnOK setBezelStyle:CPRoundedBezelStyle];
  [btnOK setAction:@selector(doRename:)];
  [btnOK setTarget:self];
  [HUDPanel setDefaultButtonCell:btnOK];
  [btnOK setEnabled:YES];

  [panelContentView addSubview:btnOK];

  [HUDPanel makeFirstResponder:txtRename];

  // [btnBox setContentView:btnBoxView];

  [HUDPanel makeKeyAndOrderFront:self];

 return;
}

- (void)newName:(id)sender
{
}
- (void)doRename:(id)sender
{ 
  CPLog(@"%@ doRename %@", self, [txtRename objectValue]);
  var docname = [txtRename objectValue];
  var doctype = [txtRename tag];
  CPLog(@"%@ doctype %@; docname %@", self, doctype, docname);
  [HUDPanel close];

  var theBrowser = [[self window] theBrowser];
  var sel = [theBrowser selectedItem];
  var c = [theBrowser selectedColumn];
  var r = [theBrowser selectedRowInColumn:c];
  CPLog(@"%@ selectedItem r %@ c %@: %@", self, r, c, sel);

  var key = [sel objectForKey:@"ID"];
  uri = "/home/" + key;
  CPLog(@"%@ uri: %@", self, uri);
  var req = [CPURLRequest requestWithURL:uri];
  [req setHTTPMethod:@"PUT"];
  [req setHTTPBody:[txtRename objectValue]];
  [req setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
  [req setValue:doctype forHTTPHeaderField:@"aama-doctype"];
  [_readConnection cancel];
  CPLog(@"    ....sending XHR");
  var resp;
  var theDatum = [CPURLConnection sendSynchronousRequest:req returningResponse:resp];
  CPLog(@"%@ ajax data %@; result: %@", self, theDatum, resp);
  console.log("result data: ", [theDatum rawString]);
  [sel setObject:[theDatum rawString] forKey:@"Name"];
  [[[self window] theBrowser] reloadColumn:c];
}

- (void)cancelRename:(id)sender
{
  CPLog(@"cancel rename");
  //FIXME:  add logic to cancel XHR request in progress
  [HUDPanel orderOut:self];
  // [CPApp endSheet:docSavePanel];

}

- (CFAction)newDoc:(id)aSender
{
  CPLog(@"%@ newDoc %@", self, [aSender tag]);
  var theBrowser = [[self window] theBrowser];
  var sel = [theBrowser selectedItem];
  var c = [theBrowser selectedColumn];
  var r = [theBrowser selectedRowInColumn:c];
  CPLog(@"%@ selectedItem r %@ c %@: %@", self, r, c, sel);

  var doctype = [aSender tag];
  CPLog(@"%@ doctype %@", self, doctype);
  if ( doctype === "pdgm" ) {
    doctype = "PARADIGM";
  } else {
    if ( doctype === "folder" ) {
      doctype = "COLLECTION";
    }
  }
  CPLog(@"%@ doctype %@", self, doctype);
  var kids = [sel objectForKey:@"CHILDREN"];
  CPLog(@"%@ kids: %@", self, kids);


  var rect, wpt;
  if ( r < 0 ) {
    rect = [theBrowser bounds];
  } else {
    rect = [theBrowser rectOfRow:r inColumn:c];
    CPLog(@"%@ rect: %@, %@, %@, %@", self, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
  }
  wpt = [theBrowser convertPoint:rect.origin toView:nil];
  console.log("wpt ", wpt);

  HUDPanel = [[CPPanel alloc]
		   initWithContentRect:CGRectMake(0 + wpt.x,
						  0 + wpt.y + rect.size.height,
						  400, 80)
			     // styleMask:CPBorderlessWindowMask | CPClosableWindowMask];
  styleMask:CPHUDBackgroundWindowMask | CPClosableWindowMask];

  [HUDPanel setFloatingPanel:YES];
  [HUDPanel setTitle:@"Document Name"];
  var panelContentView = [HUDPanel contentView];
  var bounds = [panelContentView bounds],
    w = CGRectGetWidth(bounds),
    h = CGRectGetHeight(bounds),
    marg = 10;

  var fnBox = [[CPBox alloc] initWithFrame:CGRectMake(marg,marg, w-(20), 40)];
  [fnBox setBackgroundColor:[CPColor colorWithHexString:@"FFFFC8"]];
  [fnBox setAutoresizingMask:CPViewWidthSizable | CPViewMinYMargin];
  [fnBox setTag:FILENAME];
  var fnBoxView = [fnBox contentView];

  txtRename = [[CPTextField alloc] initWithFrame: CGRectMake(4, 4, w-20, 36)];
  [txtRename setTag:doctype];

  // var txtRename = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
  // // var txtRename = [CPTextField labelWithTitle:[sel objectForKey:@"Name"]];
  // [txtRename setStringValue:@"New folder"];
  // [txtRename setFont:[CPFont boldSystemFontOfSize:24.0]];
  // [txtRename sizeToFit];
  // [txtRename setAutoresizingMask:CPViewWidthSizable + CPViewHeightSizable];
  // [txtRename setAutoresizingMask:
  // 	       CPViewMinXMargin
  // 	     | CPViewMaxXMargin
  // 	     | CPViewMinYMargin
  // 	     | CPViewMaxYMargin];
  [txtRename setFrameOrigin:CGPointMake(0,0)];
  [txtRename setEditable:YES];
  [txtRename setBordered:YES];
  [txtRename setBezeled: YES];
  [txtRename setBezelStyle:CPTextFieldRoundedBezel];
  // [txtRename setImageScaling:CPScaleProportionally];
  [txtRename setDelegate: self];
  // [txtRename setTarget: self];
  // [txtRename setAction: @selector(saveFileName:)];
  [fnBoxView addSubview:txtRename];
  // [txtRename setCenter:[panelContentView center]];

  [panelContentView addSubview:txtRename];
  // [panelContentView addSubview:fnBox];

  btnCancel = [[CPButton alloc] initWithFrame:CGRectMake(w-180-2*marg,40, 80, 24)];
  [btnCancel setTitle:"Cancel"];
  [btnCancel setBezelStyle:CPRoundedBezelStyle];
  [btnCancel setAutoresizingMask:CPViewMinXMargin];
  [btnCancel setAction:@selector(cancelNewDoc:)];
  [btnCancel setTarget:self];
  [panelContentView addSubview:btnCancel];

  btnOK = [[CPButton alloc] initWithFrame:CGRectMake(w-90-2*marg,40, 80, 24)];
  [btnOK setTag:SAVE];
  [btnOK setTitle:"Save"];
  [btnOK setAutoresizingMask:CPViewMinXMargin];
  [btnOK setBezelStyle:CPRoundedBezelStyle];
  [btnOK setAction:@selector(doNewDoc:)];
  [btnOK setTarget:self];
  [HUDPanel setDefaultButtonCell:btnOK];
  [btnOK setEnabled:YES];

  [panelContentView addSubview:btnOK];

  [HUDPanel makeFirstResponder:txtRename];

  // [btnBox setContentView:btnBoxView];

  [HUDPanel makeKeyAndOrderFront:self];

}

- (void)cancelNewDoc:(id)sender
{
  CPLog(@"cancel new doc");
  //FIXME:  add logic to cancel XHR request in progress
  [HUDPanel orderOut:self];
  // [CPApp endSheet:docSavePanel];

}

- (CFAction)doNewDoc:(id)aSender
{
  CPLog(@"%@ doNewDoc", self);
  var doctype = [txtRename tag];
  var docname = [txtRename objectValue];
  CPLog(@"%@ doctype %@; docname %@", self, doctype, docname);
  [HUDPanel close];

  var theBrowser = [[self window] theBrowser];
  var sel = [theBrowser selectedItem];
  var c = [theBrowser selectedColumn];
  var r = [theBrowser selectedRowInColumn:c];

  var rect, wpt;
  if ( r < 0 ) {
    rect = [theBrowser bounds];
  } else {
    rect = [theBrowser rectOfRow:r inColumn:c];
    CPLog(@"%@ rect: %@, %@, %@, %@", self, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
  }
  wpt = [theBrowser convertPoint:rect.origin toView:nil];
  console.log("wpt ", wpt);

  var key, uri;
  if (sel) {
    key = [sel objectForKey:@"ID"];
    uri = "/home/" + key;
  } else { // no selection
    CPLog(@"%@ dataSource[0]: %@", self, [dataSource[0] objectForKey:@"ID"]);
    key = [dataSource objectForKey:@"ID"];
    uri = "/home/" + key;
  }
  CPLog(@"%@ uri: %@", self, uri);

  var req = [CPURLRequest requestWithURL:uri];
  [req setHTTPMethod:@"POST"];
  [req setHTTPBody:docname];
  [req setValue:doctype forHTTPHeaderField:@"aama-doctype"];
  if (doctype == "pdgm") {
    [req setValue:sparqlhost forHTTPHeaderField:@"aama-host"];
    [req setValue:sparqlport forHTTPHeaderField:@"aama-port"];
  }
  [_readConnection cancel];
  CPLog(@"%@    ....sending XHR", self);
  var resp;
  var theDatum = [CPURLConnection sendSynchronousRequest:req returningResponse:resp];
  CPLog(@"%@ ajax data %@; result: %@", self, theDatum, resp);
  console.log("result data: ", theDatum);

  var jsonObj = [theDatum JSONObject];
  var frag = [CPDictionary dictionaryWithJSObject:jsonObj recursively:YES];
  CPLog(@"%@ frag %@", self, frag);
  CPLog(@"%@ dataSource %@", self, dataSource);
  if ( c < 0 ) {
    dataSource = null;
    dataSource = frag;
    [theBrowser reloadColumn:0];
  } else {
    [sel setObject:[frag objectForKey:@"CHILDREN"] forKey:@"CHILDREN"];
    [theBrowser reloadColumn:(c)];
    [theBrowser reloadColumn:(c+1)];
  }
}

- (CFAction)trash:(id)aSender
{
  CPLog(@"%@ trash", self);
  var theBrowser = [[self window] theBrowser];
  var sel = [theBrowser selectedItem];
  var c = [theBrowser selectedColumn];
  var r = [theBrowser selectedRowInColumn:c];
  CPLog(@"%@ trashing selectedItem r %@ c %@: %@", self, r, c, sel);
  var kids = [sel objectForKey:@"CHILDREN"];
  CPLog(@"%@ kids: %@", self, kids);

  var key, uri;
  if (sel) {
    key = [sel objectForKey:@"ID"];
    uri = "/home/" + key;
  } else { // no selection
    CPLog(@"%@ no selection");
    return;
  }
  CPLog(@"%@ uri: %@", self, uri);

  var req = [CPURLRequest requestWithURL:uri];
  [req setHTTPMethod:@"DELETE"];
  [_readConnection cancel];
  CPLog(@"    ....sending XHR");
  var resp;
  var theDatum = [CPURLConnection sendSynchronousRequest:req returningResponse:resp];
  CPLog(@"%@ ajax data %@; result: %@", self, theDatum, resp);
  console.log("result data: ", theDatum);

  // here we have to use js splice(i,i)
  var prevrow = [theBrowser selectedRowInColumn:(c-1)];
  var previtem = [theBrowser itemAtRow:prevrow inColumn:(c-1)];
  CPLog(@"%@ prevrow: %@, col: %@,  item %@", self, prevrow, (c-1), previtem);
  var kids = [previtem objectForKey:@"CHILDREN"];
  CPLog(@"%@ kids %@ ct: %@", self, kids, kids.length);
  [kids removeObjectAtIndex:r];
  CPLog(@"%@ kids %@ ct: %@", self, kids, kids.length);
  CPLog(@"%@ prevrow: %@, col: %@,  item %@", self, prevrow, (c-1), previtem);
  //

  CPLog(@"%@ dataSource: %@", self, dataSource);
  [theBrowser setLastColumn:(c)];
  if (c > 0) {
    [theBrowser reloadColumn:(c)];
  }
  [theBrowser selectRow:-1 inColumn:(c)];
}


- (void)setDocument:(CPDocument)document
{
    // CPLog(@"%@: setDocument %@", self, document);
    // the super impl is complicated: registers notifications, calls addDocument, isDocumentEdited
    // in particular, calls [self window] to steup toolbar; side-effect is that
    // window gets created if not already created
    // why setDocument has anything to do with windows is another question
    // should be factored out to setWindowForDocument
    [super setDocument:document];
    dataSource = [document catalog];
    [[self window] setBrowserDelegate:self];

    CPLog(@"%@ setting browser delegate %@ for %@", self, [[[self window] theBrowser] delegate], [[self window] theBrowser]);
    // [_window setDelegate:document];
    // [_cmWindow showData];
    // [_cmWindow orderFront:self];
    // CPLog(@"/%@: setDocument %@", self, document);
}

// - (void)setWindowForDocument:(CPDocument)document
// {
//   CPLog(@"CatalogManagerWindowController.setWindowForDocument");
//   [super setWindowForDocument];
//   // if we were to refactor, this would be called after setDocument
//   // the implementation would be the same as CPWindowController.window, plus
//   // any code needed to frob the window decorations, etc
// }

- (CFAction)closeDocument  //:(id)aSender
{
  // CPLog(@"CatalogManagerWindowController: closeDocument");
  [super closeDocument:aSender];
}

//{DEBUG
- (@action)showWindow:(id)aSender
{
    // CPLog(@"%@/: showWindow: %@", self, aSender);
    [_window showData];
    [super showWindow:aSender];


    // var theWindow = [self window];
    // if ([theWindow respondsToSelector:@selector(becomesKeyOnlyIfNeeded)] && [theWindow becomesKeyOnlyIfNeeded])
    //     [theWindow orderFront:aSender];
    // else
    //     [theWindow makeKeyAndOrderFront:aSender];
}
// - (CPWindow)window
// {
//     CPLog(@"CatalogManagerWindowController:Window");
//     [super window];
// }
//DEBUG}

- (void)alertDidEnd:(CPAlert)alert returnCode:(int)returnCode contextInfo:(void)contextInfo {
  if (returnCode == CPAlertFirstButtonReturn) {
  }
}

////////////////////////////////////////////////////////////////
////  WINDOW NOTIFICATIONS
////////////////////////////////////////////////////////////////
-(void)windowDidResize:(CPNotification)notification
{
  // CPLog(@"%@ windowDidResize", self);
}

////////////////////////////////////////////////////////////////
////  WINDOW DELEGATION METHODS
////////////////////////////////////////////////////////////////
-(void)windowDidResignMain:(CPNotification)notification
{
  // CPLog(@"%@ windowDidResignMain obj: %@", self, [notification object]);
  [CPApp setState:CPOffState forWindow:[self window]];
  [[self window] setAlphaValue:0.7];
}

-(void)windowDidBecomeMain:(CPNotification)notification
{
  // CPLog(@"%@ windowDidBecomeMain obj %@", self, [notification object]);
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
  // CPLog(@"%@ windowWillReturnUndoManager", self);
}

-(BOOL)windowShouldClose:(id)window
{
  // CPLog(@"%@ windowShouldClose %@", self, window);
  [CPApp removeWindowsItem:[self window]];
  return YES;
}

////////////////////////////////////////////////////////////////
////  WINDOWCONTROLLER OVERRIDE METHODS
////////////////////////////////////////////////////////////////
// must override in subclass in order to create and load programmatically rather than from CIB
- (void)loadWindow
{
  // DO NOT call [super loadWindow]; it tries to load window from CIB, which fails
  CPLog(@"%@ loadWindow", self);
  if (!_window) {
    _window = [[CatalogManagerWindow alloc] init];
      // CPLog(@"CatalogManagerWindow:loadWindow: " + _window);
      // [theWindow setDocument:[super document]];  //  initWithDocument:[super document]];
      [super setWindow:_window];
      [_window orderFront:self];
  }
  // CPLog(@"/%@ loadWindow", self);
}

- (void)windowWillLoad
{
  // CPLog(@"%@ windowWillLoad", self);
}

- (void)windowDidLoad
{
  // CPLog(@"%@: windowDidLoad", self);
  // set tab and table views?
  // [super windowDidLoad];
  // [self showWindow:nil];
}

- (BOOL)shouldCloseDocument
{
  // CPLog(@"%@ shouldCloseDocument", self);
  return [super shouldCloseDocument];
}

// this is a CPToolbar method - what's it doing here?
- (void)viewForItem:(id)theItem forView:(CPView)theView
{
  CPLog(@"%@: viewForItem:forView", self);
  var image = [[CPImage alloc]
		initWithContentsOfFile:[[CPBundle bundleForClass:[self class]]
    								       pathForResource:@"Reload.png"]
				  size:CGSizeMake(64,64)];

  var imageView = [[CPImageView alloc] initWithFrame:CGRectMake(0,0, 200, 200)];
  [imageView setBackgroundColor:[CPColor colorWithHexString:@"FF0000"]];

  [imageView setImage:image];
  [imageView setImageScaling:CPScaleNone];

  return imageView;
}


//**************************************************************

// - (void)openCatalogManager:(id)sender
// {
//     CPLog(@"CatalogManagerWindowController:openCatalogManager");
//   _window = [[CatalogManagerWindow alloc] init];
//   // CPLog(@"theWindow: " + _window);
//   [super setWindow:_window];
//   [_window orderFront:self];
// }

////////////////////////////////////////////////////////////////
//  BROWSER DELEGATE METHODS
////////////////////////////////////////////////////////////////
// NB:  each is parameterized with the browser object,
// so one delegate can be used for multiple browswers
// REQUIRED:  (from _CPBrowserTableDelegate, delegate for table in each col)
// 	browser:numberOfChildrenOfItem:
// 	browser:child:ofItem:
// 	browser:objectValueForItem:
// 	browser:imageValueForItem:

// OPTIONAL:  (from _CPBrowserTableDelegate, delegate for table in each col)
// 	browser:acceptDrop:atRow:column:dropOperation:
// 	browser:validateDrop:proposedRow:column:dropOperation:
// 	browser:writeRowsWithIndexes:inColumn:toPasteboard:
// OPTIONAL:  (from CPBrowser)
// 	NB: first three take browser obj as single arg
// 	rootItemForBrowser:
// 	browserSelectionIsChanging:
// 	browserSelectionDidChange:
// 	browser:isLeafItem:
// 	browser:imageValueForItem:
// 	browser:didChangeLastColumn:toColumn:
// 	browser:didResizeColumn:
// 	browser:selectionIndexesForProposedSelection:inColumn:
// 	browser:shouldSelectRowIndexes:inColumn:
// 	browser:canDragRowsWithIndexes:inColumn:withEvent:
// 	browser:draggingImageForRowsWithIndexes:inColumn:withEvent:
// 	browser:draggingViewForRowsWithIndexes:inColumn:withEvent:offset:
////////////////////////////////////////////////////////////////

// REQUIRED
- (id)browser:(MIBrowser)browser child:(int)index ofItem:(id)item
{
  // CPLog("%@ %@ child: %@ of item: %@", self, browser, index,
  // 	[item objectForKey:@"Name"]);
  if (item === nil) {
    // root node always has CHILDREN
    var children = [dataSource objectForKey:@"CHILDREN"];
    return children[index];
  } else
    {
      if ([item objectForKey:@"FileType"] == kCOLLECTION) {
	var coll = [item objectForKey:@"CHILDREN"];
	if (typeof coll == "undefined") {
	  return nil;
	} else {
	  if (coll) {
	    return [coll objectAtIndex:index];
	  } else {
	    return nil;
	  }
	}
      } else {
	if ([item objectForKey:@"FileType"] == kINDIVIDUAL) {
	  return nil;
	}
      }
    }
}

// REQUIRED
- (int)browser:(MIBrowser)browser numberOfChildrenOfItem:(id)item
{
  // CPLog(@"%@ %@ numberOfChildrenOfItem %@", self, browser,
  // [item objectForKey:@"Name"]);

  if (item === nil) {  // ROOT item
    var kids = [dataSource objectForKey:@"CHILDREN"];
    var n = [kids count];
    return n;
  }

  if ([item objectForKey:@"FileType"] == kCOLLECTION) {
    var children = [item objectForKey:@"CHILDREN"];
    // FALSE means none, no fetch - return 0
    // TRUE means children not yet fetched - return 0
    // Otherwise, list of children
    if (children) {
      if (children.length) {
	return [[item objectForKey:@"CHILDREN"] count];
      } else {
	return 0;
      }
    } else {
      return 0;
    }
  } else {
    if ([item objectForKey:@"FileType"] == kINDIVIDUAL) {
      return 0;
    }
  }
}

// REQUIRED
- (void)browser:(MIBrowser)browser objectValueForItem:(id)item
{
  CPLog(@"%@ %@ objectValueForItem %@", self, browser, [item objectForKey:@"Name"]);
  if (item === nil) { // ROOT item?
    return nil;
  }

  if ( [item objectForKey:@"FileType"] == kCOLLECTION ) {
    return [item objectForKey:@"Name"];
  }

  if ( [item objectForKey:@"FileType"] == kINDIVIDUAL ) {
    return [item objectForKey:@"Name"];
  }
}

// REQUIRED
- (id)browser:(MIBrowser)browser imageValueForItem:(id)item
{
  // CPLog(@"%@ %@ imageValueForItem %s", self, browser, item);

  if (item === nil) {
    return nil;
  }

  if ([item objectForKey:@"FileType"] == kCOLLECTION) {
    return [[CPImage alloc]
    	     initWithContentsOfFile:[[CPBundle bundleForClass:[self class]]
				      pathForResource:@"NetworkFolderAsia.png"]
    				      // pathForResource:"CPApplication/Open.png"]
			       size:CGSizeMake(28, 28)];
  } else {
    if ([item objectForKey:@"DataType"] == "PARADIGM") {
      return [[CPImage alloc]
	       initWithContentsOfFile:[[CPBundle bundleForClass:[self class]]
					pathForResource:@"Document.png"]
				 size:CGSizeMake(28, 28)];
    }
  }
}

////////////////////////////////////////////////////////////////
// OPTIONAL (?) delegate methods

// isLeafItem override "has no effect" per apple docs
// - (BOOL)browser:(MIBrowser)browser isLeafItem:(id)item
// {
//   CPLog(@"%@ browser:isLeafItem %@", self, item);
//   if (item === nil) {
//     // CPLog(@"isLeaf:NO");
//     return NO;
//   } else {
//     if ( [item objectForKey:@"FileType"] == kCOLLECTION ) {
//       var children = [item objectForKey:@"CHILDREN"];
//       if (children) {
// 	return NO;
//       } else return YES;
//     } else {
//       if ( [item objectForKey:@"FileType"] == kINDIVIDUAL ) {
// 	return YES;
//       }
//     }
//   }
// }


- (id)browserSelectionIsChanging:(id)browser
{
  // CPLog(@"%@ %@ browserSelectionIsChanging", self, browser);
}

- (void)collection:(CatalogManagerWindowController)theCollection
	 didRead:(BOOL)didRead
     contextInfo:(id)aContextInfo
{
    // CPLog(@"%@:didRead doc %@ (%@)", self, theCollection, didRead);
    if (!didRead)
        return;

    // [[[self window] theBrowser] reloadColumn:0];
    [[CPNotificationCenter defaultCenter]
        postNotificationName:@"collectionWasFetched" object:nil];

    // CPLog(@"/%@ %@ didRead: %@", self, theCollection, didRead);
}

- (id)browserSelectionDidChange:(id)browser
{
  CPLog(@"%@ %@ browserSelectionDidChange", self, browser);
  var sel = [browser selectedItem];
  var col = [browser selectedColumn];
  var row = [browser selectedRowInColumn:col];
  CPLog(@"%@ selectedItem r %@ c %@: %@", self, row, col, [sel objectForKey:@"Name"]);

  //TESTING
  // CPLog(@"%@ nbr selected rows: %@", self, [browser numberSelectedRows]);

  // TODO:  get IndexPath and use to navigate dataSource

  if ( col < 0 )  sel = dataSource;

  if ( [sel objectForKey:@"FileType"] == kCOLLECTION ) {
    var children = [sel objectForKey:@"CHILDREN"];
    CPLog(@"%@ children: %@", self, children);

    // children either Y, N, or a list of entries
    // Y means it has children that have not been fetched yet
    // N means it has no children, so don't bother fetching
    // List means children already fetched, so just continue

    if (children.length) {
      CPLog(@"%@ children already fetched!", self);
      if ( col < 0 ) { [browser reloadColumn:0]; }
      return true;
    } else {
      if (children) { // children == true means kids to be fetched
	var key = "/home/" + [sel objectForKey:@"ID"];
	CPLog(@"%@ fetching collection children %@", self, key);

	var req = [CPURLRequest requestWithURL:key];
	[_readConnection cancel];
	CPLog(@"    ....sending XHR");
	var resp;
	var theDatum = [CPURLConnection sendSynchronousRequest:req returningResponse:resp];
	CPLog(@"%@ ajax data %@; result: %@", self, theDatum, resp);

	// var d = [CPData dataWithRawString:theDatum];
	var jsonObj = [theDatum JSONObject];
	var frag = [CPDictionary dictionaryWithJSObject:jsonObj recursively:YES];
	CPLog(@"%@ frag %@", self, frag);

	[sel setObject:[frag objectForKey:@"CHILDREN"] forKey:@"CHILDREN"];
	// CPLog(@"%@ datasource: %@", self, dataSource);

	return;

	var uri = [frag objectForKey:@"Name"];
	var nodes = [uri componentsSeparatedByString:@"/"];
	CPLog(@"%@ nodes: %@", self, nodes);
	var theArray = [dataSource];
	var res;
	var path = "";
	var i, j;
	for (i=1; i<[nodes count]; i++) {  // skip initial null node for root
	  path = path + "/" + [nodes objectAtIndex:i];
	  CPLog(@"%@ URI node: %@", self, path);
	  for (j=0; j<[theArray count]; j++) {
	    CPLog(@"%@ round %s", self, j);
	    var o = [theArray objectAtIndex:j];
	    if ( [o objectForKey:@"Name"] == path ) {
	      CPLog(@"%@ match item %@ for path %@", self, [o objectForKey:@"Name"], path);
	      var kids = [o objectForKey:@"CHILDREN"];
	      if (kids) {
		if (kids.length > 0) {
		  theArray = kids;
		} else {
		  break;
		}
	      } else {
		break;
	      }
	    }
	  }
	}
	[theArray replaceObjectAtIndex:(j) withObject:frag];
	CPLog(@"%@ datasource: %@", self, dataSource);
      } else {
	CPLog(@"%@ no children, so no fetch", self);
      }
    }
    CPLog(@"%@ %@ /browserSelectionDidChange", self, browser);
  }
}

- (void)onCollectionFetched:(CPNotification)aNotification
{
  CPLog(@"%@: onCollectionFetched %@", self, [aNotification object] );
  var done = [aNotification object];
    var w = [self window];
    var b = [w theBrowser];
    CPLog(@"%@ window: %@; browser: %@ (sending reloadColumn", self, w, b);
    // [b reloadColumn:0];
}

- (id)browser:(MIBrowser)browser didChangeLastColumn:(int)from toColumn:(int)to
{
  // CPLog(@"%@ %@ didChangeLastColumn from %@ to %@", self, browser, from, to);
  // if FileType == kCOLLECTION
}

- (id)browser:(MIBrowser)browser didResizeColumn:(id)col
{
  // CPLog(@"%@ browser:didResizeColumn %@", self, col);
  // return Yes;
}

/*
 * summaryViewForItem - display icon and metadata for selected doc in rightmost col
 */
- (id)browser:(MIBrowser)browser summaryViewForItem:(id)item
{
    // CPLog("CatalogManager: summaryViewForItem %@", item);

    //Step 1:  get type for doc

    //Step 2:  create view for doc type
    var view = [[CPBox alloc] initWithFrame:CGRectMake(0,0, 200, 300)];
    // [view setBorderColor:[CPColor blueColor]];
    // [view setBorderWidth:2];
    // [view setBorderType:CPBezelBorder];
    // [view setContentViewMargins:10];

    var image = [[CPImage alloc]
		    initWithContentsOfFile:[[CPBundle bundleForClass:[self class]]
    								       pathForResource:@"Edit-Paradigm.png"]
				      size:CGSizeMake(128,128)];
    // CPLog(@"MI: image size w %@ h %@", [image size].width, [image size].height);
    var imageView = [[CPImageView alloc] initWithFrame:CGRectMakeZero()];
    // [imageView setBackgroundColor:[CPColor grayColor]];
    [imageView setImage:image];
    [imageView setImageScaling:CPScaleNone];
    [imageView setBoundsSize:[image size]];
    [imageView setFrameSize:[image size]];
    // CPLog(@"%@: view center: %@ x %@", self, [view center].x, [view center].y);
    // CPLog(@"%@: imageView center: %@ x %@", self, [imageView center].x, [imageView center].y);
    [imageView setCenter:CGPointMake(100,100)]; //([view center].x)/2, 80)];
    [view addSubview:imageView];

    var x = 0, y = 175, lblw = 80, lblh = 20, txtw = 100, txth = 20;
    var fnszLabel = 12;

    var lblFileName = [[CPTextField alloc] initWithFrame:CGRectMake(x, y, lblw, lblh)];
    [lblFileName setFont:[CPFont boldSystemFontOfSize:fnszLabel]];
    [lblFileName setStringValue:"Filename:"];
    [lblFileName setAlignment:CPRightTextAlignment];
    [lblFileName setSelectable:NO];
    var txtFileName = [[CPTextField alloc] initWithFrame: CGRectMake(x+lblw, y, txtw, txth)];
    [txtFileName setStringValue:[item objectForKey:@"Name"]];
    [txtFileName setSelectable:YES];
    [txtFileName sizeToFit];
    [view addSubview:lblFileName];
    [view addSubview:txtFileName];

    var lblURI = [[CPTextField alloc] initWithFrame:CGRectMake(x, y+lblh, lblw, lblh)];
    [lblURI setFont:[CPFont boldSystemFontOfSize:fnszLabel]];
    [lblURI setStringValue:"URI:"];
    [lblURI setAlignment:CPRightTextAlignment];
    var txtURI = [[CPTextField alloc] initWithFrame: CGRectMake(x+lblw, y+txth, txtw, txth)];
    [txtURI setStringValue:[item objectForKey:@"Name"]];
    [txtURI setSelectable:YES];
    [txtURI sizeToFit];
    [view addSubview:lblURI];
    [view addSubview:txtURI];

    var lblFileType = [[CPTextField alloc] initWithFrame:CGRectMake(x, y+2*lblh, lblw, lblh)];
    [lblFileType setFont:[CPFont boldSystemFontOfSize:fnszLabel]];
    [lblFileType setStringValue:"Type:"];
    [lblFileType setAlignment:CPRightTextAlignment];
    var txtFileType = [[CPTextField alloc] initWithFrame: CGRectMake(x+lblw, y+2*txth, txtw, txth)];
    [txtFileType setStringValue:[item objectForKey:@"DataType"]];
    [txtFileType setSelectable:YES];
    [txtFileType sizeToFit];
    [view addSubview:lblFileType];
    [view addSubview:txtFileType];

    var lblFilesize = [[CPTextField alloc] initWithFrame:CGRectMake(x, y+3*lblh, lblw, lblh)];
    [lblFilesize setFont:[CPFont boldSystemFontOfSize:fnszLabel]];
    [lblFilesize setStringValue:"Size:"];
    [lblFilesize setAlignment:CPRightTextAlignment];
    var txtFilesize = [[CPTextField alloc] initWithFrame: CGRectMake(x+lblw, y+3*txth, txtw, txth)];
    [txtFilesize setStringValue:[item objectForKey:@"FileSize"]];
    [txtFilesize setSelectable:YES];
    [txtFilesize sizeToFit];
    [view addSubview:lblFilesize];
    [view addSubview:txtFilesize];

    var lblFileOwner = [[CPTextField alloc] initWithFrame:CGRectMake(x, y+4*lblh, lblw, lblh)];
    [lblFileOwner setFont:[CPFont boldSystemFontOfSize:fnszLabel]];
    [lblFileOwner setStringValue:"Owner:"];
    [lblFileOwner setAlignment:CPRightTextAlignment];
    var txtFileOwner = [[CPTextField alloc] initWithFrame: CGRectMake(x+lblw, y+4*txth, txtw, txth)];
    [txtFileOwner setStringValue:[item objectForKey:@"FileOwner"]];
    [txtFileOwner setSelectable:YES];
    [txtFileOwner sizeToFit];
    [view addSubview:lblFileOwner];
    [view addSubview:txtFileOwner];

    var lblLastMod = [[CPTextField alloc] initWithFrame:CGRectMake(x, y+5*lblh, lblw, lblh)];
    [lblLastMod setFont:[CPFont boldSystemFontOfSize:fnszLabel]];
    [lblLastMod setStringValue:"Modified:"];
    [lblLastMod setAlignment:CPRightTextAlignment];
    var txtLastMod = [[CPTextField alloc] initWithFrame: CGRectMake(x+lblw, y+5*txth, txtw, txth)];
    var dt = [item objectForKey:@"LastModified"];
    // var dt = [[CPDate alloc] initWithString:@"2010-01-01 12:12:00 +0000"];
    [txtLastMod setStringValue:dt];
    [txtLastMod setSelectable:YES];
    [txtLastMod sizeToFit];
    [view addSubview:lblLastMod];
    [view addSubview:txtLastMod];

    return view;
}


// MI OVERRIDE
- (id)browser:(MIBrowser)browser addTableColumn:(CPTableColumn)aTableColumn
{
  CPLog(@"%@ addTableColumn %@", self, aTableColumn);
  return [super addTableColumn:aTableColumn];
  // [aTableColumn setResizingMask:CPTableColumnNoResizing];
}

// - (int)browser:(MIBrowser)browser numberOfRowsInColumn:(id)item
// {
//   // CPLog(@"numberOfRowsInColumn %@", item);
//   if ([item objectForKey:@"FileType"] == kCOLLECTION) {

//   } else {
//     if ([item objectForKey:@"FileType"] == kINDIVIDUAL) {
//     } else {

//     }
//   }
// }

- (BOOL)browser:(MIBrowser *)sender willDisplayCell:(id)cell atRow:(CPInteger)row column:(CPInteger)column
{
  // CPLog("4 browser: willDisplayCell:atRow:%@:column:%@", row, column);
  if (column == 0) return NO;
  return YES;
  // return [item objectForKey:@"BaseName"];
}

//****************************************************************
//  END BROWSER DELEGATE METHODS
//****************************************************************

- (CFAction)handleSelection:(id)aSender
{
  CPLog(@"%@ handleSelection", self);
}

////////////////////////////////////////////////////////////////
// xhr connection delegate methods
- (void)connection:(CPURLConnection)aConnection didReceiveResponse:(CPURLResponse)aResponse
{
    CPLog(@"%@: didReceiveResponse", self);
}

- (void)connection:(CPJSONPConnection)theConnection didReceiveData:(Object)theDatum
{
  CPLog(@"%@: didReceiveData, length: %@ %@", self, [theDatum length], theDatum);
  //This method is called when an ASYNCHRONOUS connection receives a response. in a
  //multi-part request, this method will (eventually) be called multiple times,
  //once for each part in the response.

  // CURRENTLY we use synchronous connections to manage the browser gui,
  // so this is never executed

    var session = theConnection.session;
    if (theConnection == _readConnection)
    {
      CPLog(@"    ....didReceiveData on readConnection");
      // [self readFromData:[CPData dataWithRawString:theDatum] ofType:session.fileType error:nil];

      var browser = [[self window] theBrowser];
      var jstr = {"Name": "test4",
		  // "Path": "/home/test3/test3a",
		  "FileType": "folder",
		  "DataType": "",
		  "FileOwner": "",
		  "LastModified": "Dec 9, 2011 2:36:25 PM"};
      var d = [CPData dataWithRawString:theDatum];
      var jsonObj = [d JSONObject];
      var frag = [CPDictionary dictionaryWithJSObject:jsonObj recursively:YES];
      // CPLog(@"%@ frag %@", self, frag);
      var uri = [frag objectForKey:@"Name"];
      var nodes = [uri componentsSeparatedByString:@"/"];
      // CPLog(@"%@ cat: %@", self, dataSource);
      var theArray = [dataSource objectForKey:@"CHILDREN"];
      var res;
      var path = "";
      for (var i=1; i<[nodes count]; i++) {
	path = path + "/" + [nodes objectAtIndex:i];
	CPLog(@"%@ URI node: %@", self, path);
	// CPLog(@"%@ array: %@", self, theArray);
	// var pred = [CPPredicate predicateWithFormat:@"URI == %@", path];
	// res = [theArray filteredArrayUsingPredicate:pred];
	for (var j=0; j<[theArray count]; j++) {
	  var o = [theArray objectAtIndex:j];
	  if ( [o objectForKey:@"Name"] == path ) {
	    CPLog(@"%@ found item %@", self, o);
	    //	  theArray = [[res objectAtIndex:0] objectAtKey:@"CHILDREN"];
	    // var c = {"CHILDREN": [frag]};
	    // CPLog(@"%@ new children: %@", c);
	    [theArray replaceObjectAtIndex:j withObject:frag];
	    CPLog(@"%@ modified item %@", self, theArray);
	  }
	}
      }

      objj_msgSend(session.delegate,
      		   session.didReadSelector,
      		   self,
      		   YES,
      		   session.contextInfo);
    }
    else
    {
      CPLog(@"    ....didReceiveData on non-readConnection");
      // CPLog(@"    ....session.saveOp: %@", session.saveOperation);
      // CPLog(@"    ....CPSaveToOperation: %@", CPSaveToOperation);
        if (session.saveOperation != CPSaveToOperation)
            [self setFileURL:session.absoluteURL];
        _writeRequest = nil;
        objj_msgSend(session.delegate, session.didSaveSelector, self, YES, session.contextInfo);
        [self _sendDocumentSavedNotification:YES];
    }
    CPLog(@"/%@: didReceiveData", self);
}

- (void)connectionDidFinishLoading:(CPURLConnection)theConnection
{
    CPLog(@"%@: connectionDidFinishLoading conn %@", self, theConnection);
    var w = [self window];
    var b = [w theBrowser];
    CPLog(@"%@ window: %@; browser: %@ (sending reloadColumn", self, w, b);
    // [b reloadColumn:0];
    CPLog(@"/%@: connectionDidFinishLoading\n", self);
}

- (void)connection:(CPJSONPConnection)connection didFailWithError:(CPString)error
{
  //This method is called if the request fails for any reason.
  CPLog(@"didFailWithError " + error);
}

@end ////////////////////////////////////////////////////////////////
var _CPReadSessionMake = function(aType, aDelegate, aDidReadSelector, aContextInfo)
{
    return { fileType:aType, delegate:aDelegate, didReadSelector:aDidReadSelector, contextInfo:aContextInfo };
}
