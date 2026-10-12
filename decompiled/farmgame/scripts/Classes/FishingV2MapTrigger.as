package Classes
{
   import Managers.AFInnovationManager;
   import Managers.FishingV2Manager;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class FishingV2MapTrigger extends MapTrigger
   {
      
      protected static var m_arrowBitmaps:Object = {};
      
      private static const BASIC_ARROW_BITMAP_KEY:String = "BASIC_ARROW_BITMAP_KEY";
      
      protected static var ARROW_SCALE:Number = 0.5;
      
      public static const GUITAR_PICK:Class = EmbeddedArt.guitarPick;
      
      protected var m_arrowArt:Class;
      
      protected var m_arrow:DisplayObject;
      
      private var isArrowAttached:Boolean;
      
      private var m_loadComplete:Boolean;
      
      public function FishingV2MapTrigger(itemName:String, stateToSet:String = "static")
      {
         super(itemName,stateToSet);
      }
      
      override public function onMouseOver(event:MouseEvent) : void
      {
         m_toolTipOverride = "Fishing Frenzy!";
         super.onMouseOver(event);
      }
      
      override public function onClick() : void
      {
         var featureData:Object = FishingV2Manager.getInstance().getFeatureData();
         if(Boolean(featureData) && Boolean(featureData.hasOwnProperty("MasteryReward")) && featureData["MasteryReward"] == 1)
         {
            FishingV2Manager.getInstance().showFishCollectionsWindow();
         }
         else
         {
            FishingV2Manager.getInstance().showMainUI();
         }
      }
      
      override public function getCurrentImageName() : String
      {
         return state;
      }
      
      override public function onUpdate(delta:Number) : void
      {
         super.onUpdate(delta);
      }
      
      public function loadCompleteEvent(e:Event = null) : void
      {
         this.m_loadComplete = true;
      }
      
      public function attachArrowConditionally(e:Event = null) : void
      {
         if(m_displayObject)
         {
            if(AFInnovationManager.getInstance().canCollectForTheDay())
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
               this.m_arrow.y = -100;
               this.m_arrow.x = 70;
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

