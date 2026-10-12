package GameMode
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.GenericXMLDialog;
   import Display.UI;
   import Engine.Helpers.Vector3;
   import Events.GenericPopupEvent;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   
   public class GMCreditsBuildingItemPlace extends GMAutomaticStoragePlace
   {
      
      private static const CREDITS_REOPEN_GIFT_DIALOG_TIMEOUT:Number = 2000;
      
      protected var m_creditsBuildingName:String;
      
      public function GMCreditsBuildingItemPlace(itemName:String, isGift:Boolean, shouldReOpenGift:Boolean = true, centerOnBuilding:Boolean = true, itemCount:int = 1, storageBuildingName:String = "")
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         if(storageBuildingName == "")
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               storageBuildingName = item.getStringFromDataSource("basket");
            }
            else
            {
               storageBuildingName = String(item.xml.basket);
            }
         }
         if(storageBuildingName)
         {
            super(itemName,storageBuildingName,isGift,shouldReOpenGift,centerOnBuilding,itemCount);
            this.m_creditsBuildingName = storageBuildingName;
            m_giftTimeout = CREDITS_REOPEN_GIFT_DIALOG_TIMEOUT;
            return;
         }
         throw new Error("missing required storage building name");
      }
      
      override protected function onFinishModifyBuilding(modifiedBuilding:Boolean, hasABuilding:Boolean, isFirstEntry:Boolean) : void
      {
         var buildingPosition:Vector3 = null;
         var i:int = 0;
         if(modifiedBuilding)
         {
            if(isFirstEntry)
            {
               FarmStatsManager.count(this.m_creditsBuildingName,"first_time_credit_use");
            }
            else
            {
               FarmStatsManager.count(this.m_creditsBuildingName,"use_credit");
            }
            if(m_isGift)
            {
               reOpenGiftIfNecessary();
            }
            else
            {
               buildingPosition = m_building.getPosition();
               m_itemToAdd.setPosition(buildingPosition.x,buildingPosition.y,buildingPosition.z);
               for(i = 0; i < m_itemCount; i++)
               {
                  Global.player.tryBuy(m_itemToAdd);
               }
            }
         }
         else
         {
            this.displayNoBuildingMessage();
         }
      }
      
      protected function displayNoBuildingMessage() : void
      {
         var imageSize:Number;
         var dialog:GenericXMLDialog;
         var item:FarmItem = null;
         var message:String = null;
         var centerIconUrl:String = null;
         var prefix:String = null;
         try
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(this.m_creditsBuildingName);
            if(!item.isInExperiment)
            {
               message = ZLocUtils.t("Dialogs","CreditsNoBuilding_unavailable");
               centerIconUrl = null;
            }
            else
            {
               prefix = "";
               if(ZLocUtils.hasString("Dialogs",this.m_creditsBuildingName + "CreditsNoBuilding"))
               {
                  prefix = this.m_creditsBuildingName;
               }
               message = ZLocUtils.t("Dialogs",prefix + "CreditsNoBuilding",{
                  "itemToAdd":ZLocUtils.tk_pk(m_itemToAdd.getItem().friendlyName),
                  "item":ZLocUtils.tk_pk(item.friendlyName)
               });
               centerIconUrl = Global.reverseAssetURL(item.icon,2);
            }
         }
         catch(err:Error)
         {
            message = ZLocUtils.t("Dialogs","CreditsNoBuilding_unavailable");
            centerIconUrl = null;
         }
         imageSize = 100;
         dialog = new GenericXMLDialog(null,"",null,centerIconUrl,imageSize,imageSize,message,this.noBuildingCallback,false,ZLocUtils.t("Dialogs","Accept"),null,ZLocUtils.t("Dialogs","Cancel"),null,null,GenericXMLDialog.NUM_DIALOG_WIDTH_MEDIUM);
         UI.displayPopup(dialog,false);
      }
      
      private function noBuildingCallback(event:GenericPopupEvent) : void
      {
         var partName:String = m_itemToAdd.getItem().name;
         if(event.button == GenericPopup.ACCEPT)
         {
            FarmStatsManager.count("farmville_sell_gift_screen","regift_prompt_accept",partName,"noBuildingCallback","GMCreditsBuildingItemPlace");
            UI.displayGiftBoxWindow(true);
         }
         else
         {
            FarmStatsManager.count("farmville_sell_gift_screen","regift_prompt_cancel",partName,"noBuildingCallback","GMCreditsBuildingItemPlace");
         }
      }
   }
}

