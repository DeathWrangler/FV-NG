package Classes.buffs
{
   import Classes.Buff;
   import Managers.FarmGameSettingsManager;
   import Managers.PowerHourManager;
   
   public class BPowerHour extends Buff
   {
      
      public function BPowerHour(itemName:String)
      {
         super(itemName);
      }
      
      override public function apply(isNew:Boolean = false) : void
      {
         var startHour:int = 0;
         if(!Global.player.buffs[m_itemName])
         {
            startHour = GlobalEngine.serverTime / 1000 - PowerHourManager.getInstance().timeOffset;
            Global.player.buffs[m_itemName] = {"time":startHour};
         }
      }
      
      protected function getBuffType() : String
      {
         var buffType:String = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            buffType = getItem().getStringFromDataSource("buffType");
         }
         else
         {
            buffType = getItem().xml.buffType;
         }
         return buffType;
      }
      
      override public function tick() : void
      {
         PowerHourManager.getInstance().update(this.secondsRemaining);
      }
      
      override public function unapply() : void
      {
         super.unapply();
         PowerHourManager.getInstance().terminate();
      }
   }
}

