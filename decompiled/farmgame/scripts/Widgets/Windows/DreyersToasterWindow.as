package Widgets.Windows
{
   import Display.UI;
   import Managers.DreyersPromoManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   import flash.text.TextFormat;
   
   public class DreyersToasterWindow extends AutoCloseToasterWindow
   {
      
      private static const TOASTER_MAIN_TEXT_SIZE:Number = 11;
      
      private static const TOASTER_TEXT_OFFSET:int = -4;
      
      public function DreyersToasterWindow()
      {
         super(DreyersPromoManager.getToasterAssetPath());
      }
      
      override protected function postLoadComplete() : void
      {
         var toasterBodyText:ZwTextField = null;
         var textFormat:TextFormat = null;
         super.postLoadComplete();
         if(m_window)
         {
            toasterBodyText = new ZwTextField(m_window.generic_tf,DreyersPromoManager.getToasterLocalizedText(),true);
            textFormat = toasterBodyText.getTextFormat();
            textFormat.size = TOASTER_MAIN_TEXT_SIZE;
            toasterBodyText.setTextFormat(textFormat);
            toasterBodyText.y += TOASTER_TEXT_OFFSET;
            addWidget(toasterBodyText);
            addWidget(new FarmAnimatedButton(m_window.trade_bt,this.onTrade));
            addWidget(new FarmButton(m_window.closeCompleted_bt,this.onClose));
         }
      }
      
      override public function show() : void
      {
         DreyersPromoManager.countPromoToasterImpression();
         DreyersPromoManager.setToasterSeenFlag();
         super.show();
      }
      
      protected function onTrade(event:Event) : void
      {
         DreyersPromoManager.countPromoToasterClick();
         super.onClose(event);
         UI.displayMarketDialog("DreyersToaster","seed");
      }
      
      override protected function onClose(event:Event) : void
      {
         if(event.currentTarget.name == "closeCompleted_bt")
         {
            DreyersPromoManager.countPromoToasterClose();
         }
         super.onClose(event);
      }
   }
}

