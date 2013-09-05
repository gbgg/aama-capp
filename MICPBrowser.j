/*
 * MICPBrowser.j
 * AppKit
 *
 * Created by Ross Boucher.
 * Copyright 2010, 280 North, Inc.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@import <Foundation/CPIndexSet.j>

// @import "CPControl.j"
// @import "CPImage.j"
@import "MITableView.j"
// @import "CPTextField.j"
// @import "CPScrollView.j"

/*!
    @ingroup appkit
    @class MICPBrowser
*/

@implementation MICPBrowser : CPControl
{
    id              _delegate;
    CPString        _pathSeparator;

    CPView          _contentView;
    CPScrollView    _horizontalScrollView;
    CPView          _prototypeView;

    CPArray         _tableViews;
    CPArray         _tableDelegates;

    CPView          _docSummaryView; //MI
    var             _docSummaryViewWidth; //MI

    id              _rootItem;

    BOOL            _delegateSupportsImages;

    BOOL            _delegateSupportsDocSummary;  //MI

    SEL             _doubleAction @accessors(property=doubleAction);

    BOOL            _allowsMultipleSelection;
    BOOL            _allowsEmptySelection;

    Class           _tableViewClass @accessors(property=tableViewClass);

    float           _rowHeight;
    float           _imageWidth;
    float           _leafWidth;
    float           _minColumnWidth;
    float           _defaultColumnWidth @accessors(property=defaultColumnWidth);

    CPArray         _columnWidths;
}

//DEBUG
- (void)reloadColumn:(int)column
{
// CPLog(@"%@ reloadColumn %@", self, column);
  [[self tableViewInColumn:column] reloadData];
  // [super reloadColumn:column];
}

- (CPIndexPath)selectionIndexPaths
{
// CPLog(@"%@ selectionIndexPaths", self);
  for (i=0; i< [_tableViews count]; i++) {
    var n = [[_tableViews objectAtIndex:i] numberOfSelectedRows];
// CPLog(@"%@ tableView %@ selected rows: %@", self, i, n);
// CPLog(@"%@ tableView selectedRow: %@", self,
	  // [[_tableViews objectAtIndex:i] selectedRow]);
    }
}
//DEBUG

+ (CPImage)branchImage
{
    //MI return [[CPImage alloc] initWithContentsOfFile:[[CPBundle bundleForClass:[MICPBrowser class]]
    return [[CPImage alloc] initWithContentsOfFile:[[CPBundle bundleForClass:[CPBrowser class]]
                                                    pathForResource:"browser-leaf.png"]
                                              size:CGSizeMake(9,9)];
}

+ (CPImage)highlightedBranchImage
{
    //MI return [[CPImage alloc] initWithContentsOfFile:[[CPBundle bundleForClass:[MICPBrowser class]]
    return [[CPImage alloc] initWithContentsOfFile:[[CPBundle bundleForClass:[CPBrowser class]]
                                                    pathForResource:"browser-leaf-highlighted.png"]
                                              size:CGSizeMake(9,9)];
}

- (id)initWithFrame:(CGRect)aFrame
{
    if (self = [super initWithFrame:aFrame])
    {
        [self _init];
    }

    [self setTableViewClass:[MITableView class]];

    return self;
}

//{DEBUG
// - (void)setDoubleAction:(SEL)theSelector
// {
//   CPLog(@"%@: setDoubleAction", self);
//     [super setDoubleAction:theSelector];
// }
//DEBUG}

- (void)_init
{
    _rowHeight = 23.0;
    _defaultColumnWidth = 140.0;
    _minColumnWidth = 80.0;
    _imageWidth = 23.0;
    _leafWidth = 13.0;
    _columnWidths = [];

    _pathSeparator = "/";
    _tableViews = [];
    _tableDelegates = [];
    _allowsMultipleSelection = YES;
    _allowsEmptySelection = YES;
    _tableViewClass = [_MICPBrowserTableView class];

    _docSummaryView = nil; //MI

    _prototypeView = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
    [_prototypeView setVerticalAlignment:CPCenterVerticalTextAlignment];
    [_prototypeView setValue:[CPColor whiteColor] forThemeAttribute:"text-color" inState:CPThemeStateSelectedDataView];
    [_prototypeView setLineBreakMode:CPLineBreakByTruncatingTail];

    _horizontalScrollView = [[CPScrollView alloc] initWithFrame:[self bounds]];

    [_horizontalScrollView setHasVerticalScroller:NO];
    [_horizontalScrollView setAutohidesScrollers:YES];
    [_horizontalScrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

    _contentView = [[CPView alloc] initWithFrame:CGRectMake(0, 0, 0, CGRectGetHeight([self bounds]))];
    [_contentView setAutoresizingMask:CPViewHeightSizable];

    [_horizontalScrollView setDocumentView:_contentView];

    [self addSubview:_horizontalScrollView];
}

//MI: why the archive/unarchive?
- (void)setPrototypeView:(CPView)aPrototypeView
{
    _prototypeView = [CPKeyedUnarchiver unarchiveObjectWithData:
                        [CPKeyedArchiver archivedDataWithRootObject:aPrototypeView]];
}

- (CPView)prototypeView
{
    return [CPKeyedUnarchiver unarchiveObjectWithData:
            [CPKeyedArchiver archivedDataWithRootObject:_prototypeView]];
}

- (void)setDelegate:(id)anObject
{
  // CPLog(@"%@ setDelegate %@", self, anObject);
    _delegate = anObject;
    _delegateSupportsImages = [_delegate respondsToSelector:@selector(browser:imageValueForItem:)];

    _delegateSupportsDocSummary = [_delegate respondsToSelector:@selector(browser:docSummaryViewForItem:)]; //MI

    [self loadColumnZero];
}

- (id)delegate
{
    return _delegate;
}

- (CPTableView)tableViewInColumn:(unsigned)index
{
    return _tableViews[index];
}

- (unsigned)columnOfTableView:(CPTableView)aTableView
{
    return [_tableViews indexOfObject:aTableView];
}

- (void)loadColumnZero
{
    if ([_delegate respondsToSelector:@selector(rootItemForBrowser:)])
        _rootItem = [_delegate rootItemForBrowser:self];
    else
        _rootItem = nil;

    [self setLastColumn:-1];
    [self addColumn];
}

- (void)setLastColumn:(int)columnIndex
{
  // CPLog(@"%@ setLastColumn", self)
    if (columnIndex >= _tableViews.length)
        return;

    var oldValue = _tableViews.length - 1,
        indexPlusOne = columnIndex + 1; // unloads all later columns.

    [[_tableViews.slice(indexPlusOne) valueForKey:"enclosingScrollView"]
      makeObjectsPerformSelector:@selector(removeFromSuperview)];

    //MI
    if (_docSummaryView) { // if selected item not leaf
	[[_docSummaryView enclosingScrollView] removeFromSuperview];
	_docSummaryView = nil;
    }//MI

    _tableViews = _tableViews.slice(0, indexPlusOne);
    _tableDelegates = _tableDelegates.slice(0, indexPlusOne);

    if ([_delegate respondsToSelector:@selector(browser:didChangeLastColumn:toColumn:)])
        [_delegate browser:self didChangeLastColumn:oldValue toColumn:columnIndex];

    [self tile];
}

- (int)lastColumn
{
    return _tableViews.length - 1;
}

- (void)addColumn
{
    var lastIndex = [self lastColumn],
        lastColumn = _tableViews[lastIndex],
        selectionIndexes = [lastColumn selectedRowIndexes];

    if (lastIndex >= 0 && [selectionIndexes count] > 1)
        [CPException raise:CPInvalidArgumentException
                    reason:"Can't add column, column "+lastIndex+" has invalid selection."];

    var index = lastIndex + 1,
        item = index === 0 ? _rootItem : [_tableDelegates[lastIndex] childAtIndex:[selectionIndexes firstIndex]];

    if (index > 0 && item && [self isLeafItem:item]) {
        //MI return;
	[self addDocSummaryColumn:index forItem:item];
    } else {
	[self addTableColumn:index forItem:item];
    }
}

//MI:  new routine
- (void)addDocSummaryColumn:(int)index forItem:(id)item
{
  // CPLog(@"%@: addDocSummaryColumn %@ forItem %@", self, index, [item objectForKey:@"BaseName"]);
  // CPLog(@"    nbr cols: %@", _tableViews.length);
  //MI TODO:  query datasource for doc summary view
  _docSummaryView = nil;
  _docSummaryView = [_delegate browser:self summaryViewForItem:item];
  _docSummaryViewWidth = [_docSummaryView frame].size.width;

  // _tableViews[index] = _docSummaryView;
  // _tableDelegates[index] = delegate;

  var scrollView = [[_MICPBrowserScrollView alloc] initWithFrame:CGRectMakeZero()];
  [scrollView _setBrowser:self];
  [scrollView setDocumentView:_docSummaryView];
  [scrollView setHasHorizontalScroller:NO];
  [scrollView setAutoresizingMask:CPViewHeightSizable];
  [scrollView setFrameSize:CGSizeMake(200, 0)];

  // [_docSummaryView frame].size];

  [_contentView addSubview:scrollView];

  [self tile];

  // [self scrollColumnToVisible:index];
  // CPLog(@"    nbr cols: %@", _tableViews.length);
  [self scrollColumnToView:_docSummaryView];
  // CPLog(@"/%@: addDocSummaryColumn %@ forItem %@", self, index, [item objectForKey:@"BaseName"]);
}

//MI:  new routine from original "addColumn"
- (void)addTableColumn:(int)index forItem:(id)item
{
    // CPLog(@"%@: MICPBrowser.addTableColumn %@ forItem %@", self, index, [item objectForKey:@"BaseName"]);
    var table = [[_tableViewClass alloc] initWithFrame:CGRectMakeZero() browser:self];

    [table setHeaderView:nil];
    [table setCornerView:nil];
    [table setAllowsMultipleSelection:_allowsMultipleSelection];
    [table setAllowsEmptySelection:_allowsEmptySelection];
    [table registerForDraggedTypes:[self registeredDraggedTypes]];

    [self _addTableColumnsToTableView:table forColumnIndex:index];

    var delegate = [[_MICPBrowserTableDelegate alloc] init];

    [delegate _setDelegate:_delegate];
    [delegate _setBrowser:self];
    [delegate _setIndex:index];
    [delegate _setItem:item];

    _tableViews[index] = table;
    _tableDelegates[index] = delegate;

    [table setDelegate:delegate];
    [table setDataSource:delegate];
    [table setTarget:delegate];
    [table setAction:@selector(_tableViewClicked:)];
    [table setDoubleAction:@selector(_tableViewDoubleClicked:)];
    [table setDraggingDestinationFeedbackStyle:CPTableViewDraggingDestinationFeedbackStyleRegular];

    // CPLog(@"%@: table %@", self, table);
    
    var scrollView = [[_MICPBrowserScrollView alloc] initWithFrame:CGRectMakeZero()];
    [scrollView _setBrowser:self];
    [scrollView setDocumentView:table];
    [scrollView setHasHorizontalScroller:NO];
    [scrollView setAutoresizingMask:CPViewHeightSizable];
    // [scrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

    [_contentView addSubview:scrollView];

    [self tile];

    [self scrollColumnToVisible:index];
    }
}

- (void)_addTableColumnsToTableView:(CPTableView)aTableView forColumnIndex:(unsigned)index
{
  // CPLog(@"%@ _addTableColumnsToTableView", self);
    if (_delegateSupportsImages)
    {
        var column = [[CPTableColumn alloc] initWithIdentifier:@"Image"],
            view = [[CPImageView alloc] initWithFrame:CGRectMakeZero()];

        [view setImageScaling:CPScaleProportionally];

        [column setDataView:view];
        [column setResizingMask:CPTableColumnNoResizing];

        [aTableView addTableColumn:column];
    }

    var column = [[CPTableColumn alloc] initWithIdentifier:@"Content"];

    [column setDataView:_prototypeView];
    [column setResizingMask:CPTableColumnNoResizing];

    [aTableView addTableColumn:column];

    var column = [[CPTableColumn alloc] initWithIdentifier:@"Leaf"],
        view = [[_MICPBrowserLeafView alloc] initWithFrame:CGRectMakeZero()];

    [view setBranchImage:[[self class] branchImage]];
    [view setHighlightedBranchImage:[[self class] highlightedBranchImage]];

    [column setDataView:view];
    [column setResizingMask:CPTableColumnNoResizing];

    [aTableView addTableColumn:column];
}

- (void)tile
{
  // CPLog(@"%@ tile", self);
    var xOrigin = 0,
        scrollerWidth = [CPScroller scrollerWidth],
        height = CGRectGetHeight([_contentView bounds]);

    var padding = 4;
    
    for (var i = 0, count = _tableViews.length; i < count; i++)
    {
        var tableView = _tableViews[i],
            scrollView = [tableView enclosingScrollView],
            width = [self widthOfColumn:i],
            tableHeight = CGRectGetHeight([tableView bounds]);

        [[tableView tableColumnWithIdentifier:"Image"] setWidth:_imageWidth + padding];
        [[tableView tableColumnWithIdentifier:"Content"] setWidth:width - (_leafWidth + _delegateSupportsImages ? _imageWidth : 0)
							 - scrollerWidth - scrollerWidth + padding];
        [[tableView tableColumnWithIdentifier:"Leaf"] setWidth:_leafWidth + padding];

        [tableView setRowHeight:_rowHeight];
        [tableView setFrameSize:CGSizeMake(width - scrollerWidth, tableHeight)];
        [scrollView setFrameOrigin:CGPointMake(xOrigin, 0)];
        [scrollView setFrameSize:CGSizeMake(width, height)];

        xOrigin += width;
    }

    if (_docSummaryView) {
	//MI: accomodate _docSummaryView
      // CPLog(@"%@: tile", self);
	// var tableView = _tableViews[i],
      var scrollView = [_docSummaryView enclosingScrollView];
      var width = _docSummaryViewWidth; //  frame].size.width;
      var docSummaryViewHeight = CGRectGetHeight([_docSummaryView bounds]); // + 40;
      [_docSummaryView setFrameSize:CGSizeMake(width, docSummaryViewHeight)];

      [scrollView setFrameOrigin:CGPointMake(xOrigin, 0)];
      [scrollView setFrameSize:CGSizeMake(width, height)];
      xOrigin += width;
    }
    
    [_contentView setFrameSize:CGSizeMake(xOrigin, height)];
}

- (unsigned)rowAtPoint:(CGPoint)aPoint
{
    var column = [self columnAtPoint:aPoint];
    if (column === -1)
        return -1;

    var tableView = _tableViews[column];
    return [tableView rowAtPoint:[tableView convertPoint:aPoint fromView:self]];
}

- (unsigned)columnAtPoint:(CGPoint)aPoint
{
    var adjustedPoint = [_contentView convertPoint:aPoint fromView:self];

    for (var i = 0, count = _tableViews.length; i < count; i++)
    {
        var frame = [[_tableViews[i] enclosingScrollView] frame];
        if (CGRectContainsPoint(frame, adjustedPoint))
            return i;
    }

    return -1;
}

- (CGRect)rectOfRow:(unsigned)aRow inColumn:(unsigned)aColumn
{
// CPLog(@"%@ rectOfRow %@ inColumn %@", self, aRow, aColumn);
    var tableView = _tableViews[aColumn],
        rect = [tableView rectOfRow:aRow];

    rect.origin = [self convertPoint:rect.origin fromView:tableView];
    console.log("origin: ", rect);
    return rect;
}

// ITEMS

- (id)itemAtRow:(int)row inColumn:(int)column
{
  // CPLog(@"%@ itemAtRow %@ col %@", self, row, column);
  return [_tableDelegates[column] childAtIndex:row];
}

- (BOOL)isLeafItem:(id)item
{
    return [_delegate respondsToSelector:@selector(browser:isLeafItem:)] && [_delegate browser:self isLeafItem:item];
}

- (id)parentForItemsInColumn:(int)column
{
    return [_tableDelegates[column] _item];
}

- (CPSet)selectedItems
{
    var selectedColumn = [self selectedColumn],
        selectedIndexes = [self selectedRowIndexesInColumn:selectedColumn],
        set = [CPSet set],
        index = [selectedIndexes firstIndex];

    while (index !== CPNotFound)
    {
        [set addObject:[self itemAtRow:index inColumn:selectedColumn]];
        index = [selectedIndexes indexGreaterThanIndex:index];
    }

    return set;
}

- (id)selectedItem
{
// CPLog(@"%@ selectedItem ", self);
  // return [super selectedItem];
    var selectedColumn = [self selectedColumn],
        selectedRow = [self selectedRowInColumn:selectedColumn];

    return [self itemAtRow:selectedRow inColumn:selectedColumn];
}

// CLICK EVENTS

- (void)trackMouse:(CPEvent)anEvent
{
}

- (void)_column:(unsigned)columnIndex clickedRow:(unsigned)rowIndex
{
  // CPLog(@"%@ _column %@ clickedRow %@", self, columnIndex, rowIndex);

    [self setLastColumn:columnIndex];

    if (rowIndex >= 0)
        [self addColumn];

    [self doClick:self];
}

- (void)sendAction
{
    [self sendAction:_action to:_target];
}

- (void)doClick:(id)sender
{
  // CPLog(@"%@ sending action %@ to %@", self, _action, _target);
    // [_browser selectRow:[self selectedRow] inColumn:[_browser selectedColumn]];
    [self sendAction:_action to:_target];
}

- (void)doDoubleClick:(id)sender
{
    [self sendAction:_doubleAction to:_target];
}

- (void)keyDown:(CPEvent)anEvent
{
// CPLog(@"%@ keyDown", self);
    var column = [self selectedColumn];
// CPLog(@"%@ col %@", self, column);
    if (column === -1)
        return;
// CPLog(@"%@ _tableViews[column]: %@", self, _tableViews[column]);
    [_tableViews[column] keyDown:anEvent];
}

// SIZING

- (float)columnContentWidthForColumnWidth:(float)aWidth
{
    return aWidth - (_leafWidth + _delegateSupportsImages ? _imageWidth : 0) - [CPScroller scrollerWidth];
}

- (float)columnWidthForColumnContentWidth:(float)aWidth
{
    return aWidth + (_leafWidth + _delegateSupportsImages ? _imageWidth : 0) + [CPScroller scrollerWidth];
}

- (void)setImageWidth:(float)aWidth
{
    _imageWidth = aWidth;
    [self tile];
}

- (float)imageWidth
{
    return _imageWidth;
}

- (void)setMinColumnWidth:(float)minWidth
{
    _minColumnWidth = minWidth;
    [self tile];
}

- (float)minColumnWidth
{
    return _minColumnWidth;
}

- (void)setWidth:(float)aWidth ofColumn:(unsigned)column
{
  // CPLog(@"%@ setWidth %@ of col %@", self, aWidth, column);
  if ( column < 0 ) { //MI
    _docSummaryViewWidth = aWidth; //MI
  } else { //MI
    _columnWidths[column] = aWidth;
  } //MI

    if ([_delegate respondsToSelector:@selector(browser:didResizeColumn:)])
        [_delegate browser:self didResizeColumn:column];

    [self tile];
}

- (float)widthOfDocSummaryColumn //MI
{
  return _docSummaryViewWidth;
}

- (float)widthOfColumn:(unsigned)column
{
    var width = _columnWidths[column];

    if (width == null)
        width = _defaultColumnWidth;

    return MAX([CPScroller scrollerWidth], MAX(_minColumnWidth, width));
}

- (void)setRowHeight:(float)aHeight
{
    _rowHeight = aHeight;
}

- (float)rowHeight
{
    return _rowHeight;
}

// SCROLLERS

//MI: new routine
- (void)scrollColumnToView:(CPView)column
{
  // CPLog(@"%@: MICPBrowser.scrollColumnToView", self);
  // CPLog(@"%@: doc summary enclosingScrollView %@", self, [column enclosingScrollView]);
    [_contentView scrollRectToVisible:[[column enclosingScrollView] frame]];
}

- (void)scrollColumnToVisible:(unsigned)columnIndex
{
  // CPLog(@"%@: table enclosingScrollView %@", self, [[self tableViewInColumn:columnIndex] enclosingScrollView]);
    [_contentView scrollRectToVisible:[[[self tableViewInColumn:columnIndex] enclosingScrollView] frame]];
}

- (void)scrollRowToVisible:(unsigned)rowIndex inColumn:(unsigned)columnIndex
{
    [self scrollColumnToVisible:columnIndex];
    [[self tableViewInColumn:columnIndex] scrollRowToVisible:rowIndex];
}

- (BOOL)autohidesScroller
{
    return [_horizontalScrollView autohidesScrollers];
}

- (void)setAutohidesScroller:(BOOL)shouldHide
{
    [_horizontalScrollView setAutohidesScrollers:shouldHide];
}

// SELECTION

- (unsigned)selectedRowInColumn:(unsigned)columnIndex
{
// CPLog(@"%@ selectedRowInColumn %@", self, columnIndex);
  if (columnIndex > [self lastColumn] || columnIndex < 0)
    return -1;

  return [_tableViews[columnIndex] selectedRow];
}

- (unsigned)selectedColumn
{
// CPLog(@"%@ selectedColumn ", self);
    var column = [self lastColumn],
        row = [self selectedRowInColumn:column];

    if (row >= 0)
        return column;
    else
        return column - 1;
}

- (void)selectRow:(unsigned)row inColumn:(unsigned)column
{
  // CPLog(@"%@ selectRow %@ in col %@", self, row, column);
    var selectedIndexes = row === -1 ? [CPIndexSet indexSet] : [CPIndexSet indexSetWithIndex:row];
    [self selectRowIndexes:selectedIndexes inColumn:column];
}

- (BOOL)allowsMultipleSelection
{
    return _allowsMultipleSelection;
}

- (void)setAllowsMultipleSelection:(BOOL)shouldAllow
{
    if (_allowsMultipleSelection === shouldAllow)
        return;

    _allowsMultipleSelection = shouldAllow;
    [_tableViews makeObjectsPerformSelector:@selector(setAllowsMultipleSelection:) withObject:shouldAllow];
}

- (BOOL)allowsEmptySelection
{
    return _allowsEmptySelection;
}

- (void)setAllowsEmptySelection:(BOOL)shouldAllow
{
    if (_allowsEmptySelection === shouldAllow)
        return;

    _allowsEmptySelection = shouldAllow;
    [_tableViews makeObjectsPerformSelector:@selector(setAllowsEmptySelection:) withObject:shouldAllow];
}

- (CPIndexSet)selectedRowIndexesInColumn:(unsigned)column
{
    if (column < 0 || column > [self lastColumn] +1)
        return [CPIndexSet indexSet];

    return [[self tableViewInColumn:column] selectedRowIndexes];
}

- (void)selectRowIndexes:(CPIndexSet)indexSet inColumn:(unsigned)column
{
  // CPLog(@"%@ selectRowIndexes", self);
    if (column < 0 || column > [self lastColumn] + 1)
        return;

    if ([_delegate respondsToSelector:@selector(browser:selectionIndexesForProposedSelection:inColumn:)])
        indexSet = [_delegate browser:self selectionIndexesForProposedSelection:indexSet inColumn:column];

    if ([_delegate respondsToSelector:@selector(browser:shouldSelectRowIndexes:inColumn:)] &&
       ![_delegate browser:self shouldSelectRowIndexes:indexSet inColumn:column])
        return;

    if ([_delegate respondsToSelector:@selector(browserSelectionIsChanging:)]) {
        [_delegate browserSelectionIsChanging:self];
    }

    if (column > [self lastColumn])
        [self addColumn];

    [self setLastColumn:column];

    [[self tableViewInColumn:column] selectRowIndexes:indexSet byExtendingSelection:NO];

    [self scrollColumnToVisible:column];

    if ([_delegate respondsToSelector:@selector(browserSelectionDidChange:)]) {
        [_delegate browserSelectionDidChange:self];
    }
// CPLog(@"%@ /selectRowIndexes", self);
}

- (void)setBackgroundColor:(CPColor)aColor
{
    [super setBackgroundColor:aColor];
    [_contentView setBackgroundColor:aColor];
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

// DRAG AND DROP

- (void)registerForDraggedTypes:(CPArray)types
{
    [super registerForDraggedTypes:types];
    [_tableViews makeObjectsPerformSelector:@selector(registerForDraggedTypes:) withObject:types];
}

- (BOOL)canDragRowsWithIndexes:(CPIndexSet)rowIndexes inColumn:(int)columnIndex withEvent:(CPEvent)dragEvent
{
    if ([_delegate respondsToSelector:@selector(browser:canDragRowsWithIndexes:inColumn:withEvent:)])
        return [_delegate browser:self canDragRowsWithIndexes:rowIndexes inColumn:columnIndex withEvent:dragEvent];

    return YES;
}

- (CPImage)draggingImageForRowsWithIndexes:(CPIndexSet)rowIndexes inColumn:(int)columnIndex withEvent:(CPEvent)dragEvent offset:(CGPoint)dragImageOffset
{
    if ([_delegate respondsToSelector:@selector(browser:draggingImageForRowsWithIndexes:inColumn:withEvent:offset:)])
        return [_delegate browser:self draggingImageForRowsWithIndexes:rowIndexes inColumn:columnIndex withEvent:dragEvent offset:dragImageOffset];

    return nil;
}

- (CPView)draggingViewForRowsWithIndexes:(CPIndexSet)rowIndexes inColumn:(int)columnIndex withEvent:(CPEvent)dragEvent offset:(CGPoint)dragImageOffset
{
    if ([_delegate respondsToSelector:@selector(browser:draggingViewForRowsWithIndexes:inColumn:withEvent:offset:)])
        return [_delegate browser:self draggingViewForRowsWithIndexes:rowIndexes inColumn:columnIndex withEvent:dragEvent offset:dragImageOffset];

    return nil;
}

@end

@implementation MICPBrowser (CPCoding)

- (id)initWithCoder:(CPCoder)aCoder
{
    self = [super initWithCoder:aCoder];

    if (self)
    {
        [self _init];

        _allowsEmptySelection = [aCoder decodeBoolForKey:@"MICPBrowserAllowsEmptySelectionKey"];
        _allowsMultipleSelection = [aCoder decodeBoolForKey:@"MICPBrowserAllowsMultipleSelectionKey"];
        _prototypeView = [aCoder decodeObjectForKey:@"MICPBrowserPrototypeViewKey"];
        _rowHeight = [aCoder decodeFloatForKey:@"MICPBrowserRowHeightKey"];
        _imageWidth = [aCoder decodeFloatForKey:@"MICPBrowserImageWidthKey"];
        _minColumnWidth = [aCoder decodeFloatForKey:@"MICPBrowserMinColumnWidthKey"];
        _columnWidths = [aCoder decodeObjectForKey:@"MICPBrowserColumnWidthsKey"];

        [self setDelegate:[aCoder decodeObjectForKey:@"MICPBrowserDelegateKey"]];
        [self setAutohidesScroller:[aCoder decodeBoolForKey:@"MICPBrowserAutohidesScrollerKey"]];
    }

    return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
    // Don't encode the subviews, they're transient and will be recreated from data.
    var actualSubviews = _subviews;
    _subviews = [];
    [super encodeWithCoder:aCoder];
    _subviews = actualSubviews;

    [aCoder encodeBool:[self autohidesScroller] forKey:@"MICPBrowserAutohidesScrollerKey"];
    [aCoder encodeBool:_allowsEmptySelection forKey:@"MICPBrowserAllowsEmptySelectionKey"];
    [aCoder encodeBool:_allowsMultipleSelection forKey:@"MICPBrowserAllowsMultipleSelectionKey"];
    [aCoder encodeObject:_delegate forKey:@"MICPBrowserDelegateKey"];
    [aCoder encodeObject:_prototypeView forKey:@"MICPBrowserPrototypeViewKey"];
    [aCoder encodeFloat:_rowHeight forKey:@"MICPBrowserRowHeightKey"];
    [aCoder encodeFloat:_imageWidth forKey:@"MICPBrowserImageWidthKey"];
    [aCoder encodeFloat:_minColumnWidth forKey:@"MICPBrowserMinColumnWidthKey"];
    [aCoder encodeObject:_columnWidths forKey:@"MICPBrowserColumnWidthsKey"];
}

@end


var _MICPBrowserResizeControlBackgroundImage = nil;

@implementation _MICPBrowserResizeControl : CPView
{
    CGPoint     _mouseDownX;
    MICPBrowser   _browser;
    unsigned    _index;
    unsigned    _width;
}

+ (CPImage)backgroundImage
{
    if (!_MICPBrowserResizeControlBackgroundImage)
    {
        //MI var path = [[CPBundle bundleForClass:[self class]] pathForResource:"browser-resize-control.png"];
        var path = [[CPBundle bundleForClass:[CPBrowser class]] pathForResource:"browser-resize-control.png"];
        _MICPBrowserResizeControlBackgroundImage = [[CPImage alloc] initWithContentsOfFile:path
                                                                                    size:CGSizeMake(15, 14)];
    }

    return _MICPBrowserResizeControlBackgroundImage;
}

- (id)initWithFrame:(CGRect)aFrame
{
    if (self = [super initWithFrame:aFrame])
        [self setBackgroundColor:[CPColor colorWithPatternImage:[[self class] backgroundImage]]];

    return self;
}

- (void)mouseDown:(CPEvent)anEvent
{
  // CPLog(@"%@ mouseDown", self);
    _mouseDownX = [anEvent locationInWindow].x;
    _browser = [[self superview] _browser];
    _index = [_browser columnOfTableView:[[self superview] documentView]];
    if ( _index < 0 ) { //MI
      _width = [_browser widthOfDocSummaryColumn];
    } else { //MI
      _width = [_browser widthOfColumn:_index];
    } //MI
}

- (void)mouseDragged:(CPEvent)anEvent
{
  // CPLog(@"%@ mouseDragged", self);
  var deltaX = [anEvent locationInWindow].x - _mouseDownX;
  [_browser setWidth:_width + deltaX ofColumn:_index];
}

- (void)mouseUp:(CPEvent)anEvent
{
}

@end

@implementation _MICPBrowserScrollView : CPScrollView
{
    _MICPBrowserResizeControl  _resizeControl;
    MICPBrowser                _browser @accessors;
}

- (void)initWithFrame:(CGRect)aFrame
{
    if (self = [super initWithFrame:aFrame])
    {
        _resizeControl = [[_MICPBrowserResizeControl alloc] initWithFrame:CGRectMakeZero()];
        [self addSubview:_resizeControl];
    }

    return self;
}

- (void)reflectScrolledClipView:(CPClipView)aClipView
{
    [super reflectScrolledClipView:aClipView];

    var frame = [_verticalScroller frame];
    frame.size.height = CGRectGetHeight([self bounds]) - 14.0 - frame.origin.y;
    [_verticalScroller setFrameSize:frame.size];

    var resizeFrame = CGRectMake(CGRectGetMinX(frame), CGRectGetMaxY(frame), [CPScroller scrollerWidth], 14.0);
    [_resizeControl setFrame:resizeFrame];
}

@end

@implementation _MICPBrowserTableView : CPTableView
{
    MICPBrowser   _browser;
}

- (id)initWithFrame:(CGRect)aFrame browser:(MICPBrowser)aBrowser
{
    if (self = [super initWithFrame:aFrame])
        _browser = aBrowser;

    return self;
}

- (BOOL)acceptsFirstResponder
{
    return NO;
}

- (void)mouseDown:(CPEvent)anEvent
{
    [super mouseDown:anEvent];
    [[self window] makeFirstResponder:_browser];
}

- (CPView)browserView
{
    return _browser;
}

- (BOOL)canDragRowsWithIndexes:(CPIndexSet)rowIndexes atPoint:(CGPoint)mouseDownPoint
{
    return [_browser canDragRowsWithIndexes:rowIndexes inColumn:[_browser columnOfTableView:self] withEvent:[CPApp currentEvent]];
}

- (CPImage)dragImageForRowsWithIndexes:(CPIndexSet)dragRows tableColumns:(CPArray)theTableColumns event:(CPEvent)dragEvent offset:(CPPointPointer)dragImageOffset
{
    return [_browser draggingImageForRowsWithIndexes:dragRows inColumn:[_browser columnOfTableView:self] withEvent:dragEvent offset:dragImageOffset] ||
           [super dragImageForRowsWithIndexes:dragRows tableColumns:theTableColumns event:dragEvent offset:dragImageOffset];
}

- (CPView)dragViewForRowsWithIndexes:(CPIndexSet)dragRows tableColumns:(CPArray)theTableColumns event:(CPEvent)dragEvent offset:(CPPoint)dragViewOffset
{
    var count = theTableColumns.length;
    while (count--)
    {
        if ([theTableColumns[count] identifier] === "Leaf")
            [theTableColumns removeObject:theTableColumns[count]];
    }

    return [_browser draggingViewForRowsWithIndexes:dragRows inColumn:[_browser columnOfTableView:self] withEvent:dragEvent offset:dragViewOffset] ||
           [super dragViewForRowsWithIndexes:dragRows tableColumns:theTableColumns event:dragEvent offset:dragViewOffset];
}

- (void)moveUp:(id)sender
{
    [super moveUp:sender];
    [_browser selectRow:[self selectedRow] inColumn:[_browser selectedColumn]];
}

- (void)XmoveDown:(id)sender
{
// CPLog(@"%@ moveDown %@", self, sender);
    [super moveDown:sender];
    [_browser selectRow:[self selectedRow] inColumn:[_browser selectedColumn]];
}

- (void)moveLeft:(id)sender
{
    var previousColumn = [_browser selectedColumn] - 1,
        selectedRow = [_browser selectedRowInColumn:previousColumn];

    [_browser selectRow:selectedRow inColumn:previousColumn];
}

- (void)moveRight:(id)sender
{
    [_browser selectRow:0 inColumn:[_browser selectedColumn] + 1];
}

- (void)XkeyDown:(CPEvent)anEvent
{
// CPLog(@"%@ keyDown", self);
    var character = [anEvent charactersIgnoringModifiers],
        modifierFlags = [anEvent modifierFlags];

    // Check for the key events manually, as opposed to waiting for CPWindow to sent the actual action message
    // in _processKeyboardUIKey:, because we might not want to handle the arrow events.
    if (character === CPUpArrowFunctionKey || character === CPDownArrowFunctionKey)
    {
        // We're not interested in the arrow keys if there are no rows.
        // Technically we should also not be interested if we can't scroll,
        // but Cocoa doesn't handle that situation either.
        if ([self numberOfRows] !== 0)
        {
            [self _moveSelectionWithEvent:anEvent upward:(character === CPUpArrowFunctionKey)];

            return;
        }
    }
    else if (character === CPDeleteCharacter || character === CPDeleteFunctionKey)
    {
        // Don't call super if the delegate is interested in the delete key
        if ([self _sendDelegateDeleteKeyPressed])
            return;
    }

    [super keyDown:anEvent];
}

@end

@import <Foundation/CPObject.j>

@implementation _MICPBrowserTableDelegate : _CPBrowserTableDelegate
{
    MICPBrowser   _browser @accessors;
    // unsigned    _index @accessors;
    // id          _delegate @accessors;
    // id          _item @accessors;
}

// - (unsigned)numberOfRowsInTableView:(CPTableView)aTableView
// {
//     return [_delegate browser:_browser numberOfChildrenOfItem:_item];
// }

- (void)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)column row:(unsigned)row
{
    if ([column identifier] === "Image")
        return [_delegate browser:_browser imageValueForItem:[self childAtIndex:row]];
    else if ([column identifier] === "Leaf")
        return ![_browser isLeafItem:[self childAtIndex:row]];
    else
        return [_delegate browser:_browser objectValueForItem:[self childAtIndex:row]];
}

- (void)_tableViewDoubleClicked:(CPTableView)aTableView
{
    [_browser doDoubleClick:self];
}

- (void)_tableViewClicked:(CPTableView)aTableView
{
  // CPLog(@"%@ _tableViewClicked, col %@", self, _index);
  var selectedIndexes = [aTableView selectedRowIndexes];
  var r = [selectedIndexes count] === 1 ? [selectedIndexes firstIndex] : -1;
  [_browser selectRow:r inColumn:_index];
  [_browser _column:_index clickedRow:[selectedIndexes count] === 1 ? [selectedIndexes firstIndex] : -1];
}

- (id)childAtIndex:(unsigned)index
{
  // CPLog(@"%@ childAtIndex %@", self, index);
    return [_delegate browser:_browser child:index ofItem:_item];
}

- (BOOL)tableView:(CPTableView)aTableView acceptDrop:(id)info row:(int)row dropOperation:(CPTableViewDropOperation)operation
{
    if ([_delegate respondsToSelector:@selector(browser:acceptDrop:atRow:column:dropOperation:)])
        return [_delegate browser:_browser acceptDrop:info atRow:row column:_index dropOperation:operation];
    else
        return NO;
}

- (CPDragOperation)tableView:(CPTableView)aTableView validateDrop:(id)info proposedRow:(int)row proposedDropOperation:(CPTableViewDropOperation)operation
{
    if ([_delegate respondsToSelector:@selector(browser:validateDrop:proposedRow:column:dropOperation:)])
        return [_delegate browser:_browser validateDrop:info proposedRow:row column:_index dropOperation:operation];
    else
        return CPDragOperationNone;
}

- (BOOL)tableView:(CPTableView)aTableView writeRowsWithIndexes:(CPIndexSet)rowIndexes toPasteboard:(CPPasteboard)pboard
{
    if ([_delegate respondsToSelector:@selector(browser:writeRowsWithIndexes:inColumn:toPasteboard:)])
        return [_delegate browser:_browser writeRowsWithIndexes:rowIndexes inColumn:_index toPasteboard:pboard];
    else
        return NO;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if (aSelector === @selector(browser:writeRowsWithIndexes:inColumn:toPasteboard:))
        return [_delegate respondsToSelector:@selector(browser:writeRowsWithIndexes:inColumn:toPasteboard:)];
    else
        return [super respondsToSelector:aSelector];
}

@end

@implementation _MICPBrowserLeafView : CPView
{
    BOOL        _isLeaf @accessors(readonly, property=isLeaf);
    CPImage     _branchImage @accessors(property=branchImage);
    CPImage     _highlightedBranchImage @accessors(property=highlightedBranchImage);
}

- (BOOL)objectValue
{
    return _isLeaf;
}

- (void)setObjectValue:(id)aValue
{
    _isLeaf = !!aValue;
    [self setNeedsLayout];
}

- (CGRect)rectForEphemeralSubviewNamed:(CPString)aName
{
    if (aName === "image-view")
        return CGRectInset([self bounds], 1, 1);

    return [super rectForEphemeralSubviewNamed:aName];
}

- (CPView)createEphemeralSubviewNamed:(CPString)aName
{
    if (aName === "image-view")
        return [[CPImageView alloc] initWithFrame:CGRectMakeZero()];

    return [super createEphemeralSubviewNamed:aName];
}

- (void)layoutSubviews
{
    var imageView = [self layoutEphemeralSubviewNamed:@"image-view"
                                           positioned:CPWindowAbove
                      relativeToEphemeralSubviewNamed:nil],
        isHighlighted = [self themeState] & CPThemeStateSelectedDataView;

    [imageView setImage: _isLeaf ? (isHighlighted ? _highlightedBranchImage : _branchImage) : nil];
    [imageView setImageScaling:CPScaleNone];
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
    [super encodeWithCoder:aCoder];

    [aCoder encodeBool:_isLeaf forKey:"_MICPBrowserLeafViewIsLeafKey"];
    [aCoder encodeObject:_branchImage forKey:"_MICPBrowserLeafViewBranchImageKey"];
    [aCoder encodeObject:_highlightedBranchImage forKey:"_MICPBrowserLeafViewHighlightedBranchImageKey"];
}

- (void)initWithCoder:(CPCoder)aCoder
{
    if (self = [super initWithCoder:aCoder])
    {
        _isLeaf = [aCoder decodeBoolForKey:"_MICPBrowserLeafViewIsLeafKey"];
        _branchImage = [aCoder decodeObjectForKey:"_MICPBrowserLeafViewBranchImageKey"];
        _highlightedBranchImage = [aCoder decodeObjectForKey:"_MICPBrowserLeafViewHighlightedBranchImageKey"];
    }

    return self;
}


@end
