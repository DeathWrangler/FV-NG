package Widgets.Frames
{
   import Classes.util.ZLocUtils;
   import Engine.Managers.LoadingManager;
   import Managers.DailyCheckInManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.DailyCheckInWindow;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.LoaderInfo;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class DailyCheckInLastChanceFrame extends ZwFrame
   {
      
      private var m_goodieMc:MovieClip;
      
      private var m_candyCountMc:ZwWidget;
      
      private var m_candyCountTf:FarmTextField;
      
      private var m_titleTf:FarmTextField;
      
      private var m_subTitleTf:FarmTextField;
      
      private var m_rewardsFrame:DailyCheckInRewardFrame;
      
      private var m_hintTf:FarmTextField;
      
      private var m_closeBt:FarmAnimatedButton;
      
      private var m_window:DailyCheckInWindow;
      
      public function DailyCheckInLastChanceFrame(element:DisplayObject, goodieUrl:String, window:DailyCheckInWindow)
      {
         var rewards:Array = null;
         super(element);
         this.m_window = window;
         if(m_element.hasOwnProperty("candyleft_mc"))
         {
            this.m_candyCountMc = addWidget(new ZwWidget(m_element["candyleft_mc"]),true) as ZwWidget;
         }
         if(m_element.hasOwnProperty("goodycount_tf"))
         {
            this.m_candyCountTf = addWidget(new FarmTextField(m_element["goodycount_tf"]),true) as FarmTextField;
         }
         if(m_element.hasOwnProperty("claimreward_mc"))
         {
            rewards = DailyCheckInManager.getInstance().getLastChanceRewards();
            this.m_rewardsFrame = addWidget(new DailyCheckInRewardFrame(m_element["claimreward_mc"],goodieUrl,rewards,this.m_window),true) as DailyCheckInRewardFrame;
         }
         if(m_element.hasOwnProperty("title2_tf"))
         {
            this.m_titleTf = addWidget(new FarmTextField(m_element["title2_tf"],ZLocUtils.t("Dialogs","DailyCheckIn_LastChanceTitle")),true) as FarmTextField;
         }
         if(m_element.hasOwnProperty("subtitle3_tf"))
         {
            this.m_subTitleTf = addWidget(new FarmTextField(m_element["subtitle3_tf"]),true) as FarmTextField;
         }
         if(m_element.hasOwnProperty("hint_tf"))
         {
            this.m_hintTf = addWidget(new FarmTextField(m_element["hint_tf"]),true) as FarmTextField;
         }
         if(m_element.hasOwnProperty("close_bt"))
         {
            this.m_closeBt = addWidget(new FarmAnimatedButton(m_element["close_bt"],this.onLastChanceClose),true) as FarmAnimatedButton;
         }
         var newGoodieName:String = DailyCheckInManager.getInstance().getGoodieName(false,true);
         var oldGoodieName:String = DailyCheckInManager.getInstance().getGoodieName(true);
         var goodieCount:String = DailyCheckInManager.getInstance().currentGoodieCount.toString();
         var oldGoodieText:String = goodieCount + " " + oldGoodieName + "s";
         this.m_subTitleTf.text = ZLocUtils.t("Dialogs","DailyCheckIn_LastChanceSubTitle",{
            "newGoodieName":newGoodieName,
            "oldGoodieText":oldGoodieText
         });
         this.m_hintTf.text = ZLocUtils.t("Dialogs","DailyCheckIn_LastChanceHint",{"newGoodieName":newGoodieName});
         this.m_candyCountTf.text = "x" + DailyCheckInManager.getInstance().currentGoodieCount.toString();
         if(goodieUrl)
         {
            LoadingManager.load(Global.getAssetURL(goodieUrl),this.onGoodieImgLoaded);
         }
      }
      
      private function onLastChanceClose(e:Event) : void
      {
         DailyCheckInManager.getInstance().resetLastChance();
         DailyCheckInManager.getInstance().initFeatureOptions();
         this.m_window.refreshUi();
         visible = false;
      }
      
      private function onGoodieImgLoaded(e:Event) : void
      {
         var loader:LoaderInfo = e.currentTarget as LoaderInfo;
         this.m_goodieMc = loader.content as MovieClip;
         (this.m_goodieMc[DailyCheckInWindow.GOODIE_SMALL] as DisplayObject).visible = false;
         (this.m_goodieMc[DailyCheckInWindow.GOODIE_MEDIUM] as DisplayObject).visible = false;
         (this.m_goodieMc[DailyCheckInWindow.GOODIE_LARGE] as DisplayObject).visible = true;
         (this.m_candyCountMc.element as DisplayObjectContainer).addChild(this.m_goodieMc);
      }
      
      override public function release() : void
      {
         this.m_window = null;
         super.release();
      }
   }
}

