/*
 * 
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "MorphPropertyInspector.j"
@import "AamaDocumentController.j"
@import "MorphPropertyInspectorWindow.j"
@import "LPMultiLineTextField.j"

@implementation MorphPropertyInspectorWindowController : CPWindowController
{
  // superclass holds refs to window and doc(s), etc.
  CPMutableArray dataSource @accessors(name=properties);
  CPURLConnection _readConnection;
  CPURLRequest        _writeRequest;
}

// - (id)init
// {
//   CPLog(@"%@: init", self);
//   [super init];
//   CPLog(@"%@: init", self);
//   return self;
// }

//{DEBUG
- (id)initWithWindow:(CPWindow)aWindow
{
    CPLog(@"%@: initWithWindow %@", self, aWindow);
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
//   // CPLog(@"%@ window", self);
//   // super implementation calls [self loadWindow] if it doesn't already exist
//   return [super window];
// }
// //DEBUG}

// //{DEBUG
// - (CPDocument)document
// {
//   CPLog(@"%@.document", self);
//     return _document;
// }
// //DEBUG}

- (CFAction)miniaturize:(id)sender
{
  // CPLog(@"%@:miniaturize", self);
}

- (void)refresh:(id)aSender
{
  CPLog(@"%@ refresh", self);
  // [[[self window] document] refresh:aSender];
}

- (CFAction)refreshButtonPush:(id)theDoc
{
  CPLog(@"%@: refreshButtonPush doc: %@", self, theDoc);
  // 1. find window for theDoc
  [[self window] refreshButtonPush:self];
}
- (CFAction)refreshButtonPop:(id)theDoc
{
  CPLog(@"%@: refreshButtonPop doc: %@", self, theDoc);
  // 1. find window for theDoc
  [[self window] refreshButtonPop:self];
}

- (void)setDocument:(CPDocument)document
{
    CPLog(@"%@: setDocument %@", self, document);
    // the super impl is complicated: registers notifications, calls addDocument, isDocumentEdited
    // in particular, calls [self window] to steup toolbar; side-effect is that
    // window gets created if not already created
    // why setDocument has anything to do with windows is another question
    // should be factored out to setWindowForDocument
    [super setDocument:document];
    dataSource = [document properties];
    [[[self window] theBrowser] setDelegate:self];

    // [_window setDelegate:document];
    // [_cmWindow showData];
    // [_cmWindow orderFront:self];
    CPLog(@"/%@: /setDocument %@", self, document);
}

// - (void)setWindowForDocument:(CPDocument)document
// {
//   CPLog(@"%@: setWindowForDocument", self);
//   [super setWindowForDocument];
//   // if we were to refactor, this would be called after setDocument
//   // the implementation would be the same as CPWindowController.window, plus
//   // any code needed to frob the window decorations, etc
// }

- (CFAction)closeDocument  //:(id)aSender
{
  // CPLog(@"%@: closeDocument", self);
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
//     CPLog(@"%@:Window", self);
//     [super window];
// }
//DEBUG}

- (void)openMorphPropertyInspector:(id)sender
{
  CPLog(@"%@: openMorphPropertyInspector", self);
  _window = [[MorphPropertyInspectorWindow alloc] init];
  // CPLog(@"theWindow: " + _window);
  [super setWindow:_window];
  [_window orderFront:self];
}

- (void)alertDidEnd:(CPAlert)alert returnCode:(int)returnCode contextInfo:(void)contextInfo {
  if (returnCode == CPAlertFirstButtonReturn) {
  }
}

////////////////////////////////////////////////////////////////
////  WINDOW NOTIFICATIONS
////////////////////////////////////////////////////////////////
-(void)windowDidResize:(CPNotification)notification
{
  CPLog(@"%@ windowDidResize", self);
}

////////////////////////////////////////////////////////////////
////  WINDOW DELEGATION METHODS
////////////////////////////////////////////////////////////////
-(void)windowDidResignMain:(CPNotification)notification
{
  // CPLog(@"%@ windowDidResignMain", self);
  [CPApp setState:CPOffState forWindow:[self window]];
  [[self window] setAlphaValue:0.7];
}

-(void)windowDidBecomeMain:(CPNotification)notification
{
  // CPLog(@"%@ windowDidBecomeMain", self);
  [CPApp setState:CPOnState forWindow:[self window]];
  [[self window] setAlphaValue:1.0];
  // CPLog(@"/%@ /windowDidBecomeMain", self);
}

-(void)windowDidResignKey:(CPNotification)notification
{
  // CPLog(@"%@ windowDidResignKey", self);
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

////////////////////////////////////////////////////////////////
//  BROWSER DELEGATE METHODS
////////////////////////////////////////////////////////////////
// - (void)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)column row:(unsigned)row
//     [_delegate browser:_browser objectValueForItem:[self childAtIndex:row]];
// [_delegate browser:_browser acceptDrop:info atRow:row column:_index dropOperation:operation];
// [_delegate browser:_browser validateDrop:info proposedRow:row column:_index dropOperation:operation];
// [_delegate browser:_browser writeRowsWithIndexes:rowIndexes inColumn:_index toPasteboard:pboard];
// [_delegate respondsToSelector:@selector(browser:writeRowsWithIndexes:inColumn:toPasteboard:)];

// browser:self selectionIndexesForProposedSelection:indexSet inColumn:column];
// browser:self shouldSelectRowIndexes:indexSet inColumn:column])
// [_delegate browserSelectionIsChanging:self];
// [_delegate browserSelectionDidChange:self];
// return [_delegate browser:self canDragRowsWithIndexes:rowIndexes inColumn:columnIndex withEvent:dragEvent];
// return [_delegate browser:self draggingImageForRowsWithIndexes:rowIndexes inColumn:columnIndex withEvent:dragEvent offset:dragImageOffset];
// return [_delegate browser:self draggingViewForRowsWithIndexes:rowIndexes inColumn:columnIndex withEvent:dragEvent offset:dragImageOffset];
// _rootItem = [_delegate rootItemForBrowser:self];

- (id)browserSelectionIsChanging:(id)browser
{
  // CPLog(@"%@ browserSelectionIsChanging", self);
}

- (id)browserSelectionDidChange:(id)browser
{
  CPLog(@"%@ %@ browserSelectionDidChange", self, browser);
  var sel = [browser selectedItem];
  var col = [browser selectedColumn];
  var row = [browser selectedRowInColumn:col];
  CPLog(@"%@ selectedItem r %@ c %@: %@", self, row, col, sel);
  console.log(sel);
	// [sel objectForKey:@"Lang"]);

  //TESTING
  // CPLog(@"%@ nbr selected rows: %@", self, [browser numberSelectedRows]);

  // TODO:  get IndexPath and use to navigate dataSource

  // return;

  // if ( col < 0 )  sel = dataSource;

  // if ( [sel objectForKey:@"FileType"] == kCOLLECTION ) {
    var children = sel.CHILDREN;
    if (typeof children == "undefined") {
      CPLog(@"%@ selection is leaf, has no children", self);
      return;
    }
    CPLog(@"%@ children of selection:", self); console.log(children);

  //   // children either Y, N, or a list of entries
  //   // Y means it has children that have not been fetched yet
  //   // N means it has no children, so don't bother fetching
  //   // List means children already fetched, so just continue

    if (children.length > 0) {
      CPLog(@"%@ children already fetched!", self);
      if ( col < 0 ) { [browser reloadColumn:0]; }
      CPLog(@"%@ /browserSelectionDidChange", self);
      return true;
    } else {
      // var key = "/aama/" + sel.LANG + "/" + sel.uri.value;
      var key = "/aama/" + sel.LANG + "/" + sel.TYPE;
      if (sel.TYPE === "PTYPE") key = key + "/" + sel.uri.value;
      if (sel.TYPE === "LEXEME") key = key + "/" + sel.uri.value;
      CPLog(@"%@ fetching collection children %@", self, key);

      var req = [CPURLRequest requestWithURL:key];
      [_readConnection cancel];
      var resp;

      CPLog(@"    ....sending XHR %@", key);
      var theDatum = [CPURLConnection sendSynchronousRequest:req returningResponse:resp];
      CPLog(@"%@ ajax data %@; result: %@", self, theDatum, resp);
      var props = [theDatum JSONObject];
      console.log(props);
      // var hdr = props["head"]["vars"];
      // var bindings = props["results"]["bindings"];
      // CPLog(@"%@ bindings: %@", self, bindings.length);
      // [sel  setValue:props forKey:@"CHILDREN"];
      sel.CHILDREN = props;
      return;

	var props = [[CPMutableArray alloc] init];
	for (var i=0; i < bindings.length; i++) {
	  var prop = [[CPMutableDictionary alloc] init];
	  // console.log("i: ", bindings[i].key.value);
    
	  [prop setValue:bindings[i].key.value forKey:@"key"];
	  [prop setValue:nil forKey:@"CHILDREN"];
	  [props addObject:prop];
	}

	[sel  setValue:props forKey:@"CHILDREN"];

  	// var jsonObj = [theDatum JSONObject];
  	// var frag = [CPDictionary dictionaryWithJSObject:jsonObj recursively:YES];
  	// CPLog(@"%@ frag %@", self, frag);
  	// [sel setObject:[frag objectForKey:@"CHILDREN"] forKey:@"CHILDREN"];

  	// CPLog(@"%@ datasource: %@", self, dataSource);

  	return;
    }
  // 	var uri = [frag objectForKey:@"Name"];
  // 	var nodes = [uri componentsSeparatedByString:@"/"];
  // 	CPLog(@"%@ nodes: %@", self, nodes);
  // 	var theArray = [dataSource];
  // 	var res;
  // 	var path = "";
  // 	var i, j;
  // 	for (i=1; i<[nodes count]; i++) {  // skip initial null node for root
  // 	  path = path + "/" + [nodes objectAtIndex:i];
  // 	  CPLog(@"%@ URI node: %@", self, path);
  // 	  for (j=0; j<[theArray count]; j++) {
  // 	    CPLog(@"%@ round %s", self, j);
  // 	    var o = [theArray objectAtIndex:j];
  // 	    if ( [o objectForKey:@"Name"] == path ) {
  // 	      CPLog(@"%@ match item %@ for path %@", self, [o objectForKey:@"Name"], path);
  // 	      var kids = [o objectForKey:@"CHILDREN"];
  // 	      if (kids) {
  // 		if (kids.length > 0) {
  // 		  theArray = kids;
  // 		} else {
  // 		  break;
  // 		}
  // 	      } else {
  // 		break;
  // 	      }
  // 	    }
  // 	  }
  // 	}
  // 	[theArray replaceObjectAtIndex:(j) withObject:frag];
  // 	CPLog(@"%@ datasource: %@", self, dataSource);
  //     } else {
  // 	CPLog(@"%@ no children, so no fetch", self);
  //     }
  //   }
  //   CPLog(@"%@ %@ /browserSelectionDidChange", self, browser);
  // }
}

- (id)browser:(CPBrowser)browser didChangeLastColumn:(int)from toColumn:(int)to
{
  CPLog(@"%@ browser:didChangeLastColumn from %@ to %@", self, from, to);
}

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
  // CPLog(@"/%@: viewForItem:forView", self);
}

- (id)browser:(CPBrowser)browser didResizeColumn:(id)col
{
  // return Yes;  
}

- (id)Xbrowser:(CPBrowser)browser imageValueForItem:(id)item
{
  // CPLog("%@: delegate: browser:imageValueForItem %@", self, self);
  if (item === nil) {
    return nil;
  }
  if (item === @"foo") {
    return [[CPImage alloc]
    	     initWithContentsOfFile:[[CPBundle bundleForClass:[self class]]
    								       pathForResource:@"Reload.png"]
    			       size:CGSizeMake(28, 28)];
  }

  if (CPStringFromClass([item class]) == @"CPString") {
    // if ([item objectForKey:@"DataType"] == "PDGM") {
      return [[CPImage alloc]
 	       initWithContentsOfFile:[[CPBundle bundleForClass:[self class]]
    								       pathForResource:@"Document.png"]
 				 size:CGSizeMake(28, 28)];
  } else {
    return [[CPImage alloc]
    	     initWithContentsOfFile:[[CPBundle bundleForClass:[self class]]
    								       pathForResource:@"NetworkFolderAsia.png"]
    			       size:CGSizeMake(28, 28)];
  }
}

/* analyze button action: analyze */
- (void)analyze:(id)sender
{
  CPLog(@"%@: analyze %@", self, sender);
  //either send a notification or call into doc controller directly
}

/*
 * summaryViewForItem - display icon and metadata for selected doc in rightmost col
 */
// TODO:  THIS IS TYPE-DEPENDENT!  NEED CUSTOM VIEW FOR EACH ITEM TYPE!!!!
- (id)browser:(CPBrowser)browser summaryViewForItem:(id)item
{
    CPLog("%@: summaryViewForItem %@", self, item);
    console.log(item);

    //Step 1:  get type for item

    //Step 2:  fetch item detail data

    //Step 3:  create view for item type
    var view = [[CPBox alloc] initWithFrame:CGRectMake(0,0, 200, 300)];
    // [view setBorderColor:[CPColor blueColor]];
    // [view setBorderWidth:2];
    // [view setBorderType:CPBezelBorder];
    // [view setContentViewMargins:10];

    // var image = [[CPImage alloc]
    // 		    initWithContentsOfFile:[[CPBundle bundleForClass:[self class]]
    // 								       pathForResource:@"Edit-Paradigm.png"]
    // 				      size:CGSizeMake(128,128)];
    // // CPLog(@"%@    image size w %@ h %@", self, [image size].width, [image size].height);
    // var imageView = [[CPImageView alloc] initWithFrame:CGRectMakeZero()];
    // // [imageView setBackgroundColor:[CPColor grayColor]];
    // [imageView setImage:image];
    // [imageView setImageScaling:CPScaleNone];
    // [imageView setBoundsSize:[image size]];
    // [imageView setFrameSize:[image size]];
    // // CPLog(@"%@: view center: %@ x %@", self, [view center].x, [view center].y);
    // // CPLog(@"%@: imageView center: %@ x %@", self, [imageView center].x, [imageView center].y);
    // [imageView setCenter:CGPointMake(100,100)]; //([view center].x)/2, 80)];
    // [view addSubview:imageView];

    btnAnalyze = [[CPButton alloc] initWithFrame:CGRectMake(0,50, 80, 24)];
    [btnAnalyze setTag:@"ANALYZE"];
    [btnAnalyze setTitle:"Analyze"];
    [btnAnalyze setBezelStyle:CPRoundedBezelStyle];
    [btnAnalyze setAction:@selector(analyze:)];
    [btnAnalyze setTarget:self];
    // [btnAnalyze setBoundsSize:[image size]];
    // [btnAnalyze setFrameSize:[image size]];
    [btnAnalyze setCenter:CGPointMake(100,100)]; //([view center].x)/2, 80)];
    [view addSubview:btnAnalyze];

    var x = 0, y = 175, lblw = 80, lblh = 20, txtw = 100, txth = 20;
    var fnszLabel = 12;
    
    var lblFileName = [[CPTextField alloc] initWithFrame:CGRectMake(x, y, lblw, lblh)];
    [lblFileName setFont:[CPFont boldSystemFontOfSize:fnszLabel]];
    [lblFileName setStringValue:"Lexeme:"];
    [lblFileName setAlignment:CPRightTextAlignment];
    [lblFileName setSelectable:NO];
    var txtFileName = [[CPTextField alloc] initWithFrame: CGRectMake(x+lblw, y, txtw, txth)];
    // [txtFileName setStringValue:[item objectForKey:@"BaseName"]];
    [txtFileName setStringValue:[item.key["value"]]];
    [txtFileName setSelectable:YES];
    [txtFileName sizeToFit];
    [view addSubview:lblFileName];
    [view addSubview:txtFileName];

    var lblURI = [[CPTextField alloc] initWithFrame:CGRectMake(x, y+lblh, lblw, lblh)];
    [lblURI setFont:[CPFont boldSystemFontOfSize:fnszLabel]];
    [lblURI setStringValue:"URI:"];
    [lblURI setAlignment:CPRightTextAlignment];
    var txtURI = [[CPTextField alloc] initWithFrame: CGRectMake(x+lblw, y+txth, txtw, txth)];
    // [txtURI setStringValue:[item objectForKey:@"URI"]];
    [txtURI setSelectable:YES];
    [txtURI sizeToFit];
    [view addSubview:lblURI];
    [view addSubview:txtURI];

    var lblFileType = [[CPTextField alloc] initWithFrame:CGRectMake(x, y+2*lblh, lblw, lblh)];
    [lblFileType setFont:[CPFont boldSystemFontOfSize:fnszLabel]];
    [lblFileType setStringValue:"Type:"];
    [lblFileType setAlignment:CPRightTextAlignment];
    var txtFileType = [[CPTextField alloc] initWithFrame: CGRectMake(x+lblw, y+2*txth, txtw, txth)];
    // [txtFileType setStringValue:[item objectForKey:@"DataType"]];
    [txtFileType setSelectable:YES];
    [txtFileType sizeToFit];
    [view addSubview:lblFileType];
    [view addSubview:txtFileType];

    var lblFilesize = [[CPTextField alloc] initWithFrame:CGRectMake(x, y+3*lblh, lblw, lblh)];
    [lblFilesize setFont:[CPFont boldSystemFontOfSize:fnszLabel]];
    [lblFilesize setStringValue:"Size:"];
    [lblFilesize setAlignment:CPRightTextAlignment];
    var txtFilesize = [[CPTextField alloc] initWithFrame: CGRectMake(x+lblw, y+3*txth, txtw, txth)];
    // [txtFilesize setStringValue:[item objectForKey:@"FileSize"]];
    [txtFilesize setSelectable:YES];
    [txtFilesize sizeToFit];
    [view addSubview:lblFilesize];
    [view addSubview:txtFilesize];

    var lblFileOwner = [[CPTextField alloc] initWithFrame:CGRectMake(x, y+4*lblh, lblw, lblh)];
    [lblFileOwner setFont:[CPFont boldSystemFontOfSize:fnszLabel]];
    [lblFileOwner setStringValue:"Owner:"];
    [lblFileOwner setAlignment:CPRightTextAlignment];
    var txtFileOwner = [[CPTextField alloc] initWithFrame: CGRectMake(x+lblw, y+4*txth, txtw, txth)];
    // [txtFileOwner setStringValue:[item objectForKey:@"FileOwner"]];
    [txtFileOwner setSelectable:YES];
    [txtFileOwner sizeToFit];
    [view addSubview:lblFileOwner];
    [view addSubview:txtFileOwner];

    var lblLastMod = [[CPTextField alloc] initWithFrame:CGRectMake(x, y+5*lblh, lblw, lblh)];
    [lblLastMod setFont:[CPFont boldSystemFontOfSize:fnszLabel]];
    [lblLastMod setStringValue:"Modified:"];
    [lblLastMod setAlignment:CPRightTextAlignment];
    var txtLastMod = [[CPTextField alloc] initWithFrame: CGRectMake(x+lblw, y+5*txth, txtw, txth)];
    // var dt = [item objectForKey:@"LastModified"];
    // var dt = [[CPDate alloc] initWithString:@"2010-01-01 12:12:00 +0000"];
    // [txtLastMod setStringValue:dt];
    [txtLastMod setSelectable:YES];
    [txtLastMod sizeToFit];
    [view addSubview:lblLastMod];
    [view addSubview:txtLastMod];

    return view;
}

- (id)browser:(CPBrowser)browser addTableColumn:(CPTableColumn)aTableColumn
{
  // CPLog(@"%@: addTableColumn", self);
  // [aTableColumn setResizingMask:CPTableColumnNoResizing];
}

- (id)browser:(CPBrowser)browser child:(int)index ofItem:(id)item
{
  CPLog("%@ browser: child:%@ of item %@", self, index, item); // ofItem: %@", index) //, item);
  // console.log(item);
  var child;
  try {
    if (item === nil) {
      child = dataSource[index];
    } else {
      child = item.CHILDREN[index];
    }
  }
  catch(e) {
    CPLog(@"%@ EXCEPTION: browser:%@ child:%@ ofItem:%@", self, browser, child, item);
    console.log(e);
  }
  CPLog(@"%@ /child:%@ is %@", self, index, child);
  console.log(child);
  return child;
}

- (int)browser:(CPBrowser)browser numberOfRowsInColumn:(id)item
{
  // CPLog(@"%@ numberOfRowsInColumn %@", self, item);
}

- (int)browser:(CPBrowser)browser numberOfChildrenOfItem:(id)item
{
  CPLog(@"%@ numberOfChildrenOfItem %@", self, item);
  //console.log(item);
  var n;
  try {
    if (item === nil) {
      n = [dataSource count];
    } else {
      if (item.CHILDREN) {
	n = item.CHILDREN.length;
      } else {
	n = 0;
      }
    }
  }
  catch(e) {
    CPLog(@"%@ browser:%@ numberOfChildrenOfItem:%@", self, browser, item);
    console.log(e);
  }
  CPLog(@"%@ browser:numberOfChildrenOfItem %@", self, n);
  return n;
}

- (BOOL)browser:(CPBrowser)browser isLeafItem:(id)item
{
  CPLog(@"%@ isLeafItem: %@", self, item);
  console.log(item);
  var answer;
  if (item === nil) {
    answer = NO;
  } else {
    // if (CPStringFromClass([item class]) == @"CPString") {
    CPLog(@"%@ kids %@", self, item.CHILDREN);
    if (item.CHILDREN) {
      answer = NO;
    } else {
      answer = YES;
    }
  }
  CPLog(@"%@ leaf item? %@", self, answer);
  return answer;
}

- (BOOL)browser:(CPBrowser *)sender willDisplayCell:(id)cell atRow:(CPInteger)row column:(CPInteger)column
{
  // CPLog("4 browser: willDisplayCell:atRow:%@:column:%@", row, column);
  if (column == 0) return NO;
  return YES;
  // return [item objectForKey:@"BaseName"];
}

- (void)browser:(CPBrowser)sender objectValueForItem:(id)item
{
  // CPLog("%@ 5 browser: objectValueForItem %@", self, item);  console.log(item);
  if (item === nil) {
    return nil;
  }
  var obj;
  // if (CPStringFromClass([item class]) == @"CPString") {
  //   obj = item;
  // } else {
  //   // obj = [item objectForKey:@"key"];
  // }
  obj = item.key.value;

  CPLog(@"%@ objectValueForItem %@", self, obj); 
  return obj;
  
}

@end ////////////////////////////////////////////////////////////////


