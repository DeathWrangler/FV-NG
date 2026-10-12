package Classes.BushelBaby
{
   import Classes.Animal;
   import Classes.ZItem.FarmItem;
   
   public class BushelBabyNPCLevel
   {
      
      public static const ASSET_STATE_IDLE:String = "idle";
      
      private var m_npc:BushelBabyNPC;
      
      private var m_levelNum:int;
      
      private var m_item:FarmItem;
      
      private var m_orderItems:Vector.<BushelBabyOrderItem>;
      
      public function BushelBabyNPCLevel(npc:BushelBabyNPC, configObj:Object)
      {
         var orderItem:Object = null;
         super();
         this.m_npc = npc;
         this.m_levelNum = parseInt(configObj.levelNum);
         this.m_item = Global.farmGameSettingsManager.getFarmItemByName(configObj.itemName);
         this.m_orderItems = new Vector.<BushelBabyOrderItem>();
         for each(orderItem in configObj.orderItems)
         {
            this.m_orderItems.push(new BushelBabyOrderItem(this,orderItem));
         }
      }
      
      public function get npc() : BushelBabyNPC
      {
         return this.m_npc;
      }
      
      public function get levelNum() : int
      {
         return this.m_levelNum;
      }
      
      public function get friendlyItemTitle() : String
      {
         return this.m_item.friendlyTitle;
      }
      
      public function get assetUrl() : String
      {
         return this.m_item.imageRelativeUrl(Animal.STATE_FRONT_IDLE);
      }
      
      public function get assetScale() : Number
      {
         return this.m_item.imageScale;
      }
      
      public function get item() : FarmItem
      {
         return this.m_item;
      }
      
      public function get iconUrl() : String
      {
         return this.m_item.iconUrl;
      }
      
      public function get orderItems() : Vector.<BushelBabyOrderItem>
      {
         return this.m_orderItems;
      }
      
      public function get orderItemArray() : Array
      {
         var oIArray:Array = new Array(this.m_orderItems.length);
         var i:* = int(this.m_orderItems.length);
         while(i--)
         {
            oIArray[i] = this.m_orderItems[i];
         }
         return oIArray;
      }
      
      public function getFullExportName() : String
      {
         var exportNames:Array = this.m_item.getExpectedExportNames();
         return this.m_item.name + "_" + exportNames[0];
      }
      
      public function canCompleteOrder() : Boolean
      {
         var orderItem:BushelBabyOrderItem = null;
         var result:Boolean = true;
         for each(orderItem in this.m_orderItems)
         {
            if(!orderItem.hasEnough)
            {
               result = false;
               break;
            }
         }
         return result;
      }
   }
}

