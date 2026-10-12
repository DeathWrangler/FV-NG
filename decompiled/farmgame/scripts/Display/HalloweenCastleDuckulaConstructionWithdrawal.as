package Display
{
   import Classes.BuildingItemUseMediator;
   import Classes.ConstructionBuilding;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.storage.PartItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Transactions.TTransformBuilding;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class HalloweenCastleDuckulaConstructionWithdrawal extends ConstructionBuildingWithdrawal
   {
      
      private const PROGRESS_BAR_WIDTH:int = 120;
      
      private var m_price:Number = 1;
      
      private var m_frictionless:Boolean = false;
      
      public function HalloweenCastleDuckulaConstructionWithdrawal(storage:StorageBuilding)
      {
         m_dialogAsset = "assets/dialogs/FV_Halloween_Buildable.swf";
         super(storage);
         m_dialogType = "HalloweenCastleDuckula";
      }
      
      override protected function onLoadComplete() : void
      {
         var gb:GenericButton = null;
         m_window = m_loader.content as MovieClip;
         var main_mc:MovieClip = m_window.main_mc;
         var cancelBtn:GenericButton = new GenericButton(main_mc.close_bt,onClickClose);
         cancelBtn.m_overlay.name = "Cancel";
         main_mc.title_tf.text = ZLocUtils.tk_pk_asTitle(m_building.getItemFriendlyName());
         main_mc.title2_tf.text = "";
         var variant:int = Global.experimentManager.getExperimentVariant("fv_halloweencastle_frictionless");
         switch(variant)
         {
            case 1:
               this.m_frictionless = true;
               break;
            case 2:
               this.m_frictionless = false;
               break;
            case 3:
               this.m_frictionless = true;
               break;
            default:
               this.m_frictionless = false;
         }
         this.m_price = 1;
         main_mc.description_tf.text = ZLocUtils.t("Dialogs","HalloweenCastleDuckula_description");
         if(main_mc.hasOwnProperty("whatisthis_mc") && Boolean(main_mc.whatisthis_mc))
         {
            gb = new GenericButton(main_mc.whatisthis_mc,onClickHowDoesThisWork);
            gb.m_overlay.name = "WhatIsThisBtn";
            gb.text = ZLocUtils.t("Dialogs","WhatIsThis");
         }
         main_mc.decorationStage0_mc.visible = false;
         main_mc.decorationStage1_mc.visible = false;
         main_mc.decorationStage2_mc.visible = false;
         main_mc.decorationStage3_mc.visible = false;
         main_mc.decorationStage4_mc.visible = false;
         main_mc.decorationStage5_mc.visible = false;
         main_mc.decorationStage6_mc.visible = false;
         main_mc.progress1reveal_mc.visible = false;
         main_mc.progress2reveal_mc.visible = false;
         main_mc.progress3reveal_mc.visible = false;
         main_mc.progress4reveal_mc.visible = false;
         main_mc.progress5reveal_mc.visible = false;
         main_mc.progress6reveal_mc.visible = false;
         m_tiles = new Array(main_mc.giftPanel1,main_mc.giftPanel2,main_mc.giftPanel3,main_mc.giftPanel4);
         removeTiles();
         this.pushNewData();
         m_cashNeeded = calculateCashNeeded(this.m_price);
         var compIdx:int = 0;
         while(compIdx < getNumSlots() && compIdx < m_data.length)
         {
            this.addComponent(compIdx);
            compIdx++;
         }
         addChild(main_mc);
         var featureFlag:String = "construct" + m_dialogType;
         var lastShown:Number = Global.player.getFeatureLastShown(featureFlag);
         var featureFrequency:Number = Global.farmGameSettingsManager.getNumber("CastleDuckulaConstructionWhatIsThisFrequency",2920000);
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
               object.cost = this.m_price;
               if(m_usedTypes[giftItem.code] == null)
               {
                  object.sendGiftsToFriends = false;
                  object.name = giftItem.name;
                  object.code = giftItem.code;
                  object.type = giftItem.type;
                  object.count = giftNum;
                  object.friendlyName = giftItem.friendlyName;
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
            switch(m_building.storageLevel)
            {
               case 0:
                  m_window.main_mc.meter_0_mc.bar_mc.width = this.PROGRESS_BAR_WIDTH * sumOfParts / sumOfNeededParts;
                  m_window.main_mc.meter_1_mc.bar_mc.width = 0;
                  m_window.main_mc.meter_2_mc.bar_mc.width = 0;
                  m_window.main_mc.meter_3_mc.bar_mc.width = 0;
                  m_window.main_mc.meter_4_mc.bar_mc.width = 0;
                  m_window.main_mc.meter_5_mc.bar_mc.width = 0;
                  m_window.main_mc.decorationStage0_mc.visible = true;
                  break;
               case 1:
                  m_window.main_mc.meter_0_mc.bar_mc.width = this.PROGRESS_BAR_WIDTH;
                  m_window.main_mc.meter_1_mc.bar_mc.width = this.PROGRESS_BAR_WIDTH * sumOfParts / sumOfNeededParts;
                  m_window.main_mc.meter_2_mc.bar_mc.width = 0;
                  m_window.main_mc.meter_3_mc.bar_mc.width = 0;
                  m_window.main_mc.meter_4_mc.bar_mc.width = 0;
                  m_window.main_mc.meter_5_mc.bar_mc.width = 0;
                  m_window.main_mc.decorationStage1_mc.visible = true;
                  break;
               case 2:
                  m_window.main_mc.meter_0_mc.bar_mc.width = this.PROGRESS_BAR_WIDTH;
                  m_window.main_mc.meter_1_mc.bar_mc.width = this.PROGRESS_BAR_WIDTH;
                  m_window.main_mc.meter_2_mc.bar_mc.width = this.PROGRESS_BAR_WIDTH * sumOfParts / sumOfNeededParts;
                  m_window.main_mc.meter_3_mc.bar_mc.width = 0;
                  m_window.main_mc.meter_4_mc.bar_mc.width = 0;
                  m_window.main_mc.meter_5_mc.bar_mc.width = 0;
                  m_window.main_mc.decorationStage2_mc.visible = true;
                  break;
               case 3:
                  m_window.main_mc.meter_0_mc.bar_mc.width = this.PROGRESS_BAR_WIDTH;
                  m_window.main_mc.meter_1_mc.bar_mc.width = this.PROGRESS_BAR_WIDTH;
                  m_window.main_mc.meter_2_mc.bar_mc.width = this.PROGRESS_BAR_WIDTH;
                  m_window.main_mc.meter_3_mc.bar_mc.width = this.PROGRESS_BAR_WIDTH * sumOfParts / sumOfNeededParts;
                  m_window.main_mc.meter_4_mc.bar_mc.width = 0;
                  m_window.main_mc.meter_5_mc.bar_mc.width = 0;
                  m_window.main_mc.decorationStage3_mc.visible = true;
                  break;
               case 4:
                  m_window.main_mc.meter_0_mc.bar_mc.width = this.PROGRESS_BAR_WIDTH;
                  m_window.main_mc.meter_1_mc.bar_mc.width = this.PROGRESS_BAR_WIDTH;
                  m_window.main_mc.meter_2_mc.bar_mc.width = this.PROGRESS_BAR_WIDTH;
                  m_window.main_mc.meter_3_mc.bar_mc.width = this.PROGRESS_BAR_WIDTH;
                  m_window.main_mc.meter_4_mc.bar_mc.width = this.PROGRESS_BAR_WIDTH * sumOfParts / sumOfNeededParts;
                  m_window.main_mc.meter_5_mc.bar_mc.width = 0;
                  m_window.main_mc.decorationStage4_mc.visible = true;
                  break;
               case 5:
                  m_window.main_mc.meter_0_mc.bar_mc.width = this.PROGRESS_BAR_WIDTH;
                  m_window.main_mc.meter_1_mc.bar_mc.width = this.PROGRESS_BAR_WIDTH;
                  m_window.main_mc.meter_2_mc.bar_mc.width = this.PROGRESS_BAR_WIDTH;
                  m_window.main_mc.meter_3_mc.bar_mc.width = this.PROGRESS_BAR_WIDTH;
                  m_window.main_mc.meter_4_mc.bar_mc.width = this.PROGRESS_BAR_WIDTH;
                  m_window.main_mc.meter_5_mc.bar_mc.width = this.PROGRESS_BAR_WIDTH * sumOfParts / sumOfNeededParts;
                  m_window.main_mc.decorationStage5_mc.visible = true;
                  break;
               default:
                  m_window.main_mc.meter_0_mc.bar_mc.width = this.PROGRESS_BAR_WIDTH;
                  m_window.main_mc.meter_1_mc.bar_mc.width = this.PROGRESS_BAR_WIDTH;
                  m_window.main_mc.meter_2_mc.bar_mc.width = this.PROGRESS_BAR_WIDTH;
                  m_window.main_mc.meter_3_mc.bar_mc.width = this.PROGRESS_BAR_WIDTH;
                  m_window.main_mc.meter_4_mc.bar_mc.width = this.PROGRESS_BAR_WIDTH;
                  m_window.main_mc.meter_5_mc.bar_mc.width = this.PROGRESS_BAR_WIDTH;
                  m_window.main_mc.decorationStage6_mc.visible = true;
                  m_window.main_mc.progress6reveal_mc.visible = true;
            }
         }
      }
      
      override protected function addComponent(compId:int, index:int = 0) : void
      {
         var tile:MovieClip = null;
         var data:Object = null;
         var getThis:AskForMoreButton = null;
         var useMatButton:GenericButton = null;
         var buyRestButton:GenericButton = null;
         var buyButton:GenericButton = null;
         var finishButton:GenericButton = null;
         var sendButton:GenericButton = null;
         if(Boolean(m_tiles) && m_data[index + compId] != null)
         {
            tile = m_tiles[compId] as MovieClip;
            data = m_data[index + compId];
            tile.visible = true;
            tile.use_bt.visible = false;
            tile.use_mat_bt.visible = false;
            tile.buy_bt.visible = false;
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
                  tile.buy2_bt.visible = false;
                  tile.fcPrice_mc.visible = false;
               }
               else
               {
                  tile.completeIcon_mc.visible = false;
                  tile.getThis_bt.visible = true;
                  tile.buy_bt.visible = false;
                  getThis = null;
                  getThis = new AskForMoreButton(tile.getThis_bt,this.onGetThisCallback);
                  getThis.m_overlay.name = "GetThis_" + data.code;
                  getThis.text = ZLocUtils.t("Dialogs","AskForMore");
                  if(getThisGreyOut() || !isAskSendEnabled())
                  {
                     getThis.greyOut();
                  }
                  if(Boolean(tile.use_mat_bt) && Global.player.getGiftCountForItem(data.name) > 0)
                  {
                     tile.buy2_bt.visible = false;
                     tile.completeNow_bt.visible = false;
                     tile.use_mat_bt.visible = true;
                     tile.getThis_bt.visible = false;
                     tile.fcPrice_mc.visible = false;
                     useMatButton = new GenericButton(tile.use_mat_bt,this.onUsePartCallback);
                  }
                  else if(this.m_frictionless)
                  {
                     tile.fcPrice_mc.FCPrice_tf.text = String(this.m_price * (data.need - m_usedTypes[data.code]));
                     tile.buy2_bt.visible = false;
                     tile.completeNow_bt.visible = true;
                     buyRestButton = new GenericButton(tile.completeNow_bt,this.onBuyRemainderCallback);
                     buyRestButton.text = "Buy Remainder";
                  }
                  else
                  {
                     tile.fcPrice_mc.FCPrice_tf.text = String(this.m_price);
                     tile.completeNow_bt.visible = false;
                     buyButton = new GenericButton(tile.buy2_bt,this.onBuyCallback);
                     buyButton.text = ZLocUtils.t("Dialogs","Buy");
                     if(!isAskSendEnabled())
                     {
                        buyButton.turnOff();
                     }
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
               tile.buy2_bt.visible = false;
               tile.completeNow_bt.visible = true;
               tile.iconBox_mc.visible = false;
               finishButton = new GenericButton(tile.completeNow_bt,this.onFinishConstructionFrictionless);
               finishButton.text = ZLocUtils.t("Dialogs","CompleteNow");
               tile.fcPrice_mc.FCPrice_tf.text = String(calculateCashNeeded(this.m_price));
               sendButton = new GenericButton(tile.present_bt,this.onShowGiftingOverlay);
               sendButton.text = ZLocUtils.t("Dialogs","SendGiftsBig");
            }
         }
      }
      
      override protected function onBuyCallback(event:MouseEvent) : void
      {
         var itemName:String = getItemNameFromEvent(event);
         FarmStatsManager.count("Constructable","ui_button_click","level" + m_building.storageLevel.toString() + "halloweencastle","buy_part",this.m_price.toString());
         m_itemToBuy = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         if(Global.player.canBuyCash(m_itemToBuy.cash,true))
         {
            BuildingItemUseMediator.getInstance().mediate(m_itemToBuy.name);
            close();
         }
      }
      
      protected function onBuyRemainderCallback(event:MouseEvent) : void
      {
         var object:Object = null;
         var cost:Number = NaN;
         m_itemToBuy = Global.farmGameSettingsManager.getFarmItemByName(getItemNameFromEvent(event));
         FarmStatsManager.count("Constructable","ui_button_click","level" + m_building.storageLevel.toString() + "halloweencastle","buy_remainder_part",cost.toString());
         var amount:Number = 0;
         for each(object in m_data)
         {
            if(object.name == getItemNameFromEvent(event))
            {
               amount = object.need - object.count;
               break;
            }
         }
         cost = this.m_price * amount;
         if(Global.player.canBuyCash(cost,true))
         {
            BuildingItemUseMediator.getInstance().mediate(m_itemToBuy.name,false,null,false,true,amount);
         }
         close();
      }
      
      protected function onUsePartCallback(event:MouseEvent) : void
      {
         var itemName:String = getItemNameFromEvent(event);
         if(!Global.player.getSeenFlag("place_item_in_duckulas_castle_first_time"))
         {
            Global.player.setSeenFlag("place_item_in_duckulas_castle_first_time");
            FarmStatsManager.count("Constructable","place_item_in_structure_first_time","level" + m_building.storageLevel.toString() + "halloweencastle");
         }
         m_itemToBuy = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         if(m_itemToBuy != null && Global.player.canBuyCash(m_itemToBuy.cash,true))
         {
            BuildingItemUseMediator.getInstance().mediate(m_itemToBuy.name,true,m_building,true);
            close();
            m_building.displayStorageDialog();
         }
      }
      
      override protected function onGetThisCallback(event:MouseEvent) : void
      {
         FarmStatsManager.count("Constructable","ui_button_click","level" + m_building.storageLevel.toString() + "halloweencastle","ask_for_more");
         super.onGetThisCallback(event);
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
      
      protected function onFinishConstructionFrictionless(event:MouseEvent) : void
      {
         var newBuilding:Object = null;
         FarmStatsManager.count("Constructable","ui_button_click","level" + m_building.storageLevel.toString() + "halloweencastle","complete_now");
         FarmStatsManager.count("fv_cash_buy","duckula_castle","duckula_castle_complete",m_cashNeeded.toString());
         var buildingName:String = m_building.getItemFriendlyName();
         var cBuilding:ConstructionBuilding = m_building as ConstructionBuilding;
         if(cBuilding != null && Global.player.canBuyCash(m_cashNeeded))
         {
            newBuilding = cBuilding.transformBuilding() as Object;
            if(newBuilding)
            {
               Global.player.cash -= m_cashNeeded;
               TransactionManager.addTransaction(new TTransformBuilding(cBuilding));
            }
         }
         this.close();
      }
      
      override protected function onClickAcceptPopup(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.YES)
         {
            this.onFinishConstructionFrictionless(null);
         }
      }
      
      protected function onShowGiftingOverlay(event:MouseEvent) : void
      {
         FarmStatsManager.count("Constructable","ui_button_click","level" + m_building.storageLevel.toString() + "halloweencastle","send_gift");
         super.showGiftingOverlay();
      }
   }
}

