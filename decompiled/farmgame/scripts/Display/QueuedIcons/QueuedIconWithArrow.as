package Display.QueuedIcons
{
   import Classes.Constants.ArrowType;
   import Classes.util.MovieClipUtils;
   import Classes.util.ZLocUtils;
   import Display.DynamicIconQueue;
   import Managers.DefconManager;
   import Managers.PerformanceExperimentManager;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class QueuedIconWithArrow extends DynamicContentQueuedIcon
   {
      
      private static const ARROW_OFFSET_RIGHT_X:int = -225;
      
      private static const ARROW_OFFSET_RIGHT_Y:int = -20;
      
      private static const ARROW_OFFSET_LEFT_X:int = 25;
      
      private static const ARROW_OFFSET_LEFT_Y:int = -20;
      
      protected var m_currentArrowType:ArrowType = null;
      
      protected var m_indicatorArrow:MovieClip = null;
      
      protected var m_arrowText:String = "";
      
      public function QueuedIconWithArrow(xml:XML)
      {
         super(xml);
      }
      
      private function onArrowLoaded(event:Event) : void
      {
         var info:LoaderInfo = event.target as LoaderInfo;
         info.removeEventListener(Event.COMPLETE,this.onArrowLoaded);
         this.m_indicatorArrow = info.loader.content as MovieClip;
         this.setUpArrow(this.m_indicatorArrow);
         this.attachArrow(this.m_currentArrowType);
      }
      
      private function setUpArrow(arrow:MovieClip) : void
      {
         arrow.visible = true;
         if(m_side == DynamicIconQueue.RIGHT_SIDE)
         {
            arrow.x = ARROW_OFFSET_RIGHT_X;
            arrow.y = ARROW_OFFSET_RIGHT_Y;
         }
         else
         {
            arrow.x = ARROW_OFFSET_LEFT_X;
            arrow.y = ARROW_OFFSET_LEFT_Y;
         }
         addChild(arrow);
      }
      
      override public function finishClick(parent:DynamicIconQueue) : void
      {
         super.finishClick(parent);
         this.hideArrow();
      }
      
      protected function canShowArrow() : Boolean
      {
         var canShowArrow:Boolean = true;
         var minDefconLevel:Number = Global.flashHotParams["DEFCON_ANIMATION"] != null ? Number(Global.flashHotParams["DEFCON_ANIMATION"]) : 2;
         if(PerformanceExperimentManager.isInExtremePerformanceLimiterExperiment || DefconManager.defconLevel >= minDefconLevel)
         {
            if(this.m_indicatorArrow)
            {
               MovieClipUtils.recursiveStop(this.m_indicatorArrow);
               this.m_indicatorArrow = null;
            }
            canShowArrow = false;
         }
         return canShowArrow;
      }
      
      public function attachArrow(arrowType:ArrowType, forceArrowExpanded:Boolean = false) : void
      {
         if(this.canShowArrow())
         {
            if(this.m_currentArrowType != arrowType)
            {
               if(this.m_indicatorArrow)
               {
                  this.hideArrow();
                  this.m_indicatorArrow.progressArrow_mc.arrow_mc.removeEventListener(Event.ENTER_FRAME,this.onArrowEnterFrame);
                  removeChild(this.m_indicatorArrow);
                  this.m_indicatorArrow = null;
               }
               this.m_currentArrowType = arrowType;
               this.getArrowMovieClip(ZLocUtils.tiEmbeddedArt(arrowType.getEmbeddedArtName(m_side)));
            }
            else if(this.m_indicatorArrow != null)
            {
               this.m_indicatorArrow.visible = true;
               this.m_indicatorArrow.progressArrow_mc.arrow_mc.gotoAndPlay(1);
               this.m_indicatorArrow.progressArrow_mc.arrow_mc.infoGroup_mc.generic_tf.text = this.m_arrowText;
               if(forceArrowExpanded)
               {
                  this.m_indicatorArrow.progressArrow_mc.arrow_mc.addEventListener(Event.ENTER_FRAME,this.onArrowEnterFrame);
               }
            }
         }
      }
      
      private function getArrowMovieClip(embeddedArrowClass:Class) : void
      {
         var asset:MovieClip = new embeddedArrowClass() as MovieClip;
         var loader:Loader = asset.getChildAt(0) as Loader;
         var info:LoaderInfo = loader.contentLoaderInfo;
         info.addEventListener(Event.COMPLETE,this.onArrowLoaded);
      }
      
      public function hideArrow() : void
      {
         if(this.m_indicatorArrow != null)
         {
            this.m_indicatorArrow.visible = false;
         }
      }
      
      private function onArrowEnterFrame(event:Event) : void
      {
         var movie:MovieClip = event.target as MovieClip;
         if(movie != null)
         {
            if(movie.currentFrame == movie.totalFrames)
            {
               movie.gotoAndPlay(1);
            }
         }
      }
      
      public function setArrowText(text:String) : void
      {
         this.m_arrowText = text;
      }
   }
}

