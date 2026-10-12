package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Display.HUD.HUD;
   import Managers.IsraelInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.GenericSingleRewardPopup;
   import Widgets.Windows.IsraelInnovationRewardsMarketWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class IsraelInnovationRewardsMarketSlot extends ZwSlotFrame
   {
      
      private var m_featureName:String;
      
      private var m_data:Object;
      
      private var m_window:IsraelInnovationRewardsMarketWindow;
      
      private var m_rewardPopup:GenericSingleRewardPopup;
      
      private var m_iconMc:MovieClip;
      
      private var m_countTf:ZwTextField;
      
      private var m_overlayMc:MovieClip;
      
      private var m_messageTf:ZwTextField;
      
      private var m_item:FarmItem;
      
      private var m_itemBox:FarmIcon;
      
      private var m_redeemBt:FarmAnimatedTextButton;
      
      private var m_marketRewardsData:Object;
      
      private const MAX_REWARDS_ALLOWED:int = 5;
      
      private const REDEEMED_ALL_REWARDS:String = "You\'ve redeemed all the rewards";
      
      private const WAIT_FOR_NEXTWEEK:String = "New reward appears next week";
      
      private const FARMOFF_CHIPS:String = "xis_farmoffchip";
      
      private const REWARD_SHARE_WINDOW:String = "assets/dialogs/expansion/FV_RewardDialog_Share.swf";
      
      private const REWARD_WINDOW_IMAGE:String = "assets/dialogs/israel/RewardDialog.png";
      
      private var m_quantityTf:ZwTextField;
      
      public function IsraelInnovationRewardsMarketSlot(featureName:String, element:DisplayObject, window:IsraelInnovationRewardsMarketWindow)
      {
         this.m_featureName = featureName;
         this.m_window = window;
         super(element);
         if(m_element.hasOwnProperty("icon_mc"))
         {
            this.m_iconMc = m_element.icon_mc as MovieClip;
         }
         if(m_element.hasOwnProperty("count_tf"))
         {
            this.m_countTf = new ZwTextField(m_element["count_tf"],"Count_tf");
         }
         if(m_element.hasOwnProperty("overlay_mc"))
         {
            this.m_overlayMc = m_element.overlay_mc as MovieClip;
         }
         if(m_element.hasOwnProperty("message_tf"))
         {
            addWidget(this.m_messageTf = new ZwTextField(m_element["message_tf"],"Message_tf"));
         }
         if(m_element.hasOwnProperty("quantity_tf"))
         {
            addWidget(this.m_quantityTf = new ZwTextField(m_element["quantity_tf"],"Quantity_tf"));
         }
         if(m_element.hasOwnProperty("redeem_bt"))
         {
            addWidget(this.m_redeemBt = new FarmAnimatedTextButton(m_element["redeem_bt"],"Redeem",this.onClickRedeemButton));
            this.m_redeemBt.visible = true;
            this.m_redeemBt.enabled = false;
         }
         addWidget(this.m_itemBox = new FarmIcon(this.m_iconMc));
         addWidget(this.m_countTf = new ZwTextField(m_element["count_tf"],""));
      }
      
      public function closePopup() : void
      {
         if(this.m_rewardPopup)
         {
            this.m_rewardPopup.close();
         }
      }
      
      private function onClickRedeemButton(evt:Event) : void
      {
         this.m_redeemBt.enabled = false;
         var featureKey:String = this.m_featureName + "_RewardPopup_";
         if(this.manager.chipCount >= parseInt(this.m_countTf.text))
         {
            this.manager.redeemRewardForSlot(this.m_data["slotNumber"],this.m_countTf.text,this.m_item);
         }
      }
      
      override public function populate(data:Object) : void
      {
         var slotNo:int = 0;
         var buyCountForSlot:int = 0;
         var itemCode:String = null;
         var item:FarmItem = null;
         var cash:int = 0;
         var iconUrl:String = null;
         var timeLeftInWeek:Number = NaN;
         super.populate(data);
         this.m_data = data;
         slotNo = int(this.m_data["slotNumber"]);
         buyCountForSlot = this.manager.getBuyCountForSlot(slotNo);
         if(this.manager.canPopulateSlot(slotNo))
         {
            itemCode = this.manager.getRewardForSlot(buyCountForSlot,slotNo);
            item = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
            this.m_item = item;
            if(this.m_itemBox)
            {
               iconUrl = item.getImageByName(FarmItem.ICON_FEED);
               this.m_itemBox.setIconSize(100,100);
               this.m_itemBox.loadIcon(iconUrl);
               this.m_itemBox.visible = true;
            }
            this.m_itemBox.attachTooltip(new FarmTextTooltip(item.friendlyTitle));
            this.m_marketRewardsData = this.manager.getMarketRewardsData();
            cash = this.manager.getCashForSlot(buyCountForSlot,slotNo);
            this.m_countTf.text = cash.toString();
            this.m_countTf.visible = true;
            this.m_redeemBt.visible = true;
            if(this.manager.chipCount >= parseInt(this.m_countTf.text))
            {
               this.m_redeemBt.enabled = true;
            }
            else
            {
               this.m_redeemBt.enabled = false;
            }
            this.m_messageTf.visible = false;
            this.m_quantityTf.text = "x" + this.manager.getQuantityForSlot(buyCountForSlot,slotNo).toString();
            this.m_quantityTf.visible = true;
         }
         else if(buyCountForSlot == this.MAX_REWARDS_ALLOWED)
         {
            this.m_overlayMc.visible = true;
            this.m_redeemBt.visible = false;
            this.m_messageTf.text = "You’ve redeemed all rewards";
            this.m_messageTf.visible = true;
            this.m_countTf.visible = false;
            this.m_quantityTf.visible = false;
         }
         else
         {
            timeLeftInWeek = this.manager.getTimeLeftInWeek();
            this.m_overlayMc.visible = true;
            this.m_redeemBt.visible = false;
            this.m_redeemBt.enabled = false;
            this.m_messageTf.text = "New goodie appears in " + HUD.getformattedTimeLeft(timeLeftInWeek);
            this.m_messageTf.visible = true;
            cash = this.manager.getCashForSlot(buyCountForSlot,slotNo);
            this.m_countTf.text = cash.toString();
            this.m_countTf.visible = true;
            itemCode = this.manager.getRewardForSlot(buyCountForSlot,slotNo);
            item = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
            this.m_item = item;
            if(this.m_itemBox)
            {
               iconUrl = item.getImageByName(FarmItem.ICON_FEED);
               this.m_itemBox.setIconSize(100,100);
               this.m_itemBox.loadIcon(iconUrl);
               this.m_itemBox.visible = true;
            }
            this.m_quantityTf.text = this.manager.getQuantityForSlot(buyCountForSlot,slotNo).toString();
            this.m_quantityTf.visible = true;
         }
      }
      
      private function get manager() : IsraelInnovationManager
      {
         return IsraelInnovationManager.getInstance(this.m_featureName);
      }
   }
}

