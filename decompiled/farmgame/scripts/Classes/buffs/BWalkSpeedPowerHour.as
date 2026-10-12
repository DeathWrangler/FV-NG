package Classes.buffs
{
   import Managers.FarmGameSettingsManager;
   
   public class BWalkSpeedPowerHour extends BPowerHour
   {
      
      private static var s_currSpeed:int = 0;
      
      private const TRIPLE_SPEED_FACTOR:Number = 0.75;
      
      public function BWalkSpeedPowerHour(itemName:String)
      {
         super(itemName);
      }
      
      override public function apply(isNew:Boolean = false) : void
      {
         var walkspeed:Number = NaN;
         var walkSpeedBuffs:Array = null;
         if(Global.player.avatar != null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               walkspeed = getItem().getNumberFromDataSource("walkspeed");
            }
            else
            {
               walkspeed = Number(getItem().xml.walkspeed);
            }
            s_currSpeed = Global.player.avatar.walkSpeed;
            walkSpeedBuffs = Global.player.getBuffsByClass(BWalkSpeedPrereq);
            if(walkSpeedBuffs.length > 0)
            {
               walkspeed *= this.TRIPLE_SPEED_FACTOR;
            }
            Global.player.avatar.walkSpeed = walkspeed;
         }
         super.apply(isNew);
      }
      
      override public function unapply() : void
      {
         if(Global.player.avatar != null)
         {
            if(s_currSpeed != 0)
            {
               Global.player.avatar.walkSpeed = s_currSpeed;
            }
         }
         super.unapply();
      }
   }
}

