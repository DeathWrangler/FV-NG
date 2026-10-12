package Managers
{
   import Classes.RewardCard;
   import Classes.ZItem.FarmItem;
   
   public class RewardCardsManager
   {
      
      private static var m_objInstance:RewardCardsManager;
      
      public static const REWARD_CARDS_COUNTER:String = "reward_cards";
      
      public static const REWARD_TYPES:Array = ["animal","tree"];
      
      private var m_rewardCards:Object;
      
      private var m_canShowToaster:Boolean = true;
      
      public function RewardCardsManager(objEnforcer:SingletonEnforcer)
      {
         super();
         this.m_rewardCards = new Object();
         this.m_canShowToaster = true;
         var xml:XML = Global.farmGameSettingsManager.getXML();
         if(Boolean(xml.rewardCards) && Boolean(xml.rewardCards.children()))
         {
            this.loadXML(xml.rewardCards);
         }
      }
      
      public static function getInstance() : RewardCardsManager
      {
         if(m_objInstance == null)
         {
            m_objInstance = new RewardCardsManager(new SingletonEnforcer());
         }
         return m_objInstance;
      }
      
      public function loadXML(rewardCardsConfig:XMLList) : void
      {
         var rewardCard:RewardCard = null;
         var rewardCardXML:XML = null;
         for each(rewardCardXML in rewardCardsConfig.rewardCard)
         {
            rewardCard = new RewardCard(rewardCardXML);
            if(rewardCard.passesPrereqs())
            {
               this.m_rewardCards[rewardCard.name] = rewardCard;
            }
         }
      }
      
      public function getRewardCards() : Array
      {
         var key:String = null;
         var result:Array = new Array();
         for(key in this.m_rewardCards)
         {
            result.push(this.m_rewardCards[key]);
         }
         return result;
      }
      
      public function rewardCardsUpdated(rewardCardName:String, newValue:Object) : void
      {
         var rewardCard:RewardCard = this.m_rewardCards[rewardCardName];
         rewardCard.onPurchaseUpdate(newValue);
      }
      
      public function getRewardTypes() : Array
      {
         return RewardCardsManager.REWARD_TYPES;
      }
      
      public function redeemRewardCard(farmItem:FarmItem = null) : Boolean
      {
         var rewardCard:RewardCard = null;
         var redeemed:Boolean = false;
         for each(rewardCard in this.m_rewardCards)
         {
            if(rewardCard.isRedeemable(farmItem))
            {
               rewardCard.redeemItem(farmItem);
               redeemed = true;
            }
         }
         return redeemed;
      }
      
      public function getRedeemableRewardCard(farmItem:FarmItem) : RewardCard
      {
         var rewardCard:RewardCard = null;
         var result:RewardCard = null;
         if(farmItem != null)
         {
            for each(rewardCard in this.m_rewardCards)
            {
               if(rewardCard.isRedeemable(farmItem))
               {
                  result = rewardCard;
                  break;
               }
            }
         }
         return result;
      }
      
      public function isRewardCardsActive() : Boolean
      {
         return this.getRewardCards().length > 0;
      }
      
      public function getRewardCard(rewardCardName:String) : RewardCard
      {
         return this.m_rewardCards[rewardCardName];
      }
      
      public function getShowToaster() : Boolean
      {
         return this.m_canShowToaster;
      }
      
      public function setShowToaster(canShow:Boolean) : void
      {
         this.m_canShowToaster = canShow;
      }
   }
}

class SingletonEnforcer
{
   
   public function SingletonEnforcer()
   {
      super();
   }
}
