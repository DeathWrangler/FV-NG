package Classes
{
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.HUD.HUD;
   import Managers.FarmStatsManager;
   import Managers.OctoberSidecarFeatureManager;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class OctoberSidecarFeatureBonusBuilding extends RotateableDecoration
   {
      
      protected static const HARVEST:String = "look inside";
      
      protected static var ARROW_SCALE:Number = 0.5;
      
      protected static var m_arrowBitmaps:Object = {};
      
      private static const BASIC_ARROW_BITMAP_KEY:String = "BASIC_ARROW_BITMAP_KEY";
      
      public static const GUITAR_PICK:Class = EmbeddedArt.guitarPick;
      
      private static const FEATURE_NAME:String = "GilroysParade";
      
      protected var m_arrowArt:Class;
      
      protected var m_arrow:DisplayObject;
      
      private var isArrowAttached:Boolean;
      
      private var m_loadComplete:Boolean;
      
      private var m_buildingItemName:String = "xpu_maggiesmysterybureau";
      
      public function OctoberSidecarFeatureBonusBuilding(itemName:String = null)
      {
         super(itemName);
         this.isArrowAttached = false;
         this.m_loadComplete = false;
         this.attachArrowConditionallyAfterDelay();
      }
      
      public function attachArrowConditionallyAfterDelay() : void
      {
         var timer:Timer = new Timer(10000,1);
         timer.addEventListener(TimerEvent.TIMER,this.loadCompleteEvent);
         timer.start();
      }
      
      public function loadCompleteEvent(e:Event = null) : void
      {
         this.m_loadComplete = true;
      }
      
      override public function onUpdate(delta:Number) : void
      {
         super.onUpdate(delta);
         if(this.m_loadComplete)
         {
            this.attachArrowConditionally();
         }
      }
      
      public function attachArrowConditionally(e:Event = null) : void
      {
         var farmitem:FarmItem = null;
         if(m_displayObject)
         {
            farmitem = this.getItem();
            if(this.canHarvestBonusRewardBuilding() && this.isDecosReadyForHarvest())
            {
               this.m_arrowArt = GUITAR_PICK;
               this.showArrowDisplay();
               if(farmitem)
               {
                  setOverrideToolTip(farmitem.friendlyTitle + "\n" + "Harvest now");
               }
            }
            else
            {
               this.hideArrowDisplay();
               if(farmitem)
               {
                  if(this.canHarvestBonusRewardBuilding() && this.shouldShowBonusHarvestTimer())
                  {
                     setOverrideToolTip(farmitem.friendlyTitle + "\n" + "Harvest in " + HUD.getformattedTimeLeft(this.getTimeLeftForBonusHarvest()));
                  }
                  else
                  {
                     setOverrideToolTip(farmitem.friendlyTitle);
                  }
               }
            }
         }
      }
      
      override public function showMenu() : void
      {
         m_menuItems = this.getMenuItems();
         super.showMenu();
      }
      
      override protected function getMenuItems() : Array
      {
         var item:FarmItem = this.getItem();
         var menuItems:Array = [];
         if(item.allowMove)
         {
            menuItems.push({
               "label":ZLocUtils.t("FarmGame","Move"),
               "action":MOVE_OBJECT
            });
         }
         if(this.canHarvestBonusRewardBuilding() && this.isDecosReadyForHarvest())
         {
            menuItems.push({
               "label":ZLocUtils.t("FarmGame","Harvest"),
               "action":HARVEST
            });
         }
         return menuItems;
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case HARVEST:
                  FarmStatsManager.count(this.manager.FEATURE_TRACKING,this.m_buildingItemName,"harvest","click");
                  OctoberSidecarFeatureManager.getInstance().harvestBonusBuilding(this.m_buildingItemName);
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
      
      public function canHarvestBonusRewardBuilding() : Boolean
      {
         var isStillHarvestable:Boolean = false;
         var bonusStartTime:Number = this.manager.bonusHarvestStartTime;
         if(bonusStartTime)
         {
            if(GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - bonusStartTime < 14 * 86400)
            {
               isStillHarvestable = true;
            }
         }
         return isStillHarvestable;
      }
      
      public function shouldShowBonusHarvestTimer() : Boolean
      {
         var isStillHarvestable:Boolean = false;
         var bonusStartTime:Number = this.manager.bonusHarvestStartTime;
         if(bonusStartTime)
         {
            if(GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - bonusStartTime < 13 * 86400)
            {
               isStillHarvestable = true;
            }
         }
         return isStillHarvestable;
      }
      
      public function isDecosReadyForHarvest() : Boolean
      {
         var result:Boolean = false;
         if(this.getTimeLeftForBonusHarvest() <= 0)
         {
            result = true;
         }
         return result;
      }
      
      public function getTimeLeftForBonusHarvest() : int
      {
         var key:String = this.m_buildingItemName + this.manager.LAST_HARVEST_TIME_KEY;
         return this.getTimeLeft(key,this.manager.DEFAULT_HARVEST_THROTTLE_TIME);
      }
      
      public function getTimeLeft(key:String, throttleTime:int) : int
      {
         var timeSinceLastFeed:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(key);
         return int(throttleTime - timeSinceLastFeed);
      }
      
      protected function setArrowPosition() : void
      {
         var spr:Sprite = null;
         if(Boolean(this.m_arrow) && Boolean(m_displayObject))
         {
            spr = m_displayObject as Sprite;
            this.m_arrow.scaleX = ARROW_SCALE / m_displayObject.scaleX;
            this.m_arrow.scaleY = ARROW_SCALE / m_displayObject.scaleY;
            if(spr.getChildAt(0))
            {
               this.m_arrow.y = -15;
               this.m_arrow.x = 200;
            }
         }
      }
      
      public function showArrowDisplay() : void
      {
         if(this.m_arrow == null)
         {
            this.m_arrow = this.generateHarvestArrow();
         }
         this.m_arrow.visible = true;
         if(this.m_arrow)
         {
            if(!this.isArrowAttached)
            {
               (m_displayObject as Sprite).addChild(this.m_arrow);
               this.isArrowAttached = true;
            }
            this.setArrowPosition();
         }
      }
      
      public function hideArrowDisplay() : void
      {
         if(this.m_arrow)
         {
            this.m_arrow.visible = false;
         }
      }
      
      protected function generateHarvestArrow() : DisplayObject
      {
         var arrow:DisplayObject = this.createHarvestArrow();
         this.setArrowBitmapsData(arrow);
         return arrow;
      }
      
      protected function createHarvestArrow() : DisplayObject
      {
         return new this.m_arrowArt();
      }
      
      protected function setArrowBitmapsData(arrow:DisplayObject) : void
      {
         if(m_arrowBitmaps[BASIC_ARROW_BITMAP_KEY] == null)
         {
            m_arrowBitmaps[BASIC_ARROW_BITMAP_KEY] = new BitmapData(arrow.width,arrow.height,true,0);
            m_arrowBitmaps[BASIC_ARROW_BITMAP_KEY].draw(arrow);
         }
      }
      
      override public function getCurrentImageName() : String
      {
         return state;
      }
      
      private function get manager() : OctoberSidecarFeatureManager
      {
         return OctoberSidecarFeatureManager.getInstance(FEATURE_NAME);
      }
   }
}

