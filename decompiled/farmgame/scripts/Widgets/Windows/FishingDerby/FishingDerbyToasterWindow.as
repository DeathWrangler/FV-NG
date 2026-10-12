package Widgets.Windows.FishingDerby
{
   import Classes.Collections.Collection;
   import Classes.Collections.FishingCollectible;
   import Classes.Collections.FishingCollection;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.StatsManager;
   import Managers.CollectionsManager;
   import Managers.FeatureOptionsManager;
   import Managers.FishingDerbyManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.ToasterWindow;
   import com.greensock.TweenLite;
   import flash.events.Event;
   
   public class FishingDerbyToasterWindow extends ToasterWindow
   {
      
      public static const FISHING_TOASTER_CLOSE:String = "fishing_toasterClose";
      
      private static const ASSET_PATH:String = "assets/dialogs/Angler/FV_xap_fishing_toaster2.swf";
      
      private static const DEFAULT_FISH_NAME:String = "walleye";
      
      private static const POSTFIX_200:String = "_200.png";
      
      public static const CAUGHT_FISH:int = 0;
      
      public static const COLLECTION_COMPLETE:int = 1;
      
      public static const UNLOCKED_BOOT:int = 2;
      
      private var m_transactionResult:Object;
      
      private var m_shareButton:FarmAnimatedTextButton;
      
      private var m_bonusFrame:ZwFrame;
      
      private var m_bonusIcon:FarmIcon;
      
      private var m_bonusCount:ZwTextField;
      
      private var m_bonusTitle:ZwTextField;
      
      private var m_prizeItem:FarmItem;
      
      private var m_prizeCount:int = 0;
      
      private var m_winText:ZwTextField;
      
      private var m_winInfo:ZwTextField;
      
      private var m_toasterType:int;
      
      public function FishingDerbyToasterWindow(transactionResult:Object, toasterType:int = 0)
      {
         super(ASSET_PATH);
         this.m_transactionResult = transactionResult;
         this.m_toasterType = toasterType;
         FishingDerbyManager.instance.toaster = this;
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         switch(this.m_toasterType)
         {
            case CAUGHT_FISH:
               this.populateCaughtFish();
               break;
            case COLLECTION_COMPLETE:
               this.populateCollectionCompleteToaster();
               break;
            case UNLOCKED_BOOT:
               this.populateUnlockBootToaster();
         }
      }
      
      private function populateCaughtFish() : void
      {
         if(this.m_transactionResult.hasOwnProperty("name") && this.m_transactionResult.hasOwnProperty("collection"))
         {
            this.populateCaughtFishToaster();
         }
         else if(this.m_transactionResult.hasOwnProperty("nearMiss"))
         {
            this.populateNearMissFishToaster();
         }
         else
         {
            this.populateMissFishToaster();
         }
      }
      
      private function populateUnlockBootToaster() : void
      {
         var farmIcon:FarmIcon = new FarmIcon(m_window.icon_mc);
         farmIcon.setSmoothing(true);
         farmIcon.setIconSize(200,200);
         var farmIconUrl:String = "assets/decorations/deco_workboot_icon.png";
         var farmIcon200:String = Global.getAssetURL(farmIconUrl.slice(0,farmIconUrl.length - 4) + POSTFIX_200);
         farmIcon.loadIcon(farmIcon200);
         addWidget(farmIcon);
         addWidget(new ZwBaseWidget(m_window.bgSuccess_mc));
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t_pk("Dialogs","FishingToaster_WinTitle")));
         addWidget(this.m_winText = new ZwTextField(m_window.item_tf,ZLocUtils.t_pk("Dialogs","FishingBoot_unlocked_Header")));
         addWidget(this.m_winInfo = new ZwTextField(m_window.info2_tf,ZLocUtils.t_pk("Dialogs","FishingBoot_unlocked")));
      }
      
      private function populateCollectionCompleteToaster() : void
      {
         if(this.m_transactionResult.hasOwnProperty("rewardLink"))
         {
            addWidget(this.m_shareButton = new FarmAnimatedTextButton(m_window.accept_bt,ZLocUtils.t_pk("Dialogs","FishingToaster_Share"),this.onShare));
         }
         var collectionRewardName:String = this.m_transactionResult.collectionCompleteGiftName as String;
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(collectionRewardName);
         var farmIcon:FarmIcon = new FarmIcon(m_window.icon_mc);
         farmIcon.setSmoothing(true);
         farmIcon.setIconSize(200,200);
         var farmIconUrl:String = farmItem.iconRelativeUrl;
         var farmIcon200:String = Global.getAssetURL(farmIconUrl.slice(0,farmIconUrl.length - 4) + POSTFIX_200);
         farmIcon.loadIcon(farmIcon200);
         addWidget(farmIcon);
         addWidget(new ZwBaseWidget(m_window.bgSuccess_mc));
         var collectionName:String = ZLocUtils.t_pk("Collections",this.m_transactionResult.collection + "_friendlyName");
         var collectionCompleteGiftMessage:String = ZLocUtils.t_pk("Dialogs","FishingToaster_collectionComplete",{
            "reward":ZLocUtils.tk_pk(farmItem.friendlyName),
            "collectionName":collectionName
         });
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t_pk("Dialogs","FishingToaster_WinTitle")));
         addWidget(this.m_winText = new ZwTextField(m_window.item_tf,ZLocUtils.t_pk("Dialogs","FishingToaster_collectionComplete_Header")));
         addWidget(this.m_winInfo = new ZwTextField(m_window.info2_tf,collectionCompleteGiftMessage));
      }
      
      private function populateMissFishToaster() : void
      {
         addWidget(new ZwBaseWidget(m_window.bgFail_mc));
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t_pk("Dialogs","FishingToaster_FailTitle")));
         addWidget(new ZwTextField(m_window.item_tf,ZLocUtils.t_pk("Dialogs","FishingToaster_FailText")));
         addWidget(new ZwTextField(m_window.info_tf,ZLocUtils.t_pk("Dialogs","FishingToaster_FailInfo")));
         addWidget(this.m_shareButton = new FarmAnimatedTextButton(m_window.accept_bt,ZLocUtils.t_pk("Dialogs","Fish_Again"),this.closeWindow));
      }
      
      private function populateNearMissFishToaster() : void
      {
         addWidget(new ZwBaseWidget(m_window.bgNearMiss_mc));
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_transactionResult.nearMiss);
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t_pk("Dialogs","FishingToaster_MissTitle")));
         addWidget(new ZwTextField(m_window.item_tf,ZLocUtils.t_pk("Dialogs","FishingToaster_MissText",{"fishName":ZLocUtils.tk_pk(farmItem.friendlyName)})));
         addWidget(new ZwTextField(m_window.info_tf,ZLocUtils.t_pk("Dialogs","FishingToaster_MissInfo")));
         var farmIcon:FarmIcon = new FarmIcon(m_window.icon_mc);
         farmIcon.setSmoothing(true);
         farmIcon.setIconSize(200,200);
         var farmIconUrlNearMiss:String = farmItem.iconRelativeUrl;
         var farmIconUrlNearMiss200:String = Global.getAssetURL(farmIconUrlNearMiss.slice(0,farmIconUrlNearMiss.length - 4) + POSTFIX_200);
         farmIcon.loadIcon(farmIconUrlNearMiss200);
         addWidget(farmIcon);
         addWidget(this.m_shareButton = new FarmAnimatedTextButton(m_window.accept_bt,ZLocUtils.t_pk("Dialogs","Fish_Again"),this.closeWindow));
      }
      
      private function populateCaughtFishToaster() : void
      {
         var collectibleName:String = this.m_transactionResult.name as String;
         if(this.m_transactionResult.hasOwnProperty("rewardLink"))
         {
            addWidget(this.m_shareButton = new FarmAnimatedTextButton(m_window.accept_bt,ZLocUtils.t_pk("Dialogs","FishingToaster_Share"),this.onShare));
         }
         FishingDerbyManager.awardMasteryForCollectible(this.m_transactionResult.collection,collectibleName);
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(collectibleName);
         var collections:XMLList = CollectionsManager.getInstance().getAllCollectionXMLByType(Collection.TYPE_FISHING);
         var foundCollectible:FishingCollectible = null;
         var foundCollection:FishingCollection = this.getFoundFishingCollection(collections);
         if(foundCollection != null)
         {
            foundCollectible = this.getFoundFishingCollectible(foundCollection,collectibleName);
         }
         var farmIcon:FarmIcon = new FarmIcon(m_window.icon_mc);
         farmIcon.setSmoothing(true);
         farmIcon.setIconSize(200,200);
         var farmIconUrl:String = farmItem.iconRelativeUrl;
         var farmIcon200:String = Global.getAssetURL(farmIconUrl.slice(0,farmIconUrl.length - 4) + POSTFIX_200);
         farmIcon.loadIcon(farmIcon200);
         addWidget(farmIcon);
         addWidget(new ZwBaseWidget(m_window.bgSuccess_mc));
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t_pk("Dialogs","FishingToaster_WinTitle")));
         addWidget(this.m_winText = new ZwTextField(m_window.item_tf,ZLocUtils.t_pk("Dialogs","FishingToaster_WinText",{"fishName":ZLocUtils.tk_pk(farmItem.friendlyName)})));
         if(foundCollection != null && foundCollectible != null)
         {
            this.showTheMasteryInfo(foundCollection);
         }
         if(this.m_transactionResult.hasOwnProperty("masterySign") && this.m_transactionResult.masterySign == true)
         {
            Global.player.addGift(foundCollectible.masterySignName);
            this.m_winText.text = ZLocUtils.t_pk("Dialogs","FishingToaster_WinTextMastered",{"fishName":ZLocUtils.tk_pk(farmItem.friendlyName)});
            this.m_winInfo.text = ZLocUtils.t_pk("Dialogs","FishingToaster_WinTextMasteredGift");
         }
         else if(m_window.hasOwnProperty("mastery_tf"))
         {
            addWidget(new ZwTextField(m_window.mastery_tf,ZLocUtils.t_pk("Dialogs","Fishing_mastery")));
         }
         addWidget(this.m_bonusFrame = new ZwFrame(m_window.bonus_mc),false);
         this.m_bonusFrame.addWidget(this.m_bonusIcon = new FarmIcon(m_window.bonus_mc.icon_mc));
         this.m_bonusIcon.setIconSize(75,75);
         this.m_bonusFrame.addWidget(this.m_bonusTitle = new ZwTextField(m_window.bonus_mc.header_tf));
         this.m_bonusFrame.addWidget(this.m_bonusCount = new ZwTextField(m_window.bonus_mc.counter_tf));
         if(this.m_prizeItem != null && this.m_prizeCount > 0)
         {
            this.addBonusItem(this.m_prizeItem,this.m_prizeCount);
         }
      }
      
      private function getFoundFishingCollection(collections:XMLList) : FishingCollection
      {
         var fishingCollection:FishingCollection = null;
         var foundCollection:FishingCollection = null;
         for(var i:int = 0; i < collections.length(); i++)
         {
            fishingCollection = new FishingCollection(collections[i]);
            if(fishingCollection.name == this.m_transactionResult.collection)
            {
               foundCollection = fishingCollection;
               break;
            }
         }
         return foundCollection;
      }
      
      private function getFoundFishingCollectible(foundCollection:FishingCollection, collectibleName:String) : FishingCollectible
      {
         var fishingCollectible:FishingCollectible = null;
         var foundCollectible:FishingCollectible = null;
         for(var i:int = 0; i < foundCollection.collectibles.length; i++)
         {
            fishingCollectible = foundCollection.collectibles[i] as FishingCollectible;
            if(fishingCollectible.name == collectibleName)
            {
               foundCollectible = fishingCollectible;
               break;
            }
         }
         return foundCollectible;
      }
      
      private function showTheMasteryInfo(foundCollection:FishingCollection) : void
      {
         var k:String = null;
         var collectionName:String = ZLocUtils.t_pk("Collections",this.m_transactionResult.collection + "_friendlyName");
         var masteryOption:Object = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.FISHING_DERBY,FishingDerbyManager.FEATURE_MASTERY);
         var masteryCollection:Object = masteryOption.hasOwnProperty(foundCollection.name) ? masteryOption[foundCollection.name] : {};
         var masteryCount:int = 0;
         for(k in masteryCollection)
         {
            masteryCount++;
         }
         addWidget(this.m_winInfo = new ZwTextField(m_window.info_tf,ZLocUtils.t_pk("Dialogs","FishingToaster_WinInfo",{
            "count":masteryCount,
            "total":foundCollection.collectibles.length,
            "collectionName":collectionName
         })));
      }
      
      public function addBonusItem(farmItem:FarmItem, itemCount:int) : void
      {
         this.m_prizeItem = farmItem;
         this.m_prizeCount = itemCount;
         if(this.m_bonusIcon != null && this.m_bonusFrame != null && this.m_bonusTitle != null && this.m_bonusCount != null)
         {
            this.m_bonusIcon.loadIcon(farmItem.icon);
            this.m_bonusIcon.setSmoothing(true);
            this.m_bonusTitle.text = ZLocUtils.t_pk("Dialogs","FishingToaster_Bonus");
            this.m_bonusCount.text = itemCount.toString();
            this.m_bonusCount.visible = itemCount > 0 ? true : false;
            this.m_bonusCount.text = "x" + itemCount.toString();
            TweenLite.to(this.m_bonusFrame.element,0.3,{
               "alpha":1,
               "onComplete":function(event:Event = null):void
               {
                  m_bonusFrame.visible = true;
               }
            });
         }
      }
      
      private function onShare(event:Event) : void
      {
         this.m_shareButton.enabled = false;
         this.close();
         var collectibleName:String = this.m_transactionResult.name as String;
         var collectionName:String = ZLocUtils.t_pk("Collections",this.m_transactionResult.collection + "_friendlyName");
         FishingDerbyManager.awardMasteryForCollectible(this.m_transactionResult.collection,collectibleName);
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(DEFAULT_FISH_NAME);
         var actualFish:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(collectibleName);
         var rewardItem:FarmItem = null;
         if(this.m_transactionResult.rewardName)
         {
            rewardItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_transactionResult.rewardName);
         }
         var bundleData:Object = {
            "user":Global.player.firstName,
            "fishName":ZLocUtils.tk_pk_asTitle(farmItem.friendlyName),
            "reward_link":this.m_transactionResult.rewardLink,
            "fishCollection":collectionName,
            "actualFish":ZLocUtils.tk_pk_asTitle(actualFish.friendlyName),
            "rewardName":(rewardItem != null ? ZLocUtils.tk_pk_asTitle(rewardItem.friendlyName) : ""),
            "images":[{
               "href":"{SN_APP_URL}" + this.m_transactionResult.rewardLink,
               "src":farmItem.icon
            }]
         };
         var feedStoryBundleID:String = this.m_transactionResult.bundleId;
         GlobalEngine.socialNetwork.publishFeedStory(feedStoryBundleID,bundleData,[],false);
         StatsManager.count(FeatureOptionsManager.FISHING_DERBY,"fv_fishing_post_feed",String(Global.player.uid),"1");
      }
      
      private function closeWindow(event:Event) : void
      {
         this.close();
      }
      
      override public function close() : void
      {
         FishingDerbyManager.instance.toaster = null;
         Global.world.dispatchEvent(new Event(FISHING_TOASTER_CLOSE));
         super.close();
         FishingDerbyManager.detachAllFishingBobbers();
      }
   }
}

