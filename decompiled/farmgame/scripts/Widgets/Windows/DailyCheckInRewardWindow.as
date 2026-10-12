package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.DailyCheckInManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import flash.events.Event;
   
   public class DailyCheckInRewardWindow extends FarmWindow
   {
      
      private var m_isBonusRewardPopup:Boolean;
      
      private var m_acceptBt:FarmAnimatedTextButton;
      
      private var m_bagMc:ZwWidget;
      
      private var m_titleTf:FarmTextField;
      
      private var m_subtitleTf:FarmTextField;
      
      private var m_bonusDescTf:FarmTextField;
      
      private var m_extraTf:FarmTextField;
      
      private var m_iconMc:FarmIcon;
      
      private var m_rewardCountTf:FarmTextField;
      
      private var m_rewardItemName:String;
      
      private var m_closeCallback:Function;
      
      public function DailyCheckInRewardWindow(dialogUrl:String, isBonusRewardPopup:Boolean, rewardItemName:String, closeCallback:Function = null)
      {
         super(dialogUrl);
         this.m_isBonusRewardPopup = isBonusRewardPopup;
         this.m_rewardItemName = rewardItemName;
         this.m_closeCallback = closeCallback;
      }
      
      override protected function postLoadComplete() : void
      {
         var item:FarmItem = null;
         var iconUrl:String = null;
         var itemCode:String = null;
         var goodieRequired:int = 0;
         var rewardCount:int = 0;
         var rewardText:String = null;
         var goodieText:String = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty("accept_bt"))
         {
            this.m_acceptBt = addWidget(new FarmAnimatedTextButton(m_window["accept_bt"],"",this.onAcceptClick),true) as FarmAnimatedTextButton;
         }
         if(m_window.hasOwnProperty("bag_mc"))
         {
            this.m_bagMc = addWidget(new ZwWidget(m_window["bag_mc"]),!this.m_isBonusRewardPopup) as ZwWidget;
         }
         if(m_window.hasOwnProperty("title_tf"))
         {
            this.m_titleTf = addWidget(new FarmTextField(m_window["title_tf"],ZLocUtils.t("Dialogs","DailyCheckIn_RewardTitle")),true) as FarmTextField;
         }
         if(m_window.hasOwnProperty("generic2_tf"))
         {
            this.m_subtitleTf = addWidget(new FarmTextField(m_window["generic2_tf"]),true) as FarmTextField;
         }
         if(m_window.hasOwnProperty("generic3_tf"))
         {
            this.m_bonusDescTf = addWidget(new FarmTextField(m_window["generic3_tf"]),this.m_isBonusRewardPopup) as FarmTextField;
         }
         if(m_window.hasOwnProperty("generic4_tf"))
         {
            this.m_extraTf = addWidget(new FarmTextField(m_window["generic4_tf"],"It is in your giftbox"),true) as FarmTextField;
         }
         if(m_window.hasOwnProperty("giftcount_tf"))
         {
            this.m_rewardCountTf = addWidget(new FarmTextField(m_window["giftcount_tf"]),!this.m_isBonusRewardPopup) as FarmTextField;
         }
         item = Global.farmGameSettingsManager.getFarmItemByName(this.m_rewardItemName);
         if(this.m_isBonusRewardPopup)
         {
            iconUrl = item.getImageByName("feed");
            if(m_window.hasOwnProperty("opf_mc"))
            {
               this.m_iconMc = addWidget(new FarmIcon(m_window["opf_mc"],iconUrl),true) as FarmIcon;
               this.m_iconMc.setSmoothing(true);
            }
         }
         else
         {
            iconUrl = item.icon;
            if(m_window.hasOwnProperty("opf_mc_1"))
            {
               this.m_iconMc = addWidget(new FarmIcon(m_window["opf_mc_1"],iconUrl),true) as FarmIcon;
               this.m_iconMc.setSmoothing(true);
            }
         }
         var goodieName:String = DailyCheckInManager.getInstance().getGoodieName();
         if(this.m_isBonusRewardPopup)
         {
            this.m_acceptBt.text = ZLocUtils.t("Dialogs","DailyCheckIn_BonusRewardBtnText");
            this.m_bonusDescTf.text = ZLocUtils.t("Dialogs","DailyCheckIn_BonusRewardDescText",{"goodieName":goodieName});
            this.m_subtitleTf.text = "You have received a " + item.friendlyTitle + " for collecting all 7 " + goodieName;
         }
         else
         {
            this.m_acceptBt.text = ZLocUtils.t("Dialogs","DailyCheckIn_RewardBtnText");
            itemCode = Global.farmGameSettingsManager.getFarmItemCodeByName(this.m_rewardItemName);
            goodieRequired = DailyCheckInManager.getInstance().getGoodiesRequiredFor(itemCode);
            rewardCount = DailyCheckInManager.getInstance().getRewardItemCountFor(itemCode);
            rewardText = rewardCount + "x" + item.friendlyTitle + "s";
            goodieText = goodieRequired + " " + goodieName + "s";
            this.m_subtitleTf.text = ZLocUtils.t("Dialogs","DailyCheckIn_RewardDescText",{
               "rewardCountText":rewardText,
               "goodieRequiredText":goodieText
            });
            this.m_rewardCountTf.text = "x" + DailyCheckInManager.getInstance().getRewardItemCountFor(itemCode).toString();
         }
      }
      
      private function onAcceptClick(e:Event) : void
      {
         if(this.m_closeCallback != null)
         {
            this.m_closeCallback();
         }
         close();
      }
      
      override protected function onClose(event:Event) : void
      {
         if(this.m_closeCallback != null)
         {
            this.m_closeCallback();
         }
         close();
      }
   }
}

