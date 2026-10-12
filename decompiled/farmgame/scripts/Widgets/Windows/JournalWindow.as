package Widgets.Windows
{
   import Managers.JournalManager;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Frames.JournalWindowFrameContainer;
   
   public class JournalWindow extends FarmWindow
   {
      
      private var m_journalPagableFrame:ZwWidget = null;
      
      private var m_manager:JournalManager = null;
      
      public function JournalWindow(asset:String)
      {
         super(asset,true,true);
         this.m_manager = JournalManager.getInstance();
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         this.m_journalPagableFrame = addWidget(new JournalWindowFrameContainer(m_window)) as JournalWindowFrameContainer;
      }
   }
}

