package Classes
{
   import Managers.PerformanceExperimentManager;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class BackgroundAnimationDecoMapTrigger extends MapTrigger
   {
      
      protected static var m_arrowBitmaps:Object = new Object();
      
      private static const BASIC_ARROW_BITMAP_KEY:String = "BASIC_ARROW_BITMAP_KEY";
      
      protected static var ARROW_SCALE:Number = 0.5;
      
      public static const GUITAR_PICK:Class = EmbeddedArt.guitarPick;
      
      protected var m_arrowArt:Class;
      
      protected var m_arrow:DisplayObject;
      
      private var isArrowAttached:Boolean;
      
      private var m_loadComplete:Boolean;
      
      public function BackgroundAnimationDecoMapTrigger(itemName:String, stateToSet:String = "static")
      {
         super(itemName,stateToSet);
      }
      
      override public function onMouseOver(event:MouseEvent) : void
      {
         m_toolTipOverride = "";
         if(Global.selectedAvatar)
         {
            setHighlighted(false);
         }
      }
      
      override public function onClick() : void
      {
      }
      
      override public function getCurrentImageName() : String
      {
         return state;
      }
      
      override public function onUpdate(delta:Number) : void
      {
         super.onUpdate(delta);
         if(Global.flashHotParams["IS_GB_ANIMATION_ENABLED"])
         {
            if(isVisible())
            {
               if(m_animationState != PLAY_STATE && hasAnimation && m_allowPlay && !PerformanceExperimentManager.isInExtremePerformanceLimiterExperiment)
               {
                  this.forcePlay();
               }
            }
         }
      }
      
      public function forcePlay() : Boolean
      {
         var mc:MovieClip = null;
         var result:Boolean = false;
         m_animationState = PLAY_STATE;
         (m_displayObject as Sprite).cacheAsBitmap = false;
         var shouldPlay:Boolean = isAnimating;
         var mcContent:MovieClip = m_content as MovieClip;
         if(!mcContent)
         {
            if(Boolean(m_content is Bitmap) && Boolean(m_itemImage) && m_itemImage.image is MovieClip)
            {
               mcContent = m_itemImage.image as MovieClip;
               replaceContent(mcContent,true);
            }
            else if(m_image is MovieClip)
            {
               mcContent = m_image as MovieClip;
            }
         }
         if(mcContent)
         {
            mc = mcContent as MovieClip;
         }
         else
         {
            mc = m_image as MovieClip;
         }
         if(mc)
         {
            if(shouldPlay)
            {
               mc.play();
            }
            else
            {
               mc.stop();
            }
         }
         return true;
      }
      
      public function loadCompleteEvent(e:Event = null) : void
      {
         this.m_loadComplete = true;
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

