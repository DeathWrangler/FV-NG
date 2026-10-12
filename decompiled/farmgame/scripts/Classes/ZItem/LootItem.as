package Classes.ZItem
{
   import Engine.Managers.ErrorManager;
   
   public class LootItem
   {
      
      private static const KEY_ITEM_NAME:String = "itemName";
      
      private static const KEY_QUANTITY:String = "quantity";
      
      private static const KEY_RARITY:String = "rare";
      
      public static const RARITY_COMMON:String = "common";
      
      public static const RARITY_UNCOMMON:String = "uncommon";
      
      public static const RARITY_RARE:String = "rare";
      
      public static const RARITY_SUPER_RARE:String = "super_rare";
      
      public static const MAX_RARITY_INDEX:int = 2;
      
      private var m_item:FarmItem;
      
      private var m_quantity:int;
      
      private var m_rarity:String;
      
      private var m_data:Object;
      
      public function LootItem()
      {
         super();
         this.m_data = null;
         this.m_item = null;
         this.m_quantity = 0;
         this.m_rarity = RARITY_COMMON;
      }
      
      public function loadObject(data:Object) : void
      {
         if(data)
         {
            this.m_data = data;
            if(data.hasOwnProperty(KEY_ITEM_NAME))
            {
               this.m_item = Global.farmGameSettingsManager.getFarmItemByName(data[KEY_ITEM_NAME] as String);
            }
            if(data.hasOwnProperty(KEY_QUANTITY))
            {
               try
               {
                  this.m_quantity = parseInt(data[KEY_QUANTITY] as String);
               }
               catch(err:Error)
               {
                  ErrorManager.addError("Invalid quantity: " + data[KEY_QUANTITY]);
                  m_quantity = 1;
               }
            }
            if(data.hasOwnProperty(KEY_RARITY))
            {
               this.m_rarity = data[KEY_RARITY] as String;
            }
            else
            {
               this.m_rarity = this.m_item.rare ? RARITY_RARE : RARITY_COMMON;
            }
         }
         else
         {
            ErrorManager.addError("null data passed to LootItem#loadObject");
         }
      }
      
      public function getValueForKey(key:String) : Object
      {
         return this.m_data.hasOwnProperty(key) ? this.m_data[key] : null;
      }
      
      public function get item() : FarmItem
      {
         return this.m_item;
      }
      
      public function get quantity() : int
      {
         return this.m_quantity;
      }
      
      public function get rarity() : String
      {
         return this.m_rarity;
      }
      
      public function get rarityIndex() : int
      {
         var index:int = 0;
         switch(this.m_rarity)
         {
            case RARITY_UNCOMMON:
               index = 1;
               break;
            case RARITY_RARE:
               index = 2;
               break;
            case RARITY_SUPER_RARE:
               index = 3;
         }
         return index;
      }
   }
}

