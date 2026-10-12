package Display.Dialogs
{
   import Classes.EnglandOnboardingController;
   import Classes.util.ZLocUtils;
   import Display.FarmDynamicDialog;
   import Managers.FarmStatsManager;
   import com.troyer.widget.controller.BaseWidgetController;
   import com.troyer.widget.controller.ButtonController;
   import com.troyer.widget.controller.ImageController;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.style.BaseStyle;
   import com.troyer.widget.view.BaseWidgetView;
   import com.troyer.widget.view.TextFieldView;
   import flash.utils.Dictionary;
   
   public class NpcSpeechOnboarding extends NpcMultiSpeechBubble
   {
      
      public static const CANCEL_BUTTON_TEXT_IMPORT:String = "cancel_button_text_import";
      
      public static const INFO_ICON_ASSET_IMPORT:String = "info_icon_asset_import";
      
      public function NpcSpeechOnboarding(view:BaseWidgetView)
      {
         super(view);
      }
      
      override public function setup() : void
      {
         super.setup();
         this.setupCancel();
         this.setupInfoIcon();
         this.setupWhatsThisButton();
      }
      
      private function setupCancel() : void
      {
         var cancelButtonText:String = this.getImport(CANCEL_BUTTON_TEXT_IMPORT);
         this.getShortcutController("cancelButton").setAttribute(ButtonController.ATTRIBUTE_TEXT,"Cancel");
      }
      
      private function setupInfoIcon() : void
      {
         var iconUrl:String = this.getImport(INFO_ICON_ASSET_IMPORT);
         this.setShortcutAttribute("iconImage",ImageController.ATTRIBUTE_SOURCE,iconUrl);
      }
      
      private function setupWhatsThisButton() : void
      {
         var whatsThisController:BaseWidgetController = this.getShortcutController("whatsThis");
         whatsThisController.getChildController("whatIsThisButton").listen(WidgetControllerEvent.BUTTON_PRESSED,this.onWhatIsThisPress);
         var style:BaseStyle = new BaseStyle();
         var styleData:Dictionary = new Dictionary();
         var fontData:Dictionary = new Dictionary();
         fontData.name = "Merkin2";
         fontData.size = "11";
         fontData.embedded = "true";
         fontData.color = "0x54978f";
         styleData.fonts = [fontData];
         style.deserialize(styleData);
         (whatsThisController.getChildController("whatIsThisButton.pos.whatIsThisText").getView() as TextFieldView).setStyle(style);
         whatsThisController.getChildController("whatIsThisButton.pos.whatIsThisText").setAttribute(TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","MoreInfo"));
      }
      
      private function onWhatIsThisPress(event:WidgetControllerEvent) : void
      {
         FarmStatsManager.count(EnglandOnboardingController.ENGLAND_ONBOARDING_STATS_COUNTER,"more_info","FAQ");
         var dialog:FarmDynamicDialog = FarmDynamicDialog.createDialog("englandOnboardingFaq",EnglandOnboardingFaqDialog);
         dialog.setup();
         dialog.show();
      }
   }
}

