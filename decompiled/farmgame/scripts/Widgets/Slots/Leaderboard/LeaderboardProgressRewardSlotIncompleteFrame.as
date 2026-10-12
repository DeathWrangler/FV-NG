package Widgets.Slots.Leaderboard
{
   import Classes.Constants.QuestConstants;
   import Classes.Leaderboard.Leaderboard;
   import Classes.Leaderboard.LeaderboardState;
   import Classes.ZItem.FarmItem;
   import Classes.util.UserRewardUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.LeaderboardManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public final class LeaderboardProgressRewardSlotIncompleteFrame extends ZwFrame
   {
      
      private static const ICON_SIZE:int = 50;
      
      private var m_data:Object;
      
      private var m_icon:FarmIcon;
      
      private var m_discountTextField:ZwTextField;
      
      private var m_oneTimeOnlyTextField:ZwTextField;
      
      private var m_quantityTextField:ZwTextField;
      
      private var m_thresholdTextField:ZwTextField;
      
      private var m_buyButton:FarmAnimatedTextButton;
      
      private var m_buyPrice:int;
      
      public function LeaderboardProgressRewardSlotIncompleteFrame(element:DisplayObject)
      {
         super(element);
         this.m_icon = addWidget(new FarmIcon(m_element.rewardIcon_mc)) as FarmIcon;
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_icon.setSmoothing(true);
         this.m_oneTimeOnlyTextField = addWidget(new ZwTextField(m_element.oneTime_tf,ZLocUtils.t("Leaderboard","LeaderboardSummaryWindow_OneTimeOnly"))) as ZwTextField;
         this.m_discountTextField = addWidget(new ZwTextField(m_element.discountAmount_tf,"")) as ZwTextField;
         addWidget(new ZwTextField(m_element.numberTitle_mc,ZLocUtils.t("Leaderboard","ScoreNeeded")));
         this.m_quantityTextField = addWidget(new ZwTextField(m_element.qty_tf,"")) as ZwTextField;
         this.m_thresholdTextField = addWidget(new ZwTextField(m_element.number_tf,"")) as ZwTextField;
         this.m_buyButton = addWidget(new FarmAnimatedTextButton(m_element.buy_bt,"",this.onBuyButtonClick)) as FarmAnimatedTextButton;
      }
      
      override public function release() : void
      {
         this.m_buyButton = null;
         this.m_discountTextField = null;
         this.m_icon = null;
         this.m_oneTimeOnlyTextField = null;
         this.m_quantityTextField = null;
         this.m_thresholdTextField = null;
         super.release();
      }
      
      public function populate(data:Object) : void
      {
         var leaderboard:Leaderboard = null;
         var discountPercentage:Number = NaN;
         var threshold:int = 0;
         var type:String = null;
         var userState:LeaderboardState = null;
         var index:int = 0;
         var itemCode:String = null;
         var item:FarmItem = null;
         var basePrice:int = 0;
         var quantity:int = 0;
         this.m_data = data;
         if(this.m_data)
         {
            leaderboard = LeaderboardManager.getLeaderboardForWidget(this);
            if(leaderboard)
            {
               discountPercentage = LeaderboardManager.getProgressRewardDiscountPercentage(leaderboard.name);
               this.m_icon.loadIcon(UserRewardUtil.getImageForReward(this.m_data));
               this.m_quantityTextField.text = UserRewardUtil.getValueForReward(this.m_data);
               threshold = int(this.m_data["threshold"]);
               this.m_thresholdTextField.text = String(threshold);
               type = this.m_data["type"] as String;
               if(type == QuestConstants.REWARD_GRANT_ITEM)
               {
                  itemCode = this.m_data["value"] as String;
                  item = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
                  if(item)
                  {
                     basePrice = int(this.m_data["cash"]);
                     if(basePrice > 0)
                     {
                        quantity = this.m_data.hasOwnProperty("quantity") ? int(this.m_data["quantity"]) : 1;
                        this.m_buyPrice = Math.floor(basePrice * (1 - discountPercentage));
                     }
                  }
               }
               userState = Global.player.getLeaderboardState(leaderboard.name);
               index = leaderboard.getIndexForProgressReward(this.m_data);
               if(Boolean(this.m_buyPrice > 0 && discountPercentage > 0) && Boolean(userState) && !userState.hasProgressReward(index))
               {
                  this.m_buyButton.text = ZLocUtils.t("Leaderboard","LeaderboardSummaryWindow_BuyButton",{"cash":this.m_buyPrice});
                  this.m_buyButton.visible = true;
                  this.m_discountTextField.text = ZLocUtils.t("Leaderboard","LeaderboardSummaryWindow_Discount",{"discount":discountPercentage * 100});
                  this.m_discountTextField.visible = true;
                  this.m_oneTimeOnlyTextField.visible = true;
                  this.m_buyButton.enabled = true;
               }
               else
               {
                  this.m_buyButton.visible = false;
                  this.m_discountTextField.visible = false;
                  this.m_oneTimeOnlyTextField.visible = false;
               }
            }
         }
      }
      
      private function onBuyButtonClick(event:MouseEvent) : void
      {
         if(this.m_buyButton.enabled)
         {
            if(this.buyProgressReward())
            {
               this.m_buyButton.enabled = false;
            }
         }
      }
      
      private function buyProgressReward() : Boolean
      {
         var leaderboard:Leaderboard = null;
         var index:int = 0;
         var userState:LeaderboardState = null;
         var itemCode:String = null;
         var itemName:String = null;
         var quantity:int = 0;
         var result:Boolean = false;
         if(this.m_buyPrice > 0 && Global.player.canBuyCash(this.m_buyPrice,true))
         {
            leaderboard = LeaderboardManager.getLeaderboardForWidget(this);
            if(leaderboard)
            {
               index = leaderboard.getIndexForProgressReward(this.m_data);
               if(index >= 0)
               {
                  TransactionManager.addTransaction(new TGenericTransaction("LeaderboardService","buyProgressReward",this.buyProgressRewardTransactionCallback,[leaderboard.name,index]),true);
                  userState = Global.player.getLeaderboardState(leaderboard.name);
                  if(userState)
                  {
                     userState.setProgressReward(index);
                  }
                  Global.player.cash -= this.m_buyPrice;
                  itemCode = this.m_data["value"] as String;
                  itemName = Global.farmGameSettingsManager.getFarmItemNameByCode(itemCode);
                  quantity = this.m_data.hasOwnProperty("quantity") ? int(this.m_data["quantity"]) : 1;
                  Global.player.addGift(itemName,"0",quantity);
                  result = true;
               }
            }
         }
         return result;
      }
      
      private function buyProgressRewardTransactionCallback(result:Object) : void
      {
      }
   }
}

