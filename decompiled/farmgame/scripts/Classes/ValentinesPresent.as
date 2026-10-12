package Classes
{
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Engine.Managers.TransactionManager;
   import Transactions.TOpenValentinesPresent;
   import flash.events.MouseEvent;
   
   public class ValentinesPresent extends LootableDecoration
   {
      
      public function ValentinesPresent(itemName:String = null)
      {
         super(itemName);
      }
      
      override protected function getMenuItems() : Array
      {
         var menuItems:Array = new Array();
         if(!this.isNew)
         {
            menuItems.push({
               "label":ZLocUtils.t("FarmGame","Open"),
               "action":OPEN_OBJECT
            });
         }
         menuItems.push({
            "label":ZLocUtils.t("FarmGame","Move"),
            "action":MOVE_OBJECT
         });
         return menuItems;
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case OPEN_OBJECT:
                  this.onOpen();
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
      
      public function onOpen() : void
      {
         TransactionManager.addTransaction(new TOpenValentinesPresent(this),true);
      }
   }
}

