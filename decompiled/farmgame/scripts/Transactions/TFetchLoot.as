package Transactions
{
   import Classes.ZItem.LootItem;
   import Engine.Managers.ErrorManager;
   
   public final class TFetchLoot extends TFarmTransaction
   {
      
      private static const RESULT_KEY_LOOT_ITEMS:String = "lootItems";
      
      private static const SERVICE_METHOD:String = "LootService.fetchLoot";
      
      private var m_lootKey:String;
      
      protected var m_callback:Function;
      
      public function TFetchLoot(lootKey:String, callback:Function = null)
      {
         super();
         this.m_lootKey = lootKey;
         this.m_callback = callback;
      }
      
      override public function perform() : void
      {
         signedCall(SERVICE_METHOD,this.m_lootKey);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var lootItems:Array = null;
         var lootItem:LootItem = null;
         var lootTable:Array = null;
         var lootItemData:Object = null;
         if(result)
         {
            if(this.m_callback !== null)
            {
               lootItems = new Array();
               if(result.hasOwnProperty(RESULT_KEY_LOOT_ITEMS))
               {
                  lootItem = null;
                  lootTable = result[RESULT_KEY_LOOT_ITEMS] as Array;
                  for each(lootItemData in lootTable)
                  {
                     lootItem = new LootItem();
                     lootItem.loadObject(lootItemData);
                     lootItems.push(lootItem);
                  }
               }
               this.m_callback(lootItems);
            }
         }
         else
         {
            ErrorManager.addError(SERVICE_METHOD + " failed for loot key: " + this.m_lootKey);
         }
      }
   }
}

