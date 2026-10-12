package Classes.Quest.helperactions
{
   import Classes.Combine;
   import Classes.Constants.ClickTrackingConstants;
   import Classes.RotatableCombine;
   import Classes.RotatableSeeder;
   import Classes.Seeder;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.FarmStatsManager;
   
   public class PlantSeedHelperAction extends QuestHelperAction
   {
      
      private var m_seedItemCodes:Array;
      
      private var m_zClassTracking:String;
      
      public function PlantSeedHelperAction(questName:String, seedItemCodes:Array, zClassTracking:String = null)
      {
         super(questName);
         m_shouldCloseOnPerform = true;
         this.m_seedItemCodes = seedItemCodes;
         this.m_zClassTracking = zClassTracking;
      }
      
      override public function perform() : void
      {
         var farmItemName:String = null;
         var code:String = null;
         super.perform();
         var itemNames:Array = [];
         if(this.m_seedItemCodes)
         {
            for each(code in this.m_seedItemCodes)
            {
               farmItemName = Global.farmGameSettingsManager.getFarmItemNameByCode(code);
               if(farmItemName)
               {
                  itemNames.push(farmItemName);
               }
            }
            if(itemNames.length > 0)
            {
               if(Boolean(Global.world.getEquipment(Combine,null) as Combine) || Boolean(Global.world.getEquipment(RotatableCombine,null) as RotatableCombine))
               {
                  UI.marketLaunchReference = UI.MARKET_LAUNCH_REFERENCE_COMBINE;
               }
               else if(Boolean(Global.world.getEquipment(Seeder,null) as Seeder) || Boolean(Global.world.getEquipment(RotatableSeeder,null) as RotatableSeeder))
               {
                  UI.marketLaunchReference = UI.MARKET_LAUNCH_REFERENCE_SEEDER;
               }
               else
               {
                  UI.marketLaunchReference = null;
               }
               UI.displayMiniMarketDialog(itemNames);
               FarmStatsManager.count(ClickTrackingConstants.CLICK_STATS_COUNTER,"quest_helper",UI.marketLaunchReference,this.m_zClassTracking);
            }
            else
            {
               FarmStatsManager.count(ClickTrackingConstants.CLICK_STATS_COUNTER,"quest_helper_failure",UI.marketLaunchReference,this.m_zClassTracking);
            }
         }
      }
      
      override public function get readableText() : String
      {
         return ZLocUtils.t("Quests","Helper_PlantCrop_Button");
      }
   }
}

