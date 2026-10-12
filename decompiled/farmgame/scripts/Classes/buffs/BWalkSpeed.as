package Classes.buffs
{
   import Classes.Buff;
   import Managers.FarmGameSettingsManager;
   
   public class BWalkSpeed extends Buff
   {
      
      public function BWalkSpeed(itemName:String)
      {
         super(itemName);
      }
      
      override public function apply(isNew:Boolean = false) : void
      {
         var walkspeed:Number = NaN;
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
            Global.player.avatar.walkSpeed = walkspeed;
         }
         super.apply(isNew);
      }
      
      override public function unapply() : void
      {
         if(Global.player.avatar != null)
         {
            Global.player.avatar.walkSpeed = Global.farmGameSettingsManager.getNumber("walkSpeed");
         }
         super.unapply();
      }
   }
}

