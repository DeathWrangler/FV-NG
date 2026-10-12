package Classes.consumables
{
   import Classes.ZItem.FarmItem;
   import Classes.buffs.BMasteryTimed;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   
   public class CMasteryTimed extends CBuff
   {
      
      public function CMasteryTimed(itemName:String)
      {
         super(itemName);
      }
      
      override public function canUse() : Boolean
      {
         var item:FarmItem = null;
         var buffName:String = null;
         var result:Boolean = super.canUse();
         if(result != false)
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(m_itemName);
            if(item.buff != null && item.buff != "")
            {
               buffName = item.buff;
            }
            else
            {
               buffName = BMasteryTimed.getPermanemtBuffNameFromType(item.subType);
            }
            if(Global.player.buffs[buffName] != null)
            {
               result = false;
            }
         }
         return result;
      }
      
      override public function onFailedPerform() : void
      {
         var cannotUsePopup:GenericPopup = new GenericPopup(ZLocUtils.t("Dialogs","CannotUseWindow_TimedConsumables"));
         UI.displayPopup(cannotUsePopup,true);
      }
   }
}

