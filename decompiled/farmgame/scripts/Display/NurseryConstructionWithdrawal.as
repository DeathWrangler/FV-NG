package Display
{
   import Classes.BuildingItemUseMediator;
   import Classes.BuildingPart;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Transactions.TCompleteNow;
   import flash.events.MouseEvent;
   
   public class NurseryConstructionWithdrawal extends ConstructionBuildingWithdrawal
   {
      
      private static var m_askForMaterials:Boolean = true;
      
      protected var m_displayStorageDialog:Boolean = true;
      
      public function NurseryConstructionWithdrawal(storage:StorageBuilding)
      {
         super(storage);
         m_dialogType = "nursery";
      }
      
      override protected function onGetThisCallback(event:MouseEvent) : void
      {
         var item:FarmItem = null;
         var needString:String = null;
         var bundleData:Object = null;
         if(m_askForMaterials)
         {
            m_askForMaterials = false;
            item = Global.farmGameSettingsManager.getFarmItemByName(getItemNameFromEvent(event));
            needString = generateNeedList();
            if(needString)
            {
               bundleData = {
                  "needList":needString,
                  "images":[{
                     "href":"{SN_APP_URL}gifts.php?giftRecipient=" + Global.player.snUser.uid,
                     "src":item.icon
                  }]
               };
               GlobalEngine.socialNetwork.publishFeedStory("NurseryNeedMaterials",bundleData,[],false,this.onAskForMaterials);
            }
         }
      }
      
      override protected function onAskForMaterials() : void
      {
         m_askForMaterials = true;
         super.onAskForMaterials();
      }
      
      override protected function addComponent(compId:int, index:int = 0) : void
      {
         var buyButton:GenericButton = null;
         var completeNow:GenericButton = null;
         super.addComponent(compId,index);
         if(!m_building.isFullyBuilt())
         {
            if(Boolean(m_tiles) && Boolean(m_data[index + compId] != null) && m_usedTypes != null)
            {
               if(m_data[index + compId].sendGiftsToFriends == false)
               {
                  if(m_usedTypes[m_data[index + compId].code] != m_data[index + compId].need)
                  {
                     if(m_tiles[compId].buy_bt)
                     {
                        m_tiles[compId].buy_bt.visible = true;
                        buyButton = new GenericButton(m_tiles[compId].buy_bt,this.onBuyPartCallback);
                        buyButton.text = ZLocUtils.t("Dialogs","Buy");
                     }
                  }
               }
               else if(m_tiles[compId].completeNow_bt)
               {
                  m_tiles[compId].completeNow_bt.visible = true;
                  completeNow = new GenericButton(m_tiles[compId].completeNow_bt,this.onCompleteNowCallback);
                  completeNow.text = ZLocUtils.t("Dialogs","CompleteNow");
               }
            }
         }
      }
      
      protected function onBuyPartCallback(event:MouseEvent) : void
      {
         m_itemToBuy = Global.farmGameSettingsManager.getFarmItemByName(getItemNameFromEvent(event));
         var messageText:String = ZLocUtils.t("Dialogs","ConstructionBuilding_BuyConfirmation",{
            "item":ZLocUtils.tk_pk(m_itemToBuy.friendlyName),
            "cashQuantity":m_itemToBuy.cash
         });
         UI.displayPopup(new GenericPopup(messageText,GenericPopup.TYPE_ACCEPTCANCEL,this.onBuyPartAcceptCallback),false);
      }
      
      protected function onBuyPartAcceptCallback(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT && m_itemToBuy != null)
         {
            if(Global.player.canBuyCash(m_itemToBuy.cash,true))
            {
               BuildingItemUseMediator.getInstance().mediate(m_itemToBuy.name,false,this.m_building);
               close();
            }
         }
      }
      
      protected function onCompleteNowCallback(event:MouseEvent) : void
      {
         m_cashNeeded = calculateCashNeeded();
         pushNewData();
         var buildingName:String = m_building.getItemFriendlyName();
         UI.displayMessage(ZLocUtils.t("Dialogs","FinishConstructionBuildingPopup",{
            "cashQuantity":m_cashNeeded,
            "item":ZLocUtils.tk_pk(buildingName)
         }),GenericPopup.TYPE_ACCEPTCANCEL,this.onCompleteNowAcceptCallback);
         onClickClose(event);
      }
      
      protected function onCompleteNowAcceptCallback(event:GenericPopupEvent) : void
      {
         var data:Object = null;
         var buildingPart:BuildingPart = null;
         var parts:int = 0;
         if(event.button == GenericPopup.ACCEPT && m_cashNeeded > 0)
         {
            this.m_displayStorageDialog = false;
            if(Global.player.canBuyCash(m_cashNeeded))
            {
               for each(data in m_data)
               {
                  if(data.sendGiftsToFriends == false)
                  {
                     if(data.currentCount < data.needCount)
                     {
                        buildingPart = new BuildingPart(data.name);
                        for(parts = int(data.currentCount); parts < data.needCount; parts++)
                        {
                           m_building.addItem(buildingPart,0,false,false);
                        }
                     }
                  }
               }
               FarmStatsManager.count("fv_cash_buy","building","nurserybarn_expansion_finished",m_cashNeeded.toString());
               TransactionManager.addTransaction(new TCompleteNow(m_building));
               Global.player.cash -= m_cashNeeded;
            }
            close();
         }
      }
   }
}

