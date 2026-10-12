package Widgets.Windows.FishingDerby
{
   import Classes.Collections.Collection;
   import Classes.Collections.FishingCollection;
   import Classes.FeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Managers.CollectionsManager;
   import Managers.FeatureOptionsManager;
   import Managers.FishingDerbyManager;
   import Managers.Requests2InterstitialManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FishingDerby.FishingDerbyCollectionFrame;
   import Widgets.Frames.FishingDerby.FishingDerbyTabsFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class FishingDerbyCollectionWindow extends FarmWindow
   {
      
      public static const COMMUNITY_FEATURED_ICON:String = "assets/decorations/deco_workboot_icon.png";
      
      private static const COMMUNITY_PREREQ:String = "community";
      
      public static const FISHING_LODGE:String = "fishing_lodge";
      
      public static const FISHING_LODGE_OPEN:String = "fishing_lodge_open";
      
      private var m_collectionFrame:FishingDerbyCollectionFrame;
      
      private var m_featuredFrame:ZwFrame;
      
      private var m_featuredTtitle:ZwTextField;
      
      private var m_featureDescription:ZwTextField;
      
      private var m_featuredButton:FarmAnimatedTextButton;
      
      private var m_featuredIcon:FarmIcon;
      
      private var m_completedCollection:ZwWidget;
      
      private var m_completePrize:ZwWidget;
      
      private var m_completePrizeText:ZwTextField;
      
      public function FishingDerbyCollectionWindow(building:FeatureBuilding)
      {
         var dialogConfig:Object = building.getItem().getDialogConfig("storage");
         super(dialogConfig["path"]);
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var fishingCollection:FishingCollection = null;
         super.onLoadComplete(event);
         addWidget(this.m_featuredFrame = new ZwFrame(m_window.featured_mc));
         this.m_featuredFrame.addWidget(this.m_featuredTtitle = new ZwTextField(m_window.featured_mc.featuredTitle_tf));
         this.m_featuredFrame.addWidget(this.m_featureDescription = new ZwTextField(m_window.featured_mc.featuredItem_tf));
         this.m_featuredFrame.addWidget(this.m_featuredButton = new FarmAnimatedTextButton(m_window.featured_mc.market_bt));
         this.m_featuredFrame.addWidget(this.m_featuredIcon = new FarmIcon(m_window.featured_mc.icon_mc));
         addWidget(this.m_completedCollection = new ZwWidget(m_window.itemcollection_mc.completeCollection_mc));
         addWidget(this.m_completePrize = new ZwWidget(m_window.itemcollection_mc.prize_mc));
         addWidget(this.m_completePrizeText = new ZwTextField(m_window.itemcollection_mc.prize_mc.generic_tf));
         this.m_completePrizeText.text = ZLocUtils.t_pk("Dialogs","FishingLodge_Complete_Prize_Text");
         addWidget(new ZwTextField(m_window.title_tf,"Fishing Lodge"));
         addWidget(this.m_collectionFrame = new FishingDerbyCollectionFrame(m_window.itemcollection_mc));
         var collections:XMLList = CollectionsManager.getInstance().getAllCollectionXMLByType(Collection.TYPE_FISHING);
         var collectionTabsFrame:FishingDerbyTabsFrame = new FishingDerbyTabsFrame(m_window.collectionsTab_mc,this);
         addWidget(collectionTabsFrame);
         var fishingCollections:Array = new Array();
         for(var i:int = 0; i < collections.length(); i++)
         {
            fishingCollection = new FishingCollection(collections[i]);
            fishingCollections.push(fishingCollection);
         }
         collectionTabsFrame.items = fishingCollections;
         if(fishingCollections.length > 0)
         {
            this.setActiveCollection(fishingCollections[0]);
         }
         Global.world.dispatchEvent(new Event(FISHING_LODGE_OPEN));
         StatsManager.count(FeatureOptionsManager.FISHING_DERBY,"fishing_lodge","impressions");
      }
      
      public function setActiveCollection(fishingCollection:FishingCollection) : void
      {
         var isCollectionComplete:Boolean = false;
         var collectionPrereq:Object = null;
         var bootCollectionUnlocked:Boolean = false;
         var farmItem:FarmItem = null;
         var fishingInventory:Object = null;
         var farmItem2:FarmItem = null;
         if(!this.m_collectionFrame.collection || this.m_collectionFrame.collection.name != fishingCollection.name)
         {
            this.m_collectionFrame.collection = fishingCollection;
         }
         var completedCollections:Object = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.FISHING_DERBY,"finishedfish");
         isCollectionComplete = Boolean(completedCollections) && completedCollections.hasOwnProperty(fishingCollection.name) ? true : false;
         this.m_completedCollection.visible = isCollectionComplete;
         this.m_completePrize.visible = !isCollectionComplete;
         this.m_completePrizeText.visible = !isCollectionComplete;
         var collectionPrerequisites:Array = FishingDerbyManager.instance.getConfigArray(FishingDerbyManager.CONFIG_COLLECTIONS_PREREQ);
         var prerequisite:String = null;
         for each(collectionPrereq in collectionPrerequisites)
         {
            if(collectionPrereq.name == fishingCollection.name)
            {
               prerequisite = collectionPrereq.prereq;
               break;
            }
         }
         if(prerequisite != null)
         {
            this.m_featuredFrame.visible = true;
            if(prerequisite == COMMUNITY_PREREQ)
            {
               bootCollectionUnlocked = Boolean(FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.FISHING_DERBY,FeatureOptionsManager.FEATURE_BOOT));
               if(!bootCollectionUnlocked)
               {
                  this.m_featuredTtitle.text = ZLocUtils.t_pk("Dialogs","FishingLodge_Featured_CommunityTitle");
                  this.m_featureDescription.text = ZLocUtils.t_pk("Dialogs","FishingLodge_Featured_CommunityText",{"friendCount":Global.farmGameSettingsManager.getNumber("fishingDerbyFriendCount",3).toString()});
                  this.m_featuredIcon.loadIcon(Global.getAssetURL(COMMUNITY_FEATURED_ICON));
                  this.m_featuredButton.text = ZLocUtils.t_pk("Dialogs","FishingLodge_Featured_CommunityButton");
                  this.m_featuredButton.callback = this.inviteFriends;
                  this.m_featuredButton.visible = false;
               }
               else
               {
                  this.m_featuredFrame.visible = false;
               }
            }
            else
            {
               farmItem = Global.farmGameSettingsManager.getFarmItemByName(prerequisite);
               fishingInventory = FishingDerbyManager.getFishingInventory();
               if((fishingInventory.unlocked_rods as Array).indexOf(farmItem.name) < 0)
               {
                  this.m_featuredTtitle.text = ZLocUtils.t_pk("Dialogs","FishingLodge_Featured_Title");
                  this.m_featureDescription.text = ZLocUtils.t_pk("Dialogs","FishingLodge_Featured_Text",{"rodName":ZLocUtils.tk_pk_asTitle(farmItem.friendlyName)});
                  this.m_featuredIcon.loadIcon(farmItem.icon);
                  this.m_featuredButton.text = ZLocUtils.t_pk("Dialogs","FishingLodge_Featured_Button");
                  this.m_featuredButton.callback = this.openBaitShop;
                  this.m_featuredButton.visible = true;
               }
               else if(isCollectionComplete)
               {
                  this.m_featuredTtitle.text = ZLocUtils.t_pk("Dialogs","FishingLodge_Collection_Complete_Title");
                  this.m_featureDescription.text = ZLocUtils.t_pk("Dialogs","FishingLodge_Upsell_fish_finder_Text");
                  farmItem2 = Global.farmGameSettingsManager.getFarmItemByName("fishfinder");
                  this.m_featuredIcon.loadIcon(farmItem2.icon);
                  this.m_featuredButton.text = ZLocUtils.t_pk("Dialogs","FishingLodge_Featured_Button");
                  this.m_featuredButton.callback = this.openBuffTabInBaitShop;
               }
               else
               {
                  this.m_featuredFrame.visible = false;
               }
            }
         }
         else
         {
            this.m_featuredFrame.visible = false;
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         Global.world.dispatchEvent(new Event(FISHING_LODGE));
         super.onClose(event);
      }
      
      private function inviteFriends(event:Event) : void
      {
         close();
         Requests2InterstitialManager.displayNeighborAddWindow("fishing_lodge");
      }
      
      private function openBaitShop(event:Event) : void
      {
         close();
         var baitShopArray:Array = Global.world.getObjectsByCode("1lB");
         if(baitShopArray.length > 0)
         {
            UI.displayPopup(new FishingDerbyStoreWindow(baitShopArray[0],FishingDerbyStoreWindow.TAB_RODS),true,"FishingDerbyStoreWindow",true);
         }
      }
      
      private function openBuffTabInBaitShop(event:Event) : void
      {
         close();
         var baitShopArray:Array = Global.world.getObjectsByCode("1lB");
         if(baitShopArray.length > 0)
         {
            UI.displayPopup(new FishingDerbyStoreWindow(baitShopArray[0],FishingDerbyStoreWindow.TAB_BUFF),true,"FishingDerbyStoreWindow",true);
         }
      }
   }
}

