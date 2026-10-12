package Display.QueuedIcons
{
   import Classes.Constants.ArrowType;
   import Classes.util.ZLocUtils;
   import Display.DynamicIconQueue;
   import Managers.TimedSlotGiveawaysManager;
   
   public class TimedGiveawayIcon extends QueuedIconWithArrow
   {
      
      public function TimedGiveawayIcon(xml:XML)
      {
         super(xml);
         if(TimedSlotGiveawaysManager.canAsk(iconName) && ZLocUtils.hasString("Dialogs",iconName + "_Arrow_Text"))
         {
            this.side = DynamicIconQueue.RIGHT_SIDE;
            this.attachArrow(ArrowType.ARROWNEW);
            this.setArrowText(ZLocUtils.t("Dialogs",iconName + "_Arrow_Text"));
         }
      }
      
      override public function finishClick(queue:DynamicIconQueue) : void
      {
         super.finishClick(queue);
         TimedSlotGiveawaysManager.showGiveawayWindow(iconName);
      }
   }
}

