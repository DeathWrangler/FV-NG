package Display
{
   import Classes.BuildingItemUseMediator;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.storage.PartItem;
   import Classes.util.ZLocUtils;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class HalloweenHauntedHouseConstructionWithdrawal extends ConstructionBuildingWithdrawal
   {
      
      private const PROGRESS_BAR_WIDTH:int = 90;
      
      public function HalloweenHauntedHouseConstructionWithdrawal(storage:StorageBuilding)
      {
         m_dialogAsset = "assets/dialogs/FV_Construct_4cell_HalloweenS1.swf";
         super(storage);
         m_dialogType = "HalloweenHauntedHouse";
      }
      
      override protected function onLoadComplete() : void
      {
         var gb:GenericButton = null;
         m_window = m_loader.content as MovieClip;
         var main_mc:MovieClip = m_window.main_mc;
         var cancelBtn:GenericButton = new GenericButton(main_mc.close_bt,onClickClose);
         cancelBtn.m_overlay.name = "Cancel";
         cancelBtn.text = ZLocUtils.t("Dialogs","ReturnToFarm");
         main_mc.title_tf.text = ZLocUtils.tk_pk_asTitle(m_building.getItemFriendlyName());
         main_mc.description_tf.text = ZLocUtils.t("Dialogs","HalloweenHauntedHouse_description");
         main_mc.levelName1_tf.text = ZLocUtils.t("Dialogs","HalloweenHauntedHouse_modifier_level_1");
         main_mc.levelName2_tf.text = ZLocUtils.t("Dialogs","HalloweenHauntedHouse_modifier_level_2");
         main_mc.levelName3_tf.text = ZLocUtils.t("Dialogs","HalloweenHauntedHouse_modifier_level_3");
         if(main_mc.hasOwnProperty("whatisthis_mc") && Boolean(main_mc.whatisthis_mc))
         {
            gb = new GenericButton(main_mc.whatisthis_mc,onClickHowDoesThisWork);
            gb.m_overlay.name = "WhatIsThisBtn";
            gb.text = ZLocUtils.t("Dialogs","WhatIsThis");
         }
         m_tiles = new Array(main_mc.slot_0_mc,main_mc.slot_1_mc,main_mc.slot_2_mc,main_mc.slot_3_mc);
         removeTiles();
         this.pushNewData();
         m_cashNeeded = calculateCashNeeded();
         var compIdx:int = 0;
         while(compIdx < getNumSlots() && compIdx < m_data.length)
         {
            this.addComponent(compIdx);
            compIdx++;
         }
         addChild(main_mc);
         var featureFlag:String = "construct" + m_dialogType;
         var lastShown:Number = Global.player.getFeatureLastShown(featureFlag);
         var featureFrequency:Number = Global.farmGameSettingsManager.getNumber("HauntedHouseConstructionWhatIsThisFrequency",2920000);
         var currentTime:int = GlobalEngine.serverTime / 1000;
         if(currentTime > lastShown + featureFrequency)
         {
            Global.player.setFeatureLastShown(featureFlag,currentTime,true);
            onClickHowDoesThisWork();
         }
      }
      
      override protected function pushNewData() : void
      {
         var object:Object = null;
         var partItem:PartItem = null;
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
                  object.need = partItem.qtyNeeded;
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
            object = new Object();
            object.sendGiftsToFriends = true;
            m_data.push(object);
            m_window.main_mc.meter_mc.bar_mc.width = this.PROGRESS_BAR_WIDTH * sumOfParts / sumOfNeededParts;
         }
      }
      
      override protected function addComponent(compId:int, index:int = 0) : void
      {
         var tile:MovieClip = null;
         var data:Object = null;
         var getThis:AskForMoreButton = null;
         var buyButton:GenericButton = null;
         var finishButton:GenericButton = null;
         var sendButton:GenericButton = null;
         if(Boolean(m_tiles) && m_data[index + compId] != null)
         {
            tile = m_tiles[compId] as MovieClip;
            data = m_data[index + compId];
            tile.visible = true;
            tile.use_bt.visible = false;
            if(data.sendGiftsToFriends == false)
            {
               tile.itemTitle_tf.visible = true;
               tile.itemTitle_tf.text = ZLocUtils.tk_pk_asTitle(data.friendlyName);
               tile.alive_tf.visible = true;
               tile.alive_tf.text = ZLocUtils.t("Dialogs","ConstructionBuildingMatCount",{
                  "quantity":m_usedTypes[data.code],
                  "maximum":data.need
               });
               tile.iconBox_mc.visible = true;
               if(m_usedTypes[data.code] == data.need)
               {
                  ZLocUtils.setText(tile,"completeIcon_mc.completed_tf","Dialogs","GenericExpansion_completed_text");
                  tile.completeIcon_mc.visible = true;
                  tile.completeNow_bt.visible = false;
                  tile.getThis_bt.visible = false;
                  tile.buy_bt.visible = false;
               }
               else
               {
                  tile.completeIcon_mc.visible = false;
                  tile.completeNow_bt.visible = false;
                  tile.getThis_bt.visible = true;
                  getThis = null;
                  getThis = new AskForMoreButton(tile.getThis_bt,onGetThisCallback);
                  getThis.m_overlay.name = "GetThis_" + data.code;
                  getThis.text = ZLocUtils.t("Dialogs","AskForMore");
                  if(getThisGreyOut() || !isAskSendEnabled())
                  {
                     getThis.greyOut();
                  }
                  buyButton = new GenericButton(tile.buy_bt,this.onBuyCallback);
                  buyButton.text = ZLocUtils.t("Dialogs","Buy");
                  if(!isAskSendEnabled())
                  {
                     buyButton.turnOff();
                  }
               }
               tile.sendMaterials_tf.visible = false;
               tile.present_bt.visible = false;
               addIcon(data.name,"icon",tile,tile.icon);
            }
            else
            {
               tile.itemTitle_tf.visible = false;
               tile.alive_tf.visible = false;
               tile.completeIcon_mc.visible = false;
               tile.getThis_bt.visible = false;
               tile.sendMaterials_tf.visible = true;
               tile.present_bt.visible = true;
               tile.buy_bt.visible = false;
               tile.completeNow_bt.visible = true;
               tile.iconBox_mc.visible = false;
               finishButton = new GenericButton(tile.completeNow_bt,onFinishConstructionCallback);
               finishButton.text = ZLocUtils.t("Dialogs","CompleteNow");
               sendButton = new GenericButton(tile.present_bt,this.onShowGiftingOverlay);
               sendButton.text = ZLocUtils.t("Dialogs","SendGiftsBig");
            }
         }
      }
      
      override protected function onBuyCallback(event:MouseEvent) : void
      {
         m_itemToBuy = Global.farmGameSettingsManager.getFarmItemByName(getItemNameFromEvent(event));
         var messageText:String = ZLocUtils.t("Dialogs","ConstructionBuilding_BuyConfirmation",{
            "item":ZLocUtils.tk_pk(m_itemToBuy.friendlyName),
            "cashQuantity":m_itemToBuy.cash
         });
         UI.displayPopup(new GenericPopup(messageText,GenericPopup.TYPE_ACCEPTCANCEL,this.buyConfirmationHandler),false);
      }
      
      override protected function buyConfirmationHandler(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT && m_itemToBuy != null)
         {
            FarmStatsManager.count("Constructable","ui_button_click",m_building.getItem().name,"buy_part","accept");
            if(Global.player.canBuyCash(m_itemToBuy.cash,true))
            {
               BuildingItemUseMediator.getInstance().mediate(m_itemToBuy.name);
               close();
            }
         }
         else
         {
            FarmStatsManager.count("Constructable","ui_button_click",m_building.getItem().name,"buy_part","cancel");
         }
      }
      
      protected function onShowGiftingOverlay(event:MouseEvent) : void
      {
         FarmStatsManager.count("Constructable","ui_button_click",m_building.getItem().name,"send_gift");
         super.showGiftingOverlay();
      }
   }
}

