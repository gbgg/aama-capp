/*
 * CatalogManager - contains both controller and windows controlled for managing library of docs (i.e. a filesystem)
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "AamaDocumentController.j"
@import "CatalogManagerWindowController.j"
// @import "MIBrowser.j"

OPEN=1;
SAVE=2;
NEWFOLDER=3;
DATA=4;
OUTLINE=5;
FILENAME=6;
RENAME=6;

var _CPStandardWindowViewMinimizeButtonImage                = nil;


//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@implementation CatalogManager : CPDocument

{
    CatalogMangerWindowController catManWinCon;
    CPDictionary catalog @accessors;
    CatalogManagerWindow _cmWindow @accessors;  //TODO: migrate to controller
    CPString testServer;
    CPString localServer;
    CPString path @accessors;
    CPString filename @accessors;

    // MIBrowser theBrowser; //TODO: migrate to window controller
    CPObject _delegate;

    //TODO: these should be in MIDoclet (like CPDocument)
    CPURLConnection     _readConnection;
    CPURLRequest        _writeRequest;
}

/*!
    Initializes an empty document.
    @return the initialized document
*/
- (id)init
{
  // CPLog(@"CatalogManager: init");
  self = [super init];

  // testServer = @"http://minkdev.appspot.com/aamadav";
  // localServer= @"http://localhost:8088/aamadav/";
  // _cmWindow = [[CatalogManagerWindow alloc] init];
  // 			// initWithFrame:CGRectMake(20,100, 400, 200)];
  // [_cmWindow setDelegate:self];
  // CPLog(@"FINISHED CatalogManager: init");
  return self;
}

  /**
   * initWithType is for new docs
   */
- (id)initWithType:(CPString)aType error:({CPError})anError
{
    // CPLog(@"CatalogManager: initWithType:%@", aType);
  [super init];

  // testServer = @"http://minkdev.appspot.com/aamadav";
  // localServer= @"http://localhost:8088/aamadav/";
  // _cmWindow = [[CatalogManagerWindow alloc] init];
  // 			// initWithFrame:CGRectMake(20,100, 400, 200)];
  // [_cmWindow setDelegate:self];
  // CPLog(@"FINISHED CatalogManager: initWithType %@", aType);
  return self;
}

// Called indirectly by document, via didRead (from doc controller)
- (void)makeWindowControllers
{
    // CPLog(@"%@: makeWindowControllers", self);
  // [super makeWindowControllers] calls makeViewAndWindowControllers,
  // which only makes controllers for CIB-based apps
  // if your windows etc. are all handled programmatically,
  // then you must detect that the controller was not created,
  // created it, and then add it.
  [super makeWindowControllers]; // calls makeViewAndWindowControllers
  var ok = NO,
    count = [_windowControllers count];
  // CPLog(@"%@: makeWindowControllers count %@", self, count);
  for (; index < count; ++index) {
      var theWC = _windowControllers[index];
      // CPLog(@"    %@: makeWindowControllers controller %@", self, theWC);
      if ([theWC document] == self) 
	  ok = YES;
  }

  if (ok == NO) { // expected outcome for programmatically controlled windows
      // CPLog(@"    %@ not created from CIB; creating programmatically", self);
    //Responsibilities:  1.  make window; 2. make window controller

      // 3.  connect window widgets to doc data?

      _window = [[CatalogManagerWindow alloc] init];
      var theWindowController = [[CatalogManagerWindowController alloc] initWithWindow:_window];

    if (theWindowController)
	[self addWindowController:theWindowController];
  }

  // [theWindowController synchronizeWindowTitleWithDocumentName];
  [_window setTitle:@"Paradigm Browser"];
  [CPApp addWindowsItem:_window title:@"Paradigm Browser" filename:NO];
  // CPLog(@"/%@: makeWindowControllers", self);
}

//{DEBUG
- (void)addWindowController:(CPWindowController)aWindowController
{
    // CPLog(@"%@: addWindowController %@", self, aWindowController);
    [_windowControllers addObject:aWindowController];

    if ([aWindowController document] !== self) {
      // setDocument calls WinCtlr.window, which creates a window if it doesn't exist
      //  WinCtlr.window calls WinCtlr.loadWindow, which must be overriden to load win programmatically
      // this should be refactored into setDocument, then setWindowForDocument
      [aWindowController setDocument:self];

      //TODO:  now we have a window controller controlling a window and doc
      //  is this where we connect doc data to window widgets?  e.g. set datasource for browser?
      //  or should that code be in the WC itself?
    }
    // CPLog(@"/%@: addWindowController %@", self, aWindowController);
}
//DEBUG}
- (void)performMiniaturize:(id)aSender
{
  // CPLog(@"CatalogManager performMiniaturize");
  [self miniaturize:aSender];
}

-(CFAction)removeItem:(id)sender
{
  var theItem = [sender selectedItem];
  // CPLog(@"CatalogManager removeItem: %@", theItem);
  // var selectedColumn = [theBrowser selectedColumn],
  //   selectedRow = [theBrowser selectedRowInColumn:selectedColumn];
  // CPLog("col: %@ row: %@", selectedColumn, selectedRow);
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
- (id)initWithContentsOfURL:(CPURL)anAbsoluteURL
		     ofType:(CPString)aType
		   delegate:(id)aDelegate
	    didReadSelector:(SEL)aDidReadSelector
		contextInfo:(id)aContextInfo
{
    CPLog(@"%@: initWithContentsOfURL %@ of type %@, delegate: %@", self, anAbsoluteURL, aType, aDelegate);
    // calls readFromURL

    var doc =  [super initWithContentsOfURL:anAbsoluteURL
				     ofType:aType
				   delegate:self
			    didReadSelector:aDidReadSelector
				contextInfo:aContextInfo];
    // CPLog(@"/%@:initWithContentsOfURL", self);
    return self;
}
//DEBUG}

//{DEBUG
- (void)readFromURL:(CPURL)anAbsoluteURL
	     ofType:(CPString)aType
	   delegate:(id)aDelegate
    didReadSelector:(SEL)aDidReadSelector
	contextInfo:(id)aContextInfo
{
    CPLog(@"%@: readFromURL %@, type %@, delegate: %@, selector: %@", self, anAbsoluteURL, aType, aDelegate, aDidReadSelector);
    [[self windowControllers] makeObjectsPerformSelector:@selector(refreshButtonPush:) withObject:self];
    // called at startup; stack:
    // initWithContentsOfURL
    // makeDocumentWithContentsOfURL
    // openDocumentWithContentsOfURL
    // openTheDocument
    [_readConnection cancel];

    // FIXME: Oh man is this every looking for trouble, we need to handle login at the Cappuccino level, with HTTP Errors.
    var req = [CPURLRequest requestWithURL:anAbsoluteURL];

    // CPLog(@"    ....sending XHR");
    _readConnection = [CPURLConnection connectionWithRequest:req delegate:self];
    _readConnection.session = _CPReadSessionMake(aType, aDelegate, aDidReadSelector, aContextInfo);
    // _readConnection.session = _CPReadSessionMake(aType, aDelegate, aDidReadSelector, aContextInfo);
    //_readConnection.session = _CPReadSessionMake(@"catalog", self, @selector(catalog:didRead:contextInfo:), nil);
    // CPLog(@"/%@: readFromURL", self);
}
//DEBUG}

////////////////////////////////////////////////////////////////
- (CFAction)orderFront:(id)theDoc
{
  // CPLog(@"%@: orderFront", self);
  [_window orderFront:self];
}

-(CFAction)refresh:(id)sender
{
  // CPLog("CatalogManager: refresh action");
    [self refresh];
}

//TODO:  convert to openDocumentWithContentsOfURL
-(CFAction)refresh
{
    CPLog("CatalogManager: refresh method");

    [self readFromURL:[self fileURL]
	       ofType:[self fileType]
	     delegate:self
      didReadSelector:@selector(document:didRead:contextInfo:)
	  contextInfo:[CPDictionary dictionaryWithObject:true
						  forKey:@"shouldDisplay"]];
    return;
    
  var localServer= @"/aamadav/"; // @"http://localhost:8088/aamadav/";
  var aRequest = [CPURLRequest requestWithURL:[[CPURL alloc] initWithString:localServer]];

  [_readConnection cancel];

  //switch on the progress spinner in window titlebar
  [[self windowControllers] makeObjectsPerformSelector:@selector(refreshButtonPush:) withObject:self];
  // [_cmWindow refreshButtonPush:self];

 //FIXME:  add timeout logic in case host unavailable
  // CPLog(@"    ....sending XHR");
  _readConnection = [CPURLConnection connectionWithRequest:aRequest delegate:self];

  _readConnection.session = _CPReadSessionMake(@"catalog", self, @selector(document:didRead:contextInfo:), nil);

  // CPLog("FINISHED CatalogManager: refresh");
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

- (void)connection:(CPJSONPConnection)theConnection didReceiveData:(Object)theDatum
{
  CPLog(@"%@: didReceiveData, length: %@ %@", self, [theDatum length], theDatum);
  //This method is called when a connection receives a response. in a
  //multi-part request, this method will (eventually) be called multiple times,
  //once for each part in the response.

  var windows = [CPApp windows];
  // CPLog(@"%@/  window count: %@", self [windows count]);
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
    
    var session = theConnection.session;
    if (theConnection == _readConnection)
    {
      CPLog(@"    ....didReceiveData on readConnection");
      [self readFromData:[CPData dataWithRawString:theDatum] ofType:session.fileType error:nil];
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
    // CPLog(@"/%@: didReceiveData", self);
}

- (void)connectionDidFinishLoading:(CPURLConnection)theConnection
{
    // CPLog(@"%@: connectionDidFinishLoading conn %@", self, theConnection);
    [self makeWindowControllers];

    // CPLog(@"    shouldDisplay: %@",[theConnection.session.aContextInfo objectForKey:@"shouldDisplay"]);
    if ([theConnection.session.aContextInfo objectForKey:@"shouldDisplay"])
	[self showWindows];
    [self showWindows];
    // [[self windowControllers] makeObjectsPerformSelector:@selector(refreshButtonPop:) withObject:self];
    // CPLog(@"/%@: connectionDidFinishLoading\n", self);
}

- (void)connection:(CPJSONPConnection)connection didFailWithError:(CPString)error
{
  //This method is called if the request fails for any reason.
  // CPLog(@"didFailWithError " + error);
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
    // CPLog(@"%@: readFromData data: %@ of type %@ ", self, theDatum, aType);
    var jsonString = [[CPString alloc] initWithString:theDatum];
    // CPLog(@"    %@ jsonstring: %@", self, jsonString);
    jsonObj = [theDatum JSONObject];
    catalog = [CPMutableDictionary dictionaryWithJSObject:jsonObj recursively:YES];
    // CPLog(@"/%@: readFromData", self);
}


// - (void) setDelegate:(CPObject)aDelegate
// {
//   _delegate = aDelegate;
// }

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
