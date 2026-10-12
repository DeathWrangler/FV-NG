package Classes
{
   import Display.GenericPopup;
   import Display.MOTD;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.WorldStatManager;
   import Transactions.TGetMOTD;
   import flash.events.Event;
   
   public class MOTDMapTrigger extends StationaryMapTrigger
   {
      
      private var m_motdSeenFlag:String = null;
      
      private var m_motdData:Object = null;
      
      private var m_visibleWhileVisiting:Boolean;
      
      public function MOTDMapTrigger(itemName:String, stateToSet:String = "static")
      {
         super(itemName,stateToSet);
         this.m_visibleWhileVisiting = true;
      }
      
      override public function cleanUp() : void
      {
         this.m_motdSeenFlag = null;
         this.m_motdData = null;
         super.cleanUp();
      }
      
      override public function loadXmlData(xmlData:XML) : void
      {
         if(xmlData.hasOwnProperty("motdSeenFlag"))
         {
            this.m_motdSeenFlag = xmlData.motdSeenFlag;
            this.detach();
            TransactionManager.addTransaction(new TGetMOTD(this.m_motdSeenFlag,this.onGetMOTD),true);
         }
         this.m_visibleWhileVisiting = true;
         if(xmlData.hasOwnProperty("showVisiting"))
         {
            this.m_visibleWhileVisiting = xmlData.showVisiting.toString() == "true";
         }
      }
      
      public function onGetMOTD(amfResult:Object) : void
      {
         if(Boolean(amfResult) && amfResult.hasOwnProperty("motdSeenFlag"))
         {
            this.m_motdData = amfResult;
            if(this.m_visibleWhileVisiting || !Global.worldManager.isVisiting())
            {
               FarmStatsManager.count("mapTrigger","view",this.m_motdData["motdSeenFlag"]);
               attach();
            }
         }
      }
      
      override public function onClick() : void
      {
         if(this.m_motdData)
         {
            FarmStatsManager.count("mapTrigger","click",this.m_motdData["motdSeenFlag"]);
            MOTD.displayMOTD(this.m_motdData,false,null,this.motdAcceptCallback);
            if(this.m_motdData["worldType"])
            {
               WorldStatManager.trackMOTDMapTriggerClick(this.m_motdData["worldType"]);
            }
         }
         else
         {
            detach();
            this.cleanUp();
         }
      }
      
      private function motdAcceptCallback(event:Event = null) : void
      {
         var returnedEvent:GenericPopupEvent = event as GenericPopupEvent;
         if(!returnedEvent || returnedEvent.button != GenericPopup.CANCEL)
         {
            detach();
            this.cleanUp();
         }
      }
   }
}

