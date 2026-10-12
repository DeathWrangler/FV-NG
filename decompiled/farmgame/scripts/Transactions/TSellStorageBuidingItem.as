package Transactions
{
   public class TSellStorageBuidingItem extends TFarmTransaction
   {
      
      private var m_itemData:Object;
      
      private var m_sellAll:Boolean;
      
      private var m_callBack:Function;
      
      private var m_origin:int;
      
      private var m_sellQty:int;
      
      private var m_buildingId:int;
      
      private var m_itemMetadataHash:String;
      
      public function TSellStorageBuidingItem(itemCode:String, sellAll:Boolean, callBackFunc:Function, origin:int, sellQty:int = 1, buildingId:int = -1, itemMetadataHash:String = null)
      {
         super();
         this.m_itemData = {"code":itemCode};
         this.m_sellAll = sellAll;
         this.m_callBack = callBackFunc;
         this.m_origin = origin;
         this.m_sellQty = sellQty;
         this.m_buildingId = buildingId;
         this.m_itemMetadataHash = itemMetadataHash;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.sellStorageBuildingItem",this.m_itemData,this.m_sellAll,this.m_origin,this.m_sellQty,this.m_buildingId,this.m_itemMetadataHash);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result)
         {
            if(result.hasOwnProperty("qtySold") && result.qtySold > 0)
            {
               if(result.hasOwnProperty("sellCurrency") && result.hasOwnProperty("totalSellAmount"))
               {
                  Global.player.updateWorldCurrency(result.sellCurrency,result.totalSellAmount,true);
               }
               this.m_callBack();
            }
         }
      }
   }
}

