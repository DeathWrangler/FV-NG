package Classes
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.GenericPopupTitle;
   import Display.NurseryWithdrawal;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Transactions.TCancelFriendReward;
   import flash.events.MouseEvent;
   
   public class NurseryBuilding extends AnimalStorageBuilding
   {
      
      public static const EXPAND_IMAGE_ICON_URL:String = "assets/buildings/building_nurserybarn_icon.png";
      
      protected var m_harvestResult:Object = null;
      
      private const ADULT_FOUND_ICON_SCALE:Number = 0.7;
      
      protected var m_bundleData:Object = null;
      
      protected var m_feedAction:String = "";
      
      protected var m_callbackFunction:Function = null;
      
      public function NurseryBuilding(buildingType:String = null)
      {
         super(buildingType);
      }
      
      override public function showMenu() : void
      {
         if(this.isBusy)
         {
            showObjectBusy();
         }
         else
         {
            super.showMenu();
         }
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         super.onMenuClick(event);
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            if(item.action == HARVEST_OBJECT)
            {
               this.isBusy = true;
            }
         }
      }
      
      override public function displayStorageDialog(defaultAction:String = "") : void
      {
         UI.displayStorageDialog(new NurseryWithdrawal(this));
      }
      
      override public function onHarvestComplete(result:Object) : void
      {
         var adultItem:FarmItem = null;
         var babyItem:FarmItem = null;
         var rewardItem:FarmItem = null;
         super.onHarvestComplete(result);
         this.m_harvestResult = result;
         if(result.adultBorn)
         {
            if(result.data)
            {
               adultItem = Global.farmGameSettingsManager.getFarmItemByName(result.data.adult);
               if(adultItem)
               {
                  Global.player.addGift(result.data.adult);
               }
               babyItem = Global.farmGameSettingsManager.getFarmItemByName(result.data.baby);
               if(babyItem)
               {
                  removeContents(babyItem.code);
               }
               rewardItem = Global.farmGameSettingsManager.getFarmItemByName(result.data.rewardItem);
               if(Boolean(adultItem) && Boolean(babyItem) && Boolean(rewardItem))
               {
                  this.showAdultFoundDialog(babyItem,adultItem,rewardItem);
               }
               else
               {
                  ErrorManager.addError(ErrorManager.getFormattedErrorMessage("NurseryBuilding.onHarvestComplete - One or more of the result items is not defined.","buildingItemName=" + getItemName(),"adultItemName=" + result.data.adult,"babyItemName=" + result.data.baby,"rewardItemName=" + result.data.rewardItem));
               }
            }
            else
            {
               ErrorManager.addError(ErrorManager.getFormattedErrorMessage("NurseryBuilding.onHarvestComplete - Result data is empty.","buildingItemName=" + getItemName()));
            }
         }
         isBusy = false;
      }
      
      protected function showAdultFoundDialog(baby:FarmItem, adult:FarmItem, reward:FarmItem) : void
      {
         var message:GenericPopupTitle = new GenericPopupTitle(ZLocUtils.t("Dialogs","Congrats"),ZLocUtils.t("Dialogs","NurseryShare",{
            "item":ZLocUtils.tk_pk(baby.friendlyName),
            "adultItem":ZLocUtils.tk_pk(adult.friendlyName),
            "freeItem":ZLocUtils.tk_pk(reward.friendlyName)
         }),true,GenericPopup.TYPE_SHARECANCEL,this.onConfirmShareBaby);
         message.setIcons(null,null,adult.icon);
         message.setCenterIconScale(this.ADULT_FOUND_ICON_SCALE);
         message.setAcceptTextName("Share");
         message.setTrackerKey("Feed_share_nursery_adult");
         UI.displayPopup(message);
      }
      
      private function onConfirmShareBaby(event:GenericPopupEvent) : void
      {
         var messageType:String = null;
         var adultItem:FarmItem = null;
         var rewardItem:FarmItem = null;
         var babyItem:FarmItem = null;
         var bundleData:Object = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            messageType = "NurseryShare";
            adultItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_harvestResult.data.adult);
            rewardItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_harvestResult.data.rewardItem);
            babyItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_harvestResult.data.baby);
            if(rewardItem != null)
            {
               bundleData = {
                  "adult_name":adultItem.friendlyName,
                  "baby_name":babyItem.friendlyName,
                  "gift_name":rewardItem.friendlyName,
                  "reward_link":this.m_harvestResult.data.rewardLink,
                  "images":[{
                     "href":"{SN_APP_URL}" + this.m_harvestResult.data.rewardLink,
                     "src":rewardItem.icon
                  }]
               };
               GlobalEngine.socialNetwork.publishFeedStory(messageType,bundleData,[],false,null);
            }
         }
         else
         {
            TransactionManager.addTransaction(new TCancelFriendReward([this.m_harvestResult.data.rewardLink]));
         }
      }
      
      override protected function onCompleteExpansion(rewardLink:String, itemName:String) : void
      {
         this.m_feedAction = "NurseryBarnExpandComplete";
         var feedImage:String = Global.getAssetURL(EXPAND_IMAGE_ICON_URL);
         this.m_bundleData = {
            "reward_link":rewardLink,
            "images":[{
               "href":"{SN_APP_URL}" + rewardLink,
               "src":feedImage
            }]
         };
         var itemFriendlyName:String = Global.farmGameSettingsManager.getFarmItemByName(itemName).friendlyName;
         var message:String = ZLocUtils.t("Dialogs","nursery_completeExpandComplete");
         var dialog:GenericIconPopup = new GenericIconPopup(message,GenericPopup.TYPE_SHARE,this.onShareExpansionReward,feedImage);
         dialog.setTrackerKey("feed_share_nursery_expansion_complete");
         UI.displayPopup(dialog,false);
      }
      
      override protected function onCompleteExpansionPart(rewardLink:String, itemName:String) : void
      {
         this.m_feedAction = "NurseryBarnExpandCompletePart";
         var itemFriendlyName:String = Global.farmGameSettingsManager.getFarmItemByName(itemName).friendlyName;
         var feedImage:String = Global.getAssetURL(EXPAND_IMAGE_ICON_URL);
         this.m_bundleData = {
            "item":itemFriendlyName,
            "reward_link":rewardLink,
            "images":[{
               "href":"{SN_APP_URL}" + rewardLink,
               "src":feedImage
            }]
         };
         var message:String = ZLocUtils.t("Dialogs","nursery_completeExpandPartComplete",{"items":ZLocUtils.tk_pk(itemFriendlyName)});
         var dialog:GenericIconPopup = new GenericIconPopup(message,GenericPopup.TYPE_SHARE,this.onShareExpansionReward,feedImage);
         dialog.setTrackerKey("feed_share_nursery_expansion_materialcomplete");
         UI.displayPopup(dialog,false);
      }
      
      override protected function onCompleteHalfExpansion(rewardLink:String) : void
      {
         this.m_feedAction = "NurseryBarnExpandHalfComplete";
         var feedImage:String = Global.getAssetURL(EXPAND_IMAGE_ICON_URL);
         this.m_bundleData = {
            "reward_link":rewardLink,
            "images":[{
               "href":"{SN_APP_URL}" + rewardLink,
               "src":feedImage
            }]
         };
         var message:String = ZLocUtils.t("Dialogs","nursery_completeExpandHalfComplete");
         var dialog:GenericIconPopup = new GenericIconPopup(message,GenericPopup.TYPE_SHARE,this.onShareExpansionReward,feedImage);
         dialog.setTrackerKey("feed_share_nursery_expansion_halfway");
         UI.displayPopup(dialog,false);
      }
      
      private function onShareExpansionReward(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            GlobalEngine.socialNetwork.publishFeedStory(this.m_feedAction,this.m_bundleData,[],false);
         }
         else
         {
            TransactionManager.addTransaction(new TCancelFriendReward([this.m_bundleData["reward_link"]]));
         }
      }
      
      override public function getBuildingIcon(finished:Boolean = true) : String
      {
         return NurseryBuilding.EXPAND_IMAGE_ICON_URL;
      }
   }
}

