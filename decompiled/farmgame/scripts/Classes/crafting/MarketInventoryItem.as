package Classes.crafting
{
   import Classes.ZItem.FarmItem;
   import Engine.Managers.ErrorManager;
   
   public class MarketInventoryItem
   {
      
      private var m_itemCode:String = null;
      
      private var m_quantity:int = 0;
      
      private var m_expires:Number = 0;
      
      private var m_price:Number = 0;
      
      private var m_item:FarmItem = null;
      
      private var m_level:int = 0;
      
      public function MarketInventoryItem(itemCode:String = null, quantity:int = 0, expires:Number = 0, price:Number = 0, item:FarmItem = null, level:int = 0)
      {
         super();
         this.m_itemCode = itemCode;
         this.m_quantity = quantity;
         this.m_expires = expires;
         this.m_price = price;
         this.m_item = item;
         this.m_level = level;
      }
      
      public static function compareFriendlyName(item1:MarketInventoryItem, item2:MarketInventoryItem) : int
      {
         var result:int = 0;
         var name1:String = item1.underlyingItem ? item1.underlyingItem.friendlyTitle : "";
         var name2:String = item2.underlyingItem ? item2.underlyingItem.friendlyTitle : "";
         if(name1 < name2)
         {
            result = -1;
         }
         else if(name2 < name1)
         {
            result = 1;
         }
         else
         {
            result = 0;
         }
         return result;
      }
      
      public function constructFromResponseObject(responseObject:Object) : void
      {
         this.m_quantity = responseObject.quantity;
         this.m_itemCode = responseObject.itemCode;
         this.m_expires = 0;
         if(responseObject.price != null)
         {
            this.m_price = responseObject.price;
         }
         else
         {
            this.m_price = -1;
         }
      }
      
      public function get itemCode() : String
      {
         return this.m_itemCode;
      }
      
      public function set itemCode(newItemCode:String) : void
      {
         this.m_itemCode = newItemCode;
      }
      
      public function get quantity() : int
      {
         return this.m_quantity;
      }
      
      public function set quantity(newQuantity:int) : void
      {
         this.m_quantity = newQuantity;
      }
      
      public function get expires() : Number
      {
         return this.m_expires;
      }
      
      public function set expires(newExpires:Number) : void
      {
         this.m_expires = newExpires;
      }
      
      public function hasExpired() : Boolean
      {
         var serverTime:Number = Math.floor(GlobalEngine.serverTime / 1000);
         return this.m_expires > 0 && serverTime > this.m_expires;
      }
      
      public function get price() : Number
      {
         return this.m_price;
      }
      
      public function getTaxedPrice() : Number
      {
         return this.m_price - Math.floor(this.m_price * Global.craftConfigSettings.taxRate);
      }
      
      public function set price(newPrice:Number) : void
      {
         this.m_price = newPrice;
      }
      
      public function get level() : int
      {
         return this.m_level;
      }
      
      public function set level(newLevel:int) : void
      {
         this.m_level = newLevel;
      }
      
      public function get friendlyName() : String
      {
         var name:String = "";
         if(this.underlyingItem)
         {
            name = this.underlyingItem.friendlyName;
         }
         return name;
      }
      
      public function get underlyingItem() : FarmItem
      {
         if(this.m_item == null)
         {
            this.m_item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_itemCode);
         }
         if(!this.m_item && Config.DEBUG_MODE)
         {
            ErrorManager.addError(this.m_itemCode + " does not exist in Items.xml");
         }
         return this.m_item;
      }
      
      public function timeRemaining() : Number
      {
         var serverTime:Number = Math.floor(GlobalEngine.serverTime / 1000);
         var result:Number = 0;
         if(this.m_expires > 0)
         {
            return Math.max(this.m_expires - serverTime,0);
         }
         return result;
      }
   }
}

