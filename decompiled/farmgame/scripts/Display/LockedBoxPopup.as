package Display
{
   import Classes.ZItem.FarmItem;
   
   public class LockedBoxPopup extends MysteryPopup
   {
      
      public function LockedBoxPopup(closeCallback:Function = null, item:FarmItem = null, lootableItemName:String = "lockedbox")
      {
         super(MysteryPopup.TYPE_CONFIRM,closeCallback,item,lootableItemName);
      }
   }
}

