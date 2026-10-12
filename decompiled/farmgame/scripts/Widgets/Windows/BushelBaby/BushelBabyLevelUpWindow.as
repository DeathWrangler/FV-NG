package Widgets.Windows.BushelBaby
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FarmWindow;
   import flash.events.MouseEvent;
   
   public class BushelBabyLevelUpWindow extends FarmWindow
   {
      
      private static const ASSET:String = "assets/dialogs/FV_BushelBabies_levelUp.swf";
      
      private var m_xp:String;
      
      private var m_coins:String;
      
      private var m_onShareCallBack:Function;
      
      private var m_onCloseCallBack:Function;
      
      public function BushelBabyLevelUpWindow(xp:String, coins:String, onShareCallBack:Function, onCloseCallBack:Function)
      {
         this.m_xp = xp;
         this.m_coins = coins;
         this.m_onShareCallBack = onShareCallBack;
         this.m_onCloseCallBack = onCloseCallBack;
         super(ASSET);
      }
      
      public static function display(xp:String, coins:String, onShareCallBack:Function, onCloseCallBack:Function) : BushelBabyLevelUpWindow
      {
         var window:BushelBabyLevelUpWindow = null;
         window = new BushelBabyLevelUpWindow(xp,coins,onShareCallBack,onCloseCallBack);
         UI.displayPopup(window,false,"BushelBabyLevelUpWindow",true);
         return window;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"xrf_hiddenpalace_PostBuildingCompleteTitle")),true);
         addWidget(new ZwTextField(m_window.copy_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"levelUp_Sub_Upgrade")),true);
         addWidget(new ZwTextField(m_window.unlocked_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"worldscore_LevelUpDefault_Header")),true);
         addWidget(new ZwTextField(m_window.coins_tf,this.m_coins),true);
         addWidget(new ZwTextField(m_window.xp_tf,this.m_xp),true);
         addWidget(new FarmAnimatedTextButton(m_window.accept_bt,ZLocUtils.t("FarmGame","Share"),this.onShareButtonClick),true);
      }
      
      public function onCloseButtonClick(event:MouseEvent) : void
      {
         if(m_closeButton)
         {
            this.m_onShareCallBack();
         }
         close();
      }
      
      public function onShareButtonClick(event:MouseEvent) : void
      {
         if(this.m_onShareCallBack != null)
         {
            this.m_onShareCallBack();
         }
         close();
      }
      
      override protected function release() : void
      {
         this.m_xp = null;
         this.m_coins = null;
         this.m_onShareCallBack = null;
         this.m_onCloseCallBack = null;
         super.release();
      }
   }
}

