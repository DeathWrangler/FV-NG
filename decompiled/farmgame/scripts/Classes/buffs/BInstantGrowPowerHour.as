package Classes.buffs
{
   import Managers.InstagrowHelper;
   import Managers.MapResourceHelper;
   import Managers.PowerHourManager;
   
   public class BInstantGrowPowerHour extends BPowerHour
   {
      
      private var m_instagrowHelper:InstagrowHelper;
      
      public function BInstantGrowPowerHour(itemName:String)
      {
         super(itemName);
      }
      
      override public function apply(isNew:Boolean = false) : void
      {
         var startHour:int = 0;
         var type:String = null;
         if(!Global.player.buffs[m_itemName])
         {
            startHour = GlobalEngine.serverTime / 1000 - PowerHourManager.getInstance().timeOffset;
            Global.player.buffs[m_itemName] = {"time":startHour};
            type = this.getBuffType();
            this.m_instagrowHelper = new InstagrowHelper(MapResourceHelper.getTypeFromName(type));
            this.m_instagrowHelper.execute();
         }
      }
   }
}

