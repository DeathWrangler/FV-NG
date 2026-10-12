package Display
{
   import Classes.BuildingItemUseMediator;
   import Classes.BuildingPart;
   import Classes.Constants.MFSConstants;
   import Classes.FeatureDataObjects.BuildingExpansionData;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.MFSRequestManager;
   import Transactions.TCompleteNow;
   import Widgets.Windows.FreeGiftSelectionWindow;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class HalloweenCastleDuckulaWithdrawal extends ConstructionBuildingWithdrawal
   {
      
      private static const BAR_MC_WIDTH:int = 120;
      
      private var m_genericButtons:Object = new Object();
      
      private var m_price:Number = 1;
      
      private var m_frictionless:Boolean = false;
      
      public function HalloweenCastleDuckulaWithdrawal(storage:StorageBuilding, defaultAction:String = "")
      {
         m_dialogAsset = "assets/dialogs/FV_Halloween_Buildable.swf";
         super(storage);
         m_dialogType = "HalloweenCastleDuckula_complete";
      }
      
      override protected function onLoadComplete() : void
      {
         var gb:GenericButton = null;
         m_window = m_loader.content as MovieClip;
         var main_mc:MovieClip = m_window.main_mc;
         var cancelBtn:GenericButton = new GenericButton(main_mc.close_bt,onClickClose);
         cancelBtn.m_overlay.name = "Cancel";
         main_mc.title_tf.text = ZLocUtils.tk_pk_asTitle(m_building.getItemFriendlyName());
         main_mc.title2_tf.text = "\"" + ZLocUtils.t("Dialogs","HalloweenCastleDuckula_modifier_level_" + m_building.storageLevel.toString(),{"item":""}) + "\"";
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
         m_cashNeeded = this.calculateCashNeeded(this.m_price);
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
         m_window = m_loader.content as MovieClip;
         this.shareExpansion();
      }
      
      override protected function setupCapacityBox() : void
      {
         if(Boolean(m_window.gifts_mc.hasOwnProperty("capacity_tf")) && Boolean(m_window.gifts_mc.hasOwnProperty("current_tf")))
         {
            ZLocUtils.setText(m_window,"gifts_mc.capacity_tf","Dialogs","Capacity",{"quantity":m_building.capacity});
            ZLocUtils.setText(m_window,"gifts_mc.current_tf","Dialogs","Current",{"quantity":m_building.count});
         }
      }
      
      private function setButtonState(buttonId:String, state:String) : void
      {
         var button:GenericButton = this.m_genericButtons[buttonId] as GenericButton;
         if(button)
         {
            button.state = state;
         }
      }
      
      override protected function pushNewData() : void
      {
         var buildingExpansionData:BuildingExpansionData = null;
         var upgradeDataSource:BaseDataSource = null;
         var partDataArray:Array = null;
         var partDataSource:BaseDataSource = null;
         var partFarmItem:FarmItem = null;
         var partDataObject:Object = null;
         var upgradeData:XML = null;
         var partXml:XML = null;
         var object:Object = null;
         var partItem:FarmItem = null;
         var partData:Object = null;
         m_data = [];
         m_tileSet = 0;
         var sumOfParts:int = 0;
         if(StorageBuilding.isDynamicPartsExperimentOn())
         {
            buildingExpansionData = m_building.getNextBuildingExpansionData();
            if(Boolean(buildingExpansionData) && Boolean(buildingExpansionData.parts))
            {
               m_data = buildingExpansionData.generateWithdrawalUIData(m_building,true);
               sumOfParts = buildingExpansionData.getTotalPartsOnHand(m_building);
               this.setupProgressBar(sumOfParts / buildingExpansionData.matsNeeded);
            }
         }
         else if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            upgradeDataSource = m_building.getNextExpansionDataSource();
            if(upgradeDataSource)
            {
               partDataArray = upgradeDataSource.getArray("part");
               if(partDataArray.length > 0)
               {
                  for each(partDataSource in partDataArray)
                  {
                     partFarmItem = Global.farmGameSettingsManager.getFarmItemByName(partDataSource.getString("name"));
                     if(partFarmItem)
                     {
                        partDataObject = {};
                        partDataObject.sendGiftsToFriends = false;
                        partDataObject.itemCode = partFarmItem.code;
                        partDataObject.name = partFarmItem.name;
                        partDataObject.needCount = partDataSource.getInt("need");
                        partDataObject.currentCount = m_building.getExpansionPartCount(partFarmItem.code);
                        sumOfParts += partDataObject.currentCount;
                        partDataObject.friendlyName = partFarmItem.friendlyName;
                        partDataObject.icon = partFarmItem.icon;
                        partDataObject.cost = String(partFarmItem.cash);
                        m_data.push(partDataObject);
                     }
                  }
                  m_data.push({"sendGiftsToFriends":true});
                  this.setupProgressBar(sumOfParts / upgradeDataSource.getInt("matsNeeded"));
               }
            }
         }
         else
         {
            upgradeData = m_building.getNextExpansionData();
            if(Boolean(upgradeData) && Boolean(upgradeData.part))
            {
               for each(partXml in upgradeData.part)
               {
                  partItem = Global.farmGameSettingsManager.getFarmItemByName(partXml.@name);
                  if(partItem)
                  {
                     partData = new Object();
                     partData.sendGiftsToFriends = false;
                     partData.itemCode = partItem.code;
                     partData.name = partItem.name;
                     partData.needCount = parseInt(partXml.@need);
                     partData.currentCount = m_building.getExpansionPartCount(partItem.code);
                     sumOfParts += partData.currentCount;
                     partData.friendlyName = partItem.friendlyName;
                     partData.icon = partItem.icon;
                     partData.cost = String(partItem.cash);
                     m_data.push(partData);
                  }
               }
               object = new Object();
               object.sendGiftsToFriends = true;
               m_data.push(object);
               this.setupProgressBar(sumOfParts / int(upgradeData.@matsNeeded));
            }
         }
      }
      
      private function setupProgressBar(widthMultiplier:Number) : void
      {
         switch(m_building.storageLevel)
         {
            case 0:
               m_window.main_mc.meter_0_mc.bar_mc.width = BAR_MC_WIDTH * widthMultiplier;
               m_window.main_mc.meter_1_mc.bar_mc.width = 0;
               m_window.main_mc.meter_2_mc.bar_mc.width = 0;
               m_window.main_mc.meter_3_mc.bar_mc.width = 0;
               m_window.main_mc.meter_4_mc.bar_mc.width = 0;
               m_window.main_mc.meter_5_mc.bar_mc.width = 0;
               m_window.main_mc.decorationStage0_mc.visible = true;
               break;
            case 1:
               m_window.main_mc.meter_0_mc.bar_mc.width = BAR_MC_WIDTH;
               m_window.main_mc.meter_1_mc.bar_mc.width = BAR_MC_WIDTH * widthMultiplier;
               m_window.main_mc.meter_2_mc.bar_mc.width = 0;
               m_window.main_mc.meter_3_mc.bar_mc.width = 0;
               m_window.main_mc.meter_4_mc.bar_mc.width = 0;
               m_window.main_mc.meter_5_mc.bar_mc.width = 0;
               m_window.main_mc.decorationStage1_mc.visible = true;
               m_window.main_mc.progress1reveal_mc.visible = true;
               break;
            case 2:
               m_window.main_mc.meter_0_mc.bar_mc.width = BAR_MC_WIDTH;
               m_window.main_mc.meter_1_mc.bar_mc.width = BAR_MC_WIDTH;
               m_window.main_mc.meter_2_mc.bar_mc.width = BAR_MC_WIDTH * widthMultiplier;
               m_window.main_mc.meter_3_mc.bar_mc.width = 0;
               m_window.main_mc.meter_4_mc.bar_mc.width = 0;
               m_window.main_mc.meter_5_mc.bar_mc.width = 0;
               m_window.main_mc.decorationStage2_mc.visible = true;
               m_window.main_mc.progress2reveal_mc.visible = true;
               break;
            case 3:
               m_window.main_mc.meter_0_mc.bar_mc.width = BAR_MC_WIDTH;
               m_window.main_mc.meter_1_mc.bar_mc.width = BAR_MC_WIDTH;
               m_window.main_mc.meter_2_mc.bar_mc.width = BAR_MC_WIDTH;
               m_window.main_mc.meter_3_mc.bar_mc.width = BAR_MC_WIDTH * widthMultiplier;
               m_window.main_mc.meter_4_mc.bar_mc.width = 0;
               m_window.main_mc.meter_5_mc.bar_mc.width = 0;
               m_window.main_mc.decorationStage3_mc.visible = true;
               m_window.main_mc.progress3reveal_mc.visible = true;
               break;
            case 4:
               m_window.main_mc.meter_0_mc.bar_mc.width = BAR_MC_WIDTH;
               m_window.main_mc.meter_1_mc.bar_mc.width = BAR_MC_WIDTH;
               m_window.main_mc.meter_2_mc.bar_mc.width = BAR_MC_WIDTH;
               m_window.main_mc.meter_3_mc.bar_mc.width = BAR_MC_WIDTH;
               m_window.main_mc.meter_4_mc.bar_mc.width = BAR_MC_WIDTH * widthMultiplier;
               m_window.main_mc.meter_5_mc.bar_mc.width = 0;
               m_window.main_mc.decorationStage4_mc.visible = true;
               m_window.main_mc.progress4reveal_mc.visible = true;
               break;
            case 5:
               m_window.main_mc.meter_0_mc.bar_mc.width = BAR_MC_WIDTH;
               m_window.main_mc.meter_1_mc.bar_mc.width = BAR_MC_WIDTH;
               m_window.main_mc.meter_2_mc.bar_mc.width = BAR_MC_WIDTH;
               m_window.main_mc.meter_3_mc.bar_mc.width = BAR_MC_WIDTH;
               m_window.main_mc.meter_4_mc.bar_mc.width = BAR_MC_WIDTH;
               m_window.main_mc.meter_5_mc.bar_mc.width = BAR_MC_WIDTH * widthMultiplier;
               m_window.main_mc.decorationStage5_mc.visible = true;
               m_window.main_mc.progress5reveal_mc.visible = true;
               break;
            default:
               m_window.main_mc.meter_0_mc.bar_mc.width = BAR_MC_WIDTH;
               m_window.main_mc.meter_1_mc.bar_mc.width = BAR_MC_WIDTH;
               m_window.main_mc.meter_2_mc.bar_mc.width = BAR_MC_WIDTH;
               m_window.main_mc.meter_3_mc.bar_mc.width = BAR_MC_WIDTH;
               m_window.main_mc.meter_4_mc.bar_mc.width = BAR_MC_WIDTH;
               m_window.main_mc.meter_5_mc.bar_mc.width = BAR_MC_WIDTH;
               m_window.main_mc.decorationStage6_mc.visible = true;
               m_window.main_mc.progress6reveal_mc.visible = true;
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
         var sendGifts:GenericButton = null;
         var completeNow:GenericButton = null;
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
               tile.itemTitle_tf.text = ZLocUtils.tk_pk_asTitle(data.friendlyName);
               tile.alive_tf.text = ZLocUtils.t("Dialogs","ConstructionBuildingMatCount",{
                  "quantity":data.currentCount,
                  "maximum":data.needCount
               });
               addIcon(data.name,"icon",tile,tile.icon);
               if(data.currentCount >= data.needCount)
               {
                  ZLocUtils.setText(tile,"completeIcon_mc.completed_tf","Dialogs","GenericExpansion_completed_text");
                  tile.completeNow_bt.visible = false;
                  tile.getThis_bt.visible = false;
                  tile.buy2_bt.visible = false;
                  tile.sendMaterials_tf.visible = false;
                  tile.present_bt.visible = false;
                  tile.fcPrice_mc.visible = false;
               }
               else
               {
                  tile.sendMaterials_tf.visible = false;
                  tile.buy_bt.visible = false;
                  tile.present_bt.visible = false;
                  tile.completeIcon_mc.visible = false;
                  tile.fcPrice_mc.FCPrice_tf.text = String(this.m_price);
                  getThis = new AskForMoreButton(tile.getThis_bt,this.onAskMoreCallback);
                  getThis.text = ZLocUtils.t("Dialogs","AskForMore");
                  if(getThisGreyOut())
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
                     tile.fcPrice_mc.FCPrice_tf.text = String(this.m_price * (data.needCount - data.currentCount));
                     tile.buy2_bt.visible = false;
                     buyRestButton = new GenericButton(tile.completeNow_bt,this.onBuyRemainderCallback);
                     buyRestButton.text = "Buy Remainder";
                  }
                  else
                  {
                     tile.fcPrice_mc.FCPrice_tf.text = String(this.m_price);
                     tile.completeNow_bt.visible = false;
                     buyButton = new GenericButton(tile.buy2_bt,this.onBuyPartCallback);
                     buyButton.text = ZLocUtils.t("Dialogs","Buy");
                  }
               }
            }
            else
            {
               tile.itemTitle_tf.visible = false;
               tile.alive_tf.visible = false;
               tile.completeIcon_mc.visible = false;
               tile.getThis_bt.visible = false;
               tile.iconBox_mc.visible = false;
               tile.buy_bt.visible = false;
               tile.buy2_bt.visible = false;
               tile.completeNow_bt.visible = true;
               tile.sendMaterials_tf.text = ZLocUtils.t("Dialogs","SendMaterials");
               sendGifts = new GenericButton(tile.present_bt,this.onSendPresentsCallback);
               sendGifts.m_overlay.name = "SendGifts";
               sendGifts.text = ZLocUtils.t("Dialogs","SendGiftsBig");
               tile.fcPrice_mc.FCPrice_tf.text = String(this.calculateCashNeeded(this.m_price));
               completeNow = new GenericButton(tile.completeNow_bt,this.onCompleteNowCallback);
               completeNow.text = ZLocUtils.t("Dialogs","CompleteNow");
            }
         }
      }
      
      override protected function calculateCashNeeded(partcost:int = 1) : int
      {
         var result:int = 0;
         for(var index:int = 0; index < m_data.length; index++)
         {
            if(!m_data[index].sendGiftsToFriends)
            {
               result += (m_data[index].needCount - m_data[index].currentCount) * partcost;
            }
         }
         return result;
      }
      
      protected function onBuyPartCallback(event:MouseEvent) : void
      {
         m_itemToBuy = Global.farmGameSettingsManager.getFarmItemByName(getItemNameFromEvent(event));
         FarmStatsManager.count("Constructable","ui_button_click","level" + m_building.storageLevel.toString() + "halloweencastle","buy_part",m_itemToBuy.cash.toString());
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
            if(object.name == m_itemToBuy.name)
            {
               amount = object.needCount - object.currentCount;
               break;
            }
         }
         cost = m_itemToBuy.cash * amount;
         if(Global.player.canBuyCash(cost,true))
         {
            BuildingItemUseMediator.getInstance().mediate(m_itemToBuy.name,false,null,false,true,amount);
         }
         close();
      }
      
      protected function onUsePartCallback(event:MouseEvent) : void
      {
         var itemName:String = getItemNameFromEvent(event);
         if(!Global.player.getSeenFlag("place_item_duckulas_castle_first_time_level_" + m_building.storageLevel.toString()))
         {
            Global.player.setSeenFlag("place_item_in_duckulas_castle_first_time_level_" + m_building.storageLevel.toString());
            FarmStatsManager.count("Constructable","upgrade_structure","level" + m_building.storageLevel.toString() + "halloweencastle");
         }
         m_itemToBuy = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         if(m_itemToBuy != null && Global.player.canBuyCash(m_itemToBuy.cash,true))
         {
            BuildingItemUseMediator.getInstance().mediate(m_itemToBuy.name,true,m_building,true);
            close();
            m_building.displayStorageDialog();
         }
      }
      
      protected function onBuyPartAcceptCallback(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT && m_itemToBuy != null)
         {
            FarmStatsManager.count("Constructable","ui_button_click",m_building.getItem().name + m_building.storageLevel.toString(),"buy_part","accept");
            if(Global.player.canBuyCash(m_itemToBuy.cash,true))
            {
               BuildingItemUseMediator.getInstance().mediate(m_itemToBuy.name);
               close();
            }
         }
         else
         {
            FarmStatsManager.count("Constructable","ui_button_click",m_building.getItem().name + m_building.storageLevel.toString(),"buy_part","cancel");
         }
      }
      
      override protected function onSendPresentsCallback(event:MouseEvent) : void
      {
         FarmStatsManager.count("Constructable","ui_button_click","level" + m_building.storageLevel.toString() + "halloweencastle","send_gift");
         close();
         FreeGiftSelectionWindow.popWindow();
      }
      
      protected function onCompleteNowCallback(event:MouseEvent) : void
      {
         var data:Object = null;
         var buildingPart:BuildingPart = null;
         var parts:int = 0;
         FarmStatsManager.count("Constructable","ui_button_click","level" + m_building.storageLevel.toString() + "halloweencastle","complete_now");
         m_cashNeeded = this.calculateCashNeeded(this.m_price);
         FarmStatsManager.count("fv_cash_buy","duckula_castle","duckula_castle_" + m_building.storageLevel.toString() + "_upgrade_complete",m_cashNeeded.toString());
         var buildingName:String = m_building.getItemFriendlyName();
         if(m_cashNeeded > 0)
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
               FarmStatsManager.count("fv_cash_buy","complete_now",m_building.getItem().name + m_building.storageLevel.toString(),m_cashNeeded.toString());
               TransactionManager.addTransaction(new TCompleteNow(m_building));
               Global.player.cash -= m_cashNeeded;
            }
            close();
         }
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
               FarmStatsManager.count("fv_cash_buy","complete_now",m_building.getItem().name + m_building.storageLevel.toString(),m_cashNeeded.toString());
               TransactionManager.addTransaction(new TCompleteNow(m_building));
               Global.player.cash -= m_cashNeeded;
            }
            close();
         }
      }
      
      protected function onAskMoreCallback(event:MouseEvent) : void
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(getItemNameFromEvent(event));
         MFSRequestManager.getInstance().makeAskMatsRequest(m_building.getItem().name,item.name,"","",MFSConstants.SOURCE_DIALOG_CLICKED,CONSTRUCTABLE_STATS_COUNTER,"ui_button_click","level" + m_building.storageLevel.toString() + "halloweencastle","ask_for_more");
      }
      
      private function shareExpansion() : void
      {
         var message:String = null;
         var dialog:GenericIconPopup = null;
         var featureFlag:String = "expand" + m_dialogType + m_building.storageLevel;
         var lastShown:Number = Global.player.getFeatureLastShown(featureFlag);
         var featureFrequency:Number = Global.farmGameSettingsManager.getNumber("CastleDuckulaExpandStartFeedFeatureFrequency",864000);
         var currentTime:int = GlobalEngine.serverTime / 1000;
         if(!m_building.getTotalExpansionPartCount() && currentTime > lastShown + featureFrequency)
         {
            message = ZLocUtils.t("Dialogs",m_dialogType + "ExpandMessage");
            dialog = new GenericIconPopup(message,GenericPopup.TYPE_SHARECANCEL,this.onShareExpansion,this.getExpandFeedImage());
            dialog.setTrackerKey("feed-castleduckula-upgrade_started");
            UI.displayPopup(dialog,false);
            Global.player.setFeatureLastShown(featureFlag,currentTime,true);
         }
      }
      
      private function onShareExpansion(event:GenericPopupEvent) : void
      {
         var rewardLink:String = null;
         var bundleData:Object = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            rewardLink = "gifts.php?giftRecipient=" + Global.player.snUser.uid;
            bundleData = {
               "reward_link":rewardLink,
               "images":[{
                  "href":"{SN_APP_URL}" + rewardLink,
                  "src":this.getExpandFeedImage()
               }]
            };
            FarmStatsManager.count("Feed","Feed","CREATIVE" + m_building.storageLevel.toString(),"HalloweenCastleDuckulaExpandAsk");
            GlobalEngine.socialNetwork.publishFeedStory("HalloweenCastleDuckulaExpandAsk",bundleData,[],false);
         }
      }
      
      private function getExpandFeedImage() : String
      {
         return Global.getAssetURL("assets/buildings/building_duckulascastle2011_finished_" + m_building.storageLevel.toString() + "_icon.png");
      }
   }
}

