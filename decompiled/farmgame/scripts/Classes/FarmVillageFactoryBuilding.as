package Classes
{
   import Classes.util.FarmGameUtil;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FarmVillageFactoriesManager;
   import Managers.FeatureOptionsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Tooltips.FarmVillageFactoryBuildingToolTip;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Timer;
   
   public class FarmVillageFactoryBuilding extends Building
   {
      
      protected static var ARROW_SCALE:Number = 0.5;
      
      protected static var DEFAULT_ARROW_SIZE_X:Number = 40.05;
      
      protected static var DEFAULT_ARROW_SIZE_Y:Number = 50.3;
      
      private var m_tooltipWindow:FarmVillageFactoryBuildingToolTip = null;
      
      private var m_arrowObject:DisplayObject = null;
      
      private var m_harvestTimer:Timer = null;
      
      public function FarmVillageFactoryBuilding(itemName:String = null)
      {
         super(itemName);
         this.m_arrowObject = this.createHarvestArrow();
      }
      
      override protected function onImageLoaded(event:Event) : void
      {
         super.onImageLoaded(event);
         FeatureOptionsManager.getInstance().addEventListener(FeatureOptionsManager.EVENT_FEATURE_OPTIONS_LOADED,this.onFeatureOptionsComplete);
      }
      
      override protected function canShowSellMenuItem() : Boolean
      {
         return false;
      }
      
      private function onFeatureOptionsComplete(event:Event) : void
      {
         FeatureOptionsManager.getInstance().removeEventListener(FeatureOptionsManager.EVENT_FEATURE_OPTIONS_LOADED,this.onFeatureOptionsComplete);
         this.m_tooltipWindow = new FarmVillageFactoryBuildingToolTip(getPosition(),this);
      }
      
      override protected function createHarvestArrow() : DisplayObject
      {
         return new SimpleHarvestableResource.ORANGE_ARROW();
      }
      
      override public function onMouseOut() : void
      {
         if(!Global.worldManager.isVisiting())
         {
            if(this.m_tooltipWindow != null)
            {
               this.m_tooltipWindow.beginCloseTimer();
            }
         }
         super.onMouseOut();
      }
      
      override public function onMouseOver(event:MouseEvent) : void
      {
         if(this.m_tooltipWindow == null)
         {
            this.m_tooltipWindow = new FarmVillageFactoryBuildingToolTip(getPosition(),this);
         }
         UI.addHoverWindow(this.m_tooltipWindow);
         this.m_tooltipWindow.show();
         super.onMouseOver(event);
      }
      
      override public function onFinishPlace(transactionResult:Object = null) : void
      {
         super.onFinishPlace(transactionResult);
         TransactionManager.addTransaction(new TGenericTransaction(FarmVillageFactoriesManager.FACTORY_SERVICE,"onAddNewFactory",null,[m_itemName]));
         FarmVillageFactoriesManager.getInstance().addNewFactoryData(m_itemName);
      }
      
      public function addArrow() : void
      {
         var buildingDisplayObject:Sprite = null;
         if(m_displayObject)
         {
            buildingDisplayObject = m_displayObject as Sprite;
            if(!buildingDisplayObject.contains(this.m_arrowObject))
            {
               buildingDisplayObject.addChild(this.m_arrowObject);
               this.setFactoryArrowPosition();
            }
         }
      }
      
      private function setFactoryArrowPosition() : void
      {
         var point:Point = null;
         var spr:Sprite = null;
         if(Boolean(this.m_arrowObject) && Boolean(m_displayObject))
         {
            point = new Point();
            spr = m_displayObject as Sprite;
            this.m_arrowObject.scaleX = ARROW_SCALE / m_displayObject.scaleX;
            this.m_arrowObject.scaleY = ARROW_SCALE / m_displayObject.scaleY;
            if(spr.getChildAt(0))
            {
               point.y = -1 * Math.min(this.m_arrowObject.height,DEFAULT_ARROW_SIZE_Y);
               point.x = (spr.getChildAt(0).width - Math.min(this.m_arrowObject.width,DEFAULT_ARROW_SIZE_X) * spr.scaleX) / 2;
               if(point.x != this.m_arrowObject.x || point.y != this.m_arrowObject.y)
               {
                  this.m_arrowObject.y = point.y;
                  this.m_arrowObject.x = point.x;
               }
            }
         }
      }
      
      public function removeArrow() : void
      {
         var buildingDisplayObject:Sprite = null;
         if(m_displayObject)
         {
            buildingDisplayObject = m_displayObject as Sprite;
            if(buildingDisplayObject.contains(this.m_arrowObject))
            {
               buildingDisplayObject.removeChild(this.m_arrowObject);
            }
         }
      }
      
      public function setTimer(remainingTime:Number) : void
      {
         var timerValue:Number = NaN;
         this.removeArrow();
         if(!this.m_harvestTimer)
         {
            timerValue = remainingTime * FarmGameUtil.NUM_MSECS_IN_SECOND;
            this.m_harvestTimer = new Timer(timerValue,1);
            this.m_harvestTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onHarvestTimerComplete);
         }
         else
         {
            this.m_harvestTimer.reset();
         }
         this.m_harvestTimer.start();
      }
      
      public function onHarvestTimerComplete(event:TimerEvent = null) : void
      {
         this.addArrow();
         if(this.m_harvestTimer)
         {
            this.m_harvestTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onHarvestTimerComplete);
            this.m_harvestTimer = null;
         }
      }
   }
}

