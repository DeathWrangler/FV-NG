package Display
{
   import Classes.Constants.CrossPromoConstants;
   import Classes.util.ZLocUtils;
   import Managers.CrossPromoManager;
   import Managers.FarmStatsManager;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.view.BaseWidgetView;
   import com.troyer.widget.view.TextFieldView;
   
   public class CityvilleLaunchPromoRound2Dialog extends FarmDynamicDialog
   {
      
      public function CityvilleLaunchPromoRound2Dialog(view:BaseWidgetView)
      {
         super(view);
      }
      
      public static function popDialog(name:String) : void
      {
         var visitCityDialog:CityvilleLaunchPromoRound2Dialog = FarmDynamicDialog.createDialog(name,CityvilleLaunchPromoRound2Dialog) as CityvilleLaunchPromoRound2Dialog;
         if(visitCityDialog)
         {
            visitCityDialog.addImport(name,null);
            visitCityDialog.setup();
            visitCityDialog.show();
         }
      }
      
      override public function setup() : void
      {
         this.setShortcutAttribute("messageText",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs",CrossPromoConstants.CITY_LAUNCH_XPROMO_ROUND2_PROMO_ID + "_message"));
         this.setShortcutListener("visitButton",WidgetControllerEvent.BUTTON_PRESSED,this.onVisitPressed);
         this.setShortcutAttribute("visitButton",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs",CrossPromoConstants.CITY_LAUNCH_XPROMO_ROUND2_PROMO_ID + "_accept"));
         this.setShortcutListener("closeButton",WidgetControllerEvent.BUTTON_PRESSED,this.onCancelPressed);
         this.setShortcutAttribute("closeButton",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs",CrossPromoConstants.CITY_LAUNCH_XPROMO_ROUND2_PROMO_ID + "_cancel"));
         FarmStatsManager.count(CrossPromoConstants.CITY_LAUNCH_XPROMO_ROUND2_PROMO_ID,"dialog","impressions");
      }
      
      private function onVisitPressed(event:WidgetControllerEvent) : void
      {
         CrossPromoManager.getInstance().startOutBoundPromo(CrossPromoConstants.CITY_LAUNCH_XPROMO_ROUND2_PROMO_ID);
         FarmStatsManager.count(CrossPromoConstants.CITY_LAUNCH_XPROMO_ROUND2_PROMO_ID,"dialog","visit");
         GlobalEngine.socialNetwork.redirect(CrossPromoConstants.CITY_ROUND2_URL,null,"_blank",false);
         destroy();
      }
      
      private function onCancelPressed(event:WidgetControllerEvent) : void
      {
         FarmStatsManager.count(CrossPromoConstants.CITY_LAUNCH_XPROMO_ROUND2_PROMO_ID,"dialog","cancel");
         destroy();
      }
   }
}

