package Display.QueuedIcons
{
   import Classes.Constants.ArrowType;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.DynamicIconQueue;
   import Engine.Managers.StatsManager;
   import Managers.ToasterManager;
   import Widgets.Windows.IconToasterWindow;
   
   public class DailyDripIcon extends QueuedIconWithArrow
   {
      
      public function DailyDripIcon(xml:XML)
      {
         super(xml);
         this.side = DynamicIconQueue.RIGHT_SIDE;
         this.attachArrow(ArrowType.ARROWNEW);
         this.setArrowText(ZLocUtils.t("Dialogs",iconName + "_Arrow_Text"));
      }
      
      override public function finishClick(queue:DynamicIconQueue) : void
      {
         super.finishClick(queue);
         var itemData:FarmItem = extraData.item as FarmItem;
         if(itemData != null)
         {
            ToasterManager.getInstance().addImmediate(new IconToasterWindow(itemData.icon,extraData.message));
            StatsManager.count("react_optimization","dialog_view",itemData.name);
         }
      }
   }
}

