package Classes
{
   import Classes.ZItem.FarmItem;
   import Classes.consumables.CBushel;
   import Classes.util.ZLocUtils;
   import Display.DataDrivenOkayPopup;
   import Display.UI;
   
   public class ConstructionBuildingFinishedRewardHandler
   {
      
      private var m_buildingName:String = "";
      
      private var m_callbackData:Object = {};
      
      public function ConstructionBuildingFinishedRewardHandler(buildingName:String)
      {
         super();
         this.m_buildingName = buildingName;
      }
      
      public function giveFinishedReward(itemName:String, addToGiftbox:Boolean = true) : void
      {
         var giftItem:FarmItem = null;
         if(null != itemName && "" != itemName)
         {
            giftItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
            if(giftItem != null)
            {
               this.m_callbackData.gift = giftItem.name;
               if(addToGiftbox)
               {
                  Global.player.addGift(giftItem.name);
               }
               this.displayRewardDialog(giftItem);
            }
         }
      }
      
      public function addRewardToBuilding(itemName:String, addToBuilding:MapResource = null) : void
      {
         var giftItem:FarmItem = null;
         var featureBuilding:FeatureBuilding = null;
         var classType:Class = null;
         var mapResource:MapResource = null;
         if(null != itemName && "" != itemName)
         {
            giftItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
            if(giftItem != null)
            {
               if(null != addToBuilding && addToBuilding is FeatureBuilding)
               {
                  featureBuilding = addToBuilding as FeatureBuilding;
                  if(giftItem.type != CBushel.BUSHEL)
                  {
                     classType = giftItem.getMapResourceClass();
                     mapResource = new classType(giftItem.name);
                     if(featureBuilding.canTakeItem(mapResource))
                     {
                        featureBuilding.addItem(mapResource,0,true);
                     }
                  }
                  this.displayRewardDialog(giftItem,true);
               }
            }
         }
      }
      
      public function displayRewardDialog(giftItem:FarmItem, okayOnly:Boolean = false) : void
      {
         var cancelButtonText:String = null;
         var params:Array = null;
         var displayPopup:DataDrivenOkayPopup = null;
         var title:String = ZLocUtils.t("Dialogs",this.m_buildingName + "_finishedReward_WindowTitle");
         var text:String = ZLocUtils.t("Dialogs",this.m_buildingName + "_finishedReward_Message",{
            "item":ZLocUtils.tk_pk(giftItem.friendlyName),
            "item_same":ZLocUtils.tk_pk(giftItem.friendlyName)
         });
         var buttonText:String = ZLocUtils.t("Dialogs",this.m_buildingName + "_finishedReward_Action");
         if(okayOnly)
         {
            params = [giftItem.iconRelativeUrl,text,title,buttonText];
            displayPopup = new DataDrivenOkayPopup("CompletionCongratsOkayScreen",params);
         }
         else
         {
            cancelButtonText = ZLocUtils.t("Dialogs",this.m_buildingName + "_finishedReward_Cancel");
            params = [giftItem.iconRelativeUrl,text,title,buttonText,cancelButtonText];
            displayPopup = new DataDrivenOkayPopup("CompletionCongratsScreen",params,this.acceptCallback,this.closeCallback);
         }
         UI.displayPopup(displayPopup,true);
      }
      
      protected function acceptCallback() : void
      {
         Global.world.enterForcePlaceMode(this.m_callbackData.gift,true);
      }
      
      protected function closeCallback() : void
      {
      }
   }
}

