@import <AppKit/CPTableView.j>

//DEBUG
CPTableViewColumnDidMoveNotification        = @"CPTableViewColumnDidMoveNotification";
CPTableViewColumnDidResizeNotification      = @"CPTableViewColumnDidResizeNotification";
CPTableViewSelectionDidChangeNotification   = @"CPTableViewSelectionDidChangeNotification";
CPTableViewSelectionIsChangingNotification  = @"CPTableViewSelectionIsChangingNotification";

var CPTableViewDataSource_numberOfRowsInTableView_                                                      = 1 << 0,
    CPTableViewDataSource_tableView_objectValueForTableColumn_row_                                      = 1 << 1,
    CPTableViewDataSource_tableView_setObjectValue_forTableColumn_row_                                  = 1 << 2,
    CPTableViewDataSource_tableView_acceptDrop_row_dropOperation_                                       = 1 << 3,
    CPTableViewDataSource_tableView_namesOfPromisedFilesDroppedAtDestination_forDraggedRowsWithIndexes_ = 1 << 4,
    CPTableViewDataSource_tableView_validateDrop_proposedRow_proposedDropOperation_                     = 1 << 5,
    CPTableViewDataSource_tableView_writeRowsWithIndexes_toPasteboard_                                  = 1 << 6,

    CPTableViewDataSource_tableView_sortDescriptorsDidChange_                                           = 1 << 7;

var CPTableViewDelegate_selectionShouldChangeInTableView_                                               = 1 << 0,
    CPTableViewDelegate_tableView_dataViewForTableColumn_row_                                           = 1 << 1,
    CPTableViewDelegate_tableView_didClickTableColumn_                                                  = 1 << 2,
    CPTableViewDelegate_tableView_didDragTableColumn_                                                   = 1 << 3,
    CPTableViewDelegate_tableView_heightOfRow_                                                          = 1 << 4,
    CPTableViewDelegate_tableView_isGroupRow_                                                           = 1 << 5,
    CPTableViewDelegate_tableView_mouseDownInHeaderOfTableColumn_                                       = 1 << 6,
    CPTableViewDelegate_tableView_nextTypeSelectMatchFromRow_toRow_forString_                           = 1 << 7,
    CPTableViewDelegate_tableView_selectionIndexesForProposedSelection_                                 = 1 << 8,
    CPTableViewDelegate_tableView_shouldEditTableColumn_row_                                            = 1 << 9,
    CPTableViewDelegate_tableView_shouldSelectRow_                                                      = 1 << 10,
    CPTableViewDelegate_tableView_shouldSelectTableColumn_                                              = 1 << 11,
    CPTableViewDelegate_tableView_shouldShowViewExpansionForTableColumn_row_                            = 1 << 12,
    CPTableViewDelegate_tableView_shouldTrackView_forTableColumn_row_                                   = 1 << 13,
    CPTableViewDelegate_tableView_shouldTypeSelectForEvent_withCurrentSearchString_                     = 1 << 14,
    CPTableViewDelegate_tableView_toolTipForView_rect_tableColumn_row_mouseLocation_                    = 1 << 15,
    CPTableViewDelegate_tableView_typeSelectStringForTableColumn_row_                                   = 1 << 16,
    CPTableViewDelegate_tableView_willDisplayView_forTableColumn_row_                                   = 1 << 17,
    CPTableViewDelegate_tableViewSelectionDidChange_                                                    = 1 << 18,
    CPTableViewDelegate_tableViewSelectionIsChanging_                                                   = 1 << 19,
    CPTableViewDelegate_tableViewMenuForTableColumn_Row_                                                = 1 << 20;

//CPTableViewDraggingDestinationFeedbackStyles
CPTableViewDraggingDestinationFeedbackStyleNone = -1;
CPTableViewDraggingDestinationFeedbackStyleRegular = 0;
CPTableViewDraggingDestinationFeedbackStyleSourceList = 1;

//CPTableViewDropOperations
CPTableViewDropOn = 0;
CPTableViewDropAbove = 1;

CPSourceListGradient = "CPSourceListGradient";
CPSourceListTopLineColor = "CPSourceListTopLineColor";
CPSourceListBottomLineColor = "CPSourceListBottomLineColor";

// TODO: add docs

CPTableViewSelectionHighlightStyleNone = -1;
CPTableViewSelectionHighlightStyleRegular = 0;
CPTableViewSelectionHighlightStyleSourceList = 1;

CPTableViewGridNone                    = 0;
CPTableViewSolidVerticalGridLineMask   = 1 << 0;
CPTableViewSolidHorizontalGridLineMask = 1 << 1;

CPTableViewNoColumnAutoresizing = 0;
CPTableViewUniformColumnAutoresizingStyle = 1; // FIX ME: This is FUBAR
CPTableViewSequentialColumnAutoresizingStyle = 2;
CPTableViewReverseSequentialColumnAutoresizingStyle = 3;
CPTableViewLastColumnOnlyAutoresizingStyle = 4;
CPTableViewFirstColumnOnlyAutoresizingStyle = 5;

// #define NUMBER_OF_COLUMNS() (_tableColumns.length)
// #define UPDATE_COLUMN_RANGES_IF_NECESSARY() if (_dirtyTableColumnRangeIndex !== CPNotFound) [self _recalculateTableColumnRanges];

//DEBUG


@implementation MITableView : CPTableView
{
    CPBrowser   _browser;
}

- (id)initWithFrame:(CGRect)aFrame browser:(CPBrowser)aBrowser
{
  // CPLog(@"MITableView initWithFrame, browser %@", aBrowser);
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
  // CPLog(@"mouseDown");
    [super mouseDown:anEvent];
    [[self window] makeFirstResponder:_browser];
}

- (int)selectedRow
{
  CPLog(@"%@ selectedRow: %@", self, _lastSelectedRow);
    return _lastSelectedRow;
}

//DEBUG
- (void)noteNumberOfRowsChangedX
{
  // CPLog(@"%@ noteNumberOfRowsChanged; last selected row: %@", self, _lastSelectedRow);
    var oldNumberOfRows = _numberOfRows;

    _numberOfRows = nil;
    _cachedRowHeights = [];

    // this line serves two purposes
    // 1. it updates the _numberOfRows cache with the -numberOfRows call
    // 2. it updates the row height cache if needed
    [self noteHeightOfRowsWithIndexesChanged:[CPIndexSet indexSetWithIndexesInRange:CPMakeRange(0, [self numberOfRows])]];

    // remove row indexes from the selection if they no longer exist
    var hangingSelections = oldNumberOfRows - _numberOfRows;

    if (hangingSelections > 0)
    {

        var previousSelectionCount = [_selectedRowIndexes count];
        [_selectedRowIndexes removeIndexesInRange:CPMakeRange(_numberOfRows, hangingSelections)];

        if (![_selectedRowIndexes containsIndex:[self selectedRow]])
            _lastSelectedRow = CPNotFound;

        // For optimal performance, only send a notification if indices were actually removed.
        if (previousSelectionCount > [_selectedRowIndexes count])
            [self _noteSelectionDidChange];
    }

    [self tile];
    // CPLog(@"%@/ noteNumberOfRowsChanged; last selected row: %@", self, _lastSelectedRow);
}
//DEBUG

//DEBUG
- (void)_moveSelectionWithEvent:(CPEvent)theEvent upward:(BOOL)shouldGoUpward
{
  // CPLog(@"%@ _moveSelectionWithEvent; last row: %@ ", self, _lastSelectedRow)
    if (_implementedDelegateMethods & CPTableViewDelegate_selectionShouldChangeInTableView_ && ![_delegate selectionShouldChangeInTableView:self])
        return;
    var selectedIndexes = [self selectedRowIndexes];

    if ([selectedIndexes count] > 0)
    {
        var extend = (([theEvent modifierFlags] & CPShiftKeyMask) && _allowsMultipleSelection),
            i = [self selectedRow];

        if ([self _selectionIsBroken])
        {
            while ([selectedIndexes containsIndex:i])
            {
                shouldGoUpward ? i-- : i++;
            }
            _wasSelectionBroken = true;
        }
        else if (_wasSelectionBroken && ((shouldGoUpward && i !== [selectedIndexes firstIndex]) || (!shouldGoUpward && i !== [selectedIndexes lastIndex])))
        {
            shouldGoUpward ? i = [selectedIndexes firstIndex] - 1 : i = [selectedIndexes lastIndex];
            _wasSelectionBroken = false;
        }
        else
        {
            shouldGoUpward ? i-- : i++;
        }
    }
    else
    {
        var extend = NO;
        //no rows are currently selected
        if ([self numberOfRows] > 0)
            var i = shouldGoUpward ? [self numberOfRows] - 1 : 0; // if we select upward select the last row, otherwise select the first row
    }

    if (i >= [self numberOfRows] || i < 0)
        return;


    if (_implementedDelegateMethods & CPTableViewDelegate_tableView_shouldSelectRow_)
    {

        while (![_delegate tableView:self shouldSelectRow:i] && (i < [self numberOfRows] || i > 0))
            shouldGoUpward ? i-- : i++; //check to see if the row can be selected if it can't be then see if the next row can be selected

        //if the index still can be selected after the loop then just return
         if (![_delegate tableView:self shouldSelectRow:i])
             return;
    }

    // if we go upward and see that this row is already selected we should deselect the row below
    if ([selectedIndexes containsIndex:i] && extend)
    {
        // the row we're on is the last to be selected
        var differedLastSelectedRow = i;

        // no remove the one before/after it
        shouldGoUpward ? i++  : i--;

        [selectedIndexes removeIndex:i];

        //we're going to replace the selection
        extend = NO;
    }
    else if (extend)
    {
        if ([selectedIndexes containsIndex:i])
        {
            i = shouldGoUpward ? [selectedIndexes firstIndex] -1 : [selectedIndexes lastIndex] + 1;
            i = MIN(MAX(i,0), [self numberOfRows] - 1);
        }

        [selectedIndexes addIndex:i];
        var differedLastSelectedRow = i;
    }
    else
    {
        selectedIndexes = [CPIndexSet indexSetWithIndex:i];
        var differedLastSelectedRow = i;
    }

    [self selectRowIndexes:selectedIndexes byExtendingSelection:extend];

    // we differ because selectRowIndexes: does its own thing which would set the wrong index
    _lastSelectedRow = differedLastSelectedRow;

    if (i !== CPNotFound)
        [self scrollRowToVisible:i];
    // CPLog(@"%@ _lastSelectedRow %@", self, _lastSelectedRow);
}
//DEBUG

//DEBUG
- (void)_updateSelectionWithMouseAtRow:(CPInteger)aRow
{
  // CPLog(@"%@ _updateSelectionWithMouseAtRow", self, aRow);
    //check to make sure the row exists
    if (aRow < 0)
        return;

    var newSelection,
        shouldExtendSelection = NO;
    // If cmd/ctrl was held down XOR the old selection with the proposed selection
    if ([self mouseDownFlags] & (CPCommandKeyMask | CPControlKeyMask | CPAlternateKeyMask))
    {
        if ([_selectedRowIndexes containsIndex:aRow])
        {
            newSelection = [_selectedRowIndexes copy];

            [newSelection removeIndex:aRow];
        }

        else if (_allowsMultipleSelection)
        {
            newSelection = [_selectedRowIndexes copy];

            [newSelection addIndex:aRow];
        }

        else
            newSelection = [CPIndexSet indexSetWithIndex:aRow];
    }
    else if (_allowsMultipleSelection)
    {
        newSelection = [CPIndexSet indexSetWithIndexesInRange:CPMakeRange(MIN(aRow, _selectionAnchorRow), ABS(aRow - _selectionAnchorRow) + 1)];
        shouldExtendSelection = [self mouseDownFlags] & CPShiftKeyMask &&
                                ((_lastSelectedRow == [_selectedRowIndexes lastIndex] && aRow > _lastSelectedRow) ||
                                (_lastSelectedRow == [_selectedRowIndexes firstIndex] && aRow < _lastSelectedRow));
    }
    else if (aRow >= 0 && aRow < _numberOfRows)
        newSelection = [CPIndexSet indexSetWithIndex:aRow];
    else
        newSelection = [CPIndexSet indexSet];
    // CPLog(@"%@ _lastSelectedRow: %@", self, _lastSelectedRow);

    if ([newSelection isEqualToIndexSet:_selectedRowIndexes])
        return;

    if (_implementedDelegateMethods & CPTableViewDelegate_selectionShouldChangeInTableView_ &&
        ![_delegate selectionShouldChangeInTableView:self])
        return;

    if (_implementedDelegateMethods & CPTableViewDelegate_tableView_selectionIndexesForProposedSelection_)
        newSelection = [_delegate tableView:self selectionIndexesForProposedSelection:newSelection];
    // CPLog(@"%@ _lastSelectedRow: %@", self, _lastSelectedRow);

    if (_implementedDelegateMethods & CPTableViewDelegate_tableView_shouldSelectRow_)
    {
        var indexArray = [];

        [newSelection getIndexes:indexArray maxCount:-1 inIndexRange:nil];

        var indexCount = indexArray.length;

        while (indexCount--)
        {
            var index = indexArray[indexCount];

            if (![_delegate tableView:self shouldSelectRow:index])
                [newSelection removeIndex:index];
        }

        // as per cocoa
        if ([newSelection count] === 0)
            return;
    }
    // CPLog(@"%@ _lastSelectedRow: %@", self, _lastSelectedRow);

    // if empty selection is not allowed and the new selection has nothing selected, abort
    if (!_allowsEmptySelection && [newSelection count] === 0)
        return;

    if ([newSelection isEqualToIndexSet:_selectedRowIndexes])
        return;

    [self selectRowIndexes:newSelection byExtendingSelection:shouldExtendSelection];

    _lastSelectedRow = [newSelection containsIndex:aRow] ? aRow : [newSelection lastIndex];
    // CPLog(@"%@ _lastSelectedRow: %@", self, _lastSelectedRow);
}
//DEBUG

//DEBUG
- (void)_setSelectedRowIndexes:(CPIndexSet)rows
{
  // CPLog(@"%@ _setSelectedRowIndexes %@, count: %@, last %@", self, rows, [rows count], [rows lastIndex]);
    if ([_selectedRowIndexes isEqualToIndexSet:rows])
        return;

    var previousSelectedIndexes = _selectedRowIndexes;

    _lastSelectedRow = ([rows count] > 0) ? [rows lastIndex] : -1;
    _selectedRowIndexes = [rows copy];

    [self _updateHighlightWithOldRows:previousSelectedIndexes newRows:_selectedRowIndexes];
    [self setNeedsDisplay:YES]; // FIXME: should be setNeedsDisplayInRect:enclosing rect of new (de)selected rows
                              // but currently -drawRect: is not implemented here

    var binderClass = [[self class] _binderClassForBinding:@"selectionIndexes"];
    [[binderClass getBinding:@"selectionIndexes" forObject:self] reverseSetValueFor:@"selectedRowIndexes"];

    [self _noteSelectionDidChange];
    // CPLog(@"%@ _lastSelectedRow: %@", self, _lastSelectedRow);
}

- (void)keyDown:(CPEvent)theEvent
{
  CPLog(@"@% keyDown %@", self, theEvent);
  // Arrow keys are associated with the numeric keypad
  // if ([theEvent modifierFlags] & CPNumericPadKeyMask) {
  //   CPLog(@"MIBrowser arrow key");
  //   [self interpretKeyEvents:[CPArray arrayWithObject:theEvent]];
  // } else {
    // [super keyDown:theEvent];
  // }

    var column = [self selectedColumn];
    if (column === -1)
        return;

    // [_tableViews[column] keyDown:theEvent];

    var character = [theEvent charactersIgnoringModifiers],
        modifierFlags = [theEvent modifierFlags];

    // Check for the key events manually, as opossed to waiting for CPWindow to sent the actual actio message
    // in _processKeyboardUIKey:, because we might not want to handle the arrow events.
    if (character === CPUpArrowFunctionKey || character === CPDownArrowFunctionKey)
      {
	// CPLog(@"up/down arrow");
        // We're not interested in the arrow keys if there are no rows.
        // Technically we should also not be interested if we can't scroll,
        // but Cocoa doesn't handle that situation either.

	// NB:  default CPBrowser.moveUp implementation cannot handle multiple selection

      [self interpretKeyEvents:[CPArray arrayWithObject:theEvent]];
      return;

        if ([self numberOfRows] !== 0)
	  {
            [super _moveSelectionWithEvent:theEvent upward:(character === CPUpArrowFunctionKey)];
	    var selectedRow = [self selectedRow],
	      selectedRowIndexes = [self selectedRowIndexes],
	      selectedCol = [self selectedColumn],
	      selectedColIndices = [self selectedColumnIndexes];

	    if ([selectedRowIndexes count] > 0)
	      {
		var extend = (([theEvent modifierFlags] & CPShiftKeyMask) && _allowsMultipleSelection),
		  i = [self selectedRow];

	      }
            // return;
	  }
	// [self setLastColumn:columnIndex];
	// if (selectedRow >= 0)
	//   // [_browser addColumn];
	// [_browser doClick:_browser];

	// var selectedIndexes = [aTableView selectedRowIndexes];
	var selectedIndexes = [self selectedRowIndexes],
	  _b = [_delegate _browser];
	_i = [_delegate _index];
    
	[_b _column:_i clickedRow:[selectedIndexes count] === 1 ? [selectedIndexes firstIndex] : -1];

	return;
      }
    else if (character === CPDeleteCharacter || character === CPDeleteFunctionKey)
    {
      // CPLog(@"delete");
        if ([self _sendDelegateDeleteKeyPressed])
            return;
    }
    else if (character === CPLeftArrowFunctionKey || character === CPRightArrowFunctionKey)
    {
      // CPLog(@"left/right arrow");
      [self interpretKeyEvents:[CPArray arrayWithObject:theEvent]];
      return;
    }
    else {
      // CPLog(@"    ....other key event %@", theEvent);
      [self interpretKeyEvents:[CPArray arrayWithObject:theEvent]];
    }

    // [super keyDown:theEvent];
}

// //{DEBUG
// - (void)interpretKeyEvents:(CPArray)events
// {
//   CPLog(@"interpretKeyEvents %@", events);
//     var index = 0,
//         count = [events count];
//     CPLog(@"event count %@", count);
//     for (; index < count; ++index)
//     {
//       var event = events[index];
//       CPLog(@"event %@", event);
//       var et = [event type];
//       CPLog(@"event type %@", et);
//       var modifierFlags = [event modifierFlags];
//       CPLog(@"modifierFlags %@", modifierFlags);
//       var character = [event charactersIgnoringModifiers];
//       CPLog(@"char %@", character);
//       var selectorNames = [CPKeyBinding selectorsForKey:character modifierFlags:modifierFlags];
//       CPLog(@"selector names %@", selectorNames);

//         if (selectorNames)
//         {
//             for (var s = 0, scount = selectorNames.length; s < scount; s++)
//             {
//                 var selector = selectorNames[s];
//                 if (!selector)
//                     continue;
// 		CPLog(@"sending doCommandBySelector %@", selector);
//                 [self doCommandBySelector:CPSelectorFromString(selector)];
//             }
//         }
//         else if (!(modifierFlags & (CPCommandKeyMask | CPControlKeyMask)) && [self respondsToSelector:@selector(insertText:)]) {
// 	  CPLog(@"insertText %@", [event characters]);
// 	  [self insertText:[event characters]];
// 	}
//     }
// }
// //DEBUG}

- (void)moveUp:(id)sender
{
  // CPLog(@"%@ moveUp", self);
    // [super moveUp:sender];
  var newRow = [self selectedRow] - 1;
  if (newRow < 0) {
    newRow = 0;
  }
  // CPLog(@"newRow %@", newRow);
  var _b = [_delegate _browser];
  [_b selectRow:newRow inColumn:[_b selectedColumn]];
  [_b _column:[_b selectedColumn] clickedRow:newRow];
}

- (void)moveDown:(id)sender
{
  CPLog(@"%@ moveDown", self);
  var newRow = [self selectedRow] + 1;
  var rows = [self numberOfRows];
  if (newRow > rows) {
    newRow = rows;
  }
  // CPLog(@"newRow %@", newRow);
  var _b = [_delegate _browser];
  [_b selectRow:newRow inColumn:[_b selectedColumn]];
  [_b _column:[_b selectedColumn] clickedRow:newRow];
}

- (void)moveLeft:(id)sender
{
  var previousColumn = [_browser selectedColumn] - 1,
    selectedRow = [_browser selectedRowInColumn:previousColumn];
  if (previousColumn >= 0) {
    var _b = [_delegate _browser];
    [_b _column:previousColumn clickedRow:selectedRow];
  }
}

- (void)moveRight:(id)sender
{
  // CPLog(@"moveRight");
  [_browser selectRow:0 inColumn:[_browser selectedColumn] + 1];
  var _b = [_delegate _browser];
  [_b _column:[_b selectedColumn] clickedRow:0];
}

- (void)insertNewline:(id)sender
{
    // CPLog(@"%@ insertNewline", self);
  // [[CPApp mainWindow] tryToPerform:@selector(openTheDocument:) with:self];
  // main window must be CatMgr panel
  [[CPApp mainWindow] doCommandBySelector:@selector(openDocument:)];
}

// //{DEBUG
// - (CPView)browserView
// {
//     return _browser;
// }

// - (BOOL)canDragRowsWithIndexes:(CPIndexSet)rowIndexes atPoint:(CGPoint)mouseDownPoint
// {
//     return [_browser canDragRowsWithIndexes:rowIndexes inColumn:[_browser columnOfTableView:self] withEvent:[CPApp currentEvent]];
// }

// - (CPImage)dragImageForRowsWithIndexes:(CPIndexSet)dragRows tableColumns:(CPArray)theTableColumns event:(CPEvent)dragEvent offset:(CPPointPointer)dragImageOffset
// {
//     return [_browser draggingImageForRowsWithIndexes:dragRows inColumn:[_browser columnOfTableView:self] withEvent:dragEvent offset:dragImageOffset] ||
//            [super dragImageForRowsWithIndexes:dragRows tableColumns:theTableColumns event:dragEvent offset:dragImageOffset];
// }

// - (CPView)dragViewForRowsWithIndexes:(CPIndexSet)dragRows tableColumns:(CPArray)theTableColumns event:(CPEvent)dragEvent offset:(CPPoint)dragViewOffset
// {
//     var count = theTableColumns.length;
//     while (count--)
//     {
//         if ([theTableColumns[count] identifier] === "Leaf")
//             [theTableColumns removeObject:theTableColumns[count]];
//     }

//     return [_browser draggingViewForRowsWithIndexes:dragRows inColumn:[_browser columnOfTableView:self] withEvent:dragEvent offset:dragViewOffset] ||
//            [super dragViewForRowsWithIndexes:dragRows tableColumns:theTableColumns event:dragEvent offset:dragViewOffset];
// }


// ////////////////
// // _CPBrowserTableDelegate method
// // - (void)_tableViewClicked:(CPTableView)aTableView
// // {
// //     var selectedIndexes = [aTableView selectedRowIndexes];
// //     [_browser _column:_index clickedRow:[selectedIndexes count] === 1 ? [selectedIndexes firstIndex] : -1];
// // }



// - (void)_moveSelectionWithEvent:(CPEvent)theEvent rightward:(BOOL)shouldGoRightward
// {
//     if (_implementedDelegateMethods & CPTableViewDelegate_selectionShouldChangeInTableView_ && ![_delegate selectionShouldChangeInTableView:self])
//         return;
//     var selectedIndexes = [self selectedRowIndexes];

//     if ([selectedIndexes count] > 0)
//     {
//         var extend = (([theEvent modifierFlags] & CPShiftKeyMask) && _allowsMultipleSelection),
//             i = [self selectedRow];

//         shouldGoUpward ? i-- : i++;
//     }
//     else
//     {
//         var extend = NO;
//         //no rows are currently selected
//         if ([self numberOfRows] > 0)
//             var i = shouldGoUpward ? [self numberOfRows] - 1 : 0; // if we select upward select the last row, otherwise select the first row
//     }

//     if (i >= [self numberOfRows] || i < 0)
//         return;


//     if (_implementedDelegateMethods & CPTableViewDelegate_tableView_shouldSelectRow_)
//     {

//         while (![_delegate tableView:self shouldSelectRow:i] && (i < [self numberOfRows] || i > 0))
//             shouldGoUpward ? i-- : i++; //check to see if the row can be selected if it can't be then see if the next row can be selected

//         //if the index still can be selected after the loop then just return
//          if (![_delegate tableView:self shouldSelectRow:i])
//              return;
//     }

//     // if we go upward and see that this row is already selected we should deselect the row below
//     if ([selectedIndexes containsIndex:i] && extend)
//     {
//         // the row we're on is the last to be selected
//         var differedLastSelectedRow = i;

//         // no remove the one before/after it
//         shouldGoUpward ? i++  : i--;

//         [selectedIndexes removeIndex:i];

//         //we're going to replace the selection
//         extend = NO;
//     }
//     else if (extend)
//     {
//         if ([selectedIndexes containsIndex:i])
//         {
//             i = shouldGoUpward ? [selectedIndexes firstIndex] -1 : [selectedIndexes lastIndex] + 1;
//             i = MIN(MAX(i,0), [self numberOfRows] - 1);
//         }

//         [selectedIndexes addIndex:i];
//         var differedLastSelectedRow = i;
//     }
//     else
//     {
//         selectedIndexes = [CPIndexSet indexSetWithIndex:i];
//         var differedLastSelectedRow = i;
//     }

//     [self selectRowIndexes:selectedIndexes byExtendingSelection:extend];

//     // we differ because selectRowIndexes: does its own thing which would set the wrong index
//     _lastSelectedRow = differedLastSelectedRow;

//     if (i !== CPNotFound)
//         [self scrollRowToVisible:i];
// }
// //DEBUG}


//DEBUG
- (void)reloadData
{
  // CPLog(@"%@ reloadData", self);
    //if (!_dataSource)
    //    return;

    _reloadAllRows = YES;
    _objectValues = { };
    _cachedRowHeights = [];

    // Otherwise, if we have a row marked as group with a
    // index greater than the new number or rows
    // it keeps the the graphical group style.
    [_groupRows removeAllIndexes];

    // This updates the size too.
    [self noteNumberOfRowsChanged];

    [self setNeedsLayout];
    [self setNeedsDisplay:YES];
}
//DEBUG

@end

