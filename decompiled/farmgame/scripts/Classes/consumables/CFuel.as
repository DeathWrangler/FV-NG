package Classes.consumables
{
   import Classes.Constants.WorldsConstants;
   import Classes.Consumable;
   import Classes.util.ZLocUtils;
   
   public class CFuel extends Consumable
   {
      
      public function CFuel(itemName:String)
      {
         super(itemName);
      }
      
      override public function onUse() : void
      {
         var addedEnergy:Number = NaN;
         var refills:Number = getItem().count;
         if(refills > 0)
         {
            if(Global.world.getEquipment() != null || Global.worldManager.currentWorldType != WorldsConstants.WORLD_ID_HOME)
            {
               addedEnergy = refills * Global.player.energyMax;
               Global.player.energy += addedEnergy;
               Global.selectedAvatar.displayStatus(ZLocUtils.t("FarmGame","Status_AddEnergy",{"fuelNum":addedEnergy}));
            }
         }
      }
   }
}

