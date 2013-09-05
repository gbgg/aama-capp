/*
 * PdgmDoclet.j
 *
 *  The DocletView displays data; it uses the Doclet as its data source.
 */
@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
// @import "PdgmDocletViewController.j"
@import "MIDoclet.j"
// @import "PdgmDocletCollectionView.j"
// @import "PdgmDocletTableView.j"
// @import "PdgmDocModel.j"

var C_FILENAME = 0,
  C_PATH = 1;


var RHOST="",
  RPATH="/pdgm",
  RPORT="";

// var SPARQLHOST="http://localhost",
//   SPARQLPORT=":3030",
//   SPARQLPATH="/aama/query";

var SPARQLHOST="http://fu.sibawayhi.org",
  SPARQLPATH="/aama/query",
  SPARQLPORT=":80";
  //"69.55.234.116";


//TODO:  make this PdgmDoclet : MIDoclet
@implementation PdgmDoclet : MIDoclet // CPObject
{
  PdgmDocument theDocument @accessors;
  CPString docletType @accessors;
  // this stuff is metadata, it should be in PdgmDocument?
  CPString desc @accessors;
  //TODO: save all bits of the query string, including
  // "/sparql?query=%@&rhost=%@&rport=8080&rpath=sparql", SPARQLHOST
  CPString host @accessors;
  CPString port @accessors;
  CPString path @accessors;  // sparql endpoint
  CPString query @accessors;
  CPString pgrid @accessors; // move to DocletView?
  CPString titlebar @accessors; // display FILENAME or PATH in titlebar

  BOOL reloadFlag @accessors;

  CPURLConnection     _readConnection;
  CPURLRequest        _writeRequest;

  // datatable stuff - for sorting the table
  CPTableColumn lastColumn;  // track last column chosen
  SEL columnSortSelector;      // holds a method pointer
  BOOL sortDescending;         // sort in descending order

  // pgrid stuff
  var docletData @accessors;
  // docletData contains json data of form:
  //{ "head": {"vars": ["token", "POS", "Class", "Case", "Nbr", "Person", "Gender"]},
  //  "results": { "bindings": [ { "token": { "type": "literal", "value": "yo(o)" }, "POS": { "type": "literal", "value": "pro" }, "Class": { "type": "literal", "value": "independent" }, "Case": { "type": "literal", "value": "absolutive" }, "Nbr": { "type": "literal", "value": "sg" }, "Person": { "type": "literal", "value": "p1" }, "Gender": { "type": "literal", "value": "⊤" } },
  // { "token": { "type": "literal", "value": "ko(o)" }, "POS": { "type": "literal", "value": "pro" }, "Class": { "type": "literal", "value": "independent" }, "Case": { "type": "literal", "value": "absolutive" }, "Nbr": { "type": "literal", "value": "sg" }, "Person": { "type": "literal", "value": "p2" }, "Gender": { "type": "literal", "value": "⊤" } },
  // etc.
  // This is effectively a JS dictionary (not a CPDictionary) of two elts, keys "head" and "results"
  // "head" is a JS dictionary on one elt, key="vars", val = array of strings (morphological property names)
  // "results" is a JS dictionary of one elt, key="bindings", val = array of JS dictionaries
  //        "bindings" is an array whose elts is a JS dictionary whose keys are the morph property names of head.vars
  //		each val in this dictionary is a JS dictionary of two elts, "type" and "value"

  var headers;
  CPMutableArray __terms;
  int __termcount;
  CPMutableArray __termsIdx;  // used by normalize:i
  CPMutableArray __properties @accessors(property=pdgmProps);	//e.g. [gender, [m, f]], [nbr, [s, d, p]]...
  int __propcount;

  CPMutableArray __pdgmTerms @accessors(property=pdgmTerms);

  CPMutableArray __stack1;  // temp work area
  CPMutableArray __stack2;  // temp work area
}

-(id)init
{
  CPLog(@"%@: init\n", self);
  self = [super init];
  __pdgmTerms = [[CPMutableArray alloc] init];

  __stack1 = [[CPMutableArray alloc] init];
  __stack2 = [[CPMutableArray alloc] init];
  return self;
}

- (id)initWithCoder: (CPCoder)coder
{
  CPLog(@"%@: initWithCoder", self);
  if (self = [super init])
    {
      [self setQuery: [coder decodeObjectForKey:@"query"]];
      [self setPgrid: [coder decodeObjectForKey:@"pgrid"]];
      // [self setTitlebar: [coder decodeIntforKey:@"titlebar"]];
    }
  __pdgmTerms = [[CPMutableArray alloc] init];

  __stack1 = [[CPMutableArray alloc] init];
  // CPLog(@"__stack1: %@", __stack1);
  __stack2 = [[CPMutableArray alloc] init];
  return self;
}

- (void)encodeWithCoder:(CPCoder)coder
{
  [coder encodeObject: query forKey:@"query"];
  [coder encodeObject: pgrid forKey:@"pgrid"];
  // [coder encodeInt: titlebar forKey:@"titlebar"];
}

- (void)setDocument: (PdgmDocument)theDoc
{
  CPLog(@"%@/ setDocument: %@", self, theDoc);
  theDocument = theDoc;
  [[CPNotificationCenter defaultCenter ]
            addObserver:theDoc
               selector:@selector(onDocletWasLoaded:)
                   name:@"DocletWasLoaded" 
                 object:self];
}

////////////////////////////////////////////////////////////////
- (void)schematize
{
  // CPLog(@"%@: schematize", self);
  // Step 1:  get the induced list of prop vals
  //     Strategy: for each propname, find the unique set of values contained in the terms
  var propnames = docletData["head"]["vars"];
  var __propcount = propnames.length;
  CPLog(@"%@ properties count: %@", self, __propcount);
  CPLog(@"%@ propnames", self);
  console.dir(propnames);
  // example of propnames: ["token", "POS", "Class", "Nbr", ...]

  __terms = docletData["results"]["bindings"];
  __termcount = __terms.length;
  CPLog(@"%@ nbr of __terms: %@", self, __termcount);
  console.dir(__terms);
  // example of an elt of the terms array:
  // { "token": { "type": "literal", "value": "yo(o)" },
  //   "POS": { "type": "literal", "value": "pro" },
  //   "Class": { "type": "literal", "value": "independent" },
  //   etc.

  __properties = [[CPMutableArray alloc] init];
  // __properties is an array of prop elts, so we can reorder by propname
  // each of prop is also an array prop vals, of the form  [propname [propval1, propval2, ...]]
  //     this allows us to also reorder propvals

  var i, j;
  for (i=0; i< __propcount; i++) {
    // if ([propnames[i] isEqual:"token"]) {
    //   CPLog(@"**** skipping 'token' property", self);
    //   continue;
    // }
    // CPLog(i + " : " + propnames[i]);
    // a. use CPSet (not array) to get unique prop vals
    var vals = [[CPSet alloc] init];
    for (j=0; j<__termcount; j++) {
      var val = __terms[j][propnames[i]]["value"];
      if (val != "⊤" && val != "pNon-1") {
	[vals addObject:val];
      }
    }
    var prop = [[CPMutableArray alloc] init];
    [prop addObject:propnames[i]];
    [prop addObject:[vals allObjects]];
    [prop addObject:i]; // which column in the data?
    [__properties addObject:prop]
  }
  // CPLog(@"    schematized props: %@", __properties);

  // CPLog(@"/%@: schematize\n\n", self);
}

////////////////////////////////////////////////////////////////
// normalize
//   i:  index into properties array
- (void)normalize:(int)i withMatches:(CPArray)matches
{
  // CPLog(@"%@: normalize: %@ : %@\n", self, i, i<__propcount?__properties[i][0]:@"null");
  // CPLog(@"%@: normalize with matches %@; stack1 size %@", self, matches, [__stack1 count]);
  var pname, pval;
  pname = __properties[i][0];
  if ([pname isEqual:"token"]) {
    // CPLog(@"**** skipping 'token' property", self);
    // newMatches = [[[CPMutableArray alloc] init] setArray:matches];
    i++;
    pname = __properties[i][0];
  }

  var valcount, j;
  var result, t, term, tval;
  var nexti;
  var newMatches;
  var pvi, si, sl;
  
  valcount = __properties[i][1].length;
  // CPLog(@"\t\t\t[%@] : %@", __properties[i][1], pname);

  for (j=0; j<valcount; j++) {
    newMatches = [[CPMutableArray alloc] init];
    [newMatches setArray:matches];
    pval = __properties[i][1][j];
    // CPLog(@"\n\t\t\t\tstart: prop: [%@][%@]: %@:%@ over matchlist %@", i, j, pname, pval, newMatches);

    if (__properties[i][1].length <= 1) {
      // CPLog(@"&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& SKIPPING mono val");
      nexti = i+1;
      result = [self normalize:nexti withMatches:newMatches];
      break;
    }
    
    if (i+1 >= __propcount) { // we're at the last property
      // CPLog(@"    at last property");
      // FIRST:  check stack.  If not null, copy and fill.
      if ([__stack1 count] > 0) {
	sl = [__stack1 count];
	// CPLog(@"oooooooooooooooo    dealing with stack1 of %@ elts: %@", sl, __stack1);
	// CPLog(@"oooooooooooooooo    dealing with working stack of %@ elts: %@", [newMatches count], newMatches);
	[__stack2 removeAllObjects];
	for (si=0; si<sl; si++) {
	  for (pvi=0; pvi<valcount; pvi++) {
	    var pv = __properties[i][1][pvi];
	    if (pv == "⊤" || pv == "pNon-1") continue;
	    var elt = clone(__stack1[si]);
	    elt[pname]["value"] = pv;
	    [__stack2 addObject:elt];
	  }
	}
	// CPLog(@"    stack2 size: %@ : %@", [__stack2 count], __stack2);
	var temp = [__pdgmTerms arrayByAddingObjectsFromArray:__stack2];
	__pdgmTerms = temp;
	[__stack2 removeAllObjects];
	[__stack1 removeAllObjects];
      }
      ////////////////
      //  we're at the last propname in the proplist
      // CPLog(@"    iterate over matchlist %@", newMatches);


      for (var t=0; t < [newMatches count]; t++) {
	term = __terms[[newMatches objectAtIndex:t]];
	tval = term[pname]["value"];
	// CPLog(@"    %@: ======== %@ == %@?  %@", [newMatches objectAtIndex:t], tval, pval, tval==pval);
	// CPLog(@"  matchlist iter: %@:%@ == %@?  %@", [newMatches objectAtIndex:t], tval, pval, tval==pval);
	if ( tval == pval)  {
	  newterm = clone(term);
	  oldtval = newterm[pname]["value"];
	  // CPLog(@"     retaining %@: newtval %@:%@ for old pval %@: %@ ################",
	  // 	newterm["token"]["value"],
	  // 	pname, pval,
	  // 	pname, oldtval);
	  [__pdgmTerms addObject:newterm];
	} else {
	  if ( pval != tval ) {
	    if (tval == "⊤" || tval == "pNon-1") {
	      // CPLog("   pval: %@; tval: %@", pval, tval);
	      //  we know pval != TOP.  if tval == TOP, then insert the pval
	      //  otherwise, we expect to find a match
	      newterm = clone(term); // term has tval == TOP
	      oldtval = newterm[pname]["value"];
	      // CPLog(@"    %@: newtval %@:%@ for old pval %@: %@ ################",
	      // 	    newterm["token"]["value"],
	      // 	    pname, pval,
	      // 	    pname, oldtval);
	      newterm[pname]["value"] = pval; // candidatePval;
	      // CPLog(@"bar    stack1 adding term %@ (token %@)", [newMatches objectAtIndex:t], newterm["token"]["value"]);
	      [__pdgmTerms addObject:newterm];
	      // CPLog(@"    pdgmTerms count: %@; stack1 count %@", __pdgmTerms.length, __stack1.length);
	    } else { // pval != tval and tval != TOP
	      // CPLog(@"    discarding matchlist item %@", [newMatches objectAtIndex:t]);
	      [newMatches removeObjectAtIndex:t];
	      t--;
	      continue;
	    }
	  } // end if tval != pval else tval == pval
	} // 	end of "not at last property" clause
      } // matchlist term iter
    } else { // if (i+1 >= __propcount) - we're not at last property
      // 
      // CPLog(@"    filtering term table ");
      if (valcount > 1) { // skip properties with same val for each term


	if ([__stack1 count] > 0) { // did we previously save terms to the temp stack?
	  sl = [__stack1 count];
	  // [__stack2 removeAllObjects];
	  // CPLog(@"xxxxxxxxxxxxxxxx   stack1 sz: %@; stack2 sz: %@", sl, [__stack2 count]);
	  // for (si=0; si<sl; si++) {
	  //   // for (pvi=0; pvi<valcount; pvi++) {
	  //     var elt = clone([__stack1 objectAtIndex:si]);
	  //     //set local elt val to pval;
	  //     [__stack2 addObject:elt];
	  //   // }
	  // }
	  // CPLog(@"    stack2 size: %@", [__stack2 count]);
	  // __stack1 = nil;
	  // __stack1 = [CPMutableArray arrayWithArray:__stack2];
	  // [__stack2 removeAllObjects];
	} // we did not previously save any terms to the temp stack
	// CAUTION: we iterate over newMatches, but we may remove entries; when we do, we decrement the index t
	var didMatch = NO;
	for (var t=0; t < [newMatches count]; t++) {
	  term = __terms[[newMatches objectAtIndex:t]];
	  tval = term[pname]["value"];
	  // CPLog(@"    %@: ======== %@ == %@?  %@", [newMatches objectAtIndex:t], tval, pval, tval==pval);
	  // CPLog(@"  matchlist iter: %@:%@ == %@?  %@", [newMatches objectAtIndex:t], tval, pval, tval==pval);
	  if ( tval == pval)  {
	    // CPLog(@"    \t\t retaining");
	    didMatch = YES;
	  } else {
	    if (didMatch) { // we had a prev match, which can only involve non-TOP values
	      // so all remaining pvals for this pname can be ignored
	      [newMatches removeObjectAtIndex:t];
	      t--;
	      continue;
	    }
	    if (tval == "⊤" || tval == "pNon-1") {
	      //  we know pval != TOP.  if tval == TOP, then insert the pval
	      //  otherwise, we expect to find a match
	      newterm = clone(term); // term has tval == TOP
	      oldtval = newterm[pname]["value"];
	      // CPLog(@"    %@: newtval %@:%@ for old pval %@: %@ ################",
	      // 	    newterm["token"]["value"],
	      // 	    pname, pval,
	      // 	    pname, oldtval);
	      newterm[pname]["value"] = pval; // candidatePval;
	      // CPLog(@"bar    stack1 adding term %@ (token %@)", [newMatches objectAtIndex:t], newterm["token"]["value"]);
	      [__stack1 addObject:newterm];
	      [newMatches removeObjectAtIndex:t];
	      t--;
	      // CPLog(@"    pdgmTerms count: %@; stack1 count %@", __pdgmTerms.length, __stack1.length);
	    } else { // pval != tval and tval != TOP
	      // if ( !didMatch ) { the we have a missing value }
	      // CPLog(@"    discarding matchlist item %@", [newMatches objectAtIndex:t]);
	      [newMatches removeObjectAtIndex:t];
	      t--;
	      continue;
	    }
	  } // 	end of "not at last property" clause
	} // matchlist term iter
      } // end of valcount > 1 clause
      if ( ([newMatches count] > 0) || [__stack1 count] > 0 ) {
	// CPLog(@"....recurring....");
	nexti = i+1;
	result = [self normalize:nexti withMatches:newMatches];
      } else {
	// CPLog(@"X return prop: [%@][%@]: %@:%@\n", i, j, pname, pval);
      }
    } // } else { // if (i+1 >= __propcount)
    // CPLog(@"return prop: [%@][%@]: %@:%@\n", i, j, pname, pval);
  }  // proplist iter -  for (j=0; j<valcount; j++) {
  // CPLog(@"%@/: normalize end; pdgmTerms count: %@\n", self, [__pdgmTerms count]);
}

////////////////////////////////////////////////////////////////
// reload data
- (id)reload
{
  CPLog(@"%@: reload for doc %@", self, theDocument);
  var sparql = [CPString stringWithFormat:@"%@%@%@?query=%@&rhost=%@&rport=%@&rpath=%@",
			 RHOST, RPORT, RPATH,
			 encodeURIComponent(query),
			 SPARQLHOST, SPARQLPORT, SPARQLPATH];

  // [[theDocument _windowControllers] makeObjectsPerformSelector:@selector(refreshButtonPush:) withObject:self];
  [self readDocletWithContentsOfURL:sparql display:YES error:nil];
  CPLog(@"/%@: reload", self);
}

// refresh display
- (id)refresh
{
  CPLog(@"%@/: refresh", self);
  [_view reloadData];
}

// - (void)XmakeViewControllers:(id)theWindowController
// {
//   CPLog(@"%@: makeViewControllers", self);

//   [super makeViewControllers];  //uneccessary

//   var ok = NO,
//     count = [_viewControllers count];
//   for (; index < count; ++index) {
//     var theVC = _viewControllers[index];
//     if ([theWC doclet] == self)
//       CPLog(@"%@ makeViewControllers: VC already made");
//       ok = YES;
//   }

//   if (ok == NO) { // expected outcome for programmatically controlled windows
//     CPLog(@"%@ makeViewControllers: makeing new VC");
//     var docletView = [[PdgmDocletTableView alloc]
// 			initWithFrame:CGRectMakeZero()];
//     [docletView setDoclet:self];
//     var cv = [[theWindowController window] contentView];
//     [docletView makeDocletViewForWindowView:cv];

//     var vc = [[PdgmDocletViewController alloc] initWithView:docletView];

  
//     [self addViewController:vc];
//   }
//   // [_docWinController synchronizeWindowTitleWithDocumentName];
//   // [[[self theDocument] _docWinController]
//   // 	addTabViewToView:[[win contentView]
//   // 			     viewWithTag:@"dataView"]];
//   CPLog(@"/%@: makeViewControllers", self);
// }

/**
 * TODO:  pattern this logic after CPDocumentController's
 *   - (CPDocument)openDocumentWithContentsOfURL:(CPURL)anAbsoluteURL display:(BOOL)shouldDisplay error:(CPError)anError
 * which is the part of open logic that kicks in after open panel
 * TODO:  follow naming conventions of doc controller:  initWithContentsOfURL etc.,
 *     to be called by docletController
*/
- (void)readDocletWithContentsOfURL:(CPURL)theURL
				       display:(BOOL)shouldDisplay
					 error:(CPError)anError
{ // 
  CPLog(@"%@: readDocletWithContentsOfURL %@", self, theURL);
  // we already have a document, we just need to fetch "indirect" data for its model and then display it
  // so we don't need to follow the doc creation logic of openDocumentWithContentsOfURL
    // CORRECTION:  we will once we implement docletController
    // var win = [[[self theDocument] _docWinController] window];

  [_readConnection cancel];

  [self setDocletType:@"sparql"];
  // CPLog(@"%@: docletType: %@", self, docletType);

  var aRequest = [CPURLRequest requestWithURL:[[CPURL alloc]
						  initWithString:theURL]];

  [aRequest setValue:@"application/sparql-results+json" forHTTPHeaderField:@"Accept"];

  _readConnection = [CPURLConnection connectionWithRequest:aRequest delegate:self];
  // CPLog(@"%@: XHR conn %@", self, _readConnection);
  _readConnection.session = _CPReadSessionMake([theDocument fileType], self, @selector(doclet:didRead:contextInfo:), nil);
}

- (void)readFromData:(CPData)aDatum ofType:(CPString)aType error:(CPError)anError
{
  // CPLog(@"%@: readFromData type %@ into doclet.docletData field", self, aType);
  docletData = [aDatum JSONObject];
  // doclet = [CPKeyedUnarchiver  unarchiveObjectWithData:aDatum];
  // CPLog(@"/%@: readFromData", self);
}

// delegate method: this message is attached (by
// readDocletWithContentsOfURL) to the XHR connection object, from
// which didReceiveData method will extract it and use it to notify
// the delegate that the data has been read
// TODO: this should be in DocletController, just as it is in the
// DocumentController for docs
- (void)doclet:(PdgmDoclet)theDoclet didRead:(BOOL)didRead contextInfo:(id)aContextInfo
{
  // CPLog(@"%@: theDoclet:didRead", self);

    if (!didRead)
        return;

    [self schematize];
    // CPLog("%@        schematized properties count: %@", self, __properties.length);

    var matches = [[CPMutableArray alloc] init];
    var t;
    for (t=0; t<__termcount; t++) {
      [matches addObject:t];
    }

    [self setPdgmTerms:[[CPArray alloc] init]];
    __stack1 = [[CPMutableArray alloc] init];
    __stack2 = [[CPMutableArray alloc] init];
    [self normalize:0 withMatches:matches];
    // CPLog(@"%@        normalized data record count: %@", self, __pdgmTerms.length);

    // CPLog(@"/%@:theDoclet:didRead", self);
}

- (void)setHeaders
{
  // CPLog(@"%@ setHeaders", self);
    var items = [_view grid];
    var segs =  [_view segView];
    [segs setLabel:@"X" forSegment:0];
    [segs setWidth:80 forSegment:0];
}

// xhr connection delegate methods
- (void)connection:(CPURLConnection)theConnection didReceiveResponse:(CPURLResponse)aResponse
{
  // CPLog(@"%@: didReceiveResponse", self);
}

- (void)connection:(CPJSONPConnection)theConnection didReceiveData:(Object)aDatum
{
  CPLog(@"%@: didReceiveData %@ bytes on conn %@", self, [aDatum length], theConnection);
  // CPLog(@"    ....%@ bytes", [aDatum length]);
  // console.dir(aDatum);

  // console.log(aDatum);

  //FIXME:  send this to the doclet controller, not the document
  // the doc may have multiple doclets with fetches in progress
  // [[theDocument window] refreshButtonPop:self];

  var windows = [CPApp windows];
  CPLog(@"  window count: %@", [windows count]);
  for (iWin=0; iWin<[windows count]; iWin++) {
    if ( [windows[iWin] isFullPlatformWindow] ) {
      CPLog(@"%@/  full platform window: %@", self, windows[iWin]);
      // var bottomBar = [[w contentView] viewWithTag:66];
      // var progressIndicator = [bottomBar viewWithTag:123456789];
      var progressIndicator = [[windows[iWin] contentView] viewWithTag:123456789];
      [progressIndicator stopAnimation:YES];
      [progressIndicator removeFromSuperview];
    }
  }

    var session = theConnection.session;

    // READ
    if (theConnection == _readConnection)
    {
      // CPLog(@"%@:didReceiveData will readFromData on conn %@", self, theConnection);
      // CPLog(@"    ....TODO: implement readFromData for sparql results data");
      [self readFromData:[CPData dataWithRawString:aDatum] ofType:session.fileType error:nil];

      // send didRead msg to delegate (should be docletController),
      // which will run [doclet makeViewControllers],
      // which will both make the controllers and make the view, and
      // attach view and doclet to controller
      objj_msgSend(session.delegate, session.didReadSelector, self, YES, session.contextInfo);
    }
    else
    {
      // CPLog(@"%@ EXCEPTION: didReceiveData conn %@ does not match originating conn %@", self, theConnection, _readConnection);
        // if (session.saveOperation != CPSaveToOperation)
        //     [self setFileURL:session.absoluteURL];
        // _writeRequest = nil;
        // objj_msgSend(session.delegate, session.didSaveSelector, self, YES, session.contextInfo);
        // [self _sendDocumentSavedNotification:YES];
    }
    // CPLog(@"/%@: didReceiveData %@ bytes on conn %@", self, [aDatum length], theConnection);
}

- (void)connection:(CPJSONPConnection)theConnection didFailWithError:(CPString)anError
{
  // CPLog(@"%@: didFailWithError %@", self, error);
    var session = theConnection.session;

    if (_readConnection == theConnection)
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
  CPLog(@"%@: connectionDidFinishLoading", self);
  // Notification should be observed by doc window controller,
  // which will fetch the doclet view for use in the window.
  // Or, send the doclet viewController or view as the
  // notification object.
  // [self setHeaders];

  CPLog(@"    theDocument %@", theDocument);
  var dic = [CPDictionary dictionaryWithObject:theDocument forKey:@"doc"];
  // CPLog(@"    dic: %@", [dic objectForKey:@"doc"]);
  [[CPNotificationCenter defaultCenter]
        postNotificationName:@"DocletWasLoaded" object:self
		    userInfo:dic];
  CPLog(@"/%@: connectionDidFinishLoading", self);
}

// from CPDocument:
- (void)_sendDocumentSavedNotification:(BOOL)didSave
{
  // CPLog(@"%@ _sendDocumentSavedNotification", self);
  // if (didSave)
  //   [[CPNotificationCenter defaultCenter]
  //           postNotificationName:CPDocumentDidSaveNotification
  //                         object:self];
  // else
  //   [[CPNotificationCenter defaultCenter]
  //           postNotificationName:CPDocumentDidFailToSaveNotification
  //                         object:self];
  // CPLog(@"ERROR **** should not happen: PdgmDoclet _sendDocumentSavedNotification");
}

////////////////////////////////////////////////////////////////
// CPCollectionView Delegate Methods
 -(void)collectionViewDidChangeSelection:(CPCollectionView)collectionView;
 {
   // CPLog(@"%@ collectionViewDidChangeSelection", self);
    // Called when the selection in the collection view has changed.
    // @param collectionView the collection view who's selection changed
 }

-(void)collectionView:(CPCollectionView)collectionView didDoubleClickOnItemAtIndex:(int)index;
{
  CPLog(@"%@ didDoubleClickOnItemAtIndex", self);
    // Called when the user double-clicks on an item in the collection view.
    // @param collectionView the collection view that received the double-click
    // @param index the index of the item that received the double-click
}

-(CPData)collectionView:(CPCollectionView)collectionView dataForItemsAtIndexes:(CPIndexSet)indices forType:(CPString)aType;
{
  CPLog(@"%@ dataForItemsAtIndexes", self);
  return [CPKeyedArchiver archivedDataWithRootObject:[cells objectAtIndex:[indices firstIndex]]];
  // Invoked to obtain data for a set of indices.
  // @param collectionView the collection view to obtain data for
  // @param indices the indices to return data for
  // @param aType the data type
  // @return a data object containing the index items
}

-(CPArray)collectionView:(CPCollectionView)collectionView dragTypesForItemsAtIndexes:(CPIndexSet)indices;
{
  CPLog(@"%@ dragTypesForItemsAtIndexes", self);
  // Invoked to obtain the data types supported by the specified indices for placement on the pasteboard.
  // @param collectionView the collection view the items reside in
  // @param indices the indices to obtain drag types
  // @return an array of drag types (CPString)
}

@end // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

@implementation CPMutableArray (ReverseArray)
- (void)reverse
{
  var i;
  for (i=0; i<(floor([self count]/2.0)); i++) {
    [self exchangeObjectAtIndex:i withObjectAtIndex:([self count]-(i+1))];
  }
}

@end

////////////////////////////////////////////////////////////////

var _CPReadSessionMake = function(aType, aDelegate, aDidReadSelector, aContextInfo)
{
    return { fileType:aType, delegate:aDelegate, didReadSelector:aDidReadSelector, contextInfo:aContextInfo };
};

var _CPSaveSessionMake = function(anAbsoluteURL, aSaveOperation, aChangeCount, aDelegate, aDidSaveSelector, aContextInfo, theConnection)
{
  return { absoluteURL:anAbsoluteURL, saveOperation:aSaveOperation, changeCount:aChangeCount,
	   delegate:aDelegate, didSaveSelector:aDidSaveSelector, contextInfo:aContextInfo, connection:theConnection
  };
}

function clone(obj){
    if(obj == null || typeof(obj) != 'object')
        return obj;

    var temp = obj.constructor(); // changed

    for(var key in obj)
        temp[key] = clone(obj[key]);
    return temp;
}

