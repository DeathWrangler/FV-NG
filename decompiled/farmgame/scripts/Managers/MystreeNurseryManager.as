package Managers
{
   import Classes.Constants.WorldsConstants;
   import Classes.Constants.ZLocConstants;
   import Classes.MystreeNursery;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericXMLDialog;
   import Display.MOTD;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.FarmGameWorldEvent;
   import GameMode.GMPlantMystree;
   import Managers.Crafting.CraftingManager;
   import Transactions.TGetMOTD;
   import Transactions.TMystreeNursery;
   import Widgets.Constants.Market.Currency;
   import Widgets.Windows.MystreeNurserySunshineCraftWindow;
   import flash.events.Event;
   
   public class MystreeNurseryManager
   {
      
      private static var m_initialized:Boolean = false;
      
      private static var m_instance:MystreeNurseryManager = null;
      
      public static const SB_CRAFTING_ID:String = "kwmx";
      
      private static const CONST_BUCKET:String = "x";
      
      private static const FINAL_SAPLING:String = "saplingtree";
      
      private static const INITIAL_SB_GRANT:int = 3;
      
      private static const FEATURE_ACTIVE_PREREQ:String = "mystree_feature_enabled";
      
      private static const OTHER_WORLDS_MOTD:String = "MOTD_MYSTREE_NOT_STORYBOOK";
      
      private static const Mystrees:Array = ["butterfliesmystree","fireflyburrowmystree","twistedblossommystree","fairypuffmystree","fairyhideoutmystree","magicalpoppiesmystree","wishingstarmystree","poisonapplemystree","pumpkinhousemystree"];
      
      public static const OUT_OF_SB_ASSET_PATH:String = "assets/dialogs/FV_mystreeSunshineCraft.swf";
      
      public static const OUT_OF_SB_BUY_ASSET_PATH:String = "assets/dialogs/FV_mystreeSunshineBuy.swf";
      
      public static const FEATURE_NAME:String = "mystree";
      
      public static const MYSTREE_BUILDING_NAME:String = "jacksmystreenursery";
      
      public static const SPEEDUP_COST:int = 8;
      
      public static const PLOT_UNLOCK_COST:int = 20;
      
      public static const SUNSHINEBUCKET_SET0:int = 10;
      
      public static const SUNSHINEBUCKET_SET1:int = 20;
      
      public static const SUNSHINEBUCKET_SET2:int = 30;
      
      public static const SUNSHINEBUCKET_SET0_COST:int = 20;
      
      public static const SUNSHINEBUCKET_SET1_COST:int = 30;
      
      public static const SUNSHINEBUCKET_SET2_COST:int = 40;
      
      private const ACTION_PLANT_SAPLING:String = "plantSapling";
      
      private const ACTION_TEND_SAPLING:String = "tendSapling";
      
      private const ACTION_INIT_FEATURE:String = "initFeature";
      
      private const ACTION_SPEEDUP_SAPLINGS:String = "speedUpSaplings";
      
      private const ACTION_BUY_PLOT:String = "buyPlot";
      
      private const ACTION_BUY_SUNSHINE_BUCKET:String = "buySunshineBucket";
      
      private var m_mystreeNursery:MystreeNursery;
      
      private var m_motdData:Object = null;
      
      private var m_sentForMOTDData:Boolean = false;
      
      public function MystreeNurseryManager()
      {
         var nurseryArray:Array = null;
         super();
         if(!m_initialized)
         {
            m_initialized = true;
            nurseryArray = Global.world.getObjectsByName(MYSTREE_BUILDING_NAME);
            this.m_mystreeNursery = nurseryArray[0] as MystreeNursery;
            Global.worldManager.addEventListener(FarmGameWorldEvent.WORLD_LOADED,this.onWorldLoaded);
            return;
         }
         throw new Error("Error: Instantiation failed: Use MystreeNurseryManager.getInstance() instead of new.");
      }
      
      public static function getInstance() : MystreeNurseryManager
      {
         if(m_instance == null)
         {
            m_instance = new MystreeNurseryManager();
         }
         return m_instance;
      }
      
      public function getNurseryInstance() : MystreeNursery
      {
         return this.m_mystreeNursery;
      }
      
      public function initFeature() : void
      {
         var sbItem:FarmItem = null;
         var i:int = 0;
         var treeName:String = null;
         if(this.m_mystreeNursery)
         {
            this.m_mystreeNursery.resetFeatureData();
            sbItem = Global.farmGameSettingsManager.getFarmItemByCode(SB_CRAFTING_ID);
            Global.player.addGift(sbItem.name,"0",INITIAL_SB_GRANT);
            for(i = 0; i < Mystrees.length; i++)
            {
               treeName = Mystrees[i];
               FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME,treeName,0);
            }
            TransactionManager.addTransaction(new TMystreeNursery(this.m_mystreeNursery,this.ACTION_INIT_FEATURE));
         }
      }
      
      public function plantSapling(plotId:String) : void
      {
         if(this.canPlant(plotId))
         {
            this.m_mystreeNursery.setSaplingLevelFor(plotId,MystreeNursery.LVL1_SAPLING);
            this.m_mystreeNursery.setSaplingTendStartFor(plotId,0);
            TransactionManager.addTransaction(new TMystreeNursery(this.m_mystreeNursery,this.ACTION_PLANT_SAPLING,null,{"plotId":plotId}));
            FarmStatsManager.count("Mystree","Plant",plotId);
         }
      }
      
      public function tendSapling(plotId:String) : void
      {
         var m_mystreeCraftWindow:MystreeNurserySunshineCraftWindow = null;
         var currentTime:int = 0;
         var bucketsNeeded:int = 0;
         var lvl:int = this.m_mystreeNursery.getSaplingLevelFor(plotId);
         if(this.canTend(plotId))
         {
            if(!this.hasSunshineBuckets(plotId))
            {
               m_mystreeCraftWindow = new MystreeNurserySunshineCraftWindow();
               UI.displayPopup(m_mystreeCraftWindow,true,"",true);
            }
            else
            {
               this.m_mystreeNursery.setSaplingLevelFor(plotId,lvl + 1);
               currentTime = GlobalEngine.serverTime / 1000;
               this.m_mystreeNursery.setSaplingTendStartFor(plotId,currentTime);
               bucketsNeeded = Global.farmGameSettingsManager.getInt(MystreeNursery.TEND_SB_QUANTITY_PREFIX + lvl);
               Global.player.removeGiftWithKey(SB_CRAFTING_ID,bucketsNeeded);
               TransactionManager.addTransaction(new TMystreeNursery(this.m_mystreeNursery,this.ACTION_TEND_SAPLING,null,{"plotId":plotId}));
               FarmStatsManager.count("Mystree","Tend",plotId,(lvl + 1).toString());
            }
         }
      }
      
      public function speedUpSaplings() : void
      {
         var i:int = 0;
         if(this.canSpeedUp())
         {
            for(i = 0; i < MystreeNursery.NUM_PLOTS; i++)
            {
               this.m_mystreeNursery.setSaplingTendStartFor(i.toString(),0);
            }
            Global.player.cash -= SPEEDUP_COST;
            TransactionManager.addTransaction(new TMystreeNursery(this.m_mystreeNursery,this.ACTION_SPEEDUP_SAPLINGS));
         }
      }
      
      public function canTend(plotId:String) : Boolean
      {
         var result:Boolean = false;
         if(Boolean(this.m_mystreeNursery) && this.m_mystreeNursery.canTend(plotId))
         {
            result = true;
         }
         return result;
      }
      
      public function canPlant(plotId:String) : Boolean
      {
         var result:Boolean = false;
         if(Boolean(this.m_mystreeNursery) && this.m_mystreeNursery.canPlant(plotId))
         {
            result = true;
         }
         return result;
      }
      
      public function canSpeedUp() : Boolean
      {
         var result:Boolean = false;
         if(this.isAnySaplingWaiting() && Global.player.cash >= SPEEDUP_COST)
         {
            result = true;
         }
         return result;
      }
      
      public function isAnySaplingWaiting() : Boolean
      {
         var saplingLvl:int = 0;
         var isWaiting:Boolean = false;
         for(var i:int = 0; i < MystreeNursery.NUM_PLOTS; i++)
         {
            saplingLvl = this.m_mystreeNursery.getSaplingLevelFor(i.toString());
            if(saplingLvl > MystreeNursery.PLOT_STATE_EMPTY && !this.m_mystreeNursery.canTend(i.toString()))
            {
               isWaiting = true;
            }
         }
         return isWaiting;
      }
      
      public function setClaimedTreeFeatureOption(treeName:String) : void
      {
         var treecount:int = int(FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,treeName));
         FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME,treeName,treecount + 1);
      }
      
      public function getNumberOfBuckets() : String
      {
         var sbItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(SB_CRAFTING_ID);
         return CONST_BUCKET + Global.player.getGiftCountForItem(sbItem.name);
      }
      
      public function showCraftingWindowWithItem() : void
      {
         var prompt:GenericXMLDialog = null;
         var craftShop:String = CraftingManager.getCraftShopNameForCurrentWorld(Global.worldManager.currentWorldType);
         var craftshopOpened:Boolean = false;
         if(CraftingManager.getInstance().showCraftingWindowForRecipe(SB_CRAFTING_ID))
         {
            craftshopOpened = true;
         }
         if(!craftshopOpened)
         {
            prompt = new GenericXMLDialog(null,null,null,Global.farmGameSettingsManager.getImageByName("craftingworkshop_finished","icon",false),100,100,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"SurfaceCraftShop_Message"),null,true,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"SurfaceCraftShop_Button"),function(event:Event):void
            {
               Global.world.enterForcePlaceMode("craftingworkshop_finished",true,0,false,false,{"suppressGiftRepop":true});
            });
            UI.displayPopup(prompt,true,"",true);
         }
      }
      
      public function getClaimedCount(index:int) : int
      {
         var countText:String = "";
         return int(FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,Mystrees[index]));
      }
      
      public function getMystree(plotId:String) : void
      {
         if(plotId != null && this.canGetMystree(plotId))
         {
            Global.world.addGameMode(new GMPlantMystree(FINAL_SAPLING,plotId,false,0,true,Currency.COINS));
         }
      }
      
      public function onMystreePlaced(plotId:String) : void
      {
         if(plotId != null)
         {
            this.m_mystreeNursery.setSaplingLevelFor(plotId,0);
         }
      }
      
      public function canGetMystree(plotId:String) : Boolean
      {
         var result:Boolean = false;
         var lvl:int = this.m_mystreeNursery.getSaplingLevelFor(plotId);
         if(lvl == MystreeNursery.LVL_FINAL_MYSTREE)
         {
            result = true;
         }
         return result;
      }
      
      public function onBuyPlot(plotId:String) : void
      {
         if(plotId != null)
         {
            Global.player.cash -= PLOT_UNLOCK_COST;
            this.m_mystreeNursery.setSaplingLevelFor(plotId,0);
            TransactionManager.addTransaction(new TMystreeNursery(this.m_mystreeNursery,this.ACTION_BUY_PLOT,null,{"plotId":plotId}),true);
            FarmStatsManager.count("Mystree","unlock_slot",plotId);
         }
      }
      
      public function buySunshineBuckets(buyPackage:String) : void
      {
         var sunshinePackage:FarmItem = null;
         if(buyPackage != null)
         {
            sunshinePackage = Global.farmGameSettingsManager.getFarmItemByName(buyPackage);
            Global.player.buyFarmItem(sunshinePackage,Currency.CASH,1);
         }
      }
      
      public function hasSunshineBuckets(plotId:String) : Boolean
      {
         var result:Boolean = false;
         var lvl:int = this.m_mystreeNursery.getSaplingLevelFor(plotId);
         var sbItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(SB_CRAFTING_ID);
         var bucketsNeeded:int = Global.farmGameSettingsManager.getInt(MystreeNursery.TEND_SB_QUANTITY_PREFIX + lvl);
         if(Global.player.getGiftCountForItem(sbItem.name) >= bucketsNeeded)
         {
            result = true;
         }
         return result;
      }
      
      public function getUniqueMystreeCount() : int
      {
         var count:int = 0;
         var uniqueCount:int = 0;
         for(var i:int = 0; i < Mystrees.length; i++)
         {
            count = MystreeNurseryManager.getInstance().getClaimedCount(i);
            if(count != 0)
            {
               uniqueCount++;
            }
         }
         return uniqueCount;
      }
      
      public function isFeatureActive() : Boolean
      {
         var result:Boolean = false;
         if(PrerequisiteUtility.checkPrereqByName(FEATURE_ACTIVE_PREREQ))
         {
            result = true;
         }
         return result;
      }
      
      public function handleHUDClick() : void
      {
         var currentFarm:String = Global.worldManager.currentWorldType;
         if(currentFarm == WorldsConstants.WORLD_ID_STORYBOOK)
         {
            this.m_mystreeNursery.openMystreeUI();
         }
         else if(this.m_motdData)
         {
            MOTD.displayMOTD(this.m_motdData,false);
         }
         else if(!this.m_sentForMOTDData)
         {
            this.m_sentForMOTDData = true;
            TransactionManager.addTransaction(new TGetMOTD(OTHER_WORLDS_MOTD,this.onGetMOTD),true);
         }
      }
      
      private function onWorldLoaded(event:Event) : void
      {
         var nurseryArray:Array = null;
         var currentFarm:String = Global.worldManager.currentWorldType;
         if(currentFarm == WorldsConstants.WORLD_ID_STORYBOOK)
         {
            nurseryArray = Global.world.getObjectsByName(MYSTREE_BUILDING_NAME);
            this.m_mystreeNursery = nurseryArray[0] as MystreeNursery;
         }
      }
      
      private function onGetMOTD(amfResult:Object) : void
      {
         if(Boolean(amfResult) && amfResult.hasOwnProperty("motdSeenFlag"))
         {
            this.m_motdData = amfResult;
            this.m_sentForMOTDData = false;
            MOTD.displayMOTD(this.m_motdData,false);
         }
      }
   }
}

