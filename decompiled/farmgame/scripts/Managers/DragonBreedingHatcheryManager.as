package Managers
{
   import Classes.UGC.UGCDragonBreeding;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.DragonBreedingCraftWindow;
   import Widgets.Windows.DragonBreedingWindow;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   
   public class DragonBreedingHatcheryManager extends MystreeReskinManagerWithoutEMH
   {
      
      public static const ACTION_HATCH:String = "finishHatching";
      
      protected const ACTION_SPEEDUP_SAPLING:String = "speedUpSapling";
      
      private var m_breedingManager:DragonBreedingManager;
      
      public function DragonBreedingHatcheryManager(featureName:String, breedingManager:DragonBreedingManager)
      {
         this.m_breedingManager = breedingManager;
         super(featureName,"DragonBreedingMystreeService");
      }
      
      public static function getInstance(featureName:String, breedingManager:DragonBreedingManager) : DragonBreedingHatcheryManager
      {
         if(!m_instance)
         {
            m_instance = new Dictionary();
         }
         if(!m_instance.hasOwnProperty(featureName))
         {
            m_instance[featureName] = new DragonBreedingHatcheryManager(featureName,breedingManager);
         }
         return m_instance[featureName] as DragonBreedingHatcheryManager;
      }
      
      public function initialize() : void
      {
         var ftueFlag:String = this.getFtueFlag();
         if(!Global.player.getSeenFlag(ftueFlag))
         {
            this.initFeature();
            Global.player.setSeenFlag(ftueFlag,true);
         }
      }
      
      override protected function initPlotData() : Dictionary
      {
         var plotStates:Dictionary = new Dictionary();
         var numPlots:int = parseInt(m_staticData.numPlots);
         for(var i:int = 0; i < numPlots; i++)
         {
            plotStates[i.toString()] = new Object();
            plotStates[i.toString()][TEND_INDEX] = 0;
            if(i < numPlots / 2)
            {
               plotStates[i.toString()][PLOT_INDEX] = 0;
            }
            else
            {
               plotStates[i.toString()][PLOT_INDEX] = -1;
            }
         }
         return plotStates;
      }
      
      override public function showCraftWindow() : void
      {
         var craftWindow:DragonBreedingCraftWindow = new DragonBreedingCraftWindow(this.m_breedingManager.getCraftDialogURL(),"dragon_pen_finished",DragonBreedingManager.FIRE_ITEM_NAME);
         UI.displayPopup(craftWindow,false,"",true);
      }
      
      override public function addSunshineBuckets(num:Number) : void
      {
         FeatureOptionsInventoryManager.getInstance().addCount(m_staticData.bucketItem,num);
      }
      
      public function hatchDragonEgg(plotId:String, dragonBreedingWindow:DragonBreedingWindow) : void
      {
         if(plotId != null && canGetMystree(plotId))
         {
            setSaplingLevelFor(plotId,PLOT_STATE_EMPTY);
            setSaplingTendStartFor(plotId,0);
            this.m_breedingManager.hatchEgg(Number(plotId),dragonBreedingWindow);
         }
      }
      
      override public function plantSapling(plotId:String) : void
      {
         if(canPlant(plotId))
         {
            setSaplingLevelFor(plotId,LVL1_SAPLING);
            setSaplingTendStartFor(plotId,0);
            FarmStatsManager.count(m_featureName,"breeding","gotegg");
         }
      }
      
      public function plantTutorialSapling(plotId:String) : void
      {
         if(canPlant(plotId))
         {
            setSaplingLevelFor(plotId,LVL5_SAPLING);
            setSaplingTendStartFor(plotId,0);
            FarmStatsManager.count(m_featureName,"Plant",plotId);
         }
      }
      
      private function placeDragonForTesting() : void
      {
         var dragon:UGCDragonBreeding = null;
         dragon = new UGCDragonBreeding("dragon_bluebody_ugc");
         dragon.onMenuClick(new MouseEvent(MouseEvent.CLICK));
      }
      
      public function showBuyConfirmation(price:int, onAcceptBuyConfirmation:Function) : void
      {
         var confirmationText:String = ZLocUtils.t("Dialogs","FarmCashBuyConfirmation",{"price":price});
         if(!UI.displayMessage(confirmationText,GenericPopup.TYPE_ACCEPTCANCEL,onAcceptBuyConfirmation,"farmAnimatedCashConfirmation",true,true))
         {
         }
      }
      
      override protected function removeSunshineBuckets(num:Number) : void
      {
         FeatureOptionsInventoryManager.getInstance().removeCount(m_staticData.bucketItem,num);
      }
      
      public function speedUpSapling(plotId:String = "") : void
      {
         if(this.canSpeedUp(plotId))
         {
            setSaplingTendStartFor(plotId,0);
            Global.player.cash -= getSpeedUpCost();
            TransactionManager.addTransaction(new TGenericTransaction(m_serviceClass,this.ACTION_SPEEDUP_SAPLING,null,[m_featureName,plotId]));
         }
      }
      
      override public function canSpeedUp(plotId:String = "") : Boolean
      {
         var result:Boolean = false;
         if(plotId != "" && this.isSaplingWaiting(plotId) && Global.player.canBuyCash(getSpeedUpCost()))
         {
            result = true;
         }
         return result;
      }
      
      public function isSaplingWaiting(plotId:String = "") : Boolean
      {
         var isWaiting:Boolean = false;
         var saplingLvl:int = getSaplingLevelFor(plotId);
         if(saplingLvl < getMaxLevel())
         {
            if(saplingLvl > PLOT_STATE_EMPTY && !canTend(plotId))
            {
               isWaiting = true;
            }
         }
         return isWaiting;
      }
      
      override protected function getBucketCount() : Number
      {
         return FeatureOptionsInventoryManager.getInstance().getCount(m_staticData.bucketItem);
      }
      
      override public function getNumberOfBuckets() : String
      {
         return this.getBucketCount().toString();
      }
      
      override public function tendSapling(plotId:String, withTransaction:Boolean = true) : void
      {
         var currentTime:int = 0;
         var levelData:Dictionary = null;
         var bucketsNeeded:int = 0;
         var callback:Function = null;
         var isVistingDragonTutorialGrant:Boolean = false;
         var lvl:int = getSaplingLevelFor(plotId);
         if(canTend(plotId))
         {
            if(!hasSunshineBuckets(plotId))
            {
               this.showCraftWindow();
            }
            else
            {
               setSaplingLevelFor(plotId,lvl + 1);
               currentTime = GlobalEngine.serverTime / 1000;
               setSaplingTendStartFor(plotId,currentTime);
               levelData = getLevelData(lvl.toString());
               bucketsNeeded = levelData.hasOwnProperty("quantity") ? int(levelData["quantity"]) : 0;
               this.removeSunshineBuckets(bucketsNeeded);
               callback = null;
               if(withTransaction)
               {
                  if(this.m_breedingManager.canShowVisitingDragonTutorialStep1())
                  {
                     isVistingDragonTutorialGrant = true;
                     if(this.m_breedingManager.dragonBreedingWindow)
                     {
                        this.m_breedingManager.dragonBreedingWindow.tintWindow();
                        this.m_breedingManager.dragonBreedingWindow.enableInput = false;
                     }
                     callback = this.onTendSaplingCallback;
                  }
                  TransactionManager.addTransaction(new TGenericTransaction(m_serviceClass,ACTION_TEND_SAPLING,callback,[m_featureName,plotId,isVistingDragonTutorialGrant]));
                  FarmStatsManager.count(m_featureName,"Tend",plotId,(lvl + 1).toString());
               }
            }
         }
      }
      
      private function onTendSaplingCallback(result:Object) : void
      {
         if(result)
         {
            if(result.hasOwnProperty("success") && result["success"] == true)
            {
               if(Boolean(this.m_breedingManager) && Boolean(this.m_breedingManager.dragonBreedingWindow))
               {
                  if(this.m_breedingManager.canShowVisitingDragonTutorialStep1())
                  {
                     this.m_breedingManager.dragonBreedingWindow.toggleVisitingDragonTutorial(DragonBreedingWindow.VISITING_DRAGON_STEP_1,true);
                     this.m_breedingManager.dragonBreedingWindow.untintWindow();
                     this.m_breedingManager.dragonBreedingWindow.enableInput = true;
                  }
               }
            }
            else if(Boolean(this.m_breedingManager) && Boolean(this.m_breedingManager.dragonBreedingWindow))
            {
               this.m_breedingManager.dragonBreedingWindow.untintWindow();
               this.m_breedingManager.dragonBreedingWindow.enableInput = true;
            }
         }
      }
   }
}

