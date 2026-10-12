package Display.QueuedIcons
{
   import Display.DynamicIconQueue;
   import Widgets.Core.Frames.ZwFrame;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class TaskListQueuedIcon extends DynamicContentQueuedIcon
   {
      
      public static const TASK_LIST_ICON_NAME:String = "GildasList";
      
      public static const TASK_LIST_ICON_TYPE:String = "GildasListIcon";
      
      public static var queuedShowAnimation:Boolean = false;
      
      private static var hudIcon:TaskListQueuedIcon = null;
      
      private var m_assetLoaded:Boolean;
      
      public var m_completeAnimation:ZwFrame = null;
      
      public function TaskListQueuedIcon(xml:XML)
      {
         super(xml);
         this.m_assetLoaded = false;
      }
      
      public static function showHUDIcon() : void
      {
         if(hudIcon == null)
         {
            hudIcon = Global.hud.iconQueue.addIcon(TASK_LIST_ICON_NAME,DynamicIconQueue.ADD_BY_PRIORITY,null,null,false) as TaskListQueuedIcon;
         }
      }
      
      public static function removeHUDIcon() : void
      {
         if(hudIcon)
         {
            Global.hud.iconQueue.removeIconByName(TASK_LIST_ICON_NAME);
            hudIcon = null;
         }
      }
      
      public static function showCompletionAnimation() : void
      {
         var doneClip:MovieClip = null;
         if(Boolean(hudIcon) && Boolean(hudIcon.m_completeAnimation))
         {
            doneClip = hudIcon.m_completeAnimation.element as MovieClip;
            doneClip.stop();
            hudIcon.m_completeAnimation.visible = true;
            doneClip.gotoAndPlay(2);
         }
         else
         {
            queuedShowAnimation = true;
         }
      }
      
      public static function hideCompletionAnimation() : void
      {
         if(Boolean(hudIcon) && Boolean(hudIcon.m_completeAnimation))
         {
            hudIcon.m_completeAnimation.visible = false;
         }
         else
         {
            queuedShowAnimation = false;
         }
      }
      
      override protected function onButtonIconLoaded(event:Event) : void
      {
         this.m_assetLoaded = true;
         super.onButtonIconLoaded(event);
      }
      
      override protected function injectContent() : void
      {
         var loadedMC:MovieClip = null;
         if(this.m_assetLoaded)
         {
            loadedMC = m_Loader.content as MovieClip;
            loadedMC.x -= 7;
            loadedMC.scaleX = 0.8;
            loadedMC.scaleY = 0.8;
            this.m_completeAnimation = new ZwFrame(loadedMC.done_mc);
            m_widgetManager.addWidget(this.m_completeAnimation);
            if(TaskListQueuedIcon.queuedShowAnimation)
            {
               TaskListQueuedIcon.showCompletionAnimation();
               TaskListQueuedIcon.queuedShowAnimation = false;
            }
         }
      }
   }
}

