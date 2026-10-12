package Widgets.Windows
{
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.CapitalOnePromoManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.Promotions.CapitalOnePromoWindow;
   import flash.events.Event;
   import flash.text.TextFormat;
   
   public class CapitalOneIntroToasterWindow extends AutoCloseToasterWindow
   {
      
      private static const TIME_TO_LIVE:Number = 10000;
      
      private static const TOASTER_MAIN_TEXT_SIZE:Number = 13;
      
      private static const TOASTER_SECONDARY_TEXT_SIZE:Number = 10;
      
      private var m_accepted:Boolean = false;
      
      public function CapitalOneIntroToasterWindow()
      {
         super(CapitalOnePromoManager.TOASTER_ASSET_PATH,TIME_TO_LIVE);
      }
      
      override protected function postLoadComplete() : void
      {
         var moreButtonText:ZwTextField = null;
         var toasterBodyText:ZwTextField = null;
         var textFormat:TextFormat = null;
         super.postLoadComplete();
         if(m_window)
         {
            moreButtonText = new ZwTextField(m_window.more_bt.generic_tf,ZLocUtils.t("Dialogs","FindOutMore"),true);
            addWidget(new FarmAnimatedButton(m_window.more_bt,this.onAccept));
            toasterBodyText = new ZwTextField(m_window.generic_0_tf,ZLocUtils.t("Dialogs","CapitalOneToasterText"),true);
            textFormat = toasterBodyText.getTextFormat();
            textFormat.size = TOASTER_MAIN_TEXT_SIZE;
            toasterBodyText.setTextFormat(textFormat);
            addWidget(toasterBodyText);
            if(Boolean(m_window.generic_1_tf) && Boolean(m_window.generic_1_tf.visible))
            {
               m_window.generic_1_tf.visible = false;
            }
         }
      }
      
      override public function show() : void
      {
         CapitalOnePromoManager.countPromoToasterImpression();
         Global.player.setSeenFlag(CapitalOnePromoManager.TOASTER_SEEN);
         super.show();
      }
      
      private function onAccept(event:Event) : void
      {
         UI.displayPopup(new CapitalOnePromoWindow(),false);
         CapitalOnePromoManager.countPromoToasterClick();
         this.m_accepted = true;
         super.onClose(event);
      }
      
      override protected function onClose(event:Event) : void
      {
         if(!this.m_accepted)
         {
            CapitalOnePromoManager.countPromoToasterClose();
         }
         super.onClose(event);
      }
   }
}

