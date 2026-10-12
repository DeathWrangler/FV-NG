package Classes
{
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsInventoryManager;
   import Managers.OrderBoard.CasablancaInnovationManager;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class CasablancaInnovationMapTrigger extends MapTrigger
   {
      
      protected static var m_arrowBitmaps:Object = new Object();
      
      public static const CASABLANCA_TASK_POINTS_ITEM_CODE:String = "k9b1";
      
      private static const BASIC_ARROW_BITMAP_KEY:String = "BASIC_ARROW_BITMAP_KEY";
      
      protected static var ARROW_SCALE:Number = 0.5;
      
      public static const GUITAR_PICK:Class = EmbeddedArt.guitarPick;
      
      private var m_manager:CasablancaInnovationManager;
      
      protected var m_arrowArt:Class;
      
      protected var m_arrow:DisplayObject;
      
      private var isArrowAttached:Boolean;
      
      private var m_loadComplete:Boolean;
      
      public function CasablancaInnovationMapTrigger(itemName:String, stateToSet:String = "static")
      {
         super(itemName,stateToSet);
         if(itemName == "xca_beachcafe")
         {
            setVisible(false);
         }
         this.attachArrowConditionallyAfterDelay();
      }
      
      override public function onMouseOver(event:MouseEvent) : void
      {
         m_toolTipOverride = "Adele Bistro";
         if(Boolean(this.manager) && this.manager.getNPCProgress() >= 1000)
         {
            if(this.manager.IsBonusBuildingReadyToHarvest())
            {
               m_toolTipOverride = "Ready To Harvest";
            }
            else if(this.manager.isBonusHarvestExpired() == false)
            {
               m_toolTipOverride = "Harvest in " + this.manager.getHervestTime();
            }
         }
         super.onMouseOver(event);
      }
      
      private function get manager() : CasablancaInnovationManager
      {
         return CasablancaInnovationManager.getInstance("CasablancaInnovation");
      }
      
      override public function onClick() : void
      {
         if(this.manager)
         {
            if(this.manager.IsBonusBuildingReadyToHarvest())
            {
               this.manager.harvestCasablancaBuilding(m_itemName);
            }
            else
            {
               FarmStatsManager.count("CasablancaInnovation","OpenFeatureUI",m_itemName);
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
         var points:Number = NaN;
         if(m_itemName == "xca_beachcafe")
         {
            setState("built_0");
         }
         else
         {
            points = FeatureOptionsInventoryManager.getInstance().getCount(CASABLANCA_TASK_POINTS_ITEM_CODE);
            if(points < 300)
            {
               setState("built_0");
            }
            else if(points < 1000)
            {
               setState("built_1");
            }
            else
            {
               setState("built_2");
            }
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

