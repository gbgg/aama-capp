/*
 * MIDoclet.j
 *
 * Created by Gregg Reynolds.
 * Copyright 2011 MobileInk
 *
 * A lightweight "doclet" class, based on CPDocument.j
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

// @import "CPApplication.j"
// @import "CPResponder.j"
// @import "CPViewController.j"
// @import "MIDocletController.j"

// @import <Foundation/CPString.j>
// @import <Foundation/CPArray.j>

// @import "CPApplication.j"
// @import "CPResponder.j"
// @import "CPViewController.j"

/*
    @global
    @group CPSaveOperationType
*/
CPSaveOperation             = 0;
/*
    @global
    @group CPSaveOperationType
*/
CPSaveAsOperation           = 1;
/*
    @global
    @group CPSaveOperationType
*/
CPSaveToOperation           = 2;
/*
    @global
    @group CPSaveOperationType
*/
CPAutosaveOperation         = 3;

/*
    @global
    @group MIDocletChangeType
*/
CPChangeDone                = 0;
/*
    @global
    @group MIDocletChangeType
*/
CPChangeUndone              = 1;
/*
    @global
    @group MIDocletChangeType
*/
CPChangeCleared             = 2;
/*
    @global
    @group MIDocletChangeType
*/
CPChangeReadOtherContents   = 3;
/*
    @global
    @group MIDocletChangeType
*/
CPChangeAutosaved           = 4;

MIDocletWillSaveNotification      = @"MIDocletWillSaveNotification";
MIDocletDidSaveNotification       = @"MIDocletDidSaveNotification";
MIDocletDidFailToSaveNotification = @"MIDocletDidFailToSaveNotification";

var MIDocletUntitledCount = 0;

/*!
    @ingroup appkit
    @class MIDoclet

    MIDoclet is used to represent a doclet/file in a Cappuccino application.
    In a document-based application, generally multiple documents are open simultaneously
    (multiple text documents, slide presentations, spreadsheets, etc.), and multiple
    MIDoclets should be used to represent this.
*/
@implementation MIDoclet : CPResponder
{
  // CPWindow            _window; // For outlet purposes.
  CPView              _view; // For outlet purposes
  CPArray             _viewControllers;

  // CPDictionary        _viewControllersForWindowControllers;

    CPURL               _fileURL;
    CPString            _fileType;
    unsigned            _untitledDocletIndex;

    BOOL                _hasUndoManager;
    CPUndoManager       _undoManager;

    int                 _changeCount;

    CPURLConnection     _readConnection;
    CPURLRequest        _writeRequest;

    CPAlert             _canCloseAlert;
}

/*!
    Initializes an empty doclet.
    @return the initialized doclet
*/
- (id)init
{
    self = [super init];

    if (self)
    {
        _viewControllers = [];
        // _viewControllersForWindoCwontrollers = [CPDictionary dictionary];

        _hasUndoManager = YES;
        _changeCount = 0;

        [self setNextResponder:CPApp];
    }

    return self;
}

/*!
    Initializes the doclet with a specific data type.
    @param aType the type of doclet to initialize
    @param anError not used
    @return the initialized doclet
*/
- (id)initWithType:(CPString)aType error:({CPError})anError
{
    self = [self init];

    if (self)
        [self setFileType:aType];

    return self;
}

/*!
    Initializes a doclet of a specific type located at a URL. Notifies
    the provided delegate after initialization.
    @param anAbsoluteURL the url of the doclet content
    @param aType the type of doclet located at the URL
    @param aDelegate the delegate to notify
    @param aDidReadSelector the selector used to notify the delegate
    @param aContextInfo context information passed to the delegate
    after initialization
    @return the initialized doclet
*/
- (id)initWithContentsOfURL:(CPURL)anAbsoluteURL ofType:(CPString)aType delegate:(id)aDelegate didReadSelector:(SEL)aDidReadSelector contextInfo:(id)aContextInfo
{
    self = [self init];

    if (self)
    {
        [self setFileURL:anAbsoluteURL];
        [self setFileType:aType];

        [self readFromURL:anAbsoluteURL ofType:aType delegate:aDelegate didReadSelector:aDidReadSelector contextInfo:aContextInfo];
    }

    return self;
}

/*!
    Initializes the doclet from a URL.
    @param anAbsoluteURL the doclet location
    @param absoluteContentsURL the location of the doclet's contents
    @param aType the type of the contents
    @param aDelegate this object will receive a callback after the doclet's contents are loaded
    @param aDidReadSelector the message selector that will be sent to \c aDelegate
    @param aContextInfo passed as the argument to the message sent to the \c aDelegate
    @return the initialized doclet
*/
- (id)initForURL:(CPURL)anAbsoluteURL withContentsOfURL:(CPURL)absoluteContentsURL ofType:(CPString)aType delegate:(id)aDelegate didReadSelector:(SEL)aDidReadSelector contextInfo:(id)aContextInfo
{
    self = [self init];

    if (self)
    {
        [self setFileURL:anAbsoluteURL];
        [self setFileType:aType];

        [self readFromURL:absoluteContentsURL ofType:aType delegate:aDelegate didReadSelector:aDidReadSelector contextInfo:aContextInfo];
    }

    return self;
}

/*!
    Returns the receiver's data in a specified type. The default implementation just
    throws an exception.
    @param aType the format of the data
    @param anError not used
    @throws CPUnsupportedMethodException if this method hasn't been overridden by the subclass
    @return the doclet data
*/
- (CPData)dataOfType:(CPString)aType error:({CPError})anError
{
    [CPException raise:CPUnsupportedMethodException
                reason:"dataOfType:error: must be overridden by the doclet subclass."];
}

/*!
    Sets the content of the doclet by reading the provided
    data. The default implementation just throws an exception.
    @param aData the doclet's data
    @param aType the doclet type
    @param anError not used
    @throws CPUnsupportedMethodException if this method hasn't been
    overridden by the subclass
*/
- (void)readFromData:(CPData)aData ofType:(CPString)aType error:(CPError)anError
{
    [CPException raise:CPUnsupportedMethodException
                reason:"readFromData:ofType: must be overridden by the doclet subclass."];
}

- (void)viewControllerWillLoadCib:(CPViewController)aViewController
{
}

- (void)viewControllerDidLoadCib:(CPViewController)aViewController
{
}

- (CPViewController)firstEligibleExistingViewController
{
    return nil;
}

// Creating and managing view controllers
/*!
    Creates the view controller for this doclet.
*/
// - (void)makeViewControllers
// {
//     [self makeViewAndWindowControllers];
// }

////////////////////////////////////////////////////////////////
- (void)makeViewControllers
{
  CPLog(@"%@: makeViewControllers", self);
}

- (void)addViewController:(CPViewController)theViewController
{
  CPLog(@"%@: addViewController: %@", self, theViewController);
  [_viewControllers addObject:theViewController];

  if ([theViewController doclet] !== self)
    [theViewController setDoclet:self];
    
  //TODO: creating the view and adding it to the window should be in addViewController?
  // var win = [[[self theDocument] _docWinController] window];
  CPLog(@"/%@: addViewController: %@", self, theViewController);
}

/*!
    Returns the doclet's view controllers
*/
- (CPArray)viewControllers
{
    return _viewControllers;
}

/*!
    Add a controller to the doclet's list of controllers. This should
    be called after making a new view controller.
    @param aViewController the controller to add
*/
- (void)addViewController:(CPViewController)aViewController
{
    [_viewControllers addObject:aViewController];

    if ([aViewController doclet] !== self)
        [aViewController setDoclet:self];
}

/*!
    Remove a controller to the doclet's list of controllers. This should
    be called after closing the controller's view.
    @param aViewController the controller to remove
*/
- (void)removeViewController:(CPViewController)aViewController
{
    if (aViewController)
        [_viewControllers removeObject:aViewController];

    if ([aViewController doclet] === self)
        [aViewController setDoclet:nil];
}

- (CPView)view
{
    return _view;
}

- (CPArray)viewControllers
{
    // return [_viewControllersForWindowControllers allValues];
}

- (void)addViewController:(CPViewController)aViewController forWindowController:(CPWindowController)aWindowController
{
    // FIXME: exception if we don't own the window controller?
    [_viewControllersForWindowControllers setObject:aViewController forKey:[aWindowController UID]];

    if ([aWindowController doclet] === self)
        [aWindowController setViewController:aViewController];
}

- (void)removeViewController:(CPViewController)aViewController
{
    [_viewControllersForWindowControllers removeObject:aViewController];
}

- (CPViewController)viewControllerForWindowController:(CPWindowController)aWindowController
{
    return [_viewControllersForWindowControllers objectForKey:[aWindowController UID]];
}

// Managing Doclet views
/*!
    Shows all the doclet's views.
*/
- (void)showViews
{
    [_viewControllers makeObjectsPerformSelector:@selector(setDoclet:) withObject:self];
    [_viewControllers makeObjectsPerformSelector:@selector(showView:) withObject:self];
}

/*!
    Returns the name of the doclet as displayed in the title bar.
*/
- (CPString)displayName
{
    if (_fileURL)
        return [_fileURL lastPathComponent];

    if (!_untitledDocletIndex)
        _untitledDocletIndex = ++MIDocletUntitledCount;

    if (_untitledDocletIndex == 1)
       return @"Untitled";

    return @"Untitled " + _untitledDocletIndex;
}

- (CPString)viewCibName
{
    return nil;
}

/*!
    Returns the doclet's Cib name
*/
// - (CPString)viewCibName
// {
//     return nil;
// }

/*!
    Called after \c aViewController loads the doclet's Nib file.
    @param aWindowController the controller that loaded the Nib file
*/
// - (void)windowControllerDidLoadCib:(CPWindowController)aWindowController
// {
// }

/*!
    Called before \c aWindowController will load the doclet's Nib file.
    @param aWindowController the controller that will load the Nib file
*/
// - (void)windowControllerWillLoadCib:(CPWindowController)aWindowController
// {
// }

// Reading from and Writing to URLs
/*!
    Set the doclet's data from a URL. Notifies the provided delegate afterwards.
    @param anAbsoluteURL the URL to the doclet's content
    @param aType the doclet type
    @param aDelegate delegate to notify after reading the data
    @param aDidReadSelector message that will be sent to the delegate
    @param aContextInfo context information that gets sent to the delegate
*/
- (void)readFromURL:(CPURL)anAbsoluteURL ofType:(CPString)aType delegate:(id)aDelegate didReadSelector:(SEL)aDidReadSelector contextInfo:(id)aContextInfo
{
    [_readConnection cancel];

    // FIXME: Oh man is this every looking for trouble, we need to handle login at the Cappuccino level, with HTTP Errors.
    _readConnection = [CPURLConnection connectionWithRequest:[CPURLRequest requestWithURL:anAbsoluteURL] delegate:self];

    _readConnection.session = _CPReadSessionMake(aType, aDelegate, aDidReadSelector, aContextInfo);
}

/*!
    Returns the path to the doclet's file.
*/
- (CPURL)fileURL
{
    return _fileURL;
}

/*!
    Sets the path to the doclet's file.
    @param aFileURL the path to the doclet's file
*/
- (void)setFileURL:(CPURL)aFileURL
{
    if (_fileURL === aFileURL)
        return;

    _fileURL = aFileURL;

    [_viewControllers makeObjectsPerformSelector:@selector(synchronizeViewTitleWithDocletName)];
}

/*!
    Saves the doclet to the specified URL. Notifies the provided delegate
    with the provided selector and context info afterwards.
    @param anAbsoluteURL the url to write the doclet data to
    @param aTypeName the doclet type
    @param aSaveOperation the type of save operation
    @param aDelegate the delegate to notify after saving
    @param aDidSaveSelector the selector to send the delegate
    @param aContextInfo context info that gets passed to the delegate
*/
- (void)saveToURL:(CPURL)anAbsoluteURL ofType:(CPString)aTypeName forSaveOperation:(CPSaveOperationType)aSaveOperation delegate:(id)aDelegate didSaveSelector:(SEL)aDidSaveSelector contextInfo:(id)aContextInfo
{
    var data = [self dataOfType:[self fileType] error:nil],
        oldChangeCount = _changeCount;

    _writeRequest = [CPURLRequest requestWithURL:anAbsoluteURL];

    // FIXME: THIS IS WRONG! We need a way to decide
    if ([CPPlatform isBrowser])
        [_writeRequest setHTTPMethod:@"POST"];
    else
        [_writeRequest setHTTPMethod:@"PUT"];

    [_writeRequest setHTTPBody:[data rawString]];

    [_writeRequest setValue:@"close" forHTTPHeaderField:@"Connection"];

    if (aSaveOperation === CPSaveOperation)
        [_writeRequest setValue:@"true" forHTTPHeaderField:@"x-cappuccino-overwrite"];

    if (aSaveOperation !== CPSaveToOperation)
        [self updateChangeCount:CPChangeCleared];

    // FIXME: Oh man is this every looking for trouble, we need to handle login at the Cappuccino level, with HTTP Errors.
    var connection = [CPURLConnection connectionWithRequest:_writeRequest delegate:self];

    connection.session = _CPSaveSessionMake(anAbsoluteURL, aSaveOperation, oldChangeCount, aDelegate, aDidSaveSelector, aContextInfo, connection);
}

/*
    Implemented as a delegate method for CPURLConnection
    @ignore
*/
- (void)connection:(CPURLConnection)aConnection didReceiveResponse:(CPURLResponse)aResponse
{
    // If we got this far and it wasn't an HTTP request, then everything is fine.
    if (![aResponse isKindOfClass:[CPHTTPURLResponse class]])
        return;

    var statusCode = [aResponse statusCode];

    // Nothing to do if everything is hunky dory.
    if (statusCode === 200)
        return;

    var session = aConnection.session;

    if (aConnection == _readConnection)
    {
        [aConnection cancel];

        alert("There was an error retrieving the doclet.");

        objj_msgSend(session.delegate, session.didReadSelector, self, NO, session.contextInfo);
    }
    else
    {
        // 409: Conflict, in Cappuccino, overwrite protection for doclets.
        if (statusCode == 409)
        {
            [aConnection cancel];

            if (confirm("There already exists a file with that name, would you like to overwrite it?"))
            {
                [_writeRequest setValue:@"true" forHTTPHeaderField:@"x-cappuccino-overwrite"];

                [aConnection start];
            }
            else
            {
                if (session.saveOperation != CPSaveToOperation)
                {
                    _changeCount += session.changeCount;
                    [_viewControllers makeObjectsPerformSelector:@selector(setDocletEdited:) withObject:[self isDocletEdited]];
                }

                _writeRequest = nil;

                objj_msgSend(session.delegate, session.didSaveSelector, self, NO, session.contextInfo);
                [self _sendDocletSavedNotification:NO];
            }
        }
    }
}

/*
    Implemented as a delegate method for CPURLConnection
    @ignore
*/
- (void)connection:(CPURLConnection)aConnection didReceiveData:(CPString)aData
{
    var session = aConnection.session;

    // READ
    if (aConnection == _readConnection)
    {
        [self readFromData:[CPData dataWithRawString:aData] ofType:session.fileType error:nil];

        objj_msgSend(session.delegate, session.didReadSelector, self, YES, session.contextInfo);
    }
    else
    {
        if (session.saveOperation != CPSaveToOperation)
            [self setFileURL:session.absoluteURL];

        _writeRequest = nil;

        objj_msgSend(session.delegate, session.didSaveSelector, self, YES, session.contextInfo);
        [self _sendDocletSavedNotification:YES];
    }
}

/*
    Implemented as a delegate method for CPURLConnection
    @ignore
*/
- (void)connection:(CPURLConnection)aConnection didFailWithError:(CPError)anError
{
    var session = aConnection.session;

    if (_readConnection == aConnection)
        objj_msgSend(session.delegate, session.didReadSelector, self, NO, session.contextInfo);

    else
    {
        if (session.saveOperation != CPSaveToOperation)
        {
            _changeCount += session.changeCount;
            [_viewControllers makeObjectsPerformSelector:@selector(setDocletEdited:) withObject:[self isDocletEdited]];
        }

        _writeRequest = nil;

        alert("There was an error saving the doclet.");

        objj_msgSend(session.delegate, session.didSaveSelector, self, NO, session.contextInfo);
        [self _sendDocletSavedNotification:NO];
    }
}

/*
    Implemented as a delegate method for CPURLConnection
    @ignore
*/
- (void)connectionDidFinishLoading:(CPURLConnection)aConnection
{
    if (_readConnection == aConnection)
        _readConnection = nil;
}

// Managing Doclet Status
/*!
    Returns \c YES if there are any unsaved changes.
*/
- (BOOL)isDocletEdited
{
    return _changeCount != 0;
}

/*!
    Updates the number of unsaved changes to the doclet.
    @param aChangeType a new doclet change to apply
*/
- (void)updateChangeCount:(MIDocletChangeType)aChangeType
{
    if (aChangeType == CPChangeDone)
        ++_changeCount;
    else if (aChangeType == CPChangeUndone)
        --_changeCount;
    else if (aChangeType == CPChangeCleared)
        _changeCount = 0;
    /*else if (aChangeType == CPCHangeReadOtherContents)

    else if (aChangeType == CPChangeAutosaved)*/

    [_viewControllers makeObjectsPerformSelector:@selector(setDocletEdited:) withObject:[self isDocletEdited]];
}

// Managing File Types
/*!
    Sets the doclet's file type
    @param aType the doclet's type
*/
- (void)setFileType:(CPString)aType
{
    _fileType = aType;
}

/*!
    Returns the doclet's file type
*/
- (CPString)fileType
{
    return _fileType;
}

// Working with Undo Manager
/*!
    Returns \c YES if the doclet has a
    CPUndoManager.
*/
- (BOOL)hasUndoManager
{
    return _hasUndoManager;
}

/*!
    Sets whether the doclet should have a CPUndoManager.
    @param aFlag \c YES makes the doclet have an undo manager
*/
- (void)setHasUndoManager:(BOOL)aFlag
{
    if (_hasUndoManager == aFlag)
        return;

    _hasUndoManager = aFlag;

    if (!_hasUndoManager)
        [self setUndoManager:nil];
}

/* @ignore */
- (void)_undoManagerWillCloseGroup:(CPNotification)aNotification
{
    var undoManager = [aNotification object];

    if ([undoManager isUndoing] || [undoManager isRedoing])
        return;

    [self updateChangeCount:CPChangeDone];
}

/* @ignore */
- (void)_undoManagerDidUndoChange:(CPNotification)aNotification
{
    [self updateChangeCount:CPChangeUndone];
}

/* @ignore */
- (void)_undoManagerDidRedoChange:(CPNotification)aNotification
{
    [self updateChangeCount:CPChangeDone];
}

/*
    Sets the doclet's undo manager. This method will add the
    undo manager as an observer to the notification center.
    @param anUndoManager the new undo manager for the doclet
*/
- (void)setUndoManager:(CPUndoManager)anUndoManager
{
    var defaultCenter = [CPNotificationCenter defaultCenter];

    if (_undoManager)
    {
        [defaultCenter removeObserver:self
                                 name:CPUndoManagerDidUndoChangeNotification
                               object:_undoManager];

        [defaultCenter removeObserver:self
                                 name:CPUndoManagerDidRedoChangeNotification
                               object:_undoManager];

        [defaultCenter removeObserver:self
                                 name:CPUndoManagerWillCloseUndoGroupNotification
                               object:_undoManager];
    }

    _undoManager = anUndoManager;

    if (_undoManager)
    {

        [defaultCenter addObserver:self
                          selector:@selector(_undoManagerDidUndoChange:)
                              name:CPUndoManagerDidUndoChangeNotification
                            object:_undoManager];

        [defaultCenter addObserver:self
                          selector:@selector(_undoManagerDidRedoChange:)
                              name:CPUndoManagerDidRedoChangeNotification
                            object:_undoManager];

        [defaultCenter addObserver:self
                          selector:@selector(_undoManagerWillCloseGroup:)
                              name:CPUndoManagerWillCloseUndoGroupNotification
                            object:_undoManager];
    }
}

/*!
    Returns the doclet's undo manager. If the doclet
    should have one, but the manager is \c nil, it
    will be created and then returned.
    @return the doclet's undo manager
*/
- (CPUndoManager)undoManager
{
    if (_hasUndoManager && !_undoManager)
        [self setUndoManager:[[CPUndoManager alloc] init]];

    return _undoManager;
}

/*
    Implemented as a delegate of a CPView
    @ignore
*/
- (CPUndoManager)viewWillReturnUndoManager:(CPView)aView
{
    return [self undoManager];
}

// Handling User Actions
/*!
    Saves the doclet. If the doclet does not
    have a file path to save to (\c fileURL)
    then \c -saveDocletAs: will be called.
    @param aSender the object requesting the save
*/
- (void)saveDoclet:(id)aSender
{
    [self saveDocletWithDelegate:nil didSaveSelector:nil contextInfo:nil];
}

- (void)saveDocletWithDelegate:(id)delegate didSaveSelector:(SEL)didSaveSelector contextInfo:(Object)contextInfo
{
    if (_fileURL)
    {
        [[CPNotificationCenter defaultCenter]
            postNotificationName:MIDocletWillSaveNotification
                          object:self];

        [self saveToURL:_fileURL ofType:[self fileType] forSaveOperation:CPSaveOperation delegate:delegate didSaveSelector:didSaveSelector contextInfo:contextInfo];
    }
    else
        [self _saveDocletAsWithDelegate:delegate didSaveSelector:didSaveSelector contextInfo:contextInfo];
}

/*!
    Saves the doclet to a user specified path.
    @param aSender the object requesting the operation
*/
- (void)saveDocletAs:(id)aSender
{
    [self _saveDocletAsWithDelegate:nil didSaveSelector:nil contextInfo:nil];
}

- (void)_saveDocletAsWithDelegate:(id)delegate didSaveSelector:(SEL)didSaveSelector contextInfo:(Object)contextInfo
{
    var savePanel = [CPSavePanel savePanel],
        response = [savePanel runModal];

    if (!response)
        return;

    var saveURL = [savePanel URL];

    [[CPNotificationCenter defaultCenter]
        postNotificationName:MIDocletWillSaveNotification
                      object:self];

    [self saveToURL:saveURL ofType:[self fileType] forSaveOperation:CPSaveAsOperation delegate:delegate didSaveSelector:didSaveSelector contextInfo:contextInfo];
}

/*
    @ignore
*/
- (void)_sendDocletSavedNotification:(BOOL)didSave
{
    if (didSave)
        [[CPNotificationCenter defaultCenter]
            postNotificationName:MIDocletDidSaveNotification
                          object:self];
    else
        [[CPNotificationCenter defaultCenter]
            postNotificationName:MIDocletDidFailToSaveNotification
                          object:self];
}

@end

@implementation MIDoclet (ClosingDoclets)

- (void)close
{
    [_viewControllers makeObjectsPerformSelector:@selector(removeDocletAndCloseIfNecessary:) withObject:self];
    [[MIDocletController sharedDocletController] removeDoclet:self];
}

- (void)shouldCloseViewController:(CPViewController)controller delegate:(id)delegate shouldCloseSelector:(SEL)selector contextInfo:(Object)info
{
    if ([controller shouldCloseDoclet] || ([_viewControllers count] < 2 && [_viewControllers indexOfObject:controller] !== CPNotFound))
        [self canCloseDocletWithDelegate:self shouldCloseSelector:@selector(_doclet:shouldClose:context:) contextInfo:{delegate:delegate, selector:selector, context:info}];

    else if ([delegate respondsToSelector:selector])
        objj_msgSend(delegate, selector, self, YES, info);
}

- (void)_doclet:(MIDoclet)aDoclet shouldClose:(BOOL)shouldClose context:(Object)context
{
    if (aDoclet === self && shouldClose)
        [self close];

    objj_msgSend(context.delegate, context.selector, aDoclet, shouldClose, context.context);
}

- (void)canCloseDocletWithDelegate:(id)aDelegate shouldCloseSelector:(SEL)aSelector contextInfo:(Object)context
{
    if (![self isDocletEdited])
        return [aDelegate respondsToSelector:aSelector] && objj_msgSend(aDelegate, aSelector, self, YES, context);

    _canCloseAlert = [[CPAlert alloc] init];

    [_canCloseAlert setDelegate:self];
    [_canCloseAlert setAlertStyle:CPWarningAlertStyle];
    [_canCloseAlert setTitle:@"Unsaved Doclet"];
    [_canCloseAlert setMessageText:@"Do you want to save the changes you've made to the doclet \"" + ([self displayName] || [self fileName]) + "\"?"];

    [_canCloseAlert addButtonWithTitle:@"Save"];
    [_canCloseAlert addButtonWithTitle:@"Cancel"];
    [_canCloseAlert addButtonWithTitle:@"Don't Save"];

    _canCloseAlert._context = {delegate:aDelegate, selector:aSelector, context:context};

    [_canCloseAlert runModal];
}

- (void)alertDidEnd:(CPAlert)alert returnCode:(int)returnCode
{
    if (alert !== _canCloseAlert)
        return;

    var delegate = alert._context.delegate,
        selector = alert._context.selector,
        context = alert._context.context;

    if (returnCode === 0)
        [self saveDocletWithDelegate:delegate didSaveSelector:selector contextInfo:context];
    else
        objj_msgSend(delegate, selector, self, returnCode === 2, context);

    _canCloseAlert = nil;
}

@end

var _CPReadSessionMake = function(aType, aDelegate, aDidReadSelector, aContextInfo)
{
    return { fileType:aType, delegate:aDelegate, didReadSelector:aDidReadSelector, contextInfo:aContextInfo };
}

var _CPSaveSessionMake = function(anAbsoluteURL, aSaveOperation, aChangeCount, aDelegate, aDidSaveSelector, aContextInfo, aConnection)
{
    return { absoluteURL:anAbsoluteURL, saveOperation:aSaveOperation, changeCount:aChangeCount, delegate:aDelegate, didSaveSelector:aDidSaveSelector, contextInfo:aContextInfo, connection:aConnection };
}
