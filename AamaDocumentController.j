/*
 * 
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "PdgmDocument.j"
// @import "ScriptDocument.j"
@import "DocumentOpener.j"
@import "CatalogManager.j"
@import "MorphPropertyInspector.j"

CPSharedDocumentController = nil;

var AAMAHOME=@"/home",
  AAMAPROPS=@"/aama/Langs",
  AAMADAVURI=@"http://minkdev.appspot.com/aamadav/"
  URICLEARCACHE=@"properties/clear";

//var SPARQL = "http://localhost:8082/sparql",
//  SPARQLHOST="http://fu.sibawayhi.org/ds"  //  "69.55.234.116";


@implementation AamaDocumentController : CPDocumentController
{
    // _documents: list of open docs maintained by super
  PdgmOpenPanelController openPanelCtlr;
  // CatalogManager catMgr @accessors;
}
  
- (BOOL)applicationShouldOpenUntitledFile
{
  // CPLog(@"doc ctl: app should open untitled file");
  return YES;
}

//{DEBUG
- (id)init
{
  // debugger;
  CPLog(@"%@ doc controller: init", self);
  self = [super init];

  if (self)
    {
      _documents = [[CPArray alloc] init];

      if (!CPSharedDocumentController)
  	CPSharedDocumentController = self;

      _documentTypes = [[[CPBundle mainBundle] infoDictionary] objectForKey:@"CPBundleDocumentTypes"];
    }
  // CPLog(@"doctypes: " + _documentTypes);
  return self;
}
//DEBUG}

//{DEBUG
+ (id)sharedDocumentController
{
    if (!CPSharedDocumentController)
        [[self alloc] init];

    return CPSharedDocumentController;
}
//DEBUG}

////////////////////////////////////////////////////////////////
//{DEBUG
// - (CPDictionary)_infoForType:(CPString)aType
// {
//     CPLog(@"AamaDocumentController: _infoForType '%@'", aType);
//     var i = 0,
//         count = [_documentTypes count];
//     var documentType, dt;
//     for (;i < count; ++i)
//     {
//         documentType = _documentTypes[i];
// 	// dt = [documentType objectForKey:@"CPBundleTypeName"];
// 	CPLog(@"documentType: " + dt);
//         if (dt == aType) {
// 	    // CPLog(@"....documentType: " + dt);
//             return documentType;
// 	}
//     }
//     return nil;
// }
//DEBUG}

- (Class)documentClassForType:(CPString)aType
{
    // CPLog(@"%@/: documentClassForType %@", self, aType)
    var className = [[self _infoForType:aType] objectForKey:@"CPDocumentClass"];
    // CPLog(@"%@ class: %@ for type: %@ ", self, className, aType);
    return className ? CPClassFromString(className) : nil;
}

//{DEBUG
- (CPDocument)makeUntitledDocumentOfType:(CPString)aType error:({CPError})anError
{
  // CPLog(@"%@ makeUntitledDocumentOfType %@", self, aType);
  var theDocClass = [[self documentClassForType:aType] alloc];
  if (!theDocClass) {
    alert(@"....alloc of " + aType + @" class failed");
    return nil;
  } else {
    // CPLog(@"....theDocClass:" + theDocClass);
    var theDoc = [theDocClass initWithType:aType error:anError];
    // CPLog(@"/%@ makeUntitledDocument %@ OfType %@ ", self, theDoc, aType);
    return theDoc;
  }
}
//DEBUG}

//{DEBUG
- (void)openUntitledDocumentOfType:(CPString)aType display:(BOOL)shouldDisplay
{
  // CPLog(@"%@ openUntitledDocumentOfType %@", self, aType);
  var theDocument = [self makeUntitledDocumentOfType:aType error:nil];
  if (theDocument)
    [self addDocument:theDocument];

  if (shouldDisplay)
    {
      // CPLog(@"    AamaDocumentController calling doc.makeWindowControllers, then doc.showWindows")
      [theDocument makeWindowControllers];
      [theDocument showWindows];
    }
  // CPLog(@"/%@ openUntitledDocument %@ OfType %@", self, theDocument, aType);
  return theDocument;
}
//DEBUG}
//// temp end

////////////////////////////////////////////////////////////////
- (CFAction)cascade:(id)aSender
{
  // CPLog(@"%@ cascade", self);
  var nWins = 0;
  var menuBarH = [[CPApp mainMenu] menuBarHeight];

  var offset = menuBarH*2;
  
  var n = 0;
  var docs = [self documents];
  // CPLog(@"    doc count %@", [docs count]);
  for (var i=0; i<[docs count]; i++) {
    var doc = [docs objectAtIndex:i];
    // CPLog(@"    doc %@ %@", i, doc);
    var wcs = [doc windowControllers];
    // CPLog(@"    wcs %@ (count %@)", wcs, [wcs count]);
    var j = 0;
    for (j=0; j<[wcs count]; j++) {
      var win = [[wcs objectAtIndex:j] window];
      // CPLog(@"    win %@", win);
      [win setFrameOrigin:CGPointMake(nWins*menuBarH+offset, nWins*menuBarH+menuBarH+offset)];
      nWins = nWins + 1;
    }
    [win makeKeyAndOrderFront:self];
  }
}

////////////////////////////////////////////////////////////////
- (CFAction)clearCache:(id)aSender
{CPLog(@"%@ clearCache", self);

  CPLog(@"%@ theURL: ", self, URICLEARCACHE);
  var aRequest = [CPURLRequest requestWithURL:[[CPURL alloc]
						initWithString:URICLEARCACHE]];
  [aRequest setHTTPMethod:@"GET"];
  // CPLog(@"sending XHR");
  //FIXME:  add timeout logic in case host unavailable
  var connection = [CPURLConnection connectionWithRequest:aRequest delegate:self];}

////////////////////////////////////////////////////////////////
- (CFAction)newCatalogManager:(id)aSender
{
  CPLog(@"%@ newCatalogManager", self);

  // CPLog(@"%@ number of open docs: %@", self, [[self documents] count]);
  // var theDoc = [self openUntitledDocumentOfType:@"catalog" display:YES];

  // CPLog(@"%@ session cookie: %@");
  var theURL = AAMAHOME // @"/aamadav/"; // @"http://localhost:8088/aamadav/";

  // var theDoc = [self documentForURL:theURL]; // searches self list of open docs
  // if (theDoc) {
  //   [theDoc orderFront:self];
  //   return;
  // }

  var theDoc = [self openDocumentWithContentsOfURL:theURL display:YES error:nil];

  // if (catMgr == null) {
  //   CPLog(@"AamaDocumentController:newCatalogManager : catMgr is null?");
  //   [self setCatMgr:[[CatalogManager alloc] init]];
  //   // [self setCatMgr:catMgr];
  // }

  //BUG!!  TODO: fix close logic for catMgr to update catMgr ivar properly
  // ideally, give it the whole docMgr, doc, winctlr, win treatment
  //  that is, treat it as just another doc type
  // catMgr = [[CatalogManager alloc] init];
  // [self setCatMgr:catMgr];

  // CPLog(@"AamaDocumentController:newCatalogManager : sending refresh msg to cat mgr");
  // [[self catMgr] refresh];
  // [CPApp sendAction:@selector(show:)
  // 		 to:catMgr
  // 	       from:self];

  // CPLog(@"/%@ newCatalogManager", self);
}

- (CFAction)newMorphPropertyInspector:(id)aSender
{CPLog(@"%@ newMorphPropertyInspector", self);

  //TODO:  make this a GET on a static URI, with query and results cached on server.

  // CPLog(@"%@ number of open docs: %@", self, [[self documents] count]);
  // var theDoc = [self openUntitledDocumentOfType:@"catalog" display:YES];

// FROM <urn:aama:testdata> \

//   var theQuery = @" \
// prefix aama:	 <http://oi.uchicago.edu/aama/schema/2010#> \
// prefix rdfs:	 <http://www.w3.org/2000/01/rdf-schema#> \
// SELECT DISTINCT ?Lang ?Property ?Value \
// WHERE { \
// ?term aama:lang ?l . ?l rdfs:label ?Lang . \
// ?term ?p ?pval . ?pval rdfs:label ?Value .\
//  ?p rdfs:label ?Property . \
// } \
// ORDER BY ASC(?Lang) ASC(?Property) ASC(?Value)\
// ";

//   var theQuery = @" \
// prefix aama:	 <http://oi.uchicago.edu/aama/schema/2010#> \
// prefix rdfs:	 <http://www.w3.org/2000/01/rdf-schema#> \
// SELECT DISTINCT ?Lang \
// WHERE { \
// ?term aama:lang ?l . ?l rdfs:label ?Lang . \
// } \
// ORDER BY ASC(?Lang)\
// ";

  var theURL = AAMAPROPS;
  CPLog(@"%@ theURL: %@", self, theURL);
  var theDoc = [self openDocumentWithContentsOfURL:theURL display:YES error:nil];
  // if (theDoc) {
  //   [theDoc orderFront:self];
  // }
  // CPLog(@"/%@ newMorphPropertyInspector", self);
}

- (CFAction)newPdgmDocument:(id)aSender
{
  CPLog(@"\n\n");
  CPLog(@"%@ newPdgmDocument", self);
  //[super newDocument:aSender];
  // CPLog(@"number of open docs: %@", [[self documents] count]);
  var theDoc = [self openUntitledDocumentOfType:@"paradigm" display:YES];

  // var theDoc = [super openUntitledDocumentOfType:@"pdgm" display:YES];
  // CPLog(@"newPdgmDoc " + theDoc + " finished; now display property sheet");
  // [[CPNotificationCenter defaultCenter ]
  //           addObserver:theDoc
  //              selector:@selector(onInspectorDidCancelForNewDoc:)
  //                  name:@"InspectorDidCancelNotification" 
  //                object:nil];
  [theDoc showDocPropertySheet:theDoc];
  // CPLog(@"/%@ newPdgmDocument", self);
}

- (CFAction)newScriptDocument:(id)sender
{
  CPLog(@"\n\n");
  CPLog(@"%@ newScriptDocument", self);
  //[super newDocument:sender];
  var theDoc = [self openUntitledDocumentOfType:@"script" display:YES];
  // var theDoc = [super openUntitledDocumentOfType:@"script" display:YES];
  if (theDoc) {
    // [theDoc showPropertySheet:sender];
  } else {
    // CPLog(@"AamaDocumentController: newScriptDocument");
  }
}

- (CFAction) fetchContent:(id)aSender
{
    CPLog(@"%@ fetchContent %@", self, aSender);
    // if FileType == kCOLLECTION then fetch contents
    // otherwise NOP
}

- (CFAction) openDocument:(id)aSender
{
    CPLog(@"%@ openDocument %@", self, aSender);
    [CPApp sendAction:@selector(openSomeDocument:) to:self from:aSender];
}

- (CFAction)openSomeDocument:(id)aSender
{
  CPLog(@"%@ openSomeDocument", self);
 // app doc controller is responsible for
  //  1.  displaying open dialog
  //      a.  fetch file system tree from server
  //      b.  display fs tree in open dialog
  //  2.  obtaining selection and determining doc type
  //  3.  open doc of right type
  //      a.  send 'open doc of type' message to self
  // CPLog(@"AamaDocumentController: openDocument");
  [[CPNotificationCenter defaultCenter ]
            addObserver:self
               selector:@selector(onIriWasAcquired:)
                   name:@"IriWasAcquired" 
                 object:nil];
  openPanelCtlr = [[PdgmOpenPanelController alloc] init];
  docIRI = [openPanelCtlr acquireIriFor:OPEN];
  // CPLog(@"docIRI returned from DocOpenPanel, which sent IriWasAcquired notification");
  // the opener sends an IriWasAcquired notification, which is handled by onIriWasAcquired
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  sender is a collection with a selection, e.g. from CatalogBrowser
- (CFAction)openSelectedDocument:(id)sender
{
  CPLog(@"\n\n");
  CPLog(@"%@ openSelectedDocument from %@", self, sender);
  var item = [sender selectedItem],
    path = [item objectForKey:@"URI"],
    type = [item objectForKey:@"FileType"];
  // CPLog(@"%@ path: %@", self, path);

  //TODO: this assumes we have only one doc type (pdgm "file");
  //  change to support additional types
 // if (type == @"PARADIGM")  // != @"COLLECTION"
  //   var theDoc = [self documentForURL:path]; // searches self list of open docs
  // CPLog(@"%@ found theDoc: %@", self, theDoc);
  // if ( ! theDoc ) {
    thedoc = [self openDocumentWithContentsOfURL:path
					 display:YES
					   error:nil];
  // }
  // [theDoc orderFront:self];
  CPLog(@"/%@ /openSelectedDocument", self);
}

- (void)onIriWasAcquired:(CPNotification)aNotification
{
  // CPLog(@"AamaDocumentController: onIriWasAcquired %@", [aNotification object] );
  var iri = [aNotification object];
  // [self openDocumentWithContentsOfURL:[CPURL URLWithString:iri] display:YES error:nil];
  [self openDocumentWithContentsOfURL:iri display:YES error:nil];
}

- (CPDocument)openDocumentWithContentsOfURL:(CPURL)anAbsoluteURL
				    display:(BOOL)shouldDisplay
				      error:(CPError)anError
{
  CPLog(@"%@ openDocumentWithContentsOfURL: %@", self, anAbsoluteURL);

  var theDoc = [self documentForURL:anAbsoluteURL]; // searches self list of open docs

  if (theDoc) {
    // doc already open in a window, so add another window
    // CPLog(@"    doc %@ at URL already open; making another window for it", theDoc);
    [theDoc makeWindowControllers];
  } else {
    // CPLog(@"    doc %@ at URL NOT already open; making doc", theDoc);
    var type = [self typeForContentsOfURL:anAbsoluteURL error:anError];
    // CPLog(@"%@ openDocumentWithContentsOfURL     of type %@", self, type);
    theDoc = [self makeDocumentWithContentsOfURL:anAbsoluteURL
					  ofType:type
					delegate:self
				 didReadSelector:@selector(document:didRead:contextInfo:)
				     contextInfo:[CPDictionary dictionaryWithObject:shouldDisplay
									     forKey:@"shouldDisplay"]];

    if (theDoc) {
      [self addDocument:theDoc];
      if (theDoc) {
	[self noteNewRecentDocument:theDoc];
      }
    }
  }
  if (shouldDisplay) {
    // CPLog(@"%@openDocumentWithContentsOfURL showing windows for doc %@", self, theDoc);
    [theDoc showWindows];
  }
  // CPLog(@"doc: %@; docmdl: %@; docmdl.doc: %@", theDoc, [theDoc doclet], [[theDoc doclet] theDocument]);
  CPLog(@"/%@ /openDocumentWithContentsOfURL", self);
  return theDoc;
}

- (CPDocument)makeDocumentWithContentsOfURL:(CPURL)anAbsoluteURL
				     ofType:(CPString)aType
				   delegate:(id)aDelegate
			    didReadSelector:(SEL)aSelector
				contextInfo:(id)aContextInfo
{
  CPLog(@"%@ makeDocumentWithContentsOfURL - type %@, delegate: %@", self, aType, aDelegate);
  var docclass =  [[self documentClassForType:aType] alloc];

  // CPDoc initWithContentsOfURL sends readFromURL message to self
  // ideally we would start up the progress indicator in doc's readFromURL implementation
  // But since we're making a new doc, we have no window with progress spinner;
  // So we turn on the progress indicator here at bottom of workspace before submitting:

  // var pw = [CPPlatformWindow primaryPlatformWindow];

  var piBox = [CALayer init];
  

  var windows = [CPApp windows];
  // CPLog(@"  window count: %@", [windows count]);
  for (iWin=0; iWin<[windows count]; iWin++) {
    if ( [windows[iWin] isFullPlatformWindow] ) {
      var bottomBar = [[windows[iWin] contentView] viewWithTag:66];
      var f = [[windows[iWin] contentView] bounds];
      var progressIndicator = [[CPProgressIndicator alloc]
				initWithFrame:CGRectMake(CPRectGetWidth(f)-55, CPRectGetHeight(f)-55,
							 50, 50)];
      // var progressIndicator = [[CPProgressIndicator alloc] initWithFrame:CGRectMakeZero()];
      [progressIndicator setTag:123456789]; // get it? progress?
      [progressIndicator setIndeterminate:YES];
      [progressIndicator setStyle:CPProgressIndicatorSpinningStyle];
      // [progressIndicator setStyle:CPProgressIndicatorHUDBarStyle];
      // [progressIndicator setStyle:CPProgressIndicatorBarStyle];
      // [progressIndicator setControlSize:CPMiniControlSize];
      [progressIndicator setControlSize:CPRegularControlSize];
      [progressIndicator sizeToFit];
      [progressIndicator startAnimation:YES];
      [[windows[iWin] contentView] addSubview:progressIndicator];
      break;
    }
  }

  // sends readFromURL msg to doc
  // each doc class uses 'self' as both XHR and didRead delegates
  return [docclass initWithContentsOfURL:anAbsoluteURL
				  ofType:aType
				delegate:aDelegate  // should be nil; callee responsible for setting
			 didReadSelector:aSelector
			     contextInfo:aContextInfo];
  CPLog(@"/%@ /makeDocumentWithContentsOfURL", self);
}

////////////////////////////////////////////////////////////////
// this method is passed as a selector to doc.saveToURL
- (void)document:(CPDocument)aDocument didSave:(BOOL)didSave contextInfo:(id)aContextInfo
{
  // CPLog(@"%@/ document %@ didSave %@", aDocument, didSave);
}

// this method is passed as a selector starting with open
- (void)document:(CPDocument)aDocument didRead:(BOOL)didRead contextInfo:(id)aContextInfo
{
    CPLog(@"%@didRead doc %@ (%@)", self, aDocument, didRead);
    if (!didRead)
        return;

    [aDocument makeWindowControllers];

    if ([aContextInfo objectForKey:@"shouldDisplay"])
        [aDocument showWindows];

    // CPLog(@"    mainwin: %@ keywin: %@", [CPApp mainWindow], [CPApp keyWindow]);
    CPLog(@"/%@ /document:%@ didRead:%@", self, aDocument, didRead);
}

//{DEBUG
- (CPString)typeForContentsOfURL:(CPURL)theURL error:(CPError)outError
{
  CPLog(@"%@ typeForContentsOfURL: %@", self, theURL);
  if (theURL == AAMAHOME) return "catalog";
  if (theURL == AAMAPROPS) return "morfinspector";

  // var pfx = [theURL rangeOfString:@"/sparql"
  //       		  options:(CPAnchoredSearch)];
  // CPLog(@"    pfx : %@, %@", pfx.location, length);
  // if (pfx.location != CPNotFound) return "morfinspector";
  // CPLog(@"  pfx not found");
  return [super typeForContentsOfURL:theURL error:outError];

  // var index = 0,
  //   count = _documentTypes.length,
  //   extension = [[theURL pathExtension] lowercaseString],
  //   starType = nil;
  // // CPLog(@"extension: " + extension);
  // // CPLog(@"count: " + count);
  // for (; index < count; ++index)
  //   {
  //     var documentType = _documentTypes[index];
  //     // CPLog(@"documentType: " + documentType);
  //     var extensions = [documentType objectForKey:@"CFBundleTypeExtensions"];
  //     // CPLog(@"extensions: " + extensions);
  //     var extensionIndex = 0,
  // 	extensionCount = extensions.length;

  //       for (; extensionIndex < extensionCount; ++extensionIndex)
  //       {
  //           var thisExtension = [extensions[extensionIndex] lowercaseString];
  //           if (thisExtension === extension)
  //               return [documentType objectForKey:@"CPBundleTypeName"];

  //           if (thisExtension === "****")
  //               starType = [documentType objectForKey:@"CPBundleTypeName"];
  //       }
  //   }

  //   return starType || [self defaultType];
}
//DEBUG}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- (void)didEndSheet:(CPAlert)theAlert returnCode:(int)returnCode // contextInfo:(void)contextInfo {
{
  // CPLog(@"didEndSheet");
  [[openPanelCtlr panel] orderOut:self];
  }
}

- (CFAction) cancelOpen:(id)sender
{
  // CPLog(@"cancelOpenDocument");
  [CPApp endSheet:[_ctrlOpenPanel panel]];
}

- (CFAction) closeSheet:(id)sender
{
  // CPLog(@"close dialog");
  [CPApp endSheet:pnlNewPdgm];
}

//{DEBUG
- (void) addDocument:(CPDocument)aDocument
{
  CPLog(@"%@ addDocument: %@", self, aDocument);
  [super addDocument:aDocument];
  var docs = [self documents];
  var n = [docs count];
  // CPLog(@"    doc count: %@", n);
  if (n > 0 ) {
    for (i = 0; i < n; ++i) {
      var theDoc = docs[i];
      // CPLog(@"    doc %@ of type %@", theDoc, [theDoc fileType]);
    }
  }
  CPLog(@"%@ /addDocument: %@", self, aDocument);
}
//DEBUG}

- (void)documentController:(NSDocumentController *)docController  didCloseAll: (BOOL)didCloseAll contextInfo:(void *)contextInfo
{
  // CPLog(@"%@ docController %@ didCloseAll %@", self, docController, didCloseAll);
}

- (CFAction)closeAllDocuments:(id)aSender
{
  // CPLog(@"%@ closeAllDocuments %@", self, aSender);
  //TODO:  exclude one browser window?
  [self closeAllDocumentsWithDelegate:self
		  didCloseAllSelector:@selector(documentController:didCloseAll:contextInfo:)
			  contextInfo:nil]
  // CPLog(@"%@ closeAllDocuments %@", self, aSender);
}

// - (CFAction) closeDocument:(id)aSender
// {
//   CPLog(@"AamaDocumentController: closeDocument");
//   [super closeDocument:aSender];
// }

// - (CFAction)performClose:(id)aSender
// {
//   CPLog(@"%@ performClose", self);
// }

- (CFAction) saveDocumentsAll:(id)aSender
{
  // CPLog(@"AamaDocumentController: saveDocumentsAll");
}

- (CFAction) saveDocuments:(id)aSender
{
  // CPLog(@"%@ saveDocuments", self);
}

- (void)import:(CPDocument)aDocument
{
  // CPLog(@"AamaDocumentController: import");
}
- (void)export:(CPDocument)aDocument
{
  // CPLog(@"AamaDocumentController: export");
}

- (CFAction)miniaturize:(id)sender
{
  // CPLog(@"AamaDocumentController:miniaturize");
}

- (CFAction)help:(id)sender
{
  // CPLog(@"AamaDocumentController:help");
  var theWindow = [[CPWindow alloc] initWithContentRect: CGRectMake(0,0, 600, 300)
					      styleMask:
				      CPTitledWindowMask
				    | CPMiniaturizableWindowMask
				    | CPClosableWindowMask
				    | CPResizableWindowMask];
  [theWindow center];
  [theWindow setBackgroundColor:[CPColor colorWithHexString:@"D5E1E8"]];
  // [theWindow setTitle:@"Aama Paradigm Window"];
  var contentView = [theWindow contentView];
  
  // var helpPath = [[CPBundle bundleForClass:[CPWindowController class]] pathForResource:@"AamaHelp.html"];
  var mainInfo = [[CPBundle mainBundle] infoDictionary];
  var helpPath = [mainInfo objectForKey:@"AamaHelp"];

  var webView = [[CPWebView alloc] initWithFrame:CGRectMake(0,0,400,400)];
  [webView setMainFrameURL:helpPath];
  [contentView addSubview:webView];
  [theWindow orderFront:self];
  // window.open('http://localhost:8088/wb/Resources/AamaHelp.html','','scrollbars=no,menubar=no,height=600,width=800,resizable=yes,toolbar=no,location=no,status=no');
}

- (CFAction)cut:(id)sender
{
  // CPLog(@"AamaDocumentController:cut");
  [super miniaturize:sender];
}

- (CFAction)removeDocumentByLibrarian:(id)sender
{
  // CPLog(@"AamaDocumentController: removeDocumentByLibrarian");
  var theItem = [sender selectedItem];
  // CPLog(@"theItem " + theItem);
  var theDocURI = [theItem objectForKey:@"URI"];
  // CPLog(@"doc uri: %@", theDocURI);
  var theDoc = [self documentForURL:theDocURI];
  // CPLog(@"docs search result: %@", theDoc);
  if (theDoc) {
  // if ( doc is open )
  //   send removeDocument msg to doc controller
  } else {
    //   send DELETE xhr
    [self removeDocument:theDocURI];
    [CPApp sendAction:@selector(removeItem:)
		 to:nil
	       from:sender];
 // [super removeDocument:aDocument];
  }
}

// - (CFAction)removeDocument:(id)theDoc
// {
//   CPLog(@"%@ removeDocument: %@", self, theDoc);
//   [super removeDocument:theDoc];
//   // [self deleteFile:theDoc];
// }

- (CFAction)deleteFile:(id)theDocURI
{
  // CPLog(@"AamaDocumentController: deleteFile: %@", theDocURI);

  var aRequest = [CPURLRequest requestWithURL:[[CPURL alloc] initWithString:theDocURI]];
  [aRequest setHTTPMethod:@"DELETE"];
  // CPLog(@"sending XHR");

  //FIXME:  add timeout logic in case host unavailable
  var connection = [CPURLConnection connectionWithRequest:aRequest delegate:self];
  // [super removeDocument:theDoc];
}

// xhr connection delegate methods
- (void)connection:(CPURLConnection)aConnection didReceiveResponse:(CPURLResponse)aResponse
{
  // CPLog(@"didReceiveResponse");
}

- (void)connection:(CPJSONPConnection) connection didReceiveData:(Object)data
{
  // CPLog(@"didReceiveData");
  // CPLog(@"\n" + data);
}

- (void)connection:(CPJSONPConnection)connection didFailWithError:(CPString)error
{
  // CPLog(@"didFailWithError " + error);
}

- (void)connectionDidFinishLoading:(CPURLConnection)aConnection
{
  // CPLog(@"AamaDocumentController: connectionDidFinishLoading");
  [CPApp sendAction:@selector(refresh:)
		 to:nil
	       from:self];
}

//{DEBUG
- (CPDocument)documentForURL:(CPURL)aURL
{
  // CPLog(@"%@ documentForURL %@", self, aURL);
    var index = 0,
        count = [_documents count];
    for (; index < count; ++index)
    {
        var theDocument = _documents[index];
        if ([[theDocument fileURL] isEqual:aURL]) {
	  // CPLog(@"    the doc %@", theDocument);
	  return theDocument;
	}
    }
    return nil;
}
//DEBUG}

- (BOOL)XvalidateMenuItem:(CPMenuItem)theMenuItem
{
  // CPLog(@"%@ validateMenuItem: %@; action %@", self, [theMenuItem title], [theMenuItem action]);
  if ([theMenuItem action] == @selector(closeAllDocuments:)) {
    if ([[self documents] count] > 0)
      return YES
      else return NO;
  }
  // if ([theMenuItem action] == @selector(saveDocument:)) return NO;
  return YES;
}

@end

@implementation XhrDeleteCallbacks
// xhr connection delegate methods
+ (XhrDeleteCallbacks)get
{
  return [XhrDeleteCallbacks alloc];
}

+ (void)connection:(CPURLConnection)aConnection didReceiveResponse:(CPURLResponse)aResponse
{
  // CPLog(@"didReceiveResponse " + aResponse);
}

+ (void)connection:(CPJSONPConnection) connection didReceiveData:(Object)data
{
  // CPLog(@"didReceiveData");
  // CPLog(@"\n" + data);
}

+ (void)connection:(CPJSONPConnection)connection didFailWithError:(CPString)error
{
  CPLog(@"didFailWithError " + error);
}

+ (void)connectionDidFinishLoading:(CPURLConnection)aConnection
{
  // CPLog(@"connectionDidFinishLoading");
}

@end
