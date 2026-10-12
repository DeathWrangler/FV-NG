package Transactions
{
   import Classes.util.ZLocUtils;
   import Managers.WanderingAnimalsManager;
   
   public class TWanderingMustangBuy extends TFarmTransaction
   {
      
      public var m_rewardId:String;
      
      public var m_buyReward:Boolean;
      
      public function TWanderingMustangBuy(rewardId:String, buyReward:Boolean)
      {
         super();
         this.m_rewardId = rewardId;
         this.m_buyReward = buyReward;
      }
      
      override public function perform() : void
      {
         signedCall("WanderingAnimalService.onBuyWanderingMustang",this.m_rewardId,this.m_buyReward);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var message:String = null;
         if(result)
         {
            if(result.bought)
            {
               if(Boolean(result.cash) && Boolean(result.itemName))
               {
                  Global.player.addGift(result.itemName);
                  if(Global.player.cash > result.cash)
                  {
                     Global.player.cash -= result.cash;
                  }
                  message = ZLocUtils.t("Dialogs","wandering_mustang_congrats_gift_box");
                  WanderingAnimalsManager.getInstance().showWanderingMustangSuccessPopup(message);
               }
            }
         }
      }
   }
}

