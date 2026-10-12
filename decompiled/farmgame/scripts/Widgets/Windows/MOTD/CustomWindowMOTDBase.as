package Widgets.Windows.MOTD
{
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Transactions.TSawSpecificMOTD;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class CustomWindowMOTDBase extends FarmWindow
   {
      
      protected var m_currentMOTD:Object;
      
      protected var m_acceptCallback:Function;
      
      protected var m_cancelCallback:Function;
      
      public function CustomWindowMOTDBase(windowAssetRelUrl:String, modal:Boolean = true, bAddClickBlocker:Boolean = false)
      {
         super(windowAssetRelUrl,modal,bAddClickBlocker);
      }
      
      override protected function onClose(event:Event) : void
      {
         if(Boolean(this.m_currentMOTD) && Boolean(this.m_currentMOTD.motdSeenFlag) && !Global.player.isMotdSeenFlagSet(this.m_currentMOTD.motdSeenFlag))
         {
            FarmStatsManager.count("MOTD","close",this.m_currentMOTD.motdSeenFlag);
            TransactionManager.addTransaction(new TSawSpecificMOTD(this.m_currentMOTD));
         }
         super.onClose(event);
      }
      
      public function get currentMOTD() : Object
      {
         return this.m_currentMOTD;
      }
      
      public function set currentMOTD(motd:Object) : void
      {
         this.m_currentMOTD = motd;
      }
      
      public function set acceptCallback(callback:Function) : void
      {
         this.m_acceptCallback = callback;
      }
      
      public function set cancelCallback(callback:Function) : void
      {
         this.m_cancelCallback = callback;
      }
   }
}

