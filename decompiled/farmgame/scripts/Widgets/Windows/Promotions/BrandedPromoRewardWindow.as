package Widgets.Windows.Promotions
{
   import Classes.util.ZLocUtils;
   import Engine.Managers.SoundManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class BrandedPromoRewardWindow extends FarmWindow
   {
      
      protected const ASSET_URL:String = "assets/dialogs/FV_xpromo_stouffers_end.swf";
      
      private const LOCALIZE_TEXT_PREFIX:String = "PromoFarmReward";
      
      private const REWARD_SOUND:String = "promoFarmPopupSound_";
      
      private const REWARD_POPUP_X_OFFSET_POSTFIX:String = "PromoRewardDialogsOffset_X";
      
      private const REWARD_POPUP_Y_OFFSET_POSTFIX:String = "PromoRewardDialogsOffset_Y";
      
      protected const TITLE_ICON_SIZE:int = 65;
      
      protected const REWARD_ICON_SIZE:int = 50;
      
      protected var m_promoName:String;
      
      protected var m_closeCallback:Function;
      
      protected var m_action:String;
      
      protected var m_textPrefix:String;
      
      public function BrandedPromoRewardWindow(promoName:String, closeCallback:Function, assetPath:String = "assets/dialogs/FV_xpromo_stouffers_end.swf", action:String = null)
      {
         super(assetPath);
         this.m_action = action;
         this.m_promoName = promoName;
         this.m_closeCallback = closeCallback;
      }
      
      override public function getDialogOffset() : Point
      {
         var offset_x:int = Global.farmGameSettingsManager.getInt(this.m_promoName + this.REWARD_POPUP_X_OFFSET_POSTFIX,0);
         var offset_y:int = Global.farmGameSettingsManager.getInt(this.m_promoName + this.REWARD_POPUP_Y_OFFSET_POSTFIX,0);
         return new Point(offset_x,offset_y);
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var soundId:String = null;
         var rewardIcon0:FarmIcon = null;
         var rewardIcon1:FarmIcon = null;
         super.onLoadComplete(event);
         var soundPath:String = Global.farmGameSettingsManager.getString("promoFarmPopupSound_" + this.m_promoName);
         if(Boolean(soundPath) && soundPath != "")
         {
            soundId = "";
            SoundManager.addSound(soundId,Global.getAssetURL(soundPath));
            SoundManager.playSound(soundId);
         }
         this.m_textPrefix = this.getLocalizeTextPrefix() + "_" + this.m_promoName + "_";
         if(m_window.hasOwnProperty("title_tf") && Boolean(m_window.title_tf))
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs",this.m_textPrefix + "title")));
         }
         if(m_window.hasOwnProperty("bullets_tf") && Boolean(m_window.bullets_tf))
         {
            addWidget(new ZwTextField(m_window.bullets_tf,ZLocUtils.t("Dialogs",this.m_textPrefix + "bullets"),true));
         }
         if(m_window.hasOwnProperty("body_tf") && Boolean(m_window.body_tf))
         {
            addWidget(new ZwTextField(m_window.body_tf,ZLocUtils.t("Dialogs",this.m_textPrefix + "body"),ZLocUtils.hasString("Dialogs",this.m_textPrefix + "body")));
         }
         if(m_window.hasOwnProperty("body0_tf") && Boolean(m_window.body0_tf))
         {
            addWidget(new ZwTextField(m_window.body0_tf,ZLocUtils.t("Dialogs",this.m_textPrefix + "body1"),ZLocUtils.hasString("Dialogs",this.m_textPrefix + "body1")));
         }
         if(m_window.hasOwnProperty("body1_tf") && Boolean(m_window.body1_tf))
         {
            addWidget(new ZwTextField(m_window.body1_tf,ZLocUtils.t("Dialogs",this.m_textPrefix + "body2"),ZLocUtils.hasString("Dialogs",this.m_textPrefix + "body2")));
         }
         if(m_window.hasOwnProperty("legal_tf") && Boolean(m_window.legal_tf))
         {
            addWidget(new ZwTextField(m_window.legal_tf,ZLocUtils.t("Dialogs",this.m_textPrefix + "footer"),true));
         }
         if(m_window.hasOwnProperty("iconSlot0_mc") && Boolean(m_window.iconSlot0_mc))
         {
            rewardIcon0 = new FarmIcon(m_window.iconSlot0_mc,Global.farmGameSettingsManager.getString("promoFarmItemIcon0_" + this.m_promoName));
            rewardIcon0.setIconSize(this.REWARD_ICON_SIZE,this.REWARD_ICON_SIZE);
            addWidget(rewardIcon0);
         }
         if(m_window.hasOwnProperty("iconSlot1_mc") && Boolean(m_window.iconSlot1_mc))
         {
            rewardIcon1 = new FarmIcon(m_window.iconSlot1_mc,Global.farmGameSettingsManager.getString("promoFarmItemIcon1_" + this.m_promoName));
            rewardIcon1.setIconSize(this.REWARD_ICON_SIZE,this.REWARD_ICON_SIZE);
            addWidget(rewardIcon1);
         }
         this.setupButtons();
      }
      
      protected function setupButtons() : void
      {
         if(m_window.hasOwnProperty("share_bt") && Boolean(m_window.share_bt))
         {
            addWidget(new FarmAnimatedTextButton(m_window.share_bt,ZLocUtils.t("Dialogs","ShareButton"),this.onAccept));
         }
         if(m_window.hasOwnProperty("stayHere_bt") && Boolean(m_window.stayHere_bt))
         {
            addWidget(new FarmAnimatedTextButton(m_window.stayHere_bt,ZLocUtils.t("Dialogs",this.m_textPrefix + "button"),this.onAccept));
         }
         if(m_window.hasOwnProperty("place_bt") && Boolean(m_window.place_bt))
         {
            addWidget(new FarmAnimatedTextButton(m_window.place_bt,ZLocUtils.t("Dialogs",this.m_textPrefix + "button"),this.onAccept));
         }
         if(m_window.hasOwnProperty("accept_bt") && Boolean(m_window.accept_bt))
         {
            addWidget(new FarmAnimatedTextButton(m_window.accept_bt,ZLocUtils.t("Dialogs",this.m_textPrefix + "button"),this.onAccept));
         }
         if(m_window.hasOwnProperty("cancel_bt") && Boolean(m_window.cancel_bt))
         {
            addWidget(new FarmAnimatedTextButton(m_window.cancel_bt,ZLocUtils.t("Dialogs","NoThanks"),this.onClose));
         }
      }
      
      protected function getLocalizeTextPrefix() : String
      {
         return this.LOCALIZE_TEXT_PREFIX;
      }
      
      protected function onAccept(event:Event) : void
      {
         close();
         if(this.m_closeCallback != null)
         {
            this.m_closeCallback(true,this.m_action);
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         close();
         if(this.m_closeCallback != null)
         {
            this.m_closeCallback(false);
         }
      }
   }
}

