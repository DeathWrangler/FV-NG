package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.MystreeReskinManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Constants.ZwToggleMode;
   import Widgets.Core.Constants.ZwToggleState;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class MystreeReskinCraftWindow extends FarmWindow
   {
      
      private var m_featureName:String = null;
      
      private var m_sunshineCraft:FarmAnimatedTextButton;
      
      private var m_sunshineBuy:FarmAnimatedTextButton;
      
      private var m_titleTf:ZwTextField;
      
      private var m_bodyTf:ZwTextField;
      
      private var m_ask_bt:FarmAnimatedTextButton;
      
      public function MystreeReskinCraftWindow(dialogPath:String, featureName:String)
      {
         this.m_featureName = featureName;
         super(dialogPath);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         var windowName:String = MystreeReskinManager.getInstance(this.m_featureName).getWindowName();
         if(m_window.hasOwnProperty("craftbucket_bt"))
         {
            addWidget(this.m_sunshineCraft = new FarmAnimatedTextButton(m_window.craftbucket_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_CraftButtonText"),this.onSunshineCraftClick),true);
         }
         if(m_window.hasOwnProperty("buybucket_bt"))
         {
            addWidget(this.m_sunshineBuy = new FarmAnimatedTextButton(m_window.buybucket_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_BuyButtonText"),this.onSunshineBuyClick),true);
         }
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(this.m_titleTf = new ZwTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_CraftWindow_title")),true);
         }
         if(m_window.hasOwnProperty("body_tf"))
         {
            addWidget(this.m_bodyTf = new ZwTextField(m_window.body_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_CraftWindow_body")),true);
         }
         if(m_window.askbucket_bt)
         {
            this.m_ask_bt = addWidget(new FarmAnimatedTextButton(m_window.askbucket_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_AskButtonText"),this.onAskClick),true) as FarmAnimatedTextButton;
         }
         var hoursRemaining:int = Math.ceil(MystreeReskinManager.getInstance(this.m_featureName).getTimeUntilPostFeedEnabled() / FarmGameUtil.NUM_SECS_IN_HOUR);
         if(hoursRemaining > 0)
         {
            this.disableAskButton();
         }
      }
      
      private function onAskClick(e:Event = null) : void
      {
         this.m_ask_bt.enabled = false;
         if(MystreeReskinManager.getInstance(this.m_featureName).canPostFeed())
         {
            MystreeReskinManager.getInstance(this.m_featureName).postGeneralFeed(this.handleAskButtonCallback);
            if(this.m_ask_bt)
            {
               this.toggleButton(this.m_ask_bt,false);
            }
         }
      }
      
      private function toggleButton(button:FarmAnimatedButton, to:Boolean) : void
      {
         button.enabled = to;
         button.applyGrayOut = !to;
      }
      
      private function handleAskButtonCallback(shouldDisable:Boolean) : void
      {
         if(this.m_ask_bt)
         {
            if(shouldDisable)
            {
               this.disableAskButton();
            }
            else
            {
               this.toggleButton(this.m_ask_bt,true);
            }
         }
      }
      
      private function disableAskButton() : void
      {
         var hoursRemaining:int = 0;
         if(this.m_ask_bt)
         {
            this.m_ask_bt.enabled = true;
            this.m_ask_bt.setToggleMode(ZwToggleMode.SINGLE_SELECT);
            this.m_ask_bt.setToggleState(ZwToggleState.SELECTED);
            this.m_ask_bt.applyGrayOut = true;
            this.m_ask_bt.element.buttonMode = false;
            hoursRemaining = Math.ceil(MystreeReskinManager.getInstance(this.m_featureName).getTimeUntilPostFeedEnabled() / FarmGameUtil.NUM_SECS_IN_HOUR);
            this.m_ask_bt.attachTooltip(new FarmTextTooltip(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Growable_ConsumableAskWithTimer",{"timeLeft":hoursRemaining})));
         }
      }
      
      private function onSunshineCraftClick(event:MouseEvent) : void
      {
         MystreeReskinManager.getInstance(this.m_featureName).showCraftingWindowWithItem();
         close();
      }
      
      private function onSunshineBuyClick(event:MouseEvent) : void
      {
         var m_sunshineBuyWindow:MystreeReskinBuyWindow = new MystreeReskinBuyWindow(MystreeReskinManager.getInstance(this.m_featureName).getByDialogURL(),this.m_featureName);
         UI.displayPopup(m_sunshineBuyWindow,true,"",true);
         close();
      }
      
      override protected function release() : void
      {
         this.m_sunshineCraft = null;
         this.m_sunshineBuy = null;
         this.m_titleTf = null;
         this.m_bodyTf = null;
         if(this.m_ask_bt)
         {
            this.m_ask_bt = null;
         }
         super.release();
      }
   }
}

