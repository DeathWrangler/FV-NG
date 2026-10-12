package Transactions
{
   import Classes.Consumable;
   import Classes.LootableConsumable;
   import Classes.consumables.*;
   import Classes.util.ZLocUtils;
   import Display.UI;
   
   public class TUseLootableConsumable extends TWorldState
   {
      
      private var m_params:Object = new Object();
      
      private var m_itemName:String;
      
      public function TUseLootableConsumable(itemName:String, isGift:Boolean = true, buildingId:int = 0)
      {
         this.m_itemName = itemName;
         this.m_params.isGift = isGift;
         this.m_params.isStorageWithdrawal = buildingId;
         if(isGift)
         {
            Global.player.removeGift(null,itemName);
            UI.displayGiftBoxWindow();
         }
         var item:LootableConsumable = new LootableConsumable(itemName);
         super(item);
      }
      
      override public function perform() : void
      {
         signedWorldAction(TWorldState.ACTION_USE,this.m_params);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var consumable:Consumable = Consumable.createConsumable(result.consumableName);
         if(consumable)
         {
            consumable.onUse();
            UI.displayMessage(ZLocUtils.t("Dialogs","Lootable_Consumable_Use_Msg",{"item":ZLocUtils.tk_pk(consumable.getItemFriendlyName())}));
         }
      }
   }
}

