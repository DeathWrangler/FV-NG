package Display
{
   import Classes.BuildingItemUseMediator;
   import Classes.BuildingPart;
   import Classes.FeatureBuilding;
   import Classes.FeatureDataObjects.BuildingExpansionData;
   import Classes.IUser;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Engine.Classes.SocialNetworkUser;
   import Engine.Managers.TransactionManager;
   import Events.CloseEvent;
   import Events.GenericPopupEvent;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.SnowballFightManager;
   import Transactions.TCompleteNow;
   import Transactions.TGetEligibleW2WRecipients;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import gs.TweenLite;
   
   public class Snowman2010Dialog extends ConstructionBuildingWithdrawal
   {
      
      private static const STORAGE_LEVEL_1:int = 1;
      
      private static const STORAGE_LEVEL_2:int = 2;
      
      protected static const BAR_WIDTH:int = 60;
      
      private static const MATERIAL_RISE_TWEEN_TIME:Number = 3;
      
      private var m_genericButtons:Object = new Object();
      
      private var m_friendSelector:FriendSelector;
      
      private var m_enabled:Boolean = true;
      
      private var m_lockOverlay:Sprite;
      
      private var m_rewardLinksHash:Object = {};
      
      public function Snowman2010Dialog(building:StorageBuilding)
      {
         m_dialogAsset = "assets/dialogs/FV_Construct_Snowman.swf";
         m_dialogType = "Snowman2010_complete";
         super(building);
      }
      
      override protected function onLoadComplete() : void
      {
         var gb:GenericButton = null;
         m_window = m_loader.content as MovieClip;
         var main_mc:MovieClip = m_window.main_mc;
         m_window.main_mc.close_bt.addEventListener(MouseEvent.CLICK,onClickClose);
         main_mc.title_tf.text = ZLocUtils.tk_pk_asTitle(m_building.getItemFriendlyName());
         main_mc.level_0_tf.text = ZLocUtils.t("Dialogs","Snowman2010_Progress_Level0");
         main_mc.level_1_tf.text = ZLocUtils.t("Dialogs","Snowman2010_Progress_Level1");
         main_mc.level_2_tf.text = ZLocUtils.t("Dialogs","Snowman2010_Progress_Level2");
         main_mc.level_3_tf.text = ZLocUtils.t("Dialogs","Snowman2010_Progress_Level3");
         if(main_mc.hasOwnProperty("whatisthis_mc") && Boolean(main_mc.whatisthis_mc))
         {
            gb = new GenericButton(main_mc.whatisthis_mc,onClickHowDoesThisWork);
            gb.m_overlay.name = "WhatIsThisBtn";
            gb.text = ZLocUtils.t("Dialogs","WhatIsThis");
         }
         var completeNowCallback:Function = m_building.storageLevel == 0 ? onFinishConstructionCallback : this.onCompleteNowClick;
         var completeNow:GenericButton = new GenericButton(main_mc.complete_bt,completeNowCallback);
         completeNow.text = ZLocUtils.t("Dialogs","CompleteNow");
         m_tiles = new Array(main_mc.slot_0_mc,main_mc.slot_1_mc);
         removeTiles();
         this.pushNewData();
         m_cashNeeded = this.calculateCashNeeded();
         var compIdx:int = 0;
         while(compIdx < getNumSlots() && compIdx < m_data.length)
         {
            this.addComponent(compIdx);
            compIdx++;
         }
         addChild(main_mc);
         main_mc.gotoAndStop(m_building.storageLevel + 1);
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
         var partItem:FarmItem = null;
         var partData:Object = null;
         m_data = [];
         m_tileSet = 0;
         var sumOfParts:int = 0;
         var sumOfNeededParts:int = 0;
         if(StorageBuilding.isDynamicPartsExperimentOn())
         {
            buildingExpansionData = m_building.getNextBuildingExpansionData();
            if(Boolean(buildingExpansionData) && Boolean(buildingExpansionData.parts))
            {
               m_data = buildingExpansionData.generateWithdrawalUIData(m_building,false);
            }
            sumOfParts = buildingExpansionData.getTotalPartsOnHand(m_building);
            sumOfNeededParts = buildingExpansionData.matsNeeded;
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
                        partDataObject.friendlyName = partFarmItem.friendlyName;
                        partDataObject.icon = partFarmItem.icon;
                        m_data.push(partDataObject);
                     }
                  }
                  sumOfNeededParts = upgradeDataSource.getInt("matsNeeded");
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
                     partData.friendlyName = partItem.friendlyName;
                     partData.icon = partItem.icon;
                     m_data.push(partData);
                  }
               }
            }
            sumOfNeededParts = int(upgradeData.@matsNeeded);
         }
         if(sumOfNeededParts > 0)
         {
            if(m_building.storageLevel == STORAGE_LEVEL_1)
            {
               m_window.main_mc.meter_mc.bar_mc.width = sumOfParts / sumOfNeededParts * BAR_WIDTH + BAR_WIDTH;
            }
            if(m_building.storageLevel == STORAGE_LEVEL_2)
            {
               m_window.main_mc.meter_mc.bar_mc.width = sumOfParts / sumOfNeededParts * BAR_WIDTH + BAR_WIDTH * 2;
            }
         }
      }
      
      override protected function addComponent(compId:int, index:int = 0) : void
      {
         var data:Object = null;
         var tile:MovieClip = null;
         var getThis:AskForMoreButton = null;
         var buyButton:GenericButton = null;
         if(Boolean(m_tiles) && m_data[index + compId] != null)
         {
            data = m_data[index + compId];
            tile = m_tiles[compId] as MovieClip;
            tile.visible = true;
            tile.use_bt.visible = false;
            tile.itemTitle_tf.text = ZLocUtils.tk_pk_asTitle(data.friendlyName);
            tile.alive_tf.text = ZLocUtils.t("Dialogs","ConstructionBuildingMatCount",{
               "quantity":data.currentCount,
               "maximum":data.needCount
            });
            addIcon(data.name,"icon",tile,tile.icon);
            if(data.currentCount >= data.needCount)
            {
               ZLocUtils.setText(tile,"completeIcon_mc.completed_tf","Dialogs","GenericExpansion_completed_text");
               tile.completeIcon_mc.visible = true;
               tile.completeNow_bt.visible = false;
               tile.getThis_bt.visible = false;
               tile.buy_bt.visible = false;
               tile.sendMaterials_tf.visible = false;
               tile.present_bt.visible = false;
            }
            else
            {
               tile.sendMaterials_tf.visible = false;
               tile.present_bt.visible = false;
               tile.completeIcon_mc.visible = false;
               tile.completeNow_bt.visible = false;
               getThis = new AskForMoreButton(tile.getThis_bt,this.onAskForMoreClick);
               getThis.text = ZLocUtils.t("Dialogs","AskForMore");
               if(getThisGreyOut())
               {
                  getThis.greyOut();
               }
               buyButton = new GenericButton(tile.buy_bt,this.onBuyPartClick);
               buyButton.text = ZLocUtils.t("Dialogs","Buy");
            }
         }
      }
      
      override protected function calculateCashNeeded(partcost:int = 1) : int
      {
         var item:FarmItem = null;
         var result:int = 0;
         for(var index:int = 0; index < m_data.length; index++)
         {
            if(!m_data[index].sendGiftsToFriends)
            {
               item = Global.farmGameSettingsManager.getFarmItemByName(m_data[index].name);
               result += (m_data[index].needCount - m_data[index].currentCount) * item.cash;
            }
         }
         return result;
      }
      
      private function onBuyPartClick(event:MouseEvent) : void
      {
         m_itemToBuy = Global.farmGameSettingsManager.getFarmItemByName(getItemNameFromEvent(event));
         var messageText:String = ZLocUtils.t("Dialogs","ConstructionBuilding_BuyConfirmation",{
            "item":ZLocUtils.tk_pk(m_itemToBuy.friendlyName),
            "cashQuantity":m_itemToBuy.cash
         });
         UI.displayPopup(new GenericPopup(messageText,GenericPopup.TYPE_ACCEPTCANCEL,this.onBuyPartAcceptCallback),false);
         this.inputEnabled = false;
      }
      
      private function onBuyPartAcceptCallback(event:GenericPopupEvent) : void
      {
         this.inputEnabled = true;
         if(event.button == GenericPopup.ACCEPT && m_itemToBuy != null)
         {
            FarmStatsManager.count("Constructable","ui_button_click",m_building.getItem().name + m_building.storageLevel.toString(),"buy_part","accept");
            if(Global.player.canBuyCash(m_itemToBuy.cash,true))
            {
               this.buyPartAndUpdateUI();
            }
         }
         else
         {
            FarmStatsManager.count("Constructable","ui_button_click",m_building.getItem().name + m_building.storageLevel.toString(),"buy_part","cancel");
         }
      }
      
      protected function buyPartAndUpdateUI() : void
      {
         BuildingItemUseMediator.getInstance().mediate(m_itemToBuy.name,false,m_building);
         close();
         if(m_building is FeatureBuilding)
         {
            TweenLite.to(this,MATERIAL_RISE_TWEEN_TIME,{"onComplete":function():void
            {
               (m_building as FeatureBuilding).refreshStorageDialog();
            }});
         }
      }
      
      private function onCompleteNowClick(event:MouseEvent) : void
      {
         FarmStatsManager.count("Constructable","ui_button_click",m_building.getItem().name + m_building.storageLevel.toString(),"complete_now");
         m_cashNeeded = this.calculateCashNeeded();
         var buildingName:String = m_building.getItemFriendlyName();
         UI.displayMessage(ZLocUtils.t("Dialogs","FinishConstructionBuildingPopup",{
            "cashQuantity":m_cashNeeded,
            "item":ZLocUtils.tk_pk(buildingName)
         }),GenericPopup.TYPE_ACCEPTCANCEL,this.onCompleteNowAcceptCallback);
         onClickClose(event);
         this.inputEnabled = false;
      }
      
      private function onCompleteNowAcceptCallback(event:GenericPopupEvent) : void
      {
         var data:Object = null;
         var buildingPart:BuildingPart = null;
         var parts:int = 0;
         this.inputEnabled = true;
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
               TransactionManager.addTransaction(new TCompleteNow(m_building),true);
               Global.player.cash -= m_cashNeeded;
            }
            close();
         }
         else
         {
            m_building.displayStorageDialog();
         }
      }
      
      private function onAskForMoreClick(event:MouseEvent) : void
      {
         m_itemToBuy = Global.farmGameSettingsManager.getFarmItemByName(getItemNameFromEvent(event));
         FarmStatsManager.count("Constructable","ui_button_click",m_building.getItem().name + m_building.storageLevel.toString(),"ask_for_more");
         var transaction:TGetEligibleW2WRecipients = new TGetEligibleW2WRecipients(m_building.getItem().name,m_itemToBuy.name,this.getEligibleW2WRecipientsCallback);
         TransactionManager.addTransaction(transaction,true);
         this.inputEnabled = false;
      }
      
      private function getEligibleW2WRecipientsCallback(eligibleIds:Array, rewardLinks:Array) : void
      {
         var index:Number = NaN;
         var eligibleFriend:IUser = null;
         if(eligibleIds)
         {
            if(eligibleIds.length == rewardLinks.length)
            {
               for(index = 0; index < eligibleIds.length; index++)
               {
                  eligibleFriend = eligibleIds[index];
                  if(eligibleFriend != null)
                  {
                     this.m_rewardLinksHash[eligibleFriend.uid.toString()] = rewardLinks[index];
                  }
               }
            }
            this.m_friendSelector = new FriendSelector(false,0,0,false,this.onAskForMoreCallback,m_itemToBuy,eligibleIds,true,"assets/dialogs/FV_FriendChooser3.swf",m_building.getItem().name,m_itemToBuy.name);
            this.m_friendSelector.setCongratulations("Snowman2010_askForCongratulations");
            this.m_friendSelector.setTitle("Snowman2010_askForTitle",{"item":ZLocUtils.tk_pk(m_itemToBuy.friendlyName)});
            this.m_friendSelector.addEventListener(CloseEvent.CLOSE,this.onFriendSelectorClose);
            UI.displayPopup(this.m_friendSelector,false);
         }
         else
         {
            FarmStatsManager.count(SnowballFightManager.STAT_SNOWBALL,SnowballFightManager.STAT_ERROR_ELIGIBLE_RECIPIENTS);
            this.inputEnabled = true;
         }
      }
      
      private function onAskForMoreCallback(sendButton:MovieClip) : void
      {
         this.inputEnabled = true;
         var user:SocialNetworkUser = sendButton.snUser;
         var friendName:String = user.firstName;
         var friendId:String = user.uid;
         var rewardLink:String = "";
         if(this.m_rewardLinksHash != null)
         {
            rewardLink = this.m_rewardLinksHash[friendId];
         }
         var bundleData:Object = {
            "username":Global.player.name,
            "itemname":m_itemToBuy.friendlyName,
            "reward_link":rewardLink,
            "images":[{
               "href":"{SN_APP_URL}" + rewardLink,
               "src":m_itemToBuy.icon
            }]
         };
         GlobalEngine.socialNetwork.publishFeedStory("v",bundleData,[friendId],false);
         this.m_friendSelector.closeDialog();
         this.m_friendSelector.close();
      }
      
      private function onFriendSelectorClose(event:Event) : void
      {
         this.inputEnabled = true;
         this.m_rewardLinksHash = {};
      }
      
      private function set inputEnabled(enabled:Boolean) : void
      {
         this.m_enabled = enabled;
         if(this.m_enabled)
         {
            if(this.m_lockOverlay != null && contains(this.m_lockOverlay))
            {
               removeChild(this.m_lockOverlay);
            }
         }
         else
         {
            this.m_lockOverlay = new Sprite();
            this.m_lockOverlay.graphics.beginFill(0,0);
            this.m_lockOverlay.graphics.drawRect(0,0,width,height);
            addChild(this.m_lockOverlay);
         }
      }
   }
}

