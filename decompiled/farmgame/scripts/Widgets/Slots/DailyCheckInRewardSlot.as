package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.LoadingManager;
   import Events.GenericPopupEvent;
   import Managers.DailyCheckInManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.DailyCheckInWindow;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.LoaderInfo;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class DailyCheckInRewardSlot extends ZwSlotFrame
   {
      
      private var m_goodieMc:MovieClip;
      
      private var m_rewardMc:FarmIcon;
      
      private var m_goodieRewardMc:ZwWidget;
      
      private var m_redeemBt:FarmAnimatedTextButton;
      
      private var m_goodieCountTf:FarmTextField;
      
      private var m_rewardCountTf:FarmTextField;
      
      private var m_itemCode:String;
      
      private var m_window:DailyCheckInWindow;
      
      public function DailyCheckInRewardSlot(element:DisplayObject, goodieUrl:String, window:DailyCheckInWindow)
      {
         super(element);
         this.m_window = window;
         if(m_element)
         {
            m_element.visible = true;
         }
         if(m_element.hasOwnProperty("candy_reward_mc"))
         {
            this.m_goodieRewardMc = addWidget(new ZwWidget(m_element["candy_reward_mc"]),true) as ZwWidget;
         }
         if(m_element.hasOwnProperty("getreward_bt"))
         {
            this.m_redeemBt = addWidget(new FarmAnimatedTextButton(m_element["getreward_bt"],ZLocUtils.t("Dialogs","DailyCheckIn_RedeemBtn"),this.onRedeemRewardClick),true) as FarmAnimatedTextButton;
         }
         if(m_element.hasOwnProperty("reward_mc"))
         {
            this.m_rewardMc = addWidget(new FarmIcon(m_element["reward_mc"]),true) as FarmIcon;
         }
         if(m_element.hasOwnProperty("rewardcount_tf"))
         {
            this.m_goodieCountTf = addWidget(new FarmTextField(m_element["rewardcount_tf"]),true) as FarmTextField;
         }
         if(m_element.hasOwnProperty("giftcount_tf"))
         {
            this.m_rewardCountTf = addWidget(new FarmTextField(m_element["giftcount_tf"]),true) as FarmTextField;
         }
         if(goodieUrl)
         {
            LoadingManager.load(Global.getAssetURL(goodieUrl),this.onGoodieImgLoaded);
         }
      }
      
      override public function populate(data:Object) : void
      {
         if(data.hasOwnProperty("itemCode"))
         {
            this.m_itemCode = data.itemCode;
         }
         this.update();
      }
      
      private function onRedeemRewardClick(e:Event) : void
      {
         var goodieName:String = null;
         var item:FarmItem = null;
         var goodieCount:int = 0;
         var goodieText:String = null;
         var rewardCount:int = 0;
         var rewardItemText:String = null;
         var msg:String = null;
         if(DailyCheckInManager.getInstance().isInLastChance())
         {
            goodieName = DailyCheckInManager.getInstance().getGoodieName(true);
         }
         else
         {
            goodieName = DailyCheckInManager.getInstance().getGoodieName();
         }
         if(this.m_itemCode)
         {
            item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_itemCode);
            goodieCount = DailyCheckInManager.getInstance().getGoodiesRequiredFor(this.m_itemCode);
            goodieText = goodieCount + " " + goodieName + "s";
            rewardCount = DailyCheckInManager.getInstance().getRewardItemCountFor(this.m_itemCode);
            rewardItemText = rewardCount + "x" + item.friendlyTitle;
            msg = ZLocUtils.t("Dialogs","DailyCheckIn_RedeemConfirmText",{
               "rewardItemName":rewardItemText,
               "goodieRequired":goodieText
            });
            UI.displayMessage(msg,GenericPopup.TYPE_YESNO,this.onRedeemRewardConfirm,"",true,true);
         }
      }
      
      private function onRedeemRewardConfirm(e:GenericPopupEvent) : void
      {
         if(e.button == GenericPopup.YES)
         {
            DailyCheckInManager.getInstance().redeemReward(this.m_itemCode);
            if(this.m_window)
            {
               this.m_window.close();
            }
         }
      }
      
      private function update() : void
      {
         var rewardItem:FarmItem = null;
         this.m_redeemBt.visible = true;
         this.m_rewardMc.visible = true;
         this.m_goodieCountTf.visible = true;
         this.m_goodieRewardMc.visible = true;
         this.m_rewardCountTf.visible = true;
         if(this.m_itemCode)
         {
            this.m_goodieCountTf.text = "x" + DailyCheckInManager.getInstance().getGoodiesRequiredFor(this.m_itemCode).toString();
            this.m_rewardCountTf.text = "x" + DailyCheckInManager.getInstance().getRewardItemCountFor(this.m_itemCode).toString();
            rewardItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_itemCode);
            this.m_rewardMc.loadIcon(rewardItem.iconUrl);
            this.m_rewardMc.setSmoothing(true);
            this.m_redeemBt.enabled = DailyCheckInManager.getInstance().canRedeemReward(this.m_itemCode);
         }
      }
      
      private function onGoodieImgLoaded(e:Event) : void
      {
         var loader:LoaderInfo = null;
         if(Boolean(e) && e.currentTarget is LoaderInfo)
         {
            loader = e.currentTarget as LoaderInfo;
            if(loader.content is MovieClip)
            {
               this.m_goodieMc = loader.content as MovieClip;
               if(this.m_goodieMc)
               {
                  (this.m_goodieMc[DailyCheckInWindow.GOODIE_SMALL] as DisplayObject).visible = true;
                  (this.m_goodieMc[DailyCheckInWindow.GOODIE_MEDIUM] as DisplayObject).visible = false;
                  (this.m_goodieMc[DailyCheckInWindow.GOODIE_LARGE] as DisplayObject).visible = false;
                  if(Boolean(this.m_goodieRewardMc) && Boolean(this.m_goodieRewardMc.element))
                  {
                     (this.m_goodieRewardMc.element as DisplayObjectContainer).addChild(this.m_goodieMc);
                  }
               }
            }
         }
      }
      
      override public function release() : void
      {
         this.m_window = null;
         super.release();
      }
   }
}

