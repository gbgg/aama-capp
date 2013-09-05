/*
 * MorphPropertyInspector - contains both controller and windows controlled for managing library of docs (i.e. a filesystem)
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "AamaDocumentController.j"
@import "MorphPropertyInspectorWindow.j"
@import "MorphPropertyInspectorWindowController.j"
// @import "Frameworks/LPKit/LPCrashReporter.j"

OPEN=1;
SAVE=2;
NEWFOLDER=3;
DATA=4;
OUTLINE=5;
FILENAME=6;

var _CPStandardWindowViewMinimizeButtonImage                = nil;


//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@implementation MorphPropertyInspector : CPDocument

{
  CPMutableArray __properties @accessors(property=properties);
}

/*!
    Initializes an empty document.
    @return the initialized document
*/
- (id)init
{
  // CPLog(@"%@: init", self);
  self = [super init];

  // testServer = @"http://minkdev.appspot.com/aamadav";
  // localServer= @"http://localhost:8088/aamadav/";
  // _cmWindow = [[MorphPropertyInspectorWindow alloc] init];
  // 			// initWithFrame:CGRectMake(20,100, 400, 200)];
  // [_cmWindow setDelegate:self];
  // CPLog(@"/%@: init", self);
  return self;
}

  /**
   * initWithType is for new docs
   */
- (id)initWithType:(CPString)aType error:({CPError})anError
{
  // CPLog(@"%@: initWithType:%@", self, aType);
  [super init];
  return self;
}

// Called indirectly by document, via didRead (from doc controller)
- (void)makeWindowControllers
{
  CPLog(@"%@: makeWindowControllers", self);
  [super makeWindowControllers]; // calls makeViewAndWindowControllers
  var ok = NO,
    count = [_windowControllers count];
  // CPLog(@"%@: makeWindowControllers count %@", self, count);
  for (; index < count; ++index) {
      var theWC = _windowControllers[index];
      // CPLog(@"    %@: makeWindowControllers controller %@", self, theWC);
      if ([theWC document] == self) {
	ok = YES;
	break;
      }
  }

  if (ok == NO) { // expected outcome for programmatically controlled windows
    CPLog(@"    creating primary window");
    // _window = [[MorphPropertyInspectorWindow alloc] init];
    // calculate positioning of new window:
    var docs = [CPSharedDocumentController documents]; 
    // CPLog(@"    app doc count: %@", [docs count]);
    var nWins = 0;
    for (var i=0; i<[docs count]; i++) {
      nWins = nWins + [[[docs objectAtIndex:i] windowControllers] count];
    }
    // CPLog(@"    doc window count: %@", nWins);
    var menuBarH = [[CPApp mainMenu] menuBarHeight];
    _window = [[MorphPropertyInspectorWindow alloc]
		initWithContentRect:CGRectMake( (nWins)*menuBarH, (nWins+2)*menuBarH, 800, 400)
			  styleMask:
		  CPTitledWindowMask
		| CPMiniaturizableWindowMask
		| CPMaximizableWindowMask
		| CPRefreshableWindowMask
		| CPClosableWindowMask
		| CPResizableWindowMask];

      var theWindowController = [[MorphPropertyInspectorWindowController alloc] initWithWindow:_window];

    if (theWindowController)
	[self addWindowController:theWindowController];
  } else {
    CPLog(@"    Property Inspector primary window already exists");
  }

  if ( [[self windowControllers] count] > 1 ) {
    t = [CPString stringWithFormat:@"Property Inspector \(%@\)", [[self windowControllers] count]];
  } else {
    t = @"Property Inspector";
  }

  // CPLog(@"    window title %@", t);
  [_window setTitle:t];
  [CPApp addWindowsItem:_window title:t filename:NO];

  // [theWindowController synchronizeWindowTitleWithDocumentName];
  CPLog(@"/%@: /makeWindowControllers", self);
}

//{DEBUG
- (void)addWindowController:(CPWindowController)aWindowController
{
  // CPLog(@"%@: addWindowController %@", self, aWindowController);
  [_windowControllers addObject:aWindowController];

  if ([aWindowController document] !== self) {
    [aWindowController setDocument:self];
  }
  // CPLog(@"/%@: addWindowController %@", self, aWindowController);
}
//DEBUG}
- (void)performMiniaturize:(id)aSender
{
  // CPLog(@"%@ performMiniaturize", self);
  [self miniaturize:aSender];
}

- (void)canCloseDocumentWithDelegate:(id)aDelegate shouldCloseSelector:(SEL)aSelector contextInfo:(Object)context
{
  CPLog(@"%@ canCloseDocumentWithDelegate %@", self, aDelegate);
    if (![self isDocumentEdited])
        return [aDelegate respondsToSelector:aSelector] && objj_msgSend(aDelegate, aSelector, self, YES, context);

    // default implementation in CPDocument.j displays standard Close dialog

    CPLog(@"**** TODO:  show save dialog ****");

    // [self saveDocument:self];
    // return YES after saving
  CPLog(@"%@ canCloseDocumentWithDelegate %@ shouldCloseSelector %@", self, aDelegate, aSelector);
}

// - (void)performClose:(id)sender
// {
//   CPLog(@"%@:performClose:sender", self);
//   [super performClose:sender];
// }

-(CFAction)removeItem:(id)sender
{
  var theItem = [sender selectedItem];
  // CPLog(@"%@ removeItem: %@", self, theItem);
  // var selectedColumn = [theBrowser selectedColumn],
  //   selectedRow = [theBrowser selectedRowInColumn:selectedColumn];
  // CPLog("%@ col: %@ row: %@", self, selectedColumn, selectedRow);
  // [theBrowser reloadColumn:selectedColumn];

  // [_cmWindow makeKeyAndOrderFront:self];
}

// -(void)show
// {
//     [self reloadDocData:self];
// }

//{DEBUG
/**
 * initWithContentsOfURL - for opening existing docs
 *  NB:  the signature is different than in Cocoa, which is
 *     initWithContentsOfURL:ofType:error
 */
// - (id)initWithContentsOfURL:(CPURL)anAbsoluteURL
// 		     ofType:(CPString)aType
// 		   delegate:(id)aDelegate
// 	    didReadSelector:(SEL)aDidReadSelector
// 		contextInfo:(id)aContextInfo
// {
//     CPLog(@"%@: initWithContentsOfURL %@ of type %@, delegate: %@", self, anAbsoluteURL, aType, aDelegate);
//     // calls readFromURL

//     var doc =  [super initWithContentsOfURL:anAbsoluteURL
// 				     ofType:aType
// 				   delegate:self
// 			    didReadSelector:aDidReadSelector
// 				contextInfo:aContextInfo];
//     CPLog(@"/%@:initWithContentsOfURL", self);
//     return self;
// }
//DEBUG}

//{DEBUG
- (void)readFromURL:(CPURL)anAbsoluteURL
	     ofType:(CPString)aType
	   delegate:(id)aDelegate
    didReadSelector:(SEL)aDidReadSelector
	contextInfo:(id)aContextInfo
{
    CPLog(@"%@: readFromURL: %@ \n\t\t type: %@ \n\t\t delegate: %@ \n\t\t selector: %@",
	  self, anAbsoluteURL, aType, aDelegate, aDidReadSelector);
    [[self windowControllers] makeObjectsPerformSelector:@selector(refreshButtonPush:) withObject:self];
    // called at startup; stack:
    // doc: initWithContentsOfURL
    // dc: makeDocumentWithContentsOfURL
    // dc: openDocumentWithContentsOfURL
    // dc: openTheDocument
    [_readConnection cancel];

    // FIXME: Oh man is this every looking for trouble, we need to handle login at the Cappuccino level, with HTTP Errors.
    var req = [CPURLRequest requestWithURL:anAbsoluteURL];

    // NB!!  use SELF as both delegates (XHR and didRead) - i.e. ignore aDelegate arg
    var xhrDelegate = self;
    var didReadDelegate = self;
    _readConnection = [CPURLConnection connectionWithRequest:req delegate:xhrDelegate];
    _readConnection.session = _CPReadSessionMake(aType, didReadDelegate, aDidReadSelector, aContextInfo);

    // _readConnection.session = _CPReadSessionMake(aType, aDelegate, aDidReadSelector, aContextInfo);
    //  Why not hardcode this?  e.g.
    //_readConnection.session = _CPReadSessionMake(@"catalog", self, @selector(catalog:didRead:contextInfo:), nil);
    // CPLog(@"/%@: readFromURL", self);
}
//DEBUG}

////////////////////////////////////////////////////////////////
- (CFAction)orderFront:(id)theDoc
{
  CPLog(@"%@: orderFront", self);
  [_window orderFront:self];
}

-(CFAction)refresh:(id)sender
{
  // CPLog("%@: refresh action", self);
    [self refresh];
}

//TODO:  convert to openDocumentWithContentsOfURL
-(CFAction)refresh
{
    // CPLog("%@: refresh method", self);

    [self readFromURL:[self fileURL]
	       ofType:[self fileType]
	     delegate:self
      didReadSelector:@selector(document:didRead:contextInfo:)
	  contextInfo:[CPDictionary dictionaryWithObject:true
						  forKey:@"shouldDisplay"]];
    return;
    
  var localServer= @"/aamadav/";
  // var localServer=@"http://localhost:8088/aamadav/";

  var aRequest = [CPURLRequest requestWithURL:[[CPURL alloc] initWithString:localServer]];

  [_readConnection cancel];

  //switch on the progress spinner in window titlebar
  [[self windowControllers] makeObjectsPerformSelector:@selector(refreshButtonPush:) withObject:self];
  // [_cmWindow refreshButtonPush:self];

 //FIXME:  add timeout logic in case host unavailable
  CPLog(@"%@ refresh: sending XHR", self);
  _readConnection = [CPURLConnection connectionWithRequest:aRequest delegate:self];

  _readConnection.session = _CPReadSessionMake(@"catalog", self, @selector(document:didRead:contextInfo:), nil);

  // CPLog("%@: refresh", self);
  return;
}

//{DEBUG
- (void)showWindows
{
    // CPLog(@"%@/: showWindows", self);
  // showWindows creates windows if they don't already exist
  //super: foreach elt in _windowControllers array, runs setDocument and showWindow with self as arg
  // setDocument runs addDocument if needed
  // showWindow which creates window (via loadWindow) if needed 
  [super showWindows];
  // [_docWinController showWindow];
}

////////////////
// document DID READ
// In a "local doc", the data is fetched, then the doc added, then makeWindowControllers, then showWindows
// since our data fetch is asynchronous, we wait until didread to add doc, make WCs, then show
- (void)document:(CPDocument)aDocument
	 didRead:(BOOL)didRead
     contextInfo:(id)aContextInfo
{
  CPLog(@"%@/: didRead doc: %@, %@ (NULL OP)", self, aDocument, didRead);
}

////////////////////////////////////////////////////////////////
// xhr connection delegate methods
- (void)connection:(CPURLConnection)aConnection didReceiveResponse:(CPURLResponse)aResponse
{
    // CPLog(@"%@: didReceiveResponse", self);
}

// - (void)connection:(CPJSONPConnection)theConnection didReceiveData:(Object)theDatum
- (void)connection:(CPURLConnection)theConnection didReceiveData:(Object)theDatum
{
  CPLog(@"%@: didReceiveData, length: %@", self, [theDatum length]);
  //This method is called when a connection receives a response. in a
  //multi-part request, this method will (eventually) be called multiple times,
  //once for each part in the response.
  console.log(theDatum);

  var windows = [CPApp windows];
  // CPLog(@"  window count: %@", [windows count]);
  for (iWin=0; iWin<[windows count]; iWin++) {
    if ( [windows[iWin] isFullPlatformWindow] ) {
      // CPLog(@"%@/  full platform window: %@", self, windows[iWin]);
      // var bottomBar = [[w contentView] viewWithTag:66];
      // var progressIndicator = [bottomBar viewWithTag:123456789];
      var progressIndicator = [[windows[iWin] contentView] viewWithTag:123456789];
      [progressIndicator stopAnimation:YES];
      [progressIndicator removeFromSuperview];
    }
  }

  var result = [theDatum rangeOfString:@"Timeout" options:(CPAnchoredSearch)];
  if (result.location != CPNotFound) {
    CPLog(@"\n\n1 EXCEPTION:\t\t%@ connection:%@ didReceiveData:  TIMEOUT ON SERVER\n\n", self, theConnection);
    console.log(theConnection);
    console.log(theDatum, "\n\n");
    return;
  }

  var session = theConnection.session;  // this prop was added to the CPURLConnection object after submitting
    if (theConnection == _readConnection)
    {
      // CPLog(@"    ....didReceiveData on readConnection");
      try {
	[self readFromData:[CPData dataWithRawString:theDatum] ofType:session.fileType error:nil];
      } catch(e) {
	CPLog(@"\n\n2 EXCEPTION: %@", e);
	CPLog(@"\n\n2 EXCEPTION:\t\t%@ connection:%@ didReceiveData:%@\n\n", self, theConnection, theDatum);
	console.log(theConnection);
	console.log(theDatum, "\n\n");
	// var lpcr = [LPCrashReporter sharedErrorLogger];
	return;
      }
      objj_msgSend(session.delegate,
		   session.didReadSelector,
		   self,
		   YES,
		   session.contextInfo);
    }
    else
    {
      // CPLog(@"    ....didReceiveData on non-readConnection");
      // CPLog(@"    ....session.saveOp: %@", session.saveOperation);
      // CPLog(@"    ....CPSaveToOperation: %@", CPSaveToOperation);

        if (session.saveOperation != CPSaveToOperation)
            [self setFileURL:session.absoluteURL];

        _writeRequest = nil;

        objj_msgSend(session.delegate, session.didSaveSelector, self, YES, session.contextInfo);
        [self _sendDocumentSavedNotification:YES];
    }
    CPLog(@"/%@: /didReceiveData", self);
}

- (void)connectionDidFinishLoading:(CPURLConnection)theConnection
{
    CPLog(@"%@: connectionDidFinishLoading conn %@", self, theConnection);
    [self makeWindowControllers];

    // CPLog(@"    shouldDisplay: %@",[theConnection.session.aContextInfo objectForKey:@"shouldDisplay"]);
    // if ([theConnection.session.aContextInfo objectForKey:@"shouldDisplay"])
    // 	[self showWindows];
    [self showWindows];
    // [[self windowControllers] makeObjectsPerformSelector:@selector(refreshButtonPop:) withObject:self];
    CPLog(@"/%@: /connectionDidFinishLoading\n", self);
}

- (void)connection:(CPJSONPConnection)connection didFailWithError:(CPString)error
{
  //This method is called if the request fails for any reason.
  CPLog(@"%@ connection:%@ didFailWithError:%@", self, connection, error);
}

// - (CPWindow)panel
// {
//   return _cmWindow;
// }

- (id)pathForItem:(id)item
{
  return [_cmWindow pathForItem:item];
}

////////////////////////////////////////////////////////////////

- (void)readFromData:(CPData)theDatum ofType:(CPString)aType error:(CPError)anError
{
    CPLog(@"%@: readFromData data: %@ of type %@ ", self, theDatum, aType);
    console.log(theDatum);
    __properties = [theDatum JSONObject];

    CPLog(@"%@ props: ", self);
    console.log(__properties);

    return;

    // var hdr = props["head"]["vars"];
    // var bindings = props["results"]["bindings"];
    // temp = [[CPMutableDictionary alloc] init];
    // for (var i=0; i<bindings.length; i++) {
    //   var lang = bindings[i]["lang"]["value"];
    //   // var pname = @"Desc"; // bindings[i]["Property"]["value"];
    //   // var pval = @"Foo"; //bindings[i]["Value"]["value"];
    //   if ( [temp containsKey:lang] ) {
    // 	// var theProps = [temp valueForKey:lang];
    // 	// if ( [theProps containsKey:pname] ) {
    // 	//   var theProp = [theProps valueForKey:pname];
    // 	//   [theProp addObject:pval];
    // 	// } else {
    // 	//   var pvals = [[CPMutableSet alloc] init];
    // 	//   [pvals addObject:pval];
    // 	//   [theProps setValue:pvals forKey:pname];
    // 	// }
    //   } else {
    // 	var prop  = [[CPMutableDictionary alloc] init];
    // 	// var pvals = [[CPMutableSet alloc] init];
    // 	// [pvals addObject:pval];
    // 	// [prop setValue:pvals forKey:pname];
    // 	[temp setValue:prop forKey:lang];
    //   }
    // }
    // console.log(temp);

    // __properties = [CPMutableArray arrayWithArray:[temp allKeys]];

    __properties = [[CPMutableArray alloc] init];
    var theLangs = [temp allKeys];
    for (var i=0; i < theLangs.length; i++) {
      // CPLog(@"    key: %@, val: %@", theLangs[i], [temp valueForKey:theLangs[i]]);
      var lang = [[CPMutableDictionary alloc] init];
      [lang setValue:theLangs[i] forKey:@"key"];
      // var props = [[CPArray alloc] init];
      // var theProps = [temp objectForKey:theLangs[i]];
      // var pkeys = [theProps allKeys];
      // for (var j=0; j < pkeys.length; j++) {
      // 	var prop = [[CPMutableDictionary alloc] init];
      // 	[prop setValue:pkeys[j] forKey:@"key"];
      // 	var pvals = [theProps objectForKey:pkeys[j]];
      // 	[prop setValue:[pvals allObjects] forKey:@"children"];
      // 	[props addObject:prop];
      // }
      // [lang setValue:nil forKey:@"CHILDREN"];
      // [__properties addObject:lang];
    }

    console.log(__properties);

    // CPLog(@"/%@: readFromData", self);
}

- (void) setDelegate:(CPObject)aDelegate
{
  _delegate = aDelegate;
}

- (void)rightMouseDown:(CPEvent)anEvent
{
  // CPLog(@"rightMouseDown");
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
      
    } else { // value must be "file"
      // continue; no children
    }
  }
}

- (CFAction)removeDocument:(id)sender
{
  // CPLog(@"%@: removeDocument %@", self, [self path]);
  [CPApp sendAction:@selector(removeDocumentByLibrarian:)
		 to:[AamaDocumentController sharedDocumentController]
	       from:[_cmWindow browser]];
  //  var item = [theBrowser selecteItem];
  // var path = [_cmWindow pathForItem:[_cmWindow item]];
  // CPLog(@"deleting %@", path);
}

// - (CFAction)showDocPropertySheet:(id)sender
// {
//   CPLog(@"%@ showDocPropertySheet", self);
  
// }

@end


var _CPReadSessionMake = function(aType, aDelegate, aDidReadSelector, aContextInfo)
{
    return { fileType:aType, delegate:aDelegate, didReadSelector:aDidReadSelector, contextInfo:aContextInfo };
}

var _CPSaveSessionMake = function(anAbsoluteURL, aSaveOperation, aChangeCount, aDelegate, aDidSaveSelector, aContextInfo, aConnection)
{
    return { absoluteURL:anAbsoluteURL, saveOperation:aSaveOperation, changeCount:aChangeCount, delegate:aDelegate, didSaveSelector:aDidSaveSelector, contextInfo:aContextInfo, connection:aConnection };
}
