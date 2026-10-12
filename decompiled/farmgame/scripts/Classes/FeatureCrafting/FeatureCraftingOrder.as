package Classes.FeatureCrafting
{
   import Engine.Managers.TransactionManager;
   import Transactions.FeatureCrafting.TFillFeatureCraftingOrder;
   
   public class FeatureCraftingOrder
   {
      
      private var m_orderBoard:FeatureCraftingOrderBoard;
      
      private var m_requiredGoods:Array;
      
      private var m_complete:Boolean;
      
      private var m_rewards:Array;
      
      private var m_index:int;
      
      public function FeatureCraftingOrder(orderBoard:FeatureCraftingOrderBoard, index:int, data:Object)
      {
         var name:String = null;
         var goods:Array = null;
         var good:FeatureCraftingGood = null;
         super();
         this.m_orderBoard = orderBoard;
         this.m_index = index;
         var goodNames:Array = [];
         for(name in data.goods)
         {
            goodNames.push(name);
         }
         this.m_requiredGoods = [];
         goods = this.system.getGoodsByNames(goodNames);
         for each(good in goods)
         {
            this.m_requiredGoods.push(new FeatureCraftingRequiredGood(this.system,good,data.goods[good.name]));
         }
         this.m_complete = data.complete;
         this.m_rewards = data.rewards;
      }
      
      public function get system() : FeatureCraftingSystem
      {
         return this.m_orderBoard.system;
      }
      
      public function get orderBoard() : FeatureCraftingOrderBoard
      {
         return this.m_orderBoard;
      }
      
      public function requiredGoods() : Array
      {
         return this.m_requiredGoods;
      }
      
      public function get isComplete() : Boolean
      {
         return this.m_complete;
      }
      
      public function get rewards() : Array
      {
         return this.m_rewards;
      }
      
      public function get helperImageUrl() : String
      {
         return this.findNPCPicture();
      }
      
      private function findNPCPicture() : String
      {
         var result:String = null;
         var hashIndex:int = 0;
         var characterImages:Array = this.system.getNPCCharacterImages();
         if(characterImages)
         {
            hashIndex = (this.m_index + this.m_requiredGoods.length) % characterImages.length;
            result = characterImages[hashIndex];
         }
         return result;
      }
      
      public function fillOrder() : Boolean
      {
         var requiredGood:FeatureCraftingRequiredGood = null;
         var result:Boolean = false;
         if(this.canFillOrder())
         {
            TransactionManager.addTransaction(new TFillFeatureCraftingOrder(this.system.name,this.m_orderBoard.npcName,this.m_index),true);
            for each(requiredGood in this.m_requiredGoods)
            {
               requiredGood.good.decrementCount(requiredGood.numRequired);
            }
            this.finishFillOrder();
            result = true;
         }
         return result;
      }
      
      public function canFillOrder() : Boolean
      {
         var requiredGood:FeatureCraftingRequiredGood = null;
         var result:Boolean = false;
         if(!this.m_complete)
         {
            result = true;
            for each(requiredGood in this.m_requiredGoods)
            {
               if(!requiredGood.hasEnough)
               {
                  result = false;
                  break;
               }
            }
         }
         return result;
      }
      
      public function getBuyRemainingGoodsCost() : int
      {
         var requiredGood:FeatureCraftingRequiredGood = null;
         var result:int = 0;
         if(this.m_orderBoard.completeNowPrice > 0)
         {
            result = this.m_orderBoard.completeNowPrice;
         }
         else
         {
            for each(requiredGood in this.m_requiredGoods)
            {
               if(!requiredGood.hasEnough)
               {
                  result += requiredGood.good.costToBuy(requiredGood.numRequired - requiredGood.good.inventoryCount);
               }
            }
         }
         return result;
      }
      
      public function completeNow() : Boolean
      {
         var cost:int = 0;
         var requiredGood:FeatureCraftingRequiredGood = null;
         var result:Boolean = false;
         if(!this.canFillOrder() && !this.m_complete)
         {
            cost = this.getBuyRemainingGoodsCost();
            if(Global.player.canBuyCash(cost))
            {
               Global.player.cash -= cost;
               TransactionManager.addTransaction(new TFillFeatureCraftingOrder(this.system.name,this.m_orderBoard.npcName,this.m_index,true),true);
               if(this.m_orderBoard.completeNowPrice == 0)
               {
                  for each(requiredGood in this.m_requiredGoods)
                  {
                     requiredGood.good.decrementCount(Math.min(requiredGood.numRequired,requiredGood.good.inventoryCount));
                  }
               }
               this.finishFillOrder();
               result = true;
            }
         }
         return result;
      }
      
      private function finishFillOrder() : void
      {
         this.m_complete = true;
         if(this.system.currentContentsWindow)
         {
            this.system.currentContentsWindow.refreshInventoryCounts();
            this.system.currentContentsWindow.refreshOrders(false);
         }
         this.system.grantRewards(this.m_rewards);
         this.m_orderBoard.finishFillOrder();
      }
   }
}

