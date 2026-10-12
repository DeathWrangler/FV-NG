package Transactions
{
   import Classes.ZItem.FarmItem;
   import GameMode.GMObjectMove;
   import GameMode.GameMode;
   import Managers.UGCDecoManager;
   import flash.utils.Dictionary;
   
   public class TSellStoredItem extends TFarmTransaction
   {
      
      protected var m_sellAll:Boolean;
      
      protected var m_giftData:Object;
      
      protected var m_origin:String;
      
      private var m_callBackFunc:Function;
      
      protected var m_sellQty:int;
      
      public function TSellStoredItem(itemKey:String, sellAll:Boolean, callBackFunc:Function, origin:int, sellQty:int = 1)
      {
         super();
         this.m_giftData = {"code":itemKey};
         this.m_sellAll = sellAll;
         this.m_callBackFunc = callBackFunc;
         this.m_origin = origin.toString();
         this.m_sellQty = sellQty;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.sellStoredItem",this.m_giftData,this.m_sellAll,this.m_origin,this.m_sellQty);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var currencyUnit:String = null;
         if(result)
         {
            if(result.sellable != false)
            {
               if(result.hasOwnProperty("sellAmounts"))
               {
                  for(currencyUnit in result["sellAmounts"])
                  {
                     Global.player.updateWorldCurrency(currencyUnit,result["sellAmounts"][currencyUnit]);
                  }
               }
            }
            if(Boolean(result.giftsReset) && result.giftsReset == true)
            {
               Global.player.gifts = new Dictionary();
            }
            if(result["ugcdeco"])
            {
               UGCDecoManager.instance.setFeatureData(result.ugcdeco);
            }
         }
         Global.hud.conditionallyRefreshHUD(true);
         this.m_callBackFunc(result);
         var gm:GameMode = Global.world.getTopGameMode();
         if(gm is GMObjectMove)
         {
            Global.world.popGameMode();
         }
         var itemCode:String = Global.farmGameSettingsManager.getItemCodeFromInventoryKey(this.m_giftData.code);
         var giftObj:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
         giftObj.onSell(this.m_sellQty);
         if(giftObj != null)
         {
            if(Boolean(giftObj) && giftObj.limit > 0)
            {
               Global.player.removeLimitedItem(giftObj.name);
            }
         }
      }
   }
}

