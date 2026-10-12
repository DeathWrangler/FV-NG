package Display.Dialogs
{
   import Classes.util.ZLocUtils;
   import Display.FarmDynamicDialog;
   import com.troyer.widget.controller.ButtonController;
   import com.troyer.widget.controller.ImageController;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.view.BaseWidgetView;
   import com.troyer.widget.view.TextFieldView;
   
   public class NpcSpeechBubble extends FarmDynamicDialog
   {
      
      public static const LOC_BUNDLE_NAME_IMPORT:String = "locBundleName";
      
      public static const LOC_RESOURCE_NAME_IMPORT:String = "locResourceName";
      
      public static const BUTTON_TEXT_LOC_KEY_IMPORT:String = "buttonTextLocKey";
      
      public static const NPC_IMAGE_URL_IMPORT:String = "npcImageUrl";
      
      public static const BUTTON_CALLBACK_IMPORT:String = "buttonCallback";
      
      private var m_buttonCallback:Function;
      
      protected var m_bundleName:String;
      
      protected var m_resourceName:String;
      
      protected var m_singleTextBox:String;
      
      public function NpcSpeechBubble(view:BaseWidgetView)
      {
         super(view);
      }
      
      override public function setup() : void
      {
         super.setup();
         this.m_buttonCallback = this.getImport(BUTTON_CALLBACK_IMPORT);
         this.m_bundleName = this.getImport(LOC_BUNDLE_NAME_IMPORT);
         this.m_resourceName = this.getImport(LOC_RESOURCE_NAME_IMPORT);
         this.getSpeechText();
         this.setupSpeechText();
         this.setupButton();
         this.setupNpcImage();
      }
      
      protected function setupSpeechText() : void
      {
         this.setShortcutAttribute("bubbleText",TextFieldView.ATTRIBUTE_TEXT,this.m_singleTextBox);
      }
      
      protected function getSpeechText() : void
      {
         if(this.m_bundleName != null && this.m_resourceName != null)
         {
            this.m_singleTextBox = ZLocUtils.t(this.m_bundleName,this.m_resourceName + "_1");
         }
      }
      
      private function setupButton() : void
      {
         var buttonText:String = null;
         var buttonTextLocKey:String = this.getImport(BUTTON_TEXT_LOC_KEY_IMPORT);
         if(Boolean(buttonTextLocKey) && ZLocUtils.hasString(this.m_bundleName,buttonTextLocKey))
         {
            buttonText = ZLocUtils.t(this.m_bundleName,buttonTextLocKey);
         }
         else
         {
            buttonText = ZLocUtils.t("Dialogs","Okay");
         }
         this.setShortcutAttribute("okButton",ButtonController.ATTRIBUTE_TEXT,buttonText);
         this.getShortcutController("okButton").listen(WidgetControllerEvent.BUTTON_PRESSED,this.onButtonPress);
      }
      
      private function setupNpcImage() : void
      {
         var npcImageUrl:String = this.getImport(NPC_IMAGE_URL_IMPORT);
         if(npcImageUrl)
         {
            this.setShortcutAttribute("npcImage",ImageController.ATTRIBUTE_SOURCE,npcImageUrl);
         }
      }
      
      private function onButtonPress(event:WidgetControllerEvent) : void
      {
         if(this.m_buttonCallback != null)
         {
            this.m_buttonCallback(event);
         }
         this.destroy();
      }
   }
}

