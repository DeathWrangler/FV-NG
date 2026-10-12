package Display
{
   import Classes.BuildingItemUseMediator;
   import Classes.BuildingPart;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.storage.PartItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Transactions.TCompleteNow;
   import flash.events.MouseEvent;
   
   public class SpringGardenBuildable2011FrameConstructionWithdrawal extends SpringGardenBuildable2011Dialog
   {
      
      public function SpringGardenBuildable2011FrameConstructionWithdrawal(building:StorageBuilding)
      {
         super(building);
         this.checkForWhatIsThisDialogAutoPop();
      }
      
      override protected function pushNewData() : void
      {
         var object:Object = null;
         var partItem:PartItem = null;
         var sendGitfsObject:Object = null;
         var giftItem:FarmItem = null;
         var giftNum:Number = NaN;
         m_data = [];
         m_tileSet = 0;
         m_usedTypes = new Object();
         var objects:Array = m_building.getConstructionItems();
         var sumOfParts:int = 0;
         var sumOfNeededParts:int = 0;
         if(objects)
         {
            for each(partItem in objects)
            {
               object = new Object();
               giftItem = partItem.item;
               giftNum = partItem.onHand;
               if(m_usedTypes[giftItem.code] == null)
               {
                  object.sendGiftsToFriends = false;
                  object.name = giftItem.name;
                  object.code = giftItem.code;
                  object.type = giftItem.type;
                  object.friendlyName = giftItem.friendlyName;
                  object.cost = giftItem.cost;
                  object.currentCount = partItem.onHand;
                  object.needCount = partItem.qtyNeeded;
                  sumOfNeededParts += partItem.qtyNeeded;
                  m_usedTypes[giftItem.code] = giftNum;
                  sumOfParts += giftNum;
                  m_data.push(object);
               }
               else
               {
                  m_usedTypes[giftItem.code] += 1;
                  sumOfParts += 1;
               }
            }
            sendGitfsObject = new Object();
            sendGitfsObject.sendGiftsToFriends = true;
            m_data.push(sendGitfsObject);
            this.refreshProgressMeter();
            m_window.main_mc.decorationStage1_mc.visible = true;
            m_window.main_mc.decorationStage2_mc.visible = false;
            m_window.main_mc.decorationStage3_mc.visible = false;
         }
      }
      
      override public function show() : void
      {
         if(m_building.isFullyBuilt())
         {
            close();
         }
         else
         {
            super.show();
         }
      }
      
      override protected function refreshProgressMeter() : void
      {
         var inventoryCount:Object = getCurVsTotalPartsNeeded();
         m_window.main_mc.meter_0_mc.bar_mc.scaleX = inventoryCount.currentTotal / inventoryCount.neededTotal;
         m_window.main_mc.meter_1_mc.bar_mc.width = 0;
         m_window.main_mc.meter_2_mc.bar_mc.width = 0;
      }
      
      override protected function onCompleteNowCallback(event:MouseEvent = null) : void
      {
         if(!event)
         {
            event = new MouseEvent(MouseEvent.CLICK);
         }
         m_cashNeeded = calculateCashNeeded();
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
               TransactionManager.addTransaction(new TCompleteNow(m_building));
               Global.player.cash -= m_cashNeeded;
            }
            close();
         }
      }
      
      override protected function buyPartAndUpdateUI() : void
      {
         if(Global.player.canBuyCash(m_itemToBuy.cash,true))
         {
            BuildingItemUseMediator.getInstance().mediate(m_itemToBuy.name,false,m_building);
            close();
         }
      }
      
      public function checkForWhatIsThisDialogAutoPop() : void
      {
         if(!this.hasUserSeenWhatIsThisDialog())
         {
            this.setUserSeenWhatIsThisDialog();
            m_showWhatIsThisOnLoad = true;
         }
      }
      
      public function hasUserSeenWhatIsThisDialog() : Boolean
      {
         return Global.player.getSeenFlag(m_building.getItemName() + "WhatIsThisOpened");
      }
      
      public function setUserSeenWhatIsThisDialog() : void
      {
         Global.player.setSeenFlag(m_building.getItemName() + "WhatIsThisOpened");
      }
   }
}

