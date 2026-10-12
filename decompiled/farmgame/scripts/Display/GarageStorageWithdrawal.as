package Display
{
   import Classes.Combine;
   import Classes.Constants.Experiments;
   import Classes.Equipment;
   import Classes.GarageBuilding;
   import Classes.Harvester;
   import Classes.IrrigationSprinkler;
   import Classes.PlotRemover;
   import Classes.RotatableCombine;
   import Classes.RotatableHarvester;
   import Classes.RotatablePlotRemover;
   import Classes.RotatableSeeder;
   import Classes.RotatableTractor;
   import Classes.Seeder;
   import Classes.Tractor;
   import Classes.ZItem.DecorationItem;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Events.CloseEvent;
   import Events.GenericPopupEvent;
   import Events.MarketEvent;
   import GameMode.GMHarvester;
   import GameMode.GMIrrigationSprinkler;
   import GameMode.GMPlotRemover;
   import GameMode.GMTractorPlow;
   import GameMode.GMVehicleUpgrade;
   import Managers.EquipmentSettingsManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.MFSRequestManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class GarageStorageWithdrawal extends StorageWithdrawal
   {
      
      private const NUM_SLOTS:int = 3;
      
      private const FEATURE_NAME:String = "Garage";
      
      protected var m_removeButtons:Array = new Array();
      
      protected var m_useButtons:Array = new Array();
      
      protected var m_useAllButtons:Array = new Array();
      
      protected var m_objectsArray:Array = new Array();
      
      private var m_returnFarmBtn:GenericButton;
      
      private var m_askForPartsBtn:FarmAnimatedTextButton;
      
      private var m_buyPartsBtn:FarmAnimatedTextButton;
      
      private var m_whatIsThisBtn:GenericButton;
      
      protected var m_itemToBuy:FarmItem = null;
      
      protected var m_dialogEnabled:Boolean = true;
      
      public function GarageStorageWithdrawal(garage:GarageBuilding)
      {
         FarmStatsManager.sample(100,"fv_fbml_depr_inspect","GarageStorageWithdrawal","called");
         m_building = garage;
         if(null == m_dialogAsset && null == m_dialogType)
         {
            m_dialogAsset = "assets/dialogs/FV_Garage_Complete.swf";
            m_dialogType = "garage";
         }
         super(garage);
      }
      
      override protected function onLoadComplete() : void
      {
         m_window = m_loader.content as MovieClip;
         ZLocUtils.setText(m_window,"storage_mc.whatisthis_mc.generic_tf","Dialogs","WhatIsThis");
         m_window.storage_mc.close_bt.addEventListener(MouseEvent.CLICK,this.onCloseClick);
         if(Boolean(m_window.storage_mc.hasOwnProperty("arrowLt_bt")) && Boolean(m_window.storage_mc.hasOwnProperty("arrowRt_bt")))
         {
            m_window.storage_mc.arrowLt_bt.addEventListener(MouseEvent.CLICK,onLtArrowClick);
            m_window.storage_mc.arrowRt_bt.addEventListener(MouseEvent.CLICK,onRtArrowClick);
         }
         this.setPanelTitle();
         this.pushNewData();
         this.setupTiles();
         removeTiles();
         this.addGenericButtons();
         var compIdx:int = 0;
         while(compIdx < this.getNumSlots() && compIdx < m_data.length)
         {
            this.addComponent(compIdx);
            compIdx++;
         }
         addChild(m_window);
         if(!Global.player.getSeenFlag("FirstTimeOpenGarageStorageDialog"))
         {
            Global.player.setSeenFlag("FirstTimeOpenGarageStorageDialog");
            this.onWhatIsThisClick(new MouseEvent(MouseEvent.CLICK));
         }
      }
      
      protected function setPanelTitle() : void
      {
         m_window.storage_mc.title_tf.text = ZLocUtils.t("Dialogs","GarageTitle");
      }
      
      protected function addGenericButtons() : void
      {
         this.m_returnFarmBtn = new GenericButton(m_window.storage_mc.cancel_bt,this.onCloseClick);
         this.m_returnFarmBtn.text = ZLocUtils.t("Dialogs","ReturnToFarm");
         this.m_askForPartsBtn = new FarmAnimatedTextButton(m_window.storage_mc.askParts_mc,ZLocUtils.t("Dialogs","GarageAskForParts"),this.onAskClick);
         this.m_buyPartsBtn = new FarmAnimatedTextButton(m_window.storage_mc.buy_mc,ZLocUtils.t("Dialogs","GarageBuyParts"),this.onBuyParts);
         if(m_window.whatisthis_mc != null)
         {
            m_window.whatisthis_mc.visible = false;
         }
         this.m_whatIsThisBtn = new GenericButton(m_window.storage_mc.whatisthis_mc,this.onWhatIsThisClick);
         this.m_whatIsThisBtn.text = ZLocUtils.t("Dialogs","WhatIsThis");
         if(m_building.count == 0)
         {
            this.m_askForPartsBtn.enabled = false;
            this.m_buyPartsBtn.enabled = false;
         }
      }
      
      protected function onWhatIsThisClick(event:MouseEvent) : void
      {
         var msg:String = null;
         if(m_howDoesThisWorkPopup == null)
         {
            msg = ZLocUtils.t("Dialogs",m_building.getItem().name + "_WhatIsThis");
            m_howDoesThisWorkPopup = new GenericPopup(msg,GenericPopup.TYPE_OK,onHowDoesThisWorkClose,GenericPopup.GENERIC_ASSET_LRG);
            m_howDoesThisWorkPopup.setAcceptTextName("Okay");
            UI.displayPopup(m_howDoesThisWorkPopup,false,"whatIsThisPopup",true);
         }
      }
      
      override public function onCloseClick(event:MouseEvent) : void
      {
         m_window.storage_mc.close_bt.removeEventListener(MouseEvent.CLICK,this.onCloseClick);
         if(Boolean(m_window.storage_mc.hasOwnProperty("arrowLt_bt")) && Boolean(m_window.storage_mc.hasOwnProperty("arrowRt_bt")))
         {
            m_window.storage_mc.arrowLt_bt.removeEventListener(MouseEvent.CLICK,onLtArrowClick);
            m_window.storage_mc.arrowRt_bt.removeEventListener(MouseEvent.CLICK,onRtArrowClick);
         }
         if(event)
         {
            event.stopPropagation();
         }
         close();
         dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
      }
      
      private function onBuyParts(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(this.m_dialogEnabled)
         {
            m_window.storage_mc.close_bt.removeEventListener(MouseEvent.CLICK,this.onCloseClick);
            this.m_dialogEnabled = false;
         }
         this.m_itemToBuy = Global.farmGameSettingsManager.getFarmItemByName(GarageBuilding.VEHICLE_PART_ITEM);
         var messageText:String = ZLocUtils.t("Dialogs","ConstructionBuilding_BuyConfirmation",{
            "item":ZLocUtils.tk_pk(this.m_itemToBuy.friendlyName),
            "cashQuantity":this.m_itemToBuy.cash
         });
         UI.displayPopup(new GenericPopup(messageText,GenericPopup.TYPE_ACCEPTCANCEL,this.onBuyPartsConfirmation),false);
      }
      
      private function onBuyPartsConfirmation(evt:GenericPopupEvent) : void
      {
         if(evt.button == GenericPopup.ACCEPT && this.m_itemToBuy != null)
         {
            Global.world.addGameMode(new GMVehicleUpgrade(this.m_itemToBuy.name,false),false);
            this.onCloseClick(null);
         }
         else if(!this.m_dialogEnabled)
         {
            m_window.storage_mc.close_bt.addEventListener(MouseEvent.CLICK,this.onCloseClick);
            this.m_dialogEnabled = true;
         }
      }
      
      protected function onAskClick(event:MouseEvent) : void
      {
         FarmStatsManager.sample(100,"fv_fbml_depr_inspect","r2FlowCalled","GarageStorageWithdrawal");
         MFSRequestManager.getInstance().makeAskMatsRequest(this.FEATURE_NAME,"vehiclepart","","","dialog_click");
         this.onCloseClick(event);
      }
      
      override protected function getNumSlots() : int
      {
         return this.NUM_SLOTS;
      }
      
      override protected function setupTiles() : void
      {
         var tileName:String = null;
         for(var tileIdx:int = 0; tileIdx < this.getNumSlots(); tileIdx++)
         {
            tileName = "storagePanel" + int(tileIdx + 1).toString();
            if(m_window.storage_mc.hasOwnProperty(tileName))
            {
               m_tiles.push(m_window.storage_mc.getChildByName(tileName));
            }
         }
      }
      
      override protected function pushNewData() : void
      {
         var objectIndex:int = 0;
         var objectIdx:int = 0;
         var objectCount:Number = NaN;
         var objectNum:int = 0;
         var object:Object = null;
         var giftItem:FarmItem = null;
         var giftNum:Number = NaN;
         var giftParts:Number = NaN;
         var coinYield:String = null;
         var giftXML:XML = null;
         m_data = [];
         m_tileSet = 0;
         m_usedTypes = new Object();
         this.m_objectsArray = m_building.getContents();
         var objects:Array = this.m_objectsArray;
         var objCount:int = 0;
         if(objects)
         {
            for(objectIndex = 0; objectIndex < objects.length; objectIndex++)
            {
               objCount += objects[objectIndex].num;
            }
         }
         if(objects)
         {
            for(objectIdx = 0; objectIdx < objects.length; objectIdx++)
            {
               objectCount = Number(objects[objectIdx].num);
               for(objectNum = 0; objectNum < objectCount; objectNum++)
               {
                  object = new Object();
                  giftItem = objects[objectIdx].item;
                  giftNum = Number(objects[objectIdx].num);
                  giftParts = Number(objects[objectIdx].numParts);
                  if(giftParts < 0)
                  {
                     giftParts = 0;
                  }
                  m_usedTypes[giftItem.code] = giftNum;
                  object.name = objects[objectIdx].name;
                  object.code = objects[objectIdx].code;
                  object.type = giftItem.type;
                  object.localizedName = giftItem.friendlyName;
                  object.cost = giftItem.cost;
                  object.upgradeParts = giftParts;
                  if(FarmGameSettingsManager.isInDataSourceExperiment())
                  {
                     coinYield = giftItem.getPropertyFromItemCashSaleSource("coinYield");
                     if(coinYield)
                     {
                        object.coinYield = coinYield;
                     }
                     if(m_building.getItem().hasPropertyInDataSource("growTime"))
                     {
                        object.harvestTime = m_building.getItem().getIntFromDataSource("growTime");
                     }
                  }
                  else
                  {
                     giftXML = giftItem.xml ? giftItem.xml : (giftItem.cashXML ? giftItem.cashXML : giftItem.saleXML);
                     if(giftXML.coinYield)
                     {
                        object.coinYield = giftXML.coinYield;
                     }
                     if(m_building.getItem().xml.growTime)
                     {
                        object.harvestTime = m_building.getItem().xml.growTime;
                     }
                  }
                  if(giftItem.sizeX)
                  {
                     object.sizeX = giftItem.sizeX;
                  }
                  if(giftItem.sizeY)
                  {
                     object.sizeX = giftItem.sizeY;
                  }
                  m_data.push(object);
               }
            }
         }
         m_data.sortOn("upgradeParts",Array.NUMERIC);
         this.fixArrows();
      }
      
      override protected function fixArrows() : void
      {
         if(Boolean(m_window.storage_mc.hasOwnProperty("arrowLt_bt")) && Boolean(m_window.storage_mc.hasOwnProperty("arrowRt_bt")))
         {
            m_window.storage_mc.arrowLt_bt.visible = m_tileSet > 0 ? true : false;
            m_window.storage_mc.arrowRt_bt.visible = (m_tileSet + 1) * this.getNumSlots() < m_data.length ? true : false;
         }
      }
      
      override protected function addComponent(compId:int, index:int = 0) : void
      {
         var itemCode:String = null;
         var mc:MovieClip = null;
         var numParts:Number = NaN;
         var currAmt:Number = NaN;
         var nextAmt:Number = NaN;
         var requiredLevel:int = 0;
         var level:String = null;
         var currentKey:String = null;
         var item:FarmItem = null;
         var garageVehicleLevelLockedStrings:Array = null;
         var garageUpgradeStatsStrings:Array = null;
         if(Boolean(m_tiles) && m_data[index + compId] != null)
         {
            itemCode = m_data[index + compId].code;
            mc = m_tiles[compId] as MovieClip;
            numParts = Number(m_data[index + compId].upgradeParts);
            currAmt = this.modifyCurrentPartsAmount(numParts,itemCode);
            nextAmt = this.getNextMax(numParts,itemCode);
            requiredLevel = Equipment.getRequiredUpgradeLevel(numParts,itemCode);
            m_tiles[compId].visible = true;
            m_tiles[compId].itemTitle_tf.text = ZLocUtils.tk_pk_asTitle(m_data[index + compId].localizedName);
            level = this.getLevel(numParts,itemCode);
            m_tiles[compId].level_mc.level_tf.text = ZLocUtils.t("Dialogs","Level",{"levelNum":level});
            if(Global.player.level < requiredLevel)
            {
               garageVehicleLevelLockedStrings = ZLocUtils.splitString(ZLocUtils.t("Dialogs","GarageVehicleLevelLocked",{"quantity":requiredLevel}),2);
               m_tiles[compId].generic_tf.text = garageVehicleLevelLockedStrings[0];
               m_tiles[compId].generic2_tf.text = garageVehicleLevelLockedStrings[1];
            }
            else if(nextAmt == 0)
            {
               m_tiles[compId].generic_tf.text = ZLocUtils.t("Dialogs","GarageFullyUpgradedVehicle");
               m_tiles[compId].generic2_tf.text = "";
            }
            else
            {
               garageUpgradeStatsStrings = ZLocUtils.splitString(ZLocUtils.t("Dialogs","GarageUpgradeStats",{
                  "quantity":currAmt,
                  "quantityTotal":nextAmt
               }),2);
               m_tiles[compId].generic_tf.text = garageUpgradeStatsStrings[0];
               m_tiles[compId].generic2_tf.text = garageUpgradeStatsStrings[1];
            }
            m_tiles[compId].bar_mc.scaleX = this.setProgressBar(this.modifyCurrentPartsAmount(numParts,itemCode),this.getNextMax(numParts,itemCode));
            currentKey = m_data[index + compId].code + ":" + m_data[index + compId].upgradeParts;
            this.m_removeButtons[compId] = new GarageButton(m_tiles[compId].remove_bt,this.onRemove,currentKey,m_data[index + compId].upgradeParts);
            this.m_removeButtons[compId].m_overlay.name = m_data[index + compId].name;
            this.m_removeButtons[compId].text = ZLocUtils.t("Dialogs","Remove");
            this.m_useButtons[compId] = new GarageButton(m_tiles[compId].use_bt,this.onUseEquipment,currentKey,m_data[index + compId].upgradeParts);
            item = Global.farmGameSettingsManager.getFarmItemByCode(m_data[index + compId].code);
            this.m_useButtons[compId].m_overlay.name = item.className;
            this.m_useButtons[compId].text = ZLocUtils.t("Dialogs","Use").toUpperCase();
            if(m_tiles[compId].hasOwnProperty("useAll_bt"))
            {
               this.m_useAllButtons[compId] = new GarageButton(m_tiles[compId].useAll_bt,this.onUseAll,currentKey,m_data[index].upgradeParts);
               this.m_useAllButtons[compId].m_overlay.name = m_data[index + compId].name;
               this.m_useAllButtons[compId].text = ZLocUtils.t("Dialogs","GiftBox_UseAll").toUpperCase();
               if(!this.canUpgrade(currentKey) || Global.player.getGiftCountForItem(GarageBuilding.VEHICLE_PART_ITEM) <= 0)
               {
                  (this.m_useAllButtons[compId] as GarageButton).useGrayOnDisabled = true;
                  (this.m_useAllButtons[compId] as GarageButton).toggleDisable(false);
               }
            }
            addIcon(m_data[index + compId].name,"icon",m_tiles[compId],m_tiles[compId].icon,70,70);
         }
      }
      
      private function modifyCurrentPartsAmount(partsNum:Number, itemCode:String) : Number
      {
         var currentLevel:Object = EquipmentSettingsManager.getInstance().getLevelByPartCount(partsNum,itemCode);
         return partsNum - currentLevel.partsNeeded;
      }
      
      private function getLevel(partsNum:Number, itemCode:String) : String
      {
         var result:String = "";
         var currentLevel:Object = EquipmentSettingsManager.getInstance().getLevelByPartCount(partsNum,itemCode);
         if(currentLevel)
         {
            result = (int(currentLevel.id) + 1).toString();
         }
         return result;
      }
      
      private function getNextMax(partsNum:Number, itemCode:String) : Number
      {
         var result:Number = 0;
         var currentLevel:Object = EquipmentSettingsManager.getInstance().getLevelByPartCount(partsNum,itemCode);
         var nextLevel:Object = EquipmentSettingsManager.getInstance().getNextLevelByPartCount(partsNum,itemCode);
         if(Boolean(currentLevel) && Boolean(nextLevel))
         {
            result = nextLevel.partsNeeded - currentLevel.partsNeeded;
         }
         return result;
      }
      
      private function setProgressBar(curParts:Number, maxParts:Number) : Number
      {
         return curParts / maxParts;
      }
      
      private function onRemove(itemName:String, key:String, upgradeParts:Number) : void
      {
         var eventType:int = 0;
         var item:DecorationItem = Global.farmGameSettingsManager.getFarmItemByName(itemName) as DecorationItem;
         item.onRemove(storageBuildingId,{"numParts":upgradeParts},itemName);
         FarmStatsManager.count(m_dialogType,"click_remove");
         dispatchEvent(new MarketEvent(MarketEvent.MARKET_GIFT,MarketEvent.NONE));
         this.onCloseClick(new MouseEvent(MouseEvent.CLICK));
      }
      
      private function canUpgrade(key:String) : Boolean
      {
         var result:Boolean = true;
         var explodedKey:Array = key.split(":");
         var itemCode:String = explodedKey[0] as String;
         var quantity:int = int(explodedKey[1]);
         var requiredLevel:int = Equipment.getRequiredUpgradeLevel(quantity,itemCode);
         var max:int = 0;
         var base:int = 0;
         if(Global.player.level >= requiredLevel)
         {
            max = Equipment.getNumPartsToNextLevel(quantity,itemCode);
            base = Equipment.getNumPartsToPreviousLevel(quantity,itemCode);
            quantity -= base;
            max -= base;
         }
         if(quantity >= max)
         {
            result = false;
         }
         else
         {
            result = true;
         }
         return result;
      }
      
      private function onUseAll(itemName:String, key:String, upgradeParts:Number) : void
      {
         var eventType:int = 0;
         var item:DecorationItem = Global.farmGameSettingsManager.getFarmItemByName(itemName) as DecorationItem;
         var explodedKey:Array = key.split(":");
         var itemCode:String = explodedKey[0] as String;
         var quantity:int = int(explodedKey[1]);
         var max:int = Equipment.getNumPartsToNextLevel(quantity,itemCode);
         var equipLevel:int = Equipment.getCurrentLevel(quantity,itemCode);
         var base:int = Equipment.getNumPartsToPreviousLevel(quantity,itemCode);
         quantity -= base;
         max -= base;
         var partsToLevelUp:int = max - quantity;
         var usableParts:int = Math.min(Global.player.getGiftCountForItem(GarageBuilding.VEHICLE_PART_ITEM),partsToLevelUp);
         for(var i:int = 0; i < usableParts; i++)
         {
            (m_building as GarageBuilding).addPartToVehicle(key,true);
            explodedKey = key.split(":");
            quantity = int(explodedKey[1]) + 1;
            key = explodedKey[0] + ":" + quantity;
         }
         Global.player.removeGiftWithKey(Global.farmGameSettingsManager.getFarmItemByName(GarageBuilding.VEHICLE_PART_ITEM).code,usableParts);
         FarmStatsManager.count(m_dialogType,"click_useall");
         dispatchEvent(new MarketEvent(MarketEvent.MARKET_GIFT,MarketEvent.NONE));
         this.onCloseClick(new MouseEvent(MouseEvent.CLICK));
      }
      
      private function onUseEquipment(itemName:String, key:String, upgradeParts:Number) : void
      {
         var equipment:Equipment = (m_building as GarageBuilding).getEquipmentObject(key);
         switch(equipment.getItem().className)
         {
            case "Tractor":
               Global.world.addGameMode(new GMTractorPlow(equipment as Tractor),true);
               break;
            case "RotatableTractor":
               Global.world.addGameMode(new GMTractorPlow(equipment as RotatableTractor),true);
               break;
            case "Harvester":
               Global.world.addGameMode(new GMHarvester(equipment as Harvester),true);
               break;
            case "RotatableHarvester":
               Global.world.addGameMode(new GMHarvester(equipment as RotatableHarvester),true);
               break;
            case "Seeder":
               Global.world.m_chosenSeeder = equipment as Seeder;
               if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_UX_COMBINE_MARKET_SEARCH) == 2)
               {
                  UI.displaySeedSelectionMiniMarketDialog(equipment.getSupportedTerrainCodes(),UI.MARKET_LAUNCH_REFERENCE_SEEDER);
               }
               else
               {
                  UI.displayMarketDialog("actionMenuSeeder","seed",UI.MARKET_LAUNCH_REFERENCE_SEEDER,"seeds",null,null,null,null,-1,equipment.getSupportedTerrainCodes());
               }
               break;
            case "RotatableSeeder":
               Global.world.m_chosenSeeder = equipment as RotatableSeeder;
               if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_UX_COMBINE_MARKET_SEARCH) == 2)
               {
                  UI.displaySeedSelectionMiniMarketDialog(equipment.getSupportedTerrainCodes(),UI.MARKET_LAUNCH_REFERENCE_SEEDER);
               }
               else
               {
                  UI.displayMarketDialog("actionMenuSeeder","seed",UI.MARKET_LAUNCH_REFERENCE_SEEDER,"seeds",null,null,null,null,-1,equipment.getSupportedTerrainCodes());
               }
               break;
            case "Combine":
               Global.world.m_chosenSeeder = equipment as Combine;
               if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_UX_COMBINE_MARKET_SEARCH) == 2)
               {
                  UI.displaySeedSelectionMiniMarketDialog(equipment.getSupportedTerrainCodes(),UI.MARKET_LAUNCH_REFERENCE_COMBINE);
               }
               else
               {
                  UI.displayMarketDialog("actionMenuCombine","seed",UI.MARKET_LAUNCH_REFERENCE_COMBINE,"seeds",null,null,null,null,-1,equipment.getSupportedTerrainCodes());
               }
               break;
            case "RotatableCombine":
               Global.world.m_chosenSeeder = equipment as RotatableCombine;
               if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_UX_COMBINE_MARKET_SEARCH) == 2)
               {
                  UI.displaySeedSelectionMiniMarketDialog(equipment.getSupportedTerrainCodes(),UI.MARKET_LAUNCH_REFERENCE_COMBINE);
               }
               else
               {
                  UI.displayMarketDialog("actionMenuCombine","seed",UI.MARKET_LAUNCH_REFERENCE_COMBINE,"seeds",null,null,null,null,-1,equipment.getSupportedTerrainCodes());
               }
               break;
            case "IrrigationSprinkler":
               Global.world.addGameMode(new GMIrrigationSprinkler(equipment as IrrigationSprinkler));
               break;
            case "PlotRemover":
               Global.world.addGameMode(new GMPlotRemover(equipment as PlotRemover),true);
               break;
            case "RotatablePlotRemover":
               Global.world.addGameMode(new GMPlotRemover(equipment as RotatablePlotRemover),true);
               break;
            case "OrchardHarvester":
            case "AnimalPenHarvester":
            case "ResourceHarvester":
               equipment.showSelectPatternWindow("garage");
         }
         this.onCloseClick(new MouseEvent(MouseEvent.CLICK));
      }
   }
}

