package Classes
{
   import Classes.buffs.BMasteryGeneric;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   
   public class MasteryBuffDecoration extends BuffDecoration
   {
      
      private static const UNUSED_MASTERY_BUFF_DECORATIONS:String = "UnusedMasteryBuffDecorations";
      
      public function MasteryBuffDecoration(itemName:String = null)
      {
         super(itemName);
         var buff:Buff = getBuff();
      }
      
      override public function onPlacedFirstTime() : void
      {
         var tbuff:Buff = null;
         var buff:Buff = getBuff();
         var buffName:String = buff.itemName;
         var buffs:Array = Global.player.getBuffsByClass(BMasteryGeneric);
         var buffExpiredCount:int = 0;
         var buffCount:int = 0;
         for each(tbuff in buffs)
         {
            if(tbuff.itemName == buffName)
            {
               buffCount++;
               if(tbuff.isExpired())
               {
                  buffExpiredCount++;
               }
            }
         }
         if(buffExpiredCount >= buffCount)
         {
            buff.apply(true);
         }
      }
      
      override protected function showPlacementDialog() : void
      {
      }
      
      override public function onStorage() : void
      {
         super.onStorage();
      }
      
      override protected function updateToolTipText() : void
      {
         var buff:Buff = null;
         var timeRemainingString:String = null;
         var toolTip:String = ZLocUtils.tk_pk_asTitle(m_item.friendlyName);
         if(!Global.worldManager.isVisiting())
         {
            buff = getBuff();
            if(Boolean(buff) && !buff.isExpired())
            {
               timeRemainingString = FarmGameUtil.toFriendlyTime(getBuff().secondsRemaining);
               toolTip += "-" + ZLocUtils.t("Dialogs","ExpiresIn",{"time":timeRemainingString});
            }
            else if(this.isNew)
            {
               toolTip += "\n " + ZLocUtils.t("Dialogs","MasteryBuffApplying");
            }
            else
            {
               toolTip += "\n " + ZLocUtils.t("Dialogs","Expired");
            }
         }
         setToolTip(toolTip);
         updateToolTipPosition();
      }
   }
}

