package Display.QueuedIcons
{
   import Classes.Constants.ArrowType;
   import Classes.util.ZLocUtils;
   import Display.Quests.QuestProgressBar;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class SpecialQuestIcon extends QueuedIconWithArrow
   {
      
      public static const SPECIAL_QUEST_ICON:String = "SpecialQuestIcon";
      
      private var m_progressBar:QuestProgressBar = null;
      
      public function SpecialQuestIcon(xml:XML)
      {
         super(xml);
      }
      
      public function onAdd() : void
      {
         this.attachProgressBar();
      }
      
      public function onComplete() : void
      {
         this.playProgressBarAnimation(0);
      }
      
      public function playProgressBarAnimation(progressRatio:Number) : void
      {
         if(this.m_progressBar)
         {
            this.m_progressBar.playAnimation(progressRatio);
         }
      }
      
      private function attachProgressBar() : void
      {
         this.m_progressBar = new QuestProgressBar(-20,25,0.25,0.25);
         this.m_progressBar.addEventListener(QuestProgressBar.ANIMATION_COMPLETE_EVENT,this.animationComplete);
         this.addEventListener(MouseEvent.MOUSE_OVER,this.showProgressBar);
         this.addEventListener(MouseEvent.MOUSE_OUT,this.hideProgressBar);
         addChild(this.m_progressBar);
         this.playProgressBarAnimation(0);
      }
      
      private function animationComplete(event:Event) : void
      {
         this.hideProgressBar();
      }
      
      private function showProgressBar(event:Event = null) : void
      {
         if(this.m_progressBar)
         {
            this.m_progressBar.showProgressBar();
         }
      }
      
      private function hideProgressBar(event:Event = null) : void
      {
         if(this.m_progressBar)
         {
            this.m_progressBar.hideProgressBarWithDelay();
         }
      }
      
      override public function attachArrow(arrowType:ArrowType, shouldPersistUntilClick:Boolean = false) : void
      {
         switch(arrowType)
         {
            case ArrowType.ARROWNEW:
               setArrowText(ZLocUtils.t("Dialogs","NewGoals"));
               break;
            case ArrowType.ARROWUPDATE:
               setArrowText(ZLocUtils.t("Dialogs","Progress"));
         }
         super.attachArrow(arrowType,shouldPersistUntilClick);
      }
   }
}

