package Display
{
   import Classes.Friend;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.SeedItem;
   import Classes.breeding.BreedingFeatureState;
   import Classes.breeding.BreedingState;
   import Classes.util.ZLocUtils;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.TransactionManager;
   import Engine.Utilities;
   import GameMode.GMDefault;
   import GameMode.GMMarketPlant;
   import GameMode.GameMode;
   import Managers.BreedingManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Transactions.TBreedingProjectBegin;
   import Transactions.TBreedingProjectFinish;
   import Transactions.TBreedingProjectPurchaseHelp;
   import Transactions.TCancelFriendReward;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Buttons.ZwButton;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class GreenhouseNurseryDialog extends MovieClip
   {
      
      private var m_trayArray:Array;
      
      private var m_featureState:BreedingFeatureState;
      
      private var m_breedingState:BreedingState;
      
      private var m_finishedItem:FarmItem;
      
      private var m_transactionDialog:GenericXMLDialog;
      
      private var m_mainDialog:GreenhouseWithdrawal;
      
      private var m_currentSlot:int;
      
      private var m_currentTray:int;
      
      private var m_timeRemaining:int;
      
      private var m_openToTray:int;
      
      private var m_trayAddBtn0:MovieClip;
      
      private var m_trayAddBtn1:MovieClip;
      
      private var m_seedTray:MovieClip;
      
      private var m_slot0:MovieClip;
      
      private var m_slot1:MovieClip;
      
      private var m_result0:MovieClip;
      
      private var m_result1:MovieClip;
      
      private var m_buttonsVector:Vector.<FarmAnimatedTextButton>;
      
      private var m_crewSlot0:MovieClip;
      
      private var m_crewSlot1:MovieClip;
      
      private var m_container:MovieClip;
      
      private var m_genericText0:TextField;
      
      private var m_genericText1:TextField;
      
      private var m_genericText2:TextField;
      
      private var m_selectedSeed0:SeedItem;
      
      private var m_selectedSeed1:SeedItem;
      
      private var m_storageBuilding:StorageBuilding;
      
      private var m_buildingClassName:String;
      
      private const TRAY_AMOUNT_1:int = 1;
      
      private const TRAY_AMOUNT_2:int = 4;
      
      private const TRAY_AMOUNT_3:int = 8;
      
      private const SEED_AMOUNT:int = 50;
      
      private const NUM_FRIEND_SLOTS:int = 3;
      
      private const DAYS_REMAINING_NULL:int = 4;
      
      private const BREEDING_FEATURE_NAME:String = "greenhousebuildable_finished";
      
      private const SLOT_STATE_OPEN:String = "open";
      
      private const SLOT_STATE_FILLED:String = "filled";
      
      private const ICON_KNOWN_LRG_URL:String = "assets/dialogs/FV_Support/FV_Greenhouse/seedPacket_knownLrg.png";
      
      private const ICON_UNKNOWN_LRG_URL:String = "assets/dialogs/FV_Support/FV_Greenhouse/seedPacket_unknownLrg.png";
      
      private const ICON_KNOWN_SM_URL:String = "assets/dialogs/FV_Support/FV_Greenhouse/seedPacket_knownLrg.png";
      
      private const ICON_UNKNOWN_SM_URL:String = "assets/dialogs/FV_Support/FV_Greenhouse/seedPacket_knownLrg.png";
      
      private const ICON_CREW_EMPTY:String = "assets/dialogs/FV_Support/FV_Greenhouse/crew_blank.png";
      
      private const ICON_TIMER:String = "assets/dialogs/FV_Support/FV_Greenhouse/seedPacket_timerLrg.png";
      
      private var m_bundleData:Object = null;
      
      public function GreenhouseNurseryDialog(building:StorageBuilding, buildingClassName:String, mainDialog:GreenhouseWithdrawal, container:MovieClip, breedingState:BreedingState, openToTray:int = 0)
      {
         super();
         this.m_storageBuilding = building;
         this.m_buildingClassName = buildingClassName;
         this.m_mainDialog = mainDialog;
         this.m_container = container;
         this.m_breedingState = breedingState;
         this.m_openToTray = openToTray;
         this.m_featureState = this.m_breedingState.getBreedingFeatureState(this.BREEDING_FEATURE_NAME);
         this.m_buttonsVector = new Vector.<FarmAnimatedTextButton>();
         this.initPanel();
      }
      
      public function openFreshTab(breedingState:BreedingState, index:int) : void
      {
         this.m_breedingState = breedingState;
         this.m_featureState = this.m_breedingState.getBreedingFeatureState(this.BREEDING_FEATURE_NAME);
         this.clearAllLoadedIcons();
         this.showTray(index);
         this.showAllTrayIcons(true);
      }
      
      private function initPanel() : void
      {
         var currentNumTrays:int = 0;
         var trayIdx:int = 0;
         var ZwBtn:ZwButton = null;
         this.m_trayArray = new Array();
         for(var idx:int = 0; idx < this.TRAY_AMOUNT_3; idx++)
         {
            this.m_container["tray_" + idx + "_mc"].visible = false;
            this.m_trayArray.push(this.m_container["tray_" + idx + "_mc"]);
         }
         this.m_trayAddBtn0 = this.m_container.trayAdd_0_mc;
         this.m_trayAddBtn0.visible = false;
         this.m_trayAddBtn1 = this.m_container.trayAdd_1_mc;
         this.m_trayAddBtn1.visible = false;
         this.m_seedTray = this.m_container.seedTray_mc;
         this.m_slot0 = this.m_seedTray.slot_0_mc;
         this.m_slot0.visible = false;
         this.m_slot1 = this.m_seedTray.slot_1_mc;
         this.m_slot1.visible = false;
         this.m_genericText0 = this.m_seedTray.generic_0_tf;
         this.m_genericText0.visible = false;
         this.m_genericText1 = this.m_seedTray.generic_1_tf;
         this.m_genericText1.visible = false;
         this.m_genericText2 = this.m_seedTray.generic_2_tf;
         this.m_genericText2.visible = false;
         this.m_result0 = this.m_seedTray.result_0_mc;
         this.m_result0.visible = false;
         this.m_result1 = this.m_seedTray.result_1_mc;
         this.m_result1.visible = false;
         this.m_crewSlot0 = this.m_seedTray.crewSlot_0_mc;
         this.m_crewSlot0.visible = false;
         this.m_crewSlot1 = this.m_seedTray.crewSlot_1_mc;
         this.m_crewSlot1.visible = false;
         if(this.m_container.description_tf)
         {
            ZLocUtils.setText(this.m_container,"description_tf","Dialogs","GreenhouseNurseryGenealogyPrompt");
         }
         this.clearAllLoadedIcons();
         var currentStorageLevel:int = this.m_storageBuilding.storageLevel;
         if(this.m_featureState != null)
         {
            currentNumTrays = this.m_featureState.getNumUnlockedTrays();
            for(trayIdx = 0; trayIdx < currentNumTrays; trayIdx++)
            {
               this.m_trayArray[trayIdx].visible = true;
               this.m_trayArray[trayIdx].trayNumber_tf.text = String(trayIdx + 1);
               ZLocUtils.setText(this.m_trayArray[trayIdx],"trayTitle_tf","Dialogs","GreenhouseNurseryTray");
               ZwBtn = new ZwButton(this.m_trayArray[trayIdx],this.onTrayClick);
               this.m_trayArray[trayIdx].trayTab_mc.visible = false;
               this.setTrayReadiness(trayIdx);
            }
         }
         this.setExpandButtons(currentStorageLevel);
         this.showTray(this.m_openToTray);
      }
      
      private function setExpandButtons(currentStorageLevel:int) : void
      {
         var expandButton:ZwButton = null;
         if(currentStorageLevel == 1)
         {
            this.m_trayAddBtn0.visible = true;
            ZLocUtils.setText(this.m_trayAddBtn0,"generic_0_tf","Dialogs","GreenhouseNurserTrayExpand0");
            ZLocUtils.setText(this.m_trayAddBtn0,"generic_1_tf","Dialogs","GreenhouseNurserTrayExpand1");
            this.m_trayAddBtn1.visible = false;
            expandButton = new ZwButton(this.m_trayAddBtn0,this.openExpandTab);
         }
         else if(currentStorageLevel == 2)
         {
            this.m_trayAddBtn0.visible = false;
            this.m_trayAddBtn1.visible = true;
            ZLocUtils.setText(this.m_trayAddBtn1,"generic_0_tf","Dialogs","GreenhouseNurserTrayExpand0");
            ZLocUtils.setText(this.m_trayAddBtn1,"generic_1_tf","Dialogs","GreenhouseNurserTrayExpand1");
            expandButton = new ZwButton(this.m_trayAddBtn1,this.openExpandTab);
         }
         else if(currentStorageLevel == 3)
         {
            this.m_trayAddBtn0.visible = false;
            this.m_trayAddBtn1.visible = false;
         }
      }
      
      private function openExpandTab(event:MouseEvent) : void
      {
         this.m_mainDialog.openExpansion();
      }
      
      private function clearAllLoadedIcons() : void
      {
         Utilities.removeAllChildren(this.m_slot0.icon_mc);
         Utilities.removeAllChildren(this.m_slot1.icon_mc);
         Utilities.removeAllChildren(this.m_slot0.icon_packetLrg_mc);
         Utilities.removeAllChildren(this.m_slot1.icon_packetLrg_mc);
         Utilities.removeAllChildren(this.m_result0.icon_mc);
         Utilities.removeAllChildren(this.m_result1.icon_mc);
         Utilities.removeAllChildren(this.m_result0.icon_packetLrg_mc);
         Utilities.removeAllChildren(this.m_result1.icon_packetLrg_mc);
         Utilities.removeAllChildren(this.m_crewSlot1.slot_0_mc.icon_mc);
         Utilities.removeAllChildren(this.m_crewSlot1.slot_1_mc.icon_mc);
         Utilities.removeAllChildren(this.m_crewSlot1.slot_2_mc.icon_mc);
         var numButtons:int = int(this.m_buttonsVector.length);
         for(var i:int = 0; i < numButtons; i++)
         {
            if(this.m_buttonsVector[i] != null)
            {
               this.m_buttonsVector[i].release();
            }
         }
         this.m_buttonsVector = new Vector.<FarmAnimatedTextButton>();
      }
      
      private function onTrayClick(event:MouseEvent) : void
      {
         var trayIndex:int = int(event.currentTarget.name.split("_")[1]);
         this.clearAllLoadedIcons();
         this.showTray(trayIndex);
      }
      
      private function hideAllTrayTabs() : void
      {
         for(var idx:int = 0; idx < this.TRAY_AMOUNT_3; idx++)
         {
            this.m_trayArray[idx].trayTab_mc.visible = false;
         }
      }
      
      private function showTray(index:int) : void
      {
         var trayArray:Array = this.m_featureState.trays;
         this.m_selectedSeed0 = null;
         this.m_selectedSeed1 = null;
         this.m_currentTray = index;
         if(trayArray[index] == undefined)
         {
            this.setSlots(this.SLOT_STATE_OPEN,index);
            this.setResult(this.SLOT_STATE_OPEN,index);
            this.m_crewSlot0.visible = true;
            this.m_crewSlot1.visible = false;
            this.m_result0.visible = false;
            this.m_result1.visible = false;
            this.m_genericText1.text = "=";
            this.m_genericText2.visible = false;
         }
         else if(this.isReady(index))
         {
            this.setSlots(this.SLOT_STATE_FILLED,index);
            this.setResult(this.SLOT_STATE_FILLED,index);
            this.m_crewSlot0.visible = false;
            this.setCrewPanel(index,true);
            this.m_result0.visible = false;
            this.m_result1.visible = true;
            this.m_genericText1.text = "+";
            this.m_genericText2.visible = true;
         }
         else
         {
            this.setSlots(this.SLOT_STATE_FILLED,index);
            this.setResult(this.SLOT_STATE_FILLED,index);
            this.m_crewSlot0.visible = false;
            this.setCrewPanel(index,false);
            this.m_result0.visible = false;
            this.m_result1.visible = true;
            this.m_genericText1.text = "+";
            this.m_genericText2.visible = true;
         }
         this.m_slot0.visible = true;
         this.m_slot1.visible = true;
         this.m_genericText0.visible = true;
         this.m_genericText0.text = "+";
         this.m_genericText1.visible = true;
         this.hideAllTrayTabs();
         this.m_trayArray[index].trayTab_mc.visible = true;
         this.m_container.visible = true;
      }
      
      private function setTrayReadiness(index:int) : void
      {
         var frameNumberArray:Array = new Array();
         frameNumberArray = [5,4,3,2,1];
         this.m_trayArray[index].trayReady_mc.gotoAndStop(frameNumberArray[this.getDaysLeft(index)]);
      }
      
      private function getDaysLeft(index:int) : int
      {
         var timeRemaining:Number = NaN;
         var daysLeft:int = this.DAYS_REMAINING_NULL;
         if(this.m_featureState.trays[index] != null)
         {
            timeRemaining = this.m_featureState.timeRemaining(index);
            daysLeft = int(Math.ceil(timeRemaining / 86400));
            if(daysLeft < 0)
            {
               daysLeft = 0;
            }
         }
         return daysLeft;
      }
      
      private function setSlots(state:String, index:int) : void
      {
         var item0:FarmItem = null;
         var item1:FarmItem = null;
         ZLocUtils.setText(this.m_slot0,"Title_tf","Dialogs","GreenhouseNurseryTraySlot1");
         ZLocUtils.setText(this.m_slot1,"Title_tf","Dialogs","GreenhouseNurseryTraySlot2");
         if(state == this.SLOT_STATE_OPEN)
         {
            this.m_slot0.placeSeed_bt.visible = true;
            this.m_slot1.placeSeed_bt.visible = true;
            this.m_buttonsVector.push(new FarmAnimatedTextButton(this.m_slot0.placeSeed_bt,ZLocUtils.t("Dialogs","GreenhouseNurseryPlaceASeed"),this.onPlaceSeedClick));
            this.m_buttonsVector.push(new FarmAnimatedTextButton(this.m_slot1.placeSeed_bt,ZLocUtils.t("Dialogs","GreenhouseNurseryPlaceASeed"),this.onPlaceSeedClick));
            ZLocUtils.setText(this.m_slot0,"cropName_tf","Dialogs","GreenhouseNurseryTrayEmpty");
            ZLocUtils.setText(this.m_slot1,"cropName_tf","Dialogs","GreenhouseNurseryTrayEmpty");
            this.m_slot0.seedCost_mc.visible = false;
            this.m_slot1.seedCost_mc.visible = false;
         }
         else
         {
            item0 = Global.farmGameSettingsManager.getFarmItemByCode(this.m_featureState.trays[index].ingredients[0].code);
            item1 = Global.farmGameSettingsManager.getFarmItemByCode(this.m_featureState.trays[index].ingredients[1].code);
            this.loadIcon(item0.iconUrl,this.m_slot0.icon_mc);
            this.loadIcon(item1.iconUrl,this.m_slot1.icon_mc);
            this.m_slot0.placeSeed_bt.visible = false;
            this.m_slot1.placeSeed_bt.visible = false;
            this.loadIcon(Global.getAssetURL(this.ICON_KNOWN_LRG_URL),this.m_slot0.icon_packetLrg_mc,1);
            this.loadIcon(Global.getAssetURL(this.ICON_KNOWN_LRG_URL),this.m_slot1.icon_packetLrg_mc,1);
            ZLocUtils.setTextAsTitle(this.m_slot0,"cropName_tf",item0.friendlyName);
            ZLocUtils.setTextAsTitle(this.m_slot1,"cropName_tf",item1.friendlyName);
            this.m_slot0.seedCost_mc.cost_tf.text = String(item0.cost * this.SEED_AMOUNT);
            this.m_slot1.seedCost_mc.cost_tf.text = String(item1.cost * this.SEED_AMOUNT);
            this.m_slot0.seedCost_mc.visible = true;
            this.m_slot1.seedCost_mc.visible = true;
         }
      }
      
      private function onPlaceSeedClick(event:MouseEvent) : void
      {
         var idy:int = 0;
         this.m_currentSlot = int(event.currentTarget.parent.name.split("_")[1]);
         var seedNameArray:Array = new Array();
         var genealogy:Array = Global.player.breedingState.getBreedingFeatureState(this.BREEDING_FEATURE_NAME).genealogy;
         var item:FarmItem = null;
         for(var idx:int = 0; idx < genealogy.length; idx++)
         {
            for(idy = 0; idy < 2; idy++)
            {
               item = Global.farmGameSettingsManager.getFarmItemByCode(genealogy[idx].ingredient[idy].code);
               if(seedNameArray.indexOf(item.name) == -1)
               {
                  seedNameArray.push(item.name);
               }
            }
         }
         seedNameArray.sort();
         UI.displayMiniMarketDialog(seedNameArray,UI.MINIMARKET_CONTEXT_GREENHOUSE,"seed",this.onReturnFromMarket,false);
      }
      
      private function loadIcon(path:String, container:MovieClip, scale:Number = 0.5) : void
      {
         var trayAtLoad:int = 0;
         var icon:Loader = null;
         trayAtLoad = this.m_currentTray;
         icon = LoadingManager.load(path,function(event:Event):void
         {
            var dispObj:* = undefined;
            if(trayAtLoad == m_currentTray)
            {
               dispObj = icon.content;
               dispObj.scaleX = dispObj.scaleY = scale;
               Utilities.removeAllChildren(container);
               container.addChild(dispObj);
               container.visible = true;
            }
         });
      }
      
      private function onReturnFromMarket(isCloseFromBuy:Boolean) : void
      {
         var gm:GameMode = null;
         var gmPlant:GMMarketPlant = null;
         var item:FarmItem = null;
         if(isCloseFromBuy)
         {
            gm = Global.world.getTopGameMode();
            if(gm is GMMarketPlant)
            {
               gmPlant = gm as GMMarketPlant;
               this["m_slot" + this.m_currentSlot].placeSeed_bt.visible = false;
               item = Global.farmGameSettingsManager.getFarmItemByName(gmPlant.seedType);
               this.loadIcon(item.iconUrl,this["m_slot" + this.m_currentSlot].icon_mc);
               this.loadIcon(Global.getAssetURL(this.ICON_KNOWN_LRG_URL),this["m_slot" + this.m_currentSlot].icon_packetLrg_mc,1);
               ZLocUtils.setTextAsTitle(this["m_slot" + this.m_currentSlot],"cropName_tf",item.friendlyName);
               this["m_slot" + this.m_currentSlot].seedCost_mc.cost_tf.text = String(item.cost * this.SEED_AMOUNT);
               this["m_slot" + this.m_currentSlot].seedCost_mc.visible = true;
               gm.disableMode();
               Global.world.removeGameMode(gm);
               Global.world.addGameMode(new GMDefault(),true);
               this["m_selectedSeed" + this.m_currentSlot] = item;
               if(this.m_selectedSeed0 != null && this.m_selectedSeed1 != null)
               {
                  this.lookForSeedMatch();
               }
            }
         }
      }
      
      private function lookForSeedMatch() : void
      {
         var parentIndex:int = 0;
         var objArray:Array = null;
         var obj0:Object = null;
         var obj1:Object = null;
         var cost:int = 0;
         var resultCode:String = null;
         var resultName:String = null;
         var seedXML:XML = null;
         var seedParentLength:int = int(this.m_featureState.genealogy.length);
         var isMatch:Boolean = false;
         for(var idx:int = 0; idx < seedParentLength; idx++)
         {
            if(this.m_selectedSeed0.code == this.m_featureState.genealogy[idx].ingredient[0].code || this.m_selectedSeed0.code == this.m_featureState.genealogy[idx].ingredient[1].code)
            {
               parentIndex = idx;
            }
         }
         if((this.m_selectedSeed1.code == this.m_featureState.genealogy[parentIndex].ingredient[0].code || this.m_selectedSeed1.code == this.m_featureState.genealogy[parentIndex].ingredient[1].code) && this.m_selectedSeed0.code != this.m_selectedSeed1.code)
         {
            isMatch = true;
         }
         if(isMatch)
         {
            objArray = new Array();
            obj0 = new Object();
            obj0.code = this.m_selectedSeed0.code;
            obj0.quantity = this.SEED_AMOUNT;
            obj1 = new Object();
            obj1.code = this.m_selectedSeed1.code;
            obj1.quantity = this.SEED_AMOUNT;
            objArray = [obj0,obj1];
            cost = (this.m_selectedSeed0.cost + this.m_selectedSeed1.cost) * this.SEED_AMOUNT;
            if(Global.player.canBuy(cost))
            {
               this.popTransactionDialog(ZLocUtils.t("Dialogs","GreenhouseCombiningSeeds",{
                  "seedA":ZLocUtils.tk_pk(this.m_selectedSeed0.friendlyName),
                  "seedB":ZLocUtils.tk_pk(this.m_selectedSeed1.friendlyName)
               }));
               resultCode = this.m_featureState.genealogy[parentIndex].itemCode;
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  resultName = Global.farmGameSettingsManager.getFarmItemByCode(resultCode).name;
               }
               else
               {
                  seedXML = Global.farmGameSettingsManager.getItemXMLByCode(resultCode);
                  resultName = seedXML.@name;
               }
               FarmStatsManager.count("greenhouse","Breed_started",resultName);
               TransactionManager.addTransaction(new TBreedingProjectBegin(this.BREEDING_FEATURE_NAME,this.m_currentTray,objArray as Object,this.updateUIAfterSeedPurchase));
            }
            else
            {
               this.popNotEnoughCoinsDialog();
            }
         }
         else
         {
            this.popNoMatchDialog();
         }
      }
      
      public function updateUIAfterSeedPurchase() : void
      {
         this.m_transactionDialog.close();
         this.m_transactionDialog = null;
         this.m_featureState = this.m_breedingState.getBreedingFeatureState(this.BREEDING_FEATURE_NAME);
         var cost:int = (this.m_selectedSeed0.cost + this.m_selectedSeed1.cost) * this.SEED_AMOUNT;
         Global.player.gold -= cost;
         this.showAllTrayIcons(true);
         this.showTray(this.m_currentTray);
      }
      
      private function popNotEnoughCoinsDialog() : void
      {
         var msg:String = ZLocUtils.t("Dialogs","GreenhouseNurseryNotEnoughCoins");
         var dialog:GenericXMLDialog = new GenericXMLDialog(null,null,null,null,NaN,NaN,msg,null,true,ZLocUtils.t("Dialogs","Okay"),this.onNoMatchClose);
         UI.displayPopup(dialog,false);
      }
      
      private function popNoMatchDialog() : void
      {
         var msg0:String = ZLocUtils.t("Dialogs","GreenhouseNurseryNoMatchSeed1",{
            "seedA":ZLocUtils.tk_pk(this.m_selectedSeed0.friendlyName),
            "seedB":ZLocUtils.tk_pk(this.m_selectedSeed1.friendlyName)
         });
         var msg1:String = ZLocUtils.t("Dialogs","GreenhouseNurseryNoMatchSeed2",{
            "seedA":ZLocUtils.tk_pk(this.m_selectedSeed0.friendlyName),
            "seedB":ZLocUtils.tk_pk(this.m_selectedSeed1.friendlyName)
         });
         var msg2:String = ZLocUtils.t("Dialogs","GreenhouseNurseryNoMatchSeed3");
         var msg3:String = ZLocUtils.t("Dialogs","GreenhouseNurseryNoMatchSeed4");
         var msgArray:Array = [msg0,msg1,msg2,msg3];
         var msg:String = msgArray[Math.floor(Utilities.randBetween(0,4))];
         var dialog:GenericXMLDialog = new GenericXMLDialog(null,null,null,null,NaN,NaN,msg,this.onNoMatchClose,true,ZLocUtils.t("Dialogs","Okay"),this.onNoMatchClose);
         FarmStatsManager.count("greenhouse","Wrong_combination");
         UI.displayPopup(dialog,false);
      }
      
      private function onNoMatchClose(event:Event = null) : void
      {
         this.clearAllLoadedIcons();
         this.showTray(this.m_currentTray);
      }
      
      private function setResult(state:String, index:int) : void
      {
         var item:FarmItem = null;
         ZLocUtils.setText(this.m_result0,"Title_tf","Dialogs","GreenhouseNurseryResult");
         ZLocUtils.setText(this.m_result1,"Title_tf","Dialogs","GreenhouseNurseryResult");
         this.m_result1.visible = false;
         this.m_result0.visible = false;
         if(state == this.SLOT_STATE_OPEN)
         {
            this.loadIcon(Global.getAssetURL(this.ICON_UNKNOWN_LRG_URL),this.m_result0.icon_packetLrg_mc,1);
            this.m_result0.generic_0_tf.visible = true;
            ZLocUtils.setText(this.m_result0,"generic_0_tf","Dialogs","GreenhouseNurseryTakes3Days");
            this.m_result0.meter_mc.visible = false;
            this.m_result0.harvestNow_bt.visible = false;
         }
         else
         {
            this.m_result1.generic_0_tf.visible = false;
            if(this.isReady(index))
            {
               this.m_buttonsVector.push(new FarmAnimatedTextButton(this.m_result1.harvestNow_bt,ZLocUtils.t("Dialogs","GreenhouseNurseryHarvestNow"),this.onHarvestNowClick));
               this.m_result1.harvestNow_bt.visible = true;
               this.m_result1.meter_mc.visible = false;
               this.m_featureState = this.m_breedingState.getBreedingFeatureState(this.BREEDING_FEATURE_NAME);
               item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_featureState.trays[index].resultItemCode);
               this.loadIcon(item.iconUrl,this.m_result1.icon_mc);
               this.loadIcon(Global.getAssetURL(this.ICON_KNOWN_LRG_URL),this.m_result1.icon_packetLrg_mc,1);
            }
            else
            {
               this.m_result1.harvestNow_bt.visible = false;
               this.setProgressMeterAndImage(index);
            }
         }
      }
      
      private function popFinishedSeedDialog(result:Object) : void
      {
         this.m_mainDialog.hideReadyArrow();
         var newSeedName:String = this.m_finishedItem.friendlyName;
         var msg:String = ZLocUtils.t("Dialogs","GreenhouseNurseryFinishedSeed",{"item":ZLocUtils.tk_pk(newSeedName)});
         this.m_bundleData = null;
         if(result.rewardLink)
         {
            this.m_bundleData = {
               "reward_link":result.rewardLink,
               "item_name":this.m_finishedItem.friendlyName,
               "images":[{
                  "href":"{SN_APP_URL}" + result.rewardLink,
                  "src":this.m_finishedItem.icon
               }]
            };
         }
         var dialog:GenericXMLDialog = new GenericXMLDialog(null,null,null,null,NaN,NaN,msg,null,false,ZLocUtils.t("Dialogs","GenericShareButton"),this.shareFeed,"Cancel",this.onCancelShareFeed);
         UI.displayPopup(dialog,false);
      }
      
      private function shareFeed(event:Event = null) : void
      {
         var resultName:String = null;
         var seedXML:XML = null;
         var resultCode:String = this.m_featureState.genealogy[this.m_currentTray].itemCode;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            resultName = Global.farmGameSettingsManager.getFarmItemByCode(resultCode).name;
         }
         else
         {
            seedXML = Global.farmGameSettingsManager.getItemXMLByCode(resultCode);
            resultName = seedXML.@name;
         }
         FarmStatsManager.count("greenhouse","Seed_harvest","Share",resultName);
         var feedAction:String = "GreenHouseCrossbreed";
         GlobalEngine.socialNetwork.publishFeedStory(feedAction,this.m_bundleData,[],false);
         this.updateUIAfterHarvest();
      }
      
      private function onCancelShareFeed(event:Event = null) : void
      {
         var resultName:String = null;
         var seedXML:XML = null;
         var resultCode:String = this.m_featureState.genealogy[this.m_currentTray].itemCode;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            resultName = Global.farmGameSettingsManager.getFarmItemByCode(resultCode).name;
         }
         else
         {
            seedXML = Global.farmGameSettingsManager.getItemXMLByCode(resultCode);
            resultName = seedXML.@name;
         }
         FarmStatsManager.count("greenhouse","Seed_harvest","Cancel",resultName);
         TransactionManager.addTransaction(new TCancelFriendReward([this.m_bundleData["reward_link"]]));
         this.updateUIAfterHarvest();
      }
      
      private function onHarvestNowClick(event:MouseEvent) : void
      {
         this.popTransactionDialog(ZLocUtils.t("Dialogs","GreenHouseHarvestWaiting"));
         this.m_finishedItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_featureState.trays[this.m_currentTray].resultItemCode);
         TransactionManager.addTransaction(new TBreedingProjectFinish(this.BREEDING_FEATURE_NAME,this.m_currentTray,this.popFinishedSeedDialog));
      }
      
      private function updateUIAfterHarvest() : void
      {
         if(this.m_transactionDialog)
         {
            this.m_transactionDialog.close();
            this.m_transactionDialog = null;
         }
         this.m_featureState = this.m_breedingState.getBreedingFeatureState(this.BREEDING_FEATURE_NAME);
         this.clearAllLoadedIcons();
         this.showAllTrayIcons(true);
         this.showTray(this.m_currentTray);
      }
      
      private function isReady(index:int) : Boolean
      {
         var isReady:Boolean = false;
         var timeRemaining:Number = this.m_featureState.timeRemaining(index);
         if(timeRemaining <= 0)
         {
            isReady = true;
            FarmStatsManager.count("greenhouse","Breed_completed","Crew_members",this.m_featureState.trays[index].helpingFriends);
         }
         return isReady;
      }
      
      private function setProgressMeterAndImage(index:int) : void
      {
         ZLocUtils.setText(this.m_result1,"meter_mc.generic_tf","Dialogs","GreenhouseNurseryMeterText",{"dayQuantity":String(this.getDaysLeft(index))});
         var totalTime:Number = 86400 * 3;
         var scale:Number = (totalTime - this.m_featureState.timeRemaining(index)) / totalTime;
         if(scale > 1)
         {
            scale = 1;
         }
         this.m_result1.meter_mc.bar_mc.scaleX = scale;
         Utilities.removeAllChildren(this.m_result1.icon_packetLrg_mc);
         Utilities.removeAllChildren(this.m_result1.icon_mc);
         this.loadIcon(Global.getAssetURL(this.ICON_TIMER),this.m_result1.icon_packetLrg_mc,1);
         this.m_result1.meter_mc.visible = true;
      }
      
      private function setCrewPanel(index:int, isReady:Boolean = false) : void
      {
         var completeNowBtn:FarmAnimatedTextButton = new FarmAnimatedTextButton(this.m_crewSlot1.crewComplete_mc,ZLocUtils.t("Dialogs","GreenhouseNurseryCompleteNowBtn"),this.onCompleteNowClick);
         if(!isReady)
         {
            this.m_crewSlot1.generic_0_tf.text = "";
            completeNowBtn.enabled = true;
         }
         else
         {
            this.m_crewSlot1.generic_0_tf.text = "";
            completeNowBtn.enabled = false;
         }
         this.m_buttonsVector.push(completeNowBtn);
         var numOfFriendsHelping:int = int(this.m_featureState.trays[index].helpingFriends.length);
         var friendCount:int = 0;
         for(var idx:int = 0; idx < this.NUM_FRIEND_SLOTS; idx++)
         {
            if(numOfFriendsHelping > idx)
            {
               this.setFriendSlot(idx,String(this.m_featureState.trays[index].helpingFriends[idx]));
               friendCount++;
            }
            else
            {
               this.setFriendSlot(idx,"0");
            }
         }
         if(friendCount != 3)
         {
         }
         this.m_crewSlot1.visible = true;
      }
      
      private function onAskFriendsClick(event:MouseEvent) : void
      {
         var bm:BreedingManager = BreedingManager.getInstance();
         bm.sendHelpRequest(this.BREEDING_FEATURE_NAME,this.m_currentTray);
      }
      
      private function onCompleteNowClick(event:MouseEvent) : void
      {
         var timeRemaining:Number = this.m_featureState.timeRemaining(this.m_currentTray);
         var cashAmount:Number = Math.ceil(timeRemaining / 86400) * 2;
         if(Global.player.canBuyCash(cashAmount))
         {
            FarmStatsManager.count("greenhouse","Breed_completed","Autocomplete",this.m_featureState.trays[this.m_currentTray].helpingFriends);
            this.showSpendAmountDialog(cashAmount);
         }
      }
      
      private function showSpendAmountDialog(cashAmount:Number) : void
      {
         var msg:String = ZLocUtils.t("Dialogs","GreenhouseNurserySpendAmount",{"cashQuantity":cashAmount});
         var dialog:GenericXMLDialog = new GenericXMLDialog(null,null,null,null,NaN,NaN,msg,null,true,ZLocUtils.t("Dialogs","Okay"),this.sendCompleteTransaction);
         UI.displayPopup(dialog,false);
      }
      
      private function showNotEnoughCashDialog(cashAmount:Number) : void
      {
         var msg:String = ZLocUtils.t("Dialogs","GreenhouseNurseryNotEnoughCash",{"cashQuantity":cashAmount});
         var dialog:GenericXMLDialog = new GenericXMLDialog(null,null,null,null,NaN,NaN,msg,null,true,ZLocUtils.t("Dialogs","Okay"));
         UI.displayPopup(dialog,false);
      }
      
      private function sendCompleteTransaction(event:Event) : void
      {
         this.popTransactionDialog(ZLocUtils.t("Dialogs","GreenhousePurchaseComplete"));
         TransactionManager.addTransaction(new TBreedingProjectPurchaseHelp(this.BREEDING_FEATURE_NAME,this.m_currentTray,this.updateUIAfterHelpPurchase));
      }
      
      private function updateUIAfterHelpPurchase() : void
      {
         this.m_mainDialog.doReadyState();
         this.m_transactionDialog.close();
         this.m_transactionDialog = null;
         this.m_featureState = this.m_breedingState.getBreedingFeatureState(this.BREEDING_FEATURE_NAME);
         this.showAllTrayIcons(true);
         this.showTray(this.m_currentTray);
      }
      
      private function setFriendSlot(index:int, uid:String = "0") : void
      {
         var friend:Friend = Global.friendManager.getAppFriendData(uid);
         Utilities.removeAllChildren(this.m_crewSlot1["slot_" + index + "_mc"].icon_mc);
         if(uid != "0" && friend != null)
         {
            this.loadIcon(friend.snUser.picture,this.m_crewSlot1["slot_" + index + "_mc"].icon_mc,0.7);
         }
         else
         {
            this.loadIcon(Global.getAssetURL(this.ICON_CREW_EMPTY),this.m_crewSlot1["slot_" + index + "_mc"].icon_mc,0.9);
         }
      }
      
      private function showAllTrayIcons(bool:Boolean) : void
      {
         var trayAmountArray:Array = new Array();
         trayAmountArray = [0,this.TRAY_AMOUNT_1,this.TRAY_AMOUNT_2,this.TRAY_AMOUNT_3];
         var currentStorageLevel:int = this.m_storageBuilding.storageLevel;
         var currentNumTrays:int = int(trayAmountArray[currentStorageLevel]);
         for(var trayIdx:int = 0; trayIdx < currentNumTrays; trayIdx++)
         {
            this.m_trayArray[trayIdx].visible = bool;
            if(bool)
            {
               this.setTrayReadiness(trayIdx);
            }
            else
            {
               this.m_trayAddBtn0.visible = false;
               this.m_trayAddBtn1.visible = false;
            }
         }
         this.setExpandButtons(currentStorageLevel);
      }
      
      private function popTransactionDialog(msg:String) : void
      {
         this.m_transactionDialog = new GenericXMLDialog(null,null,null,null,NaN,NaN,msg,null,false);
         UI.displayPopup(this.m_transactionDialog,false);
      }
   }
}

