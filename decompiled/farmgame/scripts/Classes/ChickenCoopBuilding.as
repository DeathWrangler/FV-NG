package Classes
{
   import AvatarMode.AMFeedAnimals;
   import Classes.Constants.Experiments;
   import Classes.Constants.ToasterIconPaths;
   import Classes.NeighborActions.FeedChickensNeighborAction;
   import Classes.NeighborActions.NeighborActionConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.ChickenCoopWithdrawal;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.ToasterManager;
   import Transactions.TCancelFriendReward;
   import Transactions.TGiftGive;
   import Widgets.Constants.Market.Currency;
   import Widgets.Windows.ShareButtonToasterWindow;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class ChickenCoopBuilding extends AnimalStorageBuilding
   {
      
      protected var m_harvestResult:Object = null;
      
      protected var m_feedCallback:Function = null;
      
      protected var m_counterType:String;
      
      protected var m_fedByFriends:Boolean = false;
      
      public function ChickenCoopBuilding(buildingType:String)
      {
         super(buildingType);
      }
      
      override public function onHarvestComplete(result:Object) : void
      {
         this.m_harvestResult = result;
         this.m_fedByFriends = false;
         if(m_friendFedAnimalBuildingCount > 0)
         {
            this.m_fedByFriends = true;
         }
         if(result.harvestItem != null)
         {
            this.m_counterType = "found_egg_harvest";
            this.m_feedCallback = null;
            this.showEggDialog();
         }
         else if(result.bonusCoins != null)
         {
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CHICKEN_COOP_NOEGG_TOASTER) == Experiments.VARIANT_CHICKEN_COOP_NOEGG_TOASTER)
            {
               this.showNoEggToaster(result.bonusCoins);
            }
            else
            {
               this.showNoEggDialog(result.bonusCoins);
            }
         }
         m_friendFedAnimalBuildingCount = 0;
         conditionallyAttachFedOverlay();
      }
      
      override protected function sanitizeData(data:Object) : Object
      {
         if(data.usesAltGraphic)
         {
            data.usesAltGraphic = false;
         }
         return data;
      }
      
      override public function showStorageFullDialog() : void
      {
         var message:GenericPopup = new GenericPopup(ZLocUtils.t("Dialogs","ChickenCoopFull",{"coop":ZLocUtils.tk_pk(m_item.friendlyName)}));
         message.setAcceptTextName("Okay");
         UI.displayPopup(message);
      }
      
      protected function showEggDialog() : void
      {
         var harvestItem:FarmItem = null;
         var message:GenericPopup = null;
         if(this.m_harvestResult != null)
         {
            harvestItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_harvestResult.harvestItem);
            if(this.m_fedByFriends)
            {
               message = new GenericIconPopup(ZLocUtils.t("Dialogs","FedShareEgg"),GenericPopup.TYPE_SHARE,this.onConfirmShareEgg,harvestItem.icon);
               message.setTrackerKey("chickencoop-self_egg");
            }
            else
            {
               message = new GenericIconPopup(ZLocUtils.t("Dialogs","ShareEgg",{"items":ZLocUtils.tk_pk(harvestItem.friendlyName)}),GenericPopup.TYPE_SHARE,this.onConfirmShareEgg,harvestItem.icon);
               message.setTrackerKey("chickencoop-askhelp_self");
            }
            UI.displayPopup(message);
            FarmStatsManager.count("chickencoop",this.m_counterType,"show");
         }
      }
      
      protected function showNoEggDialog(bonusCoins:int) : void
      {
         var trackerKey:String = null;
         var message:GenericPopup = null;
         var messageType:String = "NoEgg";
         if(this.m_fedByFriends)
         {
            messageType = "FedNoEgg";
         }
         if(messageType == "NoEgg")
         {
            trackerKey = "chickencoop";
         }
         else if(messageType == "FedNoEgg")
         {
            trackerKey = "chickencoop-self_no_egg";
         }
         if(UI.shouldBlockPopupForRetention())
         {
            UI.handlePopupDisplayForRetention(ZLocUtils.t("Dialogs",messageType,{"quantity":bonusCoins}),GenericPopup.TYPE_SHARE,this.onNoEggDialogClose,Global.getAssetURL("assets/hud/FV_Main_ChickFeed_Icon_Lrg.png"),trackerKey);
         }
         else
         {
            message = new GenericIconPopup(ZLocUtils.t("Dialogs",messageType,{"quantity":bonusCoins}),GenericPopup.TYPE_SHARE,this.onNoEggDialogClose,Global.getAssetURL("assets/hud/FV_Main_ChickFeed_Icon_Lrg.png"),true);
            UI.displayPopup(message);
         }
         Global.player.updateWorldCurrency(Currency.GOLD,bonusCoins,true);
      }
      
      protected function showNoEggToaster(bonusCoins:int) : void
      {
         ToasterManager.getInstance().add(new ShareButtonToasterWindow(ZLocUtils.t("Dialogs","NoEggToasterTitle"),ZLocUtils.t("Dialogs","NoEggToasterText",{"quantity":bonusCoins}),Global.getAssetURL("assets/consumables/consume_coins_icon.png"),ToasterIconPaths.DIALOG_ASSET,0.5,new Point(6,6),this.onNoEggToasterClick,this.onNoEggToasterCancel));
         Global.player.updateWorldCurrency(Currency.GOLD,bonusCoins,true);
      }
      
      protected function onConfirmShareEgg(event:GenericPopupEvent) : void
      {
         var messageType:String = null;
         var harvestItem:FarmItem = null;
         var bundleData:Object = null;
         var emailData:Object = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            if(null == this.m_feedCallback)
            {
               this.m_feedCallback = this.showChickenCoopDialog;
            }
            messageType = "ShareEgg";
            if(this.m_fedByFriends)
            {
               messageType = "FedChickensFoundMysteryEgg";
            }
            harvestItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_harvestResult.harvestItem);
            if(harvestItem != null)
            {
               bundleData = {
                  "item_name":harvestItem.friendlyName,
                  "reward_link":this.m_harvestResult.rewardLink,
                  "images":[{
                     "href":"{SN_APP_URL}" + this.m_harvestResult.rewardLink,
                     "src":harvestItem.icon
                  }]
               };
               GlobalEngine.socialNetwork.publishFeedStory(messageType,bundleData,[],false,this.m_feedCallback);
               emailData = {
                  "item_name":harvestItem.friendlyName,
                  "reward_link":this.m_harvestResult.rewardLink
               };
               if(Global.worldManager.isVisitingCommunityNeighbor())
               {
                  FarmStatsManager.sample(100,"fv_fbml_depr_inspect","ChickenCoopBuilding","overlay_called");
               }
               else
               {
                  TransactionManager.addTransaction(new TGiftGive(messageType,emailData,[]));
               }
            }
            FarmStatsManager.count("chickencoop",this.m_counterType,"click_accept");
         }
         else
         {
            this.showChickenCoopDialog();
            FarmStatsManager.count("chickencoop",this.m_counterType,"click_cancel");
            TransactionManager.addTransaction(new TCancelFriendReward([this.m_harvestResult.rewardLink]));
         }
      }
      
      protected function showChickenCoopDialog() : void
      {
         if(!Global.player.getSeenFlag("ChickenCoopFirstHarvest"))
         {
            Global.player.setSeenFlag("ChickenCoopFirstHarvest");
            this.displayStorageDialog();
         }
      }
      
      override public function displayStorageDialog(defaultAction:String = "") : void
      {
         UI.displayStorageDialog(new ChickenCoopWithdrawal(this));
      }
      
      protected function publishFeed() : void
      {
         var messageType:String = this.m_fedByFriends ? "FedChickensNoMysteryEgg" : "FeedMyChickens";
         var imagePath:String = this.m_fedByFriends ? "assets/newsfeed/chicken_full.png" : "assets/newsfeed/chicken_feed.png";
         var bundleData:Object = {"images":[{
            "href":"{SN_APP_URL}index.php?visitId=" + Global.player.uid,
            "src":Global.getAssetURL(imagePath)
         }]};
         if(this.m_harvestResult.rewardLink)
         {
            bundleData["reward_link"] = this.m_harvestResult.rewardLink;
         }
         GlobalEngine.socialNetwork.publishFeedStory(messageType,bundleData,[],false,this.showChickenCoopDialog);
      }
      
      protected function cancelFriendReward() : void
      {
         this.showChickenCoopDialog();
         TransactionManager.addTransaction(new TCancelFriendReward([this.m_harvestResult.rewardLink]));
      }
      
      protected function onNoEggDialogClose(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.YES)
         {
            this.publishFeed();
         }
         else
         {
            this.cancelFriendReward();
         }
      }
      
      protected function onNoEggToasterClick() : void
      {
         FarmStatsManager.count("chickencoop","no_egg","toaster_click");
         this.publishFeed();
      }
      
      protected function onNoEggToasterCancel(event:Event) : void
      {
         this.cancelFriendReward();
      }
      
      protected function showCoopTip() : void
      {
         UI.displayMessage(ZLocUtils.t("Dialogs","ChickenCoopTip"),GenericPopup.TYPE_OK,null,"ChickenCoopTip",false,true);
      }
      
      override public function onBuildComplete(result:Object) : void
      {
         super.onBuildComplete(result);
         if(result.rewardLink)
         {
            this.m_harvestResult = result;
            this.m_feedCallback = this.showCoopTip;
            this.m_counterType = "found_egg_first";
            this.showEggDialog();
         }
      }
      
      override public function getCursor() : Class
      {
         var cursor:Class = null;
         if(Global.worldManager.isVisiting())
         {
            if(this.canFeedOnVisit())
            {
               cursor = ZLocUtils.tiEmbeddedArt("cursor_chicken_feed");
            }
         }
         else
         {
            cursor = super.getCursor();
         }
         return cursor;
      }
      
      override protected function onVisitClick() : void
      {
         if(this.canFeedOnVisit())
         {
            VisitorManager.getInstance().queueActionType(this,NeighborActionConstants.LIMIT_TYPE_FEED_ACTION);
            Global.selectedAvatar.getStateMachine().addState(new AMFeedAnimals(Global.selectedAvatar,this),true);
         }
      }
      
      override public function feedAnimals() : void
      {
         m_animalsFed = true;
         VisitorManager.getInstance().doAction(new FeedChickensNeighborAction(this));
         conditionallyAttachFedOverlay();
      }
      
      override public function canBeClickedOnVisit() : Boolean
      {
         return this.canFeedOnVisit();
      }
      
      override public function canUpdateCursorOnVisit() : Boolean
      {
         return this.canFeedOnVisit();
      }
      
      override protected function updatePlantTimeOnStore(itemCount:int, resource:MapResource) : void
      {
         if(itemCount == 0)
         {
            plantTime = Global.worldTime;
            setState(STATE_BARE);
         }
      }
   }
}

