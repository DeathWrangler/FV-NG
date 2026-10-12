package Classes.buffs
{
   import Classes.Buff;
   import Managers.FarmGameSettingsManager;
   
   public class BAvatarSize extends Buff
   {
      
      public function BAvatarSize(itemName:String)
      {
         super(itemName);
      }
      
      override public function apply(isNew:Boolean = false) : void
      {
         var size:Number = NaN;
         if(Global.player.avatar != null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               size = getItem().getNumberFromDataSource("buffSize");
            }
            else
            {
               size = Number(getItem().xml.buffSize);
            }
            Global.player.avatar.setScale(size);
         }
         super.apply(isNew);
      }
      
      override public function unapply() : void
      {
         var size:Number = NaN;
         if(Global.player.avatar != null)
         {
            size = Global.farmGameSettingsManager.getNumber("avatarScale");
            Global.player.avatar.setScale(size);
         }
         super.unapply();
      }
   }
}

