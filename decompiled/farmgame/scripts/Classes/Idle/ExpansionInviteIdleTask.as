package Classes.Idle
{
   import Managers.FarmStatsManager;
   import Transactions.TExpansionInvite;
   import Transactions.TFarmTransaction;
   
   public class ExpansionInviteIdleTask extends GenericTransactionIdleTask
   {
      
      private var m_worldType:String;
      
      public function ExpansionInviteIdleTask(worldType:String)
      {
         this.m_worldType = worldType;
         var timeDelaySeconds:int = Global.farmGameSettingsManager.getInt("ExpansionInviteDelaySeconds",240);
         var expansionInviteTransaction:TFarmTransaction = new TExpansionInvite(this.m_worldType);
         super(expansionInviteTransaction,timeDelaySeconds);
      }
      
      override public function get canFire() : Boolean
      {
         var result:Boolean = false;
         if(Global.worldManager.currentWorldType == this.m_worldType)
         {
            result = super.canFire;
         }
         return result;
      }
      
      override public function fire() : void
      {
         super.fire();
         FarmStatsManager.count("expansioninvite","idletask","fire");
      }
   }
}

