package Managers
{
   import Classes.BuriedTreasure;
   import Classes.Constants.Experiments;
   import Classes.MapResource;
   import Classes.Plot;
   import Classes.Terrain.TerrainUtil;
   import Classes.util.FarmGameUtil;
   import Display.UI;
   import Engine.Classes.Observer.IObserver;
   import Engine.Classes.World;
   import Engine.Managers.TransactionManager;
   import Transactions.TBuriedTreasureAction;
   import Widgets.Windows.BuriedTreasure.BuriedTreasureToasterWindow;
   import Widgets.Windows.BuriedTreasure.BuriedTreasureWindow;
   
   public class BuriedTreasureManager implements IObserver
   {
      
      private static var s_instance:BuriedTreasureManager;
      
      private static const FEATURE_NAME:String = "buriedtreasure";
      
      private static const TREASURE_ACTION_SEEN:String = "BuriedTreasureSeen";
      
      private static const TREASURE_ACTION_OPEN:String = "BuriedTreasureOpen";
      
      private static const TREASURE_ACTION_IGNORED:String = "BuriedTreasureIgnored";
      
      private static const FEATURE_CURRENT_TREASURE:String = "currentBuriedTreasure";
      
      private static const FEATURE_CURRENT_TREASURE_REWARD:String = "currentTreasureReward";
      
      private static const FEATURE_NEXT_TREASURE_REWARD:String = "nextTreasureReward";
      
      private static const FEATURE_NEXT_TREASURE:String = "nextBuriedTreasure";
      
      private static const FEATURE_TREASURE_LAST_SEEN_TIME:String = "buriedTreasureLastSeenTime";
      
      private static const FEATURE_TREASURE_SEEN:String = "buriedTreasureSeen";
      
      public static const BURIED_TREASURE_COUNTER:String = "mystery_treasures";
      
      private static const FIRST_STATIC_REWARD:String = "horse_yellowrose";
      
      private static const FREE_TREASURE_NAME:String = "buriedtreasure_blue";
      
      public static const FEATURE_SHOW_CHANCE_PERCENT:int = 1;
      
      private var m_data:Object = {};
      
      private var m_isDataLoaded:Boolean = false;
      
      private var m_isTreasureShowingOnPlot:Boolean = false;
      
      public function BuriedTreasureManager(key:SingletonEnforcer)
      {
         super();
         GlobalEngine.assert(key != null,"[BuriedTreasureManager] :: Use GetInstance()");
      }
      
      public static function get instance() : BuriedTreasureManager
      {
         if(!s_instance)
         {
            s_instance = new BuriedTreasureManager(new SingletonEnforcer());
         }
         return s_instance;
      }
      
      public static function isFeatureActive() : Boolean
      {
         return Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_BURIED_TREASURE) > 0 && Global.player.level >= 5;
      }
      
      public function init() : void
      {
         var plot:Plot = null;
         this.m_data = s_instance.getFeatureData();
         var plots:Array = Global.world.getObjectsByClass(Plot);
         for each(plot in plots)
         {
            plot.addObserver(this);
         }
         Global.world.addObserver(this);
      }
      
      public function get isDataLoaded() : Boolean
      {
         return this.m_isDataLoaded;
      }
      
      public function getFeatureData() : Object
      {
         var data:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,FEATURE_NAME);
         if(!data)
         {
            data = this.createFeatureData();
         }
         return data;
      }
      
      private function createFeatureData() : Object
      {
         var data:Object = new Object();
         data[FEATURE_TREASURE_LAST_SEEN_TIME] = 0;
         data[FEATURE_CURRENT_TREASURE] = "";
         data[FEATURE_CURRENT_TREASURE_REWARD] = "";
         data[FEATURE_NEXT_TREASURE] = FREE_TREASURE_NAME;
         data[FEATURE_NEXT_TREASURE_REWARD] = FIRST_STATIC_REWARD;
         data[FEATURE_TREASURE_SEEN] = false;
         this.setFeatureData(data);
         return data;
      }
      
      public function setFeatureData(data:Object) : void
      {
         this.m_data = data;
         FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME,FEATURE_NAME,data);
      }
      
      public function notify(event:String, data:Object) : void
      {
         var plot:Plot = null;
         var terrain:String = null;
         var treasure:BuriedTreasure = null;
         switch(event)
         {
            case World.OBSERVABLE_EVENT_ATTACH:
               plot = data as Plot;
               if(plot)
               {
                  plot.addObserver(this);
               }
               break;
            case World.OBSERVABLE_EVENT_DETACH:
               plot = data as Plot;
               if(plot)
               {
                  plot.removeObserver(this);
               }
               break;
            case MapResource.OBSERVABLE_EVENT_STATE:
               plot = data.object as Plot;
               if(plot)
               {
                  terrain = Global.farmGameSettingsManager.selectPrimaryTerrainNameFromGivenCodes(TerrainUtil.getTerrainCodesForItemInstance(plot));
                  if(terrain == FarmGameSettingsManager.TERRAIN_DEFAULT)
                  {
                     if(Boolean(data["state"] && data.state == Plot.STATE_PLOWED) || Boolean(data.state == Plot.STATE_PLANTED) || data.state == Plot.STATE_FALLOW)
                     {
                        if(Boolean(plot && this.shouldShowTreasure()) && Boolean(this.m_data[FEATURE_NEXT_TREASURE] != "") && !this.m_isTreasureShowingOnPlot)
                        {
                           FarmStatsManager.count(BURIED_TREASURE_COUNTER,"view");
                           treasure = new BuriedTreasure(this.m_data[FEATURE_NEXT_TREASURE],plot);
                           treasure.setOuter(Global.world);
                           treasure.attach();
                           this.m_isTreasureShowingOnPlot = true;
                        }
                     }
                  }
               }
         }
      }
      
      public function onBuriedTreasureSeen(treasure:BuriedTreasure) : void
      {
         var cashNeeded:int = treasure.getItem().cash;
         var counter:String = cashNeeded > 0 ? "fc_treasure_shown" : "free_treasure_shown";
         FarmStatsManager.count(BURIED_TREASURE_COUNTER,counter);
         this.m_data[FEATURE_TREASURE_SEEN] = true;
         this.m_data[FEATURE_TREASURE_LAST_SEEN_TIME] = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         this.m_data[FEATURE_CURRENT_TREASURE] = this.m_data[FEATURE_NEXT_TREASURE];
         this.m_data[FEATURE_CURRENT_TREASURE_REWARD] = this.m_data[FEATURE_NEXT_TREASURE_REWARD];
         this.m_data[FEATURE_NEXT_TREASURE] = "";
         this.m_data[FEATURE_NEXT_TREASURE_REWARD] = "";
         UI.displayPopup(new BuriedTreasureWindow(treasure));
         TransactionManager.addTransaction(new TBuriedTreasureAction(treasure.getItemName(),TREASURE_ACTION_SEEN),true);
      }
      
      public function onBuriedTreasureIgnored(treasure:BuriedTreasure) : void
      {
         this.m_data[FEATURE_TREASURE_SEEN] = false;
         TransactionManager.addTransaction(new TBuriedTreasureAction(treasure.getItemName(),TREASURE_ACTION_IGNORED));
      }
      
      public function onBuriedTreasureOpen(treasure:BuriedTreasure) : void
      {
         var success:Boolean = false;
         var cashNeeded:int = treasure.getItem().cash;
         if(cashNeeded > 0)
         {
            if(Global.player.canBuyCash(cashNeeded,true))
            {
               Global.player.tryBuy(treasure);
               success = true;
               FarmStatsManager.count(BURIED_TREASURE_COUNTER,"paid_unlock");
            }
         }
         else
         {
            success = true;
         }
         if(success)
         {
            this.m_data[FEATURE_TREASURE_SEEN] = false;
            Global.player.addGift(this.m_data[FEATURE_CURRENT_TREASURE_REWARD]);
            TransactionManager.addTransaction(new TBuriedTreasureAction(treasure.getItemName(),TREASURE_ACTION_OPEN),true);
         }
      }
      
      public function showTreasureRewardToaster() : void
      {
         var rewardToaster:BuriedTreasureToasterWindow = new BuriedTreasureToasterWindow(this.m_data[FEATURE_CURRENT_TREASURE_REWARD]);
         ToasterManager.getInstance().add(rewardToaster);
      }
      
      public function hideTreasureObject(treasure:BuriedTreasure) : void
      {
         treasure.detach();
         treasure.setHighlighted(false);
         treasure.setToolTip("");
         this.m_isTreasureShowingOnPlot = false;
      }
      
      private function shouldShowTreasure() : Boolean
      {
         var showChancePercent:int = 0;
         var show:Boolean = false;
         showChancePercent = Global.flashHotParams["BURIED_TREASURE_SHOW_CHANCE"] ? int(Global.flashHotParams["BURIED_TREASURE_SHOW_CHANCE"]) : FEATURE_SHOW_CHANCE_PERCENT;
         var now:int = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(now >= this.getNextTreasureAvailableTime())
         {
            show = Math.random() < showChancePercent / 100;
         }
         return show;
      }
      
      private function getNextTreasureAvailableTime() : Number
      {
         var treasureCoolDownInSecs:Number = Number(Global.flashHotParams["BURIED_TREASURE_FEATURE_SEEN_THROTTLE"]);
         return this.m_data[FEATURE_TREASURE_LAST_SEEN_TIME] + treasureCoolDownInSecs;
      }
   }
}

class SingletonEnforcer
{
   
   public function SingletonEnforcer()
   {
      super();
   }
}
