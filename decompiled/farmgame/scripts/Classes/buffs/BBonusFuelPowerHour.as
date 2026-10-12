package Classes.buffs
{
   import Managers.PowerHourManager;
   
   public class BBonusFuelPowerHour extends BPowerHour
   {
      
      private const FUEL_BUFF_AMOUNT:int = 20;
      
      public function BBonusFuelPowerHour(itemName:String)
      {
         super(itemName);
      }
      
      override public function apply(isNew:Boolean = false) : void
      {
         var startHour:int = 0;
         var addedEnergy:Number = NaN;
         if(!Global.player.buffs[m_itemName])
         {
            startHour = GlobalEngine.serverTime / 1000 - PowerHourManager.getInstance().timeOffset;
            Global.player.buffs[m_itemName] = {"time":startHour};
            addedEnergy = this.FUEL_BUFF_AMOUNT * Global.player.energyMax;
            Global.player.energy += addedEnergy;
         }
      }
   }
}

