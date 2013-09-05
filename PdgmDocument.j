/*
 * 
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "PdgmDoclet.j"
@import "PdgmDocletController.j"
@import "PdgmDocletView.j"
@import "PdgmDocWinController.j"
@import "DocumentSaver.j"
@import "PdgmDocInspector.j"

var RHOST="",
  RPATH="/pdgm",
  RPORT="";

var SPARQLHOST="http://fu.sibawayhi.org",
  SPARQLPATH="/aama/query",
  SPARQLPORT=":80";

// var SPARQLHOST="http://localhost",
//   SPARQLPORT=":3030",
//   SPARQLPATH="/aama/query";

var C_FILENAME = 0,
  C_PATH = 1;
// var CPDocumentUntitledCount = 0;

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@implementation PdgmDocument : CPDocument
{
  //TODO: array of doclets
  PdgmDoclet doclet @accessors;  //TODO: this should be owned by docletConroller?
  CPArray _doclets @accessors(property=doclets);
  
  // PdgmDocletController _docletController @accessors;
  
  // Data design:  we have 1. "local" doc data, and 2. set of doclets, data fetched by URL
  // readFromData (called by didReceiveDat) is responsible for parsing and setup

  //TODO: split into doc (this) and doc data model (i.e. the local stuff)
  // PdgmDocModel data @accessors;
  //Alternatively, the doc /is/ the model, so we put the appropriate fields here
  CPString owner @accessors;
  CPString desc @accessors;
  //etc.
  //also personal profile stuff, like colors, fonts??

  //better:
  //CPArray doclets;
  
  BOOL reloadFlag @accessors;
  CPString _properties;
}

- (id)init
{
    CPLog(@"%@: init", self);
    self = [super init];
    if (self) {
      //TODO:  move doclet setup to docletContoller?
      // [self setDoclet:[[PdgmDoclet alloc] init]]; //TODO: initWithDocument
      // [doclet setDocument:self]; //
      // [self setHasUndoManager:YES];
      // [doclet setPgrid:@"test pgrid"];
      // [doclet setTitlebar:C_PATH];
    }
    // CPLog(@"/%@: init", self);
    return self;
}

  /**
   * initWithType is for new docs
   */
- (id)initWithType:(CPString)aType error:({CPError})anError
{
  // CPLog(@"%@: initWithType %@", self, aType);
  self = [self init];

  if (self) {
    [self setFileType:aType];
    // [self updateChangeCount:CPChangeDone];
    [self setReloadFlag:YES];
    // CPLog(@"    ....PdgmDocument doclet %@", doclet);

    //TODO:  put the default query in the plist?
    //TODO:  migrate doclet setup logic to docletController
    doclet = [[PdgmDoclet alloc] init];
//     [doclet setQuery:@" \
// PREFIX ucd: <http://example.org/unicode/ucd#>\n\
// SELECT ?name ?ucs2 ?char\n\
// FROM <urn:unicode>\n\
// WHERE {\n\
//   ?ch ucd:name ?name .\n\
//   ?ch ucd:ucs2Hex ?ucs2 .\n\
//   ?ch ucd:utf8Literal ?char .\n\
//   ?ch ucd:block ucd:Basic_Latin .\n\
// }\n\
// ORDER BY ?ucs2"];
    
    // CPLog(@"/%@: initWithType %@ (doclet %@)", self, aType, doclet);
    return self;
  }
  CPLog(@"ERROR:  initWithType:%@ FAILURE", aType);
}

- (CFAction)showDocPropertySheet:(id)sender
{
  CPLog(@"%@: showDocPropertySheet", self);
  // // newly created doc should be the main app window; use it to host property sheet
  // var mainWin = [CPApp mainWindow];
  // var doc = [_windowController document];
  var pdgmDocInspector = [[PdgmDocInspector alloc] initWithDoc:self];
  CPLog(@"pdgmDocInspector: " + pdgmDocInspector);
  [[CPNotificationCenter defaultCenter ]
            addObserver:self
               selector:@selector(onInspectorDidAccept:)
                   name:@"InspectorDidAcceptNotification"
                 object:nil];
  [[CPNotificationCenter defaultCenter ]
            addObserver:self
               selector:@selector(onInspectorDidCancel:)
                   name:@"InspectorDidCancelNotification"
                 object:nil];
  [pdgmDocInspector showDocPropertySheetForType:[self fileType]];
  CPLog(@"/%@: showDocPropertySheet", self);
}

- (void)onInspectorDidAccept:(CPNotification)aNotification
{
  CPLog(@"%@: onInspectorDidAccept for doc %@", self, aNotification);
  [[CPNotificationCenter defaultCenter]
    removeObserver:self
	      name:@"InspectorDidAcceptNotification" 
	    object:nil];
  [[CPNotificationCenter defaultCenter]
    removeObserver:self
	      name:@"InspectorDidCancelNotification"
	    object:nil];
  var theDoc = [aNotification object];
  CPLog(@"theDoc %@", theDoc);
  var reloadFlag = [[theDoc doclet] reloadFlag];
  // if ( (reloadFlag == CPOnState) ) {
  // [self reloadDocData:self];
  // [[theDoc doclet] reload];
  [_windowControllers makeObjectsPerformSelector:@selector(performRefresh:) withObject:self];
  // }
  CPLog(@"/%@: onInspectorDidAccept for doc %@", self, aNotification);
}
 
- (void)onInspectorDidCancel:(CPNotification)aNotification
{
  CPLog(@"%@: onInspectorDidCancel", self);
  [[CPNotificationCenter defaultCenter]
    removeObserver:self
	      name:@"InspectorDidCancelNotification" 
	    object:nil];
  [[CPNotificationCenter defaultCenter]
    removeObserver:self
	      name:@"InspectorDidAcceptNotification" 
	    object:nil];
  [super close];
}

- (CPData)dataOfType:(CPString)aType error:({CPError})anError
{
  // CPLog(@"dataOfType: " + aType);
  // CPLog(@"keyed archiver" + [CPKeyedArchiver archivedDataWithRootObject:doclet]);
  // if (aType !== [self fileType]) {
  //   CPLog(@"type mismatch: requested: %@, native: %@", aType, [self fileType]);
  // }
  return [CPKeyedArchiver archivedDataWithRootObject:doclet];
}

/*!
  Sets the content of the document by reading the provided
  data. The default implementation just throws an exception.
  @param aData the document's data
  @param aType the document type
  @param anError not used
  @throws CPUnsupportedMethodException if this method hasn't been
  overridden by the subclass
*/
- (void)readFromData:(CPData)aData ofType:(CPString)aType error:(CPError)anError
{
    // CPLog(@"%@: readFromData data: %@ of type %@ ", self, aData, aType);
    // var doc = [doclet theDocument];
    // CPLog(@"    before unarchiving: doclet %@ in doc %@", doclet, self);
    [self setDoclet:[CPKeyedUnarchiver  unarchiveObjectWithData:aData]];
    [doclet setDocument:self];
    [_doclets addObject:doclet];
    // CPLog(@"    after unarchiving: doclet %@ in doc %@", doclet, [doclet theDocument]);
    // CPLog(@"    doclet %@", doclet);
    // CPLog(@"    query %@", [doclet query]);
    // [doclet setDocument:doc];
    // CPLog(@"    after doc data %@ for doc %@", self, doclet, [doclet theDocument]);
    // CPLog(@"/%@: readFromData", self);
}

// - (BOOL)isDocumentEdited
// {
//   CPLog(@"%@ isDocumentEdited %@", self, [super isDocumentEdited]);
//   var ed = [super isDocumentEdited];
//   return ed;
// }

- (void)updateChangeCount:(CPDocumentChangeType)aChangeType
{
  // CPLog(@"%@ updateChangeCount %@", self, aChangeType);
  [super updateChangeCount:aChangeType];
}

////////////////////////////////////////////////////////////////
//  document actions

- (CFAction)XsaveDocument:(id)aSender
{
  CPLog(@"%@: saveDocument", self);
  //  1.  display save dialog
  //      a.  fetch file system tree from server
  //      b.  display fs tree in save dialog
  //  2.  obtain save-as doc URL
  //  3.  PUT doc to server; detect overwrite and ask for confirmation

  // super's implementation:
    if ([super fileURL]) {
      CPLog(@"    ...." + [super fileURL]);
      [[CPNotificationCenter defaultCenter]
            postNotificationName:CPDocumentWillSaveNotification
                          object:self];

      [self saveToURL:[super fileURL]
	       ofType:[self fileType]
	    forSaveOperation:CPSaveAsOperation
	     delegate:self
	    didSaveSelector:@selector(document:didSave:contextInfo:) // @selector(docWasSaved:)
	  contextInfo:nil];
    }
    else {
      [[CPNotificationCenter defaultCenter ]
            addObserver:self
               selector:@selector(onIriWasAcquiredForSave:)
                   name:@"IriWasAcquired" 
                 object:nil];
      savePanelCtlr = [[DocSavePanelController alloc] init];
      [savePanelCtlr acquireIriFor:OPEN];
      // DocSavePanel sent IriWasAcquired notification to be caught by onIriWasAcquiredForSave routine
      return;
    }
}

//{DEBUG
- (void)_saveDocumentAsWithDelegate:(id)delegate didSaveSelector:(SEL)didSaveSelector contextInfo:(Object)contextInfo
{
  CPLog(@"%@: saveDocumentAsWithDelegate %@", self, delegate);
    // var savePanel = [CPSavePanel savePanel],
    //     response = [savePanel runModal];

    [[CPNotificationCenter defaultCenter ]
            addObserver:self
               selector:@selector(onIriWasAcquiredForSave:)
                   name:@"IriWasAcquired" 
                 object:nil];
    var savePanelCtlr = [[DocSavePanelController alloc] init];
    [savePanelCtlr acquireIriFor:SAVE];

    return;
    
    if (!response)
        return;

    var saveURL = [savePanel URL];

    [[CPNotificationCenter defaultCenter]
        postNotificationName:CPDocumentWillSaveNotification
                      object:self];

    [self saveToURL:saveURL ofType:[self fileType] forSaveOperation:CPSaveAsOperation delegate:delegate didSaveSelector:didSaveSelector contextInfo:contextInfo];
}
//DEBUG}

- (void)onIriWasAcquiredForSave:(CPNotification)aNotification
{
  CPLog(@"%@: onIriWasAcquiredForSave", self);
  var iri = [aNotification object];
  [self setFileURL:iri];
  CPLog(@"    save to IRI: %@ type:%@", iri, [self fileType]);
  // default CPDocument implementation:
  // [[_docWinController window] setTitleWithRepresentedFilename:iri];
  [[CPNotificationCenter defaultCenter]
        postNotificationName:CPDocumentWillSaveNotification
                      object:self];

  [self saveToURL:iri ofType:[self fileType]
	forSaveOperation:CPSaveAsOperation
  	 delegate:CPSharedDocumentController
	didSaveSelector:@selector(document:didSave:contextInfo:) // @selector(docWasSaved:)
      contextInfo:nil];
}

// - (CFAction)docWasSaved:(id)aSender
// {
//   CPLog(@"PdgmDocument: docWasSaved");
//       // if (aSaveOperation !== CPSaveToOperation)
//   [self updateChangeCount:CPChangeCleared];
// }

- (void)document:(CPDocument)aDocument didSave:(BOOL)didSave contextInfo:(id)aContextInfo
{
  CPLog(@"%@/ document %@ didSave %@", aDocument, didSave);
}

- (CFAction)revertDocument:(id)aSender
{
  CPLog(@"PdgmDocument: revertDocument");
}

- (CFAction)printDocument:(id)aSender
{
  CPLog(@"PdgmDocument: printDocument");
}

//  WINDOW stuff
////////////////////////////////////////////////////////////////
// CAPPUCCINO-specific
////////////////////////////////////////////////////////////////
// VIEW CONTROLLER mgmt
//   CPDictionary        _viewControllersForWindowControllers;
// - (void)viewControllerWillLoadCib:(CPViewController)aViewController
// - (void)viewControllerDidLoadCib:(CPViewController)aViewController
// - (void)makeViewAndWindowControllers
// - (CPArray)viewControllers
// - (void)addViewController:(CPViewController)aViewController forWindowController:(CPWindowController)aWindowController
// - (void)removeViewController:(CPViewController)aViewController
// - (CPViewController)viewControllerForWindowController:(CPWindowController)aWindowController
// - (CPString)viewCibName

// - (CPWindowController)firstEligibleExistingWindowController

// Cappuccino
- (CPString)viewCibName
{
  CPLog(@"%@ viewCibName", self);
  return nil;
}
// Cocoa
- (CPString)windowCibName
{
  CPLog(@"%@ windowCibName", self);
  return nil;
}
// Cappuccino
- (CPWindowController)firstEligibleExistingWindowController
{
  CPLog(@"%@ firstEligibleExistingWindowController", self);
  // What is this for?  Reusing windows?
  return nil;
}

// Called by doc controller, from
// - (void)openUntitledDocumentOfType:(CPString)aType display:(BOOL)shouldDisplay
// - (void)document:(CPDocument)aDocument didRead:(BOOL)didRead contextInfo:(id)aContextInfo
- (void)makeWindowControllers
{
  CPLog(@"%@: makeWindowControllers", self);
  //  Default Logic: call makeViewAndWindowControllers, whose business
  //  is to make a window controller with view controller governing
  //  the content view of the window
  
  //  Case A:  we have cibs for view and win (override doc's viewCibName and windowCibName)
  //  Case B:  we have viewCibName but no windowCibName
  //  Case C:  we have windwCibName but no viewCibName
  //    action:  creates wc from cib, add wc to doc's list of wcs; subclass must create vc if desired
  //  Case D:  neither viewCibName nor windowCibName
  //    action:  none; CPDoc subclass must implement makeWindowControllers making both vc and wc

  //  Cases A and B:
  //      1.  create viewController from cibname
  //      2.  if we already have a wc we can reuse (firstEligibleExistingWindowController), do so;  otherwise
  //      3.  create wc from cib if we have one; otherwise
  //      4.  create and init window using view frame with initWithContentRect
  //      5.  create and init wc with window
  //    then if we have both a vc and a wc, set wc to support multiple docs
  //    finally, add wc to doc's wc list, and add vc to wc's list of vc's
  //        CPDoc's addWindowController adds wc to doc wc list, then calls setDocument:self on wc

  [super makeWindowControllers]; // calls makeViewAndWindowControllers
  // Step 1:  discover if super created our wc
  var theWindowController;

  var wc = [self windowControllerForDocument:self];

  // to support multiple windows per doc, always create a new wc and win
  // if ( ! wc ) { // expected outcome for programmatically controlled windows
  if ( YES ) { // expected outcome for programmatically controlled windows
  //   CPLog(@"%@    WinCntlr not created from CIB; creating programmatically", self);

    var nWins = 0;
    var docs = [CPSharedDocumentController documents]; 
    for (var i=0; i<[docs count]; i++) {
      nWins = nWins + [[[docs objectAtIndex:i] windowControllers] count];
    }
    var menuBarH = [[CPApp mainMenu] menuBarHeight];

    // var theWindow = [[PdgmDocWindow alloc] initWithDocument:self];
    //FIXME:  doesn't addWindowController create the window?
    var theWindow = [[PdgmDocWindow alloc] initWithContentRect:CGRectMake( (nWins)*menuBarH, (nWins+2)*menuBarH, 800, 400)
						     styleMask:
					     CPTitledWindowMask
					   | CPMiniaturizableWindowMask
					   | CPMaximizableWindowMask
					   | CPRefreshableWindowMask
					   | CPClosableWindowMask
					   | CPResizableWindowMask];

    theWindowController = [[PdgmDocWinController alloc] initWithWindow:theWindow];
    [theWindow setNextResponder:theWindowController];
    [CPApp addWindowsItem:theWindow title:[[self fileURL] lastPathComponent] filename:NO];
    // CPLog(@"\n\n\t\t\t%@  WINDOW %@ nextResponder: %@ &&&&&&&&&&&&&&&&\n\n", self, theWindow, [theWindow nextResponder]);
    [theWindowController setNextResponder:self];
    // CPLog(@"\n\n\t\t\t%@  WINCTL %@ nextResponder: %@ &&&&&&&&&&&&&&&&\n\n",
	  // self, theWindowController, [theWindowController nextResponder]);
    // [theWindow setDelegate:theWindowController];

    if (theWindowController)
      [self addWindowController:theWindowController];
  } else {
    // CPLog(@"    window controller for this doc already exists: %@", theWindowController);
  }
  [theWindowController synchronizeWindowTitleWithDocumentName];
  [theWindowController setShouldCloseDocument:YES];
  if (wc) {
    [self showWindows];
    [theWindowController refreshViews:self];
  }
  CPLog(@"/%@: makeWindowControllers", self);
}

//{DEBUG
- (void)makeViewAndWindowControllersX
{
  CPLog(@"%@: makeViewAndWindowControllers", self);
    var viewCibName = [self viewCibName],
        viewController = nil,
        windowController = nil;

    // Create our view controller if we have a cib for it.
    if ([viewCibName length])
        viewController = [[CPViewController alloc] initWithCibName:viewCibName bundle:nil owner:self];

    // If we have a view controller, check if we have a free window for it.
    if (viewController) {
      CPLog(@"    .... setting windowController from viewController");
      windowController = [self firstEligibleExistingWindowController];
    }

    // If not, create one.
    if (!windowController)
    {
      CPLog(@"    .... creating windowController");
        var windowCibName = [self windowCibName];

        // From a cib if we have one.
        if ([windowCibName length]) {
	  CPLog(@"    ....using windowCibName %@", windowDibName);
	  windowController = [[CPWindowController alloc] initWithWindowCibName:windowCibName owner:self];
	}

        // If not you get a standard window capable of displaying multiple documents and view
        else if (viewController)
        {
	  CPLog(@"    .... creating view stuff");
            var view = [viewController view],
                viewFrame = [view frame];

            viewFrame.origin = CGPointMake(50, 50);

            var theWindow = [[CPWindow alloc] initWithContentRect:viewFrame
							styleMask:CPTitledWindowMask
					      | CPClosableWindowMask
					      | CPMiniaturizableWindowMask
					      | CPResizableWindowMask];

            windowController = [[CPWindowController alloc] initWithWindow:theWindow];
        } else {
	  // if we get to this point, it means the client is going to create the controller (in ...)
	  // and the window, by overriding CPWindowController.loadWindow
	}
    }

    if (windowController && viewController) {
      CPLog(@"    .... A ....");
      [windowController setSupportsMultipleDocuments:YES];
    }

    if (windowController) {
      CPLog(@"    .... B ....");
      [self addWindowController:windowController];
    }

    if (viewController) {
      CPLog(@"    .... C ....");
      [self addViewController:viewController forWindowController:windowController];
    }
    CPLog(@"/%@:makeViewAndWindowControllers", self);
}
//DEBUG}

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
      // [aWindowController setWindowForDocument:self];
    // CPLog(@"/%@: addWindowController %@", self, aWindowController);
    }
}
//DEBUG}

- (id)windowControllerForDocument:(id)theDoc
{
  // CPLog(@"%@ windowControllerForDocument %@", self, theDoc);
  var count = [[self windowControllers] count];
  // CPLog(@"    found %@ window controllers for this doc", count);
  for (index=0; index < count; ++index) {
    // CPLog(@"    window controller: %@", [[self windowControllers] objectAtIndex:index]);
    var theWC = [[self windowControllers] objectAtIndex:index];
    if ([theWC document] == theDoc) 
      return theWC;
  }
  return nil;
}


////////////////////////////////////////////////////////////////
- (void)viewControllerWillLoadCib:(CPViewController)aViewController
{
  // CPLog(@"%@: viewController %@ WillLoadCib", self, aViewController);
}

- (void)viewControllerDidLoadCib:(CPViewController)aViewController
{
  // CPLog(@"%@: viewController %@ DidLoadCib", self, aViewController);
}

- (void)makeViewControllersX
{
  CPLog(@"%@: makeViewControllers", self);

  var ok = NO,
    count = [_windowControllers count];
  for (; index < count; ++index) {
    var theWC = _windowControllers[index];
    if ([theWC document] == self) 
      ok = YES;
  }

  if (ok == NO) { // expected outcome for programmatically controlled windows
    CPLog(@"    .... WinCntlr not created from CIB; creating programmatically");

    //(void)addViewController:(CPViewController)aViewController forWindowController:(CPWindowController)aWindowController

  //   var theWindow = [[PdgmDocWindow alloc] initWithDocument:self];
  //   var theWindowController = [[PdgmDocWinController alloc] initWithWindow:theWindow];

  //   if (theWindowController)
  // 	[self addWindowController:theWindowController];
  }
  // [theWindowController synchronizeWindowTitleWithDocumentName];

  CPLog(@"/%@: makeViewControllers", self);
}

//{DEBUG
- (void)showWindows
{
  // CPLog(@"%@ showWindows", self);
  // this is the default (super) logic; but why setDocument again?
  // [_windowControllers makeObjectsPerformSelector:@selector(setDocument:) withObject:self];
  [_windowControllers makeObjectsPerformSelector:@selector(showWindow:) withObject:self];
}


- (void)miniaturize:(id)sender
{
  CPLog(@"PdgmDocument:miniaturize");
}

// - (void)windowControllerWillLoadCib:(CPWindowController *) aController
// { super implementation is null
//   CPLog(@"PdgmDocument: windowControllerWillLoadCib %@", aController);
//   [super windowControllerWillLoadCib:aController];
// }

- (void)windowDidLoad
{
  // CPLog(@"%@: windowDidLoad", self);
  var mainMenu = [CPApp mainMenu];
  [mainMenu update];
  // set tab and table views?
  // [super windowDidLoad];
  // [self showWindow:nil];
}

- (void)windowControllerDidLoadCib:(CPWindowController *) aController
{
  CPLog(@"PdgmDocument: windowControllerDidLoadCib");
  // [aController synchronizeWindowTitleWithDocumentName];
  // [aController  synchronizeWindowTitleWithDocumentName];
  // this seems to be the place where we know a new doc has been created; ??
}

- (void)alertDidEnd:(CPAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
  if (returnCode == CPAlertFirstButtonReturn) {
  }
}

/*!
    Returns the name of the document as displayed in the title bar.
*/
- (CPString)displayNameX
{ CPLog(@"PdgmDocument: displayName");
    if (_fileURL)
        return [_fileURL lastPathComponent];

    if (!_untitledDocumentIndex)
        _untitledDocumentIndex = ++CPDocumentUntitledCount;

    if (_untitledDocumentIndex == 1)
       return @"Untitled";

    return @"Untitled " + _untitledDocumentIndex;
}

// - (CFAction)X:(id)theDocURI
// {
//   CPLog(@"PdgmDocument: removeDocument: %@", theDocURI);
//   var aRequest = [CPURLRequest requestWithURL:[[CPURL alloc] initWithString:theDocURI]];
//   [aRequest setHTTPMethod:@"DELETE"];
//   CPLog(@"sending XHR");

//   //FIXME:  add timeout logic in case host unavailable
//   var connection = [CPURLConnection connectionWithRequest:aRequest delegate:self];
//   // [super removeDocument:theDoc];
// }

// xhr connection delegate methods
- (void)connection:(CPURLConnection)aConnection didReceiveResponse:(CPURLResponse)aResponse
{
    // CPLog(@"%@: didReceiveResponse", self);
}

- (void)connection:(CPJSONPConnection)aConnection didReceiveData:(Object)aDatum
{
    CPLog(@"%@: didReceiveData on conn %@ of length %@", self, aConnection, [aDatum length]);
    // CPLog(@"%@: data recd: %@", self, aDatum);
    // Step 1:  turn off refresh spinner in title bar of docwin
    //TODO:  coordinate spinner mgmt with doclets
    // [_docWinController toggleRefreshButton:self];

  var windows = [CPApp windows];
  CPLog(@"  window count: %@", [windows count]);
  for (iWin=0; iWin<[windows count]; iWin++) {
    if ( [windows[iWin] isFullPlatformWindow] ) {
      // CPLog(@"/%@  full platform window: %@", self, windows[iWin]);
      // var bottomBar = [[w contentView] viewWithTag:66];
      // var progressIndicator = [bottomBar viewWithTag:123456789];
      var progressIndicator = [[windows[iWin] contentView] viewWithTag:123456789];
      [progressIndicator stopAnimation:YES];
      [progressIndicator removeFromSuperview];
    }
  }

    var session = aConnection.session;
    if (aConnection == _readConnection)
    {
      // CPLog(@"    ....didReceiveData on readConnection");
      // CPLog(@"    ....TODO: implement readFromData for sparql results data");
      [self readFromData:[CPData dataWithRawString:aDatum] ofType:session.fileType error:nil];
      objj_msgSend(session.delegate, session.didReadSelector, self, YES, session.contextInfo);
    }
    else
    {
      // CPLog(@"    ....didReceiveData on non-readConnection");
      switch (session.saveOperation) {
      case CPSaveOperation:
	// CPLog(@"    ....session.saveOp: CPSaveOperation");
      case CPSaveAsOperation:
	// CPLog(@"    ....session.saveOp: CPSaveAsOperation");
      case CPSaveToOperation:
	// CPLog(@"    ....session.saveOp: CPSaveToOperation");
      case CPAutosaveOperation:
	// CPLog(@"    ....session.saveOp: CPAutosaveOperation");
      default: CPLog(@"  WHAT AM I DOING HERE??? ");
      }
      if (session.saveOperation != CPSaveToOperation)
	[self setFileURL:session.absoluteURL];

      _writeRequest = nil;
      
      objj_msgSend(session.delegate, session.didSaveSelector, self, YES, session.contextInfo);
      [self _sendDocumentSavedNotification:YES];
    }
    [self updateChangeCount:CPChangeCleared];
    // CPLog(@"/%@: didReceiveData", self);
}

- (void)connection:(CPJSONPConnection)aConnection didFailWithError:(CPString)anError
{
  CPLog(@"didFailWithError " + error);
    var session = aConnection.session;

    if (_readConnection == aConnection)
        objj_msgSend(session.delegate, session.didReadSelector, self, NO, session.contextInfo);

    else
    {
        if (session.saveOperation != CPSaveToOperation)
        {
            _changeCount += session.changeCount;
            [_windowControllers makeObjectsPerformSelector:@selector(setDocumentEdited:) withObject:[self isDocumentEdited]];
        }

        _writeRequest = nil;

        alert("There was an error saving the document.");

        objj_msgSend(session.delegate, session.didSaveSelector, self, NO, session.contextInfo);
        [self _sendDocumentSavedNotification:NO];
    }
}

- (void)connectionDidFinishLoading:(CPURLConnection)theConnection
{
  // CPLog(@"%@: connectionDidFinishLoading: conn %@", self, theConnection);
  //Responsibilities:
  //    0.  make doclets
  // once doclets are loaded, then:
  //    1.  make window controllers
  //    2.  show windows

  // [_docletController open...];

  // CPLog(@"%@ doclet: %@, query: %@", self, doclet, [doclet query]);

  [self updateChangeCount:CPChangeCleared];

  [self makeWindowControllers];

  // CPLog(@"    shouldDisplay: %@",[theConnection.session.aContextInfo objectForKey:@"shouldDisplay"]);
  if ([theConnection.session.aContextInfo objectForKey:@"shouldDisplay"])
    [self showWindows];
  [self showWindows];

  // _docletController = [[PdgmDocletController alloc] init];

  //TODO: for each doclet
  [doclet reload];
    
  // [doclet makeViewControllers:self];

  //TODO:  makeViewControllers
  // CPLog(@"%@: sending refreshButtonPop messages", self);
  [[self windowControllers] makeObjectsPerformSelector:@selector(refreshButtonPop:) withObject:self];
  // CPLog(@"/%@: connectionDidFinishLoading", self);
}

- (void)onDocletWasLoaded:(CPNotification)aNotification 
{
  // CPLog(@"%@: onDocletWasLoaded", self);
  // CPLog(@"    notification name: %@; object: %@; userInfo: %@",
	// [aNotification name], [aNotification object], [[aNotification userInfo] description]);
  //TODO:  check notification to make sure we're the right target
  [_windowControllers makeObjectsPerformSelector:@selector(refreshViews:) withObject:self];
  // [_windowControllers makeObjectsPerformSelector:@selector(refreshButtonPop:) withObject:self];
  // CPLog(@"%@: /onDocletWasLoaded", self);
}

// - (CFAction)orderFront:(id)sender
// {
//   CPLog(@"%@: orderFront, window: %@", self, _window);
//   // [_window orderFront:self];
//   [_windowControllers makeObjectsPerformSelector:@selector(orderFront:) withObject:self];
//   // [self showWindows];
// }

////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
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
				   delegate:aDelegate
			    didReadSelector:aDidReadSelector
				contextInfo:aContextInfo];
    CPLog(@"/%@: /initWithContentsOfURL", self);
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
    CPLog(@"%@: readFromURL - ofType:%@, delegate: %@", self, aType, aDelegate);
    // [[self windowControllers] makeObjectsPerformSelector:@selector(refreshButtonPush:) withObject:self];

    [_readConnection cancel];

    // for documentation purposes
    var xhrDelegate = self;
    var didReadDelegate = self;

    // FIXME: Oh man is this every looking for trouble, we need to handle login at the Cappuccino level, with HTTP Errors.
    var req = [CPURLRequest requestWithURL:anAbsoluteURL];
    
    CPLog(@"%@: setting up connection with xhrDelegate: %@, didReadDelegate: %@", self, xhrDelegate, didReadDelegate);
    _readConnection = [CPURLConnection connectionWithRequest:req delegate:xhrDelegate];
    _readConnection.session = _CPReadSessionMake(aType, didReadDelegate, aDidReadSelector, aContextInfo);
    CPLog(@"/%@: /readFromURL", self);
}
//DEBUG}

- (void)saveToURL:(CPURL)anAbsoluteURL
	   ofType:(CPString)aTypeName
 forSaveOperation:(CPSaveOperationType)aSaveOperation
	 delegate:(id)aDelegate
  didSaveSelector:(SEL)aDidSaveSelector
      contextInfo:(id)aContextInfo
{
  // CPLog("%@: saveToURL", self);
  // CPLog("    .... save op: %@", aSaveOperation);
    var data = [self dataOfType:[self fileType] error:nil],
        oldChangeCount = _changeCount;

    // CPLog(@"    .... " + anAbsoluteURL);
    _writeRequest = [CPURLRequest requestWithURL:anAbsoluteURL];

    // FIXME: THIS IS WRONG! We need a way to decide
    if ([CPPlatform isBrowser])
        [_writeRequest setHTTPMethod:@"PUT"];
    else
        [_writeRequest setHTTPMethod:@"PUT"];

    [_writeRequest setHTTPBody:[data rawString]];

    // avoid "Refused to set unsafe header "Connection" warning (Chrome, at least)
    // [_writeRequest setValue:@"close" forHTTPHeaderField:@"Connection"];

    if (aSaveOperation === CPSaveOperation)
        [_writeRequest setValue:@"true" forHTTPHeaderField:@"x-cappuccino-overwrite"];

    // CPLog(@"about to send xhr");    
    // FIXME: Oh man is this every looking for trouble, we need to handle login at the Cappuccino level, with HTTP Errors.
    var connection = [CPURLConnection connectionWithRequest:_writeRequest delegate:self];
    // CPLog(@"sent xhr");    

    connection.session = _CPSaveSessionMake(anAbsoluteURL, aSaveOperation, oldChangeCount, aDelegate, aDidSaveSelector, aContextInfo, connection);
}

//{DEBUG
// - (void)close
// {
//   CPLog(@"%@ close", self);
//   [super close];
// }

- (void)canCloseDocumentWithDelegate:(id)aDelegate shouldCloseSelector:(SEL)aSelector contextInfo:(Object)context
{
  CPLog(@"%@ canCloseDocumentWithDelegate %@", self, aDelegate);
    if (![self isDocumentEdited])
        return [aDelegate respondsToSelector:aSelector] && objj_msgSend(aDelegate, aSelector, self, YES, context);

    // default implementation in CPDocument.j displays standard Close dialog

    CPLog(@"**** TODO:  show save dialog ****");
    
    // [self saveDocument:self];
    return YES;
  CPLog(@"%@ canCloseDocumentWithDelegate %@ shouldCloseSelector %@", self, aDelegate, aSelector);
}

- (void)shouldCloseWindowController:(CPWindowController)controller
			   delegate:(id)delegate
		shouldCloseSelector:(SEL)selector
			contextInfo:(Object)info
{
  CPLog(@"%@ shouldCloseWindowController %@ delegate %@ selector %@", self, controller, delegate, selector);
  [super shouldCloseWindowController:controller
			    delegate:delegate
		 shouldCloseSelector:selector
			 contextInfo:info];
}


-(CFAction)performDelete:(id)theSender
{
  CPLog(@"PdgmDocument: performDelete");
}

// this method is passed as a selector starting with open
- (void)document:(CPDocument)aDocument didRead:(BOOL)didRead contextInfo:(id)aContextInfo
{
    // CPLog(@"%@/: didRead doc: %@, %@ (NULL OP)", self, aDocument, didRead);
}

- (void)reload
{
  // CPLog(@"%@: reload", self);
  [doclet reload];
  // CPLog(@"/%@: reload", self);
}

//TODO:  this goes in doclet
//  rename to sth like initWithContentsOfURL?  or just [doclet reload]?
- (CFAction)reloadDocData:(id)sender
{
  // CPLog(@"%@: reloadDocData", self);
  // var theDoc = doclet; //[aNotification object];
  // CPLog(@"%@: query: %@", self, [doclet query]);

  //TODO:  since the query string comes from the doclet, query setup should be moved to doclet?
  var sparql = [CPString stringWithFormat:@"%@%@%@?query=%@&rhost=%@&rport=%@&rpath=%@",
			 RHOST, RPORT, RPATH,
			 encodeURIComponent([doclet query]),
			 SPARQLHOST, SPARQLPORT, SPARQLPATH];

  //TODO: this will go in the docletController as an initWithContentsOfURL msg to be sent to the doclet
  // the docletController will obtain the URL from the document, which it treats as a data-source.
  // CPLog(@"%@ doclet: %@", self, doclet);
  [doclet readDocletWithContentsOfURL:sparql display:YES error:nil];
  // [_docletController readDocletWithContentsOfURL:sparql display:YES error:nil];

  // [CPApp sendAction:@selector(openTheDoclet:)
  // 		 to:_docletController
  // 	       from:self];

  // CPLog(@"%@: reloadDocData", self);
}

/**
 * TODO:  pattern this logic after CPDocumentController's
 *   - (CPDocument)openDocumentWithContentsOfURL:(CPURL)anAbsoluteURL display:(BOOL)shouldDisplay error:(CPError)anError
 * which is the part of open logic that kicks in after open panel
*/
- (CPDocument)makeDocletWithContentsOfSparqlURL:(CPURL)sparqlURL
				       display:(BOOL)shouldDisplay
					 error:(CPError)anError
{
    // CPLog(@"%@: makeDocletWithContentsOfSparqlURL", self);
  // we already have a document, we just need to fetch data for its model and then display it
  // so we don't need to follow the doc creation logic of openDocumentWithContentsOfURL

    // if (!result)
    // {
    //     var type = [self typeForContentsOfURL:anAbsoluteURL error:anError];

    //     result = [self makeDocumentWithContentsOfURL:anAbsoluteURL ofType:type delegate:self didReadSelector:@selector(document:didRead:contextInfo:) contextInfo:[CPDictionary dictionaryWithObject:shouldDisplay forKey:@"shouldDisplay"]];

    //     [self addDocument:result];

    //     if (result)
    //         [self noteNewRecentDocument:result];
    // }

  // CPLog(@"    ....loading \n\t %@ \n\t\t", sparqlURL);
  [_readConnection cancel];
  var type = [self fileType];
  var aRequest = [CPURLRequest requestWithURL:[[CPURL alloc] initWithString:sparqlURL]];
  _readConnection = [CPURLConnection connectionWithRequest:aRequest delegate:self];
  _readConnection.session = _CPReadSessionMake([self fileType], self, @selector(document:didRead:contextInfo:), nil);
  // CPLog(@"    ....sent XHR");

    // else if (shouldDisplay)
    //     [result showWindows];

    // return result;
    // CPLog(@"/%@: makeDocletWithContentsOfSparqlURL", self);
}

- (void)onInspectorDidCancelForNewDoc:(CPNotification)aNotification
{
  CPLog(@"PdgmDocument: onInspectorDidCancelForNewDoc");
  [[CPNotificationCenter defaultCenter]
    removeObserver:self
	      name:@"InspectorDidCancelNotification" 
	    object:nil];
  [[CPNotificationCenter defaultCenter]
    removeObserver:self
	      name:@"InspectorDidAcceptNotification" 
	    object:nil];
  [[CPApp mainWindow] performClose:nil];
}

- (BOOL)validateMenuItem:(CPMenuItem)theMenuItem
{
  // CPLog(@"%@ validateMenuItem: %@; action %@", self, [theMenuItem title], [theMenuItem action]);
  if ([theMenuItem action] == @selector(performClose:)) return YES;
  if ([theMenuItem action] == @selector(saveDocument:)) return YES;
  if ([theMenuItem action] == @selector(saveDocumentAs:)) return YES;
  return YES;
}

@end

var _CPReadSessionMake = function(aType, aDelegate, aDidReadSelector, aContextInfo)
{
    return { fileType:aType, delegate:aDelegate, didReadSelector:aDidReadSelector, contextInfo:aContextInfo };
};

var _CPSaveSessionMake = function(anAbsoluteURL, aSaveOperation, aChangeCount, aDelegate, aDidSaveSelector, aContextInfo, aConnection) {
  return { absoluteURL:anAbsoluteURL, saveOperation:aSaveOperation, changeCount:aChangeCount,
	   delegate:aDelegate, didSaveSelector:aDidSaveSelector, contextInfo:aContextInfo, connection:aConnection };
}
