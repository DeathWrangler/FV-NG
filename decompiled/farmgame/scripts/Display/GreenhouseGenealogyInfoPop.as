package Display
{
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.SeedItem;
   import Classes.breeding.BreedingFeatureState;
   import Classes.breeding.BreedingState;
   import Classes.util.ZLocUtils;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.TransactionManager;
   import Engine.Utilities;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Transactions.TBreedingProjectBegin;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class GreenhouseGenealogyInfoPop extends MovieClip
   {
      
      private var m_breedingState:BreedingState;
      
      private var m_makeMore:FarmAnimatedTextButton;
      
      private var m_parentSeed0:FarmItem;
      
      private var m_parentSeed1:FarmItem;
      
      private var m_hybridSeed:FarmItem;
      
      private var m_slot1BtnTool:FarmTextTooltip;
      
      private var m_transactionPop:GenericXMLDialog;
      
      private var m_main:GreenhouseGenealogyDialog;
      
      private var m_idx:int;
      
      private var m_openTray:int = 0;
      
      private var m_genealogyData:Object;
      
      private var m_container:MovieClip;
      
      private var m_slot_0:MovieClip;
      
      private var m_slot_1:MovieClip;
      
      private var m_slotInfo:MovieClip;
      
      private var m_mastery:MovieClip;
      
      private var m_cropType_tf:TextField;
      
      private var m_slotInfoBtn:ZwButton;
      
      private var m_slot1Btn:ZwButton;
      
      private const CELL_BACKGROUND_FRAME_ARRAY:Array = [3,2,1];
      
      private const UNLOCKED_STATE:int = 2;
      
      private const PARTIAL_UNLOCKED_STATE:int = 1;
      
      private const LOCKED_STATE:int = 0;
      
      private const SEED_AMOUNT:int = 50;
      
      private const UNKNOWN_ASSET_URL:String = "assets/dialogs/FV_Support/FV_Greenhouse/seedPacket_unknownSml.png";
      
      private const KNOWN_ASSET_URL:String = "assets/dialogs/FV_Support/FV_Greenhouse/seedPacket_knownSml.png";
      
      private const BREEDING_FEATURE_NAME:String = "greenhousebuildable_finished";
      
      public function GreenhouseGenealogyInfoPop(main:GreenhouseGenealogyDialog, container:MovieClip, genealogyData:Object, idx:int, breedingState:BreedingState)
      {
         super();
         this.m_main = main;
         this.m_container = container;
         this.m_genealogyData = genealogyData;
         this.m_idx = idx;
         this.m_breedingState = breedingState;
         this.m_hybridSeed = Global.farmGameSettingsManager.getFarmItemByCode(this.m_genealogyData.genealogy.itemCode);
         this.m_parentSeed0 = Global.farmGameSettingsManager.getFarmItemByCode(this.m_genealogyData.genealogy.ingredient[0].code);
         this.m_parentSeed1 = Global.farmGameSettingsManager.getFarmItemByCode(this.m_genealogyData.genealogy.ingredient[1].code);
      }
      
      public function openFreshPanel(genealogyData:Object, idx:int, breedingState:BreedingState) : void
      {
         this.m_genealogyData = genealogyData;
         this.m_idx = idx;
         this.m_breedingState = breedingState;
         this.m_hybridSeed = Global.farmGameSettingsManager.getFarmItemByCode(this.m_genealogyData.genealogy.itemCode);
         this.m_parentSeed0 = Global.farmGameSettingsManager.getFarmItemByCode(this.m_genealogyData.genealogy.ingredient[0].code);
         this.m_parentSeed1 = Global.farmGameSettingsManager.getFarmItemByCode(this.m_genealogyData.genealogy.ingredient[1].code);
         this.initPanel();
      }
      
      private function initPanel() : void
      {
         var seedPackage:SeedItem = null;
         var harvestTime:Number = NaN;
         var harvestTimeStr:String = null;
         var dayInSeconds:Number = NaN;
         var slotInfoBtnTool:FarmTextTooltip = null;
         var currentLockState:int = int(this.m_genealogyData.unlockedState);
         this.m_cropType_tf = this.m_container.infoPopup_mc.cropType_tf;
         if(currentLockState > this.LOCKED_STATE)
         {
            ZLocUtils.setTextAsTitle(this.m_cropType_tf,null,this.m_hybridSeed.friendlyName);
         }
         else
         {
            ZLocUtils.setText(this.m_cropType_tf,null,"Dialogs","GreenhouseGenealogyMysterySeed");
         }
         this.m_slot_0 = this.m_container.infoPopup_mc.slot_0_mc;
         if(currentLockState >= this.PARTIAL_UNLOCKED_STATE)
         {
            ZLocUtils.setTextAsTitle(this.m_slot_0,"cropType_tf",this.m_parentSeed0.friendlyName);
            this.loadIcon(this.m_parentSeed0.iconRelativeUrl,this.m_slot_0.icon_mc);
            this.loadIcon(this.KNOWN_ASSET_URL,this.m_slot_0.packetIcon_mc,1);
         }
         else
         {
            ZLocUtils.setText(this.m_slot_0,"cropType_tf","Dialogs","GreenhouseGenealogyMysterySeed");
            this.loadIcon(this.UNKNOWN_ASSET_URL,this.m_slot_0.packetIcon_mc,1);
         }
         this.m_slot_1 = this.m_container.infoPopup_mc.slot_1_mc;
         if(currentLockState >= this.UNLOCKED_STATE)
         {
            ZLocUtils.setTextAsTitle(this.m_slot_1,"cropType_tf",this.m_parentSeed1.friendlyName);
            this.loadIcon(this.m_parentSeed1.iconRelativeUrl,this.m_slot_1.icon_mc);
            this.loadIcon(this.KNOWN_ASSET_URL,this.m_slot_1.packetIcon_mc,1);
         }
         else
         {
            this.m_slot1Btn = new ZwButton(this.m_slot_1);
            this.m_slot1BtnTool = new FarmTextTooltip(this.getMysterySeedHint());
            this.m_slot1Btn.attachTooltip(this.m_slot1BtnTool);
            ZLocUtils.setText(this.m_slot_1,"cropType_tf","Dialogs","GreenhouseGenealogyMysterySeed");
            this.loadIcon(this.UNKNOWN_ASSET_URL,this.m_slot_1.packetIcon_mc,1);
         }
         this.m_slotInfo = this.m_container.infoPopup_mc.slotInfo_0_mc;
         if(currentLockState >= this.PARTIAL_UNLOCKED_STATE)
         {
            ZLocUtils.setTextAsTitle(this.m_slotInfo,"cropType_tf",this.m_hybridSeed.friendlyName);
            seedPackage = BuySeedPackages.getSeedFromSeedPackageName(this.m_hybridSeed.name) as SeedItem;
            harvestTime = seedPackage.growTime;
            harvestTimeStr = "";
            dayInSeconds = Global.farmGameSettingsManager.getNumber("inGameDaySeconds");
            harvestTime = dayInSeconds / 60 / 60 * harvestTime;
            harvestTimeStr = harvestTime.toFixed(0);
            this.m_slotInfo.info_tf.text = ZLocUtils.t("Dialogs","GreenhouseSeedInfo",{
               "coinQuantity":seedPackage.coinYield,
               "xpQuantity":seedPackage.plantXp,
               "hourQuantity":harvestTimeStr
            });
            this.loadIcon(this.m_hybridSeed.iconRelativeUrl,this.m_slotInfo.icon_mc);
            this.loadIcon(this.KNOWN_ASSET_URL,this.m_slotInfo.packetIcon_mc,1);
         }
         else
         {
            this.m_slotInfoBtn = new ZwButton(this.m_slotInfo);
            slotInfoBtnTool = new FarmTextTooltip("Test ");
            this.m_slotInfoBtn.attachTooltip(slotInfoBtnTool);
            this.m_slotInfo.cropType_tf.text = ZLocUtils.t("Dialogs","GreenhouseGenealogyMysterySeed");
            this.loadIcon(this.UNKNOWN_ASSET_URL,this.m_slotInfo.packetIcon_mc,1);
         }
         this.m_container.infoPopup_mc.panelBackground_mc.gotoAndStop(this.CELL_BACKGROUND_FRAME_ARRAY[currentLockState]);
         var hybridData:Object = this.m_hybridSeed as Object;
         this.m_mastery = this.m_container.infoPopup_mc.mastery_mc;
         var hybridSeedData:SeedItem = BuySeedPackages.getSeedFromSeedPackageName(hybridData.cashName) as SeedItem;
         var masteryLevel:int = hybridSeedData.masteryStars + 1;
         this.m_mastery.stars_mc.gotoAndStop(masteryLevel + 1);
         var currentProg:int = hybridSeedData.mastery.currentProgress;
         var nextGoal:int = hybridSeedData.mastery.remainingCropsToNextLevel + currentProg;
         var maxGoal:int = hybridSeedData.mastery.totalCropsNeededMax;
         if(currentProg < maxGoal)
         {
            this.m_mastery.progressBar_mc.scaleX = currentProg / nextGoal;
         }
         else
         {
            this.m_mastery.progressBar_mc.scaleX = 1;
         }
         if(this.m_mastery.progressBar_mc.scaleX > 1)
         {
            this.m_mastery.progressBar_mc.scaleX = 1;
         }
         var maxParentLevel:int = Math.max(this.m_parentSeed0.requiredLevel,this.m_parentSeed1.requiredLevel);
         var numCoins:int = (this.m_parentSeed0.cost + this.m_parentSeed1.cost) * this.SEED_AMOUNT;
         this.m_makeMore = null;
         this.m_makeMore = new FarmAnimatedTextButton(this.m_container.infoPopup_mc.makeMore_bt,ZLocUtils.t("Dialogs","GreenhouseGenealogyMakeMoreButton",{"quantity":numCoins}),this.onMakeMore);
         this.m_makeMore.visible = Global.player.canBuy(numCoins) && Global.player.level >= maxParentLevel && currentLockState == 2;
         this.m_container.blackScreen_mc.visible = true;
         this.m_container.infoPopup_mc.visible = true;
         this.m_container.infoPopup_mc.close_bt.addEventListener(MouseEvent.CLICK,this.close);
      }
      
      private function getMysterySeedHint() : String
      {
         return ZLocUtils.t("Dialogs","GreenhouseHint_" + this.m_parentSeed1.name);
      }
      
      private function close(event:MouseEvent = null) : void
      {
         this.removeAllChildren();
         if(this.m_slot1Btn)
         {
            this.m_slot1Btn.release();
            this.m_slot1Btn = null;
         }
         this.m_container.blackScreen_mc.visible = false;
         this.m_container.infoPopup_mc.visible = false;
         this.m_main.hideInfoPop();
      }
      
      private function onMakeMore(event:MouseEvent) : void
      {
         var objArray:Array = null;
         var obj0:Object = null;
         var obj1:Object = null;
         var m_featureState:BreedingFeatureState = null;
         var resultCode:String = null;
         var resultName:String = null;
         var seedXML:XML = null;
         if(this.hasOpenTrays())
         {
            objArray = new Array();
            obj0 = new Object();
            obj0.code = this.m_parentSeed0.code;
            obj0.quantity = this.SEED_AMOUNT;
            obj1 = new Object();
            obj1.code = this.m_parentSeed1.code;
            obj1.quantity = this.SEED_AMOUNT;
            objArray = [obj0,obj1];
            Global.player.gold -= (this.m_parentSeed0.cost + this.m_parentSeed1.cost) * this.SEED_AMOUNT;
            this.popTransactionPopup(ZLocUtils.t("Dialogs","GreenhouseCombiningSeeds",{
               "seedA":ZLocUtils.tk_pk(this.m_parentSeed0.friendlyName),
               "seedB":ZLocUtils.tk_pk(this.m_parentSeed1.friendlyName)
            }));
            m_featureState = this.m_breedingState.getBreedingFeatureState(this.BREEDING_FEATURE_NAME);
            resultCode = m_featureState.genealogy[this.m_idx].itemCode;
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
            TransactionManager.addTransaction(new TBreedingProjectBegin(this.BREEDING_FEATURE_NAME,this.m_openTray,objArray as Object,this.goToNurseryTab));
         }
         else
         {
            this.popNoOpenTrayDialog();
         }
      }
      
      private function goToNurseryTab(event:Event = null) : void
      {
         if(this.m_transactionPop)
         {
            this.m_transactionPop.close();
            this.m_transactionPop = null;
         }
         this.close();
         this.m_main.openNursery(this.m_openTray);
      }
      
      private function popNoOpenTrayDialog() : void
      {
         var msg:String = ZLocUtils.t("Dialogs","GreenhouseNoOpenTrays");
         var dialog:GenericXMLDialog = new GenericXMLDialog(null,null,null,null,NaN,NaN,msg,null,true,ZLocUtils.t("Dialogs","Okay"),this.goToNurseryTab);
         UI.displayPopup(dialog,false);
      }
      
      private function popTransactionPopup(msg:String) : void
      {
         var tPop:GenericXMLDialog = new GenericXMLDialog(null,null,null,null,NaN,NaN,msg,null,false);
         UI.displayPopup(tPop,false);
         this.m_transactionPop = tPop;
      }
      
      private function hasOpenTrays() : Boolean
      {
         var isOpen:Boolean = false;
         var feature:BreedingFeatureState = this.m_breedingState.getBreedingFeatureState(this.BREEDING_FEATURE_NAME);
         var length:int = feature.getNumUnlockedTrays();
         for(var idx:int = 0; idx < length; idx++)
         {
            if(feature.trays[idx] == null)
            {
               isOpen = true;
               this.m_openTray = idx;
               break;
            }
         }
         return isOpen;
      }
      
      private function removeAllChildren() : void
      {
         Utilities.removeAllChildren(this.m_slot_0.packetIcon_mc);
         Utilities.removeAllChildren(this.m_slot_0.icon_mc);
         Utilities.removeAllChildren(this.m_slot_1.packetIcon_mc);
         Utilities.removeAllChildren(this.m_slot_1.icon_mc);
         Utilities.removeAllChildren(this.m_slotInfo.packetIcon_mc);
         Utilities.removeAllChildren(this.m_slotInfo.icon_mc);
      }
      
      private function loadIcon(path:String, container:MovieClip, scale:Number = 0.35) : void
      {
         var icon:Loader = null;
         icon = LoadingManager.load(Global.getAssetURL(path),function(event:Event):void
         {
            var dispObj:* = icon.content;
            dispObj.scaleX = dispObj.scaleY = scale;
            Utilities.removeAllChildren(container);
            container.addChild(dispObj);
            container.visible = true;
         });
      }
   }
}

