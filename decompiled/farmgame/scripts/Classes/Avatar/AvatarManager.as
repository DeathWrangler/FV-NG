package Classes.Avatar
{
   import Classes.Player;
   import Classes.feed.AvatarPurchaseClothesFeed;
   import Display.AvatarOnboardDialog;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Managers.FreezeManager;
   import Transactions.TBuyAvatarItem;
   import Transactions.TSaveAvatar;
   import Widgets.Constants.Market.Currency;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class AvatarManager
   {
      
      private static var m_itemsBoughtSinceLastFeedFlow:Array;
      
      private static const AVATAR_CENTER_TIME:int = 2500;
      
      private static var m_timer:Timer = null;
      
      private static var m_isLastPurchaseFromMarket:Boolean = false;
      
      public function AvatarManager()
      {
         super();
      }
      
      public static function buyAvatarItem(itemId:String, isBuyFromMarket:Boolean = false, performImmediately:Boolean = false) : Boolean
      {
         var counter:String = null;
         var transaction:TBuyAvatarItem = null;
         var kingdom:String = null;
         var avatarItem:AvatarItem = Global.avatarConfigSettings.getItemById(itemId);
         var marketType:String = avatarItem.market;
         var result:Boolean = false;
         switch(marketType)
         {
            case Currency.COINS:
               if(Global.player.canBuy(avatarItem.cost))
               {
                  Global.player.gold -= avatarItem.cost;
                  result = true;
                  counter = "fv_coin_buy";
               }
               break;
            case Currency.CASH:
               if(Global.player.canBuyCash(avatarItem.cost))
               {
                  Global.player.cash -= avatarItem.cost;
                  result = true;
                  counter = "fv_cash_buy";
               }
         }
         if(result)
         {
            Global.player.avatarState.grantItem(itemId);
            Global.player.xp += avatarItem.xp;
            transaction = new TBuyAvatarItem(avatarItem);
            TransactionManager.addTransaction(transaction,performImmediately);
            if(m_itemsBoughtSinceLastFeedFlow == null)
            {
               m_itemsBoughtSinceLastFeedFlow = new Array();
            }
            m_itemsBoughtSinceLastFeedFlow.push(avatarItem);
            m_isLastPurchaseFromMarket = isBuyFromMarket;
            if(isBuyFromMarket)
            {
               FreezeManager.pushPostThawCallback(startPurchaseAnimationFlow);
            }
            kingdom = isBuyFromMarket ? "avatar_marketplace" : "avatar_customizer";
            FarmStatsManager.count(counter,kingdom,avatarItem.name,avatarItem.cost.toString());
         }
         return result;
      }
      
      public static function isLastPurchaseFromMarket() : Boolean
      {
         return m_isLastPurchaseFromMarket;
      }
      
      public static function saveAvatar(player:Player = null) : void
      {
         if(!player)
         {
            player = Global.player;
         }
         TransactionManager.addTransaction(new TSaveAvatar(player),true);
      }
      
      public static function grantAchievementAward(itemId:String) : void
      {
         Global.player.avatarState.grantItem(itemId);
      }
      
      public static function showOnboardDialog() : void
      {
         UI.displayPopup(new AvatarOnboardDialog());
      }
      
      public static function startPurchaseAnimationFlow() : void
      {
         Global.player.avatar.startSuperOverlay();
         Global.world.centerOnObject(Global.player.avatar,1,0,onCompleteCenterAvatar);
      }
      
      public static function onCompleteCenterAvatar() : void
      {
         if(m_timer == null)
         {
            m_timer = new Timer(AVATAR_CENTER_TIME,1);
            m_timer.addEventListener(TimerEvent.TIMER_COMPLETE,onCenterAvatarTimerComplete);
            m_timer.start();
         }
      }
      
      private static function onCenterAvatarTimerComplete(event:TimerEvent) : void
      {
         var avatarItem:AvatarItem = null;
         var feedFlow:AvatarPurchaseClothesFeed = null;
         if(m_timer != null)
         {
            m_timer.stop();
            m_timer.removeEventListener(TimerEvent.TIMER_COMPLETE,onCenterAvatarTimerComplete);
            m_timer = null;
            Global.player.avatar.stopOverlay();
            if(Boolean(m_itemsBoughtSinceLastFeedFlow) && Boolean(m_itemsBoughtSinceLastFeedFlow.length > 0) && !Global.player.getSeenSessionFlag("buyClothesFeed"))
            {
               avatarItem = m_itemsBoughtSinceLastFeedFlow.pop();
               feedFlow = new AvatarPurchaseClothesFeed(avatarItem);
               feedFlow.startFeedFlow();
               Global.player.setSeenSessionFlag("buyClothesFeed");
               m_itemsBoughtSinceLastFeedFlow.length = 0;
               m_itemsBoughtSinceLastFeedFlow = null;
            }
         }
      }
      
      public static function showAdvancedAvatarMenus() : Boolean
      {
         return userMeetsRevampLevel();
      }
      
      public static function userMeetsRevampLevel() : Boolean
      {
         return Global.player.level >= Global.avatarConfigSettings.clothingLevelGate;
      }
      
      public static function conditionallyShowOnboarding() : void
      {
         if(AvatarManager.showAdvancedAvatarMenus())
         {
            if(!Global.player.getSeenFlag("avatarOnboard"))
            {
               AvatarManager.showOnboardDialog();
               Global.player.setSeenFlag("avatarOnboard");
            }
         }
      }
   }
}

