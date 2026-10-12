package Display
{
   import Classes.BuildingItemUseMediator;
   import Classes.BuildingPart;
   import Classes.Constants.Experiments;
   import Classes.ConstructionBuilding;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.storage.PartItem;
   import Classes.util.PaymentUtil;
   import Classes.util.ZLocFailoverEntry;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Managers.InGamePaymentsManager;
   import Transactions.TRefreshBalance;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Windows.CustomFreeGiftSelectionWindow;
   import Widgets.Windows.Market.MarketPreviewWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class MultiStageConstructionFrameWithdrawal extends ConstructionBuildingWithdrawal
   {
      
      protected var m_buyButtons:Array = [];
      
      private var m_dialogConfig:Object = null;
      
      public function MultiStageConstructionFrameWithdrawal(building:StorageBuilding)
      {
         this.m_dialogConfig = (building as ConstructionBuilding).getDialogConfig();
         if(this.m_dialogConfig != null && this.m_dialogConfig.path != "" && this.m_dialogConfig.slotCount > 0 && this.m_dialogConfig.levelCount > 0)
         {
            m_dialogAsset = this.m_dialogConfig.path;
            m_dialogType = building.getItemName() + "Building";
            super(building);
         }
         else
         {
            GlobalEngine.assert(false,"gamesettings::buildableDialogs for the building needs the following: path, slotCount, levelCount");
         }
      }
      
      override public function getRect(movieClip:DisplayObject) : Rectangle
      {
         if(this.m_dialogConfig.width > 0 && this.m_dialogConfig.height > 0)
         {
            return new Rectangle(0,0,this.m_dialogConfig.width,this.m_dialogConfig.height);
         }
         return super.getRect(movieClip);
      }
      
      override protected function getNumSlots() : int
      {
         return this.m_dialogConfig.slotCount;
      }
      
      override protected function onLoadComplete() : void
      {
         var cancelBtn:GenericButton = null;
         var dialogKey:String = null;
         var fallbackDialogKey:String = null;
         var message:String = null;
         var gb:GenericButton = null;
         var slotSuffix:int = 0;
         var objectPreviewFrame:ObjectPreviewFrame = null;
         m_window = m_loader.content as MovieClip;
         if(m_window.main_mc.hasOwnProperty("close_bt"))
         {
            cancelBtn = new GenericButton(m_window.main_mc.close_bt,onClickClose);
            m_window.main_mc.close_bt.visible = true;
         }
         if(m_window.main_mc.hasOwnProperty("title_tf"))
         {
            ZLocUtils.setTextAsTitle(m_window.main_mc,"title_tf",m_building.getItemFriendlyName());
         }
         if(m_window.main_mc.hasOwnProperty("description_tf"))
         {
            dialogKey = m_dialogType + "_description";
            fallbackDialogKey = ConstructionBuilding.FALLBACK_KEY + "description";
            message = ZLocUtils.getFailoverLocString([new ZLocFailoverEntry("Dialogs",dialogKey),new ZLocFailoverEntry("Dialogs",fallbackDialogKey)],{"building":m_building.getItem().friendlyTitle});
            m_window.main_mc.description_tf.text = message;
         }
         if(m_window.main_mc.hasOwnProperty("whatisthis_mc"))
         {
            gb = new GenericButton(m_window.main_mc.whatisthis_mc,this.onClickHowDoesThisWork);
            gb.m_overlay.name = "WhatIsThisBtn";
            gb.text = ZLocUtils.t("Dialogs","WhatIsThis");
         }
         for(var slot:int = 0; slot < this.m_dialogConfig.slotCount; slot++)
         {
            slotSuffix = slot + 1;
            if(m_window.main_mc.slots_mc.hasOwnProperty("giftPanel" + slotSuffix))
            {
               m_tiles.push(m_window.main_mc.slots_mc["giftPanel" + slotSuffix]);
            }
            else
            {
               GlobalEngine.assert(false,"Dialog art missing slot panel" + slotSuffix.toString());
            }
         }
         if(Boolean(this.m_dialogConfig.buildingPreview) && Boolean(m_window.main_mc.hasOwnProperty("icon_mc")))
         {
            objectPreviewFrame = new ObjectPreviewFrame(m_window.main_mc.icon_mc,m_building.getItem(),null,MarketPreviewWindow.ZOOM_LEVELS,MarketPreviewWindow.ZOOM_WIDTHS);
         }
         for(var level:int = 0; level < this.m_dialogConfig.levelCount + 1; level++)
         {
            if(m_window.main_mc.hasOwnProperty("stage_" + level + "_mc"))
            {
               if(m_window.main_mc["stage_" + level + "_mc"].hasOwnProperty("generic_tf"))
               {
                  m_window.main_mc["stage_" + level + "_mc"].generic_tf.text = level + 1;
               }
            }
            else if(level > 0 && !m_window.main_mc.hasOwnProperty("progress" + level + "reveal_mc"))
            {
               GlobalEngine.assert(false,"Dialog art missing stage level" + level);
            }
         }
         removeTiles();
         this.pushNewData();
         m_cashNeeded = this.calculateCashNeeded();
         var compIdx:int = 0;
         while(compIdx < this.getNumSlots() && compIdx < m_data.length)
         {
            this.addComponent(compIdx);
            compIdx++;
         }
         addChild(m_window.main_mc);
         this.centerPopup();
         if(this.showUserWhatIsThisDialog())
         {
            this.setUserSeenWhatIsThisDialog();
            this.onClickHowDoesThisWork();
         }
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
                  object.cost = giftItem.cash;
                  object.currentCount = partItem.onHand;
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
            sendGitfsObject = new Object();
            sendGitfsObject.sendGiftsToFriends = true;
            m_data.push(sendGitfsObject);
            this.refreshProgressMeter();
         }
      }
      
      override protected function addComponent(compId:int, index:int = 0) : void
      {
         var tile:MovieClip = null;
         var data:Object = null;
         var buyButton:GenericButton = null;
         var askForMoreButton:AskForMoreButton = null;
         var useMatButton:GenericButton = null;
         var sendGifts:GenericButton = null;
         var cashNeeded:Number = NaN;
         var getFCash:GenericButton = null;
         var completeNow:GenericButton = null;
         if(Boolean(m_tiles) && m_data[index + compId] != null)
         {
            tile = m_tiles[compId] as MovieClip;
            data = m_data[index + compId];
            tile.visible = true;
            tile.use_bt.visible = false;
            if(data.sendGiftsToFriends == false)
            {
               tile.itemTitle_tf.text = ZLocUtils.tk_pk_asTitle(data.friendlyName);
               tile.matName = data.name;
               addIcon(data.name,"icon",tile,tile.icon);
               if(data.currentCount < data.need)
               {
                  if(tile.getThis_bt)
                  {
                     askForMoreButton = new AskForMoreButton(tile.getThis_bt,onGetThisCallback);
                     tile.askForMoreButton = askForMoreButton;
                     askForMoreButton.text = ZLocUtils.t("Dialogs","AskForMore");
                     if(getThisGreyOut())
                     {
                        askForMoreButton.greyOut();
                     }
                  }
                  else
                  {
                     GlobalEngine.assert(false,"SWF tile is missing a Ask button");
                  }
                  buyButton = null;
                  if(tile.buy_bt)
                  {
                     buyButton = new GenericButton(tile.buy_bt,this.onBuyPartButtonCallback);
                     if(tile.buy_bt.cost_tf)
                     {
                        tile.buy_bt.cost_tf.text = data.cost.toString();
                     }
                  }
                  else if(tile.buy2_bt)
                  {
                     buyButton = new GenericButton(tile.buy2_bt,this.onBuyPartButtonCallback);
                     if(tile.buy2_bt.cost_tf)
                     {
                        tile.buy2_bt.cost_tf.text = data.cost.toString();
                     }
                  }
                  else
                  {
                     GlobalEngine.assert(false,"SWF tile is missing a Buy button");
                  }
                  if(buyButton)
                  {
                     this.m_buyButtons.push(buyButton);
                     buyButton.useGrayOnDisabled = true;
                     buyButton.text = ZLocUtils.t("Dialogs","Buy");
                     tile.buyButton = buyButton;
                  }
                  if(tile.use_mat_bt)
                  {
                     useMatButton = new GenericButton(tile.use_mat_bt,this.onUsePartCallback);
                     tile.useMatButton = useMatButton;
                  }
                  else
                  {
                     GlobalEngine.assert(false,"SWF tile is missing a Use button");
                  }
               }
               this.refreshMaterialTileButtons(tile,data);
            }
            else
            {
               tile.itemTitle_tf.visible = false;
               tile.alive_tf.visible = false;
               tile.completeIcon_mc.visible = false;
               if(tile.getThis_bt)
               {
                  tile.getThis_bt.visible = false;
               }
               if(tile.buy_bt)
               {
                  tile.buy_bt.visible = false;
               }
               if(tile.buy2_bt)
               {
                  tile.buy2_bt.visible = false;
               }
               if(tile.use_mat_bt)
               {
                  tile.use_mat_bt.visible = false;
               }
               if(tile.available_tf)
               {
                  tile.available_tf.visible = false;
               }
               if(tile.sendMaterials_tf)
               {
                  tile.sendMaterials_tf.text = ZLocUtils.t("Dialogs","SendMaterials");
               }
               else
               {
                  GlobalEngine.assert(false,"SWF tile is missing a SendMaterial text field");
               }
               if(tile.present_bt)
               {
                  sendGifts = new GenericButton(tile.present_bt,this.onSendPresentsCallback);
                  sendGifts.m_overlay.name = "SendGifts";
                  sendGifts.text = ZLocUtils.t("Dialogs","SendGiftsBig");
               }
               else
               {
                  GlobalEngine.assert(false,"SWF tile is missing a Send button");
               }
               if(tile.completeNow_bt)
               {
                  cashNeeded = this.calculateCashNeeded();
                  if(Global.player.cash < cashNeeded && Global.experimentManager.getExperimentVariant("fv_in_app_purchase") == 2)
                  {
                     getFCash = new GenericButton(tile.completeNow_bt,this.getMoreCashCallback);
                     getFCash.text = ZLocUtils.t("Dialogs","GenericExpansion_button_get_farm_cash");
                     if(tile.notEnough_tf)
                     {
                        tile.notEnough_tf.text = ZLocUtils.t("Dialogs","NotEnoughCash");
                     }
                  }
                  else
                  {
                     completeNow = new GenericButton(tile.completeNow_bt,onFrictionlessFinishConstructionCallback);
                     completeNow.text = ZLocUtils.t("Dialogs","CompleteNowCamel");
                  }
                  if(tile.completeNow_bt.cost_tf)
                  {
                     tile.completeNow_bt.cost_tf.text = cashNeeded;
                  }
               }
               else
               {
                  GlobalEngine.assert(false,"SWF tile is missing a completeNow button");
               }
               if(tile.getFarmCash_bt)
               {
                  tile.getFarmCash_bt.visible = false;
               }
               if(tile.notEnough_tf)
               {
                  tile.notEnough_tf.visible = false;
               }
            }
         }
      }
      
      override protected function calculateCashNeeded(partcost:int = 1) : int
      {
         return m_building.getCashNeeded();
      }
      
      private function refreshMaterialTiles(index:int = 0, showChangeFX:Boolean = false) : void
      {
         var compId:int = 0;
         var tile:MovieClip = null;
         var data:Object = null;
         var prevCurrentCount:Number = NaN;
         var matItemCode:String = null;
         var deltaCount:Number = NaN;
         if(Boolean(m_tiles) && m_data != null)
         {
            compId = 0;
            while(compId < this.getNumSlots() && compId < m_data.length)
            {
               if(Boolean(m_tiles) && m_data[index + compId] != null)
               {
                  tile = m_tiles[compId] as MovieClip;
                  data = m_data[index + compId];
                  if(data.sendGiftsToFriends == false)
                  {
                     prevCurrentCount = Number(data.currentCount);
                     if(m_building as ConstructionBuilding)
                     {
                        matItemCode = data.code;
                     }
                     else
                     {
                        matItemCode = data.itemCode;
                     }
                     data.currentCount = m_building.getCurrentLevelConstructionItemCount(matItemCode);
                     deltaCount = 0;
                     if(showChangeFX)
                     {
                        deltaCount = data.currentCount - prevCurrentCount;
                     }
                     this.refreshMaterialTileButtons(tile,data,deltaCount);
                  }
                  else if(tile.completeNow_bt.cost_tf)
                  {
                     tile.completeNow_bt.cost_tf.text = m_building.getCashNeeded();
                  }
               }
               compId++;
            }
         }
         this.refreshProgressMeter();
      }
      
      private function refreshMaterialTileButtons(tile:MovieClip, data:Object, deltaCount:Number = 0) : void
      {
         var buildingPart:BuildingPart = null;
         var message:String = null;
         var iconFilter:Array = null;
         var iconUrl:String = null;
         var tweenDuration:Number = NaN;
         var totalInventory:Number = Global.player.getGiftCountForItem(tile.matName);
         tile.alive_tf.text = ZLocUtils.t("Dialogs","ConstructionBuildingMatCount",{
            "quantity":data.currentCount,
            "maximum":data.need
         });
         if(deltaCount > 0 && Boolean(tile.useMatButton))
         {
            buildingPart = new BuildingPart(tile.matName);
            message = "+" + deltaCount + " " + ZLocUtils.tk_pk_asTitle(data.friendlyName);
            iconFilter = [BuildingPart.newStandardGlowFilter()];
            iconUrl = buildingPart.getItem().icon;
            tweenDuration = UI.DEFAULT_STATUS_TWEEN_DURATION * 2;
            this.displayMaterialStatusChange(message,tile,iconUrl,iconFilter);
         }
         if(data.currentCount >= data.need)
         {
            ZLocUtils.setText(tile,"completeIcon_mc.completed_tf","Dialogs","GenericExpansion_completed_text");
            tile.completeIcon_mc.visible = true;
            if(tile.completeNow_bt)
            {
               tile.completeNow_bt.visible = false;
            }
            if(tile.getThis_bt)
            {
               tile.getThis_bt.visible = false;
            }
            if(tile.buy_bt)
            {
               tile.buy_bt.visible = false;
            }
            if(tile.buy2_bt)
            {
               tile.buy2_bt.visible = false;
            }
            if(tile.sendMaterials_tf)
            {
               tile.sendMaterials_tf.visible = false;
            }
            if(tile.present_bt)
            {
               tile.present_bt.visible = false;
            }
            if(tile.askForMoreButton)
            {
               tile.askForMoreButton.turnOff();
            }
            if(tile.buyButton)
            {
               tile.buyButton.turnOff();
            }
            if(tile.useMatButton)
            {
               tile.useMatButton.turnOff();
            }
            if(tile.use_mat_bt != null)
            {
               tile.use_mat_bt.visible = false;
            }
            if(tile.available_tf)
            {
               tile.available_tf.visible = false;
            }
         }
         else
         {
            tile.completeIcon_mc.visible = false;
            if(tile.sendMaterials_tf)
            {
               tile.sendMaterials_tf.visible = false;
            }
            if(tile.present_bt)
            {
               tile.present_bt.visible = false;
            }
            if(tile.completeNow_bt)
            {
               tile.completeNow_bt.visible = false;
            }
            if(getThisGreyOut())
            {
               tile.askForMoreButton.greyOut();
            }
            if(totalInventory > 0 && Boolean(tile.useMatButton))
            {
               tile.askForMoreButton.turnOff();
               tile.buyButton.turnOff();
               if(tile.useMatButton)
               {
                  tile.useMatButton.turnOn();
               }
               if(tile.available_tf)
               {
                  tile.available_tf.visible = true;
                  tile.available_tf.text = ZLocUtils.t("Dialogs","ConstructionBuildingMatAvailable",{"quantity":totalInventory});
               }
            }
            else
            {
               if(tile.askForMoreButton)
               {
                  tile.askForMoreButton.turnOn();
               }
               if(tile.buyButton)
               {
                  tile.buyButton.turnOn();
               }
               if(tile.useMatButton)
               {
                  tile.useMatButton.turnOff();
               }
               if(tile.available_tf)
               {
                  tile.available_tf.visible = false;
               }
            }
         }
      }
      
      public function displayMaterialStatusChange(message:String, tile:MovieClip, iconUrl:String = "", iconFilters:Array = null, tweenDuration:Number = 1.5, tweenDisplacement:int = 32, fontSize:int = 16, fontColor:uint = 16777215) : void
      {
         var anchorObj:DisplayObject = tile.iconBox_mc;
         var localPos:Point = new Point(anchorObj.x + anchorObj.width * 0.5,anchorObj.y - anchorObj.height);
         var screen:Point = anchorObj.localToGlobal(localPos);
         UI.displayStatus(message,screen.x,screen.y,iconUrl,iconFilters,tweenDuration,tweenDisplacement,fontSize,fontColor);
      }
      
      protected function getCurVsTotalPartsNeeded() : Object
      {
         var result:Object = new Object();
         result.neededTotal = 0;
         result.currentTotal = 0;
         for(var index:int = 0; index < m_data.length; index++)
         {
            if(!m_data[index].sendGiftsToFriends)
            {
               result.neededTotal += m_data[index].need;
               result.currentTotal += m_data[index].currentCount;
            }
         }
         return result;
      }
      
      protected function refreshProgressMeter() : void
      {
         var completionRatio:Number = NaN;
         var inventoryCount:Object = this.getCurVsTotalPartsNeeded();
         if(m_window.main_mc.hasOwnProperty("meter_1_mc"))
         {
            completionRatio = inventoryCount.currentTotal / inventoryCount.neededTotal;
            m_window.main_mc["meter_1_mc"].bar_mc.scaleX = completionRatio;
            m_window.main_mc["meter_1_mc"].visible = true;
         }
         if(m_window.main_mc.hasOwnProperty("decorationStage1_mc"))
         {
            m_window.main_mc.decorationStage1_mc.visible = false;
         }
         var unreachedLevel:int = 2;
         while(Boolean(m_window.main_mc.hasOwnProperty("decorationStage" + unreachedLevel + "_mc")) || Boolean(m_window.main_mc.hasOwnProperty("m_window.main_mc.meter_" + unreachedLevel + "_mc")) || Boolean(m_window.main_mc.hasOwnProperty("progress" + unreachedLevel + "_mc")))
         {
            if(m_window.main_mc.hasOwnProperty("decorationStage" + unreachedLevel + "_mc"))
            {
               m_window.main_mc["decorationStage" + unreachedLevel + "_mc"].visible = false;
            }
            if(m_window.main_mc.hasOwnProperty("meter_" + unreachedLevel + "_mc"))
            {
               m_window.main_mc["meter_" + unreachedLevel + "_mc"].bar_mc.width = 0;
            }
            if(m_window.main_mc.hasOwnProperty("progress" + unreachedLevel + "_mc"))
            {
               m_window.main_mc["progress" + unreachedLevel + "_mc"].visible = true;
            }
            if(m_window.main_mc.hasOwnProperty("progress" + unreachedLevel + "reveal_mc"))
            {
               m_window.main_mc["progress" + unreachedLevel + "reveal_mc"].visible = false;
            }
            unreachedLevel++;
         }
      }
      
      private function whichCashPackage() : Number
      {
         var pack:Object = null;
         var difference:int = 0;
         var cashPackages:Array = InGamePaymentsManager.packages;
         var smallestViable:Number = -1;
         var cashNeeded:Number = this.calculateCashNeeded();
         for each(pack in cashPackages)
         {
            difference = parseInt(pack["amount"]) + Global.player.cash - cashNeeded;
            if(difference >= 0 && (difference < smallestViable || smallestViable == -1))
            {
               smallestViable = difference;
            }
         }
         if(smallestViable == -1)
         {
            FarmStatsManager.count("error","GenericExpandSlot","whichCashPackage","No package viable");
            smallestViable = Global.player.cash - cashNeeded;
         }
         return smallestViable - Global.player.cash + cashNeeded;
      }
      
      protected function getMoreCashCallback(event:MouseEvent) : void
      {
         PaymentUtil.instance.addCashToCart(this.whichCashPackage(),"CompleteNow:ThanksgivingBuildable2011",this.onSuccessGetMoreCash);
      }
      
      protected function onSuccessGetMoreCash(orderId:String, status:String) : void
      {
         TransactionManager.addTransaction(new TRefreshBalance(this.balanceRefreshed),true);
      }
      
      protected function balanceRefreshed(result:Object) : void
      {
         this.close();
         this.m_building.displayStorageDialog();
      }
      
      override protected function onSendPresentsCallback(event:MouseEvent) : void
      {
         FarmStatsManager.count("Constructable","ui_button_click",m_building.getItem().name,"send_gift");
         close();
         UI.displayPopup(new CustomFreeGiftSelectionWindow(m_building.getPartsArray()));
      }
      
      protected function onBuyPartButtonCallback(event:MouseEvent) : void
      {
         m_itemToBuy = Global.farmGameSettingsManager.getFarmItemByName(getItemNameFromEvent(event));
         FarmStatsManager.count("Constructable","ui_button_click",m_building.getItem().name,"buy_part_frictionless",m_itemToBuy.name);
         if(Global.player.canBuyCash(m_itemToBuy.cash,true))
         {
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_BUILDING_UI_CASH_BUY_COUNTER) > 0)
            {
               FarmStatsManager.sample(100,"fv_cash_buy","building",m_building.getItem().name,"buy_one",m_itemToBuy.cash.toString());
            }
            BuildingItemUseMediator.getInstance().mediate(m_itemToBuy.name,false,m_building);
            close();
         }
      }
      
      protected function onUsePartCallback(event:MouseEvent) : void
      {
         var inventoryCount:Object = null;
         var itemName:String = getItemNameFromEvent(event);
         m_itemToBuy = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         FarmStatsManager.count("Constructable","ui_button_click",m_building.getItem().name,"use",m_itemToBuy.name);
         if(m_itemToBuy != null)
         {
            inventoryCount = this.getCurVsTotalPartsNeeded();
            BuildingItemUseMediator.getInstance().mediate(m_itemToBuy.name,true,m_building,true);
            if(inventoryCount.currentTotal + 1 != inventoryCount.neededTotal)
            {
               this.refreshMaterialTiles();
            }
            else
            {
               close();
            }
         }
      }
      
      public function showUserWhatIsThisDialog() : Boolean
      {
         if(this.m_dialogConfig.autoWhatIsThis == true)
         {
            return !Global.player.getSeenFlag(m_building.getItemName() + "WhatIsThisOpened");
         }
         return false;
      }
      
      public function setUserSeenWhatIsThisDialog() : void
      {
         Global.player.setSeenFlag(m_building.getItemName() + "WhatIsThisOpened");
      }
      
      override protected function onClickHowDoesThisWork(event:Event = null) : void
      {
         if(Boolean(this.m_dialogConfig.tutorialBundlePrefix) && Boolean(this.m_dialogConfig.tutorialAssetPrefix))
         {
            TutorialUI.displayBundleTutorialWindow("Dialogs",this.m_dialogConfig.tutorialBundlePrefix,this.m_dialogConfig.tutorialAssetPrefix,false);
         }
         else
         {
            super.onClickHowDoesThisWork();
         }
      }
   }
}

