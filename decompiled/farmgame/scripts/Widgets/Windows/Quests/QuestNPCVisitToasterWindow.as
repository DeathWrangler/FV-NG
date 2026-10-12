package Widgets.Windows.Quests
{
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.AutoCloseToasterWindow;
   
   public class QuestNPCVisitToasterWindow extends AutoCloseToasterWindow
   {
      
      protected static const DEFAULT_TIME_TO_LIVE:Number = 10000;
      
      private var m_message:String = null;
      
      public function QuestNPCVisitToasterWindow(assetPath:String, message:String)
      {
         super(assetPath);
         this.m_message = message;
         this.duration = DEFAULT_TIME_TO_LIVE;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new ZwTextField(m_window.message_tf,this.m_message,true));
      }
   }
}

