package Widgets.Windows.Subscriptions
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Events.SubscriptionsEvent;
   import Managers.SubscriptionsItemDropManager;
   import Managers.SubscriptionsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.utils.setTimeout;
   
   public class SubscriptionsLevelUp extends FarmWindow
   {
      
      private static const ASSET_NAME:String = "assets/dialogs/Subscriptions/FV_SubscriptionRevamp_congratulations_v2.swf";
      
      private var m_okButton:FarmAnimatedTextButton;
      
      private var m_callBack:Function;
      
      private var m_toLevel:int;
      
      private var m_transitionBG:ZwBaseWidget;
      
      public function SubscriptionsLevelUp(dialogAsset:String, callBack:Function = null, toLevel:int = 0)
      {
         super(dialogAsset);
         this.m_callBack = callBack;
         this.m_toLevel = toLevel;
      }
      
      public static function display(callBack:Function = null, toLevel:int = 0) : void
      {
         var popUp:SubscriptionsLevelUp = null;
         popUp = new SubscriptionsLevelUp(ASSET_NAME,callBack,toLevel);
         UI.displayPopup(popUp);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(this.m_okButton = new FarmAnimatedTextButton(m_window.yes_btn,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Awesome"),this.onOkButtonClicked),true);
         addWidget(new FarmTextField(m_window.title_tf,"CONGRATULATIONS"),true);
         addWidget(new FarmTextField(m_window.subtitle_tf,this.getSubtitleText()),true);
         addWidget(new FarmTextField(m_window.body_tf,this.getBodyText()),false);
         this.prepareUnicornDropContainer();
         setTimeout(this.addTransitionBG,500);
      }
      
      private function prepareUnicornDropContainer() : void
      {
         var unicornManager:SubscriptionsItemDropManager = null;
         var unicornCode:String = null;
         if(m_window.newUnicorn_mc)
         {
            if(this.m_toLevel == SubscriptionsManager.LEVEL_DIAMOND)
            {
               unicornManager = SubscriptionsItemDropManager.getInstance();
               if(unicornManager.eligibleToClaim())
               {
                  unicornCode = unicornManager.getCurrentDropItemName();
                  if(unicornCode)
                  {
                     addWidget(new SubscriptionUnicornDropContainer(m_window.newUnicorn_mc,unicornCode));
                  }
               }
            }
            else
            {
               m_window.newUnicorn_mc.visible = false;
            }
         }
      }
      
      private function addTransitionBG() : void
      {
         var mcName:String = "";
         switch(this.m_toLevel)
         {
            case SubscriptionsManager.LEVEL_SILVER:
               mcName = "bg_mc_0";
               break;
            case SubscriptionsManager.LEVEL_GOLD:
               mcName = "bg_mc_1";
               break;
            case SubscriptionsManager.LEVEL_RUBY:
               mcName = "bg_mc_2";
               break;
            case SubscriptionsManager.LEVEL_DIAMOND:
               mcName = "bg_mc_3";
         }
         if(mcName != "")
         {
            this.m_transitionBG = (addWidget(new ZwFrame(m_window.background_mc),true) as ZwFrame).addWidget(new ZwBaseWidget(m_window.background_mc[mcName]),true);
            (this.m_transitionBG.element as MovieClip).play();
         }
      }
      
      private function onOkButtonClicked(event:Event) : void
      {
         if(this.m_callBack != null)
         {
            this.m_callBack();
         }
         super.onClose(event);
         SubscriptionsManager.instance.dispatchEvent(new SubscriptionsEvent(SubscriptionsManager.SHOW_BENEFITS_POPUP,{"source":"level_up_popup"}));
      }
      
      override protected function release() : void
      {
         if(Boolean(this.m_transitionBG) && this.m_transitionBG.element as MovieClip != null)
         {
            (this.m_transitionBG.element as MovieClip).stop();
         }
         this.m_transitionBG = null;
         this.m_callBack = null;
         this.m_okButton = null;
         super.release();
      }
      
      private function getSubtitleText() : String
      {
         var text:String = "";
         if(this.m_toLevel == SubscriptionsManager.LEVEL_DIAMOND)
         {
            text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subsRet_levelup_subtitle_diamond");
         }
         else if(this.m_toLevel == SubscriptionsManager.LEVEL_RUBY)
         {
            text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subsRet_levelup_subtitle_ruby");
         }
         else if(this.m_toLevel == SubscriptionsManager.LEVEL_GOLD)
         {
            text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subsRet_levelup_subtitle_gold");
         }
         else if(this.m_toLevel == SubscriptionsManager.LEVEL_SILVER)
         {
            text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subsRet_levelup_subtitle_silver");
         }
         else if(this.m_toLevel == SubscriptionsManager.LEVEL_BRONZE)
         {
            text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subsRet_levelup_subtitle_bronze");
         }
         return text;
      }
      
      private function getBodyText() : String
      {
         var text:String = "";
         if(this.m_toLevel == SubscriptionsManager.LEVEL_DIAMOND)
         {
            text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subsRet_levelup_body_diamond");
         }
         else if(this.m_toLevel == SubscriptionsManager.LEVEL_RUBY)
         {
            text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subsRet_levelup_body_ruby");
         }
         else if(this.m_toLevel == SubscriptionsManager.LEVEL_GOLD)
         {
            text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subsRet_levelup_body_gold");
         }
         else if(this.m_toLevel == SubscriptionsManager.LEVEL_SILVER)
         {
            text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subsRet_levelup_body_silver");
         }
         else if(this.m_toLevel == SubscriptionsManager.LEVEL_BRONZE)
         {
            text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"subsRet_levelup_body_bronze");
         }
         return text;
      }
   }
}

