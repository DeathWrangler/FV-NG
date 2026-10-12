package Transactions
{
   import Classes.StorageBuilding;
   
   public class TGrantRetroactiveUpgradeAward extends TWorldState
   {
      
      public static const BUILDABLE_UPGRADE_AWARD_PREREQ_PREFIX:String = "fv_upgradeaward_prereq_";
      
      public static const BUILDABLE_UPGRADE_AWARD_ACTION_COUNT_PREFIX:String = "upgradeaward_";
      
      public function TGrantRetroactiveUpgradeAward(building:StorageBuilding)
      {
         var buildingName:String = building.getItemName();
         Global.player.setActionCount(BUILDABLE_UPGRADE_AWARD_ACTION_COUNT_PREFIX + buildingName,1);
         super(building);
      }
      
      override public function perform() : void
      {
         signedWorldAction("GrantRetroactiveUpgrade");
      }
      
      override protected function onComplete(result:Object) : void
      {
         var building:StorageBuilding = m_object as StorageBuilding;
         building.grantUpgradeAwards(result);
      }
   }
}

