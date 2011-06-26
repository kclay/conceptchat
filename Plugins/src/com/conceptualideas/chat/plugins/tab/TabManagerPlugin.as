package com.conceptualideas.chat.plugins.tab
{
	import com.conceptualideas.chat.events.ChatClientManagerEvent;
	import com.conceptualideas.chat.events.ChatScreenContextEvent;
	import com.conceptualideas.chat.interfaces.IChatClient;
	import com.conceptualideas.chat.interfaces.IScreenContext;
	import com.conceptualideas.chat.plugins.AbstractChatPlugin;
	import com.conceptualideas.chat.plugins.tab.events.TabEvent;

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.Dictionary;

	import mx.core.INavigatorContent;
	import mx.core.ISelectableList;
	import mx.core.IVisualElement;
	import mx.events.ChildExistenceChangedEvent;
	import mx.styles.IStyleClient;

	import spark.components.NavigatorContent;

	public class TabManagerPlugin extends AbstractChatPlugin implements ITabManagerPlugin
	{
		private var clientScreenMapping:Dictionary = new Dictionary(true);
		private var screenToTabMapping:Dictionary = new Dictionary(true);
		private var tabToScreenMapping:Dictionary = new Dictionary(true)

		private var stack:ISelectableList

		public function TabManagerPlugin()
		{
			super();
		}


		private var tabs:DisplayObject

		override protected function onContextInit():void
		{
			if (chatContext.chatApplication is ITabsProvider)
				tabs = ITabsProvider(chatContext.chatApplication).tabs;
		}

		public function getActiveTab():IScreenContext
		{
			if (stack && _activeTabIndex != -1)
			{
				var screen:IScreenContext = tabToScreenMapping[stack.getItemAt(_activeTabIndex)];
				if (screen)
					return screen;

			}
			return null;
		}


		public function getActiveTabName():String
		{

			if (stack && _activeTabIndex != -1)
			{
				var screen:IScreenContext = tabToScreenMapping[stack.getItemAt(_activeTabIndex)];
				if (screen)
					return screen.name;

			}
			return null;
		}

		override protected function onScreenAdded(screen:IScreenContext):void
		{
			var chatClient:IChatClient = screen.chatClient;
			clientScreenMapping[chatClient] = screen;
			var activeTab:INavigatorContent = getTabForChatScreen(screen);
			if (!stack && activeTab)
			{

				if (activeTab.parent is ISelectableList)
				{
					stack = ISelectableList(activeTab.parent);

					stack.addEventListener(ChildExistenceChangedEvent.CHILD_REMOVE, stack_childRemoveHandler, false, int.MAX_VALUE);
					stack.addEventListener(ChildExistenceChangedEvent.CHILD_ADD, stack_childAddedHandler, false, int.MAX_VALUE);
					stack.addEventListener("change", stack_indexChangedHandler);
					activeTabIndex = 0;
				}


			}

			screen.addEventListener(ChatScreenContextEvent.MESSAGE_ADDED, screenContext_messageAddedHandler);
			chatClient.addEventListener(ChatClientManagerEvent.USERLIST_UPDATED, screenChatClient_userlistHandler);

		}

		private var _activeTabIndex:int = -1;


		private function set activeTabIndex(index:int):void
		{

			var oldIndex:int = _activeTabIndex;
			_activeTabIndex = index;
			if (tabPreviousColors[index])
			{ // check to see we need to revert back to default color style


				var actualTab:IStyleClient = getRealTab(index);
				actualTab.setStyle("color", tabPreviousColors[index]);
				delete tabPreviousColors[index];


			}
			if (stack.length == 1)
				hasMultipleTabs = false;

			if (oldIndex != index && hasEventListener(TabEvent.TAB_CHANGED))
			{
				var tab:Object = stack.getItemAt(index);
				var screen:IScreenContext = tabToScreenMapping[tab];
				if (screen)
				{
					dispatchEvent(new TabEvent(TabEvent.TAB_CHANGED,
						false, false, screen.name))

				}
			}
		}

		private function stack_indexChangedHandler(e:Event):void
		{
			activeTabIndex = stack.selectedIndex;
		}

		private var hasMultipleTabs:Boolean

		private function stack_childAddedHandler(e:ChildExistenceChangedEvent):void
		{
			hasMultipleTabs = true;
			var tab:DisplayObject = e.relatedObject;
			var screenContext:IScreenContext = tabToScreenMapping[tab];
			trace("Tab ", tab, screenContext);
		}



		private var skipDataProviderRemove:Boolean  = false;

		private function stack_childRemoveHandler(e:ChildExistenceChangedEvent):void
		{

			var tab:DisplayObject = e.relatedObject;
			var screenContext:IScreenContext = tabToScreenMapping[tab];
			if (screenContext)
			{ // will fire onScreenRemoved
				skipDataProviderRemove = true;
				chatContext.removeScreenAt(chatContext.getScreenIndex(screenContext));
			}

		}



		override protected function onScreenRemoved(screen:IScreenContext):void
		{

			var chatClient:IChatClient = screen.chatClient;
			clientScreenMapping[chatClient] = null;
			tabToScreenMapping[screenToTabMapping[screen]] = null; // remove tab associated with IScreenContext
			screenToTabMapping[screen] = null;

			if (!skipDataProviderRemove) // check the tabs to see if this was from another call and not from clicking on the tab to close the window
			{

				var index:int = chatContext.getScreenIndex(screen);
				if (index != -1 && tabs.hasOwnProperty("dataProvider"))
					tabs["dataProvider"].removeItemAt(index);
			}
			skipDataProviderRemove = false;



			chatClient.disconnectFromRoom();

			chatClient.removeEventListener(ChatClientManagerEvent.USERLIST_UPDATED, screenChatClient_userlistHandler);
			if (stack.length == 1)
				hasMultipleTabs = false;
			screen.removeEventListener(ChatScreenContextEvent.MESSAGE_ADDED, screenContext_messageAddedHandler);
			//chatClient.addEventListener(ChatClientManagerEvent.NEW_MESSAGE, screenChatClient_newMessageHandler);
			chatClient = null;
		}

		private function getTabForChatScreen(screenContext:IScreenContext):INavigatorContent
		{
			var chatScreen:DisplayObject = DisplayObject(screenContext.chatScreen);
			if (screenToTabMapping[screenContext])
				return screenToTabMapping[screenContext];
			//http://flexponential.com/2009/12/08/differences-between-ivisualelement-parent-and-ivisualelement-owner/
			var ownerOrParent:String =  chatScreen is IVisualElement ? "owner" : "parent";
			var tab:Object = chatScreen;
			var found:Boolean = false;
			while (tab[ownerOrParent] != null)
			{
				tab = tab[ownerOrParent];
				if (tab is NavigatorContent)
				{ // use for clean up when CHILD_REMOVE is dispatched
					tabToScreenMapping[tab] = screenContext;
					found = true;
					break;
				}

			}

			return (tab == chatScreen || found === false) ? null : (screenToTabMapping[screenContext] = tab);
		}



		private function screenChatClient_userlistHandler(e:ChatClientManagerEvent):void
		{
			const screenContext:IScreenContext = clientScreenMapping[e.target];
			var tab:Object = getTabForChatScreen(screenContext);
			if (!tab)
				return;
			var title:String = screenContext.title;
			if (!title && tab.label)
				title = tab.label.split(" ", 1)[0];
			tab.label = title + "\n(" + e.data.userCount + " Users)";

		}

		private var tabPreviousColors:Object = {

			}

		private function screenContext_messageAddedHandler(e:ChatScreenContextEvent):void
		{
			if (!hasMultipleTabs)
				return;
			var screenContext:IScreenContext = IScreenContext(e.target);
			var tab:INavigatorContent = getTabForChatScreen(screenContext);

			var tabIndex:int = stack.getItemIndex(tab);

			if (tabIndex != -1 && tabIndex != _activeTabIndex && tabs)
			{
				if (!tabPreviousColors[tabIndex])
				{
					var actualTab:IStyleClient = getRealTab(tabIndex);
					if (actualTab)
					{
						tabPreviousColors[tabIndex] = actualTab.getStyle("color");
						actualTab.setStyle("color", 0xFF0000);
					}

				}

			}
		}

		private function getRealTab(index:int):IStyleClient
		{
			var actualTab:IStyleClient
			if ("dataGroup" in tabs)
			{
				var container:DisplayObject = tabs["dataGroup"];

				if ("getElementAt" in container)
					actualTab = IStyleClient(container["getElementAt"](index));
			}
			return actualTab;
		}



	}
}