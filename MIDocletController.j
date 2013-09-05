/*
 * MIDocletController.j
 * AppKit
 *
 * Created by Gregg Reynolds.
 * Copyright 2011, MobileInk
 *
 * modeled on CPDocumentController.j
 * Created by Francisco Tolmasky.
 * Copyright 2008, 280 North, Inc.
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

// @import "CPDocument.j"
// @import "CPOpenPanel.j"


var CPSharedDocletController = nil;

/*!
    @ingroup appkit
    @class MIDocletController
    This class is responsible for managing an document's open doclets.
*/
@implementation MIDocletController : CPObject
{
    CPArray _doclets;
    CPArray _docletTypes;
}

/*!
    Returns the singleton instance of the document's doclet controller. If it has not
    been created yet, it will be created then returned.
    @return a MIDocletController
*/
+ (id)sharedDocletController
{
    if (!CPSharedDocletController)
        [[self alloc] init];

    return CPSharedDocletController;
}

/*
    @ignore
*/
- (id)init
{
    self = [super init];

    if (self)
    {
        _doclets = [[CPArray alloc] init];

        if (!CPSharedDocletController)
            CPSharedDocletController = self;

        _docletTypes = [[[CPBundle mainBundle] infoDictionary] objectForKey:@"CPBundleDocletTypes"];
    }
    return self;
}

// Creating and Opening Doclets

/*!
    Returns the doclet matching the specified URL. This
    method searches doclets already open. It does not
    open the doclet at the URL if it is not already open.
    @param aURL the url of the doclet
    @return the doclet, or \c nil if such a doclet is not open
*/
- (MIDoclet)docletForURL:(CPURL)aURL
{
    var index = 0,
        count = [_doclets count];

    for (; index < count; ++index)
    {
        var theDoclet = _doclets[index];

        if ([[theDoclet fileURL] isEqual:aURL])
            return theDoclet;
    }

    return nil;
}

/*!
    Creates a new doclet of the specified type.
    @param aType the type of the new doclet
    @param shouldDisplay whether to display the doclet on screen
*/
- (void)openUntitledDocletOfType:(CPString)aType display:(BOOL)shouldDisplay
{
    var theDoclet = [self makeUntitledDocletOfType:aType error:nil];

    if (theDoclet)
        [self addDoclet:theDoclet];

    if (shouldDisplay)
    {
        [theDoclet makeWindowControllers];
        [theDoclet showWindows];
    }

    return theDoclet;
}

/*!
    Creates a doclet of the specified type.
    @param aType the doclet type
    @param anError not used
    @return the created doclet
*/
- (MIDoclet)makeUntitledDocletOfType:(CPString)aType error:({CPError})anError
{
    return [[[self docletClassForType:aType] alloc] initWithType:aType error:anError];
}

/*!
    Opens the doclet at the specified URL.
    @param anAbsoluteURL the path to the doclet's file
    @param shouldDisplay whether to display the doclet on screen
    @param anError not used
    @return the opened doclet
*/
- (MIDoclet)openDocletWithContentsOfURL:(CPURL)anAbsoluteURL display:(BOOL)shouldDisplay error:(CPError)anError
{
    var result = [self docletForURL:anAbsoluteURL];

    if (!result)
    {
        var type = [self typeForContentsOfURL:anAbsoluteURL error:anError];

        result = [self makeDocletWithContentsOfURL:anAbsoluteURL ofType:type delegate:self didReadSelector:@selector(doclet:didRead:contextInfo:) contextInfo:[CPDictionary dictionaryWithObject:shouldDisplay forKey:@"shouldDisplay"]];

        [self addDoclet:result];

        if (result)
            [self noteNewRecentDoclet:result];
    }
    else if (shouldDisplay)
        [result showWindows];

    return result;
}

/*!
    Loads a doclet for a specified URL with it's content
    retrieved from another URL.
    @param anAbsoluteURL the doclet URL
    @param absoluteContentsURL the location of the doclet's contents
    @param anError not used
    @return the loaded doclet or \c nil if there was an error
*/
- (MIDoclet)reopenDocletForURL:(CPURL)anAbsoluteURL withContentsOfURL:(CPURL)absoluteContentsURL error:(CPError)anError
{
    return [self makeDocletForURL:anAbsoluteURL withContentsOfURL:absoluteContentsURL  ofType:[[_docletTypes objectAtIndex:0] objectForKey:@"CPBundleTypeName"] delegate:self didReadSelector:@selector(doclet:didRead:contextInfo:) contextInfo:nil];
}

/*!
    Creates a doclet from the contents at the specified URL.
    Notifies the provided delegate with the provided selector afterwards.
    @param anAbsoluteURL the location of the doclet data
    @param aType the doclet type
    @param aDelegate the delegate to notify
    @param aSelector the selector to notify with
    @param aContextInfo the context information passed to the delegate
*/
- (MIDoclet)makeDocletWithContentsOfURL:(CPURL)anAbsoluteURL ofType:(CPString)aType delegate:(id)aDelegate didReadSelector:(SEL)aSelector contextInfo:(id)aContextInfo
{
    return [[[self docletClassForType:aType] alloc] initWithContentsOfURL:anAbsoluteURL ofType:aType delegate:aDelegate didReadSelector:aSelector contextInfo:aContextInfo];
}

/*!
    Creates a doclet from the contents of a URL, and sets
    the doclet's URL location as another URL.
    @param anAbsoluteURL the doclet's location
    @param absoluteContentsURL the location of the doclet's contents
    @param aType the doclet's data type
    @param aDelegate receives a callback after the load has completed
    @param aSelector the selector to invoke for the callback
    @param aContextInfo an object passed as an argument for the callback
    @return a new doclet or \c nil if there was an error
*/
- (MIDoclet)makeDocletForURL:(CPURL)anAbsoluteURL withContentsOfURL:(CPURL)absoluteContentsURL ofType:(CPString)aType delegate:(id)aDelegate didReadSelector:(SEL)aSelector contextInfo:(id)aContextInfo
{
    return [[[self docletClassForType:aType] alloc] initForURL:anAbsoluteURL withContentsOfURL:absoluteContentsURL ofType:aType delegate:aDelegate didReadSelector:aSelector contextInfo:aContextInfo];
}

/*
    Implemented delegate method
    @ignore
*/
- (void)doclet:(MIDoclet)aDoclet didRead:(BOOL)didRead contextInfo:(id)aContextInfo
{
    if (!didRead)
        return;

    [aDoclet makeWindowControllers];

    if ([aContextInfo objectForKey:@"shouldDisplay"])
        [aDoclet showWindows];
}

/*!
    Opens a new doclet in the application.
    @param aSender the requesting object
*/
- (CFAction)newDoclet:(id)aSender
{
    [self openUntitledDocletOfType:[[_docletTypes objectAtIndex:0] objectForKey:@"CPBundleTypeName"] display:YES];
}

- (void)openDoclet:(id)aSender
{
    // var openPanel = [CPOpenPanel openPanel];

    // [openPanel runModal];

    // var URLs = [openPanel URLs],
    //     index = 0,
    //     count = [URLs count];

    // for (; index < count; ++index)
    //     [self openDocletWithContentsOfURL:[CPURL URLWithString:URLs[index]] display:YES error:nil];
}

// Managing Doclets

/*!
    Returns the array of all doclets being managed. This is
    the same as all open doclets in the application.
*/
- (CPArray)doclets
{
    return _doclets;
}

/*!
    Adds \c aDoclet under the control of the receiver.
    @param aDoclet the doclet to add
*/
- (void)addDoclet:(MIDoclet)aDoclet
{
    [_doclets addObject:aDoclet];
}

/*!
    Removes \c aDoclet from the control of the receiver.
    @param aDoclet the doclet to remove
*/
- (void)removeDoclet:(MIDoclet)aDoclet
{
    [_doclets removeObjectIdenticalTo:aDoclet];
}

- (CPString)defaultType
{
    return [_docletTypes[0] objectForKey:@"CPBundleTypeName"];
}

- (CPString)typeForContentsOfURL:(CPURL)anAbsoluteURL error:(CPError)outError
{
    var index = 0,
        count = _docletTypes.length,

        extension = [[anAbsoluteURL pathExtension] lowercaseString],
        starType = nil;

    for (; index < count; ++index)
    {
        var docletType = _docletTypes[index],
            extensions = [docletType objectForKey:@"CFBundleTypeExtensions"],
            extensionIndex = 0,
            extensionCount = extensions.length;

        for (; extensionIndex < extensionCount; ++extensionIndex)
        {
            var thisExtension = [extensions[extensionIndex] lowercaseString];
            if (thisExtension === extension)
                return [docletType objectForKey:@"CPBundleTypeName"];

            if (thisExtension === "****")
                starType = [docletType objectForKey:@"CPBundleTypeName"];
        }
    }

    return starType || [self defaultType];
}

// Managing Doclet Types

/* @ignore */
- (CPDictionary)_infoForType:(CPString)aType
{
    var i = 0,
        count = [_docletTypes count];

    for (;i < count; ++i)
    {
        var docletType = _docletTypes[i];

        if ([docletType objectForKey:@"CPBundleTypeName"] == aType)
            return docletType;
    }

    return nil;
}

/*!
    Returns the MIDoclet subclass associated with \c aType.
    @param aType the type of doclet
    @return a Cappuccino Class object, or \c nil if no match was found
*/
- (Class)docletClassForType:(CPString)aType
{
    var className = [[self _infoForType:aType] objectForKey:@"MIDocletClass"];

    return className ? CPClassFromString(className) : nil;
}

@end

@implementation MIDocletController (Closing)

- (void)closeAllDocletsWithDelegate:(id)aDelegate didCloseAllSelector:(SEL)didCloseSelector contextInfo:(Object)info
{
    var context = {
        delegate: aDelegate,
        selector: didCloseSelector,
        context: info
    };

    [self _closeDocletsStartingWith:nil shouldClose:YES context:context];
}

// Recursive callback method. Start it by passing in a doclet of nil.
- (void)_closeDocletsStartingWith:(MIDoclet)aDoclet shouldClose:(BOOL)shouldClose context:(Object)context
{
    if (shouldClose)
    {
        [aDoclet close];

        if ([[self doclets] count] > 0)
        {
            [[[self doclets] lastObject] canCloseDocletWithDelegate:self
                                                    shouldCloseSelector:@selector(_closeDocletsStartingWith:shouldClose:context:)
                                                            contextInfo:context];
            return;
        }
    }

    if ([context.delegate respondsToSelector:context.selector])
        objj_msgSend(context.delegate, context.selector, self, [[self doclets] count] === 0, context.context);
}

@end

@implementation MIDocletController (Recents)

- (CPArray)recentDocletURLs
{
    // FIXME move this to CP land
    if (typeof window["cpRecentDocletURLs"] === 'function')
        return window.cpRecentDocletURLs();

    return [];
}

- (void)clearRecentDoclets:(id)sender
{
    if (typeof window["cpClearRecentDoclets"] === 'function')
        window.cpClearRecentDoclets();

   [self _updateRecentDocletsMenu];
}

- (void)noteNewRecentDoclet:(MIDoclet)aDoclet
{
    [self noteNewRecentDocletURL:[aDoclet fileURL]];
}

- (void)noteNewRecentDocletURL:(CPURL)aURL
{
    var urlAsString = [aURL isKindOfClass:CPString] ? aURL : [aURL absoluteString];
    if (typeof window["cpNoteNewRecentDocletPath"] === 'function')
        window.cpNoteNewRecentDocletPath(urlAsString);

   [self _updateRecentDocletsMenu];
}

- (void)_removeAllRecentDocletsFromMenu:(CPMenu)aMenu
{
    var items = [aMenu itemArray],
        count = [items count];

    while (count--)
    {
        var item = items[count];

        if ([item action] === @selector(_openRecentDoclet:))
            [aMenu removeItemAtIndex:count];
    }
}

- (void)_updateRecentDocletsMenu
{
    var menu = [[CPApp mainMenu] _menuWithName:@"_CPRecentDocletsMenu"],
        recentDoclets = [self recentDocletURLs],
        menuItems = [menu itemArray],
        docletCount = [recentDoclets count],
        menuItemCount = [menuItems count];

    [self _removeAllRecentDocletsFromMenu:menu];

    if (menuItemCount)
    {
        if (!docletCount)
        {
            if ([menuItems[0] isSeparatorItem])
                [menu removeItemAtIndex:0];
        }
        else
        {
            if (![menuItems[0] isSeparatorItem])
                [menu insertItem:[CPMenuItem separatorItem] atIndex:0];
        }
    }

    while (docletCount--)
    {
        var path = recentDoclets[docletCount],
            item = [[CPMenuItem alloc] initWithTitle:[path lastPathComponent] action:@selector(_openRecentDoclet:) keyEquivalent:nil];

        [item setTag:path];
        [menu insertItem:item atIndex:0];
    }
}

- (void)_openRecentDoclet:(id)sender
{
    [self openDocletWithContentsOfURL:[sender tag] display:YES error:nil];
}

@end
