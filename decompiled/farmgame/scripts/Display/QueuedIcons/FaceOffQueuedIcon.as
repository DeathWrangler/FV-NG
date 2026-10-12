package Display.QueuedIcons
{
   import Classes.Constants.ArrowType;
   import Classes.util.ZLocUtils;
   import Display.DynamicIconQueue;
   import Managers.FaceOffManager;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class FaceOffQueuedIcon extends QueuedIconWithArrow
   {
      
      public static const DEFAULT_ICON_NAME:String = "FaceOffGenericIcon";
      
      private static const ARROW_OFFSET_RIGHT_X:int = -225;
      
      private static const ARROW_OFFSET_RIGHT_Y:int = -20;
      
      private static const ARROW_OFFSET_LEFT_X:int = 25;
      
      private static const ARROW_OFFSET_LEFT_Y:int = -20;
      
      private var m_faceOffManager:FaceOffManager;
      
      public function FaceOffQueuedIcon(xml:XML)
      {
         super(xml);
      }
      
      override public function init() : void
      {
         this.m_faceOffManager = FaceOffManager.getInstance();
         iconName = this.m_faceOffManager.getName();
         category = "feature";
         super.init();
      }
      
      private function getArrowMovieClip(embeddedArrowClass:Class) : void
      {
         var asset:MovieClip = new embeddedArrowClass() as MovieClip;
         var loader:Loader = asset.getChildAt(0) as Loader;
         var info:LoaderInfo = loader.contentLoaderInfo;
         info.addEventListener(Event.COMPLETE,this.onArrowLoaded);
      }
      
      private function onArrowLoaded(event:Event) : void
      {
         var info:LoaderInfo = event.target as LoaderInfo;
         info.removeEventListener(Event.COMPLETE,this.onArrowLoaded);
         m_indicatorArrow = info.loader.content as MovieClip;
         this.setUpArrow(m_indicatorArrow);
         this.attachArrow(m_currentArrowType);
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
      
      public function onAdd() : void
      {
         this.conditionallyAttachArrow();
      }
      
      override public function attachArrow(arrowType:ArrowType, shouldPersistUntilClick:Boolean = false) : void
      {
         switch(arrowType)
         {
            case ArrowType.ARROWNEW:
               setArrowText(ZLocUtils.t("Dialogs","FaceOffGeneric_VoteNow"));
               break;
            case ArrowType.ARROWUPDATE:
               setArrowText(ZLocUtils.t("Dialogs","FaceOffGeneric_Results"));
         }
         super.attachArrow(arrowType,shouldPersistUntilClick);
      }
      
      public function attachResultsArrow() : void
      {
         setArrowText(ZLocUtils.t("Dialogs","FaceOffGeneric_Results"));
         super.attachArrow(ArrowType.ARROWUPDATE);
      }
      
      private function conditionallyAttachResultArrow() : void
      {
         this.attachArrow(ArrowType.ARROWNEW);
      }
      
      public function conditionallyAttachArrow() : void
      {
         if(this.m_faceOffManager.canVote())
         {
            this.attachArrow(ArrowType.ARROWNEW);
         }
      }
   }
}

