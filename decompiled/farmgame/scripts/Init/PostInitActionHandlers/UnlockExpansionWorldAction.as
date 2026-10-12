package Init.PostInitActionHandlers
{
   import Classes.ZItem.ExpansionAccess;
   import Classes.ZItem.ExpansionData;
   import Engine.Managers.TransactionManager;
   import Transactions.TExpansionWorldAccess;
   
   public class UnlockExpansionWorldAction extends AbstractPostInitAction
   {
      
      private var m_worldId:String;
      
      private var m_accessType:String;
      
      public function UnlockExpansionWorldAction(worldId:String, accessType:String)
      {
         super();
         this.m_worldId = worldId;
         this.m_accessType = accessType;
      }
      
      override public function execute() : void
      {
         var access:ExpansionAccess = null;
         var data:ExpansionData = Global.farmGameSettingsManager.getExpansionData(this.m_worldId);
         var currentMotd:Object = Global.player.currentMOTD;
         if(data)
         {
            access = data.getAccessOfType(this.m_accessType);
            if(Boolean(access) && Boolean(access.checkPrereqs()) && (currentMotd == null || !currentMotd.hasOwnProperty("handlerType") || currentMotd.handlerType != "ExpansionAccessMotdHandler"))
            {
               TransactionManager.addTransaction(new TExpansionWorldAccess(this.m_worldId,access.type,false),true);
            }
         }
         m_isFinished = true;
      }
   }
}

