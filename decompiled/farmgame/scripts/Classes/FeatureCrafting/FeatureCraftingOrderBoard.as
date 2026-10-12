package Classes.FeatureCrafting
{
   import Widgets.Windows.FeatureCrafting.FeatureCraftingRewardWindow;
   
   public class FeatureCraftingOrderBoard
   {
      
      public static const REWARDS_TYPE:String = "type";
      
      public static const REWARDS_VALUE:String = "value";
      
      public static const REWARDS_AMOUNT:String = "amount";
      
      public static const REWARDS_TYPE_COIN:String = "coins";
      
      public static const REWARDS_TYPE_ITEMGRANT:String = "item_grant";
      
      public static const REWARDS_TYPE_POINTS:String = "points";
      
      public static const REWARDS_TYPE_INVENTORYPARTS:String = "inventory_part";
      
      private var m_system:FeatureCraftingSystem;
      
      private var m_npcName:String;
      
      private var m_orders:Array;
      
      private var m_rewards:Array;
      
      private var m_timestamp:Number;
      
      private var m_completeNowPrice:int;
      
      public function FeatureCraftingOrderBoard(system:FeatureCraftingSystem, data:Object)
      {
         var orderData:Object = null;
         super();
         this.m_system = system;
         this.m_orders = [];
         var index:int = 0;
         for each(orderData in data[FeatureCraftingSystem.DATAKEY_ORDERS])
         {
            this.m_orders.push(new FeatureCraftingOrder(this,index,orderData));
            index++;
         }
         this.m_completeNowPrice = data.hasOwnProperty("completeNowPrice") ? int(data["completeNowPrice"]) : 0;
         this.m_npcName = data[FeatureCraftingSystem.DATAKEY_NPC_NAME] ? data[FeatureCraftingSystem.DATAKEY_NPC_NAME] : FeatureCraftingSystem.DEFAULT_NPC_NAME;
         this.m_rewards = data[FeatureCraftingSystem.DATAKEY_REWARDS];
         this.m_timestamp = data[FeatureCraftingSystem.DATAKEY_TIME_STAMP];
      }
      
      public function get system() : FeatureCraftingSystem
      {
         return this.m_system;
      }
      
      public function get npcName() : String
      {
         return this.m_npcName;
      }
      
      public function set npcName(_name:String) : void
      {
         this.m_npcName = _name;
      }
      
      public function get orders() : Array
      {
         return this.m_orders;
      }
      
      public function get rewards() : Array
      {
         return this.m_rewards;
      }
      
      public function get timestamp() : Number
      {
         return this.m_timestamp;
      }
      
      public function get completeNowPrice() : int
      {
         return this.m_completeNowPrice;
      }
      
      public function checkAllOrdersComplete() : Boolean
      {
         var order:FeatureCraftingOrder = null;
         var result:Boolean = true;
         for each(order in this.m_orders)
         {
            if(!order.isComplete)
            {
               result = false;
               break;
            }
         }
         return result;
      }
      
      public function finishFillOrder() : void
      {
         if(this.checkAllOrdersComplete())
         {
            this.m_system.completeOrderBoard(this);
            if(this.m_system.currentNPCWindow)
            {
               this.m_system.currentNPCWindow.close();
            }
            this.m_system.grantRewards(this.m_rewards);
            if(this.m_system.currentContentsWindow)
            {
               this.m_system.currentContentsWindow.showLoadingWidget();
            }
            FeatureCraftingRewardWindow.display(this);
         }
      }
   }
}

