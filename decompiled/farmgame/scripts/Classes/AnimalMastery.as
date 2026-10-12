package Classes
{
   import Classes.ZItem.FarmItem;
   import Classes.buffs.BMasteryPowerHour;
   import Classes.buffs.BMasteryTimed;
   import Managers.FarmGameSettingsManager;
   import Managers.PowerHourManager;
   
   public class AnimalMastery extends Mastery
   {
      
      public function AnimalMastery(xml:XML, farmItem:FarmItem = null)
      {
         var code:String = null;
         var isInDataSourceExperiment:Boolean = FarmGameSettingsManager.isInDataSourceExperiment();
         if(isInDataSourceExperiment)
         {
            code = farmItem.code;
         }
         else
         {
            code = xml.@code;
         }
         var overrideCode:String = HarvestableStorageBuilding.getItemCodeForMasteryOverrideExportName(code);
         if(code != overrideCode)
         {
            if(isInDataSourceExperiment)
            {
               farmItem = Global.farmGameSettingsManager.getFarmItemByCode(overrideCode);
            }
            else
            {
               xml = Global.farmGameSettingsManager.getItemXMLByCode(overrideCode);
            }
         }
         super(xml,farmItem);
      }
      
      override protected function getBushelMasteryMultiplier() : int
      {
         return 0;
      }
      
      override protected function getBuffMasteryMultiplier() : int
      {
         var powerHourMasteryBuffs:Array = null;
         var result:int = 0;
         if(PowerHourManager.inExperiment())
         {
            powerHourMasteryBuffs = Global.player.getBuffsByClass(BMasteryPowerHour);
            if(powerHourMasteryBuffs.length > 0)
            {
               result = Global.farmGameSettingsManager.getInt("genericMasteryBuffBonus",1);
            }
         }
         return result;
      }
      
      override protected function getTimedBuffMasteryMultipliers() : int
      {
         var result:int = 0;
         var timedMasteryBuffs:Array = new Array();
         timedMasteryBuffs = Global.player.getBuffItemsByClass(BMasteryTimed,BMasteryTimed.ANIMAL_TYPE);
         if(timedMasteryBuffs.length > 0)
         {
            result++;
         }
         return result;
      }
   }
}

