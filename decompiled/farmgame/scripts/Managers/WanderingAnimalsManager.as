package Managers
{
   import Classes.FriendReward;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.DynamicIconQueue;
   import Display.EmailPopup;
   import Display.FriendSelector;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.CloseEvent;
   import Events.GenericPopupEvent;
   import Transactions.TWanderingMustang;
   import Transactions.TWanderingMustangBuy;
   import Transactions.TWanderingMustangSendEmail;
   import flash.events.Event;
   
   public class WanderingAnimalsManager
   {
      
      private static var m_instance:WanderingAnimalsManager = null;
      
      private static var m_canInstantiate:Boolean = false;
      
      private const ITEM_CODE_MUSTANG:String = "Ga";
      
      private const ITEM_NAME_MUSTANG:String = "mustang";
      
      private const ITEM_COST_MUSTANG:Number = 4;
      
      private const WANDERING_MUSTANG_POPUP_SEEN_FLAG:String = "wanderingMustangPopup";
      
      private var m_stallionPopupFrequency:int;
      
      private var m_stallionPopupProbability:Number;
      
      private var m_mustangPopupFrequency:int;
      
      private var m_mustangPopupProbability:Number;
      
      private var m_mustangMinFriends:Number;
      
      private var m_mustangMaxFriends:Number;
      
      protected var m_friendSelector:FriendSelector;
      
      protected var m_friendList:Array;
      
      protected var m_rewardId:String;
      
      public function WanderingAnimalsManager()
      {
         super();
         if(!m_canInstantiate)
         {
            throw new Error("Cannot call WanderingAnimalsManager constructor directly - use getInstance() instead.");
         }
         this.m_stallionPopupFrequency = Global.farmGameSettingsManager.getInt("wanderingStallionPopupFrequency",86400);
         this.m_stallionPopupProbability = Global.farmGameSettingsManager.getNumber("wanderingStallionPopupProbability",0.4);
         this.m_mustangPopupFrequency = Global.farmGameSettingsManager.getInt("wanderingMustangPopupFrequency",86400);
         this.m_mustangPopupProbability = Global.farmGameSettingsManager.getNumber("wanderingMustangPopupProbability",0.4);
         this.m_mustangMinFriends = Global.farmGameSettingsManager.getNumber("wanderingMustangMinFriends",5);
         this.m_mustangMaxFriends = Global.farmGameSettingsManager.getNumber("wanderingMustangMaxFriends",15);
      }
      
      public static function getInstance() : WanderingAnimalsManager
      {
         if(null == m_instance)
         {
            m_canInstantiate = true;
            m_instance = new WanderingAnimalsManager();
            m_canInstantiate = false;
         }
         return m_instance;
      }
      
      public function showWanderingStallion() : Boolean
      {
         return false;
      }
      
      public function showWanderingMustang() : Boolean
      {
         return false;
      }
      
      public function showGiveEmailPopup() : Boolean
      {
         var iconURL:String = Global.getAssetURL("assets/animals/animal_mustang_icon.png");
         var promoMessage:String = ZLocUtils.t("Dialogs","wandering_mustang_give_email_message");
         var dialog:GenericIconPopup = new GenericIconPopup(promoMessage,GenericPopup.TYPE_ASKBUY,this.onShowGiveEmailPopup,iconURL,false,true,"showGiveEmailPopup",false,"assets/dialogs/FV_Feature_Callout_Mustang.swf");
         dialog.setAcceptTextName("wandering_mustang_give_email_button");
         dialog.setCancelTextName("Cancel");
         UI.displayPopup(dialog);
         return true;
      }
      
      public function onShowGiveEmailPopup(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            EmailManager.displayEmailPermissionPrompt(EmailPopup.EMAIL_WILD_MUSTANG,this.onFinishEmailPermission);
         }
      }
      
      public function onFinishEmailPermission() : void
      {
         TransactionManager.addTransaction(new TWanderingMustang());
      }
      
      public function onAskForHelp(rewardId:String) : void
      {
         this.m_rewardId = rewardId;
         this.m_friendSelector = new FriendSelector(true,this.m_mustangMinFriends,this.m_mustangMaxFriends,true);
         this.m_friendSelector.setTitle("WanderingMustangFriendSelectorTitle");
         this.m_friendSelector.setNextDetailText("WanderingMustangFriendSelectorNextDetail");
         this.m_friendSelector.addEventListener(CloseEvent.CLOSE,this.onFriendSelectorClose);
         UI.displayPopup(this.m_friendSelector);
         FarmStatsManager.count("wild_mustang","view_mustang","ask_for_help");
      }
      
      protected function onFriendSelectorClose(event:Event) : void
      {
         if(this.m_friendSelector == null)
         {
            this.m_friendList = new Array();
         }
         else
         {
            this.m_friendSelector.removeEventListener(CloseEvent.CLOSE,this.onFriendSelectorClose);
            this.m_friendList = this.m_friendSelector.getSelectedFriendsUID();
            this.m_friendSelector = null;
         }
         if(this.m_friendList.length > 0)
         {
            TransactionManager.addTransaction(new TWanderingMustangSendEmail(this.m_friendList,this.m_rewardId));
         }
      }
      
      public function onBuyHelp(rewardId:String, message:String) : void
      {
         this.m_rewardId = rewardId;
         var iconURL:String = Global.getAssetURL("assets/animals/animal_mustang_icon.png");
         var dialog:GenericIconPopup = new GenericIconPopup(message,GenericPopup.TYPE_ACCEPTCANCEL,this.onWanderingMustangBuyHelp,iconURL,false,false);
         dialog.setAcceptTextName("wandering_mustang_buy_now_button");
         UI.displayPopup(dialog);
         FarmStatsManager.count("wild_mustang","view_mustang","buy_help");
      }
      
      protected function onWanderingMustangBuyHelp(event:GenericPopupEvent) : void
      {
         var item:FarmItem = null;
         var buyItem:Boolean = false;
         if(event.button == GenericPopup.ACCEPT)
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(this.ITEM_NAME_MUSTANG);
            if(Global.player.canBuyCash(item.cash,true))
            {
               buyItem = true;
            }
            FarmStatsManager.count("wild_mustang","view_mustang","buy_help","click_accept");
         }
         else
         {
            FarmStatsManager.count("wild_mustang","view_mustang","buy_help","click_cancel");
         }
         TransactionManager.addTransaction(new TWanderingMustangBuy(this.m_rewardId,buyItem));
      }
      
      public function onBuyNow(rewardId:String, message:String) : void
      {
         this.m_rewardId = rewardId;
         var iconURL:String = Global.getAssetURL("assets/animals/animal_mustang_icon.png");
         var dialog:GenericIconPopup = new GenericIconPopup(message,GenericPopup.TYPE_ACCEPTCANCEL,this.onWanderingMustangBuyNow,iconURL,false,false);
         dialog.setAcceptTextName(ZLocUtils.t("Dialogs","wandering_mustang_buy_now_button"));
         UI.displayPopup(dialog);
         FarmStatsManager.count("wild_mustang","fail_mustang","buy_help");
      }
      
      protected function onWanderingMustangBuyNow(event:GenericPopupEvent) : void
      {
         var item:FarmItem = null;
         var buyItem:Boolean = false;
         if(event.button == GenericPopup.ACCEPT)
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(this.ITEM_NAME_MUSTANG);
            if(Global.player.canBuyCash(item.cash,true))
            {
               buyItem = true;
            }
            FarmStatsManager.count("wild_mustang","fail_mustang","buy_help","click_accept");
         }
         else
         {
            FarmStatsManager.count("wild_mustang","fail_mustang","buy_help","click_cancel");
         }
         TransactionManager.addTransaction(new TWanderingMustangBuy(this.m_rewardId,buyItem));
      }
      
      public function updateWanderingMustangStatus() : void
      {
         var friendReward:FriendReward = null;
         var successMessage:String = null;
         var successFound:Boolean = false;
         var friendRewardArray:Array = FriendRewardsManager.getInstance().getAllFriendRewardByName("WanderingMustangFriendReward");
         for each(friendReward in friendRewardArray)
         {
            if(friendReward)
            {
               if(friendReward.success())
               {
                  successMessage = ZLocUtils.t("Dialogs","wandering_mustang_success");
                  this.showWanderingMustangSuccessPopup(successMessage);
                  TransactionManager.addTransaction(new TWanderingMustangBuy(friendReward.id,false));
                  successFound = true;
                  break;
               }
            }
         }
         if(!successFound)
         {
            this.displayWanderingMustangOngoingExpiredPopup();
         }
      }
      
      public function displayWanderingMustangOngoingExpiredPopup() : void
      {
         var friendReward:FriendReward = null;
         var item:FarmItem = null;
         var cash:Number = NaN;
         var message:String = null;
         var friendRewardArray:Array = FriendRewardsManager.getInstance().getAllFriendRewardByName("WanderingMustangFriendReward");
         for each(friendReward in friendRewardArray)
         {
            if(friendReward)
            {
               if(friendReward.hasExpired() && !friendReward.success())
               {
                  item = Global.farmGameSettingsManager.getFarmItemByName(this.ITEM_NAME_MUSTANG);
                  cash = item.cash - friendReward.getNumHelps() * this.ITEM_COST_MUSTANG;
                  message = ZLocUtils.t("Dialogs","wandering_mustang_buy_now_message",{"quantity":cash});
                  this.onBuyNow(friendReward.id,message);
               }
               else if(!friendReward.hasExpired())
               {
                  this.displayWanderingMustangHudIcon();
               }
               break;
            }
         }
      }
      
      public function showWanderingMustangSuccessPopup(message:String) : void
      {
         var iconURL:String = null;
         var dialog:GenericIconPopup = null;
         var hasWanderingMustangItem:Boolean = Global.player.hasGiftItem(this.ITEM_CODE_MUSTANG);
         if(hasWanderingMustangItem)
         {
            iconURL = Global.getAssetURL("assets/animals/animal_mustang_icon.png");
            dialog = new GenericIconPopup(message,GenericPopup.TYPE_OK,this.onOpenGiftBox,iconURL);
            dialog.setAcceptTextName("Okay");
            UI.displayPopup(dialog);
         }
      }
      
      public function displayWanderingMustangHudIcon() : void
      {
         var extraData:Object = null;
         var friendReward:FriendReward = FriendRewardsManager.getInstance().getFriendRewardByName("WanderingMustangFriendReward");
         if(friendReward)
         {
            extraData = new Object();
            extraData.iconTooltip = ZLocUtils.t("Dialogs",friendReward.getIconToolTip(),[friendReward.getNumHelps(),friendReward.getHelperLimit(),friendReward.getDaysRemaining()]);
            Global.hud.iconQueue.addIcon("WanderingMustang",DynamicIconQueue.ADD_BY_PRIORITY,null,extraData);
         }
      }
      
      public function onOpenGiftBox(event:GenericPopupEvent) : void
      {
         UI.displayGiftBoxWindow();
      }
   }
}

