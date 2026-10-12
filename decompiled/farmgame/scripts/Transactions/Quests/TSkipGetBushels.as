package Transactions.Quests
{
   import Classes.Constants.Experiments;
   import Classes.ZItem.FarmItem;
   import Managers.Crafting.CraftingManager;
   import Managers.FarmStatsManager;
   
   public class TSkipGetBushels extends TSkipQuestTask
   {
      
      private var m_bushelCode:String = null;
      
      public function TSkipGetBushels(questName:String, taskIndex:int, bushelName:String)
      {
         super(questName,taskIndex);
         var bushelItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(bushelName);
         this.m_bushelCode = bushelItem.code;
      }
      
      override public function perform() : void
      {
         signedCall("FarmQuestService.skipGetBushelsTask",m_questName,m_taskIndex);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var beginOOS_itemsStr:String = null;
         super.onComplete(result);
         if(result != null)
         {
            if(result.hasOwnProperty("bushelsAdded"))
            {
               CraftingManager.getInstance().addItemToInventory(this.m_bushelCode,result.bushelsAdded);
               if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CRAFTING_OOS_STATS) > 0)
               {
                  beginOOS_itemsStr = "item_" + this.m_bushelCode + ":" + result.bushelsAdded;
                  FarmStatsManager.count("beginOOS","client","add_TSkipGetBushels",beginOOS_itemsStr);
               }
            }
         }
      }
   }
}

