package GameMode
{
   import Classes.BeehiveBuilding;
   import Classes.BeehiveItem;
   import Classes.CyclingCreditsBuilding;
   import Classes.EasterBasket;
   import Classes.FarmGameObject;
   import Classes.FeatureBuilding;
   import Classes.FeedTroughItem;
   import Classes.FrenchChateauBuilding;
   import Classes.HaitiBackpack;
   import Classes.HalloweenBasket;
   import Classes.HalloweenCastleDuckulaBuilding;
   import Classes.HalloweenCastleDuckulaBuildingCash;
   import Classes.HalloweenHauntedHouseBuilding;
   import Classes.HolidayPresent;
   import Classes.HolidayTreeStorage;
   import Classes.HorseStableBuilding;
   import Classes.PotOfGold;
   import Classes.StorageBuilding;
   import Classes.TuscanWedding;
   import Classes.ValentinesBox;
   import Classes.ZItem.FarmItem;
   import Display.UI;
   import flash.events.TimerEvent;
   import flash.filters.GlowFilter;
   import flash.utils.Timer;
   
   public class GMModifyBuilding extends GMGiftReOpen
   {
      
      protected const SPARKLE_TIME:int = 2500;
      
      protected var m_itemName:String = null;
      
      protected var m_itemCount:int = 1;
      
      protected var m_timer:Timer = null;
      
      protected var m_storageBuildingName:String = null;
      
      protected var m_building:StorageBuilding = null;
      
      protected var m_centerOnBuilding:Boolean = true;
      
      private var m_decorationTypes:Array = [HolidayPresent,FeedTroughItem,BeehiveItem];
      
      private var m_buildingTypes:Array = [HolidayTreeStorage,ValentinesBox,PotOfGold,EasterBasket,HaitiBackpack,HalloweenBasket,CyclingCreditsBuilding,TuscanWedding,HorseStableBuilding,FrenchChateauBuilding,BeehiveBuilding,HalloweenHauntedHouseBuilding,HalloweenCastleDuckulaBuilding,HalloweenCastleDuckulaBuildingCash,FeatureBuilding];
      
      public function GMModifyBuilding(itemName:String, storageBuildingName:String, isGift:Boolean, shouldReOpenGift:Boolean = true, centerOnBuilding:Boolean = true, itemCount:int = 1)
      {
         this.m_itemName = itemName;
         this.m_itemCount = itemCount;
         this.m_storageBuildingName = storageBuildingName;
         this.m_centerOnBuilding = centerOnBuilding;
         super(isGift,shouldReOpenGift);
      }
      
      override public function enableMode() : void
      {
         super.enableMode();
         this.onModeEnabled();
      }
      
      protected function onModeEnabled() : void
      {
         var building:StorageBuilding = null;
         var prevBuildingCount:Number = NaN;
         var item:FarmItem = null;
         var message:String = null;
         var iconFilter:Array = null;
         var iconUrl:String = null;
         var duration:Number = NaN;
         var buildings:Array = Global.world.getStorageBuildings(this.m_storageBuildingName,this.m_itemName);
         var modifiedBuilding:Boolean = false;
         var hasABuilding:Boolean = false;
         var isFirstEntry:Boolean = false;
         if(buildings.length > 0)
         {
            hasABuilding = true;
            for each(building in buildings)
            {
               if(this.canModifyBuilding(building))
               {
                  this.m_building = building;
                  prevBuildingCount = this.m_building.count;
                  this.modifyBuilding();
                  modifiedBuilding = true;
                  item = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName);
                  message = this.m_building.buildStatusMessage([this.m_itemCount,item.friendlyName]);
                  iconFilter = [new GlowFilter(16776960,1,8,8,20)];
                  iconUrl = Global.farmGameSettingsManager.getImageByName(this.m_itemName,"icon");
                  duration = UI.DEFAULT_STATUS_TWEEN_DURATION * 2;
                  this.m_building.displayStatus(message,iconUrl,iconFilter,duration);
                  if(this.m_centerOnBuilding)
                  {
                     this.m_building.centerOn();
                  }
                  if(this.m_timer == null)
                  {
                     this.m_building.startOverlay(FarmGameObject.SPARKLE_URL);
                     this.m_timer = new Timer(this.SPARKLE_TIME,1);
                     this.m_timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerComplete);
                     this.m_timer.start();
                  }
                  if(this.m_building.count == 1 && prevBuildingCount == 0)
                  {
                     isFirstEntry = true;
                  }
                  break;
               }
            }
         }
         this.onFinishModifyBuilding(modifiedBuilding,hasABuilding,isFirstEntry);
         Global.world.popGameMode();
      }
      
      protected function onTimerComplete(event:TimerEvent) : void
      {
         if(this.m_timer != null)
         {
            if(this.m_building != null)
            {
               this.m_building.stopOverlay();
            }
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerComplete);
            this.m_timer = null;
         }
      }
      
      protected function canModifyBuilding(building:Object) : Boolean
      {
         return false;
      }
      
      protected function modifyBuilding() : void
      {
      }
      
      protected function displayBuildingMarketDialog() : void
      {
      }
      
      protected function onFinishModifyBuilding(modifiedBuilding:Boolean, hasABuilding:Boolean, isFirstEntry:Boolean) : void
      {
      }
   }
}

