package Classes.consumables
{
   import Classes.Buff;
   import Classes.Consumable;
   import Classes.ZItem.FarmItem;
   import Classes.buffs.*;
   import Managers.FarmGameSettingsManager;
   import flash.utils.getDefinitionByName;
   
   public class CBuff extends Consumable
   {
      
      protected var m_buffTypes:Array = [BWalkSpeed,BWalkSpeedPrereq,BAvatarSize,BAvatarSizePrereq,BBushel,BCropExp,BMastery,BMasteryTimed,BLicense,BMasteryGeneric,BPermanentTypeMastery,BMasteryPowerHour,BBushelPowerHour,BCoinPowerHour,BXpPowerHour,BInstantGrowPowerHour,BWalkSpeedPowerHour,BBonusFuelPowerHour,BMysteryBabyPowerHour,BNeighborVisitPowerHour,BHarvestHelper];
      
      public function CBuff(itemName:String)
      {
         super(itemName);
      }
      
      override public function onUse() : void
      {
         var buffItemName:String = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            buffItemName = getItem().getStringFromDataSource("buff");
         }
         else
         {
            buffItemName = getItem().xml.buff;
         }
         var buffItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(buffItemName);
         var buffClass:String = buffItem.className;
         var tempClass:Class = getDefinitionByName("Classes.buffs." + buffClass) as Class;
         var buff:Buff = new tempClass(buffItemName);
         if(buff)
         {
            buff.apply(true);
         }
      }
   }
}

