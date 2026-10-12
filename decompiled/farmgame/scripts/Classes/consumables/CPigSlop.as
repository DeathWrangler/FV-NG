package Classes.consumables
{
   import Classes.Consumable;
   import Classes.PigpenBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericXMLDialog;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.breeding.AnimalBreedingManager;
   import Transactions.TTradePigSlop;
   import flash.events.Event;
   
   public class CPigSlop extends Consumable
   {
      
      public function CPigSlop(itemName:String)
      {
         super(itemName);
      }
      
      override public function onUse() : void
      {
         var pigpens:Array = Global.world.getObjectsByClass(PigpenBuilding);
         var pigpen:PigpenBuilding = pigpens[0] as PigpenBuilding;
         if(pigpen)
         {
            pigpen.addSlop(true);
         }
      }
      
      override public function isOptimistic() : Boolean
      {
         return true;
      }
      
      override public function canUse() : Boolean
      {
         var result:Boolean = false;
         var numSlop:Number = Global.player.getGiftCountForItem(this.getItem().name);
         var windowTitle:String = ZLocUtils.t("Dialogs","pigpenv2_UseSlopWindowTitle");
         var title:String = ZLocUtils.t("Dialogs","pigpenv2_UseSlopTitle");
         var bodyMsg:String = ZLocUtils.t("Dialogs","pigpenv2_UseSlopMessage",{
            "quantityA":numSlop,
            "quantityB":numSlop
         });
         var dialog:GenericXMLDialog = new GenericXMLDialog(windowTitle,title,null,this.getItem().iconRelativeUrl,100,100,bodyMsg,null,true,ZLocUtils.t("Dialogs","Trade"),this.onTradeSlop,ZLocUtils.t("Dialogs","Cancel"));
         UI.displayPopup(dialog,false);
         return result;
      }
      
      private function onTradeSlop(event:Event) : void
      {
         var farmItem:FarmItem = null;
         farmItem = this.getItem();
         var callback:Function = function():void
         {
            var numSlop:Number = Global.player.getGiftCountForItem(farmItem.name);
            Global.player.removeGiftWithKey(farmItem.code,numSlop);
            var lovePotion:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(AnimalBreedingManager.LOVE_POTION_ITEM_CODE);
            Global.player.addGift(lovePotion.name,"0",numSlop);
            var windowTitle:String = ZLocUtils.t("Dialogs","pigpenv2_SuccessSlopTradeWindowTitle");
            var title:String = ZLocUtils.t("Dialogs","pigpenv2_SuccessSlopTradeTitle");
            var bodyMsg:String = ZLocUtils.t("Dialogs","pigpenv2_SuccessSlopTradeMessage");
            var dialog:GenericXMLDialog = new GenericXMLDialog(windowTitle,title,null,lovePotion.iconRelativeUrl,100,100,bodyMsg,null,true,ZLocUtils.t("FarmGame","OK"),null);
            UI.displayPopup(dialog,false);
         };
         TransactionManager.addTransaction(new TTradePigSlop(callback),true);
      }
   }
}

