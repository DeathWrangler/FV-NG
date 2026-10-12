package Widgets.Windows.Promotions
{
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class BrandedPromoHelpWindow extends FarmWindow
   {
      
      protected const ASSET_URL:String = "assets/dialogs/FV_xpromo_stouffers_start.swf";
      
      private const LOCALIZE_TEXT_PREFIX:String = "PromoFarmHelp";
      
      protected const TITLE_ICON_SIZE:int = 65;
      
      protected const REWARD_ICON_SIZE:int = 50;
      
      private const HELP_POPUP_X_OFFSET_POSTFIX:String = "PromoDialogsDelayOffset_X";
      
      private const HELP_POPUP_Y_OFFSET_POSTFIX:String = "PromoDialogsDelayOffset_Y";
      
      protected var m_promoName:String;
      
      protected var m_closeCallback:Function;
      
      protected var m_textPrefix:String;
      
      public function BrandedPromoHelpWindow(promoName:String, closeCallback:Function, assetPath:String = "assets/dialogs/FV_xpromo_stouffers_start.swf")
      {
         super(assetPath);
         this.m_promoName = promoName;
         this.m_closeCallback = closeCallback;
      }
      
      override public function getDialogOffset() : Point
      {
         var offset_x:int = Global.farmGameSettingsManager.getInt(this.m_promoName + this.HELP_POPUP_X_OFFSET_POSTFIX,0);
         var offset_y:int = Global.farmGameSettingsManager.getInt(this.m_promoName + this.HELP_POPUP_Y_OFFSET_POSTFIX,0);
         return new Point(offset_x,offset_y);
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var rewardIcon0:FarmIcon = null;
         var rewardIcon1:FarmIcon = null;
         super.onLoadComplete(event);
         this.m_textPrefix = this.getLocalizeTextPrefix() + "_" + this.m_promoName + "_";
         if(m_window.hasOwnProperty("title_tf") && Boolean(m_window.title_tf))
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs",this.m_textPrefix + "title")));
         }
         if(m_window.hasOwnProperty("body_tf") && Boolean(m_window.body_tf))
         {
            addWidget(new ZwTextField(m_window.body_tf,ZLocUtils.t("Dialogs",this.m_textPrefix + "body"),true));
         }
         if(m_window.hasOwnProperty("body0_tf") && Boolean(m_window.body0_tf))
         {
            addWidget(new ZwTextField(m_window.body0_tf,ZLocUtils.t("Dialogs",this.m_textPrefix + "body"),true));
         }
         if(m_window.hasOwnProperty("body1_tf") && Boolean(m_window.body1_tf))
         {
            addWidget(new ZwTextField(m_window.body1_tf,ZLocUtils.t("Dialogs",this.m_textPrefix + "body1"),true));
         }
         if(m_window.hasOwnProperty("legal_tf") && Boolean(m_window.legal_tf))
         {
            addWidget(new ZwTextField(m_window.legal_tf,ZLocUtils.t("Dialogs",this.m_textPrefix + "footer"),ZLocUtils.hasString("Dialogs",this.m_textPrefix + "footer")));
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
         if(m_window.hasOwnProperty("stayHere_bt") && Boolean(m_window.stayHere_bt))
         {
            addWidget(new FarmAnimatedTextButton(m_window.stayHere_bt,ZLocUtils.t("Dialogs",this.m_textPrefix + "button"),this.onAccept));
         }
         if(m_window.hasOwnProperty("accept_bt") && Boolean(m_window.accept_bt))
         {
            addWidget(new FarmAnimatedTextButton(m_window.accept_bt,ZLocUtils.t("Dialogs",this.m_textPrefix + "button"),this.onAccept));
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
            this.m_closeCallback(true);
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

