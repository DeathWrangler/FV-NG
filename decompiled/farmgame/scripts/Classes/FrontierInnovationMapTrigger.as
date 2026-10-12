package Classes
{
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsInventoryManager;
   import Managers.OrderBoard.FrontierInnovationManager;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class FrontierInnovationMapTrigger extends MapTrigger
   {
      
      protected static var m_arrowBitmaps:Object = new Object();
      
      private static const BASIC_ARROW_BITMAP_KEY:String = "BASIC_ARROW_BITMAP_KEY";
      
      protected static var ARROW_SCALE:Number = 0.5;
      
      public static const GUITAR_PICK:Class = EmbeddedArt.guitarPick;
      
      private var m_manager:FrontierInnovationManager;
      
      protected var m_arrowArt:Class;
      
      protected var m_arrow:DisplayObject;
      
      private var isArrowAttached:Boolean;
      
      private var m_loadComplete:Boolean;
      
      public function FrontierInnovationMapTrigger(itemName:String, stateToSet:String = "static")
      {
         super(itemName,stateToSet);
      }
      
      override public function onMouseOver(event:MouseEvent) : void
      {
         m_toolTipOverride = "Hardy Home";
         if(Boolean(this.manager) && this.manager.getNPCProgress() >= 3000)
         {
            if(this.manager.IsBonusBuildingReadyToHarvest())
            {
               m_toolTipOverride = "Ready To Harvest";
            }
            else if(!this.manager.hasHarvestExpiryDatePassedForFeature())
            {
               m_toolTipOverride = "Harvest in " + this.manager.getHervestTime();
            }
         }
         super.onMouseOver(event);
      }
      
      private function get manager() : FrontierInnovationManager
      {
         return FrontierInnovationManager.getInstance("FrontierInnovation");
      }
      
      override public function onClick() : void
      {
         if(this.manager)
         {
            if(this.manager.IsBonusBuildingReadyToHarvest())
            {
               this.manager.harvestFinalBuilding(m_itemName);
            }
            else
            {
               FarmStatsManager.count("FrontierInnovation","OpenFeatureUI",m_itemName);
               this.manager.showMainUI();
            }
         }
      }
      
      override public function getCurrentImageName() : String
      {
         return state;
      }
      
      override public function onUpdate(delta:Number) : void
      {
         super.onUpdate(delta);
         this.updateState();
         if(this.m_loadComplete)
         {
            this.attachArrowConditionally();
         }
      }
      
      public function updateState(e:Event = null) : void
      {
         setVisible(true);
         var points:Number = FeatureOptionsInventoryManager.getInstance().getCount(FrontierInnovationManager.FRONTIER_FEATURE_POINTS_ITEM_CODE);
         if(points < FrontierInnovationManager.VAL_SECOND_MILESTONE)
         {
            setState("built_0");
         }
         else if(points < FrontierInnovationManager.VAL_FINAL_MILESTONE)
         {
            setState("built_1");
         }
         else
         {
            setState("built_2");
         }
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
      
      public function attachArrowConditionally(e:Event = null) : void
      {
         if(m_displayObject)
         {
            if(Boolean(this.manager) && this.manager.IsBonusBuildingReadyToHarvest())
            {
               this.m_arrowArt = GUITAR_PICK;
               this.showArrowDisplay();
            }
            else
            {
               this.hideArrowDisplay();
            }
         }
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
               this.m_arrow.y = 10;
               this.m_arrow.x = 400;
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
   }
}

