/*
 * 
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "PdgmDoclet.j"
@import "PdgmHdrCell.j"
var TOP = 0;
var BOTTOM = 1;
var LEFT = 2;
var RIGHT = 3;

// static vars (simulate class variables

//TODO: move the data to the doclet
var hdrs;  // CPMutableArray sort controller

var DISPLAY = 0; // pvals[DISPLAY] : BOOL
var VALUE = 1; // pvals[VALUE] : CPString

var TOPBOX = 1000;
var LEFTBOX = 1002;

// memoized pval counts
// e.g. nTopPvals = number of cols in datagrid = product of pval counts of top header properties
// e.g. person (p1,p2,p3), gender (m,f), tense (past, present,future) yields nTopVals = 3*2*3 = 18
var nTopPvals, nBottomPvals, nLeftPvals, nRightPvals; // ints
var nTopProps, nBottomProps, nLeftProps, nRightProps; // ints
var __nProps; // total number of properties (memoize for sort routine)
var nPvals; // total number of property values (memoize for sort routine)

var cellW = 75;  // default col width

var DISPLAY = 0; // pvals[DISPLAY] : BOOL
var VALUE = 1; // pvals[VALUE] : CPString
PdgmDragType       = @"PdgmDragType";

@implementation PdgmSchemaBar : CPSegmentedControl
{
  var hdrCell @accessors;
  CPColor bgColor @accessors;
  var prop @accessors;

  var theHdrCells;  // list of highlighted cells
  var theTag; // int tag of highlighted cells
}

- (id)init
{
  theHdrCells = [[CPMutableArray alloc] init];
  return [super init];
}

// - (void)mouseMoved:(CPEvent)anEvent
// {
//   // CPLog(@"%@ mouseMoved", self);
//     [_nextResponder performSelector:_cmd withObject:anEvent];
// }

- (void)mouseEntered:(CPEvent)anEvent
{
  CPLog(@"%@ mouseEntered", self);

  var location = [self convertPoint:[anEvent locationInWindow] fromView:nil];
  var prop;
  var nSegs = [self segmentCount];
  for (var iSeg=0; iSeg<nSegs; iSeg++) {
    var segFrm = [self frameForSegment:iSeg];
    if ( CPRectContainsPoint(segFrm, location) ) {
      prop = [self tagForSegment:iSeg];
      if (prop) {
	CPLog(@"    entered seg %@, tag %@", iSeg, [prop objectForKey:@"iTermProp"]);
      }
    }
  }
  theTag = [prop objectForKey:@"iTermProp"];
  // CPLog(@" iTermProp %@", theTag);
  var cell = [prop objectForKey:@"cell"];
  var tvs = [cell subviews];
  var sv = [cell superview];
  theHdrCells = [sv subviews];
  // CPLog(@" tgt subviews: %@", tgts);
  for (i=0; i<[theHdrCells count]; i++) {
    var tgt = theHdrCells[i];
    // CPLog(@" tgt %@ tag %@", tgt, [tgt tag]);
    if ( [tgt tag] == theTag ) {
      var theSubviews = [tgt subviews];
      for (var j=0; j<[theSubviews count]; j++) {
	[theSubviews[j] setBackgroundColor:[CPColor colorWithHexString:@"B5DCF2"]];
      }
    }
  }
  [super mouseEntered:anEvent];
}

/*!
    Notifies the receiver that the mouse exited the receiver's area.
    @param anEvent contains information about the exit
*/
- (void)mouseExited:(CPEvent)anEvent
{
  CPLog(@"%@ mouseExited", self);
  for (var i=0; i<[theHdrCells count]; i++) {
    var tgt = theHdrCells[i];
    // CPLog(@" tgt %@ tag %@", tgt, [tgt tag]);
    if ( [tgt tag] == theTag ) {
      var theSubviews = [tgt subviews];
      for (var j=0; j<[theSubviews count]; j++) {
	[theSubviews[j] setBackgroundColor:[CPColor colorWithHexString:@"EEEEEE"]];
      }
    }
  }
  return;


  var location = [self convertPoint:[anEvent locationInWindow] fromView:nil];
  var prop;
  var nSegs = [self segmentCount];
  for (var iSeg=0; iSeg<nSegs; iSeg++) {
    var segFrm = [self frameForSegment:iSeg];
    if ( CPRectContainsPoint(segFrm, location) ) {
      prop = [self tagForSegment:iSeg];
      if (prop) {
	CPLog(@"    entered seg %@, tag %@", iSeg, [prop objectForKey:@"iTermProp"]);
      }
    }
  }
  var theTag = [prop objectForKey:@"iTermProp"];
  // CPLog(@" iTermProp %@", theTag);
  var cell = [prop objectForKey:@"cell"];
  var tvs = [cell subviews];
  var sv = [cell superview];
  var tgts = [sv subviews];
  // CPLog(@" tgt subviews: %@", tgts);
  for (i=0; i<[tgts count]; i++) {
    var tgt = tgts[i];
    // CPLog(@" tgt %@ tag %@", tgt, [tgt tag]);
    if ( [tgt tag] == theTag ) {
      var subvs = [tgt subviews];
      for (iV=0; iV<[subvs count]; iV++) {
	[subvs[iV] setBackgroundColor:[CPColor colorWithHexString:@"EEEEEE"]]
      }
    }
  }
  [super mouseEntered:anEvent];
}

/*!
    Notifies the receiver that the user has clicked the mouse down in its area.
    @param anEvent contains information about the click
*/
// - (void)mouseDown:(CPEvent)anEvent
// {
//   CPLog(@"%@ mouseDown event %@", self, anEvent);
//   [super mouseDown:anEvent];
// }

/*!
    Notifies the receiver that the user has clicked the right mouse down in its area.
    @param anEvent contains information about the right click
*/
// - (void)rightMouseDown:(CPEvent)anEvent
// {
//     [_nextResponder performSelector:_cmd withObject:anEvent];
// }

// - (CPDragOperation)draggingEntered:(CPDraggingInfo>)sender
// {
//   CPLog(@"%@ draggingEntered event %@", self, anEvent);
// }

@end

@implementation PdgmGridViewController : CPViewController
{
  CPViewController docletViewController;

  PdgmDoclet _doclet  @accessors(property=doclet);
  // CPMutableArray __pdgmProps @accessors(property=pdgmProps);;
  // PdgmGridHeaders pdgmHdrs;

  //TODO:  move data to doclet
  CPMutableArray __pdgmTerms @accessors(property=pdgmTerms);;
  CPMutableArray __termsIndexSet;
  CPTableView __pdgmGridView;
  CPTabViewItem __tabViewItem;
  int topCount;
  int lftCount;
}

- (id)init
{
  CPLog(@"%@ init", self);
  [super init];
  return self;
}

- (id)initWithDoclet:(CPObject)theDoclet
{
  CPLog(@"\n\n\t\t%@ initWithDoclet %@\n", self, theDoclet);
  self = [super init];
  _doclet = theDoclet;
  nTopHdrs = [[CPNumber alloc] initWithInt:0];
  nBottomHdrs = [[CPNumber alloc] initWithInt:0];
  nLeftHdrs = [[CPNumber alloc] initWithInt:0];
  nRightHdrs = [[CPNumber alloc] initWithInt:0];
  hdrs = nil;
  // hdrs = [[CPMutableArray alloc] init];
  __pdgmTerms = [[theDoclet pdgmTerms] copy];
  // console.log(__pdgmTerms);
  // normalize the data
  CPLog(@"/%@ initWithDoclet %@\n\n", self);
  return self;
}

- (id)setDocletViewController:(CPViewController)theVC
{
  CPLog(@"%@ setDocletViewController", self);
  docletViewController = theVC;
}

- (void)buildPdgmHdrs:(CPArray)rawHdrs
{
  CPLog(@"%@ buildPdgmHdrs", self);
  if (hdrs) {
    CPLog(@"/%@    already built; re-memoizing", self);
    [self setSpansAndReps];
    [self memoizeProps];
    return;
  }
  var len = rawHdrs.length;
  var totalHdrs = 0,
    props = [];
  for (var i=0; i<len; i++) {
    if (rawHdrs[i][0] == "token") {
      // CPLog(@"    removing prop %@ : %@", rawHdrs[i][0], rawHdrs[i][1]);
      continue;
    }
    // if (rawHdrs[i][1].length <= 1) {
    //   // CPLog(@"    removing prop %@ : %@", rawHdrs[i][0], rawHdrs[i][1]);
    //   continue;
    // }
    totalHdrs = props.push(i);
  }
  // CPLog(@"    %@ headers: %@", totalHdrs, props);
  var lfthdrs = Math.ceil(totalHdrs / 2);
  var tophdrs = totalHdrs - lfthdrs;
  // CPLog(@"    total headers: %@; %@ top headers;  %@ left headers ", totalHdrs, tophdrs, lfthdrs);

  var Thdr = [[CPMutableArray alloc] init];
  var Bhdr = [[CPMutableArray alloc] init];
  var Lhdr = [[CPMutableArray alloc] init];
  var Rhdr = [[CPMutableArray alloc] init];

  // TOP headers

  // [self dumpHdrs];
  nPvals = 0;
  __nProps = 0;
  nTopPvals = 1;
  nTopProps = 0;
  nPrevProps = 0; // memoize for easiy retrieval
  var prop;
  // CPLog(@"    do top headers");
  for (var i=0; i<tophdrs; i++) {
    var j = props[i];
    var pn = rawHdrs[j][0];

    var pv = rawHdrs[j][1];
    var pvals = [[CPMutableArray alloc] init];
    // CPLog(@"    prop %@", pn);
    for (var iPval=0; iPval<pv.length; iPval++) {
      // CPLog(@"        pval: %@", pv[iPval]);
      var pval = [[CPMutableArray alloc] init];
      [pval addObject:YES]; // pvals[DISPLAY]
      [pval addObject:[pv[iPval] copy]]; // pvals[VALUE]
      [pvals addObject:pval];
    }

    // CPLog(@"    pvals: %@", pvals);

    var tidx = rawHdrs[j][2];
    nTopProps = nTopProps + 1;
    nTopPvals = nTopPvals * pv.length;

    var span = 1;
    for (var k=i+1; k < tophdrs; k++) {
      span = span * rawHdrs[props[k]][1].length;
    }

    prop = [[CPMutableDictionary alloc] initWithObjectsAndKeys:
					  pn, @"name",
					YES, @"display",
					[pvals count], @"nDisplayedPvals",
					1, @"reps",
					pvals, @"pvals",
					span, @"span",
					0, @"hdr",
					nPrevProps, @"nPrevProps",
					pn, @"keyTermProp",
					tidx, @"iTermProp",
					// tokFld, @"tokenFld",
					[[CPView alloc] init], @"cell"];
    // console.log(prop);
    [Thdr addObject:prop];
    nPrevProps +=1;
  }
  // if (nTopPvals == 1) nTopPvals = 0;
  nPvals += nTopPvals;
  __nProps += nTopProps;

  nBottomProps = 0;
  nBottomPvals = 0;

  // CPLog(@"    do left headers");
  // LEFT headers
  nLeftPvals = 1;
  nLeftProps = 0;
  for (var i=tophdrs; i<totalHdrs; i++) {
    var j = props[i];
    var pn = rawHdrs[j][0];

    var pv = rawHdrs[j][1];
    var pvals = [[CPMutableArray alloc] init];
    // CPLog(@"    prop %@", pn);
    for (var iPval=0; iPval<pv.length; iPval++) {
      // CPLog(@"        pval: %@", pv[iPval]);
      var pval = [[CPMutableArray alloc] init];
      [pval addObject:YES]; // pvals[DISPLAY]
      [pval addObject:[pv[iPval] copy]]; // pvals[VALUE]
      [pvals addObject:pval];
    }
    // CPLog(@"        pvals: %@", pvals);

    var tidx = rawHdrs[j][2];
    nLeftProps = nLeftProps + 1;
    nLeftPvals = nLeftPvals * pv.length;
    var span = 1;
    for (var k=i+1; k < totalHdrs; k++) {
      span = span * rawHdrs[props[k]][1].length;
    }
    prop = [[CPMutableDictionary alloc] initWithObjectsAndKeys:
					  pn, @"name",
					YES, @"display",
					[pvals count], @"nDisplayedPvals",
					1, @"reps",
					pvals, @"pvals",
					span, @"span",
					2, @"hdr",
					nPrevProps, @"nPrevProps",
					pn, @"keyTermProp",
					tidx, @"iTermProp",
					[[CPView alloc] init], @"cell"];
					// CGSizeMake(0,0), @"frame"];
    [Lhdr addObject:prop];
    nPrevProps +=1;
  }
  if (nLeftPvals == 1) nLeftPvals = 0;
  nPvals += nLeftPvals;
  __nProps += nLeftProps;

  nRightProps = 0;
  nRightPvals = 0;

  hdrs = [[CPMutableArray alloc] init];
  [hdrs addObject:Thdr];
  [hdrs addObject:Bhdr]; // initally empty
  [hdrs addObject:Lhdr];
  [hdrs addObject:Rhdr]; // initially empty

  // CPLog(@"    now adjust headers");
  // [self dumpHdrs];
  CPLog(@"/%@ /buildPdgmHdrs \n\n", self);
}

- (void)makeSubviewForTabViewItem:(TabViewItem)theViewItem
{
  CPLog(@"%@ makeSubviewForTabViewItem %@", self, theViewItem);
  // [self dumpHdrs];
  __tabViewItem = theViewItem;

  [self setSpansAndReps];
  [self memoizeProps];

  [self refreshPdgmGridView];

}

////////////////////////////////////////////////////////////////
 - (void)refreshPdgmGridView
 {
   CPLog(@"%@ refreshPdgmGridView", self);
   theViewItem = __tabViewItem;
   var sw = [CPScroller scrollerWidth];

   __pdgmGridView = [[CPTableView alloc] initWithFrame:CGRectMakeZero()];
   [__pdgmGridView setGridColor:[CPColor blackColor]];
   [__pdgmGridView setGridStyleMask: CPTableViewSolidVerticalGridLineMask 
	      | CPTableViewSolidHorizontalGridLineMask ];
   // [__pdgmGridView setBackgroundColor:[CPColor redColor]];
   // var nCols = [pdgmHdrs nbrCols];
   var cellW = 75;
   var tally = 0;
   // for (var i=0; i<nCols; i++) {
   // [self dumpHdrs];
   var colct = 1;
   // CPLog(@"    setting %@ top hdrs", hdrs[TOP].length);
   for (var i=0; i<hdrs[TOP].length; i++) {
     if ( ! [hdrs[TOP][i] objectForKey:@"display"] ) {
       // CPLog(@"    skipping hdr %@", i);
       continue;
     }
     var thisProp = hdrs[TOP][i];
     var thisPvals = [thisProp objectForKey:@"pvals"];
     var nDispPvals = 0;
     for (var iPval=0; iPval<[thisPvals count]; iPval++) {
       var thisPval = [thisPvals objectAtIndex:iPval];
       if ( [thisPval objectAtIndex:DISPLAY] )
	 nDispPvals += 1;
     }
     colct = colct * nDispPvals;
   }

   for (var i=0; i<colct; i++) {
     // CPLog(@"    setting hdr col %@", i);
     column = [[CPTableColumn alloc] initWithIdentifier:i];
     [column setWidth:cellW];
     [__pdgmGridView addTableColumn:column];
   }

   [__pdgmGridView setHeaderView:nil];
   [__pdgmGridView setDataSource:self];

   // CPLog(@"    gridView stuff");
   var gridView = [self makeHdrViews];
   // console.log(gridView);
   var gridViewFrame = [gridView frame];
   // console.log(gridViewFrame);

   var cellH = [__pdgmGridView rowHeight];
   // CPLog(@"    finished table view ");
   // [self dumpTableView:tableView];
   //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   // SCROLL VIEW
   var deltaW = sw/2; // nTopPvals;
   var deltaH = sw/2; //nLeftPvals; // [pdgmHdrs nbrRows];

   // var scrollframe = CGRectOffset(CGRectInset([__pdgmGridView frame], -deltaW, -deltaH), 0,0); // deltaW,deltaH);
   var scrollframe = CGRectOffset(CGRectInset(gridViewFrame, -deltaW, -deltaH), deltaW, deltaH); // deltaW,deltaH);
   var scrollView = [[CPScrollView alloc] initWithFrame:scrollframe];
   [scrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
   [scrollView setBorderType:CPNoBorder];
   // [scrollView setBorderType:CPLineBorder];
   // [scrollView setBackgroundColor:[CPColor colorWithHexString:@"88000"]];
   [scrollView setDocumentView:gridView];

   // CPLog(@"    finished scroll view ");

   //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   // BOX VIEW
   var boxframe = CGRectOffset(CGRectInset([scrollView frame], -1, 0), 1, 0);
   var boxGrid = [[CPBox alloc] initWithFrame:boxframe];
   // [boxGrid setAutoresizingMask:CPViewMaxXMargin | CPViewMinXMargin | CPViewHeightSizable | CPViewMaxYMargin];
   // [boxGrid setBorderType:CPLineBorder];
   [boxGrid setBorderType:CPNoBorder];
   // [boxGrid setBorderWidth:1];
   // [boxGrid setBorderColor:[CPColor redColor]]; // colorWithHexString:@"000000"]];
   // CPLog(@"    making box view C");

   [boxGrid setTag:@"databox"];
   // now position box within content view
   [boxGrid setFrameOrigin:CGPointMake( 0,20 )];
   // CPLog(@"    finished boxView");
   [boxGrid addSubview:scrollView];

   var segsW = boxframe.size.width-20;
   var schemaBar = [[PdgmSchemaBar alloc] initWithFrame:CGRectMake(0,boxframe.size.height + 24,
									segsW, 20)];
   [schemaBar setTrackingMode:CPSegmentSwitchTrackingSelectAny];
   // [schemaBar setTrackingMode:CPSegmentSwitchTrackingMomentary];
   // CPLog(@"    nbr props: %@", __nProps);
   [schemaBar setSegmentCount:__nProps+1];
   [schemaBar setTarget:self];
   [schemaBar setAction:@selector(schemaBarClicked:)];

   // sort hdrs for populating schema bar
   var tmpHdrs = [[CPMutableArray alloc] init];
   for (var iHdr=0; iHdr<RIGHT; iHdr++) {
     thisHdr = [hdrs objectAtIndex:iHdr];
     for (var iProp=0; iProp<[thisHdr count]; iProp++) {
       var thisProp = [thisHdr objectAtIndex:iProp];
       [tmpHdrs addObject:thisProp];
     }
   }
   var hdrSortDescriptor = [[[CPSortDescriptor alloc] initWithKey:@"name"
							ascending:YES
							 selector:@selector(caseInsensitiveCompare:)] autorelease];
   var descriptors = [CPArray arrayWithObject:hdrSortDescriptor];
   sortedHdrs = [tmpHdrs sortedArrayUsingDescriptors:descriptors];
   for (var iProp=0; iProp<[sortedHdrs count]; iProp++) {
     var thisProp = [sortedHdrs objectAtIndex:iProp];
     var thisLabel = [thisProp objectForKey:@"name"];
     var nSeg = [thisProp objectForKey:@"nPrevProps"];
     var bDispl = [thisProp objectForKey:@"display"];
     var tag = [thisProp objectForKey:@"iTermProp"];
     [schemaBar setLabel:thisLabel forSegment:iProp];
     [schemaBar setTag:thisProp forSegment:iProp]; // ptr to prop header
     [schemaBar setSelected:bDispl forSegment:iProp];
     [schemaBar setHdrCell:boxGrid];
   }

   var oldSubviews = [[theViewItem view] subviews];  // CPArray
   for (var i=0; i<[oldSubviews count]; i++) {
     v = [oldSubviews objectAtIndex:i];
     [v removeFromSuperview];
   }

   [[theViewItem view] addSubview:boxGrid];
   [[theViewItem view] addSubview:schemaBar]; //schemaBar];

   var owningWin = [[theViewItem tabView] window];
   var winfr = [owningWin frame];
   var o = winfr.origin;
   var offset = sw;
   var winframe = CGRectOffset(CGRectInset([boxGrid frame], -offset+4, -offset-28-10), 0, offset-14);
   [owningWin setFrame:winframe];
   [owningWin setFrameOrigin:o];

   [boxGrid setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable ];

   [[docletViewController _docletWindow] setSavedPdgmGridFrame:winframe];
   // [statusBox setAutoresizingMask: CPViewWidthSizable];
   [schemaBar setAutoresizingMask:CPViewWidthSizable | CPViewMinYMargin];

   [__pdgmGridView setNeedsDisplay:YES];
   // var CtxMenu = [[CPMenu alloc] initWithTitle:@"Tabs"];
   // [CtxMenu setAutoenablesItems:NO];
   // var mi = [[CPMenuItem alloc] initWithTitle:@"Test Sort" action:@selector(sortPdgm:) keyEquivalent:nil];
   // [mi setEnabled:YES];
   // [CtxMenu addItem:mi];
   // [boxGrid setMenu:CtxMenu];

   // [__pdgmGridView sizeLastColumnToFit];
   // [__pdgmGridView setDelegate:self];

   // [__pdgmGridView reloadData];

   // [self dumpdHrs];
   // [self dumpTableView:__pdgmGridView];

   // CPLog(@"/%@ refreshPdgmGridView", self);
 }

 - (void)makeHdrViews
 {
   CPLog(@"%@ makeHdrViews", self);
   //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   //  HEADER CELLS
   //TODO:  size and position header cells
   //  At this point we have the table origin and the header cell spans.
   //  Algorithm:
   //    TOP/BOTTOM:  for header cell, fetch col width, set cell size, set cell origin relative to scrollView origin
   //    LEFT/RIGHT: ditto

   // REMINDER:  hdrs is an array of header objects
   //		a header object is an array of "property" objects of type dictionary

   // prep:
   // [self dumpHdrs];
   // CPLog(@"    table view: %@", __pdgmGridView);

   var gridBounds = CGRectMakeZero(); // will be used below
   // [gridView setBorderType:CPNoBorder];
   // [gridView setBorderWidth:1];
   // [gridView setBorderColor:[CPColor blackColor]]; // colorWithHexString:@"000000"]];

   // use to aggregate header cells for easy positioning en masse
   var topHeaders = [[CPView alloc] initWithFrame:CGRectMakeZero()];
   [topHeaders setTag:TOPBOX];
   var lftHeaders = [[CPView alloc] initWithFrame:CGRectMakeZero()];
   [lftHeaders setTag:LEFTBOX];

   var tblCols = [__pdgmGridView tableColumns]; // CPArray
   // console.log("tblcols: ", tblCols);
   var cellW = 75;
   var cellH = [__pdgmGridView rowHeight];
   
   // [self dumpHdrs];
   // CPLog(@"    making table hdrs A");
   // FIRST do top and bottom
   var scrollView = [__pdgmGridView superview];
   // CPLog(@"    scroll view: %@", scrollView);

   var Origin = [__pdgmGridView frame].origin; // used in view geometry calcs below
   
   var fnszLabel = 12;
   var propCount= 0;
   for (var iHdr=0; iHdr<RIGHT; iHdr++) {
     // CPLog(@"entering header loop %@", iHdr);
     if ( (iHdr % 2) != 0 ) continue;  // only do TOP and LEFT
     // CPLog(@"INITIATING HDR iteration %@", i);
     var thisHdr = [hdrs objectAtIndex:iHdr];
     if (thisHdr == 0) continue;
     nPropsThisHdr = [thisHdr count];

     // var nDisplayedProps = 0;
     // for (var iProp=0; iProp<nPropsThisHdr; iProp++) {
     //   if ( [[thisHdr objectAtIndex:iProp] objectForKey:@"display"] ) {
     // 	 // CPLog(@"    thisHdr display? %@", [[thisHdr objectAtIndex:iProp] objectForKey:@"display"]);
     // 	 nDisplayedProps += 1;
     //   }
     // }
     // CPLog(@"    scrollView origin: %@, %@", Origin.x, Origin.y);
     // CPLog("header %@; nbr props: %@, displayed %@", i, nPropsThisHdr, nDisplayedProps);
     // CPLog("iterating j over %@ props", nPropsThisHdr);
     
     var displayedProps = 0;
     var skippedProps = 0;
     // CPLog(@"entering property loop for header %@", iHdr);
     for (var iProp=0; iProp<nPropsThisHdr; iProp++) {

       var thisProp = [thisHdr objectAtIndex:iProp];

       if ( [thisProp objectForKey:@"display"] )
	 displayedProps += 1;
       else {
	 skippedProps += 1;
	 continue;
       }

       // var prop = thisProp;
       var pname = [thisProp objectForKey:@"name"];
       var pvals = [thisProp objectForKey:@"pvals"]; // CPMutableArray
       var nbrPvals = [pvals count];
       var nDisplayedPvals = [thisProp objectForKey:@"nDisplayedPvals"];

       // NOW set header cell origin and add to boxGrid view

       //Task: discovery how many times to repeat pval cells for this property
       // e.g. if we have person (p1,p2,p3) then gender (m,f) then tense (past, present, future)
       // then tense will have 6 reps (= 3*2*1), gender 3 reps (3*1), and person 1 rep (1*1) 
       var reps = 1;
       for (var iPrevProp=0; iPrevProp<iProp; iPrevProp++) {
	 var prevProp = [thisHdr objectAtIndex:iPrevProp];
	 // var prevPvals = [prevProp objectForKey:@"pvals"];
	 // for (var iPval=0; iPval<[prevPvals count]; iPval++) {
	 //   var prevPval = [prevPvals objectAtIndex:iPval];
	 //   if ( [prevPval objectAtIndex:DISPLAY] )
	 // }
	 // CPLog(@"    prevProp display? %@", [prevProp valueForKey:@"nDisplayedPvals"]);
	 reps = reps * [prevProp valueForKey:@"nDisplayedPvals"];
	 // }
       }
       
       // CPLog("    pname: %@; nbrPvals %@ nDisplayedPvals: %@ (%@ reps)", pname, nbrPvals, nDisplayedPvals, reps);

       // i = index of this header (TOP, BOTTOM, LEFT, or RIGHT)
       // iProp = index this property within this header
       // nbrPvals = nbr of pvals in this property
       // nDisplayedPvals = nbr displayable pvals in this property
       // reps = nbr times to repeat the set of pvals
       var reps = [thisProp objectForKey:@"reps"];
       for (var thisRep=0; thisRep<reps; thisRep++) {
	 // CPLog(@"      entering rep loop %@ for pvals %@", thisRep, pvals);

	 // we need to interate over all pvals, in order to get all the displayed ones
	 var nSkippedPvals = 0;
	 for (iPval=0; iPval<nbrPvals; iPval++) {
	   var thisPval = [pvals objectAtIndex:iPval];
	   if ( ! [thisPval objectAtIndex:DISPLAY] ) {
	     nSkippedPvals += 1;
	     continue;
	   }

	   // CPLog(@"        entering pvals loop %@; thisPval: %@", iPval, thisPval);

	   var w = 0,
	     h = 0,
	     o = 0;

	   var thisRect = 0;

	   var nDisplayedPvals = [thisProp objectForKey:@"nDisplayedPvals"];
	   switch (iHdr) {
	   case TOP:
	     spanW = [thisProp objectForKey:@"span"] * (cellW+3);
	     h = cellH;
	     o = CGPointMake( thisRep * (nDisplayedPvals*spanW) + (iPval-nSkippedPvals) * spanW,
			      (iProp - skippedProps) * cellH);

	     thisRect = CGRectMake(o.x, o.y, spanW, cellH);
	     // CPLog(@" thisRect: %@", thisRect);
	     // console.log(thisRect);

	     if (gridBounds.origin.y == 0) {
	       // gridBounds.origin.x = Origin.x;
	       gridBounds.origin.y = -o.y;
	       var pt = CGPointMake([__pdgmGridView frame].origin.x, gridBounds.origin.y);
	       [__pdgmGridView setFrameOrigin:pt];
	     }
	     break;

	   case LEFT:
	     spanH = [thisProp objectForKey:@"span"] * (cellH + 2);
	     // o = CGPointMake(Origin.x - ( (displayedProps - iProp + skippedProps) * w ),
	     // CPLog(@" iProp %@, skippedProps: %@, thisPval: %@, thisRep: %@, spanH %@, cellH %@",
	     // 	   iProp, skippedProps, iPval, thisRep, spanH, cellH);
	     o = CGPointMake( (iProp - skippedProps) * cellW,
			      thisRep * (nDisplayedPvals*spanH) + (iPval-nSkippedPvals) * spanH);

	     thisRect = CGRectMake(o.x, o.y, cellW, spanH);

	     // CPLog(@" thisRect: %@", thisRect);
	     // o = CGPointMake(Origin.x - ( (nPropsThisHdr - iProp + skippedProps) * w ),
	     // 			      Origin.y + (thisRep * nDisplayedPvals * h) + iPval * h);
	     if (gridBounds.origin.x == 0) {
	       gridBounds.origin.x = -o.x;
	       var pt = CGPointMake(gridBounds.origin.x ,[__pdgmGridView frame].origin.y);
	       [__pdgmGridView setFrameOrigin:pt];
	     }
	     break;
	   default: CPLog(@"%@    HOW DID I GET HERE???", self);
	   }

	   var thisFrame = CGRectMake(gridBounds.origin.x + o.x,
				      gridBounds.origin.y + o.y,
				      w, h); // thisFrame.size.width, thisFrame.size.height);

	   // CPLog(@"    finished geometry; creating widgets");
	   var pvalname = [thisPval objectAtIndex:VALUE]; // pvals[VALUE] = pval string

	   // CPLog(@"  pname: %@; pval: %@", pname, pvalname);
	   // console.log("        this object at index: ", thisProp, iPval);

	   // NOW create the view object
	   // var cellText = [[CPTextField alloc] initWithFrame:thisFrame];

	   var cellText = [[CPTextField alloc] initWithFrame:thisRect];

	   // [cellText setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
	   [cellText setStringValue:pvalname];
	   [cellText setFont:[CPFont boldSystemFontOfSize:fnszLabel]];
	   [cellText setAlignment:CPCenterTextAlignment];
	   [cellText setSelectable:NO];
	   // [cellText setTag:[thisProp objectForKey:@"keyTermProp"]];
	   // [cellText setTag:3];
	   // CPLog(@"    cellText: %@", cellText);
	   // var theColor;
	   // switch (iThisProp) {
	   // case 0: theColor = @"888888"; break;
	   // case 1: theColor = @"DDDDDD"; break;
	   // case 2: theColor = @"000088"; break;
	   // }
	   [cellText setBackgroundColor:[CPColor colorWithHexString:@"EEEEEE"]];

	   var cellView = [[PdgmHdrCell alloc] initWithFrame:thisRect];

	   // var cellView = [[PdgmHdrCell alloc] initWithFrame:thisFrame];
	   // [cellView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
	   [cellView setBorderType:CPBezelBorder];
	   [cellView setBorderWidth:1];
	   [cellView setBorderColor:[CPColor blackColor]]; // colorWithHexString:@"000000"]];
	   [cellView setValue:self forKey:@"pdgmGridVC"];
	   [cellView setValue:pname forKey:@"pname"];
	   [cellView setPname:pname];
	   [cellView setProp:thisProp];
	   [cellView setValue:pvalname forKey:@"pval"];
	   [cellView setValue:iHdr forKey:@"hdr"];
	   [cellView setValue:pvals forKey:@"pvals"];
	   [cellView setContentView:cellText];
	   // CPLog(@" iTermProp %@", [thisProp objectForKey:@"iTermProp"]);
	   [cellView setTag:[thisProp objectForKey:@"iTermProp"]];
	   // CPLog(@" HEADER CELL: %@ for pn %@ pv %@", cellView, pname, pvalname);
	   [thisProp setObject:cellView forKey:@"cell"];


	   switch (iHdr) {
	   case TOP:
	     // CPLog(@" TOP");
	     // [cellView setFrameOrigin:CGPointMake(0,CGRectGetHeight([topHeaders frame]))];
	     [topHeaders addSubview:cellView]; // positioned:CPWindowAbove relativeTo:nil];
	     var f = CGRectUnion([topHeaders frame], [cellView frame]);
	     [topHeaders setFrame:f];
	     break;
	   case LEFT:
	     // CPLog(@" LEFT %@, %@, %@, %@ : %@ : %@", o.x, o.y, w, h, pname, pvalname);
	     var y = [cellView frame].origin.y;
	     [lftHeaders addSubview:cellView]; // positioned:CPWindowAbove relativeTo:nil];
	     var f = CGRectUnion([lftHeaders frame], [cellView frame]);
	     [lftHeaders setFrame:f];
	     break
	   default: CPLog(@"####  WHAT AM I DOING HERE????");
	   }
	   // var boxGrid = [[scrollView superview] superview];
	   // console.log([cellView frame]);
	   // [[[[__pdgmGridView superview] superview] superview] addSubview:cellView];  // boxGrid
	   // CPLog(@"  ..../iteration %@  of %@ propvals (of total %@)", k+1, nbrPvals, propCount);
	   propCount +=1;
	 }
	 // CPLog(@"..../iteration %@  of %@ reps\n\n", thisRep+1, reps );
       }
       // CPLog("..../iteration %@ of %@ props", iProp, nPropsThisHdr);
     }
     // CPLog("..../iteration %@ of %@ headers", iHdr, RIGHT);
   }
   // [self dumpHdrs];
   // CPLog(@"    assembling");
   gridBounds.size.width = gridBounds.origin.x + [__pdgmGridView frame].size.width;
   gridBounds.size.height = gridBounds.origin.y + [__pdgmGridView frame].size.height;

   [topHeaders setFrameOrigin:CGPointMake(CGRectGetWidth([lftHeaders frame]), 0)]; 
   [lftHeaders setFrameOrigin:CGPointMake(0, CGRectGetHeight([topHeaders frame]))];
   [__pdgmGridView setFrameOrigin:CGPointMake(CGRectGetWidth([lftHeaders frame]), CGRectGetHeight([topHeaders frame]))];

   var w = CGRectGetWidth([lftHeaders frame]) + CGRectGetWidth([__pdgmGridView frame]);
   var h = CGRectGetHeight([topHeaders frame]) + CGRectGetHeight([__pdgmGridView frame]);
   // CPLog(@" w,h: %@,%@", w, h);
   
   var gridView = [[CPView alloc] initWithFrame:CGRectMake(0,0, w, h)];
   [gridView addSubview:topHeaders];
   [gridView addSubview:lftHeaders];
   [gridView addSubview:__pdgmGridView];

   var gridTblFrame = [__pdgmGridView frame];

   var gvFrame = [gridView frame];
   // CPLog(@"   gridView frame %@, %@, %@, %@",
   // 	 gvFrame.origin.x, gvFrame.origin.y,
   // 	 gvFrame.size.width, gvFrame.size.height);

   var thFrame = [topHeaders frame];
   var lhFrame = [lftHeaders frame];
   // CPLog(@"   top headers frame %@, %@, %@, %@",
   // 	 thFrame.origin.x, thFrame.origin.y,
   // 	 thFrame.size.width, thFrame.size.height);
   // CPLog(@"   left headers frame %@, %@, %@, %@",
   // 	 lhFrame.origin.x, lhFrame.origin.y,
   // 	 lhFrame.size.width, lhFrame.size.height);
   // CPLog(@"   grid table frame %@, %@, %@, %@",
   // 	 gridTblFrame.origin.x, gridTblFrame.origin.y,
   // 	 gridTblFrame.size.width, gridTblFrame.size.height);
   // CPLog(@"   gridBounds %@, %@, %@, %@",
   // 	 gridBounds.origin.x, gridBounds.origin.y,
   // 	 gridBounds.size.width, gridBounds.size.height);
   // [gridView setFrame:gridBounds];
   // [gridView setFrameOrigin:CGPointMake(0,0)];
   // CPLog(@"/%@ makeHdrViews", self);

   CPLog(@"%@ /makeHdrViews", self);
   return gridView;
 }

 // @override
 - (void)setView:(CPDocletView)theView
 {
   CPLog(@"%@ setView %@", self, theView);
   [super setView:theView];
 }

 - (void)setViewForDoclet:(CPDoclet)doclet
 {
   CPLog(@"%@ setViewForDoclet", self);
 }

 - (CFAction)closeDoclet  //:(id)aSender
 {
   CPLog(@"%@: closeDoclet", self);
   [super closeDoclet:aSender];
 }

 /*!
     The method notifies the controller that it's window is about to load.
 */
 - (void)windowWillLoad
 {
   CPLog(@"%@: windowWillLoad", self);
 }

 - (void)loadView
 {
   // DO NOT call [super loadView]; it tries to load window from CIB, which fails
   CPLog(@"%@ loadView", self);
   if (!_window) {
     var theView = [[[_view class] alloc] initWithDoclet:[super doclet]];
     CPLog(@"theView: %@", self, theView);
     _view = theView;
     [theView orderFront:self];
   }
 }

 ////////////////////////////////////////////////////////////////
- (CFAction)setSpansAndReps
 {
   CPLog(@"%@: setSpansAndReps", self);
   for (var iHdr=0; iHdr<RIGHT; iHdr++) {
     // CPLog(@"iHdr %@", iHdr);
     var props = [hdrs objectAtIndex:iHdr];
     var nProps = [props count];
     var thisReps = 1;
     for (var iThisProp=0; iThisProp<nProps; iThisProp++) {
       // CPLog(@" iThisProp %@", iThisProp);
       var thisProp = [props objectAtIndex:iThisProp];
       [thisProp setValue:thisReps forKey:@"reps"];
       // CPLog(@"    thisProp %@", thisProp);
       var thisPvals = [thisProp objectForKey:@"pvals"];
       var nDisplayedPvals = 0;
       for (var iPval=0; iPval<[thisPvals count]; iPval++) {
	 var thisPval = [thisPvals objectAtIndex:iPval];
	     if ( [thisPval objectAtIndex:DISPLAY] )
	       nDisplayedPvals += 1;
       }
       [thisProp setValue:nDisplayedPvals forKey:@"nDisplayedPvals"];
       thisReps = thisReps * nDisplayedPvals;

       var span = 1;
       for (var iNextProp=iThisProp+1; iNextProp < nProps; iNextProp++) {
	 if ( [props[iNextProp] objectForKey:@"display"] ) {
	   var nextProp = [props objectAtIndex:iNextProp];
	   //FIXME:  skip if (! pval[DISPLAY])
	   // CPLog(@" iNextProp %@", iNextProp);
	   // CPLog(@" NextProp %@", nextProp);
	   var nextPvals = [nextProp objectForKey:@"pvals"];
	   var iPvals;
	   var nDisplayedPvals = 0;
	   //TODO:  we can use [nextProp valueForKey:@:nDisplayedPvals"]
	   // CPLog(@"    nDisplayedPvals: ", [nextProp valueForKey:@"nDisplayedPvals"]);
	   for (var iPval=0; iPval<[nextPvals count]; iPval++) {
	     // CPLog(@"iPval %@", iPval);
	     var nextPval = [nextPvals objectAtIndex:iPval];
	     // CPLog(@" nextPval %@", nextPval);
	     if ( [nextPval objectAtIndex:DISPLAY] )
	       nDisplayedPvals += 1;
	   }
	   span = span * nDisplayedPvals;
	 }
       }
       [thisProp setValue:span forKey:@"span"];
     }
   }
   // [[[self doclet] theDocument] updateChangeCount:CPChangeDone];
   CPLog(@"/%@: /setSpansAndReps", self);
 }
 ////////////////////////////////////////////////////////////////
- (CFAction)moveProp:(CPString)fromProp fromHdr:(int)fromHdr toProp:(CPString)toProp toHdr:(int)toHdr
 {
   CPLog(@"%@: moveProp %@:%@ to %@:%@", self, fromProp, fromHdr, toProp, toHdr);

   // var temp = hdrs;
   // hdrs = nil;
   // [self dumpHdrs];
   var fromHdrObj = hdrs[fromHdr];
   var i, j;
   var fromPropObj;
   // if (fromHdr == toHdr) {
     for (i=0; i<fromHdrObj.length; i++) {
       if ([hdrs[fromHdr][i] objectForKey:@"name"] == fromProp) {
	 fromIdx = i;
       }
     }
     for (i=0; i<hdrs[toHdr].length; i++) {
       if ([hdrs[toHdr][i] objectForKey:@"name"] == toProp) {
	 toIdx = i;
       }
     }
   // }

   for (i=0; i<fromHdrObj.length; i++) {
     if ([fromHdrObj[i] objectForKey:@"name"] == fromProp) {
       fromPropObj = [fromHdrObj[i] copy];
       // CPLog(@"    removing prop %@ from header %@ at index %@", fromPropObj, hdrs[fromHdr], i);
       [hdrs[fromHdr] removeObjectAtIndex:i];
       // CPLog(@"    removed prop %@ from header %@ at index %@", fromPropObj, hdrs[fromHdr], i);
       break;
     }
   }
   // CPLog(@"    finished removal");

   var toHdrObj = hdrs[toHdr];
   var toPropObj;
   for (j=0; j<toHdrObj.length; j++) {
     if ([toHdrObj[j] objectForKey:@"name"] == toProp) {
       var k = fromIdx < toIdx ? j + 1 : j;
       // CPLog(@"    moving prop from %@ to %@", fromIdx, toIdx);
       [fromPropObj setValue:toHdr forKey:@"hdr"];
       [toHdrObj insertObject:fromPropObj atIndex:k];
       break;
     }
   }
   // CPLog(@"    finished insertion");
   [self setSpansAndReps];
   [self memoizeProps];

   CPLog(@"/%@: moveProp", self);
 }

- (CFAction)movePval:(CPString)fromPval toPval:(CPString)toPval inProp:(CPString)theProp inHdr:(int)theHdr
{
  CPLog(@"%@: movePval %@ toPval %@ inProp %@ inHdr %@", self, fromPval, toPval, theProp, theHdr);

  var iProp;
  for (iProp=0; iProp<hdrs[theHdr].length; iProp++) {
    if ([hdrs[theHdr][iProp] objectForKey:@"name"] == theProp)
      break;
  }
  var pvals = [hdrs[theHdr][iProp] objectForKey:@"pvals"];
  var fromIdx;
  for (fromIdx=0; fromIdx<[pvals count]; fromIdx++) {
    var pval = [pvals objectAtIndex:fromIdx];
    if ( [pval objectAtIndex:VALUE] == fromPval ) {
      fromPval = pval;
      break;
    }
  }
  var toIdx; // = [[hdrs[theHdr][iProp] objectForKey:@"pvals"] indexOfObject:toPval];
  for (toIdx=0; toIdx<[pvals count]; toIdx++) {
    var pval = [pvals objectAtIndex:toIdx];
    if ( [pval objectAtIndex:VALUE] == toPval )
      break;
  }
  
  var fromPvalObj = [hdrs[theHdr][iProp] copy];
  [[hdrs[theHdr][iProp] objectForKey:@"pvals"] removeObjectAtIndex:fromIdx];
  [[hdrs[theHdr][iProp] objectForKey:@"pvals"] insertObject:fromPval atIndex:toIdx];
  [self setSpansAndReps];
  [self memoizeProps];
  CPLog(@"%@: /movePval %@ toPval %@ inProp %@ inHdr %@", self, fromPval, toPval, theProp, theHdr);
}

////////////////////////////////////////////////////////////////
- (void)memoizeProps
{
   CPLog(@"/%@: memoizeProps", self);

   // nTopPvals: number of cols in datagrid = product of pval counts of properties
   nTopPvals = 1;
   var hdr = [hdrs objectAtIndex:TOP];
   for (i=0; i<[hdr count]; i++) {
     nTopPvals = nTopPvals * [[hdr objectAtIndex:i] objectForKey:@"nDisplayedPvals"];
   }
   nPvals = nTopPvals;

   // nBottomPvals == nTopPvals
   // nBottomPvals = 1;
   // for (i=0; i<nBottomProps; i++) {
   //   nBottomPvals = nBottomPvals * [[[[hdrs objectAtIndex:BOTTOM] objectAtIndex:i] objectForKey:@"pvals"] count];
   // }
   // nPvals = nPvals + nBottomPvals;

   // nLeftPvals: number of cols in datagrid = product of pval counts of properties
   nLeftPvals = 1;
   var hdr = [hdrs objectAtIndex:LEFT];
   for (i=0; i<[hdr count]; i++) {
     nLeftPvals = nLeftPvals * [[hdr objectAtIndex:i] objectForKey:@"nDisplayedPvals"];
   }
   nPvals = nPvals + nLeftPvals;
   // nRightPvals == nLeftPvals

   [self makeIndexSet];
   CPLog(@"/%@: /memoizeProps", self);
 }

////////////////////////////////////////////////////////////////
 - (void)makeIndexSet
{
  CPLog(@"%@ makeIndexSet", self);
  // NB: the result is an ordered index set that will be used to
  // control the grid populate logic in the browser delegate methods
  
  // Logic: iterate over the terms.  For each term, iterate over the
  // pvals.  For each, look it up in the header descriptors.  If its
  // display property is YES, add its index to the index set;
  // otherwise skip it.  If the whole property is set to no display,
  // include it anyway.

  // [self dumpHdrs];

  __termsIndexSet = [[CPMutableArray alloc] init];
  var skip = NO;
  
  for (var iTerm=0; iTerm<[__pdgmTerms count]; iTerm++) {
    // CPLog(@"token %@: %@", iTerm, __pdgmTerms[iTerm]["token"]["value"]);
    // console.log(__pdgmTerms[iTerm]);

    skip = NO;
    match = NO;
    for (var iHdr=0; iHdr<[hdrs count]; iHdr++) {
      var thisHdr = [hdrs objectAtIndex:iHdr];
      // CPLog(@"  thisHdr %@", iHdr);
      match = NO;
      skip  = NO;

      for (var iProp=0; iProp<[thisHdr count]; iProp++) {
	var thisProp = [thisHdr objectAtIndex:iProp];
	var pname= [thisProp objectForKey:@"name"];
	if ( pname == "token" ) continue;
	
	var keyTermProp = [thisProp objectForKey:@"keyTermProp"]; // index into term for thisProp
	// CPLog(@"    thisProp %@; keyTermProp %@: %@", pname, keyTermProp, __pdgmTerms[iTerm][keyTermProp]["value"]);
	// CPLog(@"   pname %@ at keyTermProp %@ = %@", pname, keyTermProp, __pdgmTerms[iTerm][keyTermProp]["value"]);	
	for (var iPvals=0; iPvals<[thisProp count]; iPvals++) {
	  var thisPvals = [thisProp objectForKey:@"pvals"];
	  // CPLog(@"      thisPvals %@: %@", iPvals, thisPvals);

	  match = NO;
	  for (var iPval=0; iPval<[thisPvals count]; iPval++) {
	    var thisPval = [thisPvals objectAtIndex:iPval];
	    var thisPvalVal = [thisPval objectAtIndex:VALUE];
	    // CPLog(@"    __pdgmTerms[%@][%@]: %@", iTerm, keyTermProp);
	    // CPLog(@"        thisPval %@;  term prop %@", thisPval, __pdgmTerms[iTerm][keyTermProp]["value"]);
	    if ( thisPvalVal == __pdgmTerms[iTerm][keyTermProp]["value"] ) {
	      // CPLog(@"    MATCH");
	      match = YES;
	      if ( ! [thisPval objectAtIndex:DISPLAY] ) {
		// 	CPLog(@"    DISPLAY YES for %@", thisPvalVal);
		// } else {
		skip = YES;
		// CPLog(@"    DISPLAY NO for %@", thisPvalVal);
	      }
	      break;
	    }
	    if (match) break;
	  }
	  if (match) break;
	} // finished pvals
      } // finished prop
      if (skip) { // found a NO DISPLAY, so skip remaining props in header
	// CPLog(@"    skipping %@", iTerm);
	break;
      }
    } // finished header
    if ( ! skip) {
      // CPLog(@"    adding %@ to index set", iTerm);
      [__termsIndexSet addObject:iTerm];
    }
  }
  CPLog(@"    terms index set: %@", __termsIndexSet);
  CPLog(@"%@ /makeIndexSet", self);
}

////////////////////////////////////////////////////////////////
 - (CFAction)filterPval:(id)theSender
{
  CPLog(@"%@ filterPval sender %@, title %@", self, theSender, [theSender title]);
  var prop = [[theSender representedObject] prop];
  CPLog(@" prop: %@", prop);
  var pvals = [prop objectForKey:@"pvals"];
  for (iPval=0; iPval<[pvals count]; iPval++) {
    var pval = [pvals objectAtIndex:iPval];
    if ( [pval objectAtIndex:VALUE] == [theSender title] ) {
      var disp = ! [pval objectAtIndex:DISPLAY];
      [pval replaceObjectAtIndex:DISPLAY withObject:disp];
      
      break;
    }
  }
  [self setSpansAndReps];
  [self memoizeProps];
  // [self dumpHdrs];
  [self refreshPdgmGridView];
}

////////////////////////////////////////////////////////////////
 - (CFAction)schemaBarClicked:(id)theSender
 {
   CPLog(@"%@: schemaBarClicked", self);
   var seg = [theSender selectedSegment];
   // CPLog(@"    clicked segment: %@ %@; selected? %@", seg, [theSender labelForSegment:seg],
   // 	 [theSender isSelectedForSegment: seg]);
   var prop = [theSender tagForSegment:seg];
   // var prop = [theSender prop];
   // CPLog(@"    prop %@", prop);
   [prop setValue:( ! [prop objectForKey:@"display"] ) forKey:@"display"];
   // [self dumpHdrs];
   [self refreshPdgmGridView];
 }

 ////////////////////////////////////////////////////////////////
 - (CFAction)sortPdgm
 {
   CPLog(@"%@: sortPdgm", self);

  // CPLog(@"    before sort");
  // console.log(__pdgmTerms);
  var temp = [__pdgmTerms sortedArrayUsingFunction:termComparator context:i];
  __pdgmTerms = temp;
  // CPLog(@"    after sort");
  // console.log(temp);
  // [self dumpHdrs];

  [self refreshPdgmGridView];
  [__pdgmGridView reloadData];
  // CPLog(@" CPOrderedAscending: %@, CPOrderedSame:  %@, CPOrderedDescending:  %@, true %@, false %@",
  // 	CPOrderedAscending, CPOrderedSame, CPOrderedDescending, true, false);
  CPLog(@"/%@: sortPdgm", self);
}


////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
//  Table Datasource methods - for table in PdgmGridViewController

- (int)numberOfRowsInTableView:(CPTableView)aTableView
{
  CPLog(@"%@: numberOfRowsInTableView", self);
  CPLog(@"    nbr grid rows: %@", nLeftPvals);
  CPLog(@"    nbr terms:     %@", __pdgmTerms.length);
  return nLeftPvals; // [pdgmHdrs nbrRows];
}

- (id)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aTableColumn row:(int)theRow
{
  return @"foo";
  CPLog(@"%@: tableView:objectValueForTableColumn %@, row %@", self, [aTableColumn identifier], theRow);
  var col = [aTableColumn identifier];
  var tempRow = col * nLeftPvals + theRow; // [pdgmHdrs nbrRows] + theRow;
  var row = __termsIndexSet[tempRow];
  CPLog(@"    token: %@", __pdgmTerms[row]); // ["token"]["value"]);
  console.dir(__pdgmTerms[row]);
  return __pdgmTerms[row]["token"]["value"];
}

////////////////////////////////////////////////////////////////
//  Table delegate methods
//
- (BOOL)selectionShouldChangeInTableView:(CPTableView)aTableView
{
}
- (CPView)tableView:(CPTableView)tableView dataViewForTableColumn:(CPTableColumn)tableColumn row:(int)row
{
}

- (void)tableView:(CPTableView)tableView didClickTableColumn:(CPTableColumn)tableColumn
{
}

- (void)tableView:(CPTableView)tableView didDragTableColumn:(CPTableColumn)tableColumn
{
}

- (float)tableView:(CPTableView)tableView heightOfRow:(int)row
{
}

- (BOOL)tableView:(CPTableView)tableView isGroupRow:(int)row
{
}

- (void)tableView:(CPTableView)tableView mouseDownInHeaderOfTableColumn:(CPTableColumn)tableColumn
{
}

- (int)tableView:(CPTableView)tableView nextTypeSelectMatchFromRow:(int)startRow
	   toRow:(int)endRow
       forString:(CPString)searchString
{
}

- (CPIndexSet)tableView:(CPTableView)tableView selectionIndexesForProposedSelection:(CPIndexSet)proposedSelectionIndexes
{
}

- (BOOL)tableView:(CPTableView)aTableView shouldEditTableColumn:(CPTableColumn)aTableColumn row:(int)rowIndex
{
}

- (BOOL)tableView:(CPTableView)aTableView shouldSelectRow:(int)rowIndex
{
}

- (BOOL)tableView:(CPTableView)aTableView shouldSelectTableColumn:(CPTableColumn)aTableColumn
{
}

- (BOOL)tableView:(CPTableView)aTableView shouldShowCellExpansionForTableColumn:(CPTableColumn)tableColumn row:(int)row
{
}

- (BOOL)tableView:(CPTableView)aTableView shouldTrackView:(CPView)aView forTableColumn:(CPTableColumn)tableColumn row:(int)row
{
}

- (BOOL)tableView:(CPTableView)aTableView shouldTypeSelectForEvent:(CPEvent)event withCurrentSearchString:(CPString)searchString
{
}

- (CPString)tableView:(CPTableView)aTableView
       toolTipForView:(CPView)aView
		 rect:(CPRectPointer)rect
	  tableColumn:(CPTableColumn)aTableColumn
		  row:(int)row
	mouseLocation:(CPPoint)mouseLocation
{
}

- (CPString)tableView:(CPTableView)tableView typeSelectStringForTableColumn:(CPTableColumn)tableColumn row:(int)row
{
}

- (void)tableView:(CPTableView)aTableView willDisplayView:(id)aView forTableColumn:(CPTableColumn)aTableColumn row:(int)rowIndex
{
}

- (void)tableViewSelectionDidChange:(CPNotification)aNotification
{
}

- (void)tableViewSelectionIsChanging:(CPNotification)aNotification
{
}

- (void)dumpWindowGeom:(CPTableView)theWin
{
  CPLog(@"%@ dumpWindowGeom: %@", self, theWin);
  var frame = [theWin frame];
  var bnds = [[theWin contentView] bounds];

  
  console.log("win frame: ", frame);
  console.log("win bounds: ", bnds);

  // console.log("width: " + [win width])
  // console.log("frame (" + frame.size.width + "," + frame.size.height + ")", frame,
  // 	      "bounds (" + bnds.size.width + "," + bnds.size.height + ")", bnds);
  // console.log(" frame offset (-10,-10)", CGRectOffset(frame, -10, -10));
  // console.log(" frame inset (-10,-10)", CGRectInset(frame, -10, -10));

  CPLog(@"/%@ dumpWindowGeom", self);
}

- (void)dumpHdrs
{
  CPLog(@"%@ dumpHdrs", self);
  CPLog("    __nProps %@;  nPvals: %@", __nProps, nPvals);
  CPLog("    nTopProps: %@; nBottomProps %@; nLeftProps %@; nRightProps %@", nTopProps, nBottomProps, nLeftProps, nRightProps);
  CPLog("    nTopPvals: %@; nBottomPvals %@; nLeftPvals %@; nRightPvals %@", nTopPvals, nBottomPvals, nLeftPvals, nRightPvals);
  console.log(hdrs);
  for(var i=0; i<RIGHT; i++) {
    console.log("    header ", i, hdrs[i]);
  }
  CPLog(@"/%@ /dumpHdrs", self);
}

- (void)dumpTableView:(CPTableView)theView
{
  CPLog(@"%@ dumpTableView: %@", self, theView);
  var frame = [theView frame];
  var bnds = [theView bounds];
  // console.log("width: " + [theView width])
  console.log("frame (" + frame.size.width + "," + frame.size.height + ")", frame,
	      "bounds (" + bnds.size.width + "," + bnds.size.height + ")", bnds);
  console.log(" frame offset (-10,-10)", CGRectOffset(frame, -10, -10));
  console.log(" frame inset (-10,-10)", CGRectInset(frame, -10, -10));

  var tcols =  [theView tableColumns];
  var nCols =  tcols.length;
  console.log("colums: " + [theView numberOfColumns]);
  console.log("rows: " + [theView numberOfRows]);
  for (var i=0; i<nCols; i++) {
    var col = [tcols objectAtIndex:i];
    // console.log("col " + i, col, " width: " + [col width]);
  }
  CPLog(@"/%@ dumpTableView: %@", self, theView);
}

- (BOOL)validateMenuItem:(CPMenuItem)theMenuItem
{
  CPLog(@"%@ validateMenuItem: %@; action %@", self, [theMenuItem title], [theMenuItem action]);
  return YES;
}

 // /*!
 //     The method notifies the controller that it's window has loaded.
 // */
 // - (void)windowDidLoad
 // {
 //   CPLog(@"%@: windowDidLoad", self);
 //   // set tab and table views?
 //   // [super windowDidLoad];
 //   // [self showView:nil];
 // }

@end

////////////////////////////////////////////////////////////////
var termComparator = function(term1, term2, sortController)
{
  // CPLog(@"%@ termComparator", self);
  // console.log(term1);
  // console.log(term2);
  // console.log(sortController);
  var tok1 = term1["token"]["value"];
  var tok2 = term2["token"]["value"];
  
  for (var i=0; i<__nProps; i++) {
    // compute indices into headers and properties
    // this maps the index i to index hdr into the hdrs array, and idx into the resulting prop's pval list
    var idx, hdr;
    if (i < nTopProps) {
      // CPLog(@"    TOP %@", nTopProps); 
      idx = i;
      hdr = TOP;
    } else if (i < nTopProps + nBottomProps) {
      idx = i - nTopProps;
      hdr = BOTTOM;
    } else if (i < nTopProps + nBottomProps + nLeftProps) {
      // CPLog(@"    LEFT %@", nLeftProps); 
      idx = i - (nTopProps + nBottomProps);
      hdr = LEFT;
    } else if (i < __nProps) {
      idx = i - (nTopProps + nBottomProps + nLeftProps);
      hdr = RIGHT;
    } else { syslogd.log("should not be here"); }

    // CPLog(@" mapping %@ to %@ / %@", i, hdr, idx);
  
    // now find the pdgmTerm col corresponding to the property
    var hprop = hdrs[hdr][idx];
    // console.log(hprop);
    var pname = [hprop objectForKey:@"name"];
    // CPLog(@"    term1 %@, term2 %@; pname: %@", tok1, tok2, pname);
    // console.log(term1[pname]["value"]);
    // use the term's pval as index into header prop descriptor
    pvals = [hprop objectForKey:@"pvals"];
    var i1, i2;
    for (i1=0; i1<[pvals count]; i1++) {
      var pval = [pvals objectAtIndex:i1];
      if ( [pval objectAtIndex:VALUE] == term1[pname]["value"] ) break;
    }
    for (i2=0; i2<[pvals count]; i2++) {
      var pval = [pvals objectAtIndex:i2];
      if ( [pval objectAtIndex:VALUE] == term2[pname]["value"] ) break;
    }
    // var t1 = [p1 indexOfObject:term1[pname]["value"]];
    // var t2 = [p1 indexOfObject:term2[pname]["value"]];

    var result = [i1 compare:i2];
    // CPLog(@"    prop: %@  -- %@:%@ (%@) > %@:%@ (%@) ? %@",
    // 	  pname, tok1, term2[pname]["value"], t1,
    // 	  tok2, term1[pname]["value"], t2,
    // 	  result);
    if ( result == CPOrderedSame ) { continue; }
    else {
      // CPLog(@" result: %@", result);
      return result;
    }
  }
  CPLog(@"    **************** ERROR: found equal terms!! ****************");
  console.log(term1);
  console.log(term2);
  return CPOrderedSame;
};

